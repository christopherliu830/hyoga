const sdl = @import("sdl");

const Window = @This();

hdl: *sdl.Window,
aspect: f32,

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
    return .{ .hdl = instance, .aspect = 640 / 480 };
}

pub fn deinit(window: Window) void {
    sdl.video.destroyWindow(window.hdl);
    sdl.init.quit();
}

pub fn setRelativeMouseMode(self: Window, mode: bool) void {
    _ = sdl.mouse.setWindowRelativeMouseMode(self.hdl, mode);
}

