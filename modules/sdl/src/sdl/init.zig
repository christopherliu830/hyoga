const std = @import("std");
const sdl = @import("sdl.zig");

const InitFlags = packed struct(c_int) {
    _padding_0: u4 = 0,
    audio: bool = false,
    video: bool = false,
    _padding_1: u3 = 0,
    joystick: bool = false,
    _padding_2: u2 = 0,
    haptic: bool = false,
    gamepad: bool = false,
    events: bool = false,
    sensor: bool = false,
    camera: bool = false,
    _padding_4: u15 = 0,

    comptime {
        std.debug.assert(@as(c_int, @bitCast(InitFlags{ .audio = true })) == 0x10);
        std.debug.assert(@as(c_int, @bitCast(InitFlags{ .video = true })) == 0x20);
        std.debug.assert(@as(c_int, @bitCast(InitFlags{ .joystick = true })) == 0x200);
        std.debug.assert(@as(c_int, @bitCast(InitFlags{ .haptic = true })) == 0x1000);
        std.debug.assert(@as(c_int, @bitCast(InitFlags{ .gamepad = true })) == 0x2000);
        std.debug.assert(@as(c_int, @bitCast(InitFlags{ .events = true })) == 0x4000);
        std.debug.assert(@as(c_int, @bitCast(InitFlags{ .sensor = true })) == 0x8000);
        std.debug.assert(@as(c_int, @bitCast(InitFlags{ .camera = true })) == 0x10000);
    }
};

extern fn SDL_Init(flags: InitFlags) bool;
pub fn init(flags: InitFlags) !void {
    if (!SDL_Init(flags)) {
        std.log.err("SDL init failure {s}", .{sdl.getError()});
        return error.SdlError;
    }
}

extern fn SDL_Quit() void;
pub const quit = SDL_Quit;
