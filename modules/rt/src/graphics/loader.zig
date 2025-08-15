const std = @import("std");
const stbi = @import("stb_image");
const gpu = @import("gpu.zig");
const tx = @import("texture.zig");
const mdl = @import("model.zig");
const mt = @import("material.zig");
const sdl = @import("sdl");

const Loader = @This();

pool: std.Thread.Pool,
tsa: std.heap.ThreadSafeAllocator,

pub fn Queue(comptime T: type) type {
    return struct {
        pub const Node = std.SinglyLinkedList.Node;

        tsa: std.heap.ThreadSafeAllocator,
        mutex: std.Thread.Mutex = .{},
        items: std.ArrayListUnmanaged(T) = .empty,

        pub fn init(self: *@This(), in_allocator: std.heap.ThreadSafeAllocator) void {
            self.items = .empty;
            self.tsa = in_allocator;
            self.mutex = .{};
        }

        pub fn push(self: *@This(), value: T) !void {
            self.mutex.lock();
            defer self.mutex.unlock();

            try self.items.append(self.allocator(), value);
        }

        pub fn pop(self: *@This()) ?T {
            self.mutex.lock();
            defer self.mutex.unlock();
            return self.items.pop();
        }

        pub fn deinit(self: *@This()) void {
            self.mutex.lock();
            defer self.mutex.unlock();
            self.items.deinit(self.allocator());
        }

        pub fn allocator(self: *@This()) std.mem.Allocator {
            return self.tsa.allocator();
        }
    };
}

pub fn init(self: *Loader, parent_allocator: std.mem.Allocator) !void {
    self.* = .{
        .tsa = .{ .child_allocator = parent_allocator },
        .pool = undefined,
    };
    try self.pool.init(.{ .allocator = parent_allocator });
}

pub fn deinit(self: *Loader) void {
    self.pool.deinit();
}

pub fn allocator(self: *Loader) std.mem.Allocator {
    return self.tsa.allocator();
}

// Start a function that will eventually add a node to
// the queue that is passed in.
pub fn run(self: *Loader, queue: anytype, comptime func: anytype, args: anytype) !void {
    // Verify type
    if (@typeInfo(@TypeOf(queue)) != .pointer) {
        @compileError("Must be a pointer to a queue");
    }

    try self.pool.spawn(func, .{queue} ++ args);
}
