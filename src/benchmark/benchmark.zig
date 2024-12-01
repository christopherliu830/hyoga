const std = @import("std");
const zbench = @import("zbench");

const Hive = @import("hive.zig").Benchmark;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = gpa.allocator();
    const stdout = std.io.getStdOut().writer();
    var bench = zbench.Benchmark.init(allocator, .{});
    defer bench.deinit();

    const hive = Hive { .seed = try allocator.create(u64) };

    var a = hive;
    a = try a.generate(allocator);
    a.iters = 1;

    const single = a;

    try bench.addParam("Hive - Random", &hive, .{ .iterations = 1024 });
    try bench.addParam("Hive - One loop time", &single , .{ });
    try stdout.writeAll("\n");
    try bench.run(stdout);
}