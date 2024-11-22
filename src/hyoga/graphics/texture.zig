const std = @import("std");
const sdl = @import("sdl");

const hya = @import("hyoga-arena");

pub const Arena = hya.Arena(*sdl.gpu.Texture);

pub const Handle = Arena.Handle;

pub const Cache = std.StringHashMap(Handle);

pub const TextureType = enum {
    diffuse,
    specular,
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