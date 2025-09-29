const std = @import("std");
const hy = @import("hyoga");
const sdl = @import("sdl");
const sdlsc = @import("sdl_shadercross");
const SlotMap = @import("hyoga").SlotMap;
const Gpu = @import("gpu.zig");
const root = @import("root.zig");
const tx = @import("texture.zig");
const Mat4 = @import("hyoga").math.Mat4;
const Vec3 = @import("hyoga").math.Vec3;
const Strint = @import("../strintern.zig");

const panic = std.debug.panic;
const max_uniform_limit = 8;

pub const Handle = SlotMap(Material).Handle;

pub const ShaderDefinition = struct {
    num_samplers: u32 = 0,
    num_storage_textures: u32 = 0,
    num_storage_buffers: u32 = 0,
    num_uniform_buffers: u32 = 0,
    textures: [4]?hy.gfx.TextureType = @splat(null),
    storage_buffers: [max_uniform_limit]Strint.Index,
    uniforms: [max_uniform_limit]Strint.Index,
};

// Specification for the resource JSON
const PipelineInfo = struct {
    pub const ProgramInfo = struct {
        uniforms: ?[][]const u8 = null,
        samplers: ?[][]const u8 = null,
        storage_buffers: ?[][]const u8 = null,
    };

    fn load(path: []const u8, arena: std.mem.Allocator) !PipelineInfo {
        const info_path = try std.mem.concat(arena, u8, &.{ path, ".rsl.json" });
        const info_file = try std.fs.cwd().openFile(info_path, .{});
        const info_bytes = try info_file.readToEndAlloc(arena, 1024 * 16);
        info_file.close();
        return try std.json.parseFromSliceLeaky(PipelineInfo, arena, info_bytes, .{});
    }

    pass: root.PipelineType,
    alpha_blend: bool = true,
    vertex: ?ProgramInfo = null,
    fragment: ?ProgramInfo = null,
};

const MaterialInfo = struct {
    program: [:0]const u8,
    textures: std.json.ArrayHashMap(TextureInfo) = .{},
    params_size: u32 = 0,

    const TextureInfo = union(enum) {
        path: [:0]const u8,
        pass_result: [:0]const u8,
    };

    fn load(path: []const u8, arena: std.mem.Allocator) !MaterialInfo {
        const info_path = try std.mem.concat(arena, u8, &.{ path, ".mat.json" });
        const info_file = try std.fs.cwd().openFile(info_path, .{});
        const info_bytes = try info_file.readToEndAlloc(arena, 1024 * 16);
        info_file.close();
        return try std.json.parseFromSliceLeaky(MaterialInfo, arena, info_bytes, .{});
    }
};

pub const MaterialTemplate = struct {
    pipeline: *sdl.gpu.GraphicsPipeline,
    vert_program_def: ShaderDefinition,
    frag_program_def: ShaderDefinition,
};

