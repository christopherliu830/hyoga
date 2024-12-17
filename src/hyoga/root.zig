const std = @import("std");
const sdl = @import("sdl");
pub const math = @import("hyoga-math");
pub const slotmap = @import("hyoga-slotmap");
pub const Window = @import("window.zig");
pub const material = @import("graphics/material.zig");
pub const Input = @import("input/Input.zig");
pub const Symbol = @import("Symbol.zig");
pub const UI = @import("graphics/ui.zig");
pub const Gpu = @import("graphics/gpu.zig");
pub const SkipMap = @import("skipmap.zig").SkipMap;
pub const World = @import("Game.zig").World;
pub const GameInterface = @import("Game.zig").GameInterface;
pub const Engine = @import("Engine.zig");

pub fn init() *Engine {
    return Engine.init() catch |err| {
        std.debug.panic("Engine init failure: {}", .{err});
    };
}
