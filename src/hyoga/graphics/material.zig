const std = @import("std");
const sdl = @import("sdl");
const gpu = @import("gpu.zig");
const tx = @import("texture.zig");
const Mat4 = @import("hyoga-math").Mat4;
const Vec3 = @import("hyoga-math").Vec3;

pub const Material = struct {
    pipeline: *sdl.gpu.GraphicsPipeline,
    vert_program_def: ShaderDefinition,
    frag_program_def: ShaderDefinition,
    textures: []const tx.TextureView = &.{},
};

pub const MvpUniformGroup = extern struct {
    model: Mat4,
    inverse_model: Mat4,
    view_proj: Mat4,
};

pub const LightingUBO = extern struct {
    light_dir: Vec3,
    camera_pos: Vec3
};

pub const ShaderDefinition = struct {
    uniform_location_mvp: ?u32 = null,
    uniform_location_lighting: ?u32 = null,
    textures: [4]?tx.TextureType = [_]?tx.TextureType{ null } ** 4,
};


pub const ProgramInfo = struct {
    uniforms: ?std.json.ArrayHashMap(u32) = null,
    samplers: ?std.json.ArrayHashMap(u32) = null,
};

pub const MaterialInfo = struct {
    pass: gpu.PassType,
    vert: ProgramInfo,
    frag: ProgramInfo, 
};

pub fn readFromPath(device: *sdl.gpu.Device, path: []const u8, parent_allocator: std.mem.Allocator) !Material {
    var arena = std.heap.ArenaAllocator.init(parent_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    
    const info_path = try std.mem.concat(allocator, u8, &.{path, ".json"});
    const info_file = try std.fs.cwd().openFile(info_path, .{});
    defer info_file.close();
    const info_bytes = try info_file.readToEndAlloc(allocator, 4096);
    const info = try std.json.parseFromSliceLeaky(MaterialInfo, allocator, info_bytes, .{});

    const v_sampler_count = if (info.vert.samplers) |s| s.map.count() else 0;
    const v_uniform_count = if (info.vert.uniforms) |u| u.map.count() else 0;
    const vert_path = try std.mem.concat(allocator, u8, &.{path, ".vert.spv"});
    const vert_file = try std.fs.cwd().openFile(vert_path, .{});
    defer vert_file.close();
    const vert_code = try vert_file.readToEndAlloc(allocator, 4096);
    const vert_shader = try device.createShader(.{
        .code = vert_code.ptr,
        .code_size = @intCast(vert_code.len),
        .entrypoint = "main",
        .format = .{ .spirv = true },
        .num_samplers = @intCast(v_sampler_count),
        .num_storage_textures = 0,
        .num_storage_buffers = 0,
        .num_uniform_buffers = @intCast(v_uniform_count),
    });
    defer device.releaseShader(vert_shader);

    const f_sampler_count = if (info.frag.samplers) |s| s.map.count() else 0;
    const f_uniform_count = if (info.frag.uniforms) |u| u.map.count() else 0;
    const frag_path = try std.mem.concat(allocator, u8, &.{path, ".frag.spv"});
    const frag_file = try std.fs.cwd().openFile(frag_path, .{});
    defer frag_file.close();
    const frag_code = try frag_file.readToEndAlloc(allocator, 4096);
    const frag_shader = try device.createShader(.{
        .code = frag_code.ptr,
        .code_size = @intCast(frag_code.len),
        .entrypoint = "main",
        .format = .{ .spirv = true },
        .num_samplers = @intCast(f_sampler_count),
        .num_storage_textures = 0,
        .num_storage_buffers = 0,
        .num_uniform_buffers = @intCast(f_uniform_count),
    }); 
    defer device.releaseShader(frag_shader);

    const pipeline= gpu.buildPipeline(.{
        .enable_depth = true,
        .enable_stencil = true,
        .vert = vert_shader,
        .frag = frag_shader,
        .pass = info.pass,
    });

    const v_uniform_mvp = if (info.vert.uniforms) |x| x.map.get("mvp") else null;
    const v_uniform_lighting = if (info.vert.uniforms) |x| x.map.get("lighting") else null;
    const f_uniform_mvp = if (info.frag.uniforms) |x| x.map.get("mvp") else null;
    const f_uniform_lighting = if (info.frag.uniforms) |x| x.map.get("lighting") else null;
    
    var vert_textures: [4]?tx.TextureType = [_]?tx.TextureType { null } ** 4;
    if (info.vert.samplers) |samplers| {
        var it = samplers.map.iterator();
        while (it.next()) |entry| {
            var tex_type: tx.TextureType = undefined;
            if (std.mem.eql(u8, entry.key_ptr.*, "diffuse")) {
                tex_type = .diffuse;
            } else if (std.mem.eql(u8, entry.key_ptr.*, "specular")) {
                tex_type = .specular;
            } else {
                std.debug.panic("Texture type key not found!", .{});
            }
            vert_textures[entry.value_ptr.*] = tex_type;
        }
    }

    var frag_textures: [4]?tx.TextureType = [_]?tx.TextureType { null } ** 4;
    if (info.frag.samplers) |samplers| {
        var it = samplers.map.iterator();
        while (it.next()) |entry| {
            var tex_type: tx.TextureType = undefined;
            if (std.mem.eql(u8, entry.key_ptr.*, "diffuse")) {
                tex_type = .diffuse;
            } else if (std.mem.eql(u8, entry.key_ptr.*, "specular")) {
                tex_type = .specular;
            } else {
                std.debug.panic("Texture type key not found!", .{});
            }
            frag_textures[entry.value_ptr.*] = tex_type;
        }
    }

    return Material {
        .pipeline = pipeline,
        .vert_program_def = .{
            .uniform_location_mvp = v_uniform_mvp,
            .uniform_location_lighting = v_uniform_lighting,
            .textures = vert_textures,
        },
        .frag_program_def = .{
            .uniform_location_mvp = f_uniform_mvp,
            .uniform_location_lighting = f_uniform_lighting,
            .textures = frag_textures,
        },
    };
}
