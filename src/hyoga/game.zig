const std = @import("std");
const gpu = @import("graphics/gpu.zig");
const Mat4 = @import("hyoga-math").Mat4;
const Vec3 = @import("hyoga-math").Vec3;

const Engine= @import("Engine.zig");

pub const Game = extern struct {
    quit: bool = false,
    restart: bool = false,
    scene: gpu.Scene,
    frame_time: f64 = 0,
    memory: *anyopaque,
};

pub const GameInterface = extern struct {
    init: *const fn(*Engine) callconv(.C) Game,
    shutdown: *const fn(*Engine, Game) callconv(.C) void,
    update: *const fn (*Engine, Game) callconv(.C) Game,
    render: *const fn (*Engine, Game) callconv(.C) void,
    reload: *const fn (*Engine, Game) callconv (.C) bool,
};
