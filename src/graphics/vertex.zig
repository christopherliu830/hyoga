const vec3 = @import("../hym/vec3.zig");

pub const Vertex = struct {
    pos: [3]f32,
    normal: [3]f32,
    uv: [2]f32,
};