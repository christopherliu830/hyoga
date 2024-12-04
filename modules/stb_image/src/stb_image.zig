const std = @import("std");

const alignment = 16;

pub usingnamespace @cImport({ @cInclude("stb_image.h"); });

var buffer: []u8 = undefined;
var fba: std.heap.FixedBufferAllocator = undefined;
var parent_allocator: std.mem.Allocator = undefined;
var arena: std.heap.ArenaAllocator = undefined;
var alloc_size_by_ptr: std.AutoHashMap(usize, usize) = undefined;

pub fn malloc(size: usize) callconv(.C) ?*anyopaque {
    // var allocator = arena.allocator();
    var allocator = parent_allocator;

    const mem = allocator.alignedAlloc(u8, 16, size)
        catch @panic("out of memory");

    alloc_size_by_ptr.put(@intFromPtr(mem.ptr), size)
        catch @panic("out of memory");

    var total_size: usize = 0;
    var it = alloc_size_by_ptr.valueIterator();
    while (it.next()) |s| total_size += s.*;
    return @ptrCast(mem.ptr);

}

pub fn realloc(in_ptr: ?*anyopaque, size: usize) callconv(.C) ?*anyopaque {
    // var allocator = arena.allocator();
    var allocator = parent_allocator;

    if (in_ptr) |ptr| {
        const alloc_size = alloc_size_by_ptr.get(@intFromPtr(ptr)) orelse 0;
        const alloc: [*]align(16)u8 = @alignCast(@ptrCast(ptr));

        const new_alloc = allocator.realloc(alloc[0..alloc_size], size) 
            catch @panic("Out of memory");

        if (alloc_size > 0) {
            const removed = alloc_size_by_ptr.remove(@intFromPtr(ptr));
            std.debug.assert(removed);
        }

        alloc_size_by_ptr.put(@intFromPtr(new_alloc.ptr), size) catch @panic("out of memory");

        return @ptrCast(new_alloc);
    } else { 
        return malloc(size);
    }

    var total_size: usize = 0;
    var it = alloc_size_by_ptr.valueIterator();
    while (it.next()) |s| total_size += s.*;
}

pub fn free(in_ptr: ?*anyopaque) callconv(.C) void {
    var allocator = parent_allocator;
    if (in_ptr) |ptr| {
        const alloc_size = alloc_size_by_ptr.get(@intFromPtr(ptr)) orelse 0;
        const alloc: [*]align(16)u8 = @alignCast(@ptrCast(ptr));

        allocator.free(alloc[0..alloc_size]);

        if (alloc_size > 0) {
            const removed = alloc_size_by_ptr.remove(@intFromPtr(ptr));
            std.debug.assert(removed);
        }
    } 
    // no-op for arena
}

extern var vtable: extern struct {
    malloc: ?*const fn (size: usize) callconv(.C) ?*anyopaque,
    free: ?*const fn(ptr: ?*anyopaque) callconv(.C) void,
    realloc: *const fn(ptr: ?*anyopaque, size: usize) callconv(.C) ?*anyopaque, 
};


pub fn init(in_allocator: std.mem.Allocator) void {
    parent_allocator = in_allocator;
    arena = std.heap.ArenaAllocator.init(parent_allocator);
    alloc_size_by_ptr = std.AutoHashMap(usize, usize).init(parent_allocator);

    vtable = .{
        .malloc = malloc,
        .realloc = realloc,
        .free = free,
    };
}

pub fn resetArena(mode: std.heap.ArenaAllocator.ResetMode) void {
    _ = arena.reset(mode);
}
