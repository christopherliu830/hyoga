const std = @import("std");

/// Handle OOM by crashing.
pub inline fn oom() noreturn {
    std.debug.panic("out of memory", .{});
}
