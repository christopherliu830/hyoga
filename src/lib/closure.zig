const std = @import("std");
const debug = @import("debug.zig");

// pub const RunProto = *const fn (*Runnable, ctx: ?*anyopaque) void;
// pub const Runnable = struct { runFn: RunProto };

pub fn Runnable(Event: type) type {
    return struct {
        const RunProto = fn (*Runnable(Event), ctx: ?*const Event) void;
        runFn: *const RunProto,
    };
}

const Root = @This();

pub fn createDynamic(
    comptime handler: anytype,
    args: anytype,
    allocator: std.mem.Allocator,
) !*Runnable(anyopaque) {
    return create(handler, args, anyopaque, allocator);
}

pub fn create(
    comptime handler: anytype,
    args: anytype,
    comptime Context: type,
    allocator: std.mem.Allocator,
) !*Runnable(Context) {
    const Args = @TypeOf(args);
    const Closure = struct {
        arguments: Args,
        runnable: Runnable(Context) = .{ .runFn = runFn },

        fn runFn(runnable: *Runnable(Context), ctx: ?*const Context) void {
            const closure: *@This() = @alignCast(@fieldParentPtr("runnable", runnable));
            @call(.auto, handler, closure.arguments ++ .{ctx});
        }
    };

    const closure = try allocator.create(Closure);
    closure.* = .{ .arguments = args };
    return &closure.runnable;
}

/// Convenience builder for making many closures at once.
pub const Builder = struct {
    allocator: std.mem.Allocator,

    pub fn make(self: *const Builder, handler: anytype, args: anytype) *Runnable(anyopaque) {
        return createDynamic(handler, args, self.allocator) catch debug.oom();
    }
};
