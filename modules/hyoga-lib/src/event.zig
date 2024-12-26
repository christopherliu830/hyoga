const Vec2 = @import("math/vec2.zig").Vec2;

pub const MouseMotion = struct {
    position: Vec2,
    delta: Vec2,
};

pub const MouseWheel = struct {
    delta: f32 = 0,
};