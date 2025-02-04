//! Helper for linking to runtime input system.
const std = @import("std");
const keys = @import("../key.zig");
const math = @import("../math/math.zig");
const closure = @import("../closure.zig");

pub const Input = opaque {
    pub const Device = enum(u8) {
        mouse,
        keyboard,
    };

    pub const Group = enum(u64) {
        none = 0,
        _,
    };

    pub const OnFlags = packed struct(u8) {
        up: bool = false,
        down: bool = false,
        held: bool = false,
        _padding: u5 = 0,
    };

    pub const BindButton = union {
        keyboard: keys.Keycode,
        mouse: keys.MouseButton,
    };

    pub const BindOptions = extern struct {
        button: u32,
        device: Device,
        fire_on: OnFlags = .{ .down = true },

        // Convenience generators here

        pub fn mouseOn(button: keys.MouseButton, flags: OnFlags) BindOptions {
            std.debug.assert(flags.down or flags.up or flags.held);

            return .{
                .button = @intFromEnum(button),
                .device = .mouse,
                .fire_on = flags,
            };
        }

        pub fn mouse(button: keys.MouseButton) BindOptions {
            return mouseOn(button, .{ .down = true });
        }

        pub fn mouseUp(button: keys.MouseButton) BindOptions {
            return mouseOn(button, .{ .up = true });
        }

        pub fn mouseHeld(button: keys.MouseButton) BindOptions {
            return mouseOn(button, .{ .held = true });
        }

        pub fn keyOn(button: keys.Keycode, flags: OnFlags) BindOptions {
            return .{
                .button = @intFromEnum(button),
                .device = .keyboard,
                .fire_on = flags,
            };
        }

        pub fn key(button: keys.Keycode) BindOptions {
            return keyOn(button, .{ .down = true });
        }

        pub fn keyUp(button: keys.Keycode) BindOptions {
            return keyOn(button, .{ .up = true });
        }

        pub fn keyHeld(button: keys.Keycode) BindOptions {
            return keyOn(button, .{ .held = true });
        }
    };

    pub const BindHelper = struct {
        allocator: std.mem.Allocator,
        input: *Input,
        group: Group,

        pub fn bind(self: *const BindHelper, opts: BindOptions, handler: anytype, args: anytype) void {
            self.input.bind(
                self.group,
                opts,
                closure.createDynamic(handler, args, self.allocator) catch std.debug.panic("oom", .{}),
            );
        }
    };

    pub const reset = hyioReset;
    pub const createGroup = hyioCreateGroup;
    pub const getGroup = hyioGetGroup;
    pub const groupDestroy = hyioGroupDestroy;
    pub const setGroupEnabled = hyioSetGroupEnabled;
    pub const bind = hyioBind;
    pub const queryMouse = hyioQueryMouse;
    pub const queryMousePosition = hyioQueryMousePosition;
    pub const queryKey = hyioQueryKey;

    extern fn hyioReset(*Input) void;
    extern fn hyioCreateGroup(*Input) Input.Group;
    extern fn hyioGetGroup(*Input, Group) Group;
    extern fn hyioGroupDestroy(*Input, Group) void;
    extern fn hyioSetGroupEnabled(*Input, Group, bool) void;
    extern fn hyioBind(*Input, Group, BindOptions, *closure.Runnable(anyopaque)) void;
    extern fn hyioQueryMouse(*Input, keys.MouseButton) bool;
    extern fn hyioQueryMousePosition(*Input) math.Vec2;
    extern fn hyioQueryKey(*Input, keys.Keycode) bool;
};
