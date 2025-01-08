const std = @import("std");
const sdl = @import("sdl");
const sdlsc = @import("sdl_shadercross");
const SlotMap = @import("hyoga-lib").SlotMap;
const Gpu = @import("gpu.zig");
const tx = @import("texture.zig");
const Mat4 = @import("hyoga-lib").math.Mat4;
const Vec3 = @import("hyoga-lib").math.Vec3;
const Strint = @import("../strintern.zig");

const max_uniform_limit = 8;
const empty_uniform_array = [_]Strint.ID { .invalid } ** 8;

pub const Handle = SlotMap(Material).Handle;

pub const MaterialTemplate = struct {
    pipeline: *sdl.gpu.GraphicsPipeline,
    vert_program_def: ShaderDefinition,
    frag_program_def: ShaderDefinition,
};

pub const Material = struct {
    pipeline: *sdl.gpu.GraphicsPipeline,
    vert_program_def: ShaderDefinition,
    frag_program_def: ShaderDefinition,
    textures: tx.TextureSet,

    pub fn fromTemplate(template: MaterialTemplate, textures: tx.TextureSet) Material {
        return Material {
            .pipeline = template.pipeline,
            .vert_program_def = template.vert_program_def,
            .frag_program_def = template.frag_program_def,
            .textures = textures
        };
    }
};

pub const ShaderDefinition = struct {
    num_samplers: u32 = 0,
    num_storage_textures: u32 = 0,
    num_storage_buffers: u32 = 0,
    num_uniform_buffers: u32 = 0,
    textures: [4]?tx.TextureType = [_]?tx.TextureType{ null } ** 4,
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
    vert: ?ProgramInfo = null,
    frag: ?ProgramInfo = null, 
};

pub const MaterialReadOptions = struct {
    path: []const u8,

    // Passed to build pipeline params
    format: ?sdl.gpu.TextureFormat = null,
    enable_depth: bool = true,
    enable_stencil: bool = true,
    fill_mode: sdl.gpu.FillMode = .fill,
};

pub fn readFromPath(gpu: *Gpu, options: MaterialReadOptions, allocator: std.mem.Allocator) !MaterialTemplate {
    const path = options.path;
    var arena_allocator = std.heap.ArenaAllocator.init(allocator);
    defer arena_allocator.deinit();
    const arena = arena_allocator.allocator();

    const info = loadMaterialInfo(path, arena) catch |err| {
        std.debug.panic("Could not read material json: {s}: {}", .{path, err});
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
    });

    var vert_textures: [4]?tx.TextureType = [_]?tx.TextureType { null } ** 4;
    var frag_textures: [4]?tx.TextureType = [_]?tx.TextureType { null } ** 4;
    var vert_uniforms: [max_uniform_limit]Strint.ID = empty_uniform_array;
    var frag_uniforms: [max_uniform_limit]Strint.ID = empty_uniform_array;
    var vert_storages: [max_uniform_limit]Strint.ID = empty_uniform_array;
    var frag_storages: [max_uniform_limit]Strint.ID = empty_uniform_array;

    inline for (.{
        .{ info.vert, &vert_textures, &vert_uniforms, &vert_storages }, 
        .{ info.frag, &frag_textures, &frag_uniforms, &frag_storages },
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
                        std.debug.panic("Invalid RSL for {s}: Requested invalid texture of type {s}", .{
                            options.path,
                            name
                        });
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


    return MaterialTemplate {
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
    const info_path = try std.mem.concat(arena, u8, &.{path, ".rsl.json"});
    const info_file = try std.fs.cwd().openFile(info_path, .{});
    const info_bytes = try info_file.readToEndAlloc(arena, 1024 * 16);
    info_file.close();
    return try std.json.parseFromSliceLeaky(MaterialSpec, arena, info_bytes, .{});
}

pub fn loadShader(device: *sdl.gpu.Device,
                  stage: sdl.gpu.ShaderStage,
                  path: []const u8, out_info:
                  ?*sdlsc.GraphicsShaderMetadata,
                  arena: std.mem.Allocator) !*sdl.gpu.Shader
{
    const full_path = switch(stage) {
        .vertex => try std.mem.concat(arena, u8, &.{path, ".vert.spv"}),
        .fragment => try std.mem.concat(arena, u8, &.{path, ".frag.spv"}),
    };
    
    const sdlsc_stage: sdlsc.ShaderStage = switch(stage) {
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
