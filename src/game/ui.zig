const std = @import("std");
const hy = @import("hyoga");

const frames_slice_len = 128;

pub const State = struct {
    second_timer: std.time.Timer, // Timer that ticks every second
    window_timing_open: bool = false,
    frame_time: u64 = 0,
    drawn_frame_time: u64 = 0,
    frame_times: [frames_slice_len]f64 = [_]f64{0} ** frames_slice_len,
    current_frame_time_idx: u8 = 0,
    restart_requested: bool = false, 

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

    const ui = hy.UI.imgui;
    if (ui.BeginMainMenuBar()) {
        if (ui.BeginMenu("File")) {
            if (ui.MenuItem("Restart")) {
                state.restart_requested = true;

            }
            ui.EndMenu();
        }
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
            drawFrametimePlot(state);
        }
        ui.End();
    }
}

pub fn drawFrametimePlot(state: *State) void {
    var times: [frames_slice_len]f64 = undefined;
    const new_time: f64 = @as(f64, @floatFromInt(state.frame_time)) / std.time.ns_per_ms;
    state.frame_times[state.current_frame_time_idx] = new_time;

    const back_len = (frames_slice_len - state.current_frame_time_idx);

    for(state.current_frame_time_idx..frames_slice_len, 0..) |time, i| {
        times[i] = state.frame_times[time];
    } 
    for(0..state.current_frame_time_idx, back_len..) |time, i| {
        times[i] = state.frame_times[time];
    }

    const plot = hy.UI.implot;
    if (plot.begin("My Plot", .{}, plot.Flags.CanvasOnly)) {
        plot.setupAxesLimits(0, @floatFromInt(frames_slice_len), 0, 40, .always);
        plot.plotBars("Bar", @as([]f64, &times), .{});
        plot.end();
    }

    state.current_frame_time_idx = (state.current_frame_time_idx + 1) % frames_slice_len;
}