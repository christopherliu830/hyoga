const c = @import("sdl/c.zig");
const sdl = @import("sdl/sdl.zig");
const gl = @import("gl");
const cfg = @import("config.zig");

var gl_procs: gl.ProcTable = undefined;

pub const Mods = enum(u32) { ctrl, alt, shift };

pub const Action = enum(u8) { keyup, keydown, hold };

pub var instance: *sdl.Window = undefined;

/// Sets gl variables and creates a glfw window.
/// Returns the glfw window object.
/// NOTE: Caller responsible for calling shutdownWindow() to
/// deinit the window module.
pub fn init() !void {
    if (!sdl.c.SDL_Init(sdl.c.SDL_INIT_VIDEO)) {
        sdl.c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }

    instance = sdl.video.createWindow("My Game Window", 640, 480, .{ .resizeable = true, }) orelse {
        sdl.c.SDL_Log("Unable to create window: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
}

pub fn destroy() void {
    sdl.video.destroyWindow(instance);
    sdl.c.SDL_Quit();
}

pub fn swapBuffers() void {
    if (!sdl.c.SDL_GL_SwapWindow(instance)) {
        sdl.c.SDL_Log("Unable to swap buffers: %s", c.SDL_GetError());
    }
}

pub fn setRelativeMouseMode(mode: bool) void {
    _ = sdl.mouse.setWindowRelativeMouseMode(instance, mode);
}
