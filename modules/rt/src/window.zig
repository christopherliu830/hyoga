const std = @import("std");
const sdl = @import("sdl");
const hy = @import("hyoga-lib");
const hym = hy.math;

const Window = @This();

hdl: *sdl.Window,

/// Returns an SDL window handle.
pub fn init() !Window {
    const instance = try sdl.video.createWindow("My Game Window", 640, 480, .{
        .resizeable = true,
    });
    return .{ .hdl = instance };
}

pub fn deinit(window: Window) void {
    sdl.video.destroyWindow(window.hdl);
    sdl.quit();
}

pub fn dimensions(window: Window) hym.Vec2 {
    const dims = sdl.video.windowSizeInPixels(window.hdl) catch unreachable;
    return hym.vec2.create(@floatFromInt(dims[0]), @floatFromInt(dims[1]));
}

pub fn projectionMatrix(window: *const Window) hym.Mat4 {
    const dims = window.dimensions();
    const l: f32 = 0;
    const r: f32 = dims.x();
    const t: f32 = dims.y();
    const b: f32 = 0;

    const transform: hym.Mat4 = @bitCast([16]f32{
        2 / (r - l),       0,                 0,  0,
        0,                 2 / (t - b),       0,  0,
        0,                 0,                 -1, 0,
        (r + l) / (l - r), (t + b) / (b - t), 0,  1,
    });

    return transform;
}

pub fn setRelativeMouseMode(self: Window, mode: bool) void {
    _ = sdl.mouse.setWindowRelativeMouseMode(self.hdl, mode);
}
