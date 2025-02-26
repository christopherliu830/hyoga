const std = @import("std");
const mdl = @import("model.zig");
const hy = @import("hyoga-lib");
const sdl = @import("sdl");
const sdlsc = @import("sdl_shadercross");
const ai = @import("assimp");
const build_options = @import("build_options");

const SlotMap = @import("hyoga-lib").SlotMap;
const hym = @import("hyoga-lib").math;
const vec3 = hym.vec3;
const mat4 = hym.mat4;
const hym_cam = hym.cam;

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

pub const AddRenderableOptions = rbl.RenderList.AddOptions;
pub const Material = mt.Material;
pub const MaterialHandle = mt.Handle;
pub const MaterialTemplate = mt.MaterialTemplate;
pub const MaterialType = mt.Material.Type;
pub const Mesh = mdl.Mesh;
pub const Model = mdl.Handle;
pub const Models = mdl.Models;
pub const RenderItemHandle = rbl.RenderItemHandle;
pub const SpriteHandle = hy.SlotMap(Sprite).Handle;
pub const TextureHandle = tx.Handle;
pub const Textures = tx.Textures;
pub const TextureSet = tx.TextureSet;
pub const TextureArray = tx.TextureArray;
pub const TextureSetCreateInfo = tx.TextureSetCreateInfo;
pub const primitives = @import("primitives.zig");

const log = std.log.scoped(.gpu);
const panic = std.debug.panic;

/// These constant strings are declared in each shader's resource manifest
/// in order to bind SSBOs and uniforms.
pub const StringIDs = struct {
    all_renderables: Strint.ID,
    selected_renderables: Strint.ID,
    view: Strint.ID,
    projection: Strint.ID,
    view_projection: Strint.ID, // RH, y-up view projection matrix. note that SDL_gpu flips viewports to ensure consistency among all backends.
    camera_world_position: Strint.ID,
    light_direction: Strint.ID,
    viewport_size: Strint.ID,
    sprites: Strint.ID,
    material_idx: Strint.ID,
    time: Strint.ID,

    pub fn init(strint: *Strint) @This() {
        return .{
            // Storage buffers
            .all_renderables = strint.from("hy_all_renderables") catch hy.err.oom(),
            .selected_renderables = strint.from("hy_selected_renderables") catch hy.err.oom(),
            // Uniform buffers
            .view = strint.from("hy_view_matrix") catch hy.err.oom(),
            .projection = strint.from("hy_projection_matrix") catch hy.err.oom(),
            .view_projection = strint.from("hy_view_projection_matrix") catch hy.err.oom(),
            .camera_world_position = strint.from("hy_camera_world_position") catch hy.err.oom(),
            .light_direction = strint.from("hy_light_direction") catch hy.err.oom(),
            .viewport_size = strint.from("hy_viewport_size") catch hy.err.oom(),
            .sprites = strint.from("hy_sprites") catch hy.err.oom(),
            .material_idx = strint.from("hy_material_index") catch hy.err.oom(),
            .time = strint.from("hy_time") catch hy.err.oom(),
        };
    }
};

pub const BufferHandle = packed union {
    buffer: *sdl.gpu.Buffer,
    transfer: *sdl.gpu.Buffer,
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
    primitive_type: sdl.gpu.PrimitiveType,
};

pub const GpuSprite = extern struct {
    width: u32,
    height: u32,
    offset: u32,
    len: u32,
    speed: f32,
    time_offset: f32 = 0,
    color: [4]f32 = .{ 1, 1, 1, 1 },

    comptime {
        hy.meta.assertMatches(GpuSprite, hy.Gpu.Sprite);
    }
};

pub const Sprite = extern struct {
    model: Model,
    material: MaterialHandle,
};

