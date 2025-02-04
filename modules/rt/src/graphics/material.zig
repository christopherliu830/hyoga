const std = @import("std");
const hy = @import("hyoga-lib");
const sdl = @import("sdl");
const sdlsc = @import("sdl_shadercross");
const SlotMap = @import("hyoga-lib").SlotMap;
const Gpu = @import("gpu.zig");
const tx = @import("texture.zig");
const Mat4 = @import("hyoga-lib").math.Mat4;
const Vec3 = @import("hyoga-lib").math.Vec3;
const Strint = @import("../strintern.zig");

const panic = std.debug.panic;
const max_uniform_limit = 8;
const empty_uniform_array = [_]Strint.ID{.invalid} ** 8;

pub const Handle = SlotMap(Material).Handle;

pub const MaterialTemplate = struct {
    pipeline: *sdl.gpu.GraphicsPipeline,
    vert_program_def: ShaderDefinition,
    frag_program_def: ShaderDefinition,
};

pub const Materials = struct {
    gpu: *Gpu,
    param_buf: std.ArrayListUnmanaged(u8) = .{},
    materials: hy.SlotMap(Material) = .empty,
    templates: std.EnumArray(Material.Type, MaterialTemplate),

    pub fn init(gpu: *Gpu) Materials {
        return .{
            .gpu = gpu,
            .templates = .init(
                .{
                    .standard = readFromPath(gpu, .{
                        .path = "shaders/standard",
                        .enable_depth = true,
                    }, gpu.gpa) catch panic("error creating standard shader", .{}),
                    .sprite = readFromPath(gpu, .{
                        .path = "shaders/sprite",
                        .enable_depth = true,
                    }, gpu.gpa) catch panic("error creating sprite shader", .{}),
                    .post_process = readFromPath(gpu, .{
                        .path = "shaders/post_process",
                    }, gpu.gpa) catch panic("error creating post process shader", .{}),
                    .bw_mask = readFromPath(gpu, .{
                        .path = "shaders/outline",
                        .format = .r8_unorm,
                    }, gpu.gpa) catch panic("error creating bw shader", .{}),
                    .billboard = readFromPath(gpu, .{
                        .path = "shaders/billboard",
                        .enable_depth = true,
                    }, gpu.gpa) catch panic("error creating billboard shader", .{}),
                },
            ),
        };
    }

    pub fn insert(self: *Materials, mt_type: Material.Type, txs: tx.TextureSet) Handle {
        const template = self.templates.get(mt_type);
        const mat: Material = Material.fromTemplate(mt_type, template, self.param_buf.items.len, txs);
        self.param_buf.appendNTimes(self.gpu.gpa, 0, paramsSize(mt_type)) catch hy.err.oom();
        std.debug.assert(self.param_buf.items.len % 4 == 0);
        const hdl = self.materials.insert(self.gpu.gpa, mat) catch hy.err.oom();
        std.debug.print("mat inserting: {} {}-{}\n", .{ hdl.index, mat.params_start, self.param_buf.items.len });
        return hdl;
    }

    pub fn remove(self: *Materials, hdl: Handle) void {
        std.debug.print("mat Removing: {}\n", .{hdl});
        const mat = self.materials.get(hdl).?;
        const rm_start = mat.params_start;
        const rm_len = paramsSize(mat.params_type);

        if (rm_len > 0) {
            self.param_buf.replaceRangeAssumeCapacity(rm_start, rm_len, &.{});
            var it = self.materials.iterator();
            while (it.nextPtr()) |m| {
                if (m.params_start > rm_start) {
                    m.params_start -= rm_len;
                }
            }
        }

        self.materials.remove(hdl);
    }

    /// No guarantees for the lifetime of this generated material
    /// In addition, no parameters
    pub fn createWeak(self: *Materials, mt_type: Material.Type, txs: tx.TextureSet) Material {
        const template = self.templates.get(mt_type);
        return Material.fromTemplate(mt_type, template, 0, txs);
    }

    pub fn get(self: *Materials, handle: Handle) ?Material {
        return self.materials.get(handle);
    }

    pub fn setParams(self: *Materials, handle: Handle, data: *const anyopaque) void {
        const mat = self.get(handle).?;
        const bytes = self.param_buf.items[mat.params_start .. mat.params_start + paramsSize(mat.params_type)];
        std.debug.print("Insert material data {} -> {}\n", .{ handle.index, mat.params_start });
        const ptr: [*]const u8 = @ptrCast(data);
        @memcpy(bytes, ptr);
    }

    pub fn deinit(self: *Materials) void {
        self.gpu.device.releaseGraphicsPipeline(self.templates.get(.bw_mask).pipeline);
        self.gpu.device.releaseGraphicsPipeline(self.templates.get(.post_process).pipeline);
        self.gpu.device.releaseGraphicsPipeline(self.templates.get(.standard).pipeline);
        self.gpu.device.releaseGraphicsPipeline(self.templates.get(.billboard).pipeline);
        self.gpu.device.releaseGraphicsPipeline(self.templates.get(.sprite).pipeline);
        self.param_buf.deinit(self.gpu.gpa);
        self.materials.deinit(self.gpu.gpa);
    }
};

