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

pub const Scene = struct {
    camera: camera.Camera,
};

const RenderState = struct {
    buf_vertex: *sdl.gpu.Buffer,
    pipeline: *sdl.gpu.GraphicsPipeline,
    sampler: *sdl.gpu.Sampler = undefined,
    texture: *sdl.gpu.Texture = undefined,
    scene: *Scene = undefined,
    sample_count: sdl.gpu.SampleCount = .@"1",
    frames: u32 = 0,
};

const RenderObject = struct {
    model: mat4.Mat4,
};

var models = [_]RenderObject{.{ .model = mat4.identity }} ** 4;

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

pub var device: *sdl.gpu.Device = undefined;
pub var render_state: RenderState = undefined;
pub var window_state: WindowState = .{};

pub var speed: f32 = 1;

pub fn init(hdl_window: *sdl.Window, in_scene: *Scene) !void {
    window_state.hdl_window = hdl_window;

    device = try sdl.gpu.Device.create(null, .{ .spirv = true });
    try device.claimWindow(hdl_window);

    const vertex_shader = try device.createShader(spirv.getVertexCreateInfo());
    defer device.releaseShader(vertex_shader);
    const fragment_shader = try device.createShader(spirv.getFragmentCreateInfo());
    defer device.releaseShader(fragment_shader);

    const buf_vertex = try device.createBuffer(.{
        .usage = .{ .vertex = true, .index = true },
        .size = @sizeOf(@TypeOf(cube)),
    });

    try upload(buf_vertex, &std.mem.toBytes(cube));

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
            .offset = @sizeOf(f32) * 3,
        },
        .{
            .buffer_slot = 0,
            .format = .float2,
            .location = 2,
            .offset = @sizeOf(f32) * 6,
        }
    };

    const pipeline_desc = sdl.gpu.GraphicsPipelineCreateInfo {
        .target_info = .{
            .num_color_targets = 1,
            .color_target_descriptions = color_target_desc.ptr,
            .depth_stencil_format = .d16_unorm,
            .has_depth_stencil_target = true,
        },
        .depth_stencil_state = .{
            .enable_depth_test = true,
            .enable_depth_write = true,
            .compare_op = .less_or_equal,
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

    const texture = loadTexture("textures/plywood_diff_1k.jpg");

    const sampler_info = sdl.gpu.SamplerCreateInfo {
        .address_mode_u = .clamp_to_edge,
        .address_mode_v = .clamp_to_edge,
        .address_mode_w = .clamp_to_edge,
        .min_filter = .linear,
        .mag_filter = .linear,
    };

    const sampler = sdl.gpu.createSampler(device, &sampler_info).?;

    render_state = .{
        .buf_vertex = buf_vertex,
        .frames = 0,
        .pipeline = pipeline,
        .sampler = sampler,
        .sample_count = sample_count,
        .scene = in_scene,
        .texture = texture,
    };

    models[1].model.translate(vec3.create(0, 1, -4));
    models[2].model.translate(vec3.create(3, 2, -2));
}

pub fn shutdown() void {
    device.releaseTexture(window_state.tex_depth);

    device.releaseTexture(render_state.texture);
    device.releaseBuffer(render_state.buf_vertex);
    device.releaseSampler(render_state.sampler);
    device.releaseGraphicsPipeline(render_state.pipeline);
    device.destroy();
}

pub fn upload(buffer: *sdl.gpu.Buffer, data: []const u8) !void {
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
        .offset = 0,
        .size = @intCast(data.len),
    };

    copy_pass.uploadToBuffer(buf_location, dst_region, false);
    copy_pass.end();
    cmd.submit();
}

pub fn uploadToTexture(texture: *sdl.gpu.Texture, w: u32, h: u32, data: []const u8) !void {
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
        .texture = texture,
        .w = w,
        .h = h,
        .d = 1,
    };

    copy_pass.uploadToTexture(buf_src, buf_dst, false);
    copy_pass.end();
    cmd.submit();
}


