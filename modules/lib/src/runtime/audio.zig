const std = @import("std");
const ExternSliceConst = @import("../root.zig").ExternSliceConst;

pub const Sound = enum(u128) {
    none = 0,
    _,

    pub const play = hyaudSoundPlay;
    pub const stop = hyaudSoundStop;
};

pub fn read(path: []const u8) Sound {
    return hyaudSoundRead(.make(path));
}

extern fn hyaudSoundPlay(sound: *Sound) void;
extern fn hyaudSoundStop(sound: *Sound) void;
extern fn hyaudSoundRead(path: ExternSliceConst(u8)) Sound;
