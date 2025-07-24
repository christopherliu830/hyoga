pub const hym = @import("../math/math.zig");

pub const UI = opaque {
    pub const State = extern struct {
        imgui_ctx: ?*anyopaque,
        free_fn: ?*anyopaque,
        alloc_fn: ?*anyopaque,
        user_data: ?*anyopaque,
        clay_context: ?*anyopaque,
        clay_measure_text_fn: ?*anyopaque,
    };

    pub const InputState = extern struct {
        mouse_down: bool,
        mouse_position: hym.Vec2,
    };

    pub const getGlobalState = hyuiGetGlobalState;
    pub const inputState = hyuiInputState;

    extern fn hyuiGetGlobalState(*UI) State;
    extern fn hyuiInputState(ui: *UI) InputState;
};
