const std = @import("std");
const sdl = @import("sdl");
const imgui = @import("imgui");
const hya = @import("hyoga-arena");

const window = @import("window.zig");

pub const keycode = @import("sdl").keycode;
const vec2 = @import("hyoga-math").vec2;

const Input = @This();

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

const Runnable = struct {
    runFn: RunProto,
};

const RunProto = *const fn(*Runnable) void;

const KeybindList = hya.Arena(InputHandler);
const MousebindList = hya.Arena(MouseInputHandler);
const Keybinds = std.AutoHashMap(keycode.Keycode, KeybindList);
const Mousebinds = std.AutoHashMap(MouseButton, MousebindList);
const KeyState = [8]keycode.Keycode; // 32 keys down at once

allocator: std.mem.Allocator,
keybinds: Keybinds,
keys_down: [32]keycode.Keycode = [_]keycode.Keycode { 0 } ** 32,
num_keys_down: u8 = 0,

mousebinds: Mousebinds,
mouse_state: MouseState = .{},

input_inited: bool = false,

pub fn init(in_allocator: std.mem.Allocator) Input {
    return .{
        .allocator = in_allocator,
        .keybinds = Keybinds.init(in_allocator),
        .mousebinds = Mousebinds.init(in_allocator),
        .input_inited = true,
    };
}

pub fn shutdown(self: *@This()) void {
    {
        var it = self.keybinds.valueIterator();
        while (it.next()) |binds| {
            binds.deinit();
        }
    }
    {
        var it = self.mousebinds.valueIterator();
        while (it.next()) |binds| {
            binds.deinit();
        }
    }

    self.keybinds.deinit();
    self.mousebinds.deinit();
}

pub fn bind(self: *Input, key: keycode.Keycode, handler: InputHandler) !KeybindList.Handle {
    const entry = try self.keybinds.getOrPut(key);
    if (!entry.found_existing) {
        entry.value_ptr.* = try KeybindList.create(self.allocator, 1);
    }

    const list = entry.value_ptr;
    return try list.insert(handler);
}

pub fn bindMouse(self: *Input, button: MouseButton, handler: MouseInputHandler) !MousebindList.Handle {
    const entry = try self.mousebinds.getOrPut(button);
    if (!entry.found_existing) {
        entry.value_ptr.* = try MousebindList.create(self.allocator, 1);
    }
    const list = entry.value_ptr;
    return try list.insert(handler);
}

pub fn bindMouseAny(self: *Input, button: MouseButton, comptime handler: anytype, args: anytype) {
    const Args = @TypeOf(args);
    const Closure = struct {
        input: *Input,
        arguments: Args,
        run_node: std.SinglyLinkedList(Runnable).Node = .{ .data = .{ .runFn = runFn }},

        fn runFn() void {
            const run_node: *std.SinglyLinkedList(Runnable).Node = @fieldParentPtr("data", runnable);
            const closure: *@This() = @alignCast(@fieldParentPtr("run_node", run_node));
            @call(.auto, func, closure.arguments);
            closure.input.allocator.destroy(closure);
        }
    };
}

pub fn queryKey(self: *Input, key: keycode.Keycode) bool {
    for(self.keys_down[0..self.num_keys_down]) |downkey| {
        if (downkey == key) return true;
    }
    return false;
}

pub fn queryMouse(self: *Input, button: MouseButton) bool {
    return switch(button) {
        .left => self.mouse_state.left,
        .right => self.mouse_state.right,
        .middle => self.mouse_state.middle,
        .motion => self.mouse_state.motion.x != 0 and self.mouse_state.motion.y != 0,
        .wheel => self.mouse_state.wheel != 0,
    };
}

pub fn post(self: *Input, key: keycode.Keycode, mods: keycode.Keymod, action: InputFlags) void {
    _ = mods;

    if (self.keybinds.get(key)) |binds| {
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

pub fn postMouse(self: *Input, mouse: MouseButton, action: InputFlags, event: MouseEvent) void {
    if (self.mousebinds.get(mouse)) |binds| {
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

pub fn update(self: *Input, event: sdl.events.Event) void {
    switch (event.type) {
        sdl.events.type.key_down => {
            const key = event.key.key;
            if (!event.key.repeat) {
                self.keys_down[self.num_keys_down] = key;
                self.num_keys_down += 1;
                self.post(key, undefined, .{ .down = true });
            }
            else {
                self.post(key, undefined, .{ .held = true });
            }
        },

        sdl.events.type.key_up => {
            const key = event.key.key;

            if (self.num_keys_down > 0) {
                for(0..self.num_keys_down) |i| {
                    if (self.keys_down[i] == key) {
                        self.keys_down[i] = self.keys_down[self.num_keys_down - 1];
                        self.num_keys_down -= 1;
                    }
                }
            }

            self.post(key, undefined, .{ .up = true });
        },

        else => {},
    }

    switch(event.type) {
        sdl.events.type.mouse_button_down => {
            switch(event.button.button) {
                1 => {
                    self.mouse_state.left = true;
                    self.postMouse(.left, .{ .down = true }, .{ .left = event.button });
                },
                2 => {
                    self.mouse_state.middle = true;
                    self.postMouse(.middle, .{ .down = true }, .{ .middle = event.button });
                },
                3 => {
                    self.mouse_state.right = true;
                    self.postMouse(.right, .{ .down = true }, .{ .right = event.button });
                },
                else => {},
            }
        },
        sdl.events.type.mouse_button_up => {
            switch(event.button.button) {
                1 => {
                    self.mouse_state.left = false;
                    self.postMouse(.left, .{ .up = true }, .{ .left = event.button });
                },
                2 => {
                    self.mouse_state.middle = false;
                    self.postMouse(.middle, .{ .up = true }, .{ .middle = event.button });
                },
                3 => {
                    self.mouse_state.right = false;
                    self.postMouse(.right, .{ .up = true }, .{ .right = event.button });
                },
                else => {},
            }
        },
        sdl.events.type.mouse_motion => {
            self.mouse_state.motion.x = event.motion.xrel;
            self.mouse_state.motion.y = event.motion.yrel;
            self.postMouse(.motion, .{ .down = true }, .{ .motion = event.motion });
        },
        sdl.events.type.mouse_wheel => {
            self.postMouse(.wheel, .{ .down = true }, .{ .wheel = event.wheel });
        },
        else => {},
    }
}
