const std = @import("std");

// https://github.com/mattreecebentley/plf_hive/blob/main/plf_hive.h

pub fn Hive(comptime UnalignedT: type) type {
    const SkipfieldType = blk: {
        if (@sizeOf(UnalignedT) > 10 or @alignOf(UnalignedT) > 10) {
            break :blk u16;
        }
        else {
            break :blk u8;
        }
    };

    // The element as allocated in memory needs to be at-least 2*skipfield_type width in order to support free list indexes in erased element memory space, so:
    // make the size of this struct the larger of alignof(T), sizeof(T) or 2*skipfield_type (the latter is only relevant for type char/uchar), and
    // make the alignment alignof(T).
    // This type is used mainly for correct pointer arithmetic while iterating over elements in memory.
    const aligned_size= std.math.maxInt(2 * @sizeOf(SkipfieldType), std.math.maxInt(@alignOf(T), @sizeOf(T)));
    const T = struct {
        data: std.meta.Int(.unsigned, aligned_size) align(@alignOf(T)),
    };

    // We combine the allocation of elements and skipfield into one allocation to save performance.
    // This memory must be allocated as an aligned type with the same alignment as T in order for 
    // the elements to align with memory boundaries correctly (which won't happen if we allocate as char or uint_8).
    // But the larger the sizeof in the type we use for allocation, the greater the chance of creating a lot of
    // unused memory in the skipfield portion of the allocated block. So we create a type that is sizeof(alignof(T)),
    // as in most cases alignof(T) < sizeof(T). If alignof(t) >= sizeof(t) this makes no difference.
    const Allocation = struct {
        data: std.meta.Int(.unsigned, @alignOf(T)) align(@alignOf(T))
    };

    return struct {

        // group == element memory block + skipfield + block metadata
        pub const Group = struct {
            skipfield: []SkipfieldType, // Start of the skipfield
            next_group: ?*Group = null,
            elements: []T, // Start of the memory block
            previous_group: ?*Group,
            free_list_head: SkipfieldType, // Index of last erased element in the group.
            capacity: SkipfieldType, // Element capacity
            size: SkipfieldType, // Number of active elements
            erasures_list_next_group: ?*Group = null, // Next and previous groups that contain a non-empty free list.
            erasures_list_next_group: ?*Group = null,

            pub fn create(capacity: u32, elements_per_group: u8, allocator: std.mem.Allocator) Group {
                const data = try allocator.alloc(u8, capacity);
                const skipfield = @ptrCast(@alignCast(data + elements_per_group * @sizeOf(T)));
                return Group {
                    .elements = .{ .ptr = @ptrCast(@alignCast(data)), .len = elements_per_group },
                    .skipfield = .{ .ptr = @ptrCast(@alignCast(data)), .len = elements_per_group },
                };
            }
        };
        
        allocator: std.mem.Allocator,
        unused_groups: std.SinglyLinkedList(*Group),
        end_index: usize = 0,
        total_size: usize = 32,

        pub fn create(allocator: std.mem.Allocator) Hive(T) {

        }

        pub fn createGroup(self: *Hive(T), size: usize) *Group {
            self.allocator.alloc(u8, size);
        }

        pub fn insert(self: *Hive(T), value: T) void {
            var next_group: *Group = undefined;
            if (self.unused_groups.first == null) {
                const new_group_size = self.total_size;
                next_group = createGroup(new_group_size);
                next_group.items

                self.total_size += new_group_size;
            }
        }
    };
}