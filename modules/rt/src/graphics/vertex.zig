const vec3 = @import("hyoga-lib").math.vec3;

pub const Vertex = struct {
    pos: [3]f32,
    normal: [3]f32,
    uv: [2]f32,
};

pub const UIVertex = struct {
    pos: [2]f32 = .{ 0, 0 },
    uv: [2]f32 = .{ 0, 0 },
    color: [4]f32 = .{ 0, 0, 0, 0 },
};
