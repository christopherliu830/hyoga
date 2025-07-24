const im = @import("imgui.zig");
const sdl = @import("sdl");

//TODO: Finish example
pub fn main() !void {
    try sdl.init(.{ .video = true, .gamepad = true });
    defer sdl.quit();

    const display = sdl.video.getPrimaryDisplay();
    const main_scale = sdl.video.getDisplayContentScale(display);

    const window_flags: sdl.video.WindowFlags = .{
        .resizeable = true,
        .hidden = true,
        .high_pixel_density = true,
    };

    const w: u16 = @intFromFloat(1280.0 * main_scale);
    const h: u16 = @intFromFloat(720.0 * main_scale);
    const window = try sdl.video.createWindow("Dear ImGui SDL3+SDL_GPU example", w, h, window_flags);

    _ = window.positionSet(
        sdl.video.windowPosCenteredDisplay(0),
        sdl.video.windowPosCenteredDisplay(0),
    );

    window.show();

    const device = try sdl.gpu.createDevice(
        .{ .spirv = true, .dxil = true, .metallib = true },
        true,
        null,
    );

    try device.claimWindow(window);
    device.setSwapchainParameters(.sdr, .mailbox);

    im.createContext(null);

    const io = im.getIO();
    io.config_flags.nav_enable_keyboard = true;
    io.config_flags.nav_enable_gamepad = true;
    io.config_flags.docking_enable = true;
    io.config_flags.viewports_enable = true;

    im.styleColorsDark(null);
}