pub const Material = struct {
    pub const Type = enum(u32) {
        standard,
        sprite,
        post_process,
        bw_mask,
        billboard,

        comptime {
            hy.meta.assertMatches(Type, hy.Gpu.MaterialType);
        }
    };

    pipeline: *sdl.gpu.GraphicsPipeline,
    vert_program_def: ShaderDefinition,
    frag_program_def: ShaderDefinition,
    params_start: usize,
    params_type: Type,
    textures: tx.TextureSet,

    pub fn fromTemplate(
        template_type: Material.Type,
        template: MaterialTemplate,
        param_start: usize,
        textures: tx.TextureSet,
    ) Material {
        return .{
            .pipeline = template.pipeline,
            .vert_program_def = template.vert_program_def,
            .frag_program_def = template.frag_program_def,
            .textures = textures,
            .params_start = param_start,
            .params_type = template_type,
        };
    }

    pub fn deinit(self: *Material, textures: *tx.Textures) void {
        var it = self.textures.iterator();
        while (it.next()) |entry| {
            if (entry.value.handle) |hdl| {
                textures.destroy(hdl);
            }
        }
    }
};

pub const ShaderDefinition = struct {
    num_samplers: u32 = 0,
    num_storage_textures: u32 = 0,
    num_storage_buffers: u32 = 0,
    num_uniform_buffers: u32 = 0,
    textures: [4]?tx.TextureType = [_]?tx.TextureType{null} ** 4,
    storage_buffers: [max_uniform_limit]Strint.ID,
    uniforms: [max_uniform_limit]Strint.ID,
};

// Specification for the resource JSON
pub const MaterialSpec = struct {
    pub const ProgramInfo = struct {
        uniforms: ?[][]const u8 = null,
        samplers: ?[][]const u8 = null,
        storage_buffers: ?[][]const u8 = null,
    };

    pass: Gpu.PassType,
    vertex: ?ProgramInfo = null,
    fragment: ?ProgramInfo = null,
};

pub const MaterialReadOptions = struct {
    path: [:0]const u8,

    // Passed to build pipeline params
    format: ?sdl.gpu.TextureFormat = null,
    enable_depth: bool = false,
    enable_stencil: bool = false,
    fill_mode: sdl.gpu.FillMode = .fill,
    primitive_type: sdl.gpu.PrimitiveType = .trianglelist,
};

