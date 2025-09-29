const std = @import("std");
const hy = @import("hyoga");
const sdl = @import("sdl");
const Gpu = @import("gpu.zig");
const StringTable = @import("../strintern.zig");
const gfx = @import("root.zig");
const mt = @import("material.zig");
const mdl = @import("model.zig");
const buf = @import("buffer.zig");
const rbl = @import("renderable.zig");
const tracy = @import("tracy");

const hym = hy.math;
const Renderable = rbl.Renderable;

const panic = std.debug.panic;

/// Render objects onto a texture
pub const Forward = struct {
    device: *sdl.gpu.Device,
    name: StringTable.Index,
    gpu: *Gpu,
    target: sdl.gpu.ColorTargetInfo,
    tex_info: sdl.gpu.TextureCreateInfo,
    tex_scale: f32,
    ds_target: ?sdl.gpu.DepthStencilTargetInfo,
    ds_tex_info: ?sdl.gpu.TextureCreateInfo,
    blit_material: gfx.MaterialHandle = .none,
    transforms_buffer: buf.DynamicBuffer(hym.Mat4),
    match_window_size: bool,

    // <0 is reserved for builtins
    order: i32,

    render_list: rbl.RenderList,

    pub const ForwardOptions = struct {
        gpu: *Gpu,
        name: StringTable.Index,
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
        order: i32,
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
        const name = options.gpu.string_table.lookupZ(options.name);
        device.setTextureName(dest_tex, name.ptr);

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
                device.setTextureName(depth_tex, name.ptr);

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
            .render_list = .{},
            .target = target,
            .tex_info = tex_info,
            .ds_tex_info = ds_tex_info,
            .ds_target = depth_stencil_target,
            .tex_scale = options.dest_tex_scale,
            .transforms_buffer = buf.DynamicBuffer(hym.Mat4).init(options.gpu.device, &options.gpu.storage_allocator, 1024 * 128, "Object Mats") catch unreachable,
            .match_window_size = options.match_window_size,
            .blit_material = options.blit_material,
            .order = options.order,
        };
    }

    pub fn deinit(self: *Forward) void {
        if (self.order == std.math.minInt(u32)) return;
        self.gpu.storage_allocator.destroy(self.transforms_buffer.buffer);
        self.device.releaseTexture(self.texture());
        if (self.depthStencilTexture()) |dst| self.device.releaseTexture(dst);
        self.render_list.deinit();
        self.order = std.math.minInt(i32);
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

        const name = self.gpu.string_table.lookupZ(self.name);
        self.target.texture = self.device.createTexture(&self.tex_info) catch @panic("error creating texture");
        self.device.setTextureName(self.target.texture, name.ptr);
        if (self.ds_target) |*target| {
            target.texture = self.device.createTexture(&self.ds_tex_info.?) catch @panic("error creating texture");
            self.device.setTextureName(target.texture, name.ptr);
        }
    }

    pub fn texture(self: Forward) *sdl.gpu.Texture {
        return self.target.texture;
    }

    pub fn depthStencilTexture(self: Forward) ?*sdl.gpu.Texture {
        return (self.ds_target orelse return null).texture;
    }

    pub fn render(self: *Forward, cmd: *sdl.gpu.CommandBuffer) !void {
        const zone_pass_render = tracy.initZone(@src(), .{ .name = "gfx.pass.render" });
        defer zone_pass_render.deinit();

        if (self.render_list.instances.num_items == 0) {
            return;
        }

        const gpu = self.gpu;

        var count: u32 = 0;
        {
            var all_instances = self.render_list.instances.iterator();
            while (all_instances.nextPtr()) |instance| {
                count += @intCast(instance.transforms.array.items.len);
            }
        }

        try self.transforms_buffer.resize(&gpu.storage_allocator, count);

        {
            const buf_transfer = self.device.createTransferBuffer(&.{
                .usage = .upload,
                .size = self.transforms_buffer.buffer.size,
            }).?;

            defer self.device.releaseTransferBuffer(buf_transfer);
            var map: [*]u8 = @ptrCast(@alignCast(self.device.mapTransferBuffer(buf_transfer, false).?));

            var all_instances = self.render_list.instances.iterator();
            while (all_instances.next()) |instance| {
                if (instance.transforms.array.items.len == 0) continue;
                const data = std.mem.sliceAsBytes(instance.transforms.array.items);
                @memcpy(map, data);
                map += data.len;
            }

            const copy_cmd = self.device.acquireCommandBuffer().?;
            defer _ = copy_cmd.submit();

            const copy_pass = cmd.beginCopyPass().?;
            defer copy_pass.end();

            const buf_location = sdl.gpu.TransferBufferLocation{
                .transfer_buffer = buf_transfer,
                .offset = 0,
            };

            const dst_region = sdl.gpu.BufferRegion{
                .buffer = self.transforms_buffer.buffer.hdl,
                .offset = 0,
                .size = self.transforms_buffer.buffer.size,
            };

            copy_pass.uploadToBuffer(&buf_location, &dst_region, false);
        }

        const color = (&self.target)[0..1];
        const depth = if (self.ds_target != null) &self.ds_target.? else null;

        const pass = cmd.beginRenderPass(color.ptr, @intCast(color.len), depth).?;
        defer pass.end();
        pass.setStencilReference(1);

        var last_pipeline: ?*sdl.gpu.GraphicsPipeline = null;

        var total_instances_rendered: u32 = 0;

        {
            var all_instances = self.render_list.instances.iterator();
            while (all_instances.next()) |instance| {
                if (instance.transforms.array.items.len == 0) continue;
                try gpu.uniforms.put(gpu.gpa, gpu.ids.all_renderables, .{ .buffer = self.transforms_buffer.buffer.hdl });
                const mesh = instance.mesh;
                const num_instances: u32 = @intCast(instance.transforms.array.items.len);
                try gpu.draw(.{
                    .cmd = cmd,
                    .pass = pass,
                    .num_first_instance = total_instances_rendered,
                    .num_instances = num_instances,
                    .mesh = mesh,
                    .last_pipeline = &last_pipeline,
                });
                total_instances_rendered += num_instances;
            }
        }
    }

    pub const BlitOptions = struct {
        cmd: *sdl.gpu.CommandBuffer,
        target: *sdl.gpu.Texture,
        load_op: sdl.gpu.LoadOp,
        clear_color: sdl.FColor,
    };

    pub fn blit(self: Forward, opts: BlitOptions) !void {
        const cmd = opts.cmd;

        const fp_color: sdl.gpu.ColorTargetInfo = .{
            .texture = opts.target,
            .load_op = opts.load_op,
            .store_op = .store,
            .clear_color = opts.clear_color,
            .cycle = false,
        };

        const rp = cmd.beginRenderPass(&.{fp_color}, 1, null) orelse {
            std.log.err("error begin render pass {s}", .{sdl.getError()});
            return error.SdlError;
        };
        defer rp.end();

        if (self.blit_material.valid()) {
            const material = self.gpu.materials.get(self.blit_material).?;
            rp.bindGraphicsPipeline(material.pipeline);
            self.gpu.materialBind(cmd, rp, material);
        } else {
            const pipeline = self.gpu.materials.templates.get(.screen_blit).pipeline;
            rp.bindGraphicsPipeline(pipeline);

            const binding: sdl.gpu.TextureSamplerBinding = .{
                .sampler = self.gpu.default_assets.sampler,
                .texture = self.texture(),
            };

            rp.bindFragmentSamplers(0, &.{binding}, 1);
        }

        rp.drawPrimitives(3, 1, 0, 0);
    }
};
