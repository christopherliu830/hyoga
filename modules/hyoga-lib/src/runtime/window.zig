pub const math = @import("../math/math.zig");

pub const Window = extern struct {
    pub const setRelativeMouseMode = hywSetRelativeMouseMode;
    pub const dimensions = hywDimensions;
};

extern fn hywSetRelativeMouseMode(window: *Window, on_off: bool) void;
extern fn hywDimensions(window: *Window) math.Vec2;
