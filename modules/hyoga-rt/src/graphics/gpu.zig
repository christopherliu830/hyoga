pub const mdl = @import("model.zig");
pub const primitives = @import("primitives.zig");

const std = @import("std");
const sdl = @import("sdl");
const sdlsc = @import("sdl_shadercross");
const ai = @import("assimp");
const build_options = @import("build_options");

const SlotMap = @import("hyoga-lib").SlotMap;
const hym = @import("hyoga-lib").math;
const vec3 = hym.vec3;
const mat4 = hym.mat4;
const hym_cam = hym.cam;

const stb = @import("stb_image");
const Window = @import("../window.zig");

const buf = @import("buffer.zig");
const tx = @import("texture.zig");
const mt = @import("material.zig");
const Loader = @import("loader.zig");
const Strint = @import("../strintern.zig");
const Vertex = @import("vertex.zig").Vertex;
const passes = @import("passes.zig");
const rbl = @import("renderable.zig");
const Scene = @import("../root.zig").Scene;
const World = @import("../root.zig").World;

const Gpu = @This();

pub const ModelHandle = mdl.Handle;
pub const Models = mdl.Models;
pub const RenderItemHandle = rbl.RenderItemHandle;
pub const AddRenderableOptions = rbl.RenderList.AddModelOptions;


pub const BufferHandle = packed union {
    buffer: *sdl.gpu.Buffer,
    transfer: *sdl.gpu.Buffer,
};

/// This struct is sent to shaders as a uniform
/// buffer and fields must be kept in sync.
pub const GpuScene = extern struct {
    view_proj: hym.Mat4, // RH, y-up view projection matrix. note that SDL_gpu flips viewports to ensure consistency among all backends.
    camera_world_pos: [3]f32,
    viewport_size_x: u32,
    light_dir: [3]f32,
    viewport_size_y: u32,
};

pub const RenderSubmitResult = struct {
    num_drawn_verts: u32 = 0,
    num_draw_calls: u32 = 0,
};

pub const PassType = enum {
    default,
    post_process,
    ui,
};

pub const BuildPipelineParams = struct {
    format: ?sdl.gpu.TextureFormat,
    vert: *sdl.gpu.Shader,
    frag: *sdl.gpu.Shader,
    pass: PassType,
    enable_depth: bool,
    enable_stencil: bool,
    fill_mode: sdl.gpu.FillMode,
};

const RenderState = struct {
    forward_pass: passes.Forward,
    blit_pass: passes.BlitPass,

    default_material: mt.MaterialTemplate,
    post_material: mt.MaterialTemplate,
    outline_material: mt.MaterialTemplate,
    primitives_material: mt.Handle,

    default_texture: *sdl.gpu.Texture,
    black_texture: *sdl.gpu.Texture,
    white_texture: *sdl.gpu.Texture,

    cube: ModelHandle,
    quad: ModelHandle,

    sampler: *sdl.gpu.Sampler = undefined,

    obj_buf: buf.DynamicBuffer(mat4.Mat4),
    scene: *Scene = undefined,
    active_target: ?*sdl.gpu.Texture,
    pending_submit_result: ?RenderSubmitResult = null,
};

pub const PassTargets = struct {
    color: []const sdl.gpu.ColorTargetInfo,
    depth: ?*const sdl.gpu.DepthStencilTargetInfo,
};

const WindowState = struct {
    window: *Window = undefined,
    angle: vec3.Vec3 = vec3.zero,
    cam_position: vec3.Vec3 = vec3.create(0, 0, 2.5),
    msaa_tex: *sdl.gpu.Texture = undefined,
    prev_drawable_w: u32 = 0,
    prev_drawable_h: u32 = 0,
};

const RenderTarget = struct {
    target: []sdl.gpu.ColorTargetInfo,
    scene: *Scene,
};

const RenderCommand = struct {
    cmd: *sdl.gpu.CommandBuffer,
    pass: *sdl.gpu.RenderPass,
};

const ShaderType = enum { vertex, fragment };

const Uniform = union(enum) {
    u32: u32,
    f32: f32,
    f32x3: [3]f32,
    f32x4: [4]f32,
    mat4x4: [4][4]f32,
    buffer: *sdl.gpu.Buffer,
};