pub fn begin() !RenderCommand {
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
        // device.releaseTexture(window_state.tex_depth);
        // window_state.tex_depth = try createDepthTexture(drawable_w, drawable_h);
    }

    window_state.prev_drawable_w = drawable_w;
    window_state.prev_drawable_h = drawable_h;

    var color_target = [1]sdl.gpu.ColorTargetInfo{.{
        .clear_color = .{ .r = 0, .g = 0.2, .b = 0.4, .a = 1 },
        .load_op = .clear,
        .store_op = .store,
        .texture = swapchain,
        .cycle = false,
    }};

    var depth_target = sdl.gpu.DepthStencilTargetInfo{
        .clear_depth = 1,
        .load_op = .clear,
        .store_op = .store,
        .stencil_load_op = .dont_care,
        .stencil_store_op = .dont_care,
        .texture = window_state.tex_depth,
        .cycle = true,
    };


    const w: f32 = @floatFromInt(drawable_w);
    const h: f32 = @floatFromInt(drawable_h);

    const pass = sdl.gpu.beginRenderPass(cmd, &color_target, 1, &depth_target) orelse {
        std.log.err("could not begin render pass: {s}", .{sdl.getError()});
        return error.SDLError;
    };

    const cam = &render_state.scene.camera;
    const cam_pos = cam.position;
    const view = hym_cam.lookAt(cam_pos, vec3.add(cam_pos, cam.look_direction), vec3.y);
    const persp = hym_cam.perspectiveMatrix(45, w / h, 0.01, 100);

    for (&models) |*model| {
        model.model.spin(0.0004, vec3.create(1, 1, 0));
        model.model.spin(0.0001, vec3.create(0, 0, 1));
        var matrix_final: mat4.Mat4 = model.model;
        matrix_final.mul(view);
        matrix_final.mul(persp);
        // const mat_normal = mat4.inverse(mat4.transpose(mat4.mul(model.model, view)));
        // const mat_normal = mat4.transpose(mat4.inverse(model.model));
        // const mat_normal = mat4.mul(model.model, view);
        const mat_normal = model.model;
        const vert_ubo = .{
            matrix_final,
            mat_normal
        };

        sdl.gpu.pushVertexUniformData(cmd, 0, &vert_ubo, @sizeOf(@TypeOf(vert_ubo)));
        const vertex_binding = [1]sdl.gpu.BufferBinding{.{
            .buffer = render_state.buf_vertex,
            .offset = @offsetOf(@TypeOf(cube), "vertices"),
        }};
        
        const index_binding = [1]sdl.gpu.BufferBinding {.{
            .buffer = render_state.buf_vertex,
            .offset = @offsetOf(@TypeOf(cube), "indices"),
        }};

        sdl.gpu.bindGraphicsPipeline(pass, render_state.pipeline);
        sdl.gpu.bindVertexBuffers(pass, 0, &vertex_binding, 1);
        sdl.gpu.bindIndexBuffer(pass, &index_binding, .@"16bit");
        sdl.gpu.bindFragmentSamplers(pass, 0, &.{ .sampler = render_state.sampler, .texture =  render_state.texture }, 1);
        sdl.gpu.drawPrimitives(pass, 36, 1, 0, 0);
        sdl.gpu.drawIndexedPrimitives(pass, cube.indices.len, 1, 0, 0, 0);

    }


    render_state.frames += 1;
    return .{ 
        .cmd = cmd,
        .pass = pass
    };
}

pub fn submit(render: RenderCommand) void {
    sdl.gpu.endRenderPass(render.pass);
    sdl.gpu.submitCommandBuffer(render.cmd);

}

