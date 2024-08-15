const std = @import("std");
const genarray = @import("genarray.zig");
const ww = @import("window.zig");

const Handler = fn (ctx: *anyopaque) void;

pub const Key = enum { up, down };

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

var keybinds: Keybinds = undefined;
var input_inited = false;

pub fn init(allocator: std.mem.Allocator, _: ww.Window) !void {
    if (!input_inited) {
        //window.setKeyCallback(handleInput);
        keybinds = Keybinds.init(allocator);
        input_inited = true;
    }
}

pub fn bind(key: Key, handler: InputHandler) !void {
    try keybinds.put(key, handler);
}

pub fn handleInput(window: ww.Window, _: Key, scancode: i32, _: anyopaque, mods: anyopaque) void {
    _ = window;
    _ = scancode;
    _ = mods;
    return;

    // const action: InputAction = switch(glfw_action) {
    //     .press => .{ .down = true },
    //     .repeat => .{ .held = true },
    //     .release => .{ .up = true },
    // };

    // if (keybinds.get(key)) |binded| {
    //     const left: u8 = @bitCast(action);
    //     const right: u8 = @bitCast(binded.fire_on);
    //     if (left & right != 0) binded.handler(binded.ctx);
    // }
}