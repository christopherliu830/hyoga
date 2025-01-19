const std = @import("std");
const sdl = @import("sdl");
const hy = @import("hyoga-lib");
const rt = hy.runtime;
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

    comptime {
        hy.debug.assertMatches(InputFlags, rt.Input.OnFlags);
    }
};

pub const Device = enum(u8) {
    mouse,
    keyboard,

    comptime {
        hy.debug.assertMatches(Device, rt.Input.Device);
    }
};

pub const BindOptions = extern struct {
    button: u32,
    device: Device,
    fire_on: InputFlags,

    comptime {
        hy.debug.assertMatches(BindOptions, rt.Input.BindOptions);
    }
};

pub const DelegateList = std.ArrayListUnmanaged(*hy.closure.Runnable);
const ActionSet = std.EnumArray(Action, DelegateList);
const Mousebinds = std.AutoHashMapUnmanaged(u32, ActionSet);
const Keybinds = std.AutoHashMapUnmanaged(u32, ActionSet);
const KeysDownSet = std.EnumSet(Keycode);
const MouseDownSet = std.EnumSet(MouseButton);

pub const Group = struct {
    pub const Handle = hy.SlotMap(Group).Handle;

    arena: std.heap.ArenaAllocator,
    input: *Input,
    enabled: bool = true,
    keybinds: Keybinds = .empty,
    mousebinds: Mousebinds = .empty,

    pub fn getCallbacks(
        group: *Group,
        device: Device,
        button: u32,
    ) *ActionSet {
        const allocator = group.arena.allocator();
        const action_set = switch (device) {
            .mouse => &group.mousebinds,
            .keyboard => &group.keybinds,
        };

        const entry = action_set.getOrPut(allocator, button) catch hy.err.oom();

        if (!entry.found_existing) {
            entry.value_ptr.* = ActionSet.initFill(.{});
        }

        return entry.value_ptr;
    }

    pub fn bind(
        group: *Group,
        options: BindOptions,
        delegate: *hy.closure.Runnable,
    ) !void {
        const allocator = group.arena.allocator();
        var action_set = group.getCallbacks(options.device, options.button);

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

pub fn bind(self: *Input, hdl: Group.Handle, options: BindOptions, delegate: *hy.closure.Runnable) !void {
    var group = self.groups.getPtr(hdl) catch std.debug.panic("No input group found", .{});
    group.bind(options, delegate) catch std.debug.panic("failed to bind input", .{});
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

pub fn post(self: *Input, device: Device, key: u32, mods: types.Keymod, action: Action, event: anytype) void {
    _ = mods;

    var it = self.groups.iterator();
    while (it.nextPtr()) |group| {
        if (group.enabled) {
            const callbacks = group.getCallbacks(device, key);
            for (callbacks.getPtr(action).items) |handler| {
                var e = event;
                @call(.auto, handler.runFn, .{ handler, &e });
            }
        }
    }
}

pub fn updateKeyboard(self: *Input, event: sdl.events.Event) void {
    switch (event.type) {
        sdl.events.type.key_down => {
            const key = types.fromSdl(event.key.key);
            self.keys_down.insert(key);
            self.post(
                .keyboard,
                @intFromEnum(key),
                undefined,
                if (event.key.repeat) .held else .down,
                event,
            );
        },

        sdl.events.type.key_up => {
            const key = types.fromSdl(event.key.key);
            _ = self.keys_down.remove(key);

            self.post(
                .keyboard,
                @intFromEnum(key),
                undefined,
                .up,
                event,
            );
        },

        else => {},
    }
}

pub fn updateMouse(self: *Input, event: sdl.events.Event) void {
    self.mouse_state.remove(.motion);
    self.mouse_state.remove(.wheel);

    switch (event.type) {
        sdl.events.type.mouse_button_down => {
            const button: MouseButton = switch (event.button.button) {
                0 => unreachable,
                1 => .left,
                2 => .middle,
                3 => .right,
                else => |v| @enumFromInt(v + 100),
            };

            self.mouse_state.insert(button);
            self.post(
                .mouse,
                @intFromEnum(button),
                undefined,
                .down,
                event,
            );
        },

        sdl.events.type.mouse_button_up => {
            const button: MouseButton = switch (event.button.button) {
                0 => unreachable,
                1 => .left,
                2 => .middle,
                3 => .right,
                else => |v| @enumFromInt(v + 100),
            };

            self.mouse_state.remove(button);
            self.post(
                .mouse,
                @intFromEnum(button),
                undefined,
                .up,
                event,
            );
        },

        sdl.events.type.mouse_motion => {
            self.mouse_state.insert(.motion);
            const m = event.motion;
            self.post(
                .mouse,
                @intFromEnum(MouseButton.motion),
                undefined,
                .down,
                hy.event.MouseMotion{
                    .position = hy.math.vec(.{ m.x, m.y }),
                    .delta = hy.math.vec(.{ m.xrel, m.yrel }),
                },
            );
        },

        sdl.events.type.mouse_wheel => {
            self.post(
                .mouse,
                @intFromEnum(MouseButton.wheel),
                undefined,
                .down,
                hy.event.MouseWheel{ .delta = event.wheel.y },
            );
            self.mouse_state.insert(.wheel);
        },
        else => {},
    }
}
