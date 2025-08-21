const std = @import("std");
const hy = @import("hyoga");
const hym = hy.math;

const verts: []const hym.Vec2 = &.{
    .of(0, 0),
    .of(2, -0.5),
    .of(3, 1.5),
    .of(6, -0.6),
    .of(7.4, 1.6),
};

pub fn main() !void {
    var dbg: std.heap.DebugAllocator(.{}) = .init;
    defer _ = dbg.deinit();
    const al = dbg.allocator();
    var sd: hym.triangle.CDT = try .init(al, verts);
    defer sd.deinit();

    try sd.remove(.of(3, 1.5));

    const tris = try sd.enumerate();
    defer sd.allocator.free(tris);

    for (sd.vertices.items) |vt| {
        std.debug.print("vts: {d} {d}\n", .{ vt.x(), vt.y() });
    }

    for (tris) |tri| {
        std.debug.print("tri: {f}\n", .{tri});
        std.debug.print("a: {f}\n", .{tri.sym()});
        std.debug.print("b: {f}\n", .{tri.lnext().sym()});
        std.debug.print("c: {f}\n", .{tri.lprev().sym()});
    }
}
