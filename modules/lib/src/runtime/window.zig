pub const math = @import("../math/math.zig");

pub const Window = extern struct {
    pub const setRelativeMouseMode = hywSetRelativeMouseMode;
    pub const dimensions = hywDimensions;
    pub const projectionMatrix = hywProjectionMatrix;
};

extern fn hywSetRelativeMouseMode(window: *Window, on_off: bool) void;
extern fn hywDimensions(window: *Window) math.Vec2;
extern fn hywProjectionMatrix(window: *Window) math.Mat4;
