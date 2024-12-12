const std = @import("std");
const sdl = @import("sdl");
const stbi = @import("stb_image");
const ai = @import("assimp");
const ld = @import("loader.zig");
const hya = @import("hyoga-arena");
const sym = @import("../Symbol.zig");

pub const Handle = sym.ID;

const TextureId = struct {
    handle: ?sym.ID = null,
    target: ?*sdl.gpu.Texture = null,
};

const TextureLoadJob = struct {
    path: [:0]const u8,
    target: *sdl.gpu.Texture,
};

pub const TextureSet = std.EnumMap(TextureType, TextureId);

pub const TextureType = enum {
    diffuse,
    specular,
    height,
    normal,
};

pub const tex_to_hyoga_type = std.EnumMap(ai.TextureType, TextureType).init(.{
    .diffuse = .diffuse,
    .specular = .specular,
    .height = .height,
    .normals = .normal,
});

pub const Textures = struct {
    allocator: std.mem.Allocator,
    device: *sdl.gpu.Device,
    queue: ld.Queue(TextureLoadJob),
    textures: std.AutoHashMapUnmanaged(sym.ID, *sdl.gpu.Texture) = .{},
    symbol: *sym,

    pub fn create(device: *sdl.gpu.Device, symbol: *sym, allocator: std.mem.Allocator) Textures {
        var t: Textures = undefined;
        t.allocator = allocator;
        t.queue.init(allocator);
        t.device = device;
        t.textures = .{};
        t.symbol = symbol;
        return t;
    }

    pub fn deinit(self: *@This()) void {
        self.flushQueue() catch std.debug.panic("Could not flush queue", .{});
        var it = self.textures.valueIterator();
        while (it.next()) |entry| {
            self.device.releaseTexture(entry.*);
        }
        self.textures.deinit(self.allocator);
    }

    pub fn get(self: *@This(), id: sym.ID) !?*sdl.gpu.Texture {
        try self.flushQueue();
        return self.textures.get(id);
    }

    pub fn read(self: *@This(), path: [:0]const u8) !Handle {
        const copy = try self.allocator.dupeZ(u8, path);
        try ld.run(&self.queue, readTexture, .{ self.device, copy });
        return self.symbol.from(path);
    }

    pub fn flushQueue(self: *@This()) !void {
        while (self.queue.pop()) |entry| {
            const tex_symbol = try self.symbol.from(entry.path);
            self.allocator.free(entry.path);
            try self.textures.put(self.allocator,tex_symbol, entry.target);
        }
    }

    fn readTexture(queue: *ld.Queue(TextureLoadJob), device: *sdl.gpu.Device, pathZ: [:0]const u8) void {

        var c_w: c_int = 0;
        var c_h: c_int = 0;
        var c_d: c_int = 0;
        const tex_pixels = stbi.c.stbi_load(pathZ.ptr, &c_w, &c_h, &c_d, 4);
        defer stbi.c.stbi_image_free(tex_pixels);
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
                .path = pathZ,
                .target = tex,
            }) catch @panic("out of memory");

            device.releaseFence(fence);
        } else @panic("Could not submit command buffer");

    }
};

