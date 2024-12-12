const std = @import("std");
const sdl = @import("sdl");
const sdlsc = @import("sdl_shadercross");
const hya = @import("hyoga-arena");
const Gpu = @import("gpu.zig");
const tx = @import("texture.zig");
const Mat4 = @import("hyoga-math").Mat4;
const Vec3 = @import("hyoga-math").Vec3;

pub const Handle = hya.Arena(Material).Handle;

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


// Specification for the resource JSON
pub const MaterialInfo = struct {
    pub const ProgramInfo = struct {
        uniforms: ?std.json.ArrayHashMap(u32) = null,
        samplers: ?std.json.ArrayHashMap(u32) = null,
    };

    pass: Gpu.PassType,
    vert: ProgramInfo,
    frag: ProgramInfo, 
};

pub fn readFromPath(gpu: *Gpu, path: []const u8, arena: std.mem.Allocator) !MaterialTemplate {
    const info = try loadMaterialInfo(path, arena);


    const vert_shader = try loadShader(gpu.device, .vertex, path, arena);
    defer gpu.device.releaseShader(vert_shader);

    const frag_shader = try loadShader(gpu.device, .fragment, path, arena);
    defer gpu.device.releaseShader(frag_shader);

    const pipeline = gpu.buildPipeline(.{
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

    // Convert specified requested samplers to enum values
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

    return MaterialTemplate {
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

pub fn loadMaterialInfo(path: []const u8, arena: std.mem.Allocator) !MaterialInfo {
    const info_path = try std.mem.concat(arena, u8, &.{path, ".rsl.json"});
    const info_file = try std.fs.cwd().openFile(info_path, .{});
    const info_bytes = try info_file.readToEndAlloc(arena, 1024 * 16);
    info_file.close();
    return try std.json.parseFromSliceLeaky(MaterialInfo, arena, info_bytes, .{});
}

pub fn loadShader(device: *sdl.gpu.Device, stage: sdl.gpu.ShaderStage, path: []const u8, arena: std.mem.Allocator) !*sdl.gpu.Shader {
    const full_path = switch(stage) {
        .vertex => try std.mem.concat(arena, u8, &.{path, ".vert.spv"}),
        .fragment => try std.mem.concat(arena, u8, &.{path, ".frag.spv"}),
    };

    const file = try std.fs.cwd().openFile(full_path, .{});
    defer file.close();
    const code = try file.readToEndAlloc(arena, 1024 * 16);

    var shader_info = try sdlsc.reflectGraphicsSpirv(code);

    return try sdlsc.compileGraphicsShaderFromSpirv(device, stage, .{
        .bytecode = code,
        .entrypoint = "main",
    }, &shader_info);
}