pub fn createDepthTexture(w: u32, h: u32) (error{SDLError}!*sdl.gpu.Texture) {
    var depthtex_createinfo = sdl.gpu.TextureCreateInfo{
        .type = .@"2d",
        .format = .d16_unorm,
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

fn loadShader(shader_type: ShaderType) !*sdl.gpu.Shader {
    const format: sdl.gpu.ShaderFormat = sdl.gpu.getShaderFormats(device);
    std.log.debug("selected format: {}", .{format});

    var create_info: sdl.gpu.ShaderCreateInfo = undefined;
    if (format.dxbc) {
        create_info = .{
            .num_samplers = 0,
            .num_storage_buffers = 0,
            .num_storage_textures = 0,
            .num_uniform_buffers = if (shader_type == .vertex) 1 else 0,
            .props = 0,
            .format = .{ .dxbc = true },
            .code = if (shader_type == .vertex) dxbc.D3D11_CubeVert else dxbc.D3D11_CubeFrag,
            .code_size = if (shader_type == .vertex) dxbc.D3D11_CubeVert.len else dxbc.D3D11_CubeFrag.len,
            .entrypoint = if (shader_type == .vertex) "VSMain" else "PSMain",
            .stage = if (shader_type == .vertex) .vertex else .fragment,
        };
    } else if (format.dxil) {
        create_info = .{
            .num_samplers = 0,
            .num_storage_buffers = 0,
            .num_storage_textures = 0,
            .num_uniform_buffers = if (shader_type == .vertex) 1 else 0,
            .props = 0,
            .format = .{ .dxil = true },
            .code = if (shader_type == .vertex) dxil.D3D12_CubeVert else dxil.D3D12_CubeFrag,
            .code_size = if (shader_type == .vertex) dxil.D3D12_CubeVert.len else dxil.D3D12_CubeFrag.len,
            .entrypoint = if (shader_type == .vertex) "VSMain" else "PSMain",
            .stage = if (shader_type == .vertex) .vertex else .fragment,
        };
    } else if (format.metallib) {
        std.log.debug("selected format: metallib", .{});
        create_info = .{
            .num_samplers = 0,
            .num_storage_buffers = 0,
            .num_storage_textures = 0,
            .num_uniform_buffers = if (shader_type == .vertex) 1 else 0,
            .props = 0,
            .format = .{ .metallib = true },
            .code = undefined,
            .code_size = 0,
            .entrypoint = "",
            .stage = if (shader_type == .vertex) .vertex else .fragment,
        };
        unreachable; //TODO: - add metal support
    } else {
        create_info = .{
            .num_samplers = if (shader_type == .vertex) 0 else 1,
            .num_storage_buffers = 0,
            .num_storage_textures = 0,
            .num_uniform_buffers = if (shader_type == .vertex) 1 else 0,
            .props = 0,
            .format = .{ .spirv = true },
            .code = if (shader_type == .vertex) &spirv.cube_shader_vert_spv else &spirv.cube_shader_frag_spv,
            .code_size = if (shader_type == .vertex) spirv.cube_shader_vert_spv.len else spirv.cube_shader_frag_spv.len,
            .entrypoint = "main",
            .stage = if (shader_type == .vertex) .vertex else .fragment,
        };
    }

}

fn loadTexture(path: [:0]const u8) *sdl.gpu.Texture {
    var c_w: c_int = 0;
    var c_h: c_int = 0;
    var c_d: c_int = 0;
    const tex_pixels = c.stbi_load(path.ptr, &c_w, &c_h, &c_d, 4);
    const w: u32 = @intCast(c_w);
    const h: u32 = @intCast(c_h);
    const d: u32 = 4;
    defer c.stbi_image_free(tex_pixels);
    const texture_info = sdl.gpu.TextureCreateInfo {
        .type = .@"2d",
        .format = .r8g8b8a8_unorm,
        .usage = .{ .sampler = true },
        .height = h,
        .layer_count_or_depth = 1,
        .num_levels = 1,
        .width = w,
        .sample_count = .@"1",
    };
    const texture = sdl.gpu.createTexture(device, &texture_info).?;

    const buf_trans_desc = sdl.gpu.TransferBufferCreateInfo {
        .size = w * h * d,
        .usage = .upload
    };

    const buf_transfer = sdl.gpu.createTransferBuffer(device, &buf_trans_desc);
    defer sdl.gpu.releaseTransferBuffer(device, buf_transfer);

    const ptr: [*]u8 = @ptrCast(@alignCast(sdl.gpu.mapTransferBuffer(device, buf_transfer, false)));
    @memcpy(ptr, tex_pixels[0..w * h * d]);

    const cmd = sdl.gpu.acquireCommandBuffer(device).?;
    const pass = sdl.gpu.beginCopyPass(cmd).?;

    sdl.gpu.uploadToTexture(pass, 
        &.{
            .offset = 0,
            .pixels_per_row = w,
            .rows_per_layer = h,
            .transfer_buffer = buf_transfer
        },
        &.{ 
            .texture = texture,
            .w = w,
            .h = h,
            .d = 1,
        }, 
        false
    );
    sdl.gpu.endCopyPass(pass);
    sdl.gpu.submitCommandBuffer(cmd);
    return texture;
}