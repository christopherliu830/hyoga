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

pub fn Sphere(size: usize) type {
    const caps = 2;
    const rings = size - 1;
    const vert_size = size * rings + caps;
    const idx_size = 3 * (size * caps + 2 * size * (rings - 1));

    return struct {
        vertices: [vert_size]Vertex,
        indices: [idx_size]u32,
        pub fn make() @This() {
            const start: f64 = -math.pi / 2.0;
            const end: f64 = math.pi / 2.0;

            var vert_buf: [vert_size]Vertex = undefined;
            var vert_list: std.ArrayListUnmanaged(Vertex) = .{
                .items = vert_buf[0..0],
                .capacity = vert_size,
            };

            var idx_buf: [idx_size]u32 = undefined;
            var idx_list: std.ArrayListUnmanaged(u32) = .{
                .items = idx_buf[0..0],
                .capacity = idx_size,
            };

            var tz = start;

            const pitch = (end - start) / @as(f32, @floatFromInt(size));
            const stride = math.pi * 2.0 / @as(f32, @floatFromInt(size));

            for (0..size + 1) |row| {
                const pole_pos = hym.Vec3.of(@floatCast(math.cos(tz)), @floatCast(math.sin(tz)), 0).normal().div(2);

                // Bottom cap, top cap
                if (tz == start) {
                    vert_list.appendAssumeCapacity(.{ .pos = pole_pos.v, .normal = pole_pos.v, .uv = .{ 0, 0 } });
                }

                // First row
                else if (tz == start + pitch) {
                    for (0..size) |j| {
                        const vert_pos = hym.vec3.rotate(pole_pos, hym.vec3.py, stride * @as(f32, @floatFromInt(j)));
                        vert_list.appendAssumeCapacity(.{ .pos = vert_pos.v, .normal = vert_pos.v, .uv = .{ 0, 0 } });
                    }
                    inline for (0..size - 1) |i| {
                        idx_list.appendSliceAssumeCapacity(&.{ 0, 1 + i, 2 + i });
                    }
                    idx_list.appendSliceAssumeCapacity(&.{ 0, size, 1 });
                }

                // Last row
                else if (tz == end) {
                    vert_list.appendAssumeCapacity(.{ .pos = pole_pos.v, .normal = pole_pos.v, .uv = .{ 0, 0 } });
                    const end_idx = vert_size - 1;
                    inline for (0..size - 1) |i| {
                        idx_list.appendSliceAssumeCapacity(&.{
                            end_idx - size + i,
                            end_idx,
                            end_idx - size + i + 1,
                        });
                    }
                    idx_list.appendSliceAssumeCapacity(&.{
                        end_idx - 1,
                        end_idx,
                        end_idx - size,
                    });
                }
                // Second-seventh rows
                else {
                    // Previous row's vertices
                    const p: @Vector(size, u32) = blk: {
                        var nums = std.simd.iota(u32, size);
                        nums += @splat(@intCast((row - 2) * size + 1));
                        break :blk nums;
                    };

                    for (0..size) |j| {
                        const vert_pos = hym.vec3.rotate(pole_pos, hym.vec3.py, stride * @as(f32, @floatFromInt(j)));
                        vert_list.appendAssumeCapacity(.{ .pos = vert_pos.v, .normal = vert_pos.v, .uv = .{ 0, 0 } });
                    }

                    // Current row's vertices
                    const c: @Vector(size, u32) = p + @as(@Vector(size, u32), @splat(size));

                    inline for (0..size - 1) |i| {
                        idx_list.appendSliceAssumeCapacity(&.{
                            p[i], c[i], c[i + 1], p[i], c[i + 1], p[i + 1],
                        });
                    }
                    idx_list.appendSliceAssumeCapacity(&.{
                        p[size - 1], c[size - 1], c[0], p[size - 1], c[0], p[0],
                    });
                }

                tz += pitch;
            }

            std.debug.print("IDX: {}\n", .{idx_list.items.len});

            return .{
                .vertices = vert_buf,
                .indices = idx_buf,
            };
        }
    };
}

pub fn createSphere() Sphere(16) {
    return .make();
}
