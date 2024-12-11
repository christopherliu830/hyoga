const std = @import("std");
const gpu = @import("graphics/gpu.zig");

pub const Game = extern struct {
    quit: bool = false,
    scene: gpu.Scene,
    frame_time: u64 = 0,
    user_data: ?*anyopaque = null,
};

pub const CreateOptions = struct {
    fn_update: *const fn (*Game) void,
    fn_render: *const fn (*Game) void,
    user_data: ?*anyopaque = null,
};

pub fn create(options: CreateOptions) Game {
    return .{
        .fn_update = options.fn_update,
        .fn_render = options.fn_render,
    };
}

pub const GameInterface = extern struct {
    init: *const fn() callconv(.C) void,
    shutdown: *const fn() callconv(.C) void,
    update: *const fn (Game) callconv(.C) Game,
    render: *const fn (Game) callconv(.C) void,
    data: *const fn() callconv(.C) *anyopaque,
    reload: *const fn(*anyopaque) callconv(.C) void,
};
