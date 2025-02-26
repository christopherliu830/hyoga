//! A skipmap retains the memory addresses of members as it grows
//! while maintaining a O(n) iteration time. A skipmap consists of
//! a doubly-linked list of blocks that contain an array of
//! members an associated metadata. Each new allocated block is
//! double the size of the previous block.
//! Insertions make use of a free list, both per-block as well
//! as a skipmap-wide open group list.

const std = @import("std");

const EntryType = enum {
    empty,
    occupied,
};

pub fn SkipMap(comptime T: type) type {
    const Size = blk: {
        if (@sizeOf(T) > 10 or @alignOf(T) > 10) {
            break :blk u16;
        } else {
            break :blk u8;
        }
    };

    return SkipMapSized(T, Size);
}

pub fn SkipMapSized(comptime T: type, comptime Size: type) type {
    return struct {
        const Self = @This();

        pub const Cursor = struct {
            group: *Group,
            element: *Slot,
            skip: *Skip,

            pub inline fn unwrap(self: Cursor) *T {
                if (self.skip.value != 0) std.debug.panic("unwrap of empty value", .{});
                return &self.element.data;
            }
        };

        pub const Iterator = struct {
            cursor: Cursor,
            end: *Skip,

            pub fn next(self: *Iterator) ?Cursor {
                const cursor = &self.cursor;

                if (cursor.skip == self.end) return null;

                std.debug.assert(@intFromPtr(cursor.group.skipfieldStart()) <= @intFromPtr(cursor.skip));
                std.debug.assert(@intFromPtr(cursor.skip) <= @intFromPtr(cursor.group.skipfield + cursor.group.capacity + 1));
                std.debug.assert(@intFromPtr(cursor.group.elementsStart()) <= @intFromPtr(cursor.element));
                std.debug.assert(@intFromPtr(cursor.element) <= @intFromPtr(cursor.group.elementsEnd()));

                const ret = cursor.*;

                std.debug.assert(&cursor.element.data == &cursor.element.data);

                cursor.skip = cursor.skip.right(1);
                var skiplen = cursor.skip.value;
                cursor.element = cursor.element.right(1 + skiplen);

                if (cursor.element == cursor.group.elementsEnd()) {
                    if (cursor.group.next_group) |next_group| {
                        cursor.group = next_group;
                        const len = next_group.skipfieldStart().value;
                        cursor.element = next_group.elementsStart().right(len);
                        cursor.skip = next_group.skipfieldStart().right(len);

                        skiplen = 0;
                    }
                }

                cursor.skip = cursor.skip.right(skiplen);

                return ret;
            }
        };

        const Stride = std.meta.Int(.unsigned, @alignOf(T) * 8);

        const Skip = struct {
            value: Size,

            inline fn right(self: *Skip, count: usize) *Skip {
                const ptr: [*]Skip = @ptrCast(self);
                return @ptrCast(ptr + count);
            }

            // Pointer subtraction only works with usize, so an
            // additional function definition is needed here.
            inline fn left(self: *Skip, count: usize) *Skip {
                const ptr: [*]Skip = @ptrCast(self);
                return @ptrCast(ptr - count);
            }
        };

        const SlotIndex = enum(Size) {
            none = std.math.maxInt(Size),
            // Index to the last erased element in the group.
            _,

            inline fn unwrap(i: @This()) ?Size {
                return switch (i) {
                    .none => return null,
                    else => @intFromEnum(i),
                };
            }
        };

        const FreeListNode = struct {
            next: SlotIndex,
            prev: SlotIndex,
        };

        const Slot = union {
            data: T,
            free_node: FreeListNode,

            inline fn right(self: *Slot, count: usize) *Slot {
                const ptr: [*]Slot = @ptrCast(self);
                return @ptrCast(ptr + count);
            }

            // Pointer subtraction only works with usize, so an
            // additional function definition is needed here.
            inline fn left(self: *Slot, count: usize) *Slot {
                const ptr: [*]Slot = @ptrCast(self);
                return @ptrCast(ptr - count);
            }
        };

        // group == element memory block + skipfield + block metadata
        pub const Group = struct {
            skipfield: [*]Skip, // Start of the skipfield.
            next_group: ?*Group = null,
            elements: [*]Slot, // Start of the memory block
            previous_group: ?*Group = null,
            free_list_head: SlotIndex, // Index of last erased element in the group.
            capacity: Size, // Element capacity
            size: Size = 0, // Number of active elements
            prev_open_group: ?*Group = null, // Next and previous groups that contain a non-empty free list.
            next_open_group: ?*Group = null,
            group_no: u8 = 0,

            inline fn skipfieldStart(self: *Group) *Skip {
                return @ptrCast(&self.skipfield[0]);
            }

            inline fn elementsStart(self: *Group) *Slot {
                return @ptrCast(&self.elements[0]);
            }

            inline fn elementsEnd(self: *Group) *Slot {
                return @ptrCast(@alignCast(&self.skipfield[0]));
            }

            inline fn indexOf(self: *Group, slot: *Slot) SlotIndex {
                return @enumFromInt((@intFromPtr(slot) - @intFromPtr(self.elements)) / @sizeOf(Slot));
            }

            inline fn getFree(self: *Group, node: SlotIndex) ?*FreeListNode {
                if (node.unwrap()) |index| {
                    return &self.elements[index].free_node;
                } else return null;
            }

            fn alignedSize(num_elements: Size) usize {
                // Start of skipfield must be aligned on T,
                // so allocate by block
                const capacity: usize = @intCast(num_elements);
                const raw_size = capacity * (@sizeOf(Skip) + @sizeOf(Slot)) + @sizeOf(Skip);
                const aligned_size = (raw_size + @sizeOf(Stride) - 1) / @sizeOf(Stride);
                return aligned_size;
            }

            fn init(self: *Group, capacity: Size, prev_group: ?*Group, allocator: std.mem.Allocator) !void {
                const size = Group.alignedSize(capacity);

                const data = try allocator.alignedAlloc(Stride, @alignOf(T), size);

                // Assign pointers into memory block
                const ptr_elements: [*]Slot = @ptrCast(@alignCast(data.ptr));
                const ptr_skipfield: [*]Skip = @ptrCast(ptr_elements + capacity);
                @memset(ptr_skipfield[0 .. capacity + 1], .{ .value = 0 });

                if (prev_group) |g| g.next_group = self;

                self.* = .{
                    .previous_group = prev_group,
                    .skipfield = ptr_skipfield,
                    .elements = ptr_elements,
                    .free_list_head = .none,
                    .capacity = capacity,
                    .group_no = if (prev_group) |group| group.group_no + 1 else 0,
                };
            }

            fn deinit(self: *Group, allocator: std.mem.Allocator) void {
                const ptr_data: [*]align(@alignOf(T)) Stride = @ptrCast(@alignCast(self.elements));
                const data = ptr_data[0..Group.alignedSize(self.capacity)];
                self.group_no = 0;
                allocator.free(data);
                allocator.destroy(self);
            }
        };

        // Doubly doubly linked list
        pub const GroupList = struct {
            head: ?Cursor = null,
            tail: ?Cursor = null,
            open_head: ?*Group = null,
            total_capacity: usize = 0,
            size: usize = 0, // Number of groups in the collection.

            pub fn prepend(self: *GroupList, node: *Group) void {
                if (self.head) |*head| {
                    std.debug.assert(head.group.previous_group == null);
                    node.next_group = head.group;
                    head.group.previous_group = node;
                    head.group = node;
                    head.element = node.elementsStart();
                    head.skip = node.skipfieldStart();
                    self.total_capacity += node.capacity;
                    self.size += 1;
                } else {
                    self.head = Cursor{
                        .group = node,
                        .element = node.elementsStart(),
                        .skip = node.skipfieldStart(),
                    };
                    self.tail = self.head;
                    self.size += 1;
                }
            }

            pub fn append(self: *GroupList, node: *Group) void {
                if (self.tail) |*tail| {
                    std.debug.assert(tail.element == tail.group.elementsEnd());
                    std.debug.assert(tail.group.next_group == null);

                    node.previous_group = tail.group;
                    tail.group.next_group = node;
                    self.tail = .{
                        .group = node,
                        .element = node.elementsStart(),
                        .skip = node.skipfieldStart(),
                    };
                    self.total_capacity += node.capacity;
                    self.size += 1;
                    node.group_no = tail.group.group_no + 1;
                } else self.prepend(node);
            }

            pub fn remove(self: *GroupList, node: *Group) void {
                if (self.size == 1) {
                    self.head = null;
                    self.tail = null;
                    self.open_head = null;
                    self.total_capacity = 0;
                    self.size = 0;
                    return;
                }

                self.size -= 1;

                if (node.previous_group) |prev| {
                    prev.next_group = node.next_group;
                }
                // Head node
                else {
                    std.debug.assert(self.head.?.group == node);

                    const next = node.next_group.?;
                    const skiplen = next.skipfieldStart().value;
                    self.head = .{
                        .group = next,
                        .element = next.elementsStart().right(skiplen),
                        .skip = next.skipfieldStart().right(skiplen),
                    };

                    self.total_capacity -= node.capacity;
                }

                if (node.next_group) |next| {
                    next.previous_group = node.previous_group;
                }

                // Tail node
                else {
                    std.debug.assert(self.tail.?.group == node);
                    std.debug.assert(node.previous_group != null);

                    const prev = node.previous_group.?;
                    self.tail = .{
                        .group = prev,
                        .element = prev.elementsEnd(),
                        .skip = prev.skipfieldStart().right(prev.capacity),
                    };
                }

                self.total_capacity -= node.capacity;
                std.debug.assert(self.head.?.group != node);
                std.debug.assert(self.tail.?.group != node);
            }
        };

        groups: GroupList,
        open_groups_head: ?*Group = null,
        total_capacity: usize = 0,
        len: usize = 0,
        block_capacity: Size = 8,
        max_block_capacity: Size = @min(std.math.maxInt(Size) - 1, 8192),
        allocator: std.mem.Allocator,

        pub const CreateOptions = struct {
            initial_block_capacity: Size = 32,
        };

        pub fn create(allocator: std.mem.Allocator, options: CreateOptions) !SkipMap(T) {
            const skipmap = SkipMap(T){
                .groups = .{},
                .allocator = allocator,
                .block_capacity = options.initial_block_capacity,
            };
            return skipmap;
        }

        pub fn deinit(self: *Self) void {
            if (self.groups.size > 0) {
                while (self.groups.head) |*head| {
                    const g = head.group;
                    self.groups.remove(head.group);
                    g.deinit(self.allocator);
                }
            }
        }

        pub fn iterator(self: *Self) Iterator {
            // Not initialized, return a dummy iterator
            if (self.len == 0) {
                return .{ .end = @ptrCast(@alignCast(self)), .cursor = .{
                    .group = undefined,
                    .element = undefined,
                    .skip = @ptrCast(@alignCast(self)),
                } };
            }

            return .{
                .end = self.groups.tail.?.skip,
                .cursor = self.groups.head.?,
            };
        }

        pub fn insert(self: *Self, value: T) !Cursor {
            // First element
            if (self.groups.head == null) {
                var group: *Group = undefined;
                const capacity = @min(self.block_capacity, self.max_block_capacity);
                group = try self.createGroup(null, capacity);

                self.groups.prepend(group);

                var tail = &self.groups.tail.?;
                tail.element.* = .{ .data = value };
                tail.element = tail.element.right(1);
                tail.skip = tail.skip.right(1);
                group.size += 1;
                self.len += 1;

                return self.groups.head.?;
            }

            // Insert into an open group
            else if (self.open_groups_head) |group| {
                group.size += 1;
                self.len += 1;

                const idx = group.free_list_head.unwrap().?;
                const slot = &group.elements[idx];
                const skip = &group.skipfield[idx];

                const old_free_node = slot.free_node;

                // Fix up skipblock and vacancy groups
                const skiplen = skip.value - 1;

                // This is the start of a skipbock
                if (skiplen != 0) {
                    skip.right(1).value = skiplen;
                    skip.right(skiplen).value = skiplen;
                    slot.right(1).* = .{ .free_node = old_free_node };

                    if (old_free_node.next.unwrap()) |idx_next| {
                        group.elements[idx_next].free_node.prev = @enumFromInt(idx + 1);
                    }

                    // Point free list head to new skipblock start
                    group.free_list_head = @enumFromInt(idx + 1);
                }

                // Remove free list
                else {
                    group.free_list_head = old_free_node.next;
                    if (group.free_list_head.unwrap()) |head| {
                        group.elements[head].free_node.prev = .none;
                    }
                    // No elements free, remove from vacancy list
                    else {
                        self.open_groups_head = self.open_groups_head.?.next_open_group;
                    }
                }

                slot.* = .{ .data = value };
                skip.value = 0;

                // If this group is the same as the head, we need to move
                // the head left to include the inserted element.
                if (self.groups.head) |*head| if (group == head.group) {
                    const idx_slot = group.indexOf(slot).unwrap().?;
                    const idx_head = group.indexOf(head.element).unwrap().?;
                    if (group == head.group and idx_slot < idx_head) {
                        head.* = .{
                            .element = slot,
                            .skip = skip,
                            .group = group,
                        };
                    }
                };

                return .{
                    .group = group,
                    .element = slot,
                    .skip = skip,
                };
            } else if (self.groups.tail != null and self.groups.tail.?.element != self.groups.tail.?.group.elementsEnd()) {
                const tail = &(self.groups.tail.?);
                const cursor = tail.*;
                tail.element.* = .{ .data = value };
                tail.element = tail.element.right(1);
                tail.skip = tail.skip.right(1);
                self.len += 1;
                tail.group.size += 1;
                return cursor;
            }

            // ELSE: End of group, allocate new.
            else {
                self.block_capacity = @min(@as(usize, @intCast(self.block_capacity)) * 2, self.max_block_capacity);

                const group = try self.createGroup(self.groups.tail.?.group, self.block_capacity);
                self.groups.append(group);

                var tail = &self.groups.tail.?;
                tail.element.* = .{ .data = value };
                tail.group.size += 1;
                self.total_capacity += group.capacity;
                self.len += 1;

                const cursor = tail.*;

                tail.element = tail.element.right(1);
                tail.skip = tail.skip.right(1);

                return cursor;
            }
        }

        pub fn remove(self: *Self, cursor: Cursor) void {
            std.debug.assert(self.len != 0);
            std.debug.assert(cursor.element != self.groups.tail.?.element);
            std.debug.assert(cursor.skip.value == 0);

            self.len -= 1;
            const group = cursor.group;
            group.size -= 1;

            if (group.size > 0) {
                const if_start_node_0_else_1: u1 = if (cursor.skip == group.skipfieldStart()) 0 else 1;

                const has_left_skipblock = cursor.skip.left(if_start_node_0_else_1).value != 0;
                const has_right_skipblock = cursor.skip.right(1).value != 0;

                var head_skiplen: Size = 1;

                // No consecutive erased elements, create a skipblock of len 1
                // and fix up free list.
                if (!has_left_skipblock and !has_right_skipblock) {
                    cursor.skip.value = 1;

                    const index = cursor.group.indexOf(cursor.element);

                    if (group.free_list_head.unwrap()) |head| {
                        group.elements[head].free_node.prev = index;
                    } else {
                        group.next_open_group = self.open_groups_head;

                        if (self.open_groups_head) |vacant_group| {
                            vacant_group.prev_open_group = group;
                        }

                        self.open_groups_head = group;
                    }

                    cursor.element.* = .{ .free_node = .{
                        .prev = .none,
                        .next = group.free_list_head,
                    } };

                    group.free_list_head = index;
                }

                // A skipblock on the left.
                // Increase skiplen by 1 and set current node's value and value of
                // the start node and current to the new value.
                else if (has_left_skipblock and !has_right_skipblock) {
                    const prev = cursor.skip.left(1);
                    const start = cursor.skip.left(prev.value);
                    const skiplen = prev.value + 1;

                    start.value = skiplen;
                    cursor.skip.value = skiplen;
                }

                // A skipblock on the right.
                // Increase skiplen by 1 and make this the start of the
                // skipblock (move free list information)
                else if (!has_left_skipblock and has_right_skipblock) {
                    const next_skipfield = cursor.skip.right(1);
                    const skiplen = next_skipfield.value + 1;
                    const end_skipfield = cursor.skip.right(skiplen - 1);
                    end_skipfield.value = skiplen;
                    cursor.skip.value = skiplen;

                    // Edit free list - The free list information is stored at the start of every skipblock.

                    // Move the skipfield information into the new start
                    cursor.element.* = .{ .free_node = cursor.element.right(1).free_node };

                    const index = cursor.group.indexOf(cursor.element);
                    const node_prev = cursor.element.free_node.prev.unwrap();
                    const node_next = cursor.element.free_node.next.unwrap();

                    if (node_next) |next| {
                        cursor.group.elements[next].free_node.prev = index;
                    }

                    if (node_prev) |prev| {
                        cursor.group.elements[prev].free_node.next = index;
                    } else { // Migrated node is head
                        cursor.group.free_list_head = index;
                    }

                    head_skiplen = skiplen;
                }

                // Between two skipblocks.
                // Set skiplen to (left skipblock count) + (right skipblock count) + 1
                // and delete the right block from free list. (merge with left skipblock)
                else {
                    cursor.skip.value = 1;
                    const prev = cursor.skip.left(1).value;
                    const next = cursor.skip.right(1).value;
                    const skiplen = prev + next + 1;
                    const start = cursor.skip.left(prev);
                    const end = cursor.skip.right(next);
                    start.value = skiplen;
                    end.value = skiplen;

                    const free_node = cursor.element.right(1).free_node;
                    if (free_node.next.unwrap()) |next_free| {
                        cursor.group.elements[next_free].free_node.prev = free_node.prev;
                    }

                    if (free_node.prev.unwrap()) |prev_free| {
                        cursor.group.elements[prev_free].free_node.next = free_node.next;
                    } else { // Removed node was head
                        cursor.group.free_list_head = @enumFromInt(free_node.next.unwrap().?);
                    }

                    head_skiplen = next + 1;
                }

                std.debug.assert(group.free_list_head == .none or group.elements[group.free_list_head.unwrap().?].free_node.prev == .none);

                // If head was removed, move head forward until a valid element.
                if (cursor.element == self.groups.head.?.element) {
                    self.groups.head.?.skip = cursor.skip.right(head_skiplen);
                    self.groups.head.?.element = cursor.element.right(head_skiplen);
                }
            }

            // The removed element is the last in the group.
            // The group is empty, so can be deallocated.
            else {

                // Only group left, reuse
                if (self.groups.size == 1) {
                    self.open_groups_head = null;
                    self.groups.tail.?.group = group;
                    self.groups.tail.?.element = group.elementsStart();
                    self.groups.tail.?.skip = group.skipfieldStart();

                    self.groups.head = self.groups.tail.?;

                    @memset(group.skipfield[0..group.capacity], .{ .value = 0 });
                    group.free_list_head = .none;
                    group.size = 0;
                    group.previous_group = null;
                    group.next_group = null;
                    group.next_open_group = null;
                    group.prev_open_group = null;
                    group.group_no = 0;
                } else {
                    self.groups.remove(group);

                    // Remove from vacancies
                    // Needs check here in case of new group -> one element added -> removed
                    if (group.free_list_head != .none) {
                        self.closeGroup(group);
                    }

                    self.total_capacity -= group.capacity;
                    group.deinit(self.allocator);
                }
            }
        }

        pub fn find(self: *Self, element: *T) ?Cursor {
            // Not initialized
            if (self.groups.tail == null) return null;

            // Iterate backwards since the tail groups are the biggest in size
            var node: ?*Group = self.groups.tail.?.group;
            while (node) |group| {
                if (@intFromPtr(group.elementsStart()) <= @intFromPtr(element) and
                    @intFromPtr(group.elementsEnd()) > @intFromPtr(element))
                {
                    const found_element: *Slot = @ptrCast(element);

                    return Cursor{
                        .element = found_element,
                        .group = group,
                        .skip = group.skipfieldStart().right(group.indexOf(found_element).unwrap().?),
                    };
                }
                node = group.previous_group;
            }
            return null;
        }

        fn closeGroup(self: *Self, group: *Group) void {
            if (group.prev_open_group) |prev| {
                prev.next_open_group = group.next_open_group;
            } else {
                self.open_groups_head = group.next_open_group;
            }

            if (group.next_open_group) |next| {
                next.prev_open_group = group.prev_open_group;
            }
        }

        fn createGroup(self: *Self, prev_group: ?*Group, capacity: Size) !*Group {
            _ = prev_group;
            var group = try self.allocator.create(Group);
            errdefer self.allocator.destroy(group);
            try group.init(capacity, null, self.allocator);
            return group;
        }
    };
}