device: *sdl.gpu.Device,
gpa: std.mem.Allocator,
arena: std.heap.ArenaAllocator,
buffer_allocator: buf.BufferAllocator,
loader: *Loader,
swapchain_target_desc: sdl.gpu.ColorTargetDescription,
frames: u32 = 0,
strint: *Strint,
render_state: RenderState = undefined,
window_state: WindowState = .{},
renderables: rbl.RenderList,
outlined: std.AutoArrayHashMapUnmanaged(rbl.RenderItemHandle, void),
speed: f32 = 1,
textures: tx.Textures,
models: mdl.Models,
materials: SlotMap(mt.Material),
uniforms: std.StringHashMapUnmanaged(Uniform),

pub fn init(window: *Window, loader: *Loader, strint: *Strint, gpa: std.mem.Allocator) !*Gpu {
    if (build_options.backend) |backend| _ = sdl.hints.setHint("SDL_GPU_DRIVER", backend);
    const d = sdl.gpu.createDevice(sdlsc.getSpirvShaderFormats(), true, null) orelse {
        std.log.err("[GPU] create device failure: {s}", .{sdl.getError()});
        return error.CreateDeviceFailure;
    };
    _ = d.claimWindow(window.hdl);

    if (!d.setSwapchainParameters(window.hdl, .sdr, .immediate)) {
        std.log.warn("[GPU] Swapchain parameters could not be set:" ++
            "{s}", .{sdl.getError()});
    }

    std.log.info("[GPU] Selected backend: {s}", .{d.getDeviceDriver()});

    var self = try gpa.create(Gpu);
    self.* = .{
        .gpa = gpa,
        .arena = std.heap.ArenaAllocator.init(gpa),
        .buffer_allocator = buf.BufferAllocator.init(d, .{ .vertex = true, .index = true }, self.gpa),
        .device = d,
        .swapchain_target_desc = .{ .format = d.getSwapchainTextureFormat(window.hdl) },
        .loader = loader,
        .strint = strint,
        .textures = tx.Textures.create(d, loader, strint, self.gpa),
        .models = mdl.Models.create(loader, strint, self.gpa),
        .materials = try SlotMap(mt.Material).create(self.gpa, 1),
        .window_state = .{ .window = window },
        .renderables = try rbl.RenderList.init(self, self.gpa),
        .outlined = .{},
        .uniforms = .empty,
    };

    try sdlsc.init();
    self.textures.image_loader.use();

    const material = try mt.readFromPath(self, .{
        .path = "shaders/standard",
        .enable_depth = true,
        .enable_stencil = false,
        .fill_mode = .fill,
    }, self.gpa);

    // Generate default assets

    // Unloaded texture
    const texture = self.device.createTexture(&.{
        .format = .b8g8r8a8_unorm, 
        .height = 256,
        .width = 256,
        .layer_count_or_depth = 1,
        .num_levels = 1,
        .sample_count = .@"1",
        .usage = .{ .sampler = true }
    }).?;
    self.device.setTextureName(texture, "null_tex");

    var buffer: [256 * 256]u32 = [_]u32{0xffffffff} ** (256 * 256);
    const black = 0xff000000;
    const white = 0xffffffff;

    for (0..256) |i| {
        for (0..256) |j| {
            if ((i + j) % 2 == 999) {
                @memset(buffer[i * 256 + j .. i * 256 + j + 1], black);
            }
            else {
                @memset(buffer[i * 256 + j .. i * 256 + j + 1], white);
            }
        }
    }
    try self.uploadToTexture(texture, 256, 256, &std.mem.toBytes(buffer));

    // Black texture
    const black_texture = self.device.createTexture(&.{
        .format = .b8g8r8a8_unorm, 
        .height = 1,
        .width = 1,
        .layer_count_or_depth = 1,
        .num_levels = 1,
        .sample_count = .@"1",
        .usage = .{ .sampler = true }
    }).?;
    self.device.setTextureName(black_texture, "black_tex");

    try self.uploadToTexture(black_texture, 1, 1, &[4]u8{1, 0, 0, 0});

    const white_texture = self.device.createTexture(&.{
        .format = .b8g8r8a8_unorm, 
        .height = 1,
        .width = 1,
        .layer_count_or_depth = 1,
        .num_levels = 1,
        .sample_count = .@"1",
        .usage = .{ .sampler = true }
    }).?;
    self.device.setTextureName(white_texture, "white_tex");

    try self.uploadToTexture(white_texture, 1, 1, &std.mem.toBytes([_]u32 {white}));

    // Sampler
    const sampler_info = sdl.gpu.SamplerCreateInfo {
        .address_mode_u = .clamp_to_edge,
        .address_mode_v = .clamp_to_edge,
        .address_mode_w = .clamp_to_edge,
        .min_filter = .linear,
        .mag_filter = .linear,
    };

    const white_material = try self.materials.insert(
        mt.Material.fromTemplate(material, tx.TextureSet.initFull(.{ .target = white_texture })));

    const cube = try self.createModel(&primitives.cube.vertices, &primitives.cube.indices, white_material);
    const quad = try self.createModel(&primitives.quad.vertices, &primitives.quad.indices, white_material);

    const quad_mat_template = try mt.readFromPath(self, .{
        .path = "shaders/post_process",
        .enable_depth = false,
        .enable_stencil = false,
    }, self.gpa);
    
    var w: c_int = 0;
    var h: c_int = 0;
    _ = sdl.video.getWindowSizeInPixels(window.hdl, &w, &h);

    self.render_state = .{
        .forward_pass = passes.Forward.init(self.device, .{
            .name = "standard",
            .clear_color = .{ .r = 0.2, .g = 0.2, .b = 0.4, .a = 1 },
            .depth_enabled = true,
            .stencil_enabled = false,
            .dest_format = self.swapchain_target_desc.format,
            .dest_usage = .{ .color_target = true, .sampler = true },
            .dest_tex_width = @intCast(w),
            .dest_tex_height = @intCast(h),
        }),

        .blit_pass = passes.BlitPass.init(self, self.device),

        .default_material = material,
        .default_texture = texture,
        .black_texture = black_texture,
        .white_texture = white_texture,

        .cube = cube,
        .quad = quad,

        .post_material = quad_mat_template,

        .outline_material = try mt.readFromPath(self, .{
            .path = "shaders/outline",
            .enable_depth = false,
            .enable_stencil = false,
            .format = .r8_unorm,
        }, self.gpa),

        .primitives_material = white_material,

        .sampler = self.device.createSampler(&sampler_info).?,
        .obj_buf = try buf.DynamicBuffer(mat4.Mat4).init(self.device, 512, "Object Mats"),
        .active_target = null,
    };

    return self;
}

