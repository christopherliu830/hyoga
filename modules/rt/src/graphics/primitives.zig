const std = @import("std");
const math = @import("std").math;
const hy = @import("hyoga-lib");
const hym = hy.math;

const Vertex = @import("vertex.zig").Vertex;

pub const Shape = enum(u8) {
    cube,
    quad,
    sphere,
};

pub const Cube = struct {
    vertices: [24]Vertex,
    indices: [36]u32,
    pub const bounds = hym.AxisAligned{
        .min = hym.vec3.create(-0.5, -0.5, -0.5),
        .max = hym.vec3.create(0.5, 0.5, 0.5),
    };
};

pub const cube: Cube = blk: {
    const vertices = [8][3]f32{
        .{ -0.5, -0.5, -0.5 },
        .{ -0.5, -0.5, 0.5 },
        .{ -0.5, 0.5, -0.5 },
        .{ -0.5, 0.5, 0.5 },
        .{ 0.5, -0.5, -0.5 },
        .{ 0.5, -0.5, 0.5 },
        .{ 0.5, 0.5, -0.5 },
        .{ 0.5, 0.5, 0.5 },
    };

    var c = Cube{
        .vertices = [_]Vertex{.{ .pos = .{ 0, 0, 0 }, .normal = .{ 0, 0, 0 }, .uv = .{ 0, 0 } }} ** 24,
        .indices = [_]u32{0} ** 36,
    };

    for (0..8) |i| {
        const index = i * 3;
        c.vertices[index].pos = vertices[i];
        c.vertices[index].normal = .{ vertices[i][0], 0, 0 };

        c.vertices[index + 1].pos = vertices[i];
        c.vertices[index + 1].normal = .{ 0, vertices[i][1], 0 };

        c.vertices[index + 2].pos = vertices[i];
        c.vertices[index + 2].normal = .{ 0, 0, vertices[i][2] };
    }

    var uv_mode: u32 = 0;
    for (0..8) |i| {
        for (0..3) |j| {
            switch (uv_mode) {
                0 => c.vertices[i * 3 + j].uv = .{ 0, 0 },
                1 => c.vertices[i * 3 + j].uv = .{ 1, 0 },
                2 => c.vertices[i * 3 + j].uv = .{ 0, 1 },
                else => unreachable,
            }
        }
        uv_mode = (uv_mode + 1) % 3;
    }

    c.indices = .{
        // TOP
        7,  19, 10,
        10, 19, 22,

        // BOTTOM
        4,  16, 1,
        1,  16, 13,

        // LEFT
        3,  0,  9,
        9,  0,  6,

        // RIGHT
        12, 15, 18,
        18, 15, 21,

        // FRONT
        2,  14, 8,
        8,  14, 20,

        // BACK
        17, 5,  23,
        23, 5,  11,
    };

    break :blk c;
};

pub const Quad = struct {
    vertices: [4]Vertex,
    indices: [6]u32,
    pub const bounds = hym.AxisAligned{
        .min = hym.vec3.create(-0.5, -0.5, 0),
        .max = hym.vec3.create(0.5, 0.5, 0),
    };
};

pub const quad: Quad = blk: {
    const pos = [4][3]f32{
        .{ -0.5, -0.5, 0 },
        .{ -0.5, 0.5, 0 },
        .{ 0.5, -0.5, 0 },
        .{ 0.5, 0.5, 0 },
    };

    const uvs = [4][2]f32{
        .{ 0, 1 },
        .{ 0, 0 },
        .{ 1, 1 },
        .{ 1, 0 },
    };

    var verts: [4]Vertex = undefined;

    for (0..4) |i| {
        verts[i] = .{ .pos = pos[i], .normal = .{ 0, 0, 1 }, .uv = uvs[i] };
    }

    break :blk .{
        .vertices = verts,
        .indices = .{ 0, 1, 3, 0, 3, 2 },
    };
};

pub const Sphere8 = struct {
    vertices: [58]Vertex,
    indices: [58]u32,

    pub const bounds: hym.AxisAligned = .{
        .min = .of(-0.5, -0.5, -0.5),
        .max = .of(0.5, 0.5, 0.5),
    };
};

pub fn createSphere() Sphere8 {
    const start: f64 = -math.pi / 2.0;
    const end: f64 = math.pi / 2.0;

    var tz = start;

    var verts: [58]Vertex = [_]Vertex{undefined} ** 58;
    const idxs: [58]u32 = std.simd.iota(u32, 58);

    var i: u32 = 0;
    while (tz <= end) {
        const v = hym.Vec3.of(@floatCast(math.cos(tz)), @floatCast(math.sin(tz)), 0);
        if (tz == start) {
            std.debug.print("ROW 0\n", .{});
            verts[i] = .{ .pos = v.v, .normal = v.v, .uv = .{ 0, 0 } };

            i += 1;
            std.debug.print("hello {}\n", .{i});
        } else if (tz == end) {
            std.debug.print("ROW 7\n", .{});
            verts[i] = .{ .pos = v.v, .normal = v.v, .uv = .{ 0, 0 } };
            i += 1;
            std.debug.print("hello {}\n", .{i});
        } else {
            std.debug.print("ROW N\n", .{});
            for (0..8) |j| {
                const r_v = hym.vec3.rotate(v, hym.vec3.py, (math.pi * 2.0 / 8.0) * @as(f32, @floatFromInt(j)));
                verts[i] = .{ .pos = r_v.v, .normal = r_v.v, .uv = .{ 0, 0 } };
                i += 1;
            }
            std.debug.print("hello {}\n", .{i});
        }
        tz += (end - start) / 8.0;
    }
    std.debug.print("hello {}\n", .{i});
    return .{
        .vertices = verts,
        .indices = idxs,
    };
}
