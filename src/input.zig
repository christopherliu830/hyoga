const std = @import("std");
const genarray = @import("genarray.zig");
const window = @import("window.zig");

const Handler = fn (ctx: *anyopaque) void;

pub const InputFlags = packed struct(u8) {
    up: bool = false,
    down: bool = false,
    held: bool = false,

    _padding: u5 = 0,
};

pub const Keybinds = std.AutoHashMap(window.Key, InputHandler);

pub const InputHandler = struct {
    name: []const u8,
    fire_on: InputFlags,
    handler: *const Handler,
    ctx: *anyopaque,
};

var keybinds: Keybinds = undefined;
var input_inited = false;

pub fn init(allocator: std.mem.Allocator, _: window.Handle) !void {
    if (!input_inited) {
        keybinds = Keybinds.init(allocator);
        input_inited = true;
    }
}

pub fn bind(key: window.Key, handler: InputHandler) !void {
    try keybinds.put(key, handler);
}

pub fn post(key: window.Key, mods: window.Mods, action: window.Action) void {
    _ = mods;
    const flags: InputFlags = switch(action) {
        .keydown => .{ .down = true },
        .hold => .{ .held = true },
        .keyup => .{ .up = true },
    };

    if (keybinds.get(key)) |binded| {
        // By bitcasting the struct, we can compare each
        // field as if it was a bitmask.
        const left: u8 = @bitCast(flags);
        const right: u8 = @bitCast(binded.fire_on);
        if (left & right != 0) binded.handler(binded.ctx);
    }
}