pub fn shutdown(self: *Gpu) void {
    sdlsc.quit();

    self.device.releaseWindow(self.window_state.window.hdl);

    self.textures.deinit();
    self.models.deinit();
    self.materials.deinit();

    self.device.releaseTexture(self.render_state.default_texture);
    self.device.releaseTexture(self.render_state.black_texture);
    self.device.releaseSampler(self.render_state.sampler);
    self.device.releaseGraphicsPipeline(self.render_state.post_material.pipeline);
    self.device.releaseGraphicsPipeline(self.render_state.default_material.pipeline);
    self.device.destroy();

    self.arena.deinit();
}

pub fn uploadToBuffer(self: *Gpu, buffer: *sdl.gpu.Buffer, offset: u32, data: []const u8) !void {
    const buf_transfer = self.device.createTransferBuffer(&.{
        .usage = .upload,
        .size = @intCast(data.len),
    }).?;
    defer self.device.releaseTransferBuffer(buf_transfer);

    const map: [*]u8 = @ptrCast(@alignCast(self.device.mapTransferBuffer(buf_transfer, false).?));
    @memcpy(map, data);
    self.device.unmapTransferBuffer(buf_transfer);

    const cmd = self.device.acquireCommandBuffer().?;

    const copy_pass = cmd.beginCopyPass().?;

    const buf_location = sdl.gpu.TransferBufferLocation{
        .transfer_buffer = buf_transfer,
        .offset = 0,
    };

    const dst_region = sdl.gpu.BufferRegion {
        .buffer = buffer,
        .offset = offset,
        .size = @intCast(data.len),
    };

    copy_pass.uploadToBuffer(&buf_location, &dst_region, false);
    copy_pass.end();
    _ = cmd.submit();
}

