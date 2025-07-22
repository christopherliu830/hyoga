const std = @import("std");
const hy = @import("hyoga-lib");
const sdl = @import("sdl");
const Gpu = @import("gpu.zig");
const gfx = @import("root.zig");
const mt = @import("material.zig");
const mdl = @import("model.zig");
const buf = @import("buffer.zig");
const rbl = @import("renderable.zig");

const hym = hy.math;
const Renderable = rbl.Renderable;

const panic = std.debug.panic;

/// Render objects onto a texture
pub const Forward = struct {
    device: *sdl.gpu.Device,
    name: [:0]const u8,
    gpu: *Gpu,
    target: sdl.gpu.ColorTargetInfo,
    tex_info: sdl.gpu.TextureCreateInfo,
    tex_scale: f32,
    ds_target: ?sdl.gpu.DepthStencilTargetInfo,
    ds_tex_info: ?sdl.gpu.TextureCreateInfo,
    blit_material: gfx.MaterialHandle = .none,
    transforms_buffer: buf.DynamicBuffer(hym.Mat4),
    match_window_size: bool,

    items: rbl.RenderList,

    pub const ForwardOptions = struct {
        gpu: *Gpu,
        name: [:0]const u8,
        clear_color: sdl.pixels.FColor = .{ .r = 0, .g = 0, .b = 0, .a = 0 },

        load_op: sdl.gpu.LoadOp = .clear,
        depth_load_op: sdl.gpu.LoadOp = .clear,
        store_op: sdl.gpu.StoreOp = .store,
        sample_count: sdl.gpu.SampleCount = .@"1",

        dest_format: sdl.gpu.TextureFormat,
        dest_usage: sdl.gpu.TextureUsageFlags,
        dest_tex_width: u16,
        dest_tex_height: u16,
        dest_tex_scale: f32 = 1,

        depth_enabled: bool = false,
        stencil_enabled: bool = false,
        match_window_size: bool = true,

        blit_material: gfx.MaterialHandle = .none,
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
            .cycle = options.load_op != .load,
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
                    .load_op = options.depth_load_op,
                    .store_op = .store,
                    .stencil_load_op = .clear,
                    .stencil_store_op = .store,
                    .texture = depth_tex,
                    .cycle = options.depth_load_op != .load,
                };
            }
        };

        return .{
            .device = device,
            .name = options.name,
            .gpu = options.gpu,
            .items = .init(options.gpu),
            .target = target,
            .tex_info = tex_info,
            .ds_tex_info = ds_tex_info,
            .ds_target = depth_stencil_target,
            .tex_scale = options.dest_tex_scale,
            .transforms_buffer = buf.DynamicBuffer(hym.Mat4).init(options.gpu.device, 1024 * 16, "Object Mats") catch unreachable,
            .match_window_size = options.match_window_size,
            .blit_material = options.blit_material,
        };
    }

    pub fn deinit(self: *Forward) void {
        self.device.releaseTexture(self.texture());
        if (self.depthStencilTexture()) |dst| self.device.releaseTexture(dst);
        self.device.releaseBuffer(self.transforms_buffer.hdl);
        self.items.deinit();
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
        self.tex_info.width = @intFromFloat(fw * self.tex_scale);
        self.tex_info.height = @intFromFloat(fh * self.tex_scale);

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

    pub fn render(self: *Forward, cmd: *sdl.gpu.CommandBuffer) !void {
        if (self.items.items.num_items == 0) {
            return;
        }

        const gpu = self.gpu;
        const arena = gpu.arena.allocator();

        const render_pack = try self.items.packAll(arena);
        const transforms = render_pack.transforms;
        try gpu.uploadToBuffer(self.transforms_buffer.hdl, 0, std.mem.sliceAsBytes(transforms));
        try gpu.uniforms.put(gpu.gpa, gpu.ids.all_renderables, .{ .buffer = self.transforms_buffer.hdl });

        const color = (&self.target)[0..1];
        const depth = if (self.ds_target != null) &self.ds_target.? else null;

        const pass = cmd.beginRenderPass(color.ptr, @intCast(color.len), depth).?;
        defer pass.end();
        pass.setStencilReference(1);

        var last_pipeline: ?*sdl.gpu.GraphicsPipeline = null;

        var total_instances_rendered: u32 = 0;

        for (0..render_pack.len) |i| {
            const mesh = render_pack.meshes[i];
            try gpu.draw(.{
                .cmd = cmd,
                .pass = pass,
                .num_first_instance = total_instances_rendered,
                .num_instances = render_pack.instance_counts[i],
                .mesh = mesh,
                .last_pipeline = &last_pipeline,
            });
            total_instances_rendered += render_pack.instance_counts[i];
        }
    }
};
