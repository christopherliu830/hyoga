pub const std = @import("std");
pub const SlotMap = @import("slot_map.zig").SlotMap;

pub fn DoubleIndirectList(T: type) type {
    return struct {
        const Self = @This();

        index_map: SlotMap(usize),
        array: std.ArrayList(T),
        back_ptrs: std.ArrayList(u32),

        pub const Handle = SlotMap(usize).Handle;

        pub const empty: Self = .{
            .index_map = .empty,
            .array = .empty,
            .back_ptrs = .empty,
        };

        pub fn deinit(self: *Self, alloc: std.mem.Allocator) void {
            self.index_map.deinit(alloc);
            self.array.deinit(alloc);
            self.back_ptrs.deinit(alloc);
            self.* = empty;
        }

        pub fn insert(self: *Self, alloc: std.mem.Allocator, value: T) !Handle {
            const item = try self.array.addOne(alloc);
            errdefer _ = self.array.pop();
            const back_ptr = try self.back_ptrs.addOne(alloc);
            errdefer _ = self.array.pop();

            const hdl = try self.index_map.insert(alloc, self.array.items.len - 1);
            back_ptr.* = hdl.index;
            item.* = value;
            return hdl;
        }

        pub fn remove(self: *Self, hdl: SlotMap(usize).Handle) void {
            const index = self.index_map.get(hdl).?;

            if (index == self.array.items.len - 1) {
                _ = self.array.pop();
                _ = self.back_ptrs.pop();
            } else {
                _ = self.array.swapRemove(index);
                _ = self.back_ptrs.swapRemove(index);
                const hdl_to_modify = self.index_map.handle_at(self.back_ptrs.items[index]);
                self.index_map.getPtr(hdl_to_modify).?.* = index;
            }
        }

        pub fn getPtr(self: *Self, hdl: Handle) *T {
            const index = self.index_map.get(hdl).?;
            return &self.array.items[index];
        }
    };
}
