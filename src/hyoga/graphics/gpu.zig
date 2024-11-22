const std = @import("std");
const c = @import("../c.zig");
const window = @import("../window.zig");

const hym = @import("hyoga-math");
const vec3 = hym.vec3;
const mat4 = hym.mat4;
const hym_cam = hym.cam;

const hya = @import("hyoga-arena");

const spirv = @import("shaders/cube_shader.zig");
const dxil = @import("cube_dxil.zig");
const dxbc = @import("cube_dxbc.zig");

const sdl = @import("sdl");

const camera = @import("../camera.zig");
const cube = @import("primitives.zig").createCube();

const tx = @import("texture.zig");
const mdl = @import("model.zig");
const mat = @import("material.zig");
const shader = @import("shader_program.zig");

const Vertex = @import("vertex.zig").Vertex;

pub const Scene = struct {
    camera: camera.Camera, 
    light_dir: vec3.Vec3,
};

pub const RenderObject = struct {
    buf: *sdl.gpu.Buffer,
    transform: mat4.Mat4,
    textures: []tx.TextureView,
    idx_offset: u32,
    idx_count: u32,
    pipeline: *sdl.gpu.GraphicsPipeline,
    material: mat.Material,
};

pub const RenderSubmitResult = struct {
    num_drawn_verts: u32 = 0,
    num_draw_calls: u32 = 0,
};

const RenderState = struct {
    default_pipeline: *sdl.gpu.GraphicsPipeline,
    default_material: mat.Material,
    outline_pipeline: *sdl.gpu.GraphicsPipeline,
    post_pipeline: *sdl.gpu.GraphicsPipeline,
    quad_buffer: *sdl.gpu.Buffer,
    sampler: *sdl.gpu.Sampler = undefined,
    specular: *sdl.gpu.Sampler = undefined,

    textures: tx.Arena,
    texture_cache: tx.Cache,

    models: mdl.Arena,
    objs: hya.Arena(RenderObject),
    robjs: PassInfo,

    scene: *Scene = undefined,
    sample_count: sdl.gpu.SampleCount = .@"1",

    active_target: ?*sdl.gpu.Texture,
    pending_submit_result: ?RenderSubmitResult = null,
};

const PassInfo = struct {
    items: hya.Arena(RenderObject),
    targets: []const sdl.gpu.ColorTargetInfo,
    depth_target: ?*const sdl.gpu.DepthStencilTargetInfo,
};

