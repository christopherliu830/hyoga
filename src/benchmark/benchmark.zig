const std = @import("std");
const zbench = @import("zbench");

const HiveBenchmark= @import("hive.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = gpa.allocator();
    const stdout = std.io.getStdOut().writer();
    var bench = zbench.Benchmark.init(allocator, .{});
    defer bench.deinit();

    const normal = try HiveBenchmark.HiveBenchmark(u128, .{
        .inserts = 1024 * 8,
        .deletes = 1024,
        .seed = 0,
    }).create(allocator);

    const small_type= try HiveBenchmark.HiveBenchmark(u8, .{
        .inserts = 1024 * 8,
        .deletes = 1024,
        .seed = 1,
    }).create(allocator);

    const big_type= try HiveBenchmark.HiveBenchmark(u1024, .{
        .inserts = 1024 * 8,
        .deletes = 1024,
        .seed = 2,
    }).create(allocator);

    const block_8 = try HiveBenchmark.HiveBenchmark(u128, .{
        .inserts = 1024 * 8,
        .deletes = 1024,
        .seed = 3,
        .initial_block_capacity = 8,
    }).create(allocator);

    const sparse = try HiveBenchmark.HiveBenchmark(u128, .{
        .inserts = 1024 * 8,
        .deletes = (1024 * 8) - 16,
        .seed = 4,
        .initial_block_capacity = 8,
    }).create(allocator);

    try bench.addParam("Hive - Normal", &normal, .{});
    try bench.addParam("Hive - u8 Size", &small_type, .{});
    try bench.addParam("Hive - u1024 Size", &big_type, .{});
    try bench.addParam("Hive - block size 8", &block_8, .{});
    try bench.addParam("Hive - sparse array", &sparse, .{});
    try stdout.writeAll("\n");
    try bench.run(stdout);
}