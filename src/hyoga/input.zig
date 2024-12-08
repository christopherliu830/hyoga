const std = @import("std");
const window = @import("window.zig");
const sdl = @import("sdl");
const imgui = @import("imgui");
const hya = @import("hyoga-arena");

pub const keycode = @import("sdl").keycode;

const vec2 = @import("hyoga-math").vec2;


const MouseButton = enum {
    left, // m1
    right, // m2
    middle, // m3
    motion,
    wheel,
};

const MouseState = struct {
    left: bool = false,
    right: bool = false,
    middle: bool = false,
    motion: struct {
        x: f32 = 0,
        y: f32 = 0,
    } = .{},
    wheel: f32 = 0,
};

pub const InputFlags = packed struct(u8) {
    up: bool = false,
    down: bool = false,
    held: bool = false,

    _padding: u5 = 0,
};

pub const InputHandler = struct {
    name: ?[]const u8 = null,
    fire_on: InputFlags = .{ .down = true },
    active: bool = false,
    handler: ?*const fn (ctx: ?*anyopaque) void,
    ctx: ?*anyopaque = null,
};

pub const MouseInputHandler = struct {
    name: ?[]const u8 = null,
    fire_on: InputFlags = .{ .down = true },
    active: bool = false,
    handler: ?*const fn(ctx: ?*anyopaque, event: MouseEvent) void = null,
    ctx: ?*anyopaque = null,
};

pub const MouseEvent = union(MouseButton) {
    left: sdl.events.MouseButtonEvent,
    right: sdl.events.MouseButtonEvent,
    middle: sdl.events.MouseButtonEvent,
    motion: sdl.events.MouseMotionEvent,
    wheel: sdl.events.MouseWheelEvent,
};

const KeybindList = hya.Arena(InputHandler);
const MousebindList = hya.Arena(MouseInputHandler);
const Keybinds = std.AutoHashMap(keycode.Keycode, KeybindList);
const Mousebinds = std.AutoHashMap(MouseButton, MousebindList);
const KeyState = [8]keycode.Keycode; // 32 keys down at once

var allocator: std.mem.Allocator = undefined;
var keybinds: Keybinds = undefined;
var keys_down: [32]keycode.Keycode = undefined;
pub var num_keys_down: u8 = 0;

var mousebinds: Mousebinds = undefined;
pub var mouse_state: MouseState = .{};

var input_inited = false;

pub fn init(allocator_: std.mem.Allocator) void {
    allocator = allocator_;

    if (!input_inited) {
        keybinds = Keybinds.init(allocator);
        mousebinds = Mousebinds.init(allocator);
        input_inited = true;
    }
}

pub fn shutdown() void {
    {
        var it = keybinds.valueIterator();
        while (it.next()) |binds| {
            binds.deinit();
        }
    }
    {
        var it = mousebinds.valueIterator();
        while (it.next()) |binds| {
            binds.deinit();
        }
    }

    keybinds.deinit();
    mousebinds.deinit();
}

pub fn bind(key: keycode.Keycode, handler: InputHandler) !KeybindList.Handle {
    const entry = try keybinds.getOrPut(key);
    if (!entry.found_existing) {
        entry.value_ptr.* = try KeybindList.create(allocator, 1);
    }

    const list = entry.value_ptr;
    return try list.insert(handler);
}

pub fn bindMouse(button: MouseButton, handler: MouseInputHandler) !MousebindList.Handle {
    const entry = try mousebinds.getOrPut(button);
    if (!entry.found_existing) {
        entry.value_ptr.* = try MousebindList.create(allocator, 1);
    }
    const list = entry.value_ptr;
    return try list.insert(handler);
}

pub fn queryKey(key: keycode.Keycode) bool {
    for(keys_down[0..num_keys_down]) |downkey| {
        if (downkey == key) return true;
    }
    return false;
}

pub fn queryMouse(button: MouseButton) bool {
    return switch(button) {
        .left => mouse_state.left,
        .right => mouse_state.right,
        .middle => mouse_state.middle,
        .motion => mouse_state.motion.x != 0 and mouse_state.motion.y != 0,
        .wheel => mouse_state.wheel != 0,
    };
}

pub fn post(key: keycode.Keycode, mods: keycode.Keymod, action: InputFlags) void {
    _ = mods;

    if (keybinds.get(key)) |binds| {
        for (binds.entries.items[0..binds.len]) |entry| {
            if (entry == .occupied) {
                const binded = entry.occupied.value;
                // By bitcasting the struct, we can compare each
                // field as if it was a bitmask.
                const left: u8 = @bitCast(action);
                const right: u8 = @bitCast(binded.fire_on);
                if (left & right != 0 and binded.handler != null) binded.handler.?(binded.ctx);
            }
        }
    }
}

pub fn postMouse(mouse: MouseButton, action: InputFlags, event: MouseEvent) void {
    if (mousebinds.get(mouse)) |binds| {
        for (binds.entries.items[0..binds.len]) |entry| {
            if (entry == .occupied) {
                const binded = entry.occupied.value;
                const left: u8 = @bitCast(action);
                const right: u8 = @bitCast(binded.fire_on);
                if (left & right != 0 and binded.handler != null) binded.handler.?(binded.ctx, event);
            }
        }
    }
}

pub fn update(event: sdl.events.Event) void {
    if (!imgui.GetIO().?.WantCaptureKeyboard) switch (event.type) {
        sdl.events.type.key_down => {
            const key = event.key.key;
            if (!event.key.repeat) {
                keys_down[num_keys_down] = key;
                num_keys_down += 1;
                post(key, undefined, .{ .down = true });
            }
            else {
                post(key, undefined, .{ .held = true });
            }
        },

        sdl.events.type.key_up => {
            const key = event.key.key;

            if (num_keys_down > 0) {
                for(0..num_keys_down) |i| {
                    if (keys_down[i] == key) {
                        keys_down[i] = keys_down[num_keys_down - 1];
                        num_keys_down -= 1;
                    }
                }
            }

            post(key, undefined, .{ .up = true });
        },

        else => {},
    };

    if (!imgui.GetIO().?.WantCaptureMouse) switch(event.type) {
        sdl.events.type.mouse_button_down => {
            switch(event.button.button) {
                1 => {
                    mouse_state.left = true;
                    postMouse(.left, .{ .down = true }, .{ .left = event.button });
                },
                2 => {
                    mouse_state.middle = true;
                    postMouse(.middle, .{ .down = true }, .{ .middle = event.button });
                },
                3 => {
                    mouse_state.right = true;
                    postMouse(.right, .{ .down = true }, .{ .right = event.button });
                },
                else => {},
            }
        },
        sdl.events.type.mouse_button_up => {
            switch(event.button.button) {
                1 => {
                    mouse_state.left = false;
                    postMouse(.left, .{ .up = true }, .{ .left = event.button });
                },
                2 => {
                    mouse_state.middle = false;
                    postMouse(.middle, .{ .up = true }, .{ .middle = event.button });
                },
                3 => {
                    mouse_state.right = false;
                    postMouse(.right, .{ .up = true }, .{ .right = event.button });
                },
                else => {},
            }
        },
        sdl.events.type.mouse_motion => {
            mouse_state.motion.x = event.motion.xrel;
            mouse_state.motion.y = event.motion.yrel;
            postMouse(.motion, .{ .down = true }, .{ .motion = event.motion });
        },
        sdl.events.type.mouse_wheel => {
            postMouse(.wheel, .{ .down = true }, .{ .wheel = event.wheel });
        },
        else => {},
    };
}
