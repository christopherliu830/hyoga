const std = @import("std");
const platform = @import("imgui/imgui_impl_sdl.zig");
const backend = @import("imgui/imgui_impl_sdlgpu.zig");
const sdl = @import("sdl");

pub const imgui = @import("imgui");
pub const implot = @import("implot");

var context: *imgui.Context = undefined;

pub const UIInitInfo = struct {
    window: *sdl.Window,
    device: *sdl.gpu.Device,
    allocator: std.mem.Allocator,
};

pub fn init(info: UIInitInfo) !void {
    context = imgui.CreateContext(null);
    _ = implot.createContext();
    try platform.init(info.window, info.allocator);
    try backend.init(&.{
        .device = info.device,
        .window = info.window,
    }, info.allocator);
}

pub fn processEvent(event: sdl.events.Event) !void {
    _ = try platform.processEvent(&event);
}

pub fn beginFrame() !void {
    const zone = @import("ztracy").Zone(@src());
    defer zone.End();
    try backend.newFrame();
    try platform.newFrame();
    imgui.NewFrame();
}

pub fn endFrame() void {
    imgui.EndFrame();
}

pub fn render(cmd: *sdl.gpu.CommandBuffer) !void {
    imgui.Render();
    try backend.renderDrawData(imgui.GetDrawData().?, cmd);
}

pub fn shutdown() void {
    backend.shutdown();
    platform.shutdown();
    implot.destroyContext(null);
    imgui.DestroyContext(context);
}