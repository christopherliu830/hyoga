const std = @import("std");
const hy = @import("../root.zig");
const hym = hy.math;
const keys = @import("../key.zig");
const math = @import("../math/math.zig");
const closure = @import("../closure.zig");
const proc_table = @import("../generated/proc_table.zig");
const proc = &proc_table.table;

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

    pub const on_down: OnFlags = .{ .down = true };
    pub const on_up: OnFlags = .{ .up = true };
    pub const on_held: OnFlags = .{ .held = true };
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
    input: *Context,
    group: Group,

    pub fn bind(self: *const BindHelper, opts: BindOptions, handler: anytype, args: anytype) void {
        self.input.bind(
            self.group,
            opts,
            closure.createDynamic(handler, args, self.allocator) catch std.debug.panic("oom", .{}),
        );
    }
};

pub fn Input(T: type) type {
    std.debug.assert(@sizeOf(T) == @sizeOf(u32));

    return struct {
        ctx: *Context,

        pub fn reset(input: Input(T)) void {
            proc.hy_io_reset(input.ctx);
        }

        pub fn mouse(input: Input(T), button: hy.MouseButton) bool {
            return proc.hy_io_mouse(input.ctx, button);
        }

        pub fn mousePosition(input: Input(T)) hym.Vec2 {
            return proc.hy_io_mousePosition(input.ctx);
        }

        pub fn bindPoll(input: Input(T), id: T, on: OnFlags, code: keys.Keycode) void {
            proc.hy_io_bindPoll(input.ctx, @intFromEnum(id), on, code);
        }

        pub fn bindPollMouse(input: Input(T), id: T, on: OnFlags, code: keys.MouseButton) void {
            proc.hy_io_bindPollMouse(input.ctx, @intFromEnum(id), on, code);
        }

        pub fn key(input: Input(T), code: hy.Keycode) bool {
            return proc.hy_io_key(input.ctx, code);
        }

        pub fn eventPump(input: Input(T)) []const T {
            const ext_slice = proc.hy_io_eventPump(input.ctx);
            return @as([*]const T, @ptrCast(ext_slice.ptr))[0..ext_slice.len];
        }

        pub fn eventClear(input: Input(T), slice: []const T) void {
            const ext_slice: hy.ExternSliceConst(u32) = .{
                .ptr = @ptrCast(slice.ptr),
                .len = slice.len,
            };
            proc.hy_io_eventClear(input.ctx, ext_slice);
        }
    };
}

pub const Context = opaque {};