pub const Materials = struct {
    gpu: *Gpu,
    param_buf: std.ArrayListUnmanaged(u32) = .{},
    materials: hy.SlotMap(Material) = .empty,
    templates: std.EnumArray(Material.Type, MaterialTemplate),

    pub fn init(gpu: *Gpu) Materials {
        return .{
            .gpu = gpu,
            .templates = .init(
                .{
                    .standard = readFromPath(gpu, .{
                        .path = "shaders/standard",
                    }) catch panic("error creating standard shader", .{}),
                    .standard_unlit = readFromPath(gpu, .{
                        .path = "shaders/standard_unlit",
                    }) catch panic("error creating standard_unlit shader", .{}),
                    .sprite = readFromPath(gpu, .{
                        .path = "shaders/sprite",
                    }) catch panic("error creating sprite shader", .{}),
                    .post_process = readFromPath(gpu, .{
                        .path = "shaders/post_process",
                    }) catch panic("error creating post_process shader", .{}),
                    .screen_blit = readFromPath(gpu, .{
                        .path = "shaders/screen_blit",
                    }) catch panic("error creating screen_blit shader", .{}),
                    .billboard = readFromPath(gpu, .{
                        .path = "shaders/billboard",
                    }) catch panic("error creating billboard shader", .{}),
                    .ui = readFromPath(gpu, .{
                        .path = "shaders/ui",
                    }) catch panic("error creating ui shader", .{}),
                    .ui_sdf = readFromPath(gpu, .{
                        .path = "shaders/ui_sdf",
                    }) catch panic("error creating ui shader", .{}),
                },
            ),
        };
    }

    pub fn load(self: *Materials, path: []const u8) !Handle {
        const path_dupe = try self.gpu.gpa.dupeZ(u8, path);
        const mat = try self.loadFromJson(path_dupe);
        const hdl = try self.materials.insert(self.gpu.gpa, mat);
        return hdl;
    }

    pub fn reload(self: *Materials, hdl: Handle) !void {
        const material = self.materials.getPtr(hdl).?;
        if (material.source_path) |path| {
            self.gpu.device.releaseGraphicsPipeline(material.pipeline);
            material.* = try self.loadFromJson(path);
        }
    }

    /// Does not assume ownership of the passed in path.
    fn loadFromJson(self: *Materials, path: [:0]const u8) !Material {
        const allocator = self.gpu.gpa;
        var ara = std.heap.ArenaAllocator.init(allocator);
        defer ara.deinit();
        const arena = ara.allocator();

        const material_info = MaterialInfo.load(path, arena) catch |e| {
            std.log.err("Error parsing material {s}: {}", .{ path, e });
            return e;
        };

        const template = readFromPath(self.gpu, .{
            .path = material_info.program,
        }) catch |e| {
            std.log.err("Read path failure: {s}\n", .{path});
            return e;
        };

        const param_size_u32s = (material_info.params_size + 3) / 4;
        self.param_buf.appendNTimes(self.gpu.gpa, 0, param_size_u32s) catch hy.err.oom();
        errdefer self.param_buf.replaceRangeAssumeCapacity(self.param_buf.items.len - param_size_u32s, param_size_u32s, &.{});

        var textures: root.TextureSet = .init(.{});

        var it = material_info.textures.map.iterator();
        while (it.next()) |entry| {
            const tag = std.meta.stringToEnum(hy.gfx.TextureType, entry.key_ptr.*) orelse {
                std.log.err("Unknown texture type {s} in material {s}", .{ entry.key_ptr.*, path });
                return error.MaterialLoadError;
            };

            const texture: tx.TextureId = switch (entry.value_ptr.*) {
                .path => |tx_path| .{ .handle = try self.gpu.textures.read(tx_path) },
                .pass_result => |tx_pass_name| .{ .pass_result = try self.gpu.string_table.from(tx_pass_name) },
            };

            textures.put(tag, texture);
        }

        return .{
            .source_path = path,
            .pipeline = template.pipeline,
            .vert_program_def = template.vert_program_def,
            .frag_program_def = template.frag_program_def,
            .textures = textures,
            .params_start = self.param_buf.items.len,
            .params_size = param_size_u32s,
        };
    }

    pub fn insert(self: *Materials, mt_type: Material.Type, txs: tx.TextureSet) Handle {
        const template = self.templates.get(mt_type);

        const param_size_u32s: u32 = switch (mt_type) {
            .sprite, .billboard => (@sizeOf(Gpu.Sprite) + 3) / 4,
            else => 0,
        };

        const mat: Material = Material.fromTemplate(template, self.param_buf.items.len, param_size_u32s, txs);
        self.param_buf.appendNTimes(self.gpu.gpa, 0, param_size_u32s) catch unreachable;
        const hdl = self.materials.insert(self.gpu.gpa, mat) catch unreachable;
        return hdl;
    }

    pub fn dupe(self: *Materials, hdl: Handle) !Handle {
        if (self.materials.get(hdl)) |mat| {
            const dupe_mat_hdl = self.materials.insert(self.gpu.gpa, undefined) catch unreachable;
            const dupe_mat = self.materials.getPtr(dupe_mat_hdl).?;
            dupe_mat.* = mat;

            dupe_mat.params_start = self.param_buf.items.len;
            self.param_buf.appendNTimes(self.gpu.gpa, 0, dupe_mat.params_size) catch unreachable;
            return dupe_mat_hdl;
        } else return error.NotFound;
    }

    pub fn remove(self: *Materials, hdl: Handle) void {
        if (self.materials.get(hdl)) |mat| {
            const rm_start = mat.params_start;
            const rm_len = mat.params_size;

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
    }

    /// No guarantees for the lifetime of this generated material
    /// In addition, no parameters
    pub fn createWeak(self: *Materials, mt_type: Material.Type, txs: tx.TextureSet) Material {
        const template = self.templates.get(mt_type);
        const param_size_u32s: u32 = switch (mt_type) {
            .sprite, .billboard => (@sizeOf(Gpu.Sprite) + 3) / 4,
            else => 0,
        };

        return Material.fromTemplate(template, 0, param_size_u32s, txs);
    }

    pub fn get(self: *Materials, handle: Handle) ?Material {
        return self.materials.get(handle);
    }

    pub fn getPtr(self: *Materials, handle: Handle) ?*Material {
        return self.materials.getPtr(handle);
    }

    pub fn setParams(self: *Materials, handle: Handle, data: *const anyopaque) void {
        const mat = self.get(handle).?;
        const bytes = self.param_buf.items[mat.params_start..][0..mat.params_size];
        const dst: []u8 = std.mem.sliceAsBytes(bytes);
        const ptr: [*]const u8 = @ptrCast(data);
        @memcpy(dst, ptr);
    }

    pub fn deinit(self: *Materials) void {
        var set: std.AutoHashMapUnmanaged(*sdl.gpu.GraphicsPipeline, void) = .empty;
        defer set.deinit(self.gpu.arena.allocator());

        inline for (std.meta.fields(Material.Type)) |tag| {
            const pipeline = self.templates.get(@enumFromInt(tag.value)).pipeline;
            if (!set.contains(pipeline)) {
                self.gpu.device.releaseGraphicsPipeline(pipeline);
                set.put(self.gpu.arena.allocator(), pipeline, {}) catch unreachable;
            }
        }

        var it = self.materials.iterator();
        while (it.next()) |mat| {
            if (!set.contains(mat.pipeline)) {
                self.gpu.device.releaseGraphicsPipeline(mat.pipeline);
                set.put(self.gpu.arena.allocator(), mat.pipeline, {}) catch unreachable;
            }
            if (mat.source_path) |path| {
                self.gpu.gpa.free(path);
            }
        }

        self.param_buf.deinit(self.gpu.gpa);
        self.materials.deinit(self.gpu.gpa);
    }
};

pub const Material = struct {
    pub const Type = hy.gfx.Program;

    source_path: ?[:0]const u8 = null,
    pipeline: *sdl.gpu.GraphicsPipeline,
    vert_program_def: ShaderDefinition,
    frag_program_def: ShaderDefinition,
    params_start: usize,
    params_size: u32,
    textures: tx.TextureSet,

    pub fn fromTemplate(
        template: MaterialTemplate,
        param_start: usize,
        param_size: u32,
        textures: tx.TextureSet,
    ) Material {
        return .{
            .pipeline = template.pipeline,
            .vert_program_def = template.vert_program_def,
            .frag_program_def = template.frag_program_def,
            .textures = textures,
            .params_start = param_start,
            .params_size = param_size,
        };
    }
};

pub const MaterialReadOptions = struct {
    path: [:0]const u8,

    // Passed to build pipeline params
    format: ?sdl.gpu.TextureFormat = null,
    fill_mode: sdl.gpu.FillMode = .fill,
    primitive_type: sdl.gpu.PrimitiveType = .trianglelist,
};

pub fn readFromPath(gpu: *Gpu, options: MaterialReadOptions) !MaterialTemplate {
    const allocator = gpu.gpa;
    const path = options.path;
    var arena_allocator = std.heap.ArenaAllocator.init(allocator);
    defer arena_allocator.deinit();
    const arena = arena_allocator.allocator();

    const info = PipelineInfo.load(path, arena) catch |err| {
        std.debug.panic("Could not read material json: {s}: {}", .{ path, err });
    };

    const vert_metadata, const vert_shader = try loadShader(gpu.device, .vertex, path, arena);
    defer gpu.device.releaseShader(vert_shader);
    defer sdl.free(vert_metadata);

    const frag_metadata, const frag_shader = try loadShader(gpu.device, .fragment, path, arena);
    defer gpu.device.releaseShader(frag_shader);
    defer sdl.free(frag_metadata);

    const pipeline = gpu.buildPipeline(.{
        .format = options.format,
        .vert = vert_shader,
        .frag = frag_shader,
        .pass = info.pass,
        .enable_depth = info.pass.hasDepth(),
        .enable_blend = info.alpha_blend,
        .enable_stencil = false,
        .fill_mode = options.fill_mode,
        .primitive_type = options.primitive_type,
    });

    var vert_textures: [4]?hy.gfx.TextureType = @splat(null);
    var frag_textures: [4]?hy.gfx.TextureType = @splat(null);
    var vert_uniforms: [max_uniform_limit]Strint.Index = @splat(.none);
    var frag_uniforms: [max_uniform_limit]Strint.Index = @splat(.none);
    var vert_storages: [max_uniform_limit]Strint.Index = @splat(.none);
    var frag_storages: [max_uniform_limit]Strint.Index = @splat(.none);

    inline for (.{
        .{ info.vertex, &vert_textures, &vert_uniforms, &vert_storages },
        .{ info.fragment, &frag_textures, &frag_uniforms, &frag_storages },
    }) |opts| {
        const mb_prog = opts[0];
        const prog_textures = opts[1];
        const prog_uniforms = opts[2];
        const prog_storages = opts[3];

        // Convert specified requested samplers in JSON to an array of enum values
        if (mb_prog) |prog| {
            if (prog.samplers) |samplers| {
                for (samplers, 0..) |name, i| {
                    if (std.meta.stringToEnum(hy.gfx.TextureType, name)) |tag| {
                        prog_textures[i] = tag;
                    } else {
                        std.debug.panic("Invalid RSL for {s}: Requested invalid texture of type {s}", .{ options.path, name });
                    }
                }
            }
            if (prog.uniforms) |uniforms| {
                for (uniforms, 0..) |uniform, i| {
                    const id = try gpu.string_table.from(uniform);
                    prog_uniforms[i] = id;
                }
            }
            if (prog.storage_buffers) |storages| {
                for (storages, 0..) |storage, i| {
                    const id = try gpu.string_table.from(storage);
                    prog_storages[i] = id;
                }
            }
        }
    }

    return .{
        .pipeline = pipeline,
        .vert_program_def = .{
            .num_samplers = vert_metadata.num_samplers,
            .num_storage_textures = vert_metadata.num_storage_textures,
            .num_storage_buffers = vert_metadata.num_storage_buffers,
            .num_uniform_buffers = vert_metadata.num_uniform_buffers,
            .textures = vert_textures,
            .storage_buffers = vert_storages,
            .uniforms = vert_uniforms,
        },
        .frag_program_def = .{
            .num_samplers = frag_metadata.num_samplers,
            .num_storage_textures = frag_metadata.num_storage_textures,
            .num_storage_buffers = frag_metadata.num_storage_buffers,
            .num_uniform_buffers = frag_metadata.num_uniform_buffers,
            .textures = frag_textures,
            .storage_buffers = frag_storages,
            .uniforms = frag_uniforms,
        },
    };
}

pub const LoadShaderResult = struct { *sdlsc.GraphicsShaderMetadata, *sdl.gpu.Shader };

pub fn loadShader(device: *sdl.gpu.Device, stage: sdl.gpu.ShaderStage, path: []const u8, arena: std.mem.Allocator) !LoadShaderResult {
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

    const metadata = try sdlsc.reflectGraphicsSpirv(code);
    errdefer sdl.free(metadata);

    const shader = try sdlsc.compileGraphicsShaderFromSpirv(device, sdlsc_stage, .{
        .bytecode = code,
        .entrypoint = "main",
        .debug = true,
        .name = path.ptr,
    }, metadata);

    return .{ metadata, shader };
}