pub fn uploadToTexture(self: *Gpu, tex: *sdl.gpu.Texture, w: u32, h: u32, data: []const u8) !void {
    const buf_transfer = self.device.createTransferBuffer(&.{ .size = @intCast(data.len), .usage = .upload }).?;
    defer self.device.releaseTransferBuffer(buf_transfer);
    const ptr_transfer: [*]u8 = @ptrCast(@alignCast(self.device.mapTransferBuffer(buf_transfer, false).?));
    @memcpy(ptr_transfer, data);
    self.device.unmapTransferBuffer(buf_transfer);

    // copy to transfer buffer
    const cmd = self.device.acquireCommandBuffer().?;
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
    _ = cmd.submit();
}

/// This function acquires a swapchain to draw to the
/// screen. Do not use for offscreen buffers as this is not needed.
/// Returns a command buffer.
pub fn begin(self: *Gpu) !?*sdl.gpu.CommandBuffer {
    const zone = @import("ztracy").Zone(@src());
    defer zone.End();

    self.render_state.pending_submit_result = .{};

    var drawable_w: u32 = undefined;
    var drawable_h: u32 = undefined;

    const cmd = self.device.acquireCommandBuffer() orelse {
        std.log.err("could not acquire command buffer", .{});
        return error.SDLError;
    };

    var swapchain: ?*sdl.gpu.Texture = null;
    if (!cmd.acquireSwapchainTexture(self.window_state.window.hdl, &swapchain, &drawable_w, &drawable_h)) {
        std.log.err("Could not acquire swapchain texture", .{});
        return error.AcquireSwapchainError;
    } else if (swapchain) |s| {
        if (self.window_state.prev_drawable_w != drawable_w or self.window_state.prev_drawable_h != drawable_h) {
            self.render_state.forward_pass.resize(drawable_w, drawable_h);
        }

        self.window_state.prev_drawable_w = drawable_w;
        self.window_state.prev_drawable_h = drawable_h;

        self.render_state.active_target = s;
        return cmd;
    } else {
        // No swapchain was acquired, probably too many frames in flight.
        if (!cmd.cancel()) {
            std.log.err("could not cancel command buffer", .{});
            return error.SDLError;
        }
        return null;
    }
}

pub fn render(self: *Gpu, cmd: *sdl.gpu.CommandBuffer, scene: *Scene) !void {
    const zone = @import("ztracy").Zone(@src());
    defer zone.End();
    const arena = self.arena.allocator();

    try self.uniforms.put(self.gpa, "hy_view_projection_matrix", .{ .mat4x4 = scene.view_proj.m });
    try self.uniforms.put(self.gpa, "hy_camera_world_position", .{ .f32x3 = scene.camera_world_pos.v });
    try self.uniforms.put(self.gpa, "hy_light_direction", .{ .f32x3 = scene.light_dir.v });
    try self.uniforms.put(self.gpa, "hy_viewport_size", .{ .@"f32x4" = .{ 
        @floatFromInt(self.window_state.prev_drawable_w),
        @floatFromInt(self.window_state.prev_drawable_h),
        0, 0 }});
    try self.uniforms.put(self.gpa, "hy_renderables", .{ .buffer = self.render_state.obj_buf.hdl });

    const render_pack = try self.renderables.packAll(arena);
    const transforms = render_pack.transforms;
    try self.uploadToBuffer(self.render_state.obj_buf.hdl, 0, std.mem.sliceAsBytes(transforms));

    self.doPass(.{
        .cmd = cmd,
        .scene = scene.*,
        .targets = self.render_state.forward_pass.targets(),
        .items = .{ .pack = render_pack }
    }) catch unreachable;

    // Render selected objects as mask for outline
    const mask: ?passes.Forward = blk: {
        if (self.outlined.keys().len == 0) {
            break :blk null;
        } else {
            const mask = passes.Forward.init(self.device, .{
                .name = "mask",
                .dest_format = .r8_unorm,
                .dest_usage = .{ .color_target = true, .sampler = true },
                .dest_tex_width = @intCast(self.window_state.prev_drawable_w),
                .dest_tex_height = @intCast(self.window_state.prev_drawable_h),
            });

            self.doPass(.{
                .cmd = cmd,
                .scene = scene.*,
                .material = mt.Material.fromTemplate(self.render_state.outline_material, .{}),
                .targets = mask.targets(),
                .items = .{ .handles = self.outlined.keys() },
            }) catch unreachable;

            break :blk mask;
        }
    };
    defer if (mask) |m| m.deinit();

    self.doPass(.{
        .cmd = cmd,
        .scene = scene.*,
        .targets = self.render_state.blit_pass.targets(self.render_state.active_target.?),
        .items = .{ .renderables = (&self.render_state.blit_pass.quad)[0..1] },
        .material = mt.Material.fromTemplate(
            self.render_state.post_material,
            tx.TextureSet.init(.{
                .diffuse = .{ .target = self.render_state.forward_pass.texture() },
                .mask = .{ .target = if (mask != null) mask.?.texture() else self.render_state.black_texture },
            }),
        ),
    }) catch unreachable;
}

