const std = @import("std");
const hy = @import("hyoga-lib");
const imgui = @import("imgui");
const plot = @import("implot");
const ControlMode = @import("game.zig").ControlMode;
const ent = @import("entity.zig");

const frames_slice_len = 128;

const InspectorDelegate = *const fn (ctx: ?*anyopaque, ui_state: *State) void;

const Windows = struct {
    camera: bool = false,
    perf: bool = false,
    inspector: bool = false,
};

pub const State = struct {
    second_timer: std.time.Timer, // Timer that ticks every second
    windows: Windows = .{},
    mode: ControlMode,
    update_time: u64 = 0,
    render_time: u64 = 0,
    displayed_render_time: f64 = 0,
    frame_times: hy.CircleQueue(frames_slice_len, f64) = .{ .items = [_]f64{0} ** frames_slice_len },
    current_frame_time_idx: u8 = 0,
    restart_requested: bool = false,
    inspector: InspectorWindow = .none,

    pub fn create() !State {
        return .{
            .second_timer = try std.time.Timer.start(),
        };
    }
};

pub const InspectorWindow = union(enum) {
    none: void,
    player: *ent.Player,

    pub fn draw(self: InspectorWindow, state: *State) void {
        if (std.meta.activeTag(self) != .none) {
            if (begin()) {
                switch (self) {
                    .none => unreachable,
                    .player => |player| player.inspector(state),
                }
            }
            imgui.End();
        }
    }

    pub fn begin() bool {
        const padding: f32 = 12;

        const window_flags: imgui.WindowFlags = .{
            .no_title_bar = true,
            .no_resize = true,
            .no_scrollbar = true,
            .no_collapse = true,
            .no_docking = true,
            .always_auto_resize = true,
            .no_saved_settings = true,
            .no_focus_on_appearing = true,
            .no_nav_inputs = true,
            .no_nav_focus = true,
            .no_move = true,
        };

        const ui = imgui;
        const viewport = imgui.GetMainViewport().?;
        const work_pos = viewport.WorkPos;
        const work_size = viewport.WorkSize;

        const pos: imgui.Vec2 = .{
            .x = work_pos.x + work_size.x - padding,
            .y = work_pos.y + padding,
        };

        const pivot: imgui.Vec2 = .{ .x = 1, .y = 0 };

        ui.SetNextWindowPosEx(pos, .always, pivot);

        ui.SetNextWindowBgAlpha(0);
        return ui.Begin("Inspector", null, window_flags);
    }
};

pub fn drawMainUI(state: *State) void {
    const new_time = timeInMs(state.render_time);
    state.frame_times.push(new_time);
    const Vec = @Vector(frames_slice_len, f64);
    state.displayed_render_time = @reduce(.Add, @as(Vec, state.frame_times.items)) / frames_slice_len;

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
            if (ui.MenuItemEx("Inspector", null, state.windows.inspector, true)) {
                state.windows.inspector = !state.windows.inspector;
            }
            ui.EndMenu();
        }
        ui.EndMainMenuBar();
    }

    if (state.windows.perf) {
        if (ui.Begin("Performance", &state.windows.perf, .none)) {
            const render_time = state.displayed_render_time;
            const fps: f64 = 1000 / render_time;
            ui.Text("Frame time: %.2fms (%.1f)fps", render_time, fps);
            drawFrametimePlot(state);
        }
        ui.End();
    }

    if (state.windows.inspector) {
        state.inspector.draw(state);
    }

    drawOverlay(state);
}

pub fn drawFrametimePlot(state: *State) void {
    const times = state.frame_times.orderedItems()[0..state.frame_times.len()];
    if (plot.begin("My Plot", .{}, plot.Flags.CanvasOnly)) {
        plot.setupAxesLimits(0, @floatFromInt(frames_slice_len), 0, 40, .always);
        plot.plotBars("Bar", times, .{});
        plot.end();
    }
}

pub fn drawOverlay(state: *State) void {
    const padding: f32 = 12;

    const window_flags: imgui.WindowFlags = .{
        .no_title_bar = true,
        .no_resize = true,
        .no_scrollbar = true,
        .no_collapse = true,
        .no_docking = true,
        .always_auto_resize = true,
        .no_saved_settings = true,
        .no_focus_on_appearing = true,
        .no_nav_inputs = true,
        .no_nav_focus = true,
        .no_move = true,
    };

    const ui = imgui;
    const viewport = imgui.GetMainViewport().?;
    const work_pos = viewport.WorkPos;
    const pos: imgui.Vec2 = .{ .x = work_pos.x + padding, .y = work_pos.y + padding };
    ui.SetNextWindowPos(pos, .always);

    ui.SetNextWindowBgAlpha(0);
    if (ui.Begin("Main Overlay", null, window_flags)) {
        const render_time = state.displayed_render_time;
        const fps: f64 = 1000 / render_time;
        imgui.Text("FPS: %.2f", fps);
        imgui.Text("Mode: %s", @tagName(state.mode).ptr);
    }
    ui.End();
}

fn timeInMs(time: u64) f64 {
    return @as(f64, @floatFromInt(time)) / std.time.ns_per_ms;
}
