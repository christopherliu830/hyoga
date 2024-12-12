const std = @import("std");
const gpu = @import("graphics/gpu.zig");
const ui = @import("graphics/ui.zig");
const Hy = @import("root.zig");

pub const Game = extern struct {
    quit: bool = false,
    scene: gpu.Scene,
    frame_time: u64 = 0,
    memory: *anyopaque,
    imgui_state: ui.ImguiState = .{}, 
};

pub const GameInterface = extern struct {
    init: *const fn(*Hy) callconv(.C) Game,
    shutdown: *const fn(*Hy, Game) callconv(.C) void,
    update: *const fn (*Hy, Game) callconv(.C) Game,
    render: *const fn (*Hy, Game) callconv(.C) void,
};