pub fn submit(self: *Gpu, cmd: *sdl.gpu.CommandBuffer) RenderSubmitResult {
    const zone = @import("ztracy").Zone(@src());
    defer zone.End();

    _ = cmd.submit();
    _ = self.arena.reset(.retain_capacity);
    const result = self.render_state.pending_submit_result.?;
    self.render_state.pending_submit_result = null;
    self.render_state.active_target = null;
    return result;
}

pub const PassIterator = union(enum) {
    renderables: []const rbl.Renderable,
    handles: []const rbl.RenderItemHandle,
    iterator: rbl.RenderList.Iterator,
    pack: rbl.PackedRenderables,
};

pub const PassInfo = struct {
    cmd: *sdl.gpu.CommandBuffer,

    items: PassIterator,

    material: ?mt.Material = null, // force every object to use the same material
    targets: PassTargets,
    scene: Scene,
};

pub fn doPass(self: *Gpu, job: PassInfo) !void {
    const zone = @import("ztracy").Zone(@src());
    defer zone.End();

    const color = job.targets.color;
    const depth = job.targets.depth;
    const pass = job.cmd.beginRenderPass(color.ptr, @intCast(color.len), depth).?;
    defer pass.end();

    var last_pipeline: ?*sdl.gpu.GraphicsPipeline = null;


    switch(job.items) {
        .renderables => |items| for (items, 0..) |item, i| {
            try self.doPassOne(@intCast(i), pass, item.mesh, job, &last_pipeline);
        },
        .handles => |handles| for (handles) |hdl| {
            const item = self.renderables.items.get(hdl) catch continue;
            try self.doPassOne(hdl.index, pass, item.mesh, job, &last_pipeline);
        },
        .iterator => |iterator| {
            var it = iterator;
            while (it.next()) |value| {
                try self.doPassOne(it.index(), pass, value.mesh, job, &last_pipeline);
            }
        },
        .pack => |pack| {
            var total_instances_rendered: u32 = 0;
            for(0..pack.len) |i| {
                const mesh = pack.meshes[i];
                try self.doPassInstanced(&job, pass, total_instances_rendered, pack.instance_counts[i], mesh);
                total_instances_rendered += pack.instance_counts[i];
            }
        }
    }
}

