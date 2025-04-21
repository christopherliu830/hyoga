const std = @import("std");

const EntryType = enum {
    empty,
    occupied,
};

const FreeSlot = struct {
    generation: u32,
    next: ?u32,
};

fn Entry(comptime T: type) type {
    return struct {
        generation: u32,
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

pub fn SlotMap(comptime T: type) type {
    return struct {
        end: u32,
        entries: std.ArrayListUnmanaged(SlotMap(T).Slot),
        free_list: ?u32,
        num_items: u32,

        pub const empty: SlotMap(T) = .{
            .end = 0,
            .entries = .{},
            .free_list = null,
            .num_items = 0,
        };

        pub const Slot = union(EntryType) { empty: FreeSlot, occupied: Entry(T) };

        pub const ValidItemsIterator = struct {
            slot_map: *SlotMap(T),
            next_index: u32 = 0,

            pub inline fn index(self: *ValidItemsIterator) u32 {
                return self.next_index - 1;
            }

            pub inline fn handle(self: *ValidItemsIterator) SlotMap(T).Handle {
                return self.slot_map.handle_at(self.index());
            }

            pub fn nextPtr(self: *ValidItemsIterator) ?*T {
                const i = self.next_index;
                if (i < 0 or i >= self.slot_map.end) return null;

                while (self.next_index < self.slot_map.end) {
                    switch (self.slot_map.slots()[self.next_index]) {
                        .occupied => |*val| {
                            self.next_index += 1;
                            return &val.value;
                        },
                        .empty => {
                            self.next_index += 1;
                        },
                    }
                }

                return null;
            }

            pub fn next(self: *ValidItemsIterator) ?T {
                const i = self.next_index;
                if (i < 0 or i >= self.slot_map.end) return null;

                while (self.next_index < self.slot_map.end) {
                    const slot = self.slot_map.entries.items[self.next_index];
                    switch (slot) {
                        .occupied => |val| {
                            self.next_index += 1;
                            return val.value;
                        },
                        .empty => {
                            self.next_index += 1;
                        },
                    }
                }

                return null;
            }
        };

        pub const Handle = extern struct {
            generation: u32 = 0,
            index: u32 = 0,

            pub const invalid = SlotMap(T).Handle{ .generation = 0, .index = 0 };

            pub fn is_valid(self: SlotMap(T).Handle) bool {
                return self.generation != 0;
            }

            pub inline fn eql(self: *const SlotMap(T).Handle, other: SlotMap(T).Handle) bool {
                return self.index == other.index and self.generation == other.generation;
            }

            pub inline fn toStr(self: SlotMap(T).Handle) [:0]const u8 {
                var buf: [32:0]u8 = undefined;
                const slice = std.fmt.bufPrintZ(&buf, "[{}/{}]", .{ self.index, self.generation }) catch unreachable;
                return slice;
            }
        };

        pub fn deinit(self: *SlotMap(T), allocator: std.mem.Allocator) void {
            self.entries.clearAndFree(allocator);
            self.* = .empty;
        }

        pub fn clear(self: *SlotMap(T)) void {
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

        pub fn capacity(self: *SlotMap(T)) u32 {
            return @intCast(self.entries.capacity);
        }

        pub fn get(self: *SlotMap(T), handle: SlotMap(T).Handle) ?T {
            const idx = handle.index;

            std.debug.assert(idx < self.end);

            return switch (self.entries.items[idx]) {
                .empty => null,
                .occupied => |val| blk: {
                    if (val.generation > handle.generation) break :blk null;
                    break :blk val.value;
                },
            };
        }

        pub fn getPtr(self: *SlotMap(T), handle: SlotMap(T).Handle) ?*T {
            const idx = handle.index;

            std.debug.assert(idx < self.end);

            return switch (self.entries.items[idx]) {
                .empty => null,
                .occupied => |*val| blk: {
                    if (val.generation > handle.generation) break :blk null;
                    break :blk &val.value;
                },
            };
        }

        pub fn at(self: *SlotMap(T), idx: u32) ?*T {
            std.debug.assert(idx < self.end);
            return switch (self.entries.items[idx]) {
                .empty => null,
                .occupied => |val| val.value,
            };
        }

        pub fn handle_at(self: *const SlotMap(T), idx: u32) SlotMap(T).Handle {
            return switch (self.entries.items[idx]) {
                .empty => std.debug.panic("handle_at used on an empty slot", .{}),
                .occupied => |val| .{ .index = idx, .generation = val.generation },
            };
        }

        pub fn iterator(self: *SlotMap(T)) ValidItemsIterator {
            return .{
                .slot_map = self,
                .next_index = 0,
            };
        }

        pub fn slots(self: *const SlotMap(T)) []SlotMap(T).Slot {
            return self.entries.items;
        }

        /// Caller is responsible for freeing the returned slice.
        pub fn toSlice(self: *SlotMap(T), allocator: std.mem.Allocator) ![]T {
            var items = try allocator.alloc(T, self.end);
            var it = self.iterator();
            var i: u32 = 0;
            while (it.next()) |item| : (i += 1) {
                items[i] = item;
            }
            return items;
        }

        pub fn insert(self: *SlotMap(T), allocator: std.mem.Allocator, value: T) !SlotMap(T).Handle {
            if (self.free_list != null) {
                const idx = self.free_list.?;
                const slot = &self.entries.items[idx];
                const gen = slot.empty.generation;

                self.free_list = slot.empty.next;
                slot.* = .{ .occupied = .{ .generation = gen, .value = value } };
                self.num_items += 1;

                return .{ .index = idx, .generation = gen };
            } else {
                const index = self.end;
                if (index >= self.capacity()) {
                    const new_cap = @max(self.capacity() * 2, 1);
                    try self.resize(allocator, new_cap);
                    return self.insert(allocator, value);
                }

                try self.entries.insert(allocator, index, .{ .occupied = .{
                    .generation = 1,
                    .value = value,
                } });

                self.end += 1;
                self.num_items += 1;

                return .{
                    .index = index,
                    .generation = 1,
                };
            }
        }

        pub fn remove(self: *SlotMap(T), handle: SlotMap(T).Handle) void {
            const idx = handle.index;
            if (idx >= self.end) return;
            const slot = &self.entries.items[idx];
            const val: ?T = switch (self.entries.items[idx]) {
                .empty => null,
                .occupied => |entry| blk: {
                    slot.* = .{ .empty = .{
                        .generation = entry.generation + 1,
                        .next = self.free_list,
                    } };
                    self.free_list = idx;
                    break :blk entry.value;
                },
            };
            if (val != null) {
                self.num_items -= 1;
                return;
            }
        }

        pub fn resize(self: *SlotMap(T), allocator: std.mem.Allocator, new_cap: u32) !void {
            if (new_cap > std.math.maxInt(u32)) return error.OutOfMemory;
            try self.entries.ensureTotalCapacity(allocator, new_cap);
        }
    };
}

test "slotmap create and deinit" {
    var g: SlotMap(u32) = .{};
    defer g.deinit(std.desting.allocator);
    try std.testing.expect(g.entries.capacity == 20);
}

test "slotmap insertions" {
    var g: SlotMap(u32) = .{};
    defer g.deinit();
    try std.testing.expectError(error.OutOfRange, g.get(.{ .index = 0, .generation = 0 }));
    const id = try g.insert(std.testing.allocator, 37);
    const id2 = try g.insert(std.testing.allocator, 42);
    try std.testing.expect(try g.get(id) == 37);
    try std.testing.expect(try g.get(id2) == 42);
}

test "slotmap invalidations" {
    var g: SlotMap(u32) = .{};
    defer g.deinit();
    const id = try g.insert(std.testing.allocator, 37);
    try std.testing.expect(try g.get(id) == 37);
    const val = g.remove(id);
    try std.testing.expect(val == 37);
    try std.testing.expectError(error.Invalidated, g.get(id));

    const new_id = try g.insert(std.testing.allocator, 24);
    try std.testing.expect(try g.get(new_id) == 24);
    try std.testing.expectError(error.Invalidated, g.get(id));
    try std.testing.expect(id.index == new_id.index);
}
