const builtin = @import("builtin");

pub const Color = struct {
    value: u32,

    pub fn hex(value: u24) Color {
        return .{ .value = (@as(u32, @intCast(value)) << 8) | 0xff };
    }

    pub fn hexa(value: u32) Color {
        return .{ .value = value };
    }

    pub fn asf32x4(self: *const Color) [4]f32 {
        const values: [4]u8 = @bitCast(self.value);
        if (builtin.cpu.arch.endian() == .little) {
            return .{
                @as(f32, @floatFromInt(values[3])),
                @as(f32, @floatFromInt(values[2])),
                @as(f32, @floatFromInt(values[1])),
                @as(f32, @floatFromInt(values[0])),
            };
        } else {
            return .{
                @as(f32, @floatFromInt(values[0])),
                @as(f32, @floatFromInt(values[1])),
                @as(f32, @floatFromInt(values[2])),
                @as(f32, @floatFromInt(values[3])),
            };
        }
    }
};
