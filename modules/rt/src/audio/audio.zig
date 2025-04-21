const std = @import("std");
const sdl = @import("sdl");
const mix = @import("sdl_mixer");

pub const Audio = @This();

pub const Sound = struct {
    pub fn create() void {}
};

pub fn init() !Audio {
    if (!mix.open(0, null)) {
        sdl.log(sdl.getError());
        unreachable;
    }
    return .{};
}

pub fn shutdown() void {
    mix.close();
}
