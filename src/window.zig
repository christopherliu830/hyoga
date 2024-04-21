const glfw = @import("mach-glfw");
const gl = @import("gl");
const cfg = @import("./config.zig");

var gl_procs: gl.ProcTable = undefined;

/// Sets gl variables and creates a glfw window.
/// Returns the glfw window object.
/// NOTE: Caller responsible for calling shutdownWindow() to
/// deinit the window module.
pub fn startupWindow() !glfw.Window {
    if (!glfw.init(.{})) return error.InitFailed;

    const window = glfw.Window.create(cfg.window.w, cfg.window.h, "Hyoga", null, null, .{
        .context_version_major = gl.info.version_major,
        .context_version_minor = gl.info.version_minor,

        .opengl_profile = switch (gl.info.api) {
            .gl => .opengl_core_profile,
            .gles => .opengl_any_profile,
            else => comptime unreachable,
        },
        .opengl_forward_compat = gl.info.api == .gl,
    }) orelse return error.InitFailed;

    glfw.makeContextCurrent(window);

    if (!gl_procs.init(glfw.getProcAddress)) return error.InitFailed;

    gl.makeProcTableCurrent(&gl_procs);

    // MacOS reports resolution differently
    const size = window.getFramebufferSize();
    gl.Viewport(0, 0, @intCast(size.width), @intCast(size.height));
    gl.ClearColor(
        cfg.window.clear_color[0],
        cfg.window.clear_color[1],
        cfg.window.clear_color[2],
        cfg.window.clear_color[3],
    );

    window.setFramebufferSizeCallback(framebufferSizeCallback);

    return window;
}

pub fn shutdownWindow(window: glfw.Window) void {
    gl.makeProcTableCurrent(null);
    glfw.makeContextCurrent(null);
    window.destroy();
    glfw.terminate();
}

fn framebufferSizeCallback(_: glfw.Window, width: u32, height: u32) void {
    gl.Viewport(0, 0, @intCast(width), @intCast(height));
}
