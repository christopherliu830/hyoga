const std = @import("std");
const glfw = @import("mach-glfw");
const genarray = @import("genarray.zig");

const Handler = fn (ctx: *anyopaque) void;

pub const Key = glfw.Key;

pub const InputAction = packed struct(u8) {
    up: bool = false,
    down: bool = false,
    held: bool = false,

    _padding: u5 = 0,
};

pub const Keybinds = std.AutoHashMap(Key, InputHandler);

pub const InputHandler = struct {
    name: []const u8,
    fire_on: InputAction,
    handler: *const Handler,
    ctx: *anyopaque,
};

var glfw_window: glfw.Window = undefined;
var keybinds: Keybinds = undefined;
var input_inited = false;

pub fn init(allocator: std.mem.Allocator, window: glfw.Window) !void {
    if (!input_inited) {
        window.setKeyCallback(handleInput);
        keybinds = Keybinds.init(allocator);
        input_inited = true;
    }
}

pub fn bind(key: Key, handler: InputHandler) !void {
    try keybinds.put(key, handler);
}

pub fn handleInput(window: glfw.Window, key: Key, scancode: i32, glfw_action: glfw.Action, mods: glfw.Mods) void {
    _ = window;
    _ = scancode;
    _ = mods;
    const action: InputAction = switch(glfw_action) {
        .press => .{ .down = true },
        .repeat => .{ .held = true },
        .release => .{ .up = true },
    };

    if (keybinds.get(key)) |binded| {
        const left: u8 = @bitCast(action);
        const right: u8 = @bitCast(binded.fire_on);
        if (left & right != 0) binded.handler(binded.ctx);
    }
}