test "skipmap.create" {
    const allocator = std.testing.allocator;
    var skipmap = try SkipMap(u128).create(allocator, .{ .initial_block_capacity = 2 });
    defer skipmap.deinit();
    for (0..100) |i| {
        _ = try skipmap.insert(@intCast(i));
    }
    var it = skipmap.iterator();
    var i: u128 = 0;
    while (it.next()) |val| : ({
        i += 1;
    }) {
        try std.testing.expectEqual(i, val.*);
    }
}

test "skipmap.remove" {
    const allocator = std.testing.allocator;
    var skipmap = try SkipMap(u128).create(allocator, .{ .initial_block_capacity = 8 });
    defer skipmap.deinit();
    const a = try skipmap.insert(1);
    const b = try skipmap.insert(2);
    const c = try skipmap.insert(3);
    const d = try skipmap.insert(4);
    const e = try skipmap.insert(5);
    const f = try skipmap.insert(6);
    _ = try skipmap.insert(7);

    // Test all skipblock merge cases
    skipmap.remove(b);
    skipmap.remove(c); // [1] [_] [_] skipblock on left
    skipmap.remove(f);
    skipmap.remove(e); // [_] [_] [1] skipblock on right
    skipmap.remove(d); // [2] [_] [2] skipblock merge
    skipmap.remove(a); // First element

    var it = skipmap.iterator();
    try std.testing.expectEqual(7, it.next().?.*);
    try std.testing.expectEqual(null, it.next());
}

test "skipmap.reuse" {
    const allocator = std.testing.allocator;
    var skipmap = try SkipMap(u128).create(allocator, .{ .initial_block_capacity = 8 });
    defer skipmap.deinit();
    _ = try skipmap.insert(1);
    const b = try skipmap.insert(2);
    _ = try skipmap.insert(3);

    skipmap.remove(b);
    _ = try skipmap.insert(4);

    var it = skipmap.iterator();
    try std.testing.expectEqual(1, it.next().?.*);
    try std.testing.expectEqual(4, it.next().?.*);
    try std.testing.expectEqual(3, it.next().?.*);
    try std.testing.expectEqual(null, it.next());
}
