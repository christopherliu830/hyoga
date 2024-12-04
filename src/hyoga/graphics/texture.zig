const std = @import("std");
const sdl = @import("sdl");
const ai = @import("assimp");

const hya = @import("hyoga-arena");

pub const Arena = hya.Arena(*sdl.gpu.Texture);

pub const Handle = Arena.Handle;

pub const Cache = std.StringHashMap(Handle);

pub const TextureSet = std.EnumMap(TextureType, Handle);

pub const TextureType = enum {
    diffuse,
    specular,
    height,
    normal,
};

pub const TextureView = struct {
    hdl: Handle,
    type: TextureType,
};

pub const TextureMemory = struct {
    w: u32,
    h: u32,
    d: u32 = 1,
    data: []const u8,
    format: sdl.gpu.TextureFormat = .r8g8b8a8_unorm
};

pub const tex_to_hyoga_type = std.EnumMap(ai.TextureType, TextureType).init(.{
    .diffuse = .diffuse,
    .specular = .specular,
    .height = .height,
    .normals = .normal,
});
