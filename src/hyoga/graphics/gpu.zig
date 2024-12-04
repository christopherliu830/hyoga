const std = @import("std");
const sdl = @import("sdl");
const ai = @import("assimp");

const hya = @import("hyoga-arena");
const hym = @import("hyoga-math");
const vec3 = hym.vec3;
const mat4 = hym.mat4;
const hym_cam = hym.cam;

const camera = @import("../camera.zig");
const stb = @import("stb_image");
const window = @import("../window.zig");

const cube = @import("primitives.zig").createCube();

const tx = @import("texture.zig");
const mdl = @import("model.zig");
const mt = @import("material.zig");

const Vertex = @import("vertex.zig").Vertex;

// Exports
pub const RenderItemHandle = hya.Handle(RenderItem);
pub const ModelHandle = mdl.Handle;

pub const Scene = struct {
    camera: camera.Camera, 
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
    vert: *sdl.gpu.Shader,
    frag: *sdl.gpu.Shader,
    pass: PassType,
    enable_depth: bool = true,
    enable_stencil: bool = true,
};

const RenderItem = struct {
    next: ?RenderItemHandle = null,
    buf: *sdl.gpu.Buffer,
    transform: mat4.Mat4 = mat4.identity,
    parent_transform: ?*mat4.Mat4 = null,
    idx_offset: u32,
    idx_count: u32,
    material: mt.Handle,
};

const RenderState = struct {
    default_material: mt.MaterialTemplate,
    post_material: mt.MaterialTemplate,
    outline_pipeline: *sdl.gpu.GraphicsPipeline,
    quad_buffer: *sdl.gpu.Buffer,
    sampler: *sdl.gpu.Sampler = undefined,

    textures: tx.Arena,
    texture_cache: tx.Cache,

    models: mdl.Arena,
    materials: hya.Arena(mt.Material),
    objs: hya.Arena(RenderItem),
    robjs: PassInfo,

    scene: *Scene = undefined,

    active_target: ?*sdl.gpu.Texture,
    pending_submit_result: ?RenderSubmitResult = null,
};

const PassInfo = struct {
    items: hya.Arena(RenderItem),
    targets: []const sdl.gpu.ColorTargetInfo,
    depth_target: ?*const sdl.gpu.DepthStencilTargetInfo,
};

const GPU = struct {
    allocator: std.mem.Allocator,
    arena: std.heap.ArenaAllocator,
    device: *sdl.gpu.Device,
    swapchain_target_desc: sdl.gpu.ColorTargetDescription,
    frames: u32 = 0,
};

