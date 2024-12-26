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

pub fn SlotMap(comptime T: type) type {
    const Slot = union(EntryType) { empty: FreeSlot, occupied: Entry(T) };

    return struct {
        pub const ValidItemsIterator = struct {
            arena: *SlotMap(T),
            next_index: u32 = 0,

            pub inline fn index(self: *ValidItemsIterator) u32 {
                return self.next_index - 1;
            }
            
            pub fn nextPtr(self: *ValidItemsIterator) ?*T {
                const i = self.next_index;
                if (i < 0 or i >= self.arena.len) return null;

                while (self.next_index < self.arena.len) {
                    var slot = self.arena.entries.items[self.next_index];
                    switch(slot) {
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
                if (i < 0 or i >= self.arena.len) return null;

                while (self.next_index < self.arena.len) {
                    const slot = self.arena.entries.items[self.next_index];
                    switch(slot) {
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

            pub const invalid = SlotMap(T).Handle { .generation = 0, .index = 0 };

            pub fn is_valid(self: SlotMap(T).Handle) bool { return self.generation != 0; }
        };

        len: u32,
        entries: std.ArrayList(Slot),
        free_list: ?u32,
        num_items: u32,

        pub fn create(allocator: std.mem.Allocator, size: u32) !SlotMap(T) {
            return SlotMap(T){
                .len = 0,
                .entries = try std.ArrayList(Slot).initCapacity(allocator, size),
                .free_list = null,
                .num_items = 0,
            };
        }

        pub fn deinit(self: *SlotMap(T)) void {
            self.entries.clearAndFree();
        }

        pub fn capacity(self: SlotMap(T)) u32 {
            return @intCast(self.entries.capacity);
        }

        pub fn get(self: SlotMap(T), handle: SlotMap(T).Handle) !T {
            const idx = handle.index;
            if (idx >= self.len) return error.OutOfRange;
            return switch (self.entries.items[idx]) {
                .empty => error.Invalidated,
                .occupied => |val| blk: {
                    if (val.generation > handle.generation) break :blk error.Invalidated;
                    break :blk val.value;
                },
            };
        }

        pub fn getPtr(self: SlotMap(T), handle: SlotMap(T).Handle) !*T {
            const idx = handle.index;
            if (idx >= self.len) return error.OutOfRange;
            return switch (self.entries.items[idx]) {
                .empty => error.Invalidated,
                .occupied => |*val| blk: {
                    if (val.generation > handle.generation) break :blk error.Invalidated;
                    break :blk &val.value;
                },
            };
            
        }

        pub fn at(self: SlotMap(T), idx: u32) !*T {
            if (idx >= self.len) return error.OutOfRange;
            return switch (self.entries.items[idx]) {
                .empty => error.Invalidated,
                .occupied => |val| val.value,
            };
        }

        pub fn handle_at(self: SlotMap(T), idx: u32) !SlotMap(T).Handle {
            return switch (self.entries.items[idx]) {
                .empty => error.Invalidated,
                .occupied => |val| .{ .index = idx, .generation = val.generation },
            };
        }

        pub fn iterator(self: *SlotMap(T)) ValidItemsIterator {
            return ValidItemsIterator {
                .arena = self,
                .next_index = 0,
            };
        }

        /// Caller is responsible for freeing the returned slice.
        pub fn toSlice(self: *SlotMap(T), allocator: std.mem.Allocator) ![]T {
            var items = try allocator.alloc(T, self.len);
            var it = self.iterator();
            var i: u32 = 0;
            while (it.next()) |item|: (i += 1) {
                items[i] = item;
            } 
            return items;
        }

        pub fn insert(self: *SlotMap(T), value: T) !SlotMap(T).Handle {
            if (self.free_list != null) {
                const idx = self.free_list.?;
                const slot = &self.entries.items[idx];
                const gen = slot.empty.generation;

                self.free_list = slot.empty.next;
                slot.* = .{ .occupied = .{ .generation = gen, .value = value } };
                self.num_items += 1;

                return .{ .index = idx, .generation = gen };
            } else {
                const index = self.len;
                if (index >= self.capacity()) {
                    const new_cap = @max(self.capacity() * 2, 1);
                    try self.resize(new_cap);
                    return self.insert(value);
                }

                try self.entries.insert(index, .{ .occupied = .{
                    .generation = 1,
                    .value = value,
                } });

                self.len += 1;
                self.num_items += 1;

                return .{
                    .index = index,
                    .generation = 1,
                };
            }
        }

        pub fn remove(self: *SlotMap(T), handle: SlotMap(T).Handle) void {
            const idx = handle.index;
            if (idx >= self.len) return;
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

        pub fn resize(self: *SlotMap(T), new_cap: u32) !void {
            if (new_cap > std.math.maxInt(u32)) return error.OutOfMemory;
            try self.entries.ensureTotalCapacity(new_cap);
        }
    };
}

test "slotmap create and deinit" {
    var g = try SlotMap(u32).create(std.testing.allocator, 20);
    defer g.deinit();
    try std.testing.expect(g.entries.capacity == 20);
}

test "slotmap insertions" {
    var g = try SlotMap(u32).create(std.testing.allocator, 20);
    defer g.deinit();
    try std.testing.expectError(error.OutOfRange, g.get(.{ .index = 0, .generation = 0 }));
    const id = try g.insert(37);
    const id2 = try g.insert(42);
    try std.testing.expect(try g.get(id) == 37);
    try std.testing.expect(try g.get(id2) == 42);
}

test "slotmap invalidations" {
    var g = try SlotMap(u32).create(std.testing.allocator, 20);
    defer g.deinit();
    const id = try g.insert(37);
    try std.testing.expect(try g.get(id) == 37);
    const val = g.remove(id);
    try std.testing.expect(val == 37);
    try std.testing.expectError(error.Invalidated, g.get(id));

    const new_id = try g.insert(24);
    try std.testing.expect(try g.get(new_id) == 24);
    try std.testing.expectError(error.Invalidated, g.get(id));
    try std.testing.expect(id.index == new_id.index);
}