const GPU = struct {
    allocator: std.mem.Allocator,
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

const LightingUBO = extern struct {
    light_dir: vec3.Vec3,
    camera_pos: vec3.Vec3
};

const TransformMatrices= extern struct {
    model: mat4.Mat4,
    mvp: mat4.Mat4,
    normal_transform: mat4.Mat4
};

pub var ctx: GPU = undefined;
pub var render_state: RenderState = undefined;
pub var window_state: WindowState = .{};

pub var speed: f32 = 1;

pub fn init(hdl_window: *sdl.Window, allocator: std.mem.Allocator) !void {
    window_state.hdl_window = hdl_window;

    const d = try sdl.gpu.Device.create(null, .{ .spirv = true });
    try d.claimWindow(hdl_window);

    ctx = .{
        .allocator = allocator,

        .device = d,

        .swapchain_target_desc = .{
            .format = sdl.gpu.getSwapchainTextureFormat(d, hdl_window)
        }
    };

    const vertex_shader = try ctx.device.createShader(spirv.vert_info);
    defer ctx.device.releaseShader(vertex_shader);
    const fragment_shader = try ctx.device.createShader(spirv.frag_info);
    defer ctx.device.releaseShader(fragment_shader);

    const sample_count = .@"1";

    const color_target_desc: []const sdl.gpu.ColorTargetDescription = &.{ ctx.swapchain_target_desc };

    const vertex_buffer_desc: []const sdl.gpu.VertexBufferDescription = &.{.{
        .slot = 0,
        .input_rate = .vertex,
        .instance_step_rate = 0,
        .pitch = @sizeOf(@TypeOf(cube.vertices[0])),
    }};

    const vertex_attributes: []const sdl.gpu.VertexAttribute = &.{
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
            .offset = @offsetOf(@TypeOf(cube.vertices[0]), "normal"),
        },
        .{
            .buffer_slot = 0,
            .format = .float2,
            .location = 2,
            .offset = @offsetOf(@TypeOf(cube.vertices[0]), "uv"),
        }
    };

    const stencil_state = sdl.gpu.StencilOpState {
        .compare_op = .always,
        .depth_fail_op = .replace,
        .fail_op = .replace,
        .pass_op = .replace,
    };

    const pipeline_desc = sdl.gpu.GraphicsPipelineCreateInfo {
        .target_info = .{
            .num_color_targets = 1,
            .color_target_descriptions = color_target_desc.ptr,
            .depth_stencil_format = .d32_float_s8_uint,
            .has_depth_stencil_target = true,
        },
        .depth_stencil_state = .{
            .enable_depth_test = true,
            .enable_depth_write = true,
            .enable_stencil_test = true,
            .compare_op = .less_or_equal,
            .compare_mask = 0x00,
            .write_mask = 0xff,
            .front_stencil_state = stencil_state,
            .back_stencil_state = stencil_state,
        },
        .multisample_state = .{ .sample_count = sample_count },
        .primitive_type = .trianglelist,
        .vertex_shader = vertex_shader,
        .fragment_shader = fragment_shader,
        .vertex_input_state = .{
            .num_vertex_buffers = @intCast(vertex_buffer_desc.len),
            .vertex_buffer_descriptions = vertex_buffer_desc.ptr,
            .num_vertex_attributes = @intCast(vertex_attributes.len),
            .vertex_attributes = vertex_attributes.ptr,
        },
        .props = 0,
    };

    const pipeline = sdl.gpu.createGraphicsPipeline(ctx.device, &pipeline_desc) orelse {
        std.log.err("Could not create pipeline: {s}", .{sdl.getError()});
        unreachable;
    };

    const material = mat.Material {
        .pipeline = pipeline,
        .vert_program_def = spirv.vert_program,
        .frag_program_def = spirv.frag_program,
    };

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

    const quad_buffer = sdl.gpu.createBuffer(ctx.device, &.{
        .size = @sizeOf(Verts),
        .usage = .{ .vertex = true, .index = true },
    }).?;

    try uploadToBuffer(quad_buffer, 0, &std.mem.toBytes(verts));

    render_state = .{
        .objs = try hya.Arena(RenderObject).create(ctx.allocator, 1),
        .default_pipeline = pipeline,
        .default_material = material,
        .outline_pipeline = createOutlineShader(),
        .post_pipeline = createPostProcessShader(),
        .quad_buffer = quad_buffer,
        .sampler = sdl.gpu.createSampler(ctx.device, &sampler_info).?,
        .specular  = sdl.gpu.createSampler(ctx.device, &sampler_info).?,
        .sample_count = sample_count,
        .textures = textures,
        .texture_cache = texture_cache,
        .models = try mdl.Arena.create(ctx.allocator, 8),
        .active_target = null,
        .robjs = undefined,
    };
}

