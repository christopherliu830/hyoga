const std = @import("std");
const c = @import("../c.zig");
const window = @import("../window.zig");

const vec3 = @import("../hym/vec3.zig");
const mat4 = @import("../hym/mat4.zig");
const hym_cam = @import("../hym/cam.zig");

const spirv = @import("shaders/cube_shader.zig");
const dxil = @import("cube_dxil.zig");
const dxbc = @import("cube_dxbc.zig");

const sdl = @import("sdl");

const camera = @import("../camera.zig");
const cube = @import("primitives.zig").createCube();

const tx = @import("texture.zig");
const mdl = @import("model.zig");

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
};

pub const RenderSubmitResult = struct {
    num_drawn_verts: u32 = 0,
    num_draw_calls: u32 = 0,
};

const RenderState = struct {
    allocator: std.mem.Allocator,
    
    pipeline: *sdl.gpu.GraphicsPipeline,
    outline_pipeline: *sdl.gpu.GraphicsPipeline,
    diffuse: *sdl.gpu.Sampler = undefined,
    specular: *sdl.gpu.Sampler = undefined,

    textures: tx.Arena,
    texture_cache: tx.Cache,

    models: mdl.Arena,

    objs: std.ArrayList(RenderObject),

    scene: *Scene = undefined,
    sample_count: sdl.gpu.SampleCount = .@"1",
    frames: u32 = 0,

    pending_submit_result: ?RenderSubmitResult = null,
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

pub var device: *sdl.gpu.Device = undefined;
pub var render_state: RenderState = undefined;
pub var window_state: WindowState = .{};

pub var speed: f32 = 1;

pub fn init(hdl_window: *sdl.Window, in_scene: *Scene, allocator: std.mem.Allocator) !void {
    window_state.hdl_window = hdl_window;

    device = try sdl.gpu.Device.create(null, .{ .spirv = true });
    try device.claimWindow(hdl_window);

    const vertex_shader = try device.createShader(spirv.vert_info);
    defer device.releaseShader(vertex_shader);
    const fragment_shader = try device.createShader(spirv.frag_info);
    defer device.releaseShader(fragment_shader);


    const sample_count = .@"1";

    const color_target_desc: []const sdl.gpu.ColorTargetDescription = &.{.{ 
        .format = sdl.gpu.getSwapchainTextureFormat(device, hdl_window),
    }};

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

    const pipeline = sdl.gpu.createGraphicsPipeline(device, &pipeline_desc) orelse {
        std.log.err("Could not create pipeline: {s}", .{sdl.getError()});
        unreachable;
    };

    var w: c_int = 0;
    var h: c_int = 0;
    _ = sdl.video.getWindowSizeInPixels(hdl_window, &w, &h);
    window_state.tex_depth = try createDepthTexture(@intCast(w), @intCast(h));

    const textures = try tx.Arena.create(allocator, 8);
    const texture_cache = tx.Cache.init(allocator);

    const sampler_info = sdl.gpu.SamplerCreateInfo {
        .address_mode_u = .clamp_to_edge,
        .address_mode_v = .clamp_to_edge,
        .address_mode_w = .clamp_to_edge,
        .min_filter = .linear,
        .mag_filter = .linear,
    };

    render_state = .{
        .allocator = allocator,
        .objs = std.ArrayList(RenderObject).init(allocator),
        .frames = 0,
        .pipeline = pipeline,
        .outline_pipeline = createOutlineShader(color_target_desc),
        .diffuse = sdl.gpu.createSampler(device, &sampler_info).?,
        .specular  = sdl.gpu.createSampler(device, &sampler_info).?,
        .sample_count = sample_count,
        .scene = in_scene,
        .textures = textures,
        .texture_cache = texture_cache,
        .models = try mdl.Arena.create(allocator, 8),
    };

    const hdl_backpack = try importModel("assets/sea-keep-lonely-watcher/source/Stronghold.fbx", .{
        .transform = mat4.rotation(90, vec3.create(1, 0, 0)),
        .post_process = .{
            .triangulate = true,
            .split_large_meshes = true,
            .embed_textures = true,
            .flip_uvs = true,
        }
    });
    const backpack = try render_state.models.getPtr(hdl_backpack);

    for (backpack.meshes.items) |mesh| {
        const vertex_buffer_size: u32 = @intCast(mesh.vertices.items.len * @sizeOf(@TypeOf(mesh.vertices.items[0])));
        const buffer_size: u32 = @intCast(vertex_buffer_size + mesh.indices.items.len * @sizeOf(@TypeOf(mesh.indices.items[0])));
        const buffer = try device.createBuffer(.{
            .size = buffer_size,
            .usage = .{ .index = true, .vertex = true}
        });

        try uploadToBuffer(buffer, 0, std.mem.sliceAsBytes(mesh.vertices.items));
        try uploadToBuffer(buffer, vertex_buffer_size, std.mem.sliceAsBytes(mesh.indices.items));

        const render_obj = RenderObject {
            .buf = buffer,
            .transform = backpack.transform,
            .idx_offset = vertex_buffer_size,
            .idx_count = @intCast(mesh.indices.items.len),
            .textures = mesh.textures.items,
        };

        try render_state.objs.append(render_obj);
    }
}

pub fn shutdown() void {
    // var it = render_state.texture_cache.keyIterator();
    // while (it.next()) |key_str| {
    //     render_state.allocator.free(key_str);
    // }
    device.releaseTexture(window_state.tex_depth);

    device.releaseSampler(render_state.diffuse);
    device.releaseSampler(render_state.specular);
    device.releaseGraphicsPipeline(render_state.pipeline);
    device.destroy();
}

pub fn uploadToBuffer(buffer: *sdl.gpu.Buffer, offset: u32, data: []const u8) !void {
    const buf_transfer = try device.createTransferBuffer(.{
        .usage = .upload,
        .size = @intCast(data.len),
    });
    defer device.destroyTransferBuffer(buf_transfer);

    const map = try device.mapTransferBuffer(buf_transfer, false);
    @memcpy(map, data);
    device.unmapTransferBuffer(buf_transfer);

    const cmd = try device.acquireCommandBuffer();

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
    cmd.submit();
}

pub fn uploadToTexture(tex: *sdl.gpu.Texture, w: u32, h: u32, data: []const u8) !void {
    const buf_transfer = try device.createTransferBuffer(.{
        .size = @intCast(data.len),
        .usage = .upload
    });
    defer device.releaseTransferBuffer(buf_transfer);
    const ptr_transfer = try device.mapTransferBuffer(buf_transfer, false);
    @memcpy(ptr_transfer, data);
    device.unmapTransferBuffer(buf_transfer);

    // copy to transfer buffer
    const cmd = try device.acquireCommandBuffer();
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
    cmd.submit();
}

pub fn begin() !RenderCommand {
    render_state.pending_submit_result = .{};

    const cmd = sdl.gpu.acquireCommandBuffer(device) orelse {
        std.log.err("could not acquire command buffer", .{});
        return error.SDLError;
    };

    var drawable_w: u32 = undefined;
    var drawable_h: u32 = undefined;

    const swapchain = sdl.gpu.acquireSwapchainTexture(cmd, window_state.hdl_window, &drawable_w, &drawable_h) orelse {
        // No swapchain was acquired, probably too many frames in flight.
        return error.NoSwapchain;
    };

    // Resize the depth buffer if the window size changed

    if (window_state.prev_drawable_w != drawable_w or window_state.prev_drawable_h != drawable_h) {
        device.releaseTexture(window_state.tex_depth);
        window_state.tex_depth = try createDepthTexture(drawable_w, drawable_h);
    }

    window_state.prev_drawable_w = drawable_w;
    window_state.prev_drawable_h = drawable_h;

    var color_target = [1]sdl.gpu.ColorTargetInfo {.{
        .clear_color = .{ .r = 0, .g = 0.2, .b = 0.4, .a = 1 },
        .load_op = .clear,
        .store_op = .store,
        .texture = swapchain,
        .cycle = false,
    }};

    var depth_target = sdl.gpu.DepthStencilTargetInfo {
        .clear_depth = 1,
        .clear_stencil = 0,
        .load_op = .clear,
        .store_op = .store,
        .stencil_load_op = .clear,
        .stencil_store_op = .store,
        .texture = window_state.tex_depth,
        .cycle = true,
    };

    const w: f32 = @floatFromInt(drawable_w);
    const h: f32 = @floatFromInt(drawable_h);

    const pass = sdl.gpu.beginRenderPass(cmd, &color_target, 1, &depth_target) orelse {
        std.debug.panic("Could not begin render pass: {s}", .{sdl.getError()});
    };

    const cam = &render_state.scene.camera;
    const cam_pos = cam.position;

    var model = mat4.rotation(@as(f32, @floatFromInt(0)) / 5000, vec3.create(0, 1, 1));
    model.apply(mat4.rotation(@as(f32, @floatFromInt(0)) / 5000, vec3.create(1, 1, 0)));
    model.apply(mat4.vector_scale(vec3.create(0.1, 0.1, 0.1)));
    const view = hym_cam.lookAt(cam_pos, vec3.add(cam_pos, cam.look_direction), vec3.y);
    const persp = hym_cam.perspectiveMatrix(45, w / h, 0.5, 100);

    const lighting_ubo = LightingUBO {
        .light_dir = render_state.scene.light_dir,
        .camera_pos = render_state.scene.camera.position
    };

    sdl.gpu.pushFragmentUniformData(cmd, 0, &lighting_ubo, @sizeOf(LightingUBO));

    pass.bindGraphicsPipeline(render_state.pipeline);
    pass.setStencilReference(1);
    for (render_state.objs.items) |obj| {
        const m = mat4.mul(model, obj.transform);
        const ubo = TransformMatrices {
            .model = m,
            .mvp = mat4.mul(mat4.mul(persp, view), m),
            .normal_transform = mat4.transpose(mat4.inverse(m)),
        };

        sdl.gpu.pushVertexUniformData(cmd, 0, &ubo, @sizeOf(TransformMatrices));
        drawModel(pass, obj) catch continue;
    }

    // Draw outlines
    pass.bindGraphicsPipeline(render_state.outline_pipeline);

    for (render_state.objs.items) |obj| {
        var m = mat4.mul(model, obj.transform);
        m.mul(mat4.vector_scale(vec3.create(1, 1, 1)));
        const ubo = TransformMatrices {
            .model = m,
            .mvp = mat4.mul(mat4.mul(persp, view), m),
            .normal_transform = mat4.transpose(mat4.inverse(m)),
        };
        sdl.gpu.pushVertexUniformData(cmd, 0, &ubo, @sizeOf(TransformMatrices));
        drawModel(pass, obj) catch continue;
    }

    render_state.frames += 1;
    return .{ 
        .cmd = cmd,
        .pass = pass
    };
}

pub fn submit(render: RenderCommand) RenderSubmitResult {
    sdl.gpu.endRenderPass(render.pass);
    sdl.gpu.submitCommandBuffer(render.cmd);
    const result = render_state.pending_submit_result.?;
    render_state.pending_submit_result = null;
    return result;
}

pub fn createDepthTexture(w: u32, h: u32) (error{SDLError}!*sdl.gpu.Texture) {
    var depthtex_createinfo = sdl.gpu.TextureCreateInfo{
        .type = .@"2d",
        .format = .d32_float_s8_uint,
        .width = @intCast(w),
        .height = @intCast(h),
        .layer_count_or_depth = 1,
        .num_levels = 1,
        .sample_count = render_state.sample_count,
        .usage = .{ .depth_stencil_target = true },
        .props = 0,
    };

    return sdl.gpu.createTexture(device, &depthtex_createinfo) orelse {
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
        .layer_count_or_depth = 1,
        .num_levels = 1,
        .width = data.w,
        .sample_count = .@"1",
    };

    const tex = sdl.gpu.createTexture(device, &texture_info).?;
    try uploadToTexture(tex, data.w, data.h, data.data);

    const path_copy = try render_state.allocator.dupe(u8, name);
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
    const mod = try mdl.load(path, settings, render_state.allocator);
    return try render_state.models.insert(mod);
}

pub fn drawModel(pass: *sdl.gpu.RenderPass, obj: RenderObject) !void {
    const default_tex = try render_state.textures.get(obj.textures[0].hdl);
    var texes = [2]*sdl.gpu.Texture {default_tex, default_tex };
    for (obj.textures) |tex| {
        switch(tex.tex_type) {
            .diffuse => {
                texes[0] = render_state.textures.get(tex.hdl) catch default_tex;
            },
            .specular => {
                texes[1] = render_state.textures.get(tex.hdl) catch default_tex;
            }
        }
    }
    sdl.gpu.bindFragmentSamplers(pass, 0, &.{.{ .sampler = render_state.diffuse, .texture = texes[0] }}, 1);
    sdl.gpu.bindFragmentSamplers(pass, 1, &.{.{ .sampler = render_state.specular, .texture = texes[1] }}, 1);

    const vertex_binding = [1]sdl.gpu.BufferBinding{.{
        .buffer = obj.buf,
        .offset = 0,
    }};
    
    const index_binding = [1]sdl.gpu.BufferBinding {.{
        .buffer = obj.buf,
        .offset = obj.idx_offset,
    }};

    sdl.gpu.bindVertexBuffers(pass, 0, &vertex_binding, 1);
    sdl.gpu.bindIndexBuffer(pass, &index_binding, .@"32bit");
    sdl.gpu.drawIndexedPrimitives(pass, obj.idx_count, 1, 0, 0, 0);

    render_state.pending_submit_result.?.num_draw_calls += 1;
    render_state.pending_submit_result.?.num_drawn_verts += obj.idx_offset / @sizeOf(Vertex);
}

pub fn createOutlineShader(color_target_desc: []const sdl.gpu.ColorTargetDescription) *sdl.gpu.GraphicsPipeline {
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

    const vert_shader = device.createShader(@import("shaders/single_color.zig").vert_info) catch std.debug.panic("Could not load shader!", .{});
    defer device.releaseShader(vert_shader);
    const frag_shader = device.createShader(@import("shaders/single_color.zig").frag_info) catch std.debug.panic("Could not load shader!", .{});
    defer device.releaseShader(frag_shader);

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

    return device.createGraphicsPipeline(pipeline_desc) catch std.debug.panic("Could not create pipeline!", .{});
}