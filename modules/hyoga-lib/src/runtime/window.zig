pub const Window = extern struct {
    pub const setRelativeMouseMode = hywSetRelativeMouseMode;
    pub const aspect = hywAspect;
};

extern fn hywSetRelativeMouseMode(window: *Window, on_off: bool) void;
extern fn hywAspect(window: *Window) f32;
