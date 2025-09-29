const std = @import("std");
const hym = @import("../math.zig");

pub const vertex_face = @import("vertex_face.zig");
pub const quad_edge = @import("quad_edge.zig");

pub const CDT = vertex_face.CDT;
pub const Triangle = vertex_face.Triangle.Ref;
pub const VisibilityPolygon = vertex_face.VisibilityPolygon;

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
