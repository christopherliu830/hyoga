const ExternSliceConst = @import("../runtime.zig").ExternSliceConst;

pub const Sound = extern struct {
    chunk: *anyopaque,

    pub fn read(path: []const u8) Sound {
        return hyaudSoundRead(.make(@constCast(path)));
    }

    pub const play = hyaudSoundPlay;
};

extern fn hyaudSoundPlay(sound: Sound) void;
extern fn hyaudSoundRead(path: ExternSliceConst(u8)) Sound;
