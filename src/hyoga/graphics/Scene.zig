const std = @import("std");
const sdl = @import("sdl");
const hym = @import("hyoga-math");
const gpu = @import("gpu.zig");
const Mat4 = hym.Mat4;
const Vec3 = hym.Vec3;

pub const Scene = extern struct {
    // Global data, changes rarely
    viewport_size_x: u16,
    viewport_size_y: u16,

    // Global data, changes every frame
    view_proj: Mat4,
    light_dir: Vec3,
    start_renderables: [1]Mat4 // Uploaded to GPU as array, not to be used directly.
};

pub const SceneBuffer = struct {
    device: *sdl.gpu.Device,
    buffer: gpu.Buffer = .{ .size = 0, .hdl = undefined },
    buf_transfer: gpu.Buffer = .{ .size = 0, .hdl_transfer = null },

    pub fn update(self: *SceneBuffer, scene: Scene, renderables: []const Mat4) void {
        const up_size: u32 = @intCast(@sizeOf(Scene) + (renderables.len - 1) * @sizeOf(Mat4));
        self.growBuffers(up_size);

        // Set up copy
        const map = self.device.mapTransferBuffer(self.buf_transfer.hdl_transfer.?, false) orelse {
            std.log.err("Could not map transfer buffer: {s}", .{sdl.getError()});
            return;
        };
        const scene_map: *Scene = @ptrCast(@alignCast(map));
        defer self.device.unmapTransferBuffer(self.buf_transfer.hdl_transfer.?);

        scene_map.* = scene;
        @memcpy(&scene_map.start_renderables, renderables);

        const cmd = self.device.acquireCommandBuffer() orelse {
            std.log.err("Could not acquire command buffer: {s}", .{sdl.getError()});
            return;
        };
        defer _ = cmd.submit();

        const copy_pass = cmd.beginCopyPass() orelse {
            std.log.err("Could not acquire copy_pass: {s}", .{sdl.getError()});
            return;
        };
        defer copy_pass.end();

        const buf_src = sdl.gpu.TransferBufferLocation {
            .transfer_buffer = self.buf_transfer.hdl_transfer,
            .offset = 0,
        };

        const buf_dst = sdl.gpu.BufferRegion {
            .buffer = self.buffer.hdl,
            .offset = 0,
            .size = up_size,
        };

        copy_pass.uploadToBuffer(&buf_src, &buf_dst, false);
    }

    fn growBuffers(self: *SceneBuffer, min_size: u32) void {
        if (self.buf_transfer.size < min_size) {
            if (self.buf_transfer.hdl_transfer) |hdl| {
                self.device.releaseTransferBuffer(hdl);
            }

            const new_size: u32 = if (self.buf_transfer.size > 0) @max(self.buf_transfer.size * 2, min_size) else min_size;

            const new_transfer_buf = self.device.createTransferBuffer(&.{
                .usage = .upload,
                .size = new_size,
            }) orelse {
                std.debug.panic("could not allocate transfer buffer on gpu", .{});
            };

            self.buf_transfer = gpu.Buffer {
                .hdl_transfer = new_transfer_buf,
                .size = new_size,
            };
        }

        if (self.buffer.size < min_size) {
            if (self.buffer.size > 0) {
                self.device.releaseBuffer(self.buffer.hdl);
            }
            const new_buf = self.device.createBuffer(&.{
                .usage = .{ .graphics_storage_read = true, },
                .size = min_size,
            }) orelse {
                std.debug.panic("could not allocate for storage buffer", .{});
            };


            self.buffer = gpu.Buffer {
                .hdl = new_buf,
                .size = min_size,
            };
        }
    }
};
