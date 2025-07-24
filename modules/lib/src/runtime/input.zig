const std = @import("std");
const hy = @import("../root.zig");
const hym = hy.math;
const keys = @import("../key.zig");
const math = @import("../math/math.zig");
const closure = @import("../closure.zig");
const proc_table = @import("proc_table.zig");
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

pub const Context = opaque {
    pub fn reset(input: *Context) void {
        proc.hy_io_reset(input);
    }

    pub fn mouse(input: *Context, button: hy.MouseButton) bool {
        return proc.hy_io_mouse(input, button);
    }

    pub fn mousePosition(input: *Context) hym.Vec2 {
        return proc.hy_io_mousePosition(input);
    }

    pub fn bindPoll(input: *Context, id: anytype, on: OnFlags, code: keys.Keycode) void {
        std.debug.assert(@sizeOf(@TypeOf(id)) == @sizeOf(u32));
        proc.hy_io_bindPoll(input, @intFromEnum(id), on, code);
    }

    pub fn bindPollMouse(input: *Context, id: anytype, on: OnFlags, code: keys.MouseButton) void {
        std.debug.assert(@sizeOf(@TypeOf(id)) == @sizeOf(u32));
        proc.hy_io_bindPollMouse(input, @intFromEnum(id), on, code);
    }

    pub fn key(input: *Context, code: hy.Keycode) bool {
        return proc.hy_io_key(input, code);
    }

    pub fn eventPump(input: *Context, T: type) []const T {
        std.debug.assert(@sizeOf(T) == @sizeOf(u32));
        const ext_slice = proc.hy_io_eventPump(input);
        return @as([*]const T, @ptrCast(ext_slice.ptr))[0..ext_slice.len];
    }

    pub fn eventClear(input: *Context, slice: anytype) void {
        const type_info = @typeInfo(@TypeOf(slice));
        std.debug.assert(type_info.pointer.size == .slice);
        const Child = type_info.pointer.child;
        std.debug.assert(@sizeOf(Child) == @sizeOf(u32));
        const ext_slice: hy.ExternSliceConst(u32) = .{
            .ptr = @ptrCast(slice.ptr),
            .len = slice.len,
        };
        proc.hy_io_eventClear(input, ext_slice);
    }
};
