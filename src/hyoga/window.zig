const sdl = @import("sdl");
const gl = @import("gl");

var gl_procs: gl.ProcTable = undefined;

pub const Mods = enum(u32) { ctrl, alt, shift };

pub const Action = enum(u8) { keyup, keydown, hold };

pub var instance: *sdl.Window = undefined;

/// Sets gl variables and creates a glfw window.
/// Returns the glfw window object.
/// NOTE: Caller responsible for calling shutdownWindow() to
/// deinit the window module.
pub fn init() !void {
    if (!sdl.init.init(sdl.init.Flag.video)) {
        sdl.log("Unable to initialize SDL: %s", sdl.getError());
        return error.SDLInitializationFailed;
    }

    instance = sdl.video.createWindow("My Game Window", 640, 480, .{ .resizeable = true, }) orelse {
        sdl.log("Unable to create window: %s", sdl.getError());
    
        return error.SDLInitializationFailed;
    };
}

pub fn destroy() void {
    sdl.video.destroyWindow(instance);
    sdl.init.quit();
}

pub fn setRelativeMouseMode(mode: bool) void {
    _ = sdl.mouse.setWindowRelativeMouseMode(instance, mode);
}
