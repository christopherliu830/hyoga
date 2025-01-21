const std = @import("std");

pub fn CircleQueue(length: usize, T: type) type {
    return struct {
        const Self = @This();
        tail: usize = 0,
        head: usize = 0,
        items: [length]T,

        pub fn push(self: *Self, item: T) void {
            self.items[self.head] = item;
            self.head = (self.head + 1) % length;
            if (self.head == self.tail) {
                _ = pop(self);
            }
        }

        pub fn pop(self: *Self) T {
            const item = self.items[self.tail];
            self.tail = (self.tail + 1) % length;
            return item;
        }

        pub fn len(self: *const Self) usize {
            return if (self.head < self.tail)
                length + self.head - self.tail
            else
                self.head - self.tail;
        }

        pub fn orderedItems(self: *const Self) [length]T {
            var arranged: [length]T = undefined;
            var i: usize = 0;
            if (self.head < self.tail) {
                for (self.items[self.tail..length]) |val| {
                    arranged[i] = val;
                    i += 1;
                }
                for (self.items[0..self.head]) |val| {
                    arranged[i] = val;
                    i += 1;
                }
            } else {
                for (self.items[self.tail..self.head]) |val| {
                    arranged[i] = val;
                    i += 1;
                }
            }
            return arranged;
        }
    };
}
