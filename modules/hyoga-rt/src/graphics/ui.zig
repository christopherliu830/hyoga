const std = @import("std");
const platform = @import("imgui/imgui_impl_sdl.zig");
const backend = @import("imgui/imgui_impl_sdlgpu.zig");
const sdl = @import("sdl");
pub const imgui = @import("imgui");
pub const implot = @import("implot");
const Gpu = @import("gpu.zig");
const Window = @import("../window.zig");

const UI = @This();

context: ?*imgui.Context,
implot_context: ?*implot.Context,
free_fn: imgui.MemFreeFunc,
alloc_fn: imgui.MemAllocFunc,
user_data: ?*anyopaque,

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
};

pub fn init(info: UIInitInfo) !UI {
    var self: UI = undefined;
    self.context = imgui.CreateContext(null);
    self.implot_context = implot.createContext();
    imgui.GetAllocatorFunctions(&self.alloc_fn, &self.free_fn, &(self.user_data.?));
    try platform.init(info.window, info.allocator);
    try backend.init(&.{
        .gpu = info.gpu,
        .window = info.window.hdl,
    }, info.allocator);
    return self;
}

pub fn processEvent(self: *UI, event: sdl.events.Event) !void {
    self.useState();
    _ = try platform.processEvent(&event);
}

pub fn beginFrame(self: *UI) !void {
    self.useState();
    const zone = @import("ztracy").Zone(@src());
    defer zone.End();
    try backend.newFrame();
    try platform.newFrame();
    imgui.NewFrame();
}

pub fn endFrame(self: *UI) void {
    self.useState();
    imgui.EndFrame();
}

pub fn wantsKeyboard(_: *UI) bool {
    return (imgui.GetIO() orelse return false).WantCaptureKeyboard;
}

pub fn wantsMouse(_: *UI) bool {
    return (imgui.GetIO() orelse return false).WantCaptureMouse;
}

pub fn render(_: *UI, cmd: *sdl.gpu.CommandBuffer) !void {
    imgui.Render();
    try backend.renderDrawData(imgui.GetDrawData().?, cmd);
}

pub fn shutdown(_: *UI) void {
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
    };
}