const DefaultAssets = struct {
    forward_pass: passes.Forward,

    default_texture: *sdl.gpu.Texture,
    black_texture: *sdl.gpu.Texture,
    white_texture: *sdl.gpu.Texture,

    cube: Model,
    quad: Model,
    sphere: Model,

    sampler: *sdl.gpu.Sampler = undefined,

    obj_buf: buf.DynamicBuffer(mat4.Mat4),
    selected_obj_buf: buf.DynamicBuffer(mat4.Mat4),
    sprite_buf: buf.DynamicBuffer(u128),
    scene: *Scene = undefined,
    active_target: ?*sdl.gpu.Texture,
    pending_submit_result: ?RenderSubmitResult = null,
};

const WindowState = struct {
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
    u32x4: [4]u32,
    f32: f32,
    f64: f64,
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
strint: *Strint,
window: *Window,
default_assets: DefaultAssets = undefined,
window_state: WindowState = .{},
renderables: rbl.RenderList,
outlined: std.AutoArrayHashMapUnmanaged(rbl.RenderItemHandle, void),
sprites: hy.SlotMap(Sprite),
speed: f32 = 1,
textures: tx.Textures,
models: Models,
materials: mt.Materials,
uniforms: std.AutoHashMapUnmanaged(Strint.ID, Uniform),
ids: StringIDs,

pub fn init(window: *Window, loader: *Loader, strint: *Strint, gpa: std.mem.Allocator) !*Gpu {
    if (build_options.backend) |backend| _ = sdl.hints.setHint("SDL_GPU_DRIVER", backend);

    const device = sdl.gpu.createDevice(sdlsc.getSpirvShaderFormats(), true, null) orelse {
        log.err("[GPU] create device failure: {s}", .{sdl.getError()});
        return error.CreateDeviceFailure;
    };

    _ = device.claimWindow(window.hdl);

    if (!device.setSwapchainParameters(window.hdl, .sdr, .immediate)) {
        log.warn("[GPU] Swapchain parameters could not be set: {s}", .{sdl.getError()});
    }

    log.info("[GPU] Selected backend: {s}", .{device.getDeviceDriver()});

    var self = gpa.create(Gpu) catch hy.err.oom();

    self.* = .{
        .gpa = gpa,
        .device = device,
        .arena = .init(gpa),
        .buffer_allocator = .init(self.device, .{ .vertex = true, .index = true }, self.gpa),
        .loader = loader,
        .strint = strint,
        .window = window,
        .window_state = .{},
        .ids = .init(self.strint),
        .textures = .init(self.device, loader, strint, self.gpa),
        .models = .create(loader, strint, self.gpa),
        .materials = .init(self),
        .renderables = .init(self, self.gpa),
        .outlined = .{},
        .sprites = .empty,
        .uniforms = .empty,
    };

    sdlsc.init() catch |e| panic("sdl shader compiler init failure: {}", .{e});
    self.textures.image_loader.use();

    // Generate default assets

    // Unloaded texture
    const texture = self.device.createTexture(&.{
        .format = .b8g8r8a8_unorm,
        .height = 256,
        .width = 256,
        .layer_count_or_depth = 1,
        .num_levels = 1,
        .sample_count = .@"1",
        .usage = .{ .sampler = true },
    }) catch panic("error creating texture", .{});

    self.device.setTextureName(texture, "null_tex");

    var buffer: [256 * 256]u32 = [_]u32{0xffffffff} ** (256 * 256);
    const black = 0xff000000;
    const white = 0xffffffff;

    for (0..256) |i| {
        for (0..256) |j| {
            if ((i + j) % 2 == 0) {
                @memset(buffer[i * 256 + j .. i * 256 + j + 1], black);
            } else {
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
        .usage = .{ .sampler = true },
    }) catch panic("error creating texture", .{});
    self.device.setTextureName(black_texture, "black_tex");

    try self.uploadToTexture(black_texture, 1, 1, &[4]u8{ 1, 0, 0, 0 });

    const white_texture = self.device.createTexture(&.{
        .format = .b8g8r8a8_unorm,
        .height = 1,
        .width = 1,
        .layer_count_or_depth = 1,
        .num_levels = 1,
        .sample_count = .@"1",
        .usage = .{ .sampler = true },
    }) catch panic("error creating texture", .{});
    self.device.setTextureName(white_texture, "white_tex");

    try self.uploadToTexture(white_texture, 1, 1, &std.mem.toBytes([_]u32{white}));

    // Sampler
    const sampler_info: sdl.gpu.SamplerCreateInfo = .{
        .address_mode_u = .clamp_to_edge,
        .address_mode_v = .clamp_to_edge,
        .address_mode_w = .clamp_to_edge,
        .min_filter = .nearest,
        .mag_filter = .nearest,
    };

    const white_material = self.materials.insert(.standard, .initFull(.{ .target = white_texture }));

    const cube = try self.createModel(&primitives.cube.vertices, &primitives.cube.indices, white_material);
    const quad = try self.createModel(&primitives.quad.vertices, &primitives.quad.indices, white_material);
    const sphere_primitive = primitives.createSphere();
    const sphere = try self.createModel(&sphere_primitive.vertices, &sphere_primitive.indices, white_material);

    var w: c_int = 0;
    var h: c_int = 0;
    _ = sdl.video.getWindowSizeInPixels(window.hdl, &w, &h);

    self.default_assets = .{
        .forward_pass = passes.Forward.init(self.device, .{
            .name = "standard",
            .clear_color = .{ .r = 0, .g = 0, .b = 0, .a = 0 },
            .depth_enabled = true,
            .dest_format = self.device.getSwapchainTextureFormat(self.window.hdl),
            .dest_usage = .{ .color_target = true, .sampler = true },
            .dest_tex_width = @as(u16, @intCast(w)),
            .dest_tex_height = @as(u16, @intCast(h)),
            .dest_tex_scale = 0.6,
        }),

        .default_texture = texture,
        .black_texture = black_texture,
        .white_texture = white_texture,

        .cube = cube,
        .quad = quad,
        .sphere = sphere,

        .sampler = self.device.createSampler(&sampler_info) orelse std.debug.panic("create sampler failure: {s}", .{sdl.getError()}),
        .obj_buf = try buf.DynamicBuffer(mat4.Mat4).init(self.device, 512, "Object Mats"),
        .selected_obj_buf = try buf.DynamicBuffer(mat4.Mat4).init(self.device, 512, "Selected Object Mats"),
        .sprite_buf = try buf.DynamicBuffer(u128).init(self.device, 1024, "Sprite Atlas Sizes"),
        .active_target = null,
    };

    try self.uniforms.put(self.gpa, self.ids.all_renderables, .{ .buffer = self.default_assets.obj_buf.hdl });
    try self.uniforms.put(self.gpa, self.ids.selected_renderables, .{ .buffer = self.default_assets.selected_obj_buf.hdl });
    try self.uniforms.put(self.gpa, self.ids.sprites, .{ .buffer = self.default_assets.sprite_buf.hdl });

    return self;
}

pub fn shutdown(self: *Gpu) void {
    sdlsc.quit();

    self.device.waitForIdle() catch {
        std.debug.panic("Could not wait for idle: {s}", .{sdl.getError()});
    };

    self.device.releaseWindow(self.window.hdl);

    self.textures.deinit();
    self.models.deinit();
    self.materials.deinit();
    self.renderables.deinit();

    self.buffer_allocator.deinit();

    self.default_assets.forward_pass.deinit();
    self.device.releaseBuffer(self.default_assets.obj_buf.hdl);
    self.device.releaseBuffer(self.default_assets.selected_obj_buf.hdl);
    self.device.releaseBuffer(self.default_assets.sprite_buf.hdl);
    self.device.releaseTexture(self.default_assets.default_texture);
    self.device.releaseTexture(self.default_assets.black_texture);
    self.device.releaseTexture(self.default_assets.white_texture);
    self.device.releaseSampler(self.default_assets.sampler);

    self.outlined.deinit(self.gpa);
    self.sprites.deinit(self.gpa);
    self.uniforms.deinit(self.gpa);
    self.arena.deinit();

    self.device.destroy();

    const gpa = self.gpa;
    gpa.destroy(self);
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

    const dst_region = sdl.gpu.BufferRegion{
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

    self.default_assets.pending_submit_result = .{};

    var drawable_w: u32 = undefined;
    var drawable_h: u32 = undefined;

    const cmd = self.device.acquireCommandBuffer() orelse {
        std.log.err("could not acquire command buffer", .{});
        return error.SDLError;
    };

    var swapchain: ?*sdl.gpu.Texture = null;
    if (!cmd.acquireSwapchainTexture(self.window.hdl, &swapchain, &drawable_w, &drawable_h)) {
        std.log.err("Could not acquire swapchain texture", .{});
        return error.AcquireSwapchainError;
    } else if (swapchain) |s| {
        if (self.window_state.prev_drawable_w != drawable_w or self.window_state.prev_drawable_h != drawable_h) {
            self.default_assets.forward_pass.resize(drawable_w, drawable_h);
        }

        self.window_state.prev_drawable_w = drawable_w;
        self.window_state.prev_drawable_h = drawable_h;

        self.default_assets.active_target = s;
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

pub fn render(self: *Gpu, cmd: *sdl.gpu.CommandBuffer, scene: *Scene, time: u64) !void {
    const zone = @import("ztracy").Zone(@src());
    defer zone.End();
    const arena = self.arena.allocator();

    try self.uniforms.put(self.gpa, self.ids.view, .{ .mat4x4 = scene.view.m });
    try self.uniforms.put(self.gpa, self.ids.projection, .{ .mat4x4 = scene.proj.m });
    try self.uniforms.put(self.gpa, self.ids.view_projection, .{ .mat4x4 = scene.view.mul(scene.proj).m });
    try self.uniforms.put(self.gpa, self.ids.camera_world_position, .{ .f32x3 = scene.camera_world_pos.v });
    try self.uniforms.put(self.gpa, self.ids.light_direction, .{ .f32x3 = scene.light_dir.v });
    try self.uniforms.put(self.gpa, self.ids.viewport_size, .{ .f32x4 = .{ @floatFromInt(self.window_state.prev_drawable_w), @floatFromInt(self.window_state.prev_drawable_h), 0, 0 } });
    try self.uniforms.put(self.gpa, self.ids.time, .{ .f32 = @as(f32, @floatFromInt(time)) / std.time.ns_per_s });

    const render_pack = try self.renderables.packAll(arena);
    const transforms = render_pack.transforms;
    try self.uploadToBuffer(self.default_assets.obj_buf.hdl, 0, std.mem.sliceAsBytes(transforms));

    try self.uploadToBuffer(self.default_assets.sprite_buf.hdl, 0, self.materials.param_buf.items);

    // Render forward pass
    self.doPass(.{
        .cmd = cmd,
        .scene = scene.*,
        .targets = self.default_assets.forward_pass.targets(),
        .items = .{ .pack = render_pack },
    }) catch unreachable;

    self.blitToScreen(
        cmd,
        self.default_assets.active_target.?,
        self.default_assets.forward_pass.texture(),
        self.default_assets.forward_pass.texture(),
        self.uniforms.get(self.ids.viewport_size).?.f32x4,
    );
}

pub fn submit(self: *Gpu, cmd: *sdl.gpu.CommandBuffer) RenderSubmitResult {
    const zone = @import("ztracy").Zone(@src());
    defer zone.End();

    _ = cmd.submit();
    _ = self.arena.reset(.retain_capacity);
    const result = self.default_assets.pending_submit_result.?;
    self.default_assets.pending_submit_result = null;
    self.default_assets.active_target = null;
    return result;
}

/// The vertex data for blitToScreen is hard coded into the shader,
/// so we only need to supply textures and draw 3 vertices.
pub fn blitToScreen(
    self: *Gpu,
    cmd: *sdl.gpu.CommandBuffer,
    screen_tex: *sdl.gpu.Texture,
    scene_tex: *sdl.gpu.Texture,
    mask_tex: *sdl.gpu.Texture,
    viewport_size: [4]f32,
) void {
    const color: sdl.gpu.ColorTargetInfo = .{
        .texture = screen_tex,
        .load_op = .clear,
        .store_op = .store,
        .clear_color = .{ .r = 0.15, .g = 0.15, .b = 0.15, .a = 1 },
        .cycle = false,
    };

    const pass = cmd.beginRenderPass((&color)[0..1], 1, null) orelse
        panic("error begin render pass {s}", .{sdl.getError()});
    defer pass.end();

    pass.bindGraphicsPipeline(self.materials.templates.get(.post_process).pipeline);

    const binding = [_]sdl.gpu.TextureSamplerBinding{
        .{ .sampler = self.default_assets.sampler, .texture = scene_tex },
        .{ .sampler = self.default_assets.sampler, .texture = mask_tex },
    };

    pass.bindFragmentSamplers(0, &binding, 2);

    cmd.pushFragmentUniformData(0, std.mem.asBytes(&viewport_size), @sizeOf(@TypeOf(viewport_size)));

    pass.drawPrimitives(3, 1, 0, 0);
}

const PassIterator = union(enum) {
    renderables: []const rbl.Renderable,
    handles: []const rbl.RenderItemHandle,
    iterator: rbl.RenderList.Iterator,
    pack: rbl.PackedRenderables,
};

pub const PassTargets = struct {
    color: []const sdl.gpu.ColorTargetInfo,
    depth: ?*const sdl.gpu.DepthStencilTargetInfo,
};

const PassInfo = struct {
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
    pass.setStencilReference(1);
    defer pass.end();

    var last_pipeline: ?*sdl.gpu.GraphicsPipeline = null;

    switch (job.items) {
        .renderables => |items| for (items, 0..) |item, i| {
            try self.draw(&job, pass, @intCast(i), 1, item.mesh, &last_pipeline);
        },
        .handles => |handles| for (handles) |hdl| {
            const item = self.renderables.items.get(hdl) orelse continue;
            try self.draw(&job, pass, @intCast(hdl.index), 1, item.mesh, &last_pipeline);
        },
        .iterator => |iterator| {
            var it = iterator;
            while (it.next()) |value| {
                try self.draw(&job, pass, @intCast(it.index()), 1, value.mesh, &last_pipeline);
            }
        },
        .pack => |pack| {
            var total_instances_rendered: u32 = 0;
            for (0..pack.len) |i| {
                const mesh = pack.meshes[i];
                try self.draw(&job, pass, total_instances_rendered, pack.instance_counts[i], mesh, &last_pipeline);
                total_instances_rendered += pack.instance_counts[i];
            }
        },
    }
}

fn draw(
    self: *Gpu,
    job: *const PassInfo,
    pass: *sdl.gpu.RenderPass,
    num_first_instance: u32,
    num_instances: u32,
    mesh: Mesh,
    last_pipeline: *?*sdl.gpu.GraphicsPipeline,
) !void {
    const zone = @import("ztracy").ZoneN(@src(), "RenderInstanced");
    defer zone.End();

    const material = if (job.material) |m| m else self.materials.get(mesh.material) orelse {
        std.debug.panic("No valid material found", .{});
    };
    const buffer = mesh.buffer;

    if (last_pipeline.* != material.pipeline) {
        pass.bindGraphicsPipeline(material.pipeline);
        last_pipeline.* = material.pipeline;
    }

    try self.uniforms.put(self.gpa, self.ids.material_idx, .{ .u32 = @intCast(material.params_start) });

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

        for (program_def.storage_buffers, 0..) |storage_buffer_name, i| {
            if (self.uniforms.get(storage_buffer_name)) |value| {
                pushStorageBuffer(pass, @intCast(i), &[_]*sdl.gpu.Buffer{value.buffer}, 1);
            }
        }

        for (program_def.uniforms, 0..) |uniform_name, i| {
            if (self.uniforms.get(uniform_name)) |value| {
                const idx: u32 = @intCast(i);
                switch (value) {
                    .u32 => |*data| pushUniform(job.cmd, idx, std.mem.asBytes(data), @sizeOf(@TypeOf(data.*))),
                    .u32x4 => |*data| pushUniform(job.cmd, idx, std.mem.asBytes(data), @sizeOf(@TypeOf(data.*))),
                    .f32 => |*data| pushUniform(job.cmd, idx, std.mem.asBytes(data), @sizeOf(@TypeOf(data.*))),
                    .f64 => |*data| pushUniform(job.cmd, idx, std.mem.asBytes(data), @sizeOf(@TypeOf(data.*))),
                    .f32x3 => |*data| pushUniform(job.cmd, idx, std.mem.asBytes(data), @sizeOf(@TypeOf(data.*))),
                    .f32x4 => |*data| pushUniform(job.cmd, idx, std.mem.asBytes(data), @sizeOf(@TypeOf(data.*))),
                    .mat4x4 => |*data| pushUniform(job.cmd, idx, std.mem.asBytes(data), @sizeOf(@TypeOf(data.*))),
                    .buffer => unreachable,
                }
            }
        }

        for (program_def.textures, 0..) |needed_tex_type, i| {
            if (needed_tex_type == null) continue;
            const tex_id = material.textures.get(needed_tex_type.?).?;
            const texture: *sdl.gpu.Texture = blk: {
                if (tex_id.target) |target| break :blk target;
                if (tex_id.handle) |handle| break :blk self.textures.get(handle) catch self.default_assets.default_texture orelse self.default_assets.default_texture;
                panic("[GPU] Textures must have a handle or direct target defined", .{});
            };

            const binding = [_]sdl.gpu.TextureSamplerBinding{.{ .sampler = self.default_assets.sampler, .texture = texture }};

            pushSampler(pass, @intCast(i), &binding, 1);
        }
    }

    pass.bindVertexBuffers(0, &.{ .buffer = buffer.hdl, .offset = @intCast(buffer.offset) }, 1);
    pass.bindIndexBuffer(&.{ .buffer = buffer.hdl, .offset = @intCast(buffer.idx_start) }, .@"32bit");
    pass.drawIndexedPrimitives(buffer.idxCount(), num_instances, 0, 0, num_first_instance);
}

pub fn buildPipeline(self: *Gpu, params: BuildPipelineParams) *sdl.gpu.GraphicsPipeline {
    const sample_count = .@"1";

    const color_target_desc: []const sdl.gpu.ColorTargetDescription = &.{.{
        .format = params.format orelse self.device.getSwapchainTextureFormat(self.window.hdl),
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

    const vertex_buffer_desc: []const sdl.gpu.VertexBufferDescription = switch (params.pass) {
        .default => &.{.{
            .slot = 0,
            .input_rate = .vertex,
            .instance_step_rate = 0,
            .pitch = @sizeOf(Vertex),
        }},
        .post_process => &.{},
        .ui => &.{.{
            .slot = 0,
            .input_rate = .vertex,
            .instance_step_rate = 0,
            .pitch = @sizeOf(f32) * 8, // from IMGUI: vec2 pos, vec2 uv, vec4 col
        }},
    };

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
        .post_process => &.{},
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

    const stencil_state: sdl.gpu.StencilOpState = .{
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
        .primitive_type = params.primitive_type,
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

pub fn materialCreate(self: *Gpu, mt_type: mt.Material.Type, txs: *const TextureArray) !MaterialHandle {
    var map: tx.TextureSet = .{};

    for (std.meta.tags(tx.TextureType), 0..) |tag, i| {
        map.put(tag, .{ .handle = txs[i] });
    }

    return self.materials.insert(mt_type, map);
}

pub fn importModel(self: *Gpu, path: [*:0]const u8, settings: Models.ImportSettings) !Model {
    const path_slice = std.mem.span(path);
    const allocator = self.arena.allocator();

    var import = ai.importFile(path_slice, settings.post_process);
    // Don't release the scene, it will be passed to models for read.

    var materials_array = try allocator.alloc(mt.Handle, import.num_materials);

    // Material indices start at one for assimp imports
    materials_array[0] = mt.Handle.invalid;
    for (import.materials[1..import.num_materials], 1..) |ai_material, mat_index| {
        var texture_set = TextureSet.init(.{});

        inline for (std.meta.fields(ai.TextureType)) |field| {
            const tex_type: ai.TextureType = @enumFromInt(field.value);
            const count = ai_material.getTextureCount(tex_type);
            for (0..count) |i| {
                var str: ai.String = undefined;
                _ = ai_material.getTexture(ai.Material.GetTextureInfo{
                    .tex_type = tex_type,
                    .index = @intCast(i),
                    .path = &str,
                });

                const ai_tex_id: [:0]u8 = str.data[0..str.len :0];
                var tex_id: [:0]u8 = ai_tex_id;
                var handle: ?TextureHandle = null;

                if (import.getEmbeddedTexture(ai_tex_id.ptr)) |tex| {
                    _ = tex;
                    unreachable;
                } else { // Texture is a relative path
                    tex_id = try std.fs.path.joinZ(self.arena.allocator(), &[_][]const u8{ std.fs.path.dirname(path_slice).?, ai_tex_id });
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

        const material = self.materials.insert(.standard, texture_set);
        materials_array[mat_index] = material;
    }

    const model = try self.models.read(import, materials_array, settings);
    return model;
}

pub fn createModel(self: *Gpu, verts: []const Vertex, indices: []const u32, material: mt.Handle) !Model {
    const alloc_buffer = try self.buffer_allocator.alloc(
        @intCast(@sizeOf(Vertex) * verts.len +
            @sizeOf(u32) * indices.len),
    );

    const buffer: buf.VertexIndexBuffer = .{
        .hdl = alloc_buffer.hdl,
        .size = alloc_buffer.size,
        .offset = alloc_buffer.offset,
        .idx_start = @intCast(alloc_buffer.offset + @sizeOf(Vertex) * verts.len),
    };

    try self.uploadToBuffer(buffer.hdl, buffer.offset, std.mem.sliceAsBytes(verts));
    try self.uploadToBuffer(buffer.hdl, buffer.idx_start, std.mem.sliceAsBytes(indices));

    var mesh = try self.models.allocator.alloc(Mesh, 1);
    errdefer self.models.allocator.destroy(mesh);

    mesh[0] = .{
        .buffer = buffer,
        .material = material,
    };

    const model: mdl.Model = .{
        .children = mesh,
        .transform = mat4.identity,
        .bounds = primitives.Cube.bounds,
    };

    return self.models.add(model);
}

pub fn modelPrimitive(self: *Gpu, shape: primitives.Shape) Model {
    return switch (shape) {
        .cube => return self.default_assets.cube,
        .quad => return self.default_assets.quad,
        .sphere => return self.default_assets.sphere,
    };
}

pub fn selectRenderable(self: *Gpu, handle: rbl.RenderItemHandle) void {
    self.outlined.put(self.gpa, handle, {}) catch hy.err.oom();
}

pub fn renderableSetTransform(
    self: *Gpu,
    handle: rbl.RenderItemHandle,
    transform: mat4.Mat4,
) void {
    const renderable = self.renderables.items.getPtr(handle) orelse {
        log.warn("Renderable set transform called when no renderable exists", .{});
        return;
    };

    renderable.transform = transform;
}

pub const SpriteCreateOptions = extern struct {
    atlas: [*:0]const u8,
    width: u16,
    height: u16,
    offset: u16,
    len: u16,
    speed: f32,
    color: [4]f32,

    comptime {
        hy.meta.assertMatches(SpriteCreateOptions, hy.Gpu.SpriteCreateOptions);
    }
};

pub fn spriteCreate(self: *Gpu, opts: SpriteCreateOptions) !hy.SlotMap(Sprite).Handle {
    std.debug.assert(opts.width != 0);
    std.debug.assert(opts.height != 0);

    const mat_hdl = blk: {
        const span = std.mem.span(opts.atlas);
        if (std.mem.eql(u8, span, "white")) {
            const tex = self.default_assets.white_texture;
            break :blk self.materials.insert(.billboard, .init(.{ .diffuse = .{ .target = tex } }));
        } else {
            const tex = try self.textures.read(std.mem.span(opts.atlas));
            break :blk self.materials.insert(.billboard, .init(.{ .diffuse = .{ .handle = tex } }));
        }
    };

    const quad = try self.models.dupe(self.default_assets.quad, .{ .material = mat_hdl });

    self.materials.setParams(mat_hdl, &Gpu.GpuSprite{
        .width = opts.width,
        .height = opts.height,
        .offset = opts.offset,
        .len = if (opts.len == 0) opts.width * opts.height else opts.len,
        .speed = opts.speed,
        .color = opts.color,
    });

    const sprite_hdl = self.sprites.insert(self.gpa, .{ .model = quad, .material = mat_hdl });

    return sprite_hdl;
}

pub fn spriteDestroy(self: *Gpu, hdl: hy.SlotMap(Sprite).Handle) void {
    const sprite = self.sprites.get(hdl) orelse {
        std.debug.panic("No sprite found for handle {}", .{hdl});
    };

    self.materialDestroy(sprite.material);
    self.models.remove(sprite.model);
}

pub fn spriteWeakPointer(self: *Gpu, hdl: RenderItemHandle) ?*GpuSprite {
    const renderable = (self.renderables.items.getPtr(hdl) orelse return null);
    const mat_hdl = renderable.mesh.material;
    const mat = self.materials.get(mat_hdl) orelse return null;
    const ptr: *Gpu.GpuSprite = @ptrCast(@alignCast(&self.materials.param_buf.items[mat.params_start]));
    return ptr;
}

pub fn spriteCurrentIndex(self: *Gpu, sprite: *GpuSprite) u32 {
    const time = blk: {
        if (self.uniforms.get(self.ids.time)) |t| break :blk t.f32 else break :blk 0;
    };
    const counter: u32 = @intFromFloat(@max(0, time * sprite.speed + sprite.time_offset));
    const index = (counter % sprite.len) + sprite.offset;
    return index;
}

pub fn spriteDupe(self: *Gpu, hdl: SpriteHandle) SpriteHandle {
    const sprite = self.sprites.getPtr(hdl).?;
    const mat_hdl = sprite.material;
    const mat = self.materials.get(mat_hdl).?;

    const duped_mat = self.materials.insert(.billboard, mat.textures);
    const sprite_data: *align(1) GpuSprite = @ptrCast(&self.materials.param_buf.items[mat.params_start]);
    self.materials.setParams(duped_mat, sprite_data);

    const quad = self.models.dupe(self.default_assets.quad, .{ .material = duped_mat }) catch hy.err.oom();
    const sprite_hdl = self.sprites.insert(self.gpa, .{ .model = quad, .material = duped_mat }) catch hy.err.oom();
    return sprite_hdl;
}

pub fn renderableOfSprite(self: *Gpu, hdl: SpriteHandle) !RenderItemHandle {
    const sprite = self.sprites.get(hdl).?;

    const renderable = try self.renderables.add(.{
        .model = sprite.model,
        .time = 0,
    });

    return renderable;
}

pub fn materialDestroy(self: *Gpu, handle: SlotMap(mt.Material).Handle) void {
    var mat = self.materials.get(handle) orelse {
        std.debug.panic("No material found for handle {}", .{handle});
    };
    mat.deinit(&self.textures);
    self.materials.remove(handle);
}

pub fn renderableDestroy(self: *Gpu, handle: RenderItemHandle) void {
    self.renderables.remove(handle);
}
