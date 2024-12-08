const std = @import("std");
const hy = @import("hyoga");

pub const State = struct {
    second_timer: std.time.Timer, // Timer that ticks every second
    window_timing_open: bool = false,
    frame_time: u64 = 0,
    drawn_frame_time: u64 = 0,

    pub fn create() !State {
        return .{
            .second_timer = try std.time.Timer.start(),
        };
    }
};

pub fn drawMainUI(state: *State) void {
    if (state.second_timer.read() > 1 * std.time.ns_per_s) {
        state.second_timer.reset();
        state.drawn_frame_time = state.frame_time;
    }

    const ui = hy.ui.imgui;
    if (ui.BeginMainMenuBar()) {
        if (ui.MenuItem("Timings")) {
            state.window_timing_open = !state.window_timing_open;
        }
        ui.EndMainMenuBar();
    }

    if (state.window_timing_open) {
        if (ui.Begin("Timings", &state.window_timing_open, 0)) {
            const fps: f32 = 1 / (@as(f32, @floatFromInt(state.drawn_frame_time)) / std.time.ns_per_s);
            ui.Text("Frame time: %.2fms (%.1f)fps", 
                @as(f32, @floatFromInt(state.drawn_frame_time)) / std.time.ns_per_ms,
                fps);
        }
        ui.End();
    }
}