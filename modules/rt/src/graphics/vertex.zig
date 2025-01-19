const vec3 = @import("hyoga-lib").math.vec3;

pub const Vertex = struct {
    pos: [3]f32,
    normal: [3]f32,
    uv: [2]f32,
};
