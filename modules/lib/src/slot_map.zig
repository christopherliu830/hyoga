const std = @import("std");

const EntryType = enum {
    empty,
    occupied,
};

fn Entry(Guard: type, comptime T: type) type {
    return struct {
        generation: Guard,
        value: T,
    };
}

// Helper type to get the handle for an arena.
pub fn Handle(comptime T: type) type {
    return SlotMap(T).Handle;
}

pub fn Slot(comptime T: type) type {
    return SlotMap(T).Slot;
}

pub fn SlotMap(T: type) type {
    return SlotMapSized(u32, u32, T);
}

pub fn SlotMapSized(Guard: type, Size: type, comptime T: type) type {
    return struct {
        const Self = @This();
        end: Size,
        entries: std.ArrayListUnmanaged(Self.Slot),
        free_list: ?Size,
        live_list: std.DynamicBitSetUnmanaged,
        num_items: Size,

        pub const empty: Self = .{
            .end = 0,
            .entries = .{},
            .free_list = null,
            .live_list = .{},
            .num_items = 0,
        };

        pub const Slot = struct {
            generation: Guard,
            elem: Elem,

            const Elem = union {
                next: Size,
                value: T,
            };
        };

        pub const ValidItemsIterator = struct {
            live_iterator: std.DynamicBitSetUnmanaged.Iterator(.{}),
            slot_map: *Self,
            last_index: Size = std.math.maxInt(Size),

            pub inline fn index(self: *ValidItemsIterator) Size {
                return self.last_index;
            }

            pub inline fn handle(self: *ValidItemsIterator) Self.Handle {
                return self.slot_map.handle_at(self.index());
            }

            pub fn nextPtr(self: *ValidItemsIterator) ?*T {
                if (self.live_iterator.next()) |slot_index| {
                    const slot = &self.slot_map.entries.items[slot_index];
                    self.last_index = @intCast(slot_index);
                    return &slot.elem.value;
                }
                return null;
            }

            pub fn next(self: *ValidItemsIterator) ?T {
                if (self.live_iterator.next()) |slot_index| {
                    const slot = self.slot_map.entries.items[slot_index];
                    self.last_index = @intCast(slot_index);
                    return slot.elem.value;
                }
                return null;
            }
        };

        pub const Handle = extern struct {
            generation: Guard = 0,
            index: Size = 0,

            pub const invalid: Self.Handle = .{ .generation = 0, .index = 0 };
            pub const none: Self.Handle = .{ .generation = 0, .index = 0 };

            pub fn valid(self: Self.Handle) bool {
                return self.generation != 0;
            }

            pub inline fn eql(self: *const Self.Handle, other: Self.Handle) bool {
                return self.index == other.index and self.generation == other.generation;
            }

            pub fn order(self: Self.Handle, rhs: Self.Handle) std.math.Order {
                const ord = std.math.order(self.index, rhs.index);
                if (ord == .eq) return std.math.order(self.generation, rhs.generation);
                return ord;
            }

            pub inline fn toStr(self: Self.Handle) [:0]const u8 {
                var buf: [32:0]u8 = undefined;
                const slice = std.fmt.bufPrintZ(&buf, "[{}/{}]", .{ self.index, self.generation }) catch unreachable;
                return slice;
            }
        };

        pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
            self.live_list.deinit(allocator);
            self.entries.clearAndFree(allocator);
            self.* = .empty;
        }

        pub fn clear(self: *Self) void {
            for (self.slots(), 0..) |slot, i| {
                switch (slot) {
                    .occupied => {
                        const hdl = self.handle_at(@intCast(i));
                        self.remove(hdl);
                    },
                    .empty => continue,
                }
            }
        }

        pub fn capacity(self: *Self) Size {
            return @intCast(self.entries.capacity);
        }

        pub fn get(self: *Self, handle: Self.Handle) ?T {
            const idx = handle.index;

            std.debug.assert(idx < self.end);

            const slot = &self.entries.items[idx];
            if (self.live_list.isSet(idx)) {
                if (slot.generation > handle.generation) {
                    return null;
                } else {
                    return slot.elem.value;
                }
            }
            return null;
        }

        pub fn getPtr(self: *Self, handle: Self.Handle) ?*T {
            const idx = handle.index;

            std.debug.assert(idx < self.end);

            const slot = &self.entries.items[idx];
            if (self.live_list.isSet(idx)) {
                if (slot.generation > handle.generation) {
                    return null;
                } else {
                    return &slot.elem.value;
                }
            }
            return null;
        }

        pub fn at(self: *Self, idx: Size) ?*T {
            std.debug.assert(idx < self.end);
            if (self.live_list.isSet(idx)) {
                return &self.entries.items[idx].elem.value;
            } else {
                return null;
            }
        }

        pub fn handle_at(self: *const Self, idx: Size) Self.Handle {
            if (self.live_list.isSet(idx)) {
                return .{ .index = idx, .generation = self.entries.items[idx].generation };
            } else {
                std.debug.panic("handle_at used on an empty slot", .{});
            }
        }

        pub fn iterator(self: *Self) ValidItemsIterator {
            return .{
                .slot_map = self,
                .live_iterator = self.live_list.iterator(.{}),
            };
        }

        pub fn slots(self: *const Self) []Self.Slot {
            return self.entries.items;
        }

        /// Caller is responsible for freeing the returned slice.
        pub fn toSlice(self: *Self, allocator: std.mem.Allocator) ![]T {
            var items = try allocator.alloc(T, self.end);
            var it = self.iterator();
            var i: Size = 0;
            while (it.next()) |item| : (i += 1) {
                items[i] = item;
            }
            return items;
        }

        pub fn insert(self: *Self, allocator: std.mem.Allocator, value: T) !Self.Handle {
            if (self.free_list != null) {
                const idx = self.free_list.?;
                const slot = &self.entries.items[idx];
                const gen = slot.generation;

                if (slot.elem.next != std.math.maxInt(Size)) {
                    self.free_list = slot.elem.next;
                } else {
                    self.free_list = null;
                }

                slot.elem = .{ .value = value };
                self.num_items += 1;
                self.live_list.set(idx);

                return .{ .index = idx, .generation = gen };
            } else {
                const index: Size = self.end - 0;
                if (index >= self.capacity()) {
                    const new_cap = @max(self.capacity() * 2, 1);
                    try self.resize(allocator, new_cap);
                    try self.live_list.resize(allocator, self.capacity(), false);
                }

                self.entries.items.len += 1;
                self.entries.items[index] = .{
                    .generation = 1,
                    .elem = .{ .value = value },
                };

                self.live_list.set(index);
                self.end += 1;
                self.num_items += 1;

                return .{
                    .index = index,
                    .generation = 1,
                };
            }
        }

        pub fn remove(self: *Self, handle: Self.Handle) void {
            const idx = handle.index;
            if (idx >= self.end) {
                std.debug.panic("slot_map.remove called with handle {} when no element exists", .{handle});
            }
            if (!self.live_list.isSet(idx)) {
                return;
            }

            self.live_list.unset(idx);

            const slot = &self.entries.items[idx];
            slot.generation += 1;

            if (self.free_list) |free_idx| {
                slot.elem = .{ .next = free_idx };
            } else {
                slot.elem = .{ .next = std.math.maxInt(u32) };
            }

            self.free_list = idx;
            self.num_items -= 1;
        }

        pub fn resize(self: *Self, allocator: std.mem.Allocator, new_cap: Size) !void {
            if (new_cap > std.math.maxInt(Size)) return error.OutOfMemory;
            try self.entries.ensureTotalCapacity(allocator, new_cap);
        }
    };
}

test "slotmap insertions" {
    var g: SlotMap(u32) = .empty;
    defer g.deinit(std.testing.allocator);
    const id = try g.insert(std.testing.allocator, 37);
    const id2 = try g.insert(std.testing.allocator, 42);
    try std.testing.expect(g.get(id).? == 37);
    try std.testing.expect(g.get(id2).? == 42);
}

test "slotmap invalidations" {
    const allocator = std.testing.allocator;
    var g: SlotMap(u32) = .empty;
    defer g.deinit(allocator);
    const id = try g.insert(allocator, 37);
    try std.testing.expectEqual(g.get(id).?, 37);
    g.remove(id);
    try std.testing.expectEqual(g.get(id), null);

    const new_id = try g.insert(allocator, 24);
    try std.testing.expectEqual(g.get(new_id).?, 24);
    g.remove(new_id);
    try std.testing.expectEqual(g.get(id), null);
    try std.testing.expect(id.index == new_id.index);
}