pub fn shutdown() void {
    sdl.gpu.releaseWindowFromDevice(ctx.device, window_state.hdl_window);

    var tx_it = render_state.textures.iterator();
    while (tx_it.next()) |item| {
        sdl.gpu.releaseTexture(ctx.device, item);
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
    ctx.device.releaseSampler(render_state.specular);
    ctx.device.releaseGraphicsPipeline(render_state.default_pipeline);
    ctx.device.releaseGraphicsPipeline(render_state.outline_pipeline);
    ctx.device.releaseGraphicsPipeline(render_state.post_pipeline);
    ctx.device.destroy();

}

pub fn device() *sdl.gpu.Device {
    return ctx.device;
}

pub fn activeRenderTarget() ?*sdl.gpu.Texture {
    return render_state.active_target;
}

pub fn uploadToBuffer(buffer: *sdl.gpu.Buffer, offset: u32, data: []const u8) !void {
    const buf_transfer = try ctx.device.createTransferBuffer(.{
        .usage = .upload,
        .size = @intCast(data.len),
    });
    defer ctx.device.destroyTransferBuffer(buf_transfer);

    const map = try ctx.device.mapTransferBuffer(buf_transfer, false);
    @memcpy(map, data);
    ctx.device.unmapTransferBuffer(buf_transfer);

    const cmd = try ctx.device.acquireCommandBuffer();

    const copy_pass = try cmd.beginCopyPass();

    const buf_location = sdl.gpu.TransferBufferLocation {
        .transfer_buffer = buf_transfer,
        .offset = 0,
    };

    const dst_region = sdl.gpu.BufferRegion {
        .buffer = buffer,
        .offset = offset,
        .size = @intCast(data.len),
    };

    copy_pass.uploadToBuffer(buf_location, dst_region, false);
    copy_pass.end();
    _ = cmd.submit();
}

pub fn uploadToTexture(tex: *sdl.gpu.Texture, w: u32, h: u32, data: []const u8) !void {
    const buf_transfer = try ctx.device.createTransferBuffer(.{
        .size = @intCast(data.len),
        .usage = .upload
    });
    defer ctx.device.releaseTransferBuffer(buf_transfer);
    const ptr_transfer = try ctx.device.mapTransferBuffer(buf_transfer, false);
    @memcpy(ptr_transfer, data);
    ctx.device.unmapTransferBuffer(buf_transfer);

    // copy to transfer buffer
    const cmd = try ctx.device.acquireCommandBuffer();
    const copy_pass = try cmd.beginCopyPass();

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

    copy_pass.uploadToTexture(buf_src, buf_dst, false);
    copy_pass.end();
    _ = cmd.submit();
}

pub fn begin() !*sdl.gpu.CommandBuffer {
    render_state.pending_submit_result = .{};

    var drawable_w: u32 = undefined;
    var drawable_h: u32 = undefined;

    const cmd = sdl.gpu.acquireCommandBuffer(ctx.device) orelse {
        std.log.err("could not acquire command buffer", .{});
        return error.SDLError;
    };

    var swapchain: ?*sdl.gpu.Texture = null;
    if (!sdl.gpu.acquireSwapchainTexture(cmd, window_state.hdl_window, &swapchain, &drawable_w, &drawable_h)) {
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

    const tex = sdl.gpu.createTexture(ctx.device, &.{
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

    defer _ = render_state.textures.remove(tex_hdl);
    defer sdl.gpu.releaseTexture(ctx.device, tex);

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

    const screen: []const sdl.gpu.ColorTargetInfo = &.{
        .{
            .texture = render_state.active_target,
            .load_op = .dont_care,
            .store_op = .store,
            .cycle = true,
        }
    };

    var arena = try hya.Arena(RenderObject).create(ctx.allocator, 1);
    _ = try arena.insert(.{
        .pipeline = render_state.post_pipeline,
        .transform = mat4.identity,
        .textures = undefined,
        .buf = render_state.quad_buffer,
        .idx_count = 6,
        .idx_offset = @sizeOf(f32) * 4 * 4,
        .material = .{
            .pipeline = render_state.post_pipeline,
            .vert_program_def = .{},
            .frag_program_def = .{ .textures = &.{ .diffuse }},
            .textures = &.{.{ .type = .diffuse, .hdl = tex_hdl }},
        },
    });

    pass = .{
        .items = arena,
        .targets = screen,
        .depth_target = null,
    };

    doPass(cmd, &pass, scene) catch {};
}

pub fn doPass(cmd: *sdl.gpu.CommandBuffer, job: *PassInfo, scene: *Scene) !void {
    const color_targets = job.targets;
    const pass = sdl.gpu.beginRenderPass(cmd, color_targets.ptr, @intCast(color_targets.len), job.depth_target).?;

    const lighting_ubo = LightingUBO {
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

        if (item.material.pipeline != last_pipeline) {
            last_pipeline = item.material.pipeline;
            pass.bindGraphicsPipeline(item.material.pipeline);
        }

        if (item.material.vert_program_def.uniform_location_mvp) |slot_index| {
            const ubo = shader.MvpUniformGroup {
                .model = item.transform,
                .inverse_model = mat4.transpose(mat4.inverse(item.transform)),
                .view_proj = mat4.mul(persp, view),
            };
            sdl.gpu.pushVertexUniformData(cmd, slot_index, &ubo, @sizeOf(TransformMatrices));
        }

        if (item.material.frag_program_def.uniform_location_mvp) |slot_index| {
            const ubo = shader.MvpUniformGroup {
                .model = item.transform,
                .inverse_model = mat4.transpose(mat4.inverse(item.transform)),
                .view_proj = mat4.mul(persp, view),
            };
            sdl.gpu.pushFragmentUniformData(cmd, slot_index, &ubo, @sizeOf(TransformMatrices));
        }

        if (item.material.vert_program_def.uniform_location_lighting) |slot_index| {
            sdl.gpu.pushFragmentUniformData(cmd, slot_index, &lighting_ubo, @sizeOf(LightingUBO));
        }

        if (item.material.frag_program_def.uniform_location_lighting) |slot_index| {
            sdl.gpu.pushFragmentUniformData(cmd, slot_index, &lighting_ubo, @sizeOf(LightingUBO));
        }

        for (item.material.vert_program_def.textures, 0..) |requested_tex, i| {
            for (item.material.textures) |mat_tex| {
                if (mat_tex.type == requested_tex) {
                    const texture = try render_state.textures.get(mat_tex.hdl);
                    const binding = [_]sdl.gpu.TextureSamplerBinding {.{ .sampler = render_state.sampler, .texture = texture }};
                    pass.bindVertexSamplers(@intCast(i), &binding, 1);
                }
            }
        }

        for (item.material.frag_program_def.textures, 0..) |requested_tex, i| {
            for (item.material.textures) |mat_tex| {
                if (mat_tex.type == requested_tex) {
                    const texture = try render_state.textures.get(mat_tex.hdl);
                    const binding = [_]sdl.gpu.TextureSamplerBinding {.{ .sampler = render_state.sampler, .texture = texture }};
                    pass.bindFragmentSamplers(@intCast(i), &binding, 1);
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
    const result = render_state.pending_submit_result.?;
    render_state.pending_submit_result = null;
    render_state.active_target = null;
    return result;
}

pub fn createDepthTexture(w: u32, h: u32) (error{SDLError}!*sdl.gpu.Texture) {
    var depthtex_createinfo = sdl.gpu.TextureCreateInfo{
        .type = .@"2d",
        .format = .d32_float_s8_uint,
        .usage = .{ .depth_stencil_target = true },
        .width = @intCast(w),
        .height = @intCast(h),
        .layer_count_or_depth = 1,
        .num_levels = 1,
        .sample_count = render_state.sample_count,
        .props = 0,
    };

    return sdl.gpu.createTexture(ctx.device, &depthtex_createinfo) orelse {
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
    };

    const tex = sdl.gpu.createTexture(ctx.device, &texture_info).?;
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
    const tex_pixels = c.stbi_load(path.ptr, &c_w, &c_h, &c_d, 4);
    const w: u32 = @intCast(c_w);
    const h: u32 = @intCast(c_h);
    const d: u32 = 4;
    defer c.stbi_image_free(tex_pixels);

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
    const tex_pixels = c.stbi_load_from_memory(data.ptr, @intCast(data.len), &c_w, &c_h, &c_d, 4);
    defer c.stbi_image_free(tex_pixels);
    const w: u32 = @intCast(c_w);
    const h: u32 = @intCast(c_h);
    const d: u32 = 4;

    return try createTextureFromMemory(name, .{ 
        .w = w, .h = h, .d = d,
        .data = tex_pixels[0..w * h * d],
    });

}

pub fn importModel(path: [:0]const u8, settings: mdl.ImportSettings)  !mdl.Handle {
    const mod = try mdl.load(path, settings, ctx.allocator);
    return try render_state.models.insert(mod);
}

pub fn addModel(hdl: mdl.Handle) !void {
    const model = try render_state.models.get(hdl);
    for (model.meshes.items) |mesh| {
        const vertex_buffer_size: u32 = @intCast(mesh.vertices.items.len * @sizeOf(@TypeOf(mesh.vertices.items[0])));
        const buffer_size: u32 = @intCast(vertex_buffer_size + mesh.indices.items.len * @sizeOf(@TypeOf(mesh.indices.items[0])));
        const buffer = try ctx.device.createBuffer(.{
            .size = buffer_size,
            .usage = .{ .index = true, .vertex = true}
        });

        try uploadToBuffer(buffer, 0, std.mem.sliceAsBytes(mesh.vertices.items));
        try uploadToBuffer(buffer, vertex_buffer_size, std.mem.sliceAsBytes(mesh.indices.items));

        // var frag_bindings = [2]sdl.gpu.TextureSamplerBinding { .{}, .{} };
        // var num_frag_bindings: u32 = 0;
        
        // for(mesh.textures.items) |t| {
        //     const tex: tx.TextureView = t;
        //     const idx: ?usize = switch (tex.tex_type) {
        //         .diffuse => 0,
        //         .specular => 1,
        //     };
        //     if (idx != null and frag_bindings[idx.?].texture == null ) {
        //         frag_bindings[idx.?] = .{
        //             .sampler = render_state.sampler,
        //             .texture = try render_state.textures.get(tex.hdl)
        //         };
        //         num_frag_bindings += 1;
        //     }
        // }
        
        var material = render_state.default_material;
        material.textures = mesh.textures.items;

        const render_obj = RenderObject {
            .buf = buffer,
            .transform = model.transform,
            .idx_offset = vertex_buffer_size,
            .idx_count = @intCast(mesh.indices.items.len),
            .textures = mesh.textures.items,
            .pipeline = render_state.default_pipeline,
            .material = material,
        };

        _ = try render_state.objs.insert(render_obj);
    }

}

pub fn createOutlineShader() *sdl.gpu.GraphicsPipeline {
    const color_target_desc: []const sdl.gpu.ColorTargetDescription = &.{ ctx.swapchain_target_desc };

    const vertex_buffer_desc: []const sdl.gpu.VertexBufferDescription = &.{.{
        .slot = 0,
        .input_rate = .vertex,
        .instance_step_rate = 0,
        .pitch = @sizeOf(Vertex),
    }};

    const vertex_attributes: []const sdl.gpu.VertexAttribute = &.{
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
    };

    const stencil_state = sdl.gpu.StencilOpState {
        .compare_op = .not_equal,
        .depth_fail_op = .keep,
        .fail_op = .keep,
        .pass_op = .keep,
    };

    const vert_shader = ctx.device.createShader(@import("shaders/single_color.zig").vert_info) catch std.debug.panic("Could not load shader!", .{});
    defer ctx.device.releaseShader(vert_shader);
    const frag_shader = ctx.device.createShader(@import("shaders/single_color.zig").frag_info) catch std.debug.panic("Could not load shader!", .{});
    defer ctx.device.releaseShader(frag_shader);

    const pipeline_desc = sdl.gpu.GraphicsPipelineCreateInfo {
        .target_info = .{
            .num_color_targets = @intCast(color_target_desc.len),
            .color_target_descriptions = color_target_desc.ptr,
            .depth_stencil_format = .d32_float_s8_uint,
            .has_depth_stencil_target = true,
        },
        .depth_stencil_state = .{
            .enable_depth_test = false,
            .enable_stencil_test = true,
            .compare_mask = 0xff,
            .write_mask = 0,
            .front_stencil_state = stencil_state,
            .back_stencil_state = stencil_state,
        },
        .multisample_state = .{ .sample_count = .@"1" },
        .primitive_type = .trianglelist,
        .vertex_shader = vert_shader,
        .fragment_shader = frag_shader,
        .vertex_input_state = .{
            .num_vertex_buffers = @intCast(vertex_buffer_desc.len),
            .vertex_buffer_descriptions = vertex_buffer_desc.ptr,
            .num_vertex_attributes = @intCast(vertex_attributes.len),
            .vertex_attributes = vertex_attributes.ptr,
        },
        .rasterizer_state = .{
            .cull_mode = .front,
        },
        .props = 0,
    };

    return ctx.device.createGraphicsPipeline(pipeline_desc) catch std.debug.panic("Could not create pipeline!", .{});
}

pub fn createPostProcessShader() *sdl.gpu.GraphicsPipeline {
    const color_target_desc: []const sdl.gpu.ColorTargetDescription = &.{ ctx.swapchain_target_desc };

    // vec2 pos
    // vec2 uv

    const vertex_buffer_desc: []const sdl.gpu.VertexBufferDescription = &.{.{
        .slot = 0,
        .input_rate = .vertex,
        .instance_step_rate = 0,
        .pitch = @sizeOf(f32) * 4,
    }};

    const vertex_attributes: []const sdl.gpu.VertexAttribute = &.{
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
    };

    const vert_shader = ctx.device.createShader(@import("shaders/post_process.zig").vert_info) catch std.debug.panic("Could not load shader!", .{});
    defer ctx.device.releaseShader(vert_shader);
    const frag_shader = ctx.device.createShader(@import("shaders/post_process.zig").frag_info) catch std.debug.panic("Could not load shader!", .{});
    defer ctx.device.releaseShader(frag_shader);

    const pipeline_desc = sdl.gpu.GraphicsPipelineCreateInfo {
        .target_info = .{
            .num_color_targets = @intCast(color_target_desc.len),
            .color_target_descriptions = color_target_desc.ptr,
            .has_depth_stencil_target = false,
        },
        .multisample_state = .{ .sample_count = .@"1" },
        .primitive_type = .trianglelist,
        .vertex_shader = vert_shader,
        .fragment_shader = frag_shader,
        .vertex_input_state = .{
            .num_vertex_buffers = @intCast(vertex_buffer_desc.len),
            .vertex_buffer_descriptions = vertex_buffer_desc.ptr,
            .num_vertex_attributes = @intCast(vertex_attributes.len),
            .vertex_attributes = vertex_attributes.ptr,
        },
        .rasterizer_state = .{
            .cull_mode = .back,
        },
        .props = 0,
    };

    return ctx.device.createGraphicsPipeline(pipeline_desc) catch std.debug.panic("Could not create pipeline!", .{});
}