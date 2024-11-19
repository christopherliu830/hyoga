const std = @import("std");
const platform = @import("imgui/imgui_impl_sdl.zig");
const backend = @import("imgui/imgui_impl_sdlgpu.zig");
const sdl = @import("sdl");

pub const imgui = @import("imgui/imgui.zig");

var context: *imgui.Context = undefined;

pub const UIInitInfo = struct {
    window: *sdl.Window,
    device: *sdl.gpu.Device,
    allocator: std.mem.Allocator,
};

pub fn init(info: UIInitInfo) !void {
    context = imgui.createContext(null).?;
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
    try backend.newFrame();
    try platform.newFrame();
    imgui.newFrame();
}

pub fn render(cmd: *sdl.gpu.CommandBuffer, pass: *sdl.gpu.RenderPass) !void {
    imgui.render();
    try backend.renderDrawData(imgui.getDrawData(), cmd, pass);
}

pub fn shutdown() void {
    backend.shutdown();
    platform.shutdown();
    context.destroy();
}