const std = @import("std");

const alignment = 16;

pub const c = @import("c");

const Stbi = @This();

tsa: std.heap.ThreadSafeAllocator,
alloc_size_by_ptr: std.AutoHashMap(usize, usize),
mutex: std.Thread.Mutex,

pub fn malloc(self: *anyopaque, size: usize) callconv(.C) ?*anyopaque {
    var stbi: *Stbi = @ptrCast(@alignCast(self));
    var allocator = stbi.tsa.allocator();

    const mem = allocator.alignedAlloc(u8, 16, size)
        catch @panic("out of memory");

    { 
        stbi.mutex.lock();
        defer stbi.mutex.unlock();
        stbi.alloc_size_by_ptr.put(@intFromPtr(mem.ptr), size)
            catch @panic("out of memory");
    }

    return @ptrCast(mem.ptr);

}

pub fn realloc(self: *anyopaque, in_ptr: ?*anyopaque, size: usize) callconv(.C) ?*anyopaque {
    var stbi: *Stbi = @ptrCast(@alignCast(self));
    var allocator = stbi.tsa.allocator();

    if (in_ptr) |ptr| {
        stbi.mutex.lock();
        defer stbi.mutex.unlock();

        const alloc_size = stbi.alloc_size_by_ptr.get(@intFromPtr(ptr)) orelse 0;

        const alloc: [*]align(16)u8 = @alignCast(@ptrCast(ptr));

        const new_alloc = allocator.realloc(alloc[0..alloc_size], size) 
            catch @panic("Out of memory");


        if (alloc_size > 0) {
            const removed = stbi.alloc_size_by_ptr.remove(@intFromPtr(ptr));
            std.debug.assert(removed);
        }

        stbi.alloc_size_by_ptr.put(@intFromPtr(new_alloc.ptr), size) catch @panic("out of memory");

        return @ptrCast(new_alloc);
    } else { 
        return malloc(self, size);
    }
}

pub fn free(self: *anyopaque, in_ptr: ?*anyopaque) callconv(.C) void {
    var stbi: *Stbi = @ptrCast(@alignCast(self));
    var allocator = stbi.tsa.allocator();

    if (in_ptr) |ptr| {
        stbi.mutex.lock();
        defer stbi.mutex.unlock();

        const alloc_size = stbi.alloc_size_by_ptr.get(@intFromPtr(ptr)) orelse 0;
        const alloc: [*]align(16)u8 = @alignCast(@ptrCast(ptr));

        allocator.free(alloc[0..alloc_size]);

        if (alloc_size > 0) {
            const removed = stbi.alloc_size_by_ptr.remove(@intFromPtr(ptr));
            std.debug.assert(removed);
        }
    } 
}

extern var hystbi_malloc: ?*const fn (self: *anyopaque, size: usize) callconv(.C) ?*anyopaque;
extern var hystbi_free: ?*const fn(self: *anyopaque, ptr: ?*anyopaque) callconv(.C) void;
extern var hystbi_realloc: *const fn(self: *anyopaque, ptr: ?*anyopaque, size: usize) callconv(.C) ?*anyopaque;

extern var hystbi_allocator: *anyopaque;

pub fn init(in_allocator: std.mem.Allocator) Stbi {
    var stb: Stbi = undefined;
    stb.mutex = .{};
    stb.tsa = std.heap.ThreadSafeAllocator { .child_allocator = in_allocator, .mutex = stb.mutex };
    stb.alloc_size_by_ptr = std.AutoHashMap(usize, usize).init(in_allocator);

    hystbi_malloc = malloc;
    hystbi_realloc = realloc;
    hystbi_free = free;

    return stb;
}

pub fn use(self: *Stbi) void {
    hystbi_allocator = self;
    hystbi_malloc = malloc;
    hystbi_realloc = realloc;
    hystbi_free = free;
}

pub fn deinit(self: *Stbi) void {
    self.alloc_size_by_ptr.deinit();
}
