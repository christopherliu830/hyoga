const std = @import("std");
const stbi = @import("stb_image");
const gpu = @import("gpu.zig");
const tx = @import("texture.zig");
const mdl = @import("model.zig");
const mt = @import("material.zig");
const sdl = @import("sdl");
const hya = @import("hyoga-arena");

const Loader = @This();

pool: std.Thread.Pool,
tsa: std.heap.ThreadSafeAllocator,

pub fn Queue(comptime T: type) type {
    return struct {
        pub const Node = std.SinglyLinkedList(T).Node;

        tsa: std.heap.ThreadSafeAllocator,
        mutex: std.Thread.Mutex = .{},
        items: std.SinglyLinkedList(T) = .{},

        pub fn init(self: *@This(), in_allocator: std.mem.Allocator) void {
            self.items = .{};
            self.mutex = .{};
            self.tsa = .{ .child_allocator = in_allocator, .mutex = self.mutex };
        }

        pub fn push(self: *@This(), value: T) !void {
            self.mutex.lock();
            defer self.mutex.unlock();

            const node = try self.allocator().create(Node);
            node.data = value;
            self.items.prepend(node);
        }

        pub fn pop(self: *@This()) ?T {
            self.mutex.lock();
            defer self.mutex.unlock();
            if (self.items.popFirst()) |node| {
                const data = node.data;
                self.allocator().destroy(node);
                return data;
            } 
            return null;
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
