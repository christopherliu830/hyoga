const std = @import("std");
const genarray = @import("genarray.zig");
const window = @import("window.zig");
const sdl = @import("sdl/sdl.zig");

pub const keycode = @import("sdl/keycode.zig");

const Handler = fn (ctx: ?*anyopaque) void;

pub const InputFlags = packed struct(u8) {
    up: bool = false,
    down: bool = false,
    held: bool = false,

    _padding: u5 = 0,
};

pub const InputHandler = struct {
    name: []const u8,
    fire_on: InputFlags = .{ .down = true },
    active: bool = false,
    handler: *const Handler,
    ctx: ?*anyopaque = null,
};

pub const Keybinds = std.AutoHashMap(keycode.Keycode, InputHandler);

var keybinds: Keybinds = undefined;

const MouseState = struct {
    button_1: bool = false,
    button_2: bool = false,
    button_3: bool = false,
};

pub var mouse = MouseState { };

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
        if (action.down or action.held) {
            keybinds.getPtr(key).?.*.active = true;
        } else {
            keybinds.getPtr(key).?.*.active = false;
        }
        // By bitcasting the struct, we can compare each
        // field as if it was a bitmask.
        const left: u8 = @bitCast(action);
        const right: u8 = @bitCast(binded.fire_on);
        if (left & right != 0) binded.handler(binded.ctx);
    }
}

pub fn query(key: keycode.Keycode) ?*const InputHandler {
    if (keybinds.get(key)) |handler| {
        return &handler;
    } else {
        return null;
    }
}

pub fn update(event: sdl.events.Event) void {
    switch (event.type) {
        sdl.events.key_down => {
            const key = event.key.key;
            post(key, undefined, .{ .down = true });
        },

        sdl.events.key_up => {
            const key = event.key.key;
            post(key, undefined, .{ .up = true });
        },

        sdl.events.mouse_button_down => {
            switch(event.button.button) {
                1 => mouse.button_1 = true,
                2 => mouse.button_2 = true,
                3 => mouse.button_3 = true,
                else => {},
            }
        },
        sdl.events.mouse_button_up => {
            switch(event.button.button) {
                1 => mouse.button_1 = false,
                2 => mouse.button_2 = false,
                3 => mouse.button_3 = false,
                else => {},
            }
        },

        else => {},
    }
}
