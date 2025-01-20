const std = @import("std");
const debug = @import("debug.zig");

pub const RunProto = *const fn (*Runnable, ctx: ?*anyopaque) void;
pub const Runnable = struct { runFn: RunProto };

const Root = @This();

pub fn create(
    comptime handler: anytype,
    args: anytype,
    allocator: std.mem.Allocator,
) !*Runnable {
    const Args = @TypeOf(args);
    const Closure = struct {
        arguments: Args,
        runnable: Runnable = .{ .runFn = runFn },

        fn runFn(runnable: *Runnable, ctx: ?*anyopaque) void {
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

    pub fn make(self: *const Builder, handler: anytype, args: anytype) *Runnable {
        return create(handler, args, self.allocator) catch debug.oom();
    }
};