fn doPassInstanced(self: *Gpu,
                   job: *const PassInfo,
                   pass: *sdl.gpu.RenderPass,
                   num_first_instance: u32,
                   num_instances: u32,
                   mesh: mdl.Mesh) !void {

    const zone = @import("ztracy").ZoneN(@src(), "RenderInstanced");
    defer zone.End();

    const material = try self.materials.get(mesh.material);
    const buffer = mesh.buffer;

    pass.bindGraphicsPipeline(material.pipeline);

    inline for (.{
        .{ 
            material.vert_program_def, 
            sdl.gpu.CommandBuffer.pushVertexUniformData, 
            sdl.gpu.RenderPass.bindVertexSamplers,
            sdl.gpu.RenderPass.bindVertexStorageBuffers,
        },
        .{ 
            material.frag_program_def,
            sdl.gpu.CommandBuffer.pushFragmentUniformData,
            sdl.gpu.RenderPass.bindFragmentSamplers,
            sdl.gpu.RenderPass.bindFragmentStorageBuffers,
        },
    }) |opt| {

        const program_def = opt[0];
        const pushUniform = opt[1];
        const pushSampler = opt[2];
        const pushStorageBuffer = opt[3];

        if (program_def.num_storage_buffers > 0) {
            pushStorageBuffer(pass, 0, &[1]*sdl.gpu.Buffer{ self.render_state.obj_buf.hdl }, 1); 
        }

        for (program_def.uniforms, 0..) |uniform_name, i| {
            if (self.uniforms.get(uniform_name)) |value| {
                const idx: u32 = @intCast(i);
                switch(value) {
                    .@"u32" => |*data| pushUniform(job.cmd, idx, std.mem.asBytes(data), @sizeOf(@TypeOf(data.*))),
                    .@"f32" => |*data| pushUniform(job.cmd, idx, std.mem.asBytes(data), @sizeOf(@TypeOf(data.*))),
                    .f32x3  => |*data| pushUniform(job.cmd, idx, std.mem.asBytes(data), @sizeOf(@TypeOf(data.*))),
                    .f32x4  => |*data| pushUniform(job.cmd, idx, std.mem.asBytes(data), @sizeOf(@TypeOf(data.*))),
                    .mat4x4 => |*data| pushUniform(job.cmd, idx, std.mem.asBytes(data), @sizeOf(@TypeOf(data.*))),
                    .buffer => unreachable, 
                    // else => |*data| pushUniform(job.cmd, idx, std.mem.asBytes(data), @sizeOf(@TypeOf(data))),
                }
            }
        }

        for (program_def.textures, 0..) |needed_tex_type, i| {
            if (needed_tex_type == null) continue;
            const tex_id = material.textures.get(needed_tex_type.?).?;
            const texture: *sdl.gpu.Texture = blk: {
                if (tex_id.target) |target| break :blk target;
                if (tex_id.handle) |handle| break :blk self.textures.get(handle) 
                    catch self.render_state.default_texture
                    orelse self.render_state.default_texture;
                std.debug.panic("[GPU] Textures must have a handle or direct target defined", .{});
            };

            const binding = [_]sdl.gpu.TextureSamplerBinding{.{
                .sampler = self.render_state.sampler,
                .texture = texture
            }};

            pushSampler(pass, @intCast(i), &binding, 1);
        }
    }

    pass.bindVertexBuffers(0, &.{ .buffer = buffer.hdl, .offset = @intCast(buffer.offset) }, 1);
    pass.bindIndexBuffer(&.{ .buffer = buffer.hdl, .offset = @intCast(buffer.idx_start) }, .@"32bit");
    pass.drawIndexedPrimitives(buffer.idxCount(), num_instances, 0, 0, num_first_instance);

}

fn doPassOne(self: *Gpu,
             index: u32,
             pass: *sdl.gpu.RenderPass,
             mesh: mdl.Mesh,
             job: PassInfo,
             last_pipeline: *?*sdl.gpu.GraphicsPipeline) !void
{
    const zone = @import("ztracy").ZoneN(@src(), "RenderOne");
    defer zone.End();

    const material = if (job.material) |m| m 
        else try self.materials.get(mesh.material);

    if (last_pipeline.* == null or material.pipeline != last_pipeline.*.?) {
        last_pipeline.* = material.pipeline;
        pass.bindGraphicsPipeline(material.pipeline);
    }

    inline for (.{
        .{ 
            material.vert_program_def, 
            sdl.gpu.CommandBuffer.pushVertexUniformData, 
            sdl.gpu.RenderPass.bindVertexSamplers,
            sdl.gpu.RenderPass.bindVertexStorageBuffers,
        },
        .{ 
            material.frag_program_def,
            sdl.gpu.CommandBuffer.pushFragmentUniformData,
            sdl.gpu.RenderPass.bindFragmentSamplers,
            sdl.gpu.RenderPass.bindFragmentStorageBuffers,
        },
    }) |opt| {

        const program_def = opt[0];
        const pushSampler = opt[2];
        const pushStorageBuffer = opt[3];

        if (program_def.num_storage_buffers > 0) {
            pushStorageBuffer(pass, 0, &[1]*sdl.gpu.Buffer{ self.render_state.obj_buf.hdl }, 1); 
        }

        for (program_def.textures, 0..) |needed_tex_type, i| {
            if (needed_tex_type == null) continue;
            const tex_id = material.textures.get(needed_tex_type.?).?;
            const texture: *sdl.gpu.Texture = blk: {
                if (tex_id.target) |target| break :blk target;
                if (tex_id.handle) |handle| break :blk self.textures.get(handle) 
                    catch self.render_state.default_texture
                    orelse self.render_state.default_texture;
                std.debug.panic("[GPU] Textures must have a handle or direct target defined", .{});
            };

            const binding = [_]sdl.gpu.TextureSamplerBinding{.{
                .sampler = self.render_state.sampler,
                .texture = texture
            }};

            pushSampler(pass, @intCast(i), &binding, 1);
        }
    }

    const buffer = mesh.buffer;
    pass.bindVertexBuffers(0, &.{ .buffer = buffer.hdl, .offset = @intCast(buffer.offset) }, 1);
    pass.bindIndexBuffer(&.{ .buffer = buffer.hdl, .offset = @intCast(buffer.idx_start) }, .@"32bit");
    pass.drawIndexedPrimitives(buffer.idxCount(), 1, 0, 0, index);
}

