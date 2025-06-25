const std = @import("std");
const hy = @import("hyoga-lib");
const hym = hy.math;
const sdl = @import("sdl");
const Gpu = @import("gpu.zig");
const buf = @import("buffer.zig");
const rbl = @import("renderable.zig");
const ttf = @import("sdl_ttf");

const MaterialHandle = Gpu.MaterialHandle;

// An slice into buffer_src
pub const Item =
    union(enum) {
        renderable: struct {
            offset: u32,
            size: u32,
            idx_start: u32,
            material: Gpu.Material,
            transform: hym.Mat4,
        },
        scissor_begin: sdl.Rect,
        scissor_end: void,
    };

pub const Context = struct {
    arena: std.heap.ArenaAllocator,
    buffer_src: std.ArrayListUnmanaged(u8) = .empty,
    buffer_allocator: buf.BufferAllocator,
    items: std.ArrayListUnmanaged(Item) = .empty,
    needs_clear: bool = false,

    pub fn reset(self: *Context) void {
        self.buffer_allocator.reset();
        _ = self.arena.reset(.retain_capacity);
        self.items = .empty;
        self.buffer_src = .empty;
    }

    pub fn deinit(self: *Context) void {
        self.buffer_allocator.deinit();
        _ = self.arena.deinit();
    }

    pub fn draw(
        im: *Context,
        gpu: *Gpu,
        cmd: *sdl.gpu.CommandBuffer,
        render_tex: *sdl.gpu.Texture,
        resolve_tex: *sdl.gpu.Texture,
    ) !bool {
        if (im.items.items.len == 0) {
            if (im.needs_clear) {
                const color: sdl.gpu.ColorTargetInfo = .{
                    .texture = render_tex,
                    .load_op = .clear,
                    .store_op = .resolve,
                    .clear_color = .{},
                    .cycle = false,
                    .resolve_texture = resolve_tex,
                };

                const pass = cmd.beginRenderPass(&.{color}, 1, null).?;
                defer pass.end();

                im.needs_clear = false;
            }
            return false;
        }

        const buffer_allocator = &im.buffer_allocator;
        const alloc_buffer = buffer_allocator.alloc(@intCast(im.buffer_src.items.len)) catch unreachable;
        defer buffer_allocator.destroy(alloc_buffer);
        try gpu.uploadToBuffer(alloc_buffer.hdl, alloc_buffer.offset, im.buffer_src.items);

        // Render UI immediates
        const color: sdl.gpu.ColorTargetInfo = .{
            .texture = render_tex,
            .load_op = .clear,
            .store_op = .resolve,
            .clear_color = .{},
            .cycle = false,
            .resolve_texture = resolve_tex,
        };

        const pass = cmd.beginRenderPass(&.{color}, 1, null).?;
        defer pass.end();
        pass.setStencilReference(1);

        var last_pipeline: ?*sdl.gpu.GraphicsPipeline = null;

        for (im.items.items) |item| {
            switch (item) {
                .renderable => |r| {
                    try gpu.uniforms.put(gpu.gpa, gpu.ids.immediate_mvp, .{ .mat4x4 = @bitCast(r.transform) });
                    try gpu.draw(.{
                        .cmd = cmd,
                        .material = r.material,
                        .pass = pass,
                        .mesh = .{
                            .buffer = .{
                                .hdl = alloc_buffer.hdl,
                                .size = r.size,
                                .offset = r.offset,
                                .idx_start = r.idx_start,
                            },
                            .material = .invalid,
                        },
                        .last_pipeline = &last_pipeline,
                    });
                },
                .scissor_begin => |s| {
                    pass.setScissor(&s);
                },
                .scissor_end => {
                    pass.setScissor(&.{
                        .x = 0,
                        .y = 0,
                        .w = @intCast(gpu.window_state.prev_drawable_w),
                        .h = @intCast(gpu.window_state.prev_drawable_h),
                    });
                },
            }
        }

        im.needs_clear = true;
        return true;
    }

    pub const ImmediateDrawOptions = struct {
        transform: hym.Mat4 = .identity,
        material: ?*const Gpu.Material = null,
    };

    pub fn drawVerts(self: *Context, verts: []const Gpu.UIVertex, indices: []const u32, opts: ImmediateDrawOptions) void {
        const gpu: *Gpu = @alignCast(@fieldParentPtr("im", self));
        std.debug.assert(verts.len > 0);
        std.debug.assert(indices.len > 0);

        const allocator = self.arena.allocator();

        const vert_start = self.buffer_src.items.len;
        self.buffer_src.appendSlice(allocator, std.mem.sliceAsBytes(verts)) catch unreachable;
        const vert_end = self.buffer_src.items.len;
        self.buffer_src.appendSlice(allocator, std.mem.sliceAsBytes(indices)) catch unreachable;
        const end = self.buffer_src.items.len;

        const immediate: Item = .{ .renderable = .{
            .offset = @intCast(vert_start),
            .idx_start = @intCast(vert_end),
            .size = @intCast(end - vert_start),
            .transform = opts.transform,
            .material = if (opts.material) |m|
                m.*
            else
                gpu.materials.createWeak(.ui, .initFull(.{ .target = gpu.default_assets.white_texture })),
        } };

        self.items.append(allocator, immediate) catch unreachable;
    }

    pub const ImmediateTextOptions = struct {
        transform: hym.Mat4 = .identity,
        color: [4]f32 = .{ 1, 1, 1, 1 },
    };

    pub fn drawText(self: *Context, glyphs: []const u8, opts: ImmediateTextOptions) void {
        const gpu: *Gpu = @alignCast(@fieldParentPtr("im", self));
        const text = gpu.text_engine.textCreate(gpu.default_assets.font, glyphs.ptr, glyphs.len).?;
        defer text.destroy();

        var maybe_draw_data = text.gpuDrawData();
        while (maybe_draw_data) |draw_data| : (maybe_draw_data = draw_data.next) {
            const allocator = self.arena.allocator();
            var verts: std.ArrayListUnmanaged(Gpu.UIVertex) = .empty;
            defer verts.deinit(allocator);
            var indices: std.ArrayListUnmanaged(u32) = .empty;
            defer indices.deinit(allocator);

            const num_verts: usize = @intCast(draw_data.num_vertices);
            const num_indices: usize = @intCast(draw_data.num_indices);

            verts.ensureUnusedCapacity(allocator, num_verts) catch unreachable;
            indices.ensureUnusedCapacity(allocator, num_indices) catch unreachable;

            for (draw_data.xy[0..num_verts], draw_data.uv[0..num_verts]) |xy, uv| {
                verts.appendAssumeCapacity(.{
                    .pos = .{ xy.x, xy.y },
                    .uv = .{ uv.x, uv.y },
                    .color = opts.color,
                });
            }

            for (draw_data.indices[0..num_indices]) |idx| {
                indices.appendAssumeCapacity(@intCast(idx));
            }

            const material = gpu.materials.createWeak(.ui_sdf, .init(.{ .diffuse = .{ .target = draw_data.atlas_texture } }));
            if (verts.items.len > 0) {
                self.drawVerts(verts.items, indices.items, .{ .transform = opts.transform, .material = &material });
            }
        }
    }

    pub const ImmediateImageOptions = extern struct {
        transform: hym.Mat4,
        color: [4]f32 = .{ 1, 1, 1, 1 },
        texture: Gpu.TextureHandle,
    };

    pub fn drawImage(self: *Context, opts: ImmediateImageOptions) void {
        const gpu: *Gpu = @alignCast(@fieldParentPtr("im", self));
        const verts: []const Gpu.UIVertex = &.{
            .{ .pos = .{ 0, 0 }, .color = opts.color, .uv = .{ 0, 1 } },
            .{ .pos = .{ 1, 0 }, .color = opts.color, .uv = .{ 1, 1 } },
            .{ .pos = .{ 1, 1 }, .color = opts.color, .uv = .{ 1, 0 } },
            .{ .pos = .{ 0, 1 }, .color = opts.color, .uv = .{ 0, 0 } },
        };

        const indices: []const u32 = &.{ 0, 1, 2, 2, 3, 0 };
        const material = gpu.materials.createWeak(.ui, .init(.{ .diffuse = .{ .handle = opts.texture } }));
        self.drawVerts(verts, indices, .{ .transform = opts.transform, .material = &material });
    }

    pub fn scissorBegin(self: *Context, rect: sdl.gpu.Rect) void {
        const allocator = self.arena.allocator();
        self.items.append(allocator, .{ .scissor_begin = rect }) catch unreachable;
    }

    pub fn scissorEnd(self: *Context) void {
        const allocator = self.arena.allocator();
        self.items.append(allocator, .scissor_end) catch unreachable;
    }
};
