const hy = @import("hyoga");
const std = @import("std");
const sdl = @import("sdl");
const mix = @import("sdl_mixer");

pub const Audio = @This();

pub const Channel = enum(c_int) { none = -1, _ };

pub const Sound = extern struct {
    chunk: ?*mix.Chunk = null,
    current_channel: Channel = .none,

    pub fn play(self: *Sound) void {
        if (self.chunk) |chunk| {
            self.current_channel = @enumFromInt(mix.channelPlay(-1, chunk, 0));
        }
    }

    pub fn stop(self: *Sound) void {
        if (self.chunk != null) {
            if (self.current_channel != .none) {
                mix.channelHalt(@intFromEnum(self.current_channel));
                self.current_channel = .none;
            }
        }
    }

    pub fn rtCast(sound: *hy.Audio.Sound) *Sound {
        return @ptrCast(sound);
    }
};

pub const InitOpts = struct {
    max_volume: u8 = 32,
};

pub fn init(opts: InitOpts) !Audio {
    if (!mix.open(0, null)) {
        sdl.log(sdl.getError());
        unreachable;
    }

    _ = mix.channelSetVolume(-1, opts.max_volume);
    return .{};
}

pub fn shutdown() void {
    mix.close();
}

pub fn read(path: [:0]const u8) Sound {
    const maybe_chunk = mix.loadWav(path.ptr);
    if (maybe_chunk) |chunk| {
        return .{ .chunk = chunk };
    } else {
        std.log.warn("SDL error: {s}", .{sdl.getError()});
        return .{};
    }
}
