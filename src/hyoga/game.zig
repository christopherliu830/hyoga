const std = @import("std");
const gpu = @import("graphics/gpu.zig");
const Mat4 = @import("hyoga-math").Mat4;
const Vec3 = @import("hyoga-math").Vec3;

const Engine= @import("Engine.zig");

pub const World = extern struct {
    quit: bool = false,
    restart: bool = false,
    scene: gpu.Scene,
    frame_time: u64 = 0,
    memory: *anyopaque,
};

pub const Entity = extern struct {
};

pub const GameInterface = extern struct {
    init: *const fn(*Engine) callconv(.C) World,
    shutdown: *const fn(*Engine, World) callconv(.C) void,
    update: *const fn (*Engine, World) callconv(.C) World,
    render: *const fn (*Engine, World) callconv(.C) void,
    reload: *const fn (*Engine, World) callconv (.C) bool,
};
