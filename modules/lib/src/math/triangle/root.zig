const std = @import("std");
const hym = @import("../math.zig");

pub const vertex_face = @import("vertex_face.zig");
pub const quad_edge = @import("quad_edge.zig");

pub const Triangulation = vertex_face.Subdivision;
pub const Visibility = vertex_face.Visibility;

pub const VertexHandle = enum(usize) {
    none = std.math.maxInt(usize),
    _,

    pub fn make(i: usize) VertexHandle {
        return @enumFromInt(i);
    }

    pub fn unwrap(self: VertexHandle) usize {
        return @intFromEnum(self);
    }
};

test {
    std.testing.refAllDecls(@This());
}
