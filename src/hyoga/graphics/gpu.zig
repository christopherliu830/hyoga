const std = @import("std");
const sdl = @import("sdl");
const sdlsc = @import("sdl_shadercross");
const ai = @import("assimp");
const build_options = @import("build_options");

const hysm = @import("hyoga-slotmap");
const hym = @import("hyoga-math");
const vec3 = hym.vec3;
const mat4 = hym.mat4;
const hym_cam = hym.cam;

const stb = @import("stb_image");
const Window = @import("../window.zig");

const cube = @import("primitives.zig").createCube();

const tx = @import("texture.zig");
const mdl = @import("model.zig");
const mt = @import("material.zig");
const Loader = @import("loader.zig");
const Symbol = @import("../Symbol.zig");
const Vertex = @import("vertex.zig").Vertex;
const scn = @import("Scene.zig");
const passes = @import("passes.zig");
const rbl = @import("renderable.zig");

const Gpu = @This();

pub const ModelHandle = mdl.Handle;

pub const RenderItemHandle = rbl.RenderItemHandle;

pub const Buffer = struct {
    hdl: ?*sdl.gpu.Buffer = null,
    hdl_transfer: ?*sdl.gpu.TransferBuffer = null,
    size: u32,
    vtx_start: u32 = 0,
    idx_start: u32 = std.math.maxInt(u32),
    idx_size: u32 = 0,

    pub inline fn idxCount(self: Buffer) u32 {
        return (self.size - self.idx_start) / @sizeOf(u32);
    }
};

pub const Scene = extern struct {
    view_proj: mat4.Mat4,
    light_dir: vec3.Vec3,
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
    format: ?sdl.gpu.TextureFormat = null,
    vert: *sdl.gpu.Shader,
    frag: *sdl.gpu.Shader,
    pass: PassType,
    enable_depth: bool = true,
    enable_stencil: bool = true,
};

const RenderState = struct {
    forward_pass: passes.Forward,
    blit_pass: passes.BlitPass,

    default_material: mt.MaterialTemplate,
    post_material: mt.MaterialTemplate,
    outline_material: mt.MaterialTemplate,

    default_texture: *sdl.gpu.Texture,

    sampler: *sdl.gpu.Sampler = undefined,

    renderables: rbl.RenderList,
    outline_renderables: rbl.RenderList,

    ssbo: scn.SceneBuffer,
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

device: *sdl.gpu.Device,
gpa: std.mem.Allocator,
arena: std.heap.ArenaAllocator,
loader: *Loader,
swapchain_target_desc: sdl.gpu.ColorTargetDescription,
frames: u32 = 0,
symbol: *Symbol,
render_state: RenderState = undefined,
window_state: WindowState = .{},
speed: f32 = 1,
textures: tx.Textures,
models: mdl.Models,
materials: hysm.SlotMap(mt.Material),

pub fn init(window: *Window, loader: *Loader, symbol: *Symbol, gpa: std.mem.Allocator) !*Gpu {
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
        .device = d,
        .swapchain_target_desc = .{ .format = d.getSwapchainTextureFormat(window.hdl) },
        .loader = loader,
        .symbol = symbol,
        .textures = tx.Textures.create(d, loader, symbol, gpa),
        .models = mdl.Models.create(loader, symbol, gpa),
        .materials = try hysm.SlotMap(mt.Material).create(gpa, 1),
        .window_state = .{ .window = window }
    };

    try sdlsc.init();

    const material = try mt.readFromPath(self, .{
        .path = "shaders/standard",
        .enable_depth = true,
        .enable_stencil = false,
    }, self.arena.allocator());

    // Generate unloaded texture pattern

    const texture = self.device.createTexture(&.{
        .format = .b8g8r8a8_unorm, 
        .height = 256,
        .width = 256,
        .layer_count_or_depth = 1,
        .num_levels = 1,
        .sample_count = .@"1",
        .usage = .{ .sampler = true }
    }).?;

    var buf: [256 * 256]u32 = [_]u32{0xffffffff} ** (256 * 256);
    const black = 0xff000000;

    for (0..256) |i| {
        for (0..256) |j| {
            if ((i + j) % 2 == 0) {
                @memset(buf[i * 256 + j .. i * 256 + j + 1], black);
            }
        }
    }

    try self.uploadToTexture(texture, 256, 256, &std.mem.toBytes(buf));

    var w: c_int = 0;
    var h: c_int = 0;
    _ = sdl.video.getWindowSizeInPixels(window.hdl, &w, &h);

    const sampler_info = sdl.gpu.SamplerCreateInfo {
        .address_mode_u = .clamp_to_edge,
        .address_mode_v = .clamp_to_edge,
        .address_mode_w = .clamp_to_edge,
        .min_filter = .linear,
        .mag_filter = .linear,
    };

    const quad_mat_template = try mt.readFromPath(self, .{
        .path = "shaders/post_process",
        .enable_depth = false,
        .enable_stencil = false,
    }, self.gpa);
    
    const scene_buf = scn.SceneBuffer {
        .device = self.device,
    };

    self.render_state = .{
        .forward_pass = passes.Forward.init(self.device, .{
            .clear_color = .{ .r = 0.2, .g = 0.2, .b = 0.4, .a = 1 },
            .depth_enabled = true,
            .stencil_enabled = false,
            .dest_format = self.swapchain_target_desc.format,
            .dest_usage = .{ .color_target = true, .sampler = true },
            .dest_tex_width = @intCast(w),
            .dest_tex_height = @intCast(h),
        }),

        .blit_pass = passes.BlitPass.init(self, self.device),

        .renderables = try rbl.RenderList.init(self, self.gpa),
        .outline_renderables = try rbl.RenderList.init(self, self.gpa),

        .default_material = material,
        .default_texture = texture,

        .post_material = quad_mat_template,

        .outline_material = try mt.readFromPath(self, .{
            .path = "shaders/outline",
            .enable_depth = false,
            .enable_stencil = false,
            .format = .r8_unorm,
        }, self.gpa),

        .sampler = self.device.createSampler(&sampler_info).?,
        .ssbo = scene_buf,
        .active_target = null,
    };

    return self;
}

