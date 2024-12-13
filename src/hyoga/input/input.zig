const std = @import("std");
const sdl = @import("sdl");
const imgui = @import("imgui");
const hya = @import("hyoga-arena");
const vec2 = @import("hyoga-math").vec2;
const window = @import("../window.zig");
const types = @import("types.zig");

pub const MouseButton = types.MouseButton;
pub const Keycode = types.Keycode;
pub const Event = sdl.events.Event;

const Input = @This();

pub const Action = enum { up, down, held };

pub const InputFlags = packed struct(u8) {
    up: bool = false,
    down: bool = false,
    held: bool = false,

    _padding: u5 = 0,
};

const Runnable = struct {
    runFn: RunProto,
};
const RunProto = *const fn(*Runnable, event: sdl.events.Event) void;

const DelegateList = std.SinglyLinkedList(Runnable);
const ActionSet = std.EnumArray(Action, DelegateList);
const Mousebinds = std.EnumArray(MouseButton, ActionSet);
const Keybinds = std.EnumArray(Keycode, ActionSet);
const KeysDownSet = std.EnumSet(Keycode);
const MouseDownSet = std.EnumSet(MouseButton);

allocator: std.mem.Allocator,
keybinds: Keybinds,
mousebinds: Mousebinds,
keys_down: KeysDownSet = .{},
mouse_state: MouseDownSet = .{}, 

input_inited: bool = false,

pub fn init(in_allocator: std.mem.Allocator) !Input {
    return .{
        .allocator = in_allocator,
        .mousebinds = Mousebinds.initFill(ActionSet.initFill(.{})),
        .keybinds = Keybinds.initFill(ActionSet.initFill(.{})),
        .input_inited = true,
    };
}

pub fn shutdown(self: *@This()) void {
    _ = self;
}

pub const BindKeyOptions = struct {
    button: Keycode,
    fire_on: InputFlags = .{ .down = true },
};

pub fn bindKey(self: *Input, options: BindKeyOptions, comptime handler: anytype, args: anytype) !void {
    const action_set= self.keybinds.getPtr(options.button);
    try self.bind(action_set, options.fire_on, handler, args);
}

pub const BindMouseOptions = struct {
    button: MouseButton,
    fire_on: InputFlags = .{ .down = true },
};

pub fn bindMouse(self: *Input, options: BindMouseOptions, comptime handler: anytype, args: anytype) !void {
    const action_set= self.mousebinds.getPtr(options.button);
    try self.bind(action_set, options.fire_on, handler, args);
}

fn bind(self: *Input, action_set: *ActionSet, fire_on: InputFlags , comptime handler: anytype, args: anytype) !void {
    const Args = @TypeOf(args);
    const Closure = struct {
        input: *Input,
        arguments: Args,
        run_node: DelegateList.Node = .{ .data = .{ .runFn = runFn }},

        fn runFn(runnable: *Runnable, event: sdl.events.Event) void {
            const run_node: *DelegateList.Node = @fieldParentPtr("data", runnable);
            const closure: *@This() = @alignCast(@fieldParentPtr("run_node", run_node));
            @call(.auto, handler, closure.arguments ++ .{event});
        }
    };

    const closure = try self.allocator.create(Closure);
    closure.* = .{
        .arguments = args,
        .input = self,
    };

    if (fire_on.down) action_set.getPtr(.down).prepend(&closure.run_node);
    if (fire_on.up) action_set.getPtr(.up).prepend(&closure.run_node);
    if (fire_on.held) action_set.getPtr(.held).prepend(&closure.run_node);
}

pub fn queryKey(self: *Input, key: types.Keycode) bool {
    for(self.keys_down.items) |downkey| {
        if (downkey == key) return true;
    }
    return false;
}

pub fn queryMouse(self: *Input, button: MouseButton) bool {
    return self.mouse_state.contains(button);
}

pub fn post(self: *Input, key: types.Keycode, mods: types.Keymod, action: Action, event: sdl.events.Event) void {
    _ = mods;
    var node = self.keybinds.getPtr(key).getPtr(action).first;
    while (node) |binded| : (node = binded.next) {
        binded.data.runFn(&binded.data, event);
    }
}

pub fn postMouse(self: *Input, mouse: MouseButton, action: Action, event: sdl.events.Event) void {
    var node = self.mousebinds.getPtr(mouse).getPtr(action).first;
    while (node) |binded| : (node = binded.next) {
        binded.data.runFn(&binded.data, event);
    }
}

pub fn update(self: *Input, event: sdl.events.Event) void {
    self.mouse_state.remove(.motion);
    self.mouse_state.remove(.wheel);

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

        sdl.events.type.mouse_button_down => {
            switch(event.button.button) {
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
            switch(event.button.button) {
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
            self.postMouse(.motion, .down, .{ .motion = event.motion });
        },
        sdl.events.type.mouse_wheel => {
            self.mouse_state.insert(.wheel);
            self.postMouse(.wheel, .down, .{ .wheel = event.wheel });
        },
        else => {},
    }
}
