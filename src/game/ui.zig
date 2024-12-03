const std = @import("std");
const hy = @import("hyoga");

pub const State = struct {
    window_timing_open: bool = false,
};

pub fn drawMainUI(state: *State) void {
    const ui = hy.ui.imgui;
    if (ui.beginMainMenuBar()) {
        if (ui.menuItem_Bool("Timings", null, false, true)) {
            state.window_timing_open = !state.window_timing_open;
        }
        ui.endMainMenuBar();
    }

    std.debug.print("{}\n", state.*);
    if (state.window_timing_open) {
        if (ui.begin("Timings", &state.window_timing_open, 0)) {

        }
        ui.end();
    }
}