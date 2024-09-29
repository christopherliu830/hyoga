const Vertex = @import("vertex.zig").Vertex;

pub const Cube = struct {
    vertices: [24]Vertex,
    indices: [36]u16,
};

pub fn createCube() Cube {
    const vertices = [8][3]f32 {
        .{-0.5, -0.5, -0.5},
        .{-0.5, -0.5,  0.5},
        .{-0.5,  0.5, -0.5},
        .{-0.5,  0.5,  0.5},
        .{ 0.5, -0.5, -0.5},
        .{ 0.5, -0.5,  0.5},
        .{ 0.5,  0.5, -0.5},
        .{ 0.5,  0.5,  0.5},
    };

    const cube = Cube {
        .vertices = .{ .{0, 0, 0} ** 24 },
        .indices = 0 ** 36,
    };

    inline for (0..8) |i| {
        const index = i * 3;
        cube.vertices[index].pos = vertices[i];
        cube.vertices[index].normal = .{ vertices[i][0], 0, 0 };
        cube.vertices[index].uv = .{ 0, 0 };

        cube.vertices[index + 1].pos = vertices[i];
        cube.vertices[index + 1].normal = .{ 0, vertices[i][1], 0 };
        cube.vertices[index + 1].uv = .{ 1, 0 };

        cube.vertices[index + 2].pos = vertices[i];
        cube.vertices[index + 2].normal = .{ 0, 0, vertices[i][2] };
        cube.vertices[index + 2].uv = .{ 0, 1 };
    }

    cube.indices = .{
        // TOP
        7, 19, 10,
        10, 19, 22,

        // BOTTOM
        4, 16, 1,
        1, 16, 13,

        // LEFT
        3, 0, 9,
        9, 0, 6,

        // RIGHT
        12, 15, 18,
        18, 15, 21,

        // FRONT
        2, 14, 8,
        8, 14, 20,

        // BACK
        17, 5, 23,
        23, 5, 11,
    };
}