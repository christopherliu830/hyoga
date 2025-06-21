const std = @import("std");
const hy = @import("hyoga-lib");
const hym = hy.math;
const platform = @import("imgui/imgui_impl_sdl.zig");
const backend = @import("imgui/imgui_impl_sdlgpu.zig");
const sdl = @import("sdl");
pub const imgui = @import("imgui");
pub const implot = @import("implot");
const Gpu = @import("gpu.zig");
const Window = @import("../window.zig");

const UI = @This();

pub const clay = @import("clay_ui.zig");

context: ?*imgui.Context,
implot_context: ?*implot.Context,
free_fn: imgui.MemFreeFunc,
alloc_fn: imgui.MemAllocFunc,
user_data: ?*anyopaque,

clay_ui: clay.UI,

pub const UIInitInfo = struct {
    window: *Window,
    gpu: *Gpu,
    allocator: std.mem.Allocator,
};

pub const GlobalState = extern struct {
    imgui_ctx: ?*imgui.Context,
    implot_ctx: ?*implot.Context,
    free_fn: imgui.MemFreeFunc,
    alloc_fn: imgui.MemAllocFunc,
    user_data: ?*anyopaque,
    clay_context: *clay.clay.Context,
    clay_measure_text_fn: ?*const anyopaque,

    comptime {
        hy.meta.assertMatches(GlobalState, hy.runtime.UI.State);
    }
};

pub fn init(info: UIInitInfo) !UI {
    var self: UI = undefined;
    // Imgui
    self.context = imgui.CreateContext(null);
    self.implot_context = implot.createContext();
    imgui.GetAllocatorFunctions(&self.alloc_fn, &self.free_fn, &(self.user_data.?));
    try platform.init(info.window, info.allocator);
    try backend.init(&.{
        .gpu = info.gpu,
        .window = info.window.hdl,
    }, info.allocator);

    self.clay_ui = try .create(info.allocator, info.gpu, info.window);

    return self;
}

pub fn processEvent(self: *UI, event: sdl.events.Event) !void {
    self.useState();
    _ = try platform.processEvent(&event);
    try self.clay_ui.processEvent(event);
}

pub fn beginFrame(self: *UI, delta_time: u64) !void {
    self.useState();
    const zone = @import("ztracy").Zone(@src());
    defer zone.End();
    try backend.newFrame();
    try platform.newFrame();
    imgui.NewFrame();

    self.clay_ui.begin(delta_time);
}

pub fn endFrame(self: *UI) void {
    self.useState();
    imgui.EndFrame();
}

pub fn wantsCaptureKeyboard(_: *UI) bool {
    return (imgui.GetIO() orelse return false).WantCaptureKeyboard;
}

pub fn wantsCaptureMouse(self: *UI) bool {
    return if (self.clay_ui.capture_mouse) true else (imgui.GetIO() orelse return false).WantCaptureMouse;
}

pub fn render(_: *UI, cmd: *sdl.gpu.CommandBuffer) !void {
    imgui.Render();
    try backend.renderDrawData(imgui.GetDrawData().?, cmd);
}

pub const InputState = extern struct {
    mouse_down: bool,
    mouse_position: hym.Vec2,

    comptime {
        hy.meta.assertMatches(InputState, hy.runtime.UI.InputState);
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
    backend.shutdown();
    platform.shutdown();
    implot.destroyContext(null);
    imgui.DestroyContext(null);
}

pub fn useState(self: *UI) void {
    imgui.SetCurrentContext(self.context);
    imgui.SetAllocatorFunctions(self.alloc_fn, self.free_fn, self.user_data);
    implot.setCurrentContext(self.implot_context);
}

pub fn getGlobalState(self: *UI) GlobalState {
    return .{
        .imgui_ctx = self.context,
        .implot_ctx = self.implot_context,
        .alloc_fn = self.alloc_fn,
        .free_fn = self.free_fn,
        .user_data = self.user_data,
        .clay_context = self.clay_ui.context,
        .clay_measure_text_fn = @ptrCast(&clay.UI.measureText),
    };
}
