const std = @import("std");
const sdl = @import("sdl");
const hy = @import("hyoga-lib");
const hym = hy.math;

const Window = @This();

hdl: *sdl.Window,

/// Returns an SDL window handle.
pub fn init() !Window {
    if (!sdl.init.init(sdl.init.Flag.video)) {
        sdl.log("Unable to initialize SDL: %s", sdl.getError());
        return error.SDLInitializationFailed;
    }

    const instance = sdl.video.createWindow("My Game Window", 640, 480, .{
        .resizeable = true,
    }) orelse {
        sdl.log("Unable to create window: %s", sdl.getError());
        return error.SDLInitializationFailed;
    };
    return .{ .hdl = instance };
}

pub fn deinit(window: Window) void {
    sdl.video.destroyWindow(window.hdl);
    sdl.init.quit();
}

pub fn dimensions(window: Window) hym.Vec2 {
    var x: c_int = 0;
    var y: c_int = 0;
    if (!sdl.video.getWindowSizeInPixels(window.hdl, &x, &y)) {
        std.log.err("Unable to get window size: {s}", .{sdl.getError()});
    }
    return hym.vec2.create(@floatFromInt(x), @floatFromInt(y));
}

pub fn setRelativeMouseMode(self: Window, mode: bool) void {
    _ = sdl.mouse.setWindowRelativeMouseMode(self.hdl, mode);
}
