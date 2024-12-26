//! Helper for linking to runtime input system.
const std = @import("std");
const key = @import("../key.zig");
const closure = @import("../closure.zig");

pub const Input = opaque {
    pub const reset = hyioReset;
    pub const bindMouse = hyioBindMouse;
    pub const bindKey = hyioBindKey;
    pub const queryMouse = hyioQueryMouse;
    pub const queryKey = hyioQueryKey;
};

pub const InputFlags = packed struct (u8) {
    up: bool = false,
    down: bool = false,
    held: bool = false,
    _padding: u5 = 0,
};

pub const BindKeyOptions = extern struct {
    button: key.Keycode,
    fire_on: InputFlags = .{ .down = true },
};

pub const BindMouseOptions = extern struct {
    button: key.MouseButton,
    fire_on: InputFlags = .{ .down = true },
};

extern fn hyioReset(*Input) void;
extern fn hyioBindMouse(*Input, BindMouseOptions, *closure.Runnable) void;
extern fn hyioBindKey(*Input, BindKeyOptions, *closure.Runnable) void;
extern fn hyioQueryMouse(*Input, key.MouseButton) bool;
extern fn hyioQueryKey(*Input, key.Keycode) bool;
