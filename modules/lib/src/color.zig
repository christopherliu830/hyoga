const builtin = @import("builtin");

pub const Color = struct {
    data: [4]f32,

    pub inline fn hsv(h: f32, s: f32, v: f32) Color {
        return .{ .data = .{ h, s, v, 1 } };
    }

    pub inline fn hsva(h: f32, s: f32, v: f32, a: f32) Color {
        return .{ .data = .{ h, s, v, a } };
    }

    pub inline fn hue(self: *const Color) f32 {
        return self.data[0];
    }

    pub inline fn hueSet(self: *const Color, h: f32) Color {
        const clipped_h = @mod(h, 360);
        return .{ .data = .{ clipped_h, self.data[1], self.data[2], self.data[3] } };
    }

    pub inline fn saturation(self: *const Color) f32 {
        return self.data[1];
    }

    pub inline fn saturationSet(self: *const Color, s: f32) Color {
        return .{ .data = .{ self.data[0], @max(0, @min(1, s)), self.data[2], self.data[3] } };
    }

    pub inline fn value(self: *const Color) f32 {
        return self.data[2];
    }

    pub fn valueSet(self: *const Color, v: f32) Color {
        return .{ .data = .{ self.data[0], self.data[1], @max(0, @min(1, v)), self.data[3] } };
    }

    pub inline fn tint(self: *const Color, t: f32) Color {
        return self.valueSet(self.value() + t);
    }

    pub inline fn alpha(self: *const Color) f32 {
        return self.data[3];
    }

    pub inline fn alphaSet(self: *const Color, a: f32) Color {
        return .{ .data = .{ self.data[0], self.data[1], self.data[2], @max(0, @min(1, a)) } };
    }

    pub fn asu8x4(self: Color) [4]u8 {
        const c_f32: f32 = self.saturation() * self.value();
        const x_f32: f32 = c_f32 * (1 - @abs(@mod((self.hue() / 60.0), 2) - 1));
        const m_f32: f32 = self.value() - c_f32;
        const c_m: u8 = @intFromFloat(@min(255, (c_f32 + m_f32) * 255));
        const x_m: u8 = @intFromFloat(@min(255, (x_f32 + m_f32) * 255));
        const m: u8 = @intFromFloat(@min(255, (m_f32 * 255)));
        const a: u8 = @intFromFloat(@min(255, self.data[3] * 255));
        const rgba: [4]u8 = switch (@as(u32, @intFromFloat(self.hue())) % 360) {
            0...59 => .{ c_m, x_m, m, a },
            60...119 => .{ x_m, c_m, m, a },
            120...179 => .{ m, c_m, x_m, a },
            180...239 => .{ m, x_m, c_m, a },
            240...299 => .{ x_m, m, c_m, a },
            300...360 => .{ c_m, m, x_m, a },
            else => unreachable,
        };
        return rgba;
    }

    pub fn asf32x4(self: *const Color) [4]f32 {
        const values: [4]u8 = self.asu8x4();
        return .{
            @as(f32, @floatFromInt(values[0])),
            @as(f32, @floatFromInt(values[1])),
            @as(f32, @floatFromInt(values[2])),
            @as(f32, @floatFromInt(values[3])),
        };
    }

    pub fn hex(val: u24) Color {
        return .hexa((@as(u32, @intCast(val)) << 8) | 0xff);
    }

    pub fn hexa(rgba: u32) Color {
        const components: @Vector(4, f32) = blk: {
            const values: [4]u8 = @bitCast(rgba);
            if (builtin.cpu.arch.endian() == .little) {
                break :blk .{
                    @as(f32, @floatFromInt(values[3])) / 255,
                    @as(f32, @floatFromInt(values[2])) / 255,
                    @as(f32, @floatFromInt(values[1])) / 255,
                    @as(f32, @floatFromInt(values[0])) / 255,
                };
            } else {
                break :blk .{
                    @as(f32, @floatFromInt(values[0])) / 255,
                    @as(f32, @floatFromInt(values[1])) / 255,
                    @as(f32, @floatFromInt(values[2])) / 255,
                    @as(f32, @floatFromInt(values[3])) / 255,
                };
            }
        };

        const r = components[0];
        const g = components[1];
        const b = components[2];
        const a = components[3];

        const max = @reduce(.Max, @Vector(3, f32){ r, g, b });
        const min = @reduce(.Min, @Vector(3, f32){ r, g, b });
        const delta = max - min;

        const h = blk: {
            if (delta == 0) {
                break :blk 0;
            }
            if (max == components[0]) {
                break :blk 60 * @mod((g - b) / delta, 6);
            } else if (max == components[1]) {
                break :blk 60 * (((b - r) / delta) + 2);
            } else {
                break :blk 60 * (((r - g) / delta) + 4);
            }
        };

        const s = if (max == 0) 0 else delta / max;

        const v = max;

        return .{ .data = .{ h, s, v, a } };
    }
};
