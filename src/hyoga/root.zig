const std = @import("std");
const sdl = @import("sdl");

pub const math = @import("hyoga-lib").math;
pub const slotmap = @import("hyoga-lib").slot_map;
pub const Window = @import("window.zig");
pub const material = @import("graphics/material.zig");
pub const Input = @import("input/Input.zig");
pub const Strint = @import("strintern.zig");
pub const UI = @import("graphics/ui.zig");
pub const Gpu = @import("graphics/gpu.zig");
pub const World = @import("Game.zig").World;
pub const GameInterface = @import("Game.zig").GameInterface;
pub const Engine = @import("Engine.zig");

pub fn init() *Engine {
    return Engine.init() catch |err| {
        std.debug.panic("Engine init failure: {}", .{err});
    };
}
