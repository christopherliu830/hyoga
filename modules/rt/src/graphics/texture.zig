const std = @import("std");
const hy = @import("hyoga-lib");
const sdl = @import("sdl");
const stbi = @import("stb_image");
const ai = @import("assimp");
const Loader = @import("loader.zig");
const Strint = @import("../strintern.zig");

pub const Handle = Strint.ID;

const TextureId = struct {
    handle: ?Handle = null,
    target: ?*sdl.gpu.Texture = null,
};

const TextureLoadJob = struct {
    path: [:0]const u8,
    target: *sdl.gpu.Texture,
};

pub const TextureArray = [std.enums.directEnumArrayLen(TextureType, 0)]Handle;

pub const TextureSet = std.EnumMap(TextureType, TextureId);

pub const TextureType = enum(u32) {
    diffuse,
    specular,
    height,
    normal,
    mask,

    comptime {
        hy.meta.assertMatches(TextureType, hy.gfx.TextureType);
    }
};

pub const tex_to_hyoga_type = std.EnumMap(ai.TextureType, TextureType).init(.{
    .diffuse = .diffuse,
    .specular = .specular,
    .height = .height,
    .normals = .normal,
});

pub const Textures = struct {
    tsa: std.heap.ThreadSafeAllocator,
    device: *sdl.gpu.Device,
    loader: *Loader,
    queue: Loader.Queue(TextureLoadJob),
    textures: std.AutoHashMapUnmanaged(Strint.ID, ?*sdl.gpu.Texture) = .{},
    strint: *Strint,
    image_loader: stbi,

    pub fn init(t: *Textures, device: *sdl.gpu.Device, loader: *Loader, strint: *Strint, allocator: std.mem.Allocator) void {
        t.tsa = .{ .child_allocator = allocator };
        t.queue.init(t.tsa);
        t.device = device;
        t.textures = .{};
        t.strint = strint;
        t.loader = loader;
        t.image_loader = stbi.init(t.tsa.allocator());
    }

    pub fn deinit(self: *@This()) void {
        const allocator = self.tsa.allocator();
        self.image_loader.deinit();
        self.flushQueue() catch std.debug.panic("Could not flush queue", .{});
        var it = self.textures.valueIterator();
        while (it.next()) |entry| {
            self.device.releaseTexture(entry.*);
        }
        self.queue.deinit();
        self.textures.deinit(allocator);
    }

    pub fn get(self: *@This(), id: Handle) !?*sdl.gpu.Texture {
        try self.flushQueue();
        return self.textures.get(id) orelse null;
    }

    pub fn destroy(self: *@This(), id: Handle) void {
        if (self.textures.contains(id)) {
            const maybe_tex = self.textures.get(id).?;
            if (maybe_tex) |tex| {
                self.device.releaseTexture(tex);
            } else {
                std.log.warn("Texture {s} removed before it was finished loading, was this intentional?", .{self.strint.asString(id)});
                // When the job finishes the texture will be released.
            }
            _ = self.textures.remove(id);
        } else {
            std.debug.panic("Destroy of invalid texture {s}", .{self.strint.asString(id)});
        }
    }

    pub fn read(self: *@This(), path: [:0]const u8) !Handle {
        const allocator = self.tsa.allocator();
        const hdl = try self.strint.from(path);

        // Cache check
        if (try self.get(hdl)) |_| {
            return hdl;
        }

        const copy = try allocator.dupeZ(u8, path);
        try self.loader.run(&self.queue, readTexture, .{ self, copy });
        try self.textures.put(allocator, hdl, null);
        return hdl;
    }

    pub fn flushQueue(self: *@This()) !void {
        const allocator = self.tsa.allocator();
        while (self.queue.pop()) |entry| {
            const tex_strint = try self.strint.from(entry.path);
            defer allocator.free(entry.path);

            const maybe_tex_slot = self.textures.get(tex_strint);

            if (maybe_tex_slot) |tex_slot| {
                if (tex_slot != null) {
                    // Two jobs are loading the same texture and another one finished first,
                    // so release this duplicate.
                    self.device.releaseTexture(entry.target);
                } else {
                    // This job was first to finish reading the texture.
                    try self.textures.put(allocator, tex_strint, entry.target);
                }
            } else {
                std.log.warn("Texture {s} removed before it was finished loading, was this intentional?", .{entry.path});
                self.device.releaseTexture(entry.target);
            }
        }
    }

    fn readTexture(queue: *Loader.Queue(TextureLoadJob), self: *Textures, pathZ: [:0]const u8) void {
        var device = self.device;
        var c_w: c_int = 0;
        var c_h: c_int = 0;
        var c_d: c_int = 0;
        const tex_pixels = stbi.c.stbi_load(pathZ.ptr, &c_w, &c_h, &c_d, 4);
        defer stbi.c.stbi_image_free(tex_pixels);
        const w: u32 = @intCast(c_w);
        const h: u32 = @intCast(c_h);
        const d: u32 = 4;

        if (w == 0 and h == 0) {
            std.debug.panic("texture {s} has width and height as 0", .{pathZ});
        }

        const texture_info = sdl.gpu.TextureCreateInfo{
            .type = .@"2d",
            .format = .r8g8b8a8_unorm,
            .usage = .{ .sampler = true },
            .height = h,
            .width = w,
            .layer_count_or_depth = 1,
            .num_levels = 1,
            .sample_count = .@"1",
            .props = 0,
        };

        const tex = device.createTexture(&texture_info) catch @panic("could not create texture");
        device.setTextureName(tex, pathZ);
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
