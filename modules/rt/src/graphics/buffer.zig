const std = @import("std");
const hy = @import("hyoga-lib");
const sdl = @import("sdl");

const panic = std.debug.panic;

pub fn BufferAllocator(comptime usage: sdl.gpu.BufferUsageFlags) type {
    return struct {
        const Self = @This();
        device: *sdl.gpu.Device,
        buffer_list: std.SinglyLinkedList = .{},
        free_buffer_list: std.SinglyLinkedList = .{},
        node_allocator: std.heap.MemoryPool(Buf),
        end_index: u32 = 0,

        pub const Buf = struct {
            node: std.SinglyLinkedList.Node,
            hdl: *sdl.gpu.Buffer,
            size: u32,
            num_allocations: u32 = 0,
        };

        pub const Iterator = struct {
            current: ?*std.SinglyLinkedList.Node,

            pub fn next(self: *Iterator) ?*Buf {
                if (self.current) |node| {
                    self.current = node.next;
                    const buf: *Buf = @fieldParentPtr("node", node);
                    return buf;
                }
            }
        };

        const min_buffer_size = 2 * 1024 * 1024;

        pub fn init(device: *sdl.gpu.Device, allocator: std.mem.Allocator) @This() {
            return .{
                .device = device,
                .node_allocator = .init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.reset();
            self.node_allocator.deinit();
        }

        pub fn iterator(self: *const Self) Iterator {
            return .{ .current = self.buffer_list.head };
        }

        pub fn reset(self: *Self) void {
            var maybe_node = self.buffer_list.popFirst();
            while (maybe_node) |node| : (maybe_node = self.buffer_list.popFirst()) {
                const buf: *Buf = @fieldParentPtr("node", node);
                self.device.releaseBuffer(buf.hdl);
                self.node_allocator.destroy(buf);
            }

            maybe_node = self.free_buffer_list.popFirst();
            while (maybe_node) |node| : (maybe_node = self.free_buffer_list.popFirst()) {
                const buf: *Buf = @fieldParentPtr("node", node);
                self.device.releaseBuffer(buf.hdl);
                self.node_allocator.destroy(buf);
            }
        }

        fn createNode(self: *Self, prev_len: u32, min_size: u32) sdl.gpu.Error!*Buf {
            if (self.free_buffer_list.first) |node| {
                const buf: *Buf = @fieldParentPtr("node", node);
                if (buf.size > min_size) {
                    const recycled_node = self.free_buffer_list.popFirst().?;
                    self.buffer_list.prepend(recycled_node);
                    self.end_index = 0;
                    return buf;
                }
            }
            const len = (prev_len + min_size) + (prev_len + min_size) / 2;
            const buffer = try self.device.createBuffer(&.{ .size = len, .usage = usage });
            self.device.setBufferName(buffer, "Buffer Allocator Buffer");
            const buf = self.node_allocator.create() catch hy.err.oom();
            buf.* = .{
                .node = .{},
                .hdl = buffer,
                .size = len,
            };
            self.buffer_list.prepend(&buf.node);
            self.end_index = 0;
            return buf;
        }

        pub fn alloc(self: *Self, n: u32) sdl.gpu.Error!Buffer {
            var cur_node: *Buf = if (self.buffer_list.first) |first_node|
                @fieldParentPtr("node", first_node)
            else
                try self.createNode(0, @min(min_buffer_size, n));

            while (true) {
                const offset = self.end_index;
                const end_offset = offset + n;

                if (end_offset <= cur_node.size) {
                    self.end_index = end_offset;
                    cur_node.num_allocations += 1;
                    return .{
                        .hdl = cur_node.hdl,
                        .offset = offset,
                        .size = n,
                    };
                }

                cur_node = try self.createNode(cur_node.size, n);
            }
        }

        pub fn destroy(self: *Self, buffer: Buffer) void {
            var it = self.buffer_list.first;
            while (it) |node| : (it = node.next) {
                const buf: *Buf = @fieldParentPtr("node", node);
                if (buf.hdl == buffer.hdl) {
                    buf.num_allocations -= 1;

                    if (buf.num_allocations == 0) {
                        if (node == self.buffer_list.first) {
                            self.end_index = 0;
                        } else {
                            self.buffer_list.remove(node);
                            self.free_buffer_list.prepend(node);
                        }
                    }
                    break;
                }
            }
        }

        pub fn dupe(self: *Self, buffer: Buffer) void {
            var it = self.buffer_list.first;
            while (it) |node| : (it = node.next) {
                const buf: *Buf = @fieldParentPtr("node", node);
                if (buf.hdl == buffer.hdl) {
                    buf.num_allocations += 1;
                    break;
                }
            }
        }

        pub fn resize(self: *Self, buffer: Buffer, new_size: u32) bool {
            const node = self.buffer_list.first orelse return false;
            const head: *Buf = @fieldParentPtr("node", node);
            if (head.hdl != buffer.hdl or buffer.offset + buffer.size != self.end_index) {
                return new_size <= buffer.size;
            }

            if (buffer.size >= new_size) {
                self.end_index -= buffer.size - new_size;
                return true;
            } else if (head.size - self.end_index >= new_size - buffer.size) {
                self.end_index += new_size - buffer.size;
                return true;
            } else {
                return false;
            }
        }
    };
}

pub const VertexIndexBuffer = struct {
    hdl: *sdl.gpu.Buffer,
    size: u32,
    offset: u32 = 0,
    idx_start: u32 = std.math.maxInt(u32),

    pub fn create(device: *sdl.gpu.Device, vtx_size: u32, idx_size: u32) VertexIndexBuffer {
        const hdl = device.createBuffer(&.{
            .usage = .{ .index = true, .vertex = true },
            .size = vtx_size + idx_size,
        }) catch panic("error creating buffer", .{});

        return .{
            .hdl = hdl,
            .size = vtx_size + idx_size,
            .idx_start = vtx_size,
        };
    }

    pub inline fn idxCount(self: VertexIndexBuffer) u32 {
        return (self.size - (self.idx_start - self.offset)) / @sizeOf(u32);
    }

    pub fn buffer(self: *const VertexIndexBuffer) Buffer {
        return .{
            .hdl = self.hdl,
            .size = self.size,
            .offset = self.offset,
        };
    }

    pub fn eql(lhs: VertexIndexBuffer, rhs: VertexIndexBuffer) bool {
        return lhs.hdl == rhs.hdl and
            lhs.offset == rhs.offset and
            lhs.idx_start == rhs.idx_start;
    }
};

pub const TransferBuffer = struct {
    hdl: *sdl.gpu.TransferBuffer,
    offset: u32 = 0,
    size: u32,

    pub fn create(device: *sdl.gpu.Device, size: u32) !TransferBuffer {
        return device.createTransferBuffer(&.{ .usage = .upload, .size = size }) orelse {
            return error.BufferCreateFailure;
        };
    }

    pub fn destroy(self: TransferBuffer, device: *sdl.gpu.Device) void {
        device.destroyTransferBuffer(self.hdl);
    }
};

pub fn StorageBuffer(comptime T: anytype) type {
    return Buffer(T, .{ .graphics_storage_read = true });
}

pub fn DynamicBuffer(T: type) type {
    return struct {
        buffer: Buffer,
        capacity: u32 = 0,

        const Allocator = BufferAllocator(.{ .graphics_storage_read = true });

        pub fn init(device: *sdl.gpu.Device, alloc: *Allocator, count: u32, name: []const u8) !@This() {
            const requested_size = count * @sizeOf(T);
            const buffer = try alloc.alloc(requested_size);

            const hdl = try device.createBuffer(&.{
                .usage = .{ .graphics_storage_read = true },
                .size = @sizeOf(T) * count,
            });

            if (name.len > 0) device.setBufferName(hdl, name.ptr);

            return .{
                .buffer = buffer,
                .capacity = requested_size,
            };
        }

        pub fn resize(self: *@This(), buf_alloc: *Allocator, count: u32) !void {
            const requested_size = count * @sizeOf(T);
            if (requested_size <= self.capacity) {
                self.buffer.size = requested_size;
            } else if (buf_alloc.resize(self.buffer, requested_size)) {
                self.capacity = requested_size;
                self.buffer.size = requested_size;
            } else {
                const buffer = try buf_alloc.alloc(requested_size);
                buf_alloc.destroy(self.buffer);
                self.buffer = buffer;
            }
        }
    };
}

pub const Buffer = struct {
    hdl: *sdl.gpu.Buffer,
    offset: u32 = 0,
    size: u32,
};
