const std = @import("std");
const sdl = @import("sdl");
const hy = @import("hyoga-lib");
const imgui = @import("imgui");
const window = @import("../window.zig");
const types = @import("types.zig");

pub const MouseButton = hy.MouseButton;
pub const Keycode = hy.Keycode;

pub const Event = sdl.events.Event;

const Input = @This();

pub const Action = enum { up, down, held };

pub const InputFlags = packed struct(u8) {
    up: bool = false,
    down: bool = false,
    held: bool = false,
    _padding: u5 = 0,
};

pub const BindKeyOptions = extern struct {
    group: Group.Handle,
    button: hy.key.Keycode,
    fire_on: InputFlags,
};

pub const BindMouseOptions = extern struct {
    group: Group.Handle,
    button: hy.key.MouseButton,
    fire_on: InputFlags,
};

pub const DelegateList = std.ArrayListUnmanaged(*hy.closure.Runnable);
const ActionSet = std.EnumArray(Action, DelegateList);
const Mousebinds = std.AutoHashMapUnmanaged(MouseButton, ActionSet);
const Keybinds = std.AutoHashMapUnmanaged(Keycode, ActionSet);
const KeysDownSet = std.EnumSet(Keycode);
const MouseDownSet = std.EnumSet(MouseButton);

pub const Group = struct {
    pub const Handle = hy.SlotMap(Group).Handle;

    arena: std.heap.ArenaAllocator,
    input: *Input,
    enabled: bool = true,
    keybinds: Keybinds = .empty,
    mousebinds: Mousebinds = .empty,

    pub fn getKeyCallbacks(group: *Group, button: Keycode) ?*ActionSet {
        // const allocator = std.heap.c_allocator;
        const allocator = group.arena.allocator();

        const entry = group.keybinds.getOrPut(allocator, button) catch {
            std.log.warn("[INPUT] Out of memory", .{});
            return null;
        };

        if (!entry.found_existing) {
            entry.value_ptr.* = ActionSet.initFill(.{});
        }

        return entry.value_ptr;
    }

    pub fn getMouseCallbacks(group: *Group, button: MouseButton) ?*ActionSet {
        // const allocator = std.heap.c_allocator;
        const allocator = group.arena.allocator();

        const entry = group.mousebinds.getOrPut(allocator, button) catch {
            std.log.warn("[INPUT] Out of memory", .{});
            return null;
        };
        if (!entry.found_existing) {
            entry.value_ptr.* = ActionSet.initFill(.{});
        }
        return entry.value_ptr;
    }

    pub fn bindMouse(group: *Group, options: BindMouseOptions, delegate: *hy.closure.Runnable) !void {
        // const allocator = std.heap.c_allocator;
        const allocator = group.arena.allocator();

        const action_set = group.getMouseCallbacks(options.button) orelse return;
        const fire_on = options.fire_on;

        if (fire_on.down) try action_set.getPtr(.down).append(allocator, delegate);
        if (fire_on.up) try action_set.getPtr(.up).append(allocator, delegate);
        if (fire_on.held) try action_set.getPtr(.held).append(allocator, delegate);
    }

    pub fn bindKey(group: *Group, options: BindKeyOptions, delegate: *hy.closure.Runnable) !void {
        // const allocator = std.heap.c_allocator;
        const allocator = group.arena.allocator();

        const action_set = group.getKeyCallbacks(options.button) orelse return;
        const fire_on = options.fire_on;
        if (fire_on.down) try action_set.getPtr(.down).append(allocator, delegate);
        if (fire_on.up) try action_set.getPtr(.up).append(allocator, delegate);
        if (fire_on.held) try action_set.getPtr(.held).append(allocator, delegate);
    }
};

allocator: std.mem.Allocator,
keybinds: Keybinds = .empty,
mousebinds: Mousebinds = .empty,
groups: hy.SlotMap(Group),
keys_down: KeysDownSet = .{},
mouse_state: MouseDownSet = .{},

input_inited: bool = false,

pub fn init(in_allocator: std.mem.Allocator) Input {
    return .{
        .allocator = in_allocator,
        .groups = hy.SlotMap(Group).create(in_allocator, 8) catch hy.err.oom(),
        .input_inited = true,
    };
}

pub fn shutdown(self: *Input) void {
    self.groups.deinit();
}

pub fn reset(self: *Input) void {
    self.groups.clear();
}

pub fn createGroup(self: *Input) Group.Handle {
    const hdl = self.groups.insert(.{
        .input = self,
        .arena = .init(std.heap.c_allocator),
    }) catch unreachable;
    return hdl;
}

