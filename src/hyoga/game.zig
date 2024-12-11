const std = @import("std");
const gpu = @import("graphics/gpu.zig");
const ui = @import("graphics/ui.zig");

pub const Game = extern struct {
    quit: bool = false,
    scene: gpu.Scene,
    frame_time: u64 = 0,
    memory: *anyopaque,
};

pub const GameInterface = extern struct {
    init: *const fn() callconv(.C) Game,
    shutdown: *const fn(Game) callconv(.C) void,
    update: *const fn (Game) callconv(.C) Game,
    render: *const fn (Game) callconv(.C) void,
    reload: *const fn(*anyopaque) callconv(.C) void,
    reloadImgui: ?*const fn(ui.ImguiState) callconv(.C) void = null,
};
