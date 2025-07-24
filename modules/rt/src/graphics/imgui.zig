const sdl = @import("sdl");
const imgui = @import("imgui");

// TODO: translate from this
// https://github.com/ocornut/imgui/blob/docking/examples/example_sdl3_sdlgpu3/main.cpp
pub fn init() void {
    const io = imgui.getIO();
    io.config_flags.nav_enable_keyboard = true;
    io.config_flags.nav_enable_gamepad = true;
    io.config_flags.docking_enable = true;
    io.config_flags.viewports_enable = true;
}
