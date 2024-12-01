const std = @import("std");

const EntryType = enum {
    empty,
    occupied,
};


pub fn Hive(comptime T: type) type {
    return struct {
        pub const Cursor = struct {
            group: *Group,
            element: *Slot,
            skip: *Skip,
        };
        
        pub const Iterator = struct {
            cursor: Cursor,
            end: *Skip,

            pub fn next(self: *Iterator) ?*T {
                const cursor = &self.cursor;
                std.debug.assert(@intFromPtr(cursor.group.skipfieldStart()) <= @intFromPtr(cursor.skip));
                std.debug.assert(@intFromPtr(cursor.skip) <= @intFromPtr(cursor.group.skipfield + cursor.group.capacity + 1));
                std.debug.assert(@intFromPtr(cursor.group.elementsStart()) <= @intFromPtr(cursor.element));
                std.debug.assert(@intFromPtr(cursor.element) <= @intFromPtr(cursor.group.elementsEnd()));

                if (cursor.skip == self.end) return null;

                if (cursor.skip.value != 0) {
                    cursor.element = cursor.element.right(cursor.skip.value);
                    cursor.skip = cursor.skip.right(cursor.skip.value);
                }

                if (cursor.skip == self.end) return null;

                const ret = &cursor.element.data;

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

            pub fn skip(self: *Iterator) void {
                const cursor = &self.cursor;
                const group_end: [*]align(1)Slot = @ptrCast(cursor.group.skipfield);
                const end = @as([*]Skip, @ptrCast(self.end));

                // TODO: implement skipfields
                // loop until the next non-null element
                while (cursor.element != group_end) {
                    if (cursor.skip[0] == 0) break;
                    if (cursor.skip == end) break;
                    cursor.element = cursor.element.right(1);
                    cursor.skip = cursor.skip.right(1);
                }
            }
        };

        const Self = @This();

        const Size = blk: {
            if (@sizeOf(T) > 10 or @alignOf(T) > 10) {
                break :blk u16;
            }
            else {
                break :blk u8;
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

        const SlotIndex = enum (Size) {
            none = std.math.maxInt(Size),
            // Index to the last erased element in the group.
            _,

            inline fn unwrap(i: @This()) ?Size {
                return switch(i) {
                    .none => return null,
                    else => @intFromEnum(i)
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
                const ptr: [*]Slot= @ptrCast(self);
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
            prev_group_with_vacancy: ?*Group = null, // Next and previous groups that contain a non-empty free list.
            next_group_with_vacancy: ?*Group = null,
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
                @memset(ptr_skipfield[0..capacity + 1], .{ .value = 0 });

                if (prev_group) |g | g.next_group = self; 

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
                const ptr_data: [*]align(@alignOf(T))Stride = @ptrCast(@alignCast(self.elements));
                const data = ptr_data[0..Group.alignedSize(self.capacity)];
                self.group_no = 0;
                allocator.free(data);
                allocator.destroy(self);
            }
        };

        head: ?Cursor = null,
        tail: Cursor,
        groups_with_vacancy: ?*Group = null,
        total_capacity: usize = 0,
        total_size: usize = 0,
        block_capacity: Size = 8,
        max_block_capacity: Size = @min(std.math.maxInt(Size), 8192), 
        allocator: std.mem.Allocator,

        pub const CreateOptions = struct {
            initial_block_capacity: Size = 8,
        };

        pub fn create(allocator: std.mem.Allocator, options: CreateOptions) !Hive(T) {
            const hive = Hive(T) {
                .allocator = allocator,
                .block_capacity = options.initial_block_capacity,
                .head = undefined,
                .tail = undefined,
            };
            return hive;
        }

        pub fn deinit(self: *Self) void {
            var q_group = self.head.?.group;
            while (q_group) |group| {
                group.deinit(self.allocator);
                q_group = group.next_group;
            }
        }

        pub fn iterator(self: *Self) Iterator {

            // const cursor = Cursor {
            //     .group = self.groups.?,
            //     .element = self.groups.?.elementsStart(),
            //     .skip = self.groups.?.skipfieldStart(),
            // };

            // const end = if (self.total_size == 0 and self.groups != null) self.groups.?.skipfieldStart() else self.tail.skip;

            return Iterator {
                .end = self.tail.skip,
                .cursor = self.head.?,
            };
        }

        pub fn insert(self: *Self, value: T) !Cursor {
            // Init
            if (self.head == null) {
                var group: *Group = undefined;
                const capacity = @min(self.block_capacity, self.max_block_capacity);
                group = try self.createGroup(null, capacity);
                group.size = 1;
                group.elements[0] = .{ .data = value };
                self.total_capacity = 1;
                self.total_size += 1;

                self.head = .{
                    .group = group,
                    .element = group.elementsStart(),
                    .skip = group.skipfieldStart()
                };

                self.tail = self.head.?;
                self.tail.element = self.tail.element.right(1);
                self.tail.skip = self.tail.skip.right(1);
                return self.head.?;
            } 

            if (self.groups_with_vacancy) |group| {
                group.size += 1;
                self.total_size += 1;

                const slot = &group.elements[group.free_list_head.unwrap().?];
                const skip = &group.skipfield[group.free_list_head.unwrap().?];
                const free_node = slot.free_node;

                // Fix up skipblock and vacancy groups
                const skiplen = skip.value - 1; 

                if (skiplen != 0) {
                    skip.right(1).value = skiplen;
                    skip.right(skiplen).value = skiplen;

                    if (free_node.next.unwrap()) |node| {
                        group.elements[node].free_node.prev = group.indexOf(slot.right(1));
                    }

                    // Point free list head to new skipblock start
                    group.free_list_head = @enumFromInt(@intFromEnum(group.free_list_head) + 1);
                    slot.right(1).* = .{ .free_node = free_node };
                } 
                // Remove free list
                else { 
                    group.free_list_head = free_node.next;
                    if (group.free_list_head.unwrap()) |head| {
                        group.elements[head].free_node.prev = .none;
                    } 
                    // No elements free, remove from vacancy list
                    else {
                        self.groups_with_vacancy = self.groups_with_vacancy.?.next_group_with_vacancy;
                    }
                }

                slot.* = .{ .data = value };
                skip.value = 0;

                if (group == self.head.?.group and group.indexOf(slot).unwrap().? < group.indexOf(self.head.?.element).unwrap().?) {
                    self.head = .{
                        .element = slot,
                        .skip= skip,
                        .group = group,
                    };
                }

                return .{
                    .group = group,
                    .element = slot,
                    .skip = skip,
                };
            } else {
                // Not at end of group yet.
                if (self.tail.element != self.tail.group.elementsEnd()) {
                    self.total_size += 1;
                    self.tail.group.size += 1;

                    self.tail.element.* = .{ .data = value };
                    const cursor = self.tail;
                    self.tail.element = self.tail.element.right(1);
                    self.tail.skip = self.tail.skip.right(1);
                    return cursor;
                }

                // End of group, allocate new.
                else { 
                    self.block_capacity *= 2;
                    const capacity = @min(self.block_capacity, self.max_block_capacity);
                    var group = try self.createGroup(self.tail.group, capacity);
                    group.elements[0] = .{ .data = value };
                    group.size = 1;
                    self.total_capacity += group.capacity;
                    self.total_size += 1;

                    const cursor = Cursor {
                        .group = group,
                        .element = group.elementsStart(),
                        .skip = group.skipfieldStart(),
                    };

                    self.tail = cursor;
                    self.tail.element = self.tail.element.right(1);
                    self.tail.skip = self.tail.skip.right(1);

                    return cursor;
                }
            }
        }

        pub fn remove(self: *Self, cursor: Cursor) void {
            std.debug.assert(self.total_size != 0);
            std.debug.assert(cursor.element != self.tail.element);
            self.total_size -= 1;
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
                    } 

                    else {
                        group.next_group_with_vacancy = self.groups_with_vacancy;

                        if (self.groups_with_vacancy) |vacant_group| {
                            vacant_group.prev_group_with_vacancy = group;
                        }

                        self.groups_with_vacancy = group;
                    }

                    cursor.element.* = .{ .free_node = .{
                        .prev= .none,
                        .next= group.free_list_head,
                    }};

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
                    cursor.element.* = .{ .free_node =  cursor.element.right(1).free_node }; 

                    const index = cursor.group.indexOf(cursor.element);
                    const node_prev= cursor.element.free_node.prev.unwrap();
                    const node_next= cursor.element.free_node.next.unwrap();

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

                if (cursor.element == self.head.?.element) {
                    self.head.?.skip = cursor.skip.right(head_skiplen);
                    self.head.?.element = cursor.element.right(head_skiplen);
                }
            } else {
                const has_next = group.next_group != null;
                const has_prev = group.previous_group != null;

                // Only group left
                if (!has_next and !has_prev) {
                    self.groups_with_vacancy = null;
                    self.tail.group = group;
                    self.tail.element = group.elementsStart();
                    self.tail.skip = group.skipfieldStart();

                    self.head = self.tail;

                    @memset(group.skipfield[0..group.capacity], .{ .value = 0 });
                    group.free_list_head = .none;
                    group.size = 0;
                    group.previous_group = null;
                    group.next_group = null;
                    group.next_group_with_vacancy = null;
                    group.prev_group_with_vacancy = null;
                    group.group_no = 0;
                }

                else if (!has_prev and has_next) {
                    group.next_group.?.previous_group = null;
                    self.head.?.group = group.next_group.?;

                    // Remove from vacancies
                    if (group.free_list_head != .none) {
                        self.fixVacancyList(group);
                    }
                    
                    const skiplen = self.head.?.group.skipfieldStart().value;
                    self.head.?.element = self.head.?.group.elementsStart().right(skiplen);
                    self.head.?.skip = self.head.?.group.skipfieldStart().right(skiplen);

                    self.total_capacity -= group.capacity;
                    group.deinit(self.allocator);
                }
                
                else if (has_prev and has_next) {
                    group.next_group.?.previous_group = group.previous_group;
                    group.previous_group.?.next_group = group.next_group;


                    if (group.free_list_head != .none) {
                        self.fixVacancyList(group);
                    }

                    self.total_capacity -= group.capacity;
                    group.deinit(self.allocator);
                }

                else { // has_prev and !has_next
                    group.previous_group.?.next_group = group.next_group;

                    if (group.free_list_head != .none) {
                        self.fixVacancyList(group);
                    }

                    group.previous_group.?.next_group = null;
                    self.tail.group = group.previous_group.?;
                    self.tail.element = self.tail.group.elementsEnd();
                    self.tail.skip = self.tail.group.skipfieldStart().right(self.tail.group.capacity);

                    self.total_capacity -= group.capacity;
                    group.deinit(self.allocator);
                }
            }
        }

        pub fn dump(self: *Self) void {
            if (self.head) |head| {
                var q_group: ?*Group = head.group;
                while (q_group) |group| {
                    std.debug.print("grp: {}\n", .{group.group_no});
                    var last = false;
                    std.debug.print("i:\t", .{});
                    for (0..group.capacity) |i| {
                        if (group.skipfieldStart().right(i) == self.tail.skip) {
                            std.debug.print("END\t", .{});
                            last = true;
                            break;
                        }

                        std.debug.print("{}\t", .{i});
                    }
                    std.debug.print("\ns:\t", .{});
                    for (group.skipfield[0..group.capacity]) |*skip| {
                        if (skip == self.tail.skip) {
                            last = true;
                            std.debug.print("END\t", .{});
                            break;
                        }

                        const v = skip.value;
                        std.debug.print("{}\t", .{v});
                    }
                    std.debug.print("\ne:\t", .{});
                    for (group.elements[0..group.capacity], 0..) |e, i| {
                        if (group.skipfieldStart().right(i) == self.tail.skip) {
                            std.debug.print("END\t", .{});
                            last = true;
                            break;
                        }

                        if (group.skipfieldStart().right(i).value == 0) {
                            std.debug.print("{}\t", .{e.data});
                        } else {
                            std.debug.print("_\t", .{});
                        }

                    }

                    std.debug.print("\nfree:\t", .{});
                    var q_node = group.free_list_head.unwrap();
                    while (q_node) |node| {
                        std.debug.print("{}->", .{node});
                        q_node = group.elements[node].free_node.next.unwrap();
                    }

                    q_group = group.next_group;
                    std.debug.print("\n", .{});


                }


                q_group = head.group;
                std.debug.print("\ngr:", .{});
                while (q_group) |group| {
                    std.debug.print("{}->", .{group.group_no});
                    q_group = group.next_group;
                }
                q_group = self.groups_with_vacancy;
                std.debug.print("\nva:", .{});
                while (q_group) |group| {
                    std.debug.print("{}->", .{group.group_no});
                    q_group = group.next_group_with_vacancy;
                }
                std.debug.print("\nhead at: {}\n", .{head.group.indexOf(head.element)});

                std.debug.print("\n", .{});
                std.debug.print("\n", .{});
            }
        }

        fn fixVacancyList(self: *Self, group: *Group) void {
            if (group == self.groups_with_vacancy) {
                self.groups_with_vacancy = group.next_group_with_vacancy;
            } else {
                group.prev_group_with_vacancy.?.next_group_with_vacancy = group.next_group_with_vacancy;

                if (group.next_group_with_vacancy != null) {
                    group.next_group_with_vacancy.?.prev_group_with_vacancy = group.prev_group_with_vacancy;
                }
            } 
        }

        fn createGroup(self: *Self, next_group: ?*Group, capacity: Size) !*Group {
            var group = try self.allocator.create(Group);
            errdefer self.allocator.destroy(group);
            try group.init(capacity, next_group, self.allocator);
            return group;
        }
    };
}

test "hive.create" {
    const allocator = std.testing.allocator;
    var hive = try Hive(u128).create(allocator, .{ .initial_block_capacity = 2 });
    defer hive.deinit();
    for (0..100) |i| { _ = try hive.insert(@intCast(i)); }
    var it = hive.iterator();
    var i: u128 = 0;
    while (it.next()) |val| : ({ i += 1; }) {
        try std.testing.expectEqual(i, val.*);
    }
}

test "hive.remove" {
    const allocator = std.testing.allocator;
    var hive = try Hive(u128).create(allocator, .{ .initial_block_capacity = 8 });
    defer hive.deinit();
    const a = try hive.insert(1);
    const b = try hive.insert(2);
    const c = try hive.insert(3);
    const d = try hive.insert(4);
    const e = try hive.insert(5);
    const f = try hive.insert(6);
    _ = try hive.insert(7);

    // Test all skipblock merge cases
    hive.remove(b); 
    hive.remove(c); // [1] [_] [_] skipblock on left
    hive.remove(f);  
    hive.remove(e); // [_] [_] [1] skipblock on right
    hive.remove(d); // [2] [_] [2] skipblock merge
    hive.remove(a); // First element

    var it = hive.iterator();
    try std.testing.expectEqual(7, it.next().?.*);
    try std.testing.expectEqual(null, it.next());
}

test "hive.reuse" {
    const allocator = std.testing.allocator;
    var hive = try Hive(u128).create(allocator, .{ .initial_block_capacity = 8 });
    defer hive.deinit();
    _ = try hive.insert(1);
    const b = try hive.insert(2);
    _ = try hive.insert(3);

    hive.remove(b);
    _ = try hive.insert(4);

    var it = hive.iterator();
    try std.testing.expectEqual(1, it.next().?.*);
    try std.testing.expectEqual(4, it.next().?.*);
    try std.testing.expectEqual(3, it.next().?.*);
    try std.testing.expectEqual(null, it.next());
}

test "hive.basic" {

}