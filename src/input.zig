const std = @import("std");
const glfw = @import("mach-glfw");
const genarray = @import("genarray.zig");

const Handler = fn () void;

pub const Key = glfw.Key;
pub const ActionArray = genarray.GenArray(Action);
pub const Keybinds = std.AutoHashMap(Key, ActionArray.Handle);

pub const Action = struct {
    handler: *const Handler, 
};

pub const InputSystem = struct {
    actions: ActionArray,
    keybinds: Keybinds,

    pub fn create(allocator: std.mem.Allocator) !InputSystem {
        return InputSystem {
            .actions = try ActionArray.create(allocator, 8),
            .keybinds = Keybinds.init(allocator),
        };
    }

    pub fn register(self: *InputSystem, key: Key, action: Action) !ActionArray.Handle { 
        const action_id = try self.actions.insert(action);
        try self.keybinds.put(key, action_id);
        return action_id;
    }

    pub fn run(self: InputSystem, window: glfw.Window) void { 
        _ = self;
        _ = window;
    }
};