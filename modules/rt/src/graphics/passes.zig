const std = @import("std");
const sdl = @import("sdl");
const Gpu = @import("gpu.zig");
const mt = @import("material.zig");
const mdl = @import("model.zig");

const panic = std.debug.panic;

const Renderable = @import("renderable.zig").Renderable;

pub const Forward = struct {
    device: *sdl.gpu.Device,
    name: [:0]const u8,
    target: sdl.gpu.ColorTargetInfo,
    ds_target: ?sdl.gpu.DepthStencilTargetInfo,
    tex_info: sdl.gpu.TextureCreateInfo,
    ds_tex_info: ?sdl.gpu.TextureCreateInfo,
    ds_tex_scale: f32,

    pub const ForwardOptions = struct {
        name: [:0]const u8,
        clear_color: sdl.pixels.FColor = .{ .r = 0, .g = 0, .b = 0, .a = 1 },

        load_op: sdl.gpu.LoadOp = .clear,
        store_op: sdl.gpu.StoreOp = .store,
        sample_count: sdl.gpu.SampleCount = .@"1",

        dest_format: sdl.gpu.TextureFormat,
        dest_usage: sdl.gpu.TextureUsageFlags,
        dest_tex_width: u16,
        dest_tex_height: u16,
        dest_tex_scale: f32 = 1,

        depth_enabled: bool = false,
        stencil_enabled: bool = false,
    };

    pub fn init(device: *sdl.gpu.Device, options: ForwardOptions) Forward {
        const w: f32 = @floatFromInt(options.dest_tex_width);
        const h: f32 = @floatFromInt(options.dest_tex_height);
        const width: u32 = @intFromFloat(w * options.dest_tex_scale);
        const height: u32 = @intFromFloat(h * options.dest_tex_scale);

        const tex_info = sdl.gpu.TextureCreateInfo{
            .type = .@"2d",
            .format = options.dest_format,
            .usage = options.dest_usage,
            .width = width,
            .height = height,
            .layer_count_or_depth = 1,
            .num_levels = 1,
            .sample_count = options.sample_count,
        };

        const dest_tex = device.createTexture(&tex_info) catch panic("could not create texture", .{});
        device.setTextureName(dest_tex, options.name.ptr);

        const target: sdl.gpu.ColorTargetInfo = .{
            .texture = dest_tex,
            .clear_color = options.clear_color,
            .load_op = options.load_op,
            .store_op = options.store_op,
            .cycle = true,
        };

        var ds_tex_info: sdl.gpu.TextureCreateInfo = undefined;
        const depth_stencil_target: ?sdl.gpu.DepthStencilTargetInfo = blk: {
            if (!options.depth_enabled and !options.stencil_enabled) {
                break :blk null;
            } else {
                ds_tex_info = .{
                    .type = .@"2d",
                    .usage = .{ .depth_stencil_target = true },
                    .format = if (options.stencil_enabled) .d32_float_s8_uint else .d32_float,
                    .width = width,
                    .height = height,
                    .layer_count_or_depth = 1,
                    .num_levels = 1,
                    .sample_count = options.sample_count,
                    .props = 0,
                };

                const depth_tex = device.createTexture(&ds_tex_info) catch panic("could not create texture", .{});
                device.setTextureName(depth_tex, options.name.ptr);

                break :blk .{
                    .clear_depth = 1,
                    .clear_stencil = if (options.stencil_enabled) 1 else 0,
                    .load_op = .clear,
                    .store_op = .store,
                    .stencil_load_op = .clear,
                    .stencil_store_op = .store,
                    .texture = depth_tex,
                    .cycle = true,
                };
            }
        };

        return .{
            .device = device,
            .name = options.name,
            .target = target,
            .tex_info = tex_info,
            .ds_tex_info = ds_tex_info,
            .ds_target = depth_stencil_target,
            .ds_tex_scale = options.dest_tex_scale,
        };
    }

    pub fn deinit(self: Forward) void {
        self.device.releaseTexture(self.texture());
        if (self.depthStencilTexture()) |dst| self.device.releaseTexture(dst);
    }

    pub fn targets(self: *const Forward) Gpu.PassTargets {
        return .{
            .color = (&self.target)[0..1],
            .depth = if (self.ds_target != null) &(self.ds_target.?) else null,
        };
    }

    pub fn resize(self: *Forward, w: u32, h: u32) void {
        const fw: f32 = @floatFromInt(w);
        const fh: f32 = @floatFromInt(h);
        self.tex_info.width = @intFromFloat(fw * self.ds_tex_scale);
        self.tex_info.height = @intFromFloat(fh * self.ds_tex_scale);

        if (self.ds_tex_info) |*info| {
            info.width = self.tex_info.width;
            info.height = self.tex_info.height;
        }

        self.device.releaseTexture(self.texture());
        self.device.releaseTexture(self.depthStencilTexture());

        self.target.texture = self.device.createTexture(&self.tex_info) catch @panic("error creating texture");
        self.device.setTextureName(self.target.texture, self.name.ptr);
        if (self.ds_target) |*target| {
            target.texture = self.device.createTexture(&self.ds_tex_info.?) catch @panic("error creating texture");
            self.device.setTextureName(target.texture, self.name.ptr);
        }
    }

    pub fn texture(self: Forward) *sdl.gpu.Texture {
        return self.target.texture;
    }
    pub fn depthStencilTexture(self: Forward) ?*sdl.gpu.Texture {
        return (self.ds_target orelse return null).texture;
    }
};

/// Final render to offscreen triangle
pub const BlitPass = struct {
    device: *sdl.gpu.Device,
    quad: Renderable,
    target: sdl.gpu.ColorTargetInfo,

    pub fn init(gpu: *Gpu, device: *sdl.gpu.Device) BlitPass {
        const Verts = extern struct {
            v: [12]f32,
            i: [3]u32,
        };

        // Triangle that will be clipped
        const verts = Verts{ .v = .{
            -3, -1, -1, 1,
            1,  3,  1,  -1,
            1,  -1, 1,  1,
        }, .i = .{ 0, 1, 2 } };

        const quad_buffer = device.createBuffer(&.{
            .size = @sizeOf(Verts),
            .usage = .{ .vertex = true, .index = true },
        }) catch panic("error creating buffer", .{});

        try gpu.uploadToBuffer(quad_buffer, 0, &std.mem.toBytes(verts));

        return .{ .device = device, .quad = .{
            .mesh = .{
                .buffer = .{
                    .hdl = quad_buffer,
                    .size = @sizeOf(Verts),
                    .idx_start = @sizeOf(f32) * 12,
                },
                .material = undefined,
            },
        }, .target = .{
            .texture = undefined,
            .load_op = .clear,
            .store_op = .store,
            .cycle = false,
        } };
    }

    pub fn deinit(self: BlitPass) void {
        self.device.releaseBuffer(self.quad);
    }

    pub fn targets(self: *BlitPass, tex: *sdl.gpu.Texture) Gpu.PassTargets {
        self.target = .{
            .texture = tex,
            .load_op = .clear,
            .store_op = .store,
            .cycle = false,
        };

        return .{
            .color = (&self.target)[0..1],
            .depth = null,
        };
    }
};
