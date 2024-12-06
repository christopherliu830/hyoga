const std = @import("std");
const hya = @import("hyoga-arena");

pub const Symbol = struct {
    value: u32,

    pub fn asString(self: Symbol) []const u8 {
        return sliceAt(self.value);
    }

    pub fn asStringZ(self: Symbol) [:0]const u8 {
        return std.mem.span(@as([*:0]const u8, @ptrCast(string_bytes.items.ptr)) + self.value);
    }
};

var arena: std.heap.ArenaAllocator = undefined;
var symbol_count: u32 = 0;
var string_bytes: std.ArrayListUnmanaged(u8) = .{};
var map: std.HashMapUnmanaged(u32, void, IndexContext, std.hash_map.default_max_load_percentage) = .{};

inline fn sliceAt(i: u32) []const u8 {
    return std.mem.span(@as([*:0]const u8, @ptrCast(string_bytes.items.ptr)) + i);
}

const IndexContext = struct {

    pub fn eql(self: IndexContext, a: u32, b: u32) bool {
        _ = self;
        return a == b;
    }

    pub fn hash(self: IndexContext, x: u32) u64 {
        _ = self;
        const x_slice = sliceAt(x);
        return std.hash_map.hashString(x_slice);
    }
};

const SliceAdapter = struct {

    pub fn eql(self: SliceAdapter, a_slice: []const u8, b: u32) bool {
        _ = self;
        const b_slice = sliceAt(b);
        return std.mem.eql(u8, a_slice, b_slice);
    }

    pub fn hash(self: SliceAdapter, adapted_key: []const u8) u64 {
        _ = self;
        return std.hash_map.hashString(adapted_key);
    }
};

const index_context = IndexContext { };

const slice_context = SliceAdapter { };

pub fn init(in_allocator: std.mem.Allocator) void {
    arena = std.heap.ArenaAllocator.init(in_allocator);
}

pub fn shutdown() void {
    arena.deinit();
}

pub fn from(str: []const u8) !Symbol {
    if (map.getEntryAdapted(str, slice_context)) |entry| {
        return .{ .value = entry.key_ptr.* };
    }

    const index: u32 = @intCast(string_bytes.items.len);
    try string_bytes.appendSlice(arena.allocator(), str);

    // Manually add a sentinel to work with runtime-generated non-sentinel strings
    // and for compatibility
    if (string_bytes.items[string_bytes.items.len - 1] != 0) try string_bytes.append(arena.allocator(), 0); 
    try map.putContext(arena.allocator(), index, {}, index_context); 
    return .{ .value = index };
}
