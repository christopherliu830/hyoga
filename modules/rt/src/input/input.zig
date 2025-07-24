const std = @import("std");
const sdl = @import("sdl");
const hy = @import("hyoga-lib");
const rt = hy.runtime;
const imgui = @import("imgui");
const window = @import("../window.zig");
const types = @import("types.zig");
const log = std.log.scoped(.input);

const Input = @This();

allocator: std.mem.Allocator,
groups: hy.SlotMap(Group),
keys_down: KeysDownSet = .{},
mouse_state: MouseDownSet = .{},
input_inited: bool = false,
events: std.ArrayListUnmanaged(u32) = .empty,
triggers: std.ArrayListUnmanaged(Trigger) = .empty,

pub const MouseButton = hy.MouseButton;
pub const Keycode = hy.Keycode;
pub const Action = enum { up, down, held };

pub const InputFlags = packed struct(u8) {
    up: bool = false,
    down: bool = false,
    held: bool = false,
    _padding: u5 = 0,

    comptime {
        hy.meta.assertMatches(InputFlags, rt.Input.OnFlags);
    }
};

pub const Device = enum(u8) {
    mouse,
    keyboard,

    comptime {
        hy.meta.assertMatches(Device, rt.Input.Device);
    }
};

pub const BindOptions = extern struct {
    button: u32,
    device: Device,
    fire_on: InputFlags,

    comptime {
        hy.meta.assertMatches(BindOptions, rt.Input.BindOptions);
    }
};

pub const Trigger = struct {
    id: u32,
    on: hy.Input.OnFlags,
    code: union (enum) {
        button: Keycode,
        mouse: MouseButton,
    },
};

pub const DelegateList = std.ArrayListUnmanaged(*hy.closure.Runnable(anyopaque));

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
        delegate: *hy.closure.Runnable(anyopaque),
    ) !void {
        const allocator = group.arena.allocator();
        var action_set = group.getCallbacks(options.device, options.button);

        const fire_on = options.fire_on;

        if (fire_on.down) try action_set.getPtr(.down).append(allocator, delegate);
        if (fire_on.up) try action_set.getPtr(.up).append(allocator, delegate);
        if (fire_on.held) try action_set.getPtr(.held).append(allocator, delegate);
    }
};

pub fn init(in_allocator: std.mem.Allocator) Input {
    return .{
        .allocator = in_allocator,
        .groups = .empty,
        .input_inited = true,
    };
}

pub fn shutdown(self: *Input) void {
    var it = self.groups.iterator();
    while (it.nextPtr()) |group| {
        group.arena.deinit();
    }
    self.groups.deinit(self.allocator);
    self.triggers.deinit(self.allocator);
    self.events.deinit(self.allocator);
}

pub fn reset(self: *Input) void {
    var it = self.groups.iterator();
    while (it.nextPtr()) |group| {
        group.arena.deinit();
        self.groups.remove(it.handle());
    }
}

pub fn createGroup(self: *Input) Group.Handle {
    const hdl = self.groups.insert(self.allocator, .{
        .input = self,
        .arena = .init(self.allocator),
    }) catch unreachable;
    return hdl;
}

pub fn groupDestroy(self: *Input, handle: Group.Handle) void {
    var group = self.groups.get(handle) orelse {
        log.warn("invalid group passed to destroy", .{});
        return;
    };
    group.arena.deinit();
    self.groups.remove(handle);
}

pub fn getGroup(self: *Input, hdl: Group.Handle) Group.Handle {
    if (self.groups.num_items == 0) {
        @branchHint(.cold);
        return self.createGroup();
    } else if (self.groups.get(hdl)) |_| {
        return hdl;
    } else {
        return self.createGroup();
    }
}

pub fn setGroupEnabled(
    self: *Input,
    hdl: Group.Handle,
    enabled: bool,
) void {
    const group = self.groups.getPtr(hdl) orelse
        std.debug.panic("Invalid group handle", .{});
    group.enabled = enabled;
}

pub fn bind(
    self: *Input,
    hdl: Group.Handle,
    options: BindOptions,
    delegate: *hy.closure.Runnable(anyopaque),
) !void {
    var group = self.groups.getPtr(hdl) orelse std.debug.panic("No input group found", .{});
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
        .key_down => {
            const key = types.fromSdl(event.key.key);
            self.keys_down.insert(key);
            self.post(
                .keyboard,
                @intFromEnum(key),
                undefined,
                if (event.key.repeat) .held else .down,
                event,
            );

            for (self.triggers.items) |trigger| {
                if (trigger.code == .button and
                    trigger.code.button == key and
                    trigger.on.down)
                {
                    self.events.append(self.allocator, trigger.id) catch |err| {
                        std.log.err("append input event failure: {}", .{err});
                    };
                }
            }
        },

        .key_up => {
            const key = types.fromSdl(event.key.key);
            _ = self.keys_down.remove(key);

            self.post(
                .keyboard,
                @intFromEnum(key),
                undefined,
                .up,
                event,
            );

            for (self.triggers.items) |trigger| {
                if (trigger.code == .button and
                    trigger.code.button == key and
                    trigger.on.up)
                {
                    self.events.append(self.allocator, trigger.id) catch |err| {
                        std.log.err("append input event failure: {}", .{err});
                    };
                }
            }
        },

        else => {},
    }
}

pub fn updateMouse(self: *Input, event: sdl.events.Event) void {
    self.mouse_state.remove(.motion);
    self.mouse_state.remove(.wheel);

    switch (event.type) {
        .mouse_button_down => {
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

        .mouse_button_up => {
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

        .mouse_motion => {
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

            for (self.triggers.items) |trigger| {
                if (trigger.code == .mouse and
                    trigger.code.mouse == .motion and
                    trigger.on.down)
                {
                    self.events.append(self.allocator, trigger.id) catch |err| {
                        std.log.err("append input event failure: {}", .{err});
                    };
                }
            }

        },

        .mouse_wheel => {
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

pub fn bindPoll(self: *Input, id: u32, on: hy.Input.OnFlags, code: Keycode) !void {
    try self.triggers.append(self.allocator, .{
        .id = id,
        .on = on,
        .code = .{ .button = code },
    });
}

pub fn bindPollMouse(self: *Input, id: u32, on: hy.Input.OnFlags, code: MouseButton) !void {
    try self.triggers.append(self.allocator, .{
        .id = id,
        .on = on,
        .code = .{ .mouse  = code },
    });
}

pub fn eventPump(self: *Input) ![]const u32 {
    const events = try self.events.toOwnedSlice(self.allocator);
    self.events = .empty;
    return events;
}

pub fn eventClear(self: *Input, events: []const u32) void {
    self.allocator.free(events);
}
