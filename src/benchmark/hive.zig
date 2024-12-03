const std = @import("std");
const hy = @import("hyoga");

pub const BenchmarkOptions = struct {
    inserts: u32 = 1024 * 4,
    deletes: u32 = 1024,
    initial_block_capacity: u32 = 8,
    seed: ?u64 = 0,
    loops: u32 = 100,
    edits_per_loop: u32 = 32, 
    pregenerate: bool = true,
};

pub fn HiveBenchmark (comptime T: type, options: BenchmarkOptions) type {
    return struct {
        hive: ?*hy.Hive(T) = null,
        loops: usize = 0,

        pub fn run(self: @This(), allocator: std.mem.Allocator) void {
            self.runWithError(allocator) catch {
                std.log.err("Error running hive benchmark", .{});
            };
        }

        pub fn create(allocator: std.mem.Allocator) !@This() {
            var self = @This() {
                .loops = options.loops
            };
            self.hive = try allocator.create(hy.Hive(T));

            var hive = self.hive.?;

            hive.* = try hy.Hive(T).create(allocator, .{ 
                .initial_block_capacity = options.initial_block_capacity,
            });

            var prng = std.Random.DefaultPrng.init(options.seed orelse 0);
            var rand = prng.random();

            const values = try allocator.alloc(hy.Hive(T).Cursor, options.inserts); 

            // Seed with values
            for (0..options.inserts)  |i| {
                const rem = @min(std.math.maxInt(T), std.math.maxInt(usize));
                values[i] = try hive.insert(@intCast(i % rem));
            }

            // Deletes
            for (0..options.deletes) |i| {
                const max = options.inserts - i;
                const random_idx= rand.intRangeLessThan(usize, 0, max);
                hive.remove(values[random_idx]);
                values[random_idx] = values[max - 1];
            }

            return self;
        }

        pub fn runWithError(self: @This(), allocator: std.mem.Allocator) !void {
            _ = allocator;
            var hive = self.hive.?;
            for(0..self.loops) |_| {
                var it = hive.iterator();
                while (it.next()) |_| {}
            }
        }
    };
}
