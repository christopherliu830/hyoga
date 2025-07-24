const std = @import("std");

pub const array_group = @import("array_group.zig");
pub const closure = @import("closure.zig");
pub const color = @import("color.zig");
pub const err = @import("debug.zig");
pub const debug = @import("debug.zig");
pub const meta = @import("meta.zig");
pub const event = @import("event.zig");
pub const @"extern" = @import("extern.zig");
pub const key = @import("key.zig");
pub const list = @import("list.zig");
pub const math = @import("math/math.zig");
pub const runtime = @import("runtime.zig");
pub const slot_map = @import("slot_map.zig");
pub const skip_map = @import("skip_map.zig");
pub const circle_queue = @import("circle_queue.zig");

pub const gfx = runtime.gfx;
pub const p2 = runtime.p2;
pub const input = runtime.input;

pub const ArrayGroup = array_group.ArrayGroup;
pub const CircleQueue = circle_queue.CircleQueue;
pub const Color = color.Color;
pub const SlotMap = slot_map.SlotMap;
pub const SkipMap = skip_map.SkipMap;
pub const ExternAllocator = @"extern".ExternAllocator;
pub const ExternSlice = @"extern".ExternSlice;
pub const ExternSliceConst = @"extern".ExternSliceConst;
pub const ExternTaggedUnion = @"extern".ExternTaggedUnion;
pub const Engine = runtime.Engine;
pub const GameInterface = runtime.GameInterface;
pub const Audio = runtime.Audio;
pub const World = runtime.World;
pub const Input = runtime.Input;
pub const Gpu = runtime.Gpu;
pub const Phys2 = runtime.Phys2;
pub const UI = runtime.UI;
pub const Window = runtime.Window;
pub const Keycode = key.Keycode;
pub const Keymod = key.Keymod;
pub const MouseButton = key.MouseButton;

pub inline fn debugPrint(x: anytype) void {
    std.debug.print("{any}\n", .{x});
}

pub inline fn @"f32"(int: anytype) f32 {
    return switch (@typeInfo(@TypeOf(int))) {
        .comptime_int => int,
        .int => @floatFromInt(int),
        else => comptime unreachable,
    };
}

pub inline fn @"u32"(num: anytype) u32 {
    return switch (@typeInfo(@TypeOf(num))) {
        .comptime_int => num,
        .float => @intFromFloat(num),
        .int => @intCast(num),
        else => comptime unreachable,
    };
}

test {
    std.testing.refAllDecls(@This());
}