pub fn readFromPath(gpu: *Gpu, options: MaterialReadOptions, allocator: std.mem.Allocator) !MaterialTemplate {
    const path = options.path;
    var arena_allocator = std.heap.ArenaAllocator.init(allocator);
    defer arena_allocator.deinit();
    const arena = arena_allocator.allocator();

    const info = loadMaterialInfo(path, arena) catch |err| {
        std.debug.panic("Could not read material json: {s}: {}", .{ path, err });
    };

    var vert_info: sdlsc.GraphicsShaderMetadata = undefined;
    const vert_shader = try loadShader(gpu.device, .vertex, path, &vert_info, arena);
    defer gpu.device.releaseShader(vert_shader);

    var frag_info: sdlsc.GraphicsShaderMetadata = undefined;
    const frag_shader = try loadShader(gpu.device, .fragment, path, &frag_info, arena);
    defer gpu.device.releaseShader(frag_shader);

    const pipeline = gpu.buildPipeline(.{
        .format = options.format,
        .vert = vert_shader,
        .frag = frag_shader,
        .pass = info.pass,
        .enable_depth = options.enable_depth,
        .enable_stencil = options.enable_stencil,
        .fill_mode = options.fill_mode,
        .primitive_type = options.primitive_type,
    });

    var vert_textures: [4]?tx.TextureType = [_]?tx.TextureType{null} ** 4;
    var frag_textures: [4]?tx.TextureType = [_]?tx.TextureType{null} ** 4;
    var vert_uniforms: [max_uniform_limit]Strint.ID = empty_uniform_array;
    var frag_uniforms: [max_uniform_limit]Strint.ID = empty_uniform_array;
    var vert_storages: [max_uniform_limit]Strint.ID = empty_uniform_array;
    var frag_storages: [max_uniform_limit]Strint.ID = empty_uniform_array;

    inline for (.{
        .{ info.vertex, &vert_textures, &vert_uniforms, &vert_storages },
        .{ info.fragment, &frag_textures, &frag_uniforms, &frag_storages },
    }) |opts| {
        const prog = opts[0];
        const prog_textures = opts[1];
        const prog_uniforms = opts[2];
        const prog_storages = opts[3];
        // Convert specified requested samplers in JSON to an array of enum values
        if (prog != null) {
            if (prog.?.samplers) |samplers| {
                for (samplers, 0..) |name, i| {
                    var tex_type: ?tx.TextureType = undefined;

                    inline for (@typeInfo(tx.TextureType).@"enum".fields) |field| {
                        if (std.mem.eql(u8, name, field.name)) {
                            tex_type = @enumFromInt(field.value);
                            break;
                        }
                    }

                    if (tex_type == null) {
                        std.debug.panic("Invalid RSL for {s}: Requested invalid texture of type {s}", .{ options.path, name });
                    }

                    prog_textures[i] = tex_type;
                }
            }
            if (prog.?.uniforms) |uniforms| {
                for (uniforms, 0..) |uniform, i| {
                    const id = try gpu.strint.from(uniform);
                    prog_uniforms[i] = id;
                }
            }
            if (prog.?.storage_buffers) |storages| {
                for (storages, 0..) |storage, i| {
                    const id = try gpu.strint.from(storage);
                    prog_storages[i] = id;
                }
            }
        }
    }

    return .{
        .pipeline = pipeline,
        .vert_program_def = .{
            .num_samplers = vert_info.num_samplers,
            .num_storage_textures = vert_info.num_storage_textures,
            .num_storage_buffers = vert_info.num_storage_buffers,
            .num_uniform_buffers = vert_info.num_uniform_buffers,
            .textures = vert_textures,
            .storage_buffers = vert_storages,
            .uniforms = vert_uniforms,
        },
        .frag_program_def = .{
            .num_samplers = frag_info.num_samplers,
            .num_storage_textures = frag_info.num_storage_textures,
            .num_storage_buffers = frag_info.num_storage_buffers,
            .num_uniform_buffers = frag_info.num_uniform_buffers,
            .textures = frag_textures,
            .storage_buffers = vert_storages,
            .uniforms = frag_uniforms,
        },
    };
}

pub fn loadMaterialInfo(path: []const u8, arena: std.mem.Allocator) !MaterialSpec {
    const info_path = try std.mem.concat(arena, u8, &.{ path, ".rsl.json" });
    const info_file = try std.fs.cwd().openFile(info_path, .{});
    const info_bytes = try info_file.readToEndAlloc(arena, 1024 * 16);
    info_file.close();
    return try std.json.parseFromSliceLeaky(MaterialSpec, arena, info_bytes, .{});
}

pub fn loadShader(device: *sdl.gpu.Device, stage: sdl.gpu.ShaderStage, path: []const u8, out_info: ?*sdlsc.GraphicsShaderMetadata, arena: std.mem.Allocator) !*sdl.gpu.Shader {
    const full_path = switch (stage) {
        .vertex => try std.mem.concat(arena, u8, &.{ path, ".vert.spv" }),
        .fragment => try std.mem.concat(arena, u8, &.{ path, ".frag.spv" }),
    };

    const sdlsc_stage: sdlsc.ShaderStage = switch (stage) {
        .vertex => .vertex,
        .fragment => .fragment,
    };

    const file = try std.fs.cwd().openFile(full_path, .{});
    defer file.close();
    const code = try file.readToEndAlloc(arena, 1024 * 16);

    var info = try sdlsc.reflectGraphicsSpirv(code);
    if (out_info) |ptr| {
        ptr.* = info;
    }

    return try sdlsc.compileGraphicsShaderFromSpirv(device, sdlsc_stage, .{
        .bytecode = code,
        .entrypoint = if (stage == .vertex) "vertexMain" else "fragmentMain",
        .debug = true,
        .name = "hyoga shader",
    }, &info);
}

/// Get the required struct size in bytes based on a material's type
pub fn paramsSize(mt_type: Material.Type) usize {
    return switch (mt_type) {
        .sprite, .billboard => (@sizeOf(Gpu.GpuSprite) + 3) / 4 * 4,
        else => 0,
    };
}
