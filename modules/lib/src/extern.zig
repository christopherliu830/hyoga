pub const std = @import("std");

pub const ExternAllocator = extern struct {
    ptr: *anyopaque,
    vtable: *const std.mem.Allocator.VTable,

    pub fn allocator(self: ExternAllocator) std.mem.Allocator {
        return .{
            .ptr = self.ptr,
            .vtable = self.vtable,
        };
    }

    pub fn of(src: std.mem.Allocator) ExternAllocator {
        return .{ .ptr = src.ptr, .vtable = src.vtable };
    }
};

pub fn ExternSliceConst(T: type) type {
    return extern struct {
        ptr: [*]const T,
        len: usize = 0,

        pub fn from(slice: []const T) ExternSliceConst(T) {
            return .{ .ptr = slice.ptr, .len = slice.len };
        }

        pub fn asSlice(self: ExternSliceConst(T)) []const T {
            return self.ptr[0..self.len];
        }

        pub fn asSliceZ(self: ExternSliceConst(T)) [:0]const T {
            std.debug.assert(self.ptr[self.len] == 0);
            return self.ptr[0..self.len :0];
        }
    };
}

pub fn ExternSlice(T: type) type {
    return extern struct {
        ptr: [*]T,
        len: usize,

        pub fn from(slice: []T) ExternSlice(T) {
            return .{ .ptr = slice.ptr, .len = slice.len };
        }

        pub fn asSlice(self: ExternSlice(T)) []T {
            return self.ptr[0..self.len];
        }

        pub fn asSliceZ(self: ExternSlice(T)) [:0]T {
            std.debug.assert(self.ptr[self.len] == 0);
            return self.ptr[0..self.len :0];
        }
    };
}

pub const ExternVTable = extern struct {
    alloc: *const fn (ctx: *anyopaque, len: usize, ptr_align: u8, ret_addr: usize) callconv(.C) ?[*]u8,
    resize: *const fn (ctx: *anyopaque, buf: []u8, buf_align: u8, new_len: usize, ret_addr: usize) callconv(.C) bool,
    free: *const fn (ctx: *anyopaque, buf: []u8, buf_align: u8, ret_addr: usize) callconv(.C) void,
};

pub fn ExternTaggedUnion(Base: type) type {
    const type_info = @typeInfo(Base).@"union";

    var tag_info = @typeInfo(type_info.tag_type.?);
    tag_info.@"enum".tag_type = u32; // Change backing integer to u32
    const BaseTag = @Type(tag_info);

    const Payload = @Type(.{ .@"union" = .{
        .layout = .@"extern",
        .tag_type = null,
        .fields = std.meta.fields(Base),
        .decls = &.{},
    } });

    return extern struct {
        tag: BaseTag,
        payload: Payload,

        pub fn revert(self: @This()) Base {
            switch (self.tag) {
                inline else => |real_tag| {
                    return @unionInit(Base, @tagName(real_tag), @field(self.payload, @tagName(real_tag)));
                },
            }
        }

        pub fn get(comptime tag: BaseTag, self: @This()) std.meta.TagPayloadByName(Base, @tagName(tag)) {
            const val = @unionInit(Base, @tagName(tag), @bitCast(self.payload));
            return @field(val, @tagName(tag));
        }

        pub fn of(comptime tag: BaseTag, value: std.meta.TagPayloadByName(Payload, @tagName(tag))) @This() {
            const payload = @unionInit(Payload, @tagName(tag), value);
            return .{
                .tag = tag,
                .payload = payload,
            };
        }
    };
}
