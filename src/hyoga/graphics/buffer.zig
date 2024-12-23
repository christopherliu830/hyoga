const std = @import("std");
const sdl = @import("sdl");

pub const VertexIndexBuffer = struct {
    hdl: *sdl.gpu.Buffer,
    size: u32,
    offset: u32 = 0,
    idx_start: u32 = std.math.maxInt(u32),

    pub fn create(device: *sdl.gpu.Device, vtx_size: u32, idx_size: u32) VertexIndexBuffer {
        const hdl = device.createBuffer(&.{
            .usage = .{ .index = true, .vertex = true },
            .size = vtx_size + idx_size,
        });

        return .{
            .hdl = hdl,
            .size = vtx_size + idx_size,
            .idx_start = vtx_size,
        };
    }

    pub inline fn idxCount(self: VertexIndexBuffer) u32 {
        return (self.size - self.idx_start) / @sizeOf(u32);
    }
};

pub const TransferBuffer = struct {
    hdl: *sdl.gpu.TransferBuffer,
    offset: u32 = 0,
    size: u32,

    pub fn create(device: *sdl.gpu.Device, size: u32) !TransferBuffer {
        return device.createTransferBuffer(&.{
            .usage = .upload,
            .size = size
        }) orelse {
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
            const hdl = device.createBuffer(&.{
                .usage = .{ .graphics_storage_read = true },
                .size = @sizeOf(T) * count,
            }) orelse {
                return error.BufferCreateFailure;
            };

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

pub fn Buffer(comptime T: anytype, usage: sdl.gpu.BufferUsageFlags) type {
    return struct {
        hdl: *sdl.gpu.Buffer,
        offset: u32 = 0,
        size: u32,

        pub fn init(device: *sdl.gpu.Device, name: []const u8) !@This() {
            const hdl = device.createBuffer(&.{
                .usage = usage,
                .size = @sizeOf(T),
            }) orelse {
                return error.BufferCreateFailure;
            };

            if (name.len > 0) device.setBufferName(hdl, name.ptr);

            return .{
                .hdl = hdl,
                .size = @sizeOf(T),
            };
        }

        pub fn destroy(self: @This(), device: *sdl.gpu.Device) void {
            device.releaseBuffer(self.hdl);
        }
    };
}
