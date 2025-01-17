const std = @import("std");

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

pub const ClosureBuilder = struct {
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) ClosureBuilder {
        return .{ .allocator = allocator };
    }

    pub fn create(
        self: ClosureBuilder,
        comptime handler: anytype,
        args: anytype,
    ) !void {
        return Root.create(handler, args, self.allocator);
    }
};