const WindowState = struct {
    hdl_window: *sdl.Window = undefined,
    angle: vec3.Vec3 = vec3.zero,
    cam_position: vec3.Vec3 = vec3.create(0, 0, 2.5),
    tex_depth: *sdl.gpu.Texture = undefined,
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

pub var ctx: GPU = undefined;
pub var render_state: RenderState = undefined;
pub var window_state: WindowState = .{};

pub var speed: f32 = 1;

pub fn init(hdl_window: *sdl.Window, gpa: std.mem.Allocator) !void {
    window_state.hdl_window = hdl_window;
    const d = sdl.gpu.createDevice(.{ 
        .spirv = true,
        .metallib = true,
    }, true, null).?;
    _ = d.claimWindow(hdl_window);
    std.log.info("[GPU] Selected backend: {s}", .{d.getDeviceDriver()});

    ctx = .{
        .allocator = gpa,
        .arena = std.heap.ArenaAllocator.init(gpa),
        .device = d,
        .swapchain_target_desc = .{
            .format = d.getSwapchainTextureFormat(hdl_window)
        }
    };

    stb.init(ctx.allocator);

    const material = mt.readFromPath(ctx.device, "shaders/standard", ctx.arena.allocator()) catch unreachable;

    var w: c_int = 0;
    var h: c_int = 0;
    _ = sdl.video.getWindowSizeInPixels(hdl_window, &w, &h);
    window_state.tex_depth = try createDepthTexture(@intCast(w), @intCast(h));

    const textures = try tx.Arena.create(ctx.allocator, 8);
    const texture_cache = tx.Cache.init(ctx.allocator);

    const sampler_info = sdl.gpu.SamplerCreateInfo {
        .address_mode_u = .clamp_to_edge,
        .address_mode_v = .clamp_to_edge,
        .address_mode_w = .clamp_to_edge,
        .min_filter = .linear,
        .mag_filter = .linear,
    };

    const Verts = extern struct {
        v: [16]f32,
        i: [6]u32,
    };
    const verts = Verts {
        .v = .{
            -1, -1, 0, 1,
            -1,  1, 0, 0,
             1, -1, 1, 1,
             1,  1, 1, 0, },
        .i = .{ 0, 3, 1, 0, 2, 3, }
    };

    const quad_buffer = ctx.device.createBuffer(&.{
        .size = @sizeOf(Verts),
        .usage = .{ .vertex = true, .index = true },
    }).?;
    
    const quad_mat_template = try mt.readFromPath(ctx.device, "shaders/post_process", ctx.arena.allocator());

    try uploadToBuffer(quad_buffer, 0, &std.mem.toBytes(verts));

    render_state = .{
        .objs = try hya.Arena(RenderItem).create(ctx.allocator, 1),
        .default_material = material,
        .post_material = quad_mat_template,
        // .outline_pipeline = createOutlineShader(),
        .outline_pipeline = undefined,
        .quad_buffer = quad_buffer,
        .sampler = ctx.device.createSampler(&sampler_info).?,
        .textures = textures,
        .texture_cache = texture_cache,
        .materials = try hya.Arena(mt.Material).create(ctx.allocator, 1),
        .models = try mdl.Arena.create(ctx.allocator, 8),
        .active_target = null,
        .robjs = undefined,
    };
}

pub fn shutdown() void {
    ctx.device.releaseWindow(window_state.hdl_window);

    var tx_it = render_state.textures.iterator();
    while (tx_it.next()) |item| {
        ctx.device.releaseTexture(item);
    }
    
    var it = render_state.texture_cache.keyIterator();
    while (it.next()) |key_str| {
        ctx.allocator.free(key_str.*);
    }

    var oit = render_state.objs.iterator();
    while (oit.next()) |obj| {
        ctx.device.releaseBuffer(obj.buf);
    }

    ctx.device.releaseBuffer(render_state.quad_buffer);
    ctx.device.releaseTexture(window_state.tex_depth);
    ctx.device.releaseSampler(render_state.sampler);
    // ctx.device.releaseGraphicsPipeline(render_state.outline_pipeline);
    ctx.device.releaseGraphicsPipeline(render_state.post_material.pipeline);
    ctx.device.releaseGraphicsPipeline(render_state.default_material.pipeline);
    ctx.device.destroy();

}

pub fn device() *sdl.gpu.Device {
    return ctx.device;
}

pub fn activeRenderTarget() ?*sdl.gpu.Texture {
    return render_state.active_target;
}

pub fn uploadToBuffer(buffer: *sdl.gpu.Buffer, offset: u32, data: []const u8) !void {
    const buf_transfer = ctx.device.createTransferBuffer(&.{
        .usage = .upload,
        .size = @intCast(data.len),
    }).?;
    defer ctx.device.releaseTransferBuffer(buf_transfer);

    const map: [*]u8 = @ptrCast(@alignCast(ctx.device.mapTransferBuffer(buf_transfer, false).?));
    @memcpy(map, data);
    ctx.device.unmapTransferBuffer(buf_transfer);

    const cmd = ctx.device.acquireCommandBuffer().?;

    const copy_pass = cmd.beginCopyPass().?;

    const buf_location = sdl.gpu.TransferBufferLocation {
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

pub fn uploadToTexture(tex: *sdl.gpu.Texture, w: u32, h: u32, data: []const u8) !void {
    const buf_transfer = ctx.device.createTransferBuffer(&.{
        .size = @intCast(data.len),
        .usage = .upload
    }).?;
    defer ctx.device.releaseTransferBuffer(buf_transfer);
    const ptr_transfer: [*]u8 = @ptrCast(@alignCast(ctx.device.mapTransferBuffer(buf_transfer, false).?));
    @memcpy(ptr_transfer, data);
    ctx.device.unmapTransferBuffer(buf_transfer);

    // copy to transfer buffer
    const cmd = ctx.device.acquireCommandBuffer().?;
    const copy_pass = cmd.beginCopyPass().?;

    const buf_src = sdl.gpu.TextureTransferInfo {
        .transfer_buffer = buf_transfer,
        .offset = 0,
        .pixels_per_row = w,
        .rows_per_layer = h,
    };

    const buf_dst = sdl.gpu.TextureRegion {
        .texture = tex,
        .w = w,
        .h = h,
        .d = 1,
    };

    copy_pass.uploadToTexture(&buf_src, &buf_dst, false);
    copy_pass.end();
    _ = cmd.submit();
}

pub fn begin() !*sdl.gpu.CommandBuffer {
    render_state.pending_submit_result = .{};

    var drawable_w: u32 = undefined;
    var drawable_h: u32 = undefined;

    const cmd = ctx.device.acquireCommandBuffer() orelse {
        std.log.err("could not acquire command buffer", .{});
        return error.SDLError;
    };

    var swapchain: ?*sdl.gpu.Texture = null;
    if (!cmd.acquireSwapchainTexture(window_state.hdl_window, &swapchain, &drawable_w, &drawable_h)) {
        std.log.err("Could not acquire swapchain texture", .{});
        return error.AcquireSwapchainError;
    }
    else if (swapchain) |s| {
        if (window_state.prev_drawable_w != drawable_w or window_state.prev_drawable_h != drawable_h) {
            ctx.device.releaseTexture(window_state.tex_depth);
            window_state.tex_depth = try createDepthTexture(drawable_w, drawable_h);
        }

        window_state.prev_drawable_w = drawable_w;
        window_state.prev_drawable_h = drawable_h;

        render_state.active_target = s;
            return cmd;
    } else {
        // No swapchain was acquired, probably too many frames in flight.
        _ = cmd.cancel();
        return error.NoSwapchain;
    }
}

pub fn render(cmd: *sdl.gpu.CommandBuffer, scene: *Scene) !void {

    // First render to texture target

    const tex = ctx.device.createTexture(&.{
        .type = .@"2d",
        .format = ctx.swapchain_target_desc.format,
        .usage = .{ .color_target = true, .sampler = true },
        .width = window_state.prev_drawable_w,
        .height = window_state.prev_drawable_h,
        .layer_count_or_depth = 1,
        .num_levels = 1,
        .sample_count = .@"1",
    }).?;

    const tex_hdl = try render_state.textures.insert(tex);
    defer render_state.textures.release(tex_hdl);
    defer ctx.device.releaseTexture(tex);

    const target: []const sdl.gpu.ColorTargetInfo = &.{
        .{
            .texture = tex,
            .clear_color = .{ .r = 0.2, .g = 0.2, .b = 0.2, .a = 0},
            .load_op = .clear,
            .store_op = .store,
            .cycle = true,
        }
    };

    const depth_target = sdl.gpu.DepthStencilTargetInfo {
        .clear_depth = 1,
        .clear_stencil = 0,
        .load_op = .clear,
        .store_op = .store,
        .stencil_load_op = .clear,
        .stencil_store_op = .store,
        .texture = window_state.tex_depth,
        .cycle = true,
    };

    var pass = PassInfo {
        .targets = target,
        .depth_target = &depth_target,
        .items = render_state.objs,
    };

    doPass(cmd, &pass, scene) catch {};

    const screen_target: []const sdl.gpu.ColorTargetInfo = &.{
        .{
            .texture = render_state.active_target,
            .load_op = .clear,
            .store_op = .store,
            .cycle = true,
        }
    };

    // Create objects needed to render to final target

    const material = mt.Material.fromTemplate(render_state.post_material, tx.TextureSet.init(.{ .diffuse = tex_hdl }));
    const hdl_material = try render_state.materials.insert(material);
    defer render_state.materials.release(hdl_material);

    const render_object = RenderItem {
        .buf = render_state.quad_buffer,
        .idx_count = 6,
        .idx_offset = @sizeOf(f32) * 16,
        .material = hdl_material
    };

    var temp_list = try hya.Arena(RenderItem).create(ctx.arena.allocator(), 1);
    _ = try temp_list.insert(render_object);

    pass = .{
        .items = temp_list,
        .targets = screen_target,
        .depth_target = null,
    };

    doPass(cmd, &pass, scene) catch {};
}

pub fn doPass(cmd: *sdl.gpu.CommandBuffer, job: *PassInfo, scene: *Scene) !void {
    const color_targets = job.targets;
    const pass = cmd.beginRenderPass(color_targets.ptr, @intCast(color_targets.len), job.depth_target).?;

    const lighting_ubo = mt.LightingUBO {
        .light_dir = scene.light_dir,
        .camera_pos = scene.camera.position
    };

    const cam = scene.camera;
    const cam_pos = cam.position;

    const aspect = @as(f32, @floatFromInt(window_state.prev_drawable_w)) / @as(f32, @floatFromInt(window_state.prev_drawable_h));
    const view = hym_cam.lookAt(cam_pos, vec3.add(cam_pos, cam.look_direction), vec3.y);
    const persp = hym_cam.perspectiveMatrix(45, aspect, 0.5, 100);

    var it = job.items.iterator();
    var last_pipeline: ?*sdl.gpu.GraphicsPipeline = null;
    while (it.next()) |item| {
        const material = try render_state.materials.get(item.material);

        if (material.pipeline != last_pipeline) {
            last_pipeline = material.pipeline;
            pass.bindGraphicsPipeline(material.pipeline);
        }

        inline for (.{
            .{ material.vert_program_def, 
                sdl.gpu.CommandBuffer.pushVertexUniformData, 
                sdl.gpu.RenderPass.bindVertexSamplers },
            .{ material.frag_program_def, 
                sdl.gpu.CommandBuffer.pushFragmentUniformData, 
                sdl.gpu.RenderPass.bindFragmentSamplers },
        }) |params| {
            const program_def = params[0];
            const pushUniform = params[1];
            const pushSampler = params[2];
            if (program_def.uniform_location_mvp) |slot_index| {
                const mat_model = mat4.mul(item.transform, (item.parent_transform orelse &mat4.identity).*);
                const ubo = mt.MvpUniformGroup {
                    .inverse_model = mat4.transpose(mat4.inverse(item.transform)),
                    .view_proj = mat4.mul(view, persp),
                    .model = mat_model,
                };
                pushUniform(cmd, slot_index, &ubo, @sizeOf(mt.MvpUniformGroup));
            }

            if (program_def.uniform_location_lighting) |slot_index| {
                pushUniform(cmd, slot_index, &lighting_ubo, @sizeOf(mt.LightingUBO));
            }

            for (program_def.textures, 0..) |needed_tex_type, i| {
                if (needed_tex_type == null) continue;
                const hdl = material.textures.get(needed_tex_type.?).?;
                if (hdl.is_valid()) {
                    const texture = try render_state.textures.get(hdl);
                    const binding = [_]sdl.gpu.TextureSamplerBinding {.{ .sampler = render_state.sampler, .texture = texture }};
                    pushSampler(pass, @intCast(i), &binding, 1);
                }
            }
        }

        pass.bindVertexBuffers(0, &.{ .buffer = item.buf, .offset = 0 }, 1);
        pass.bindIndexBuffer(&.{ .buffer = item.buf, .offset = item.idx_offset }, .@"32bit");
        pass.drawIndexedPrimitives(item.idx_count, 1, 0, 0, 0);
    }

    pass.end();
}

pub fn submit(cmd: *sdl.gpu.CommandBuffer) RenderSubmitResult {
    _ = cmd.submit();
    _ = ctx.arena.reset(.retain_capacity);
    const result = render_state.pending_submit_result.?;
    render_state.pending_submit_result = null;
    render_state.active_target = null;
    return result;
}

pub fn createDepthTexture(w: u32, h: u32) (error{SDLError}!*sdl.gpu.Texture) {
    const depthtex_createinfo = sdl.gpu.TextureCreateInfo {
        .type = .@"2d",
        .format = .d32_float_s8_uint,
        .usage = .{ .depth_stencil_target = true },
        .width = @intCast(w),
        .height = @intCast(h),
        .layer_count_or_depth = 1,
        .num_levels = 1,
        .sample_count = .@"1",
        .props = 0,
    };

    return ctx.device.createTexture(&depthtex_createinfo) orelse {
        std.log.err("could not create depth texture: {s}", .{sdl.getError()});
        return error.SDLError;
    };
}

pub fn createTextureFromMemory(name: [:0] const u8, data: tx.TextureMemory) !tx.Handle {
    if (render_state.texture_cache.contains(name)) {
        return render_state.texture_cache.get(name).?;
    }

    std.log.info("[GPU]: Loading Texture {s}", .{name});

    const texture_info = sdl.gpu.TextureCreateInfo {
        .type = .@"2d",
        .format = data.format,
        .usage = .{ .sampler = true },
        .height = data.h,
        .width = data.w,
        .layer_count_or_depth = 1,
        .num_levels = 1,
        .sample_count = .@"1",
        .props = 0
    };

    const tex = ctx.device.createTexture(&texture_info).?;
    try uploadToTexture(tex, data.w, data.h, data.data);

    const path_copy = try ctx.allocator.dupe(u8, name);
    const handle = try render_state.textures.insert(tex);
    try render_state.texture_cache.put(path_copy, handle);

    return handle;
}

pub fn createTextureFromFile(path: [:0]const u8) !tx.Handle {
    if (render_state.texture_cache.contains(path)) {
        return render_state.texture_cache.get(path).?;
    }

    var c_w: c_int = 0;
    var c_h: c_int = 0;
    var c_d: c_int = 0;
    const tex_pixels = stb.stbi_load(path.ptr, &c_w, &c_h, &c_d, 4);
    const w: u32 = @intCast(c_w);
    const h: u32 = @intCast(c_h);
    const d: u32 = 4;
    defer stb.stbi_image_free(tex_pixels);

    return try createTextureFromMemory(path, .{ 
        .w = w, .h = h, 
        .data = tex_pixels[0..w * h * d],
    });
}

pub fn createTextureFromImageMemory(name: [:0] const u8, data: []const u8) !tx.Handle {
    if (render_state.texture_cache.contains(name)) {
        return render_state.texture_cache.get(name).?;
    }

    var c_w: c_int = 0;
    var c_h: c_int = 0;
    var c_d: c_int = 0;
    const tex_pixels = stb.stbi_load_from_memory(data.ptr, @intCast(data.len), &c_w, &c_h, &c_d, 4);
    defer stb.stbi_image_free(tex_pixels);
    const w: u32 = @intCast(c_w);
    const h: u32 = @intCast(c_h);
    const d: u32 = 4;

    return try createTextureFromMemory(name, .{ 
        .w = w, .h = h, .d = d,
        .data = tex_pixels[0..w * h * d],
    });

}

pub fn buildPipeline(params: BuildPipelineParams) *sdl.gpu.GraphicsPipeline {
    const sample_count = .@"1";

    const color_target_desc: []const sdl.gpu.ColorTargetDescription = &.{ .{
        .format = ctx.swapchain_target_desc.format,
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

    const vertex_buffer_desc: []const sdl.gpu.VertexBufferDescription = &.{
        switch(params.pass) {
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
            }
        }
    };

    const vertex_attributes: []const sdl.gpu.VertexAttribute = switch(params.pass) {
        .default => &.{
            .{
                .buffer_slot = 0,
                .format = .float3,
                .location = 0,
                .offset = 0,
            },
            .{
                .buffer_slot = 0,
                .format = .float3,
                .location = 1,
                .offset = @offsetOf(Vertex, "normal"),
            },
            .{
                .buffer_slot = 0,
                .format = .float2,
                .location = 2,
                .offset = @offsetOf(Vertex, "uv"),
            }
        },
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

    const target_info: sdl.gpu.GraphicsPipelineTargetInfo = switch(params.pass) {
        .default => .{
            .num_color_targets = @intCast(color_target_desc.len),
            .color_target_descriptions = color_target_desc.ptr,
            .depth_stencil_format = .d32_float_s8_uint,
            .has_depth_stencil_target = true,
        },
        .ui,
        .post_process => .{
            .num_color_targets = @intCast(color_target_desc.len),
            .color_target_descriptions = color_target_desc.ptr,
            .has_depth_stencil_target = false,
        },
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

    const pipeline_desc = sdl.gpu.GraphicsPipelineCreateInfo {
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

    const pipeline = ctx.device.createGraphicsPipeline(&pipeline_desc) orelse {
        std.log.err("Could not create pipeline: {s}", .{sdl.getError()});
        unreachable;
    };

    return pipeline;
}

pub fn importModel(path: [:0]const u8, settings: mdl.ImportSettings)  !mdl.Handle {
    var import = ai.importFile(path, settings.post_process);
    defer import.release();
    const allocator = ctx.arena.allocator();

    var materials_array = try allocator.alloc(mt.Handle, import.num_materials);

    for (import.materials[1..import.num_materials], 1..) |ai_material, mat_index| {
        var texture_set = tx.TextureSet.init(.{});

        inline for (std.meta.fields(ai.TextureType)) |field| {
            const tex_type: ai.TextureType = @enumFromInt(field.value);
            const count = ai_material.getTextureCount(tex_type);
            for (0..count) |i| {
                var str: ai.String = .{};
                _ =  ai_material.getTexture(ai.Material.GetTextureInfo {
                    .tex_type = tex_type,
                    .index = @intCast(i),
                    .path = &str,
                });

                const ai_tex_id: [:0]u8 = str.data[0..str.len :0];
                var handle: tx.Handle = undefined;

                if (import.getEmbeddedTexture(ai_tex_id.ptr)) |tex| {
                    const tex_identifier: [:0]u8 = try std.mem.concatWithSentinel(allocator, u8, &.{path, ai_tex_id}, 0);
                    if (tex.height == 0) {
                        const data = std.mem.sliceAsBytes(tex.pc_data[0..tex.width]);
                        handle = try createTextureFromImageMemory(tex_identifier, data); 
                    }
                    else {
                        const data = std.mem.sliceAsBytes(tex.pc_data[0..tex.width * tex.height]);
                        handle = try createTextureFromMemory(tex_identifier, .{
                            .w = tex.width, .h = tex.height, .d = 4,
                            .data = data,
                            .format = .b8g8r8a8_unorm
                        });
                    }
                } else { // Texture is a relative path
                    const tex_path: [:0]u8 = try std.fs.path.joinZ(allocator, &[_][]const u8 { std.fs.path.dirname(path).?, ai_tex_id});
                    std.log.info("[GPU] C Loading Tex {s} Done", .{path});
                    handle = try createTextureFromFile(tex_path);
                }

                std.debug.assert(handle.is_valid());

                const hy_tex_type: ?tx.TextureType = tx.tex_to_hyoga_type.get(tex_type);
                if (hy_tex_type) |htt| {
                    texture_set.put(htt, handle);
                } else {
                    std.log.warn("[GPU]: Unconsumed texture type {s} for object {s}", .{field.name, path});
                }
            }

        }
        const material = mt.Material.fromTemplate(render_state.default_material, texture_set);
        const hdl = try render_state.materials.insert(material);
        materials_array[mat_index] = hdl;
    }

    const model = try mdl.load(path, settings, materials_array, ctx.allocator);
    stb.resetArena(.retain_capacity);
    return try render_state.models.insert(model);
}

pub fn addModel(hdl: mdl.Handle, owner: *mat4.Mat4) !RenderItemHandle {
    const model = try render_state.models.get(hdl);
    var last_handle: ?RenderItemHandle = null;

    for (model.meshes.items) |mesh| {
        const vertex_buffer_size: u32 = @intCast(mesh.vertices.items.len * @sizeOf(@TypeOf(mesh.vertices.items[0])));
        const buffer_size: u32 = @intCast(vertex_buffer_size + mesh.indices.items.len * @sizeOf(@TypeOf(mesh.indices.items[0])));
        const buffer = ctx.device.createBuffer(&.{
            .size = buffer_size,
            .usage = .{ .index = true, .vertex = true}
        }).?;

        try uploadToBuffer(buffer, 0, std.mem.sliceAsBytes(mesh.vertices.items));
        try uploadToBuffer(buffer, vertex_buffer_size, std.mem.sliceAsBytes(mesh.indices.items));

        const render_obj = RenderItem {
            .buf = buffer,
            .next = last_handle,
            .transform = model.transform,
            .parent_transform = owner,
            .idx_offset = vertex_buffer_size,
            .idx_count = @intCast(mesh.indices.items.len),
            .material = mesh.material,
        };

        last_handle = try render_state.objs.insert(render_obj);
    }

    return last_handle.?;
}

pub fn removeModel(handle: RenderItemHandle) void {
    var next_node: ?RenderItemHandle = handle;
    while (next_node) |node| {
        const obj = render_state.objs.get(node) catch {
            std.log.warn("[GPU]: Invalid handle for removeModel, returning...", .{});
            return;
        };
        next_node = obj.next;
        ctx.device.releaseBuffer(obj.buf);
        render_state.objs.release(node);
    }
}

pub fn addMaterial(material: mt.Material) !mt.Handle {
    std.debug.assert(material.textures.len > 0);
    return render_state.materials.insert(material);
}

pub fn createOutlineShader() *sdl.gpu.GraphicsPipeline {
    // const color_target_desc: []const sdl.gpu.ColorTargetDescription = &.{ ctx.swapchain_target_desc };

    // const vertex_buffer_desc: []const sdl.gpu.VertexBufferDescription = &.{.{
    //     .slot = 0,
    //     .input_rate = .vertex,
    //     .instance_step_rate = 0,
    //     .pitch = @sizeOf(Vertex),
    // }};

    // const vertex_attributes: []const sdl.gpu.VertexAttribute = &.{
    //     .{
    //         .buffer_slot = 0,
    //         .format = .float3,
    //         .location = 0,
    //         .offset = 0,
    //     },
    //     .{
    //         .buffer_slot = 0,
    //         .format = .float3,
    //         .location = 1,
    //         .offset = @offsetOf(Vertex, "normal"),
    //     },
    //     .{
    //         .buffer_slot = 0,
    //         .format = .float2,
    //         .location = 2,
    //         .offset = @offsetOf(Vertex, "uv"),
    //     }
    // };

    // const stencil_state = sdl.gpu.StencilOpState {
    //     .compare_op = .not_equal,
    //     .depth_fail_op = .keep,
    //     .fail_op = .keep,
    //     .pass_op = .keep,
    // };

    // const vert_shader = ctx.device.createShader(&@import("shaders/single_color.zig").vert_info).?;
    // defer ctx.device.releaseShader(vert_shader);
    // const frag_shader = ctx.device.createShader(&@import("shaders/single_color.zig").frag_info).?;
    // defer ctx.device.releaseShader(frag_shader);

    // const pipeline_desc = sdl.gpu.GraphicsPipelineCreateInfo {
    //     .target_info = .{
    //         .num_color_targets = @intCast(color_target_desc.len),
    //         .color_target_descriptions = color_target_desc.ptr,
    //         .depth_stencil_format = .d32_float_s8_uint,
    //         .has_depth_stencil_target = true,
    //     },
    //     .depth_stencil_state = .{
    //         .enable_depth_test = false,
    //         .enable_stencil_test = true,
    //         .compare_mask = 0xff,
    //         .write_mask = 0,
    //         .front_stencil_state = stencil_state,
    //         .back_stencil_state = stencil_state,
    //     },
    //     .multisample_state = .{ .sample_count = .@"1" },
    //     .primitive_type = .trianglelist,
    //     .vertex_shader = vert_shader,
    //     .fragment_shader = frag_shader,
    //     .vertex_input_state = .{
    //         .num_vertex_buffers = @intCast(vertex_buffer_desc.len),
    //         .vertex_buffer_descriptions = vertex_buffer_desc.ptr,
    //         .num_vertex_attributes = @intCast(vertex_attributes.len),
    //         .vertex_attributes = vertex_attributes.ptr,
    //     },
    //     .rasterizer_state = .{
    //         .cull_mode = .front,
    //     },
    //     .props = 0,
    // };

    // return ctx.device.createGraphicsPipeline(&pipeline_desc).?;
}

pub fn createPostProcessShader() *sdl.gpu.GraphicsPipeline {
    // const color_target_desc: []const sdl.gpu.ColorTargetDescription = &.{ ctx.swapchain_target_desc };

    // // vec2 pos
    // // vec2 uv

    // const vertex_buffer_desc: []const sdl.gpu.VertexBufferDescription = &.{.{
    //     .slot = 0,
    //     .input_rate = .vertex,
    //     .instance_step_rate = 0,
    //     .pitch = @sizeOf(f32) * 4,
    // }};

    // const vertex_attributes: []const sdl.gpu.VertexAttribute = &.{
    //     .{
    //         .buffer_slot = 0,
    //         .format = .float2,
    //         .location = 0,
    //         .offset = 0,
    //     },
    //     .{
    //         .buffer_slot = 0,
    //         .format = .float2,
    //         .location = 1,
    //         .offset = 8,
    //     },
    // };

    // const vert_shader = ctx.device.createShader(&@import("shaders/post_process.zig").vert_info).?;
    // defer ctx.device.releaseShader(vert_shader);
    // const frag_shader = ctx.device.createShader(&@import("shaders/post_process.zig").frag_info).?;
    // defer ctx.device.releaseShader(frag_shader);

    // const pipeline_desc = sdl.gpu.GraphicsPipelineCreateInfo {
    //     .target_info = .{
    //         .num_color_targets = @intCast(color_target_desc.len),
    //         .color_target_descriptions = color_target_desc.ptr,
    //         .has_depth_stencil_target = false,
    //     },
    //     .multisample_state = .{ .sample_count = .@"1" },
    //     .primitive_type = .trianglelist,
    //     .vertex_shader = vert_shader,
    //     .fragment_shader = frag_shader,
    //     .vertex_input_state = .{
    //         .num_vertex_buffers = @intCast(vertex_buffer_desc.len),
    //         .vertex_buffer_descriptions = vertex_buffer_desc.ptr,
    //         .num_vertex_attributes = @intCast(vertex_attributes.len),
    //         .vertex_attributes = vertex_attributes.ptr,
    //     },
    //     .rasterizer_state = .{
    //         .cull_mode = .back,
    //     },
    //     .props = 0,
    // };

    // return ctx.device.createGraphicsPipeline(&pipeline_desc).?;
}