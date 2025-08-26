const std = @import("std");

const Vec2 = @import("math/vec2.zig").Vec2;

pub fn EventQueue(T: type) type {
    return struct {
        array: std.ArrayList(T),

        pub const empty: EventQueue(T) = .{ .array = .empty };

        pub fn pump(self: *EventQueue(T), buffer: []u8) u32 {
            const buffer_elem_count = buffer.len / @sizeOf(T);
            const source_elem_count = self.array.items.len;
            const elem_count = @min(buffer_elem_count, source_elem_count);
            @memcpy(buffer[0 .. elem_count * @sizeOf(T)], std.mem.sliceAsBytes(self.array.items[0..elem_count]));
            self.array.replaceRangeAssumeCapacity(0, elem_count, &.{});
            return @intCast(elem_count * @sizeOf(T));
        }
    };
}

pub const MouseMotion = struct {
    position: Vec2,
    delta: Vec2,
};

pub const MouseWheel = struct {
    delta: f32 = 0,
};
