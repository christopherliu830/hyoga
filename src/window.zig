const c = @import("c.zig");
const gl = @import("gl");
const cfg = @import("config.zig");

pub const Window = *c.struct_SDL_Window;

var gl_procs: gl.ProcTable = undefined;

/// Sets gl variables and creates a glfw window.
/// Returns the glfw window object.
/// NOTE: Caller responsible for calling shutdownWindow() to
/// deinit the window module.
pub fn startupWindow() !Window {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }

    const screen: Window = c.SDL_CreateWindow("My Game Window", 640, 480, c.SDL_WINDOW_OPENGL) orelse {
        c.SDL_Log("Unable to create window: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    return screen;
}

pub fn shutdownWindow(window: Window) void {
    c.SDL_DestroyWindow(window);
    c.SDL_Quit();
}

pub fn swapBuffers(window: Window) void {
    if (c.SDL_GL_SwapWindow(window) != 0) {
        c.SDL_Log("Unable to swap buffers: %s", c.SDL_GetError());
    }
}
