const std = @import("std");

const Self = @This();

pub const Index = enum(u32) {
    none = std.math.maxInt(u32),
    _,
};

inline fn sliceAt(self: *@This(), start: u32) []const u8 {
    return std.mem.span(@as([*:0]const u8, @ptrCast(self.string_bytes.items.ptr)) + start);
}

const IndexContext = struct {
    parent: *Self,

    pub fn eql(self: IndexContext, a: u32, b: u32) bool {
        _ = self;
        return a == b;
    }

    pub fn hash(self: IndexContext, x: u32) u64 {
        const x_slice = self.parent.sliceAt(x);
        return std.hash_map.hashString(x_slice);
    }
};

const SliceAdapter = struct {
    parent: *Self,

    pub fn eql(self: SliceAdapter, a_slice: []const u8, b: u32) bool {
        const b_slice = self.parent.sliceAt(b);
        return std.mem.eql(u8, a_slice, b_slice);
    }

    pub fn hash(self: SliceAdapter, adapted_key: []const u8) u64 {
        _ = self;
        return std.hash_map.hashString(adapted_key);
    }
};

arena: std.heap.ArenaAllocator,
string_bytes: std.ArrayListUnmanaged(u8) = .{},
map: std.HashMapUnmanaged(u32, void, IndexContext, std.hash_map.default_max_load_percentage) = .{},

pub fn init(in_allocator: std.mem.Allocator) Self {
    return .{
        .arena = std.heap.ArenaAllocator.init(in_allocator),
    };
}

pub fn shutdown(self: *Self) void {
    self.map.deinit(self.arena.allocator());
    self.arena.deinit();
}

pub fn from(self: *Self, str: []const u8) !Index {
    if (self.map.getEntryAdapted(str, SliceAdapter{ .parent = self })) |entry| {
        return @enumFromInt(entry.key_ptr.*);
    }

    const index: u32 = @intCast(self.string_bytes.items.len);
    try self.string_bytes.appendSlice(self.arena.allocator(), str);

    // Manually add a sentinel to work with runtime-generated non-sentinel strings
    // and for compatibility
    if (self.string_bytes.items[self.string_bytes.items.len - 1] != 0) try self.string_bytes.append(self.arena.allocator(), 0);
    try self.map.putContext(self.arena.allocator(), index, {}, IndexContext{ .parent = self });
    return @enumFromInt(index);
}

pub fn lookup(self: *Self, id: Index) []const u8 {
    return self.sliceAt(@intFromEnum(id));
}

pub fn lookupZ(self: *Self, id: Index) [:0]const u8 {
    return std.mem.span(@as([*:0]const u8, @ptrCast(self.string_bytes.items.ptr)) + @intFromEnum(id));
}
