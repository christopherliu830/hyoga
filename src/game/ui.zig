const std = @import("std");
const hy = @import("hyoga-lib");
const imgui = @import("imgui");
const plot = @import("implot");

const frames_slice_len = 128;

const Windows = struct {
    camera: bool = false,
    perf: bool = false,

};
pub const State = struct {
    second_timer: std.time.Timer, // Timer that ticks every second
    windows: Windows = .{},
    frame_time: f64 = 0,
    drawn_frame_time: f64 = 0,
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
    if (state.second_timer.read() > std.time.ns_per_s) {
        state.second_timer.reset();
        state.drawn_frame_time = state.frame_time;
    }

    const ui = imgui;
    if (ui.BeginMainMenuBar()) {
        if (ui.BeginMenu("File")) {
            if (ui.MenuItem("Restart")) {
                state.restart_requested = true;

            }
            ui.EndMenu();
        }
        if (ui.BeginMenu("Window")) {
            if (ui.MenuItemEx("Camera", null, state.windows.camera, true)) {
                state.windows.camera = !state.windows.camera;
            }
            if (ui.MenuItemEx("Performance", null, state.windows.perf, true)) {
                state.windows.perf = !state.windows.perf;
            }
            ui.EndMenu();
        }
        ui.EndMainMenuBar();
    }

    if (state.windows.perf) {
        if (ui.Begin("Performance", &state.windows.perf, 0)) {
            const fps: f64 = 1 / (state.drawn_frame_time);
            ui.Text("Frame time: %.2fms (%.1f)fps", 
                state.drawn_frame_time,
                fps);
            drawFrametimePlot(state);
        }
        ui.End();
    }
}

pub fn drawFrametimePlot(state: *State) void {
    var times: [frames_slice_len]f64 = undefined;
    const new_time: f64 = state.frame_time;
    state.frame_times[state.current_frame_time_idx] = new_time;

    const back_len = (frames_slice_len - state.current_frame_time_idx);

    for(state.current_frame_time_idx..frames_slice_len, 0..) |time, i| {
        times[i] = state.frame_times[time];
    } 
    for(0..state.current_frame_time_idx, back_len..) |time, i| {
        times[i] = state.frame_times[time];
    }

    if (plot.begin("My Plot", .{}, plot.Flags.CanvasOnly)) {
        plot.setupAxesLimits(0, @floatFromInt(frames_slice_len), 0, 40, .always);
        plot.plotBars("Bar", @as([]f64, &times), .{});
        plot.end();
    }

    state.current_frame_time_idx = (state.current_frame_time_idx + 1) % frames_slice_len;
}