pub fn buildPipeline(self: *Gpu, params: BuildPipelineParams) *sdl.gpu.GraphicsPipeline {
    const sample_count = .@"1";

    const color_target_desc: []const sdl.gpu.ColorTargetDescription = &.{.{
        .format = params.format orelse self.swapchain_target_desc.format,
        .blend_state = .{
            .enable_blend = true,
            .src_color_blendfactor = .src_alpha,
            .dst_color_blendfactor = .one_minus_src_alpha,
            .color_blend_op = .add,
            .src_alpha_blendfactor = .one,
            .dst_alpha_blendfactor = .one_minus_src_alpha,
            .alpha_blend_op = .add,
        },
    }};

    const vertex_buffer_desc: []const sdl.gpu.VertexBufferDescription = &.{switch (params.pass) {
        .default => .{
            .slot = 0,
            .input_rate = .vertex,
            .instance_step_rate = 0,
            .pitch = @sizeOf(Vertex),
        },
        .post_process => .{
            .slot = 0,
            .input_rate = .vertex,
            .instance_step_rate = 0,
            .pitch = @sizeOf(f32) * 4, // vec2 pos, vec2 uv
        },
        .ui => .{
            .slot = 0,
            .input_rate = .vertex,
            .instance_step_rate = 0,
            .pitch = @sizeOf(f32) * 8, // from IMGUI: vec2 pos, vec2 uv, vec4 col
        },
    }};

    const vertex_attributes: []const sdl.gpu.VertexAttribute = switch (params.pass) {
        .default => &.{ .{
            .buffer_slot = 0,
            .format = .float3,
            .location = 0,
            .offset = 0,
        }, .{
            .buffer_slot = 0,
            .format = .float3,
            .location = 1,
            .offset = @offsetOf(Vertex, "normal"),
        }, .{
            .buffer_slot = 0,
            .format = .float2,
            .location = 2,
            .offset = @offsetOf(Vertex, "uv"),
        } },
        .post_process => &.{
            .{
                .buffer_slot = 0,
                .format = .float2,
                .location = 0,
                .offset = 0,
            },
            .{
                .buffer_slot = 0,
                .format = .float2,
                .location = 1,
                .offset = 8,
            },
        },
        .ui => &.{
            .{
                .buffer_slot = 0,
                .format = .float2,
                .location = 0,
                .offset = 0,
            },
            .{
                .buffer_slot = 0,
                .format = .float2,
                .location = 1,
                .offset = 8,
            },
            .{
                .buffer_slot = 0,
                .format = .ubyte4_norm,
                .location = 2,
                .offset = 16,
            },
        },
    };

    const stencil_state = sdl.gpu.StencilOpState {
        .compare_op = .always,
        .depth_fail_op = .keep,
        .fail_op = .keep,
        .pass_op = .replace,
    };

    const target_info: sdl.gpu.GraphicsPipelineTargetInfo = .{
        .num_color_targets = @intCast(color_target_desc.len),
        .color_target_descriptions = color_target_desc.ptr,
        .depth_stencil_format = if (params.enable_stencil) .d32_float_s8_uint else .d32_float,
        .has_depth_stencil_target = params.enable_depth or params.enable_stencil,
    };

    const depth_stencil_state: sdl.gpu.DepthStencilState = switch (params.pass) {
        .default => .{
            .enable_depth_test = params.enable_depth,
            .enable_depth_write = params.enable_depth,
            .enable_stencil_test = params.enable_stencil,
            .compare_op = .less_or_equal,
            .compare_mask = 0xff,
            .write_mask = 0xff,
            .front_stencil_state = stencil_state,
            .back_stencil_state = stencil_state,
        },
        .ui => .{},
        .post_process => .{},
    };

    const pipeline_desc = sdl.gpu.GraphicsPipelineCreateInfo{
        .target_info = target_info,
        .depth_stencil_state = depth_stencil_state,
        .multisample_state = .{ .sample_count = sample_count },
        .primitive_type = .trianglelist,
        .rasterizer_state = .{ .fill_mode = params.fill_mode },
        .vertex_shader = params.vert,
        .fragment_shader = params.frag,
        .vertex_input_state = .{
            .num_vertex_buffers = @intCast(vertex_buffer_desc.len),
            .vertex_buffer_descriptions = vertex_buffer_desc.ptr,
            .num_vertex_attributes = @intCast(vertex_attributes.len),
            .vertex_attributes = vertex_attributes.ptr,
        },
        .props = 0,
    };

    const pipeline = self.device.createGraphicsPipeline(&pipeline_desc) orelse {
        std.log.err("Could not create pipeline: {s}", .{sdl.getError()});
        unreachable;
    };

    return pipeline;
}

