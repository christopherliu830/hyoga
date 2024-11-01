const std = @import("std");
const sdl = @import("sdl");
const hyarena = @import("../genarray.zig");

pub const Arena = hyarena.Arena(*sdl.gpu.Texture);

pub const Handle = Arena.Handle;

pub const Cache = std.StringHashMap(Handle);

pub const TextureType = enum {
    diffuse,
    specular,
};

pub const TextureView = struct {
    hdl: Handle,
    tex_type: TextureType,
    path: []const u8,
};

