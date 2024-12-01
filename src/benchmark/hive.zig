const std = @import("std");
const hy = @import("hyoga");


pub const Benchmark = struct {
    seed: *u64,

    pub fn run(self: Benchmark, allocator: std.mem.Allocator) void {
        doBenchHive(self, allocator) catch std.debug.panic("Error running benchmark!", .{});
    }

    fn doBenchHive(self: Benchmark, allocator: std.mem.Allocator) !void {
        const count = 1024 * 8;
        var hive = try hy.Hive(u128).create(allocator, .{});
        const values = try allocator.alloc(hy.Hive(u128).Cursor, count);
        var num_values: usize = 0;

        var prng = std.Random.DefaultPrng.init(self.seed.*);
        const rand = prng.random();
        self.seed.* += 1;

        for(0..1024) |n| {
            const branch = rand.intRangeLessThan(usize, 0, 100);
            if (num_values == 0 or (branch < 90 and num_values < count)) { // Add
                values[num_values] = try hive.insert(n * 1) ;
                num_values += 1;
            } else { // Remove
                const index = rand.intRangeLessThan(usize, 0, num_values);
                hive.remove(values[index]);
                num_values -= 1;
                values[index] = values[num_values];
            }

            var it = hive.iterator();
            while (it.next()) |i| { 
                _ = i; 
            }
        }

    }
};