pub fn importModel(self: *Gpu, path: [*:0]const u8, settings: Models.ImportSettings) !ModelHandle {
    const path_slice = std.mem.span(path);
    const allocator = self.arena.allocator();

    var import = ai.importFile(path_slice, settings.post_process);
    // Don't release the scene, it will be passed to models for read.

    var materials_array = try allocator.alloc(mt.Handle, import.num_materials);

    // Material indices start at one for assimp imports
    materials_array[0] = mt.Handle.invalid;
    for (import.materials[1..import.num_materials], 1..) |ai_material, mat_index| {
        var texture_set = tx.TextureSet.init(.{});

        inline for (std.meta.fields(ai.TextureType)) |field| {
            const tex_type: ai.TextureType = @enumFromInt(field.value);
            const count = ai_material.getTextureCount(tex_type);
            for (0..count) |i| {
                var str: ai.String = undefined;
                _ = ai_material.getTexture(ai.Material.GetTextureInfo {
                    .tex_type = tex_type,
                    .index = @intCast(i),
                    .path = &str,
                });

                const ai_tex_id: [:0]u8 = str.data[0..str.len :0];
                var tex_id: [:0]u8 = ai_tex_id;
                var handle: ?tx.Handle = null;

                if (import.getEmbeddedTexture(ai_tex_id.ptr)) |tex| {
                    _ = tex;
                    unreachable;
                } else { // Texture is a relative path
                    tex_id = try std.fs.path.joinZ(self.arena.allocator(), &[_][]const u8{ 
                        std.fs.path.dirname(path_slice).?,
                        ai_tex_id
                    });
                    handle = try self.textures.read(tex_id);
                }

                std.debug.assert(handle != null);

                const hy_tex_type: ?tx.TextureType = tx.tex_to_hyoga_type.get(tex_type);
                if (hy_tex_type) |htt| {
                    texture_set.put(htt, .{ .handle = handle });
                } else {
                    std.log.warn("[GPU]: Unconsumed texture type {s} for object {s}", .{ field.name, path });
                }
            }
        }
        const material = mt.Material.fromTemplate(self.render_state.default_material, texture_set);
        const hdl = try self.materials.insert(material);
        materials_array[mat_index] = hdl;
    }

    const model = try self.models.read(import, materials_array, settings);
    return model;
}

pub fn createModel(self: *Gpu, verts: []const Vertex, indices: []const u32, material: mt.Handle) !ModelHandle {
    const buffer = buf.VertexIndexBuffer.create(
        self.device,
        @intCast(@sizeOf(Vertex) * verts.len),
        @intCast(@sizeOf(u32) * indices.len),
    );

    try self.uploadToBuffer(buffer.hdl, buffer.offset, std.mem.sliceAsBytes(verts));
    try self.uploadToBuffer(buffer.hdl, buffer.idx_start, std.mem.sliceAsBytes(indices));

    const mesh = try self.gpa.create(mdl.Mesh);
    errdefer self.gpa.destroy(mesh);

    mesh.* = .{
        .buffer = buffer,
        .material = material,
    };

    const model = mdl.Model {
        .children = mesh[0..1],
        .transform = mat4.identity,
        .bounds = primitives.Cube.bounds,
    };

    return self.models.add(model);
}

pub fn getPrimitive(self: *Gpu, shape: primitives.Shape) ModelHandle {
    return switch (shape) {
        .cube => return self.render_state.cube,
        .quad => return self.render_state.quad,
    };
}

pub fn selectRenderable(self: *Gpu, handle: rbl.RenderItemHandle) void {
    self.outlined.put(self.gpa, handle, {});
}