pub fn getGroup(self: *Input, hdl: Group.Handle) Group.Handle {
    if (self.groups.get(hdl)) |_| {
        return hdl;
    } else |_| {
        return self.createGroup();
    }
}

pub fn setGroupEnabled(
    self: *Input,
    hdl: Group.Handle,
    enabled: bool,
) void {
    const group = self.groups.getPtr(hdl) catch
        std.debug.panic("Invalid group handle", .{});
    group.enabled = enabled;
}

pub fn bindMouse(self: *Input, options: BindMouseOptions, delegate: *hy.closure.Runnable) !void {
    var group = self.groups.getPtr(options.group) catch std.debug.panic("No input group found", .{});
    group.bindMouse(options, delegate) catch std.debug.panic("failed to bind input", .{});
}

pub fn bindKey(self: *Input, options: BindKeyOptions, delegate: *hy.closure.Runnable) !void {
    var group = self.groups.getPtr(options.group) catch std.debug.panic("No input group found", .{});
    group.bindKey(options, delegate) catch std.debug.panic("failed to bind input", .{});
}

pub fn queryKey(self: *Input, key: types.Keycode) bool {
    return self.keys_down.contains(key);
}

pub fn queryMouse(self: *Input, button: MouseButton) bool {
    return self.mouse_state.contains(button);
}

pub fn queryMousePosition(_: *Input) hy.math.Vec2 {
    var x: f32 = 0;
    var y: f32 = 0;
    _ = sdl.mouse.getMouseState(&x, &y);
    return hy.math.vec2.create(x, y);
}

pub fn post(self: *Input, key: types.Keycode, mods: types.Keymod, action: Action, event: sdl.events.Event) void {
    _ = mods;

    var it = self.groups.iterator();
    while (it.nextPtr()) |group| {
        if (group.enabled) {
            const callbacks = group.getKeyCallbacks(key) orelse return;
            for (callbacks.getPtr(action).items) |handler| {
                var e = event;
                @call(.auto, handler.runFn, .{ handler, &e });
            }
        }
    }
}

pub fn postMouse(self: *Input, mouse: MouseButton, action: Action, event: anytype) void {
    var it = self.groups.iterator();
    while (it.nextPtr()) |group| {
        if (group.enabled) {
            const callbacks = group.getMouseCallbacks(mouse) orelse return;
            for (callbacks.getPtr(action).items) |handler| {
                @call(.auto, handler.runFn, .{ handler, @constCast(&event) });
            }
        }
    }
}

pub fn updateKeyboard(self: *Input, event: sdl.events.Event) void {
    switch (event.type) {
        sdl.events.type.key_down => {
            const key = types.fromSdl(event.key.key);
            self.keys_down.insert(key);
            self.post(key, undefined, if (event.key.repeat) .held else .down, event);
        },

        sdl.events.type.key_up => {
            const key = types.fromSdl(event.key.key);
            _ = self.keys_down.remove(key);
            self.post(key, undefined, .up, event);
        },

        else => {},
    }
}

pub fn updateMouse(self: *Input, event: sdl.events.Event) void {
    self.mouse_state.remove(.motion);
    self.mouse_state.remove(.wheel);

    switch (event.type) {
        sdl.events.type.mouse_button_down => {
            switch (event.button.button) {
                1 => {
                    self.mouse_state.insert(.left);
                    self.postMouse(.left, .down, event);
                },
                2 => {
                    self.mouse_state.insert(.middle);
                    self.postMouse(.middle, .down, event);
                },
                3 => {
                    self.mouse_state.insert(.right);
                    self.postMouse(.right, .down, event);
                },
                else => {},
            }
        },

        sdl.events.type.mouse_button_up => {
            switch (event.button.button) {
                1 => {
                    self.mouse_state.remove(.left);
                    self.postMouse(.left, .up, event);
                },
                2 => {
                    self.mouse_state.remove(.middle);
                    self.postMouse(.middle, .up, event);
                },
                3 => {
                    self.mouse_state.remove(.right);
                    self.postMouse(.right, .up, event);
                },
                else => {},
            }
        },

        sdl.events.type.mouse_motion => {
            self.mouse_state.insert(.motion);
            const m = event.motion;
            self.postMouse(.motion, .down, hy.event.MouseMotion{
                .position = hy.math.vec(.{ m.x, m.y }),
                .delta = hy.math.vec(.{ m.xrel, m.yrel }),
            });
        },
        sdl.events.type.mouse_wheel => {
            self.mouse_state.insert(.wheel);
            self.postMouse(.wheel, .down, hy.event.MouseWheel{ .delta = event.wheel.y });
        },
        else => {},
    }
}
