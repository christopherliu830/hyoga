const std = @import("std");
const hy = @import("hyoga-lib");
const sdl = @import("sdl");

const panic = std.debug.panic;

pub const BufferAllocator = struct {
    device: *sdl.gpu.Device,
    usage: sdl.gpu.BufferUsageFlags,
    buffer_list: std.SinglyLinkedList(Buf) = .{},
    node_allocator: std.mem.Allocator,
    end_index: u32 = 0,

    pub const Buf = struct {
        hdl: *sdl.gpu.Buffer,
        size: u32,
    };

    const BufNode = std.SinglyLinkedList(Buf).Node;

    pub fn init(device: *sdl.gpu.Device, usage: sdl.gpu.BufferUsageFlags, allocator: std.mem.Allocator) BufferAllocator {
        return .{
            .device = device,
            .usage = usage,
            .node_allocator = allocator,
        };
    }

    pub fn deinit(self: *BufferAllocator) void {
        var maybe_node = self.buffer_list.popFirst();
        while (maybe_node) |node| : (maybe_node = self.buffer_list.popFirst()) {
            const buf = node.data;
            self.device.releaseBuffer(buf.hdl);
            self.node_allocator.destroy(node);
        }
    }

    fn createNode(self: *BufferAllocator, prev_len: u32, min_size: u32) sdl.gpu.Error!*BufNode {
        const len = (prev_len + min_size) + (prev_len + min_size) / 2;
        const buf = try self.device.createBuffer(&.{ .size = len, .usage = self.usage });
        self.device.setBufferName(buf, "Buffer Allocator Buffer");
        const node = self.node_allocator.create(BufNode) catch hy.err.oom();
        node.* = .{ .data = .{
            .hdl = buf,
            .size = len,
        } };
        self.buffer_list.prepend(node);
        self.end_index = 0;
        return node;
    }

    pub fn alloc(self: *BufferAllocator, n: u32) sdl.gpu.Error!Buffer {
        var cur_node = if (self.buffer_list.first) |first_node|
            first_node
        else
            try self.createNode(0, n);
        while (true) {
            const offset = self.end_index;
            const end_offset = offset + n;

            if (end_offset <= cur_node.data.size) {
                self.end_index = end_offset;
                return .{
                    .hdl = cur_node.data.hdl,
                    .offset = offset,
                    .size = n,
                };
            }

            cur_node = try self.createNode(cur_node.data.size, n);
        }
    }

    fn resize() void {}

    fn free() void {}
};

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

pub fn DynamicBuffer(comptime T: anytype) type {
    return struct {
        hdl: *sdl.gpu.Buffer,
        offset: u32 = 0,
        size: u32,

        pub fn init(device: *sdl.gpu.Device, count: u32, name: []const u8) !@This() {
            const hdl = try device.createBuffer(&.{
                .usage = .{ .graphics_storage_read = true },
                .size = @sizeOf(T) * count,
            });

            if (name.len > 0) device.setBufferName(hdl, name.ptr);

            return .{
                .hdl = hdl,
                .size = @sizeOf(T) * count,
            };
        }

        pub fn destroy(self: @This(), device: *sdl.gpu.Device) void {
            device.releaseBuffer(self.hdl);
        }

        pub fn grow(self: *@This(), device: *sdl.gpu.Device, count: u32) void {
            self.destroy(device);
            self.* = init(device, count);
        }
    };
}

pub const Buffer = struct {
    hdl: *sdl.gpu.Buffer,
    offset: u32 = 0,
    size: u32,
};
