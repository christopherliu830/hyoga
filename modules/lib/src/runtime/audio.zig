const std = @import("std");
const ExternSliceConst = @import("../root.zig").ExternSliceConst;

const proc_table = @import("proc_table.zig");
const proc = &proc_table.table;

pub const Sound = enum(u128) {
    none = 0,
    _,

    pub fn play(sound: *Sound) void {
        proc.hy_audio_soundPlay(sound);
    }

    pub fn stop(sound: *Sound) void {
        proc.hy_audio_soundStop(sound);
    }
};

pub fn read(path: []const u8) Sound {
    return proc.hy_audio_soundRead(.from(path));
}

