pub const hym = @import("../math/math.zig");

const proc_table = @import("proc_table.zig");
const proc = &proc_table.table;

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

pub const UI = opaque {
    pub fn inputState(ui: *UI) InputState {
        return proc.hy_ui_inputState(ui);
    }

    pub fn state(ui: *UI) State {
        return proc.hy_ui_globalState(ui);
    }
};
