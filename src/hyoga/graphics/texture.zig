const std = @import("std");
const sdl = @import("sdl");
const stbi = @import("stb_image");
const ai = @import("assimp");
const ld = @import("loader.zig");
const hya = @import("hyoga-arena");

const TextureId = struct {
    handle: ?[]const u8 = null,
    target: ?*sdl.gpu.Texture = null,
};

pub const TextureSet = std.EnumMap(TextureType, TextureId);

pub const TextureType = enum {
    diffuse,
    specular,
    height,
    normal,
};

pub const Textures = struct {
    device: *sdl.gpu.Device,
    queue: ld.Queue(TextureId),
    allocator: std.mem.Allocator,
    textures: std.StringHashMap(*sdl.gpu.Texture),

    pub fn init(self: *@This(), device: *sdl.gpu.Device, allocator: std.mem.Allocator) void {
        self.device = device;
        self.queue = .{};
        self.allocator = allocator;
        self.textures = std.StringHashMap(*sdl.gpu.Texture).init(allocator);
    }

    pub fn deinit(self: *@This()) void {
        self.flushQueue() catch std.debug.panic("Could not flush queue", .{});
        var it = self.textures.iterator();
        while (it.next()) |entry| {
            const key = entry.key_ptr;
            const val = entry.value_ptr;
            self.allocator.free(key.*);
            self.device.releaseTexture(val.*);
        }
        self.textures.deinit();
    }

    pub fn getTexture(self: *@This(), id: []const u8) !?*sdl.gpu.Texture {
        try self.flushQueue();
        return self.textures.get(id);
    }

    pub fn read(self: *@This(), path: []const u8) !void {
        const owned_path = try self.allocator.dupe(u8, path);
        try ld.run(&self.queue, readTexture, .{ self.device, owned_path });
    }

    pub fn flushQueue(self: *@This()) !void {
        while (self.queue.pop()) |entry| {
            try self.textures.put(entry.handle.?, entry.target.?);
        }
    }

    fn readTexture(queue: *ld.Queue(TextureId), device: *sdl.gpu.Device, path: []const u8, allocator: std.mem.Allocator) void {
        const pathZ = allocator.dupeZ(u8, path) catch "out of memory";
        defer allocator.free(pathZ);

        var c_w: c_int = 0;
        var c_h: c_int = 0;
        var c_d: c_int = 0;
        const tex_pixels = stbi.stbi_load(pathZ.ptr, &c_w, &c_h, &c_d, 4);
        defer stbi.stbi_image_free(tex_pixels);
        const w: u32 = @intCast(c_w);
        const h: u32 = @intCast(c_h);
        const d: u32 = 4;

        const texture_info = sdl.gpu.TextureCreateInfo{ .type = .@"2d", .format = .r8g8b8a8_unorm, .usage = .{ .sampler = true }, .height = h, .width = w, .layer_count_or_depth = 1, .num_levels = 1, .sample_count = .@"1", .props = 0 };

        const tex = device.createTexture(&texture_info) orelse @panic("could not create texture");
        errdefer device.releaseTexture(tex);

        const data = tex_pixels[0 .. w * h * d];

        const buf_transfer = device.createTransferBuffer(&.{ .size = @intCast(data.len), .usage = .upload }).?;

        defer device.releaseTransferBuffer(buf_transfer);

        const ptr_transfer: [*]u8 = @ptrCast(@alignCast(device.mapTransferBuffer(buf_transfer, false).?));
        @memcpy(ptr_transfer, data);
        device.unmapTransferBuffer(buf_transfer);

        // copy to transfer buffer
        const cmd = device.acquireCommandBuffer().?;
        const copy_pass = cmd.beginCopyPass().?;

        const buf_src = sdl.gpu.TextureTransferInfo{
            .transfer_buffer = buf_transfer,
            .offset = 0,
            .pixels_per_row = w,
            .rows_per_layer = h,
        };

        const buf_dst = sdl.gpu.TextureRegion{
            .texture = tex,
            .w = w,
            .h = h,
            .d = 1,
        };

        copy_pass.uploadToTexture(&buf_src, &buf_dst, false);
        copy_pass.end();

        if (cmd.submitAndAcquireFence()) |fence| {

            if (!device.waitForFences(true, &[_]*sdl.gpu.Fence{fence}, 1)) @panic("Could not wait for fence");
            queue.push(.{
                .handle = path,
                .target = tex,
            }) catch @panic("out of memory");

            device.releaseFence(fence);
        } else @panic("Could not submit command buffer");

    }
};

pub const TextureMemory = struct { w: u32, h: u32, d: u32 = 1, data: []const u8, format: sdl.gpu.TextureFormat = .r8g8b8a8_unorm };

pub const tex_to_hyoga_type = std.EnumMap(ai.TextureType, TextureType).init(.{
    .diffuse = .diffuse,
    .specular = .specular,
    .height = .height,
    .normals = .normal,
});