pub fn shutdown(self: *Gpu) void {
    sdlsc.quit();

    self.device.releaseWindow(self.window_state.window.hdl);

    {
        var it = self.render_state.renderables.iterator();
        while (it.next()) |obj| {
            self.device.releaseBuffer(obj.mesh.buffer.hdl);
        }
    }

    self.textures.deinit();
    self.models.deinit();
    self.materials.deinit();

    self.device.releaseTexture(self.render_state.default_texture);
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

    const acquire = @import("ztracy").ZoneN(@src(), "acquireCommandBuffer");
    const cmd = self.device.acquireCommandBuffer() orelse {
        std.log.err("could not acquire command buffer", .{});
        return error.SDLError;
    };
    acquire.End();

    const acquireSwapchainTexture = @import("ztracy").ZoneN(@src(), "acquireSwapchainTexture");
    defer acquireSwapchainTexture.End();
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
        self.window_state.window.aspect = @as(f32, @floatFromInt(drawable_w)) / @as(f32, @floatFromInt(drawable_h));

        self.render_state.active_target = s;
        return cmd;
    } else {
        // No swapchain was acquired, probably too many frames in flight.
        _ = cmd.cancel();
        return null;
    }
}

pub fn render(self: *Gpu, cmd: *sdl.gpu.CommandBuffer, scene: *Scene) !void {
    const zone = @import("ztracy").Zone(@src());
    defer zone.End();


    const render_scene = scn.Scene {
        .viewport_size_x = @intCast(self.window_state.prev_drawable_w),
        .viewport_size_y = @intCast(self.window_state.prev_drawable_h),
        .view_proj = scene.view_proj,
        .light_dir = scene.light_dir,
        .start_renderables = .{ mat4.identity },
    };

    const items = try self.render_state.renderables.copyItems(self.arena.allocator());
    self.render_state.ssbo.update(render_scene, items);

    // First render scene to texture target
    const all_items = self.render_state.renderables.items.iterator();

    self.doPass(.{
        .cmd = cmd,
        .scene = scene.*,
        .targets = self.render_state.forward_pass.targets(),
        .iterator = all_items,
    }) catch {};

    // Render selected objects as mask for outline
    const mask = passes.Forward.init(self.device, .{
        .dest_format = .r8_unorm,
        .dest_usage = .{ .color_target = true, .sampler = true },
        .dest_tex_width = @intCast(self.window_state.prev_drawable_w),
        .dest_tex_height = @intCast(self.window_state.prev_drawable_h),
    });
    defer mask.deinit();

    const selected_mask = self.render_state.outline_renderables.items.iterator();
    self.doPass(.{
        .cmd = cmd,
        .scene = scene.*,
        .material = mt.Material.fromTemplate(self.render_state.outline_material, .{}),
        .targets = mask.targets(),
        .iterator = selected_mask,
    }) catch {};

    self.doPass(.{
        .cmd = cmd,
        .scene = scene.*,
        .targets = self.render_state.blit_pass.targets(self.render_state.active_target.?),
        .items = (&self.render_state.blit_pass.quad)[0..1],
        .material = mt.Material.fromTemplate(
            self.render_state.post_material,
            tx.TextureSet.init(.{
                .diffuse = .{ .target = self.render_state.forward_pass.texture() },
                .mask = .{ .target = mask.texture() },
            }),
        ),
    }) catch {};
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

pub const PassInfo = struct {
    cmd: *sdl.gpu.CommandBuffer,
    items: []const rbl.Renderable = &.{},
    iterator: ?rbl.RenderList.Iterator = null,
    material: ?mt.Material = null, // force every object to use the same material
    targets: PassTargets,
    scene: Scene,
};

pub fn doPass(self: *Gpu, job: PassInfo) !void {
    if (job.items.len == 0 and job.iterator == null) return;
    const zone = @import("ztracy").Zone(@src());
    defer zone.End();

    const color = job.targets.color;
    const depth = job.targets.depth;
    const pass = job.cmd.beginRenderPass(color.ptr, @intCast(color.len), depth).?;
    defer pass.end();

    var last_pipeline: ?*sdl.gpu.GraphicsPipeline = null;

    for (job.items) |item| try self.doPassOne(pass, item, job, &last_pipeline);

    var iterator = job.iterator;
    if (iterator) |*it| {
        while (it.next()) |value| {
            try self.doPassOne(pass, value, job, &last_pipeline);
        }
    }
}

fn doPassOne(self: *Gpu,
             pass: *sdl.gpu.RenderPass,
             item: rbl.Renderable,
             job: PassInfo,
             last_pipeline: *?*sdl.gpu.GraphicsPipeline) !void
{
    const zone = @import("ztracy").ZoneN(@src(), "RenderOne");
    defer zone.End();

    const material = if (job.material) |m| m 
        else try self.materials.get(item.mesh.material);

    if (last_pipeline.* == null or material.pipeline != last_pipeline.*.?) {
        last_pipeline.* = material.pipeline;
        pass.bindGraphicsPipeline(material.pipeline);
    }

    inline for (.{
        .{ material.vert_program_def, sdl.gpu.CommandBuffer.pushVertexUniformData, sdl.gpu.RenderPass.bindVertexSamplers },
        .{ material.frag_program_def, sdl.gpu.CommandBuffer.pushFragmentUniformData, sdl.gpu.RenderPass.bindFragmentSamplers },
    }) |params| {
        const program_def = params[0];
        const pushUniform = params[1];
        const pushSampler = params[2];

        if (program_def.uniform_location_mvp) |slot_index| {
            const mat_model = mat4.mul((item.parent_transform orelse &mat4.identity).*, item.transform);
            const ubo = mt.uniform.Transform{
                .inverse_model = mat4.transpose(mat4.inverse(item.transform)),
                .view_proj = job.scene.view_proj,
                .model = mat_model,
            };
            pushUniform(job.cmd, slot_index, &ubo, @sizeOf(mt.uniform.Transform));
        }

        if (program_def.uniform_location_lighting) |slot_index| {
            const lighting_ubo = mt.uniform.Lighting {
                .light_dir = job.scene.light_dir,
                .camera_pos = vec3.zero,
            };
            pushUniform(job.cmd, slot_index, &lighting_ubo, @sizeOf(mt.uniform.Lighting));
        }

        if (program_def.uniform_location_window) |slot_index| {
            const window = mt.uniform.Window {
                .size_x = @intCast(self.window_state.prev_drawable_w),
                .size_y = @intCast(self.window_state.prev_drawable_h),
            };
            pushUniform(job.cmd, slot_index, &window, @sizeOf(mt.uniform.Window));
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

    const buffer = item.mesh.buffer;
    pass.bindVertexBuffers(0, &.{ .buffer = buffer.hdl.?, .offset = @intCast(buffer.vtx_start) }, 1);
    pass.bindIndexBuffer(&.{ .buffer = buffer.hdl.?, .offset = @intCast(buffer.idx_start) }, .@"32bit");
    pass.drawIndexedPrimitives(buffer.idxCount(), 1, 0, 0, 0);
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

pub fn importModel(self: *Gpu, path: Symbol.ID, settings: mdl.ImportSettings) !mdl.Handle {
    var import = ai.importFile( self.symbol.asStringZ(path), settings.post_process);
    defer import.release();
    const allocator = self.arena.allocator();

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
                    // tex_id = try std.mem.concatWithSentinel(self.allocator, u8, &.{ path, ai_tex_id }, 0);
                    // if (tex.height == 0) {
                    //     const data = std.mem.sliceAsBytes(tex.pc_data[0..tex.width]);
                    //     handle = try createTextureFromImageMemory(tex_id, data);
                    // } else {
                    //     const data = std.mem.sliceAsBytes(tex.pc_data[0 .. tex.width * tex.height]);
                    //     handle = try createTextureFromMemory(tex_id, .{ .w = tex.width, .h = tex.height, .d = 4, .data = data, .format = .b8g8r8a8_unorm });
                    // }
                } else { // Texture is a relative path
                    tex_id = try std.fs.path.joinZ(self.arena.allocator(), &[_][]const u8{ 
                        std.fs.path.dirname(self.symbol.asString(path)).?,
                        ai_tex_id
                    });
                    handle = try self.textures.read(tex_id);
                }

                std.debug.assert(handle != null);

                const hy_tex_type: ?tx.TextureType = tx.tex_to_hyoga_type.get(tex_type);
                if (hy_tex_type) |htt| {
                    texture_set.put(htt, .{ .handle = handle });
                } else {
                    std.log.warn("[GPU]: Unconsumed texture type {s} for object {s}", .{ field.name, self.symbol.asString(path) });
                }
            }
        }
        const material = mt.Material.fromTemplate(self.render_state.default_material, texture_set);
        const hdl = try self.materials.insert(material);
        materials_array[mat_index] = hdl;
    }

    const model = try self.models.read(self.symbol.asStringZ(path), materials_array, settings);
    return model;
}

pub fn addMaterial(self: *Gpu, material: mt.Material) !mt.Handle {
    std.debug.assert(material.textures.len > 0);
    return self.materials.insert(material);
}
