const std = @import("std");
const hy = @import("hyoga");
const hym = hy.math;
const sdl = @import("sdl");
const Gpu = @import("gpu.zig");
const Window = @import("../window.zig");

const UI = @This();

pub const clay = @import("clay_ui.zig");

clay_ui: clay.UI,

pub const UIInitInfo = struct {
    window: *Window,
    gpu: *Gpu,
    allocator: std.mem.Allocator,
};

pub const GlobalState = extern struct {
    imgui_ctx: ?*anyopaque,
    free_fn: ?*anyopaque,
    alloc_fn: ?*anyopaque,
    user_data: ?*anyopaque,
    clay_context: *clay.clay.Context,
    clay_measure_text_fn: ?*const anyopaque,

    comptime {
        hy.meta.assertMatches(GlobalState, hy.runtime.ui.State);
    }
};

pub fn init(info: UIInitInfo) !UI {
    var self: UI = undefined;

    self.clay_ui = try .create(info.allocator, info.gpu, info.window);

    return self;
}

pub fn processEvent(self: *UI, event: sdl.events.Event) !void {
    self.useState();
    try self.clay_ui.processEvent(event);
}

pub fn beginFrame(self: *UI, delta_time: u64) !void {
    self.useState();

    self.clay_ui.begin(delta_time);
}

pub fn endFrame(self: *UI) void {
    self.useState();
}

pub fn wantsCaptureKeyboard(_: *UI) bool {
    return false;
}

pub fn wantsCaptureMouse(self: *UI) bool {
    return self.clay_ui.capture_mouse;
}

pub fn render(_: *UI, cmd: *sdl.gpu.CommandBuffer) !void {
    _ = cmd;
}

pub const InputState = extern struct {
    mouse_down: bool,
    mouse_position: hym.Vec2,

    comptime {
        hy.meta.assertMatches(InputState, hy.runtime.ui.InputState);
    }
};

pub fn inputState(self: *UI) InputState {
    return .{
        .mouse_down = self.clay_ui.mouse_down,
        .mouse_position = self.clay_ui.mouse_position,
    };
}

pub fn shutdown(self: *UI, allocator: std.mem.Allocator) void {
    self.clay_ui.deinit(allocator);
}

pub fn useState(self: *UI) void {
    _ = self;
}

pub fn getGlobalState(self: *UI) GlobalState {
    return .{
        .imgui_ctx = null,
        .alloc_fn = null,
        .free_fn = null,
        .user_data = null,
        .clay_context = self.clay_ui.context,
        .clay_measure_text_fn = @ptrCast(&clay.UI.measureText),
    };
}
