const std = @import("std");
const genarray = @import("genarray.zig");
const window = @import("window.zig");
const keycode = @import("sdl/keycode.zig");

const Handler = fn (ctx: ?*anyopaque) void;

pub const InputFlags = packed struct(u8) {
    up: bool = false,
    down: bool = false,
    held: bool = false,

    _padding: u5 = 0,
};

pub const Keybinds = std.AutoHashMap(keycode.Keycode, InputHandler);

pub const InputHandler = struct {
    name: []const u8,
    fire_on: InputFlags = .{ .down = true },
    handler: *const Handler,
    ctx: ?*anyopaque = null,
};

var keybinds: Keybinds = undefined;
var input_inited = false;

pub fn init(allocator: std.mem.Allocator) void {
    if (!input_inited) {
        keybinds = Keybinds.init(allocator);
        input_inited = true;
    }
}

pub fn bind(key: keycode.Keycode, handler: InputHandler) !void {
    try keybinds.put(key, handler);
}

pub fn post(key: keycode.Keycode, mods: keycode.Keymod, action: InputFlags) void {
    _ = mods;

    if (keybinds.get(key)) |binded| {
        // By bitcasting the struct, we can compare each
        // field as if it was a bitmask.
        const left: u8 = @bitCast(action);
        const right: u8 = @bitCast(binded.fire_on);
        if (left & right != 0) binded.handler(binded.ctx);
    }
}