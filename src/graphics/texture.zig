const hyarena = @import("../genarray.zig");

pub const Arena = hyarena.GenArray(Texture);

pub const Handle = Arena.Handle;

pub const Texture = struct {
    id: u8,
    tex_type: []const u8,
};

