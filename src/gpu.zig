const std = @import("std");
const c = @import("c.zig");
const window = @import("window.zig");

const vec3 = @import("hym/vec3.zig");
const mat4 = @import("hym/mat4.zig");
const cam = @import("hym/cam.zig");

const spirv = @import("cube_spirv.zig");
const dxil = @import("cube_dxil.zig");
const dxbc = @import("cube_dxbc.zig");

const sdl = @import("sdl/sdl.zig");

const ShaderType = enum { vertex, fragment };

const RenderState = struct {
    buf_vertex: *sdl.gpu.Buffer = undefined,
    pipeline: *sdl.gpu.GraphicsPipeline = undefined,
    sample_count: sdl.gpu.SampleCount = .@"1",
    frames: u32 = 0,
};

const WindowState = struct {
    hdl_window: *sdl.Window = undefined,
    angle: vec3.Vec3 = vec3.x,
    distance: f32 = 2.5,
    tex_depth: *sdl.gpu.Texture = undefined,
    msaa_tex: *sdl.gpu.Texture = undefined,
    prev_drawable_w: u32 = 0,
    prev_drawable_h: u32 = 0,
};

const vertex_data = [_][6]f32{
    // Front face. */
    // Bottom left */
    .{ -0.5,  0.5, -0.5, 1.0, 0.0, 0.0 }, // red //
    .{  0.5, -0.5, -0.5, 0.0, 0.0, 1.0 }, // blue //
    .{ -0.5, -0.5, -0.5, 0.0, 1.0, 0.0 }, // green //

    // Top right //
    .{ -0.5, 0.5, -0.5, 1.0, 0.0, 0.0 }, // red //
    .{ 0.5,  0.5, -0.5, 1.0, 1.0, 0.0 }, // yellow //
    .{ 0.5, -0.5, -0.5, 0.0, 0.0, 1.0 }, // blue //

    // Left face //
    // Bottom left //
    .{ -0.5,  0.5,  0.5, 1.0, 1.0, 1.0 }, // white //
    .{ -0.5, -0.5, -0.5, 0.0, 1.0, 0.0 }, // green //
    .{ -0.5, -0.5,  0.5, 0.0, 1.0, 1.0 }, // cyan //

    // Top right //
    .{ -0.5,  0.5,  0.5, 1.0, 1.0, 1.0 }, // white //
    .{ -0.5,  0.5, -0.5, 1.0, 0.0, 0.0 }, // red //
    .{ -0.5, -0.5, -0.5, 0.0, 1.0, 0.0 }, // green //

    // Top face //
    // Bottom left //
    .{ -0.5, 0.5,  0.5, 1.0, 1.0, 1.0 }, // white //
    .{  0.5, 0.5, -0.5, 1.0, 1.0, 0.0 }, // yellow //
    .{ -0.5, 0.5, -0.5, 1.0, 0.0, 0.0 }, // red //

    // Top right //
    .{ -0.5, 0.5,  0.5, 1.0, 1.0, 1.0 }, // white //
    .{  0.5, 0.5,  0.5, 0.0, 0.0, 0.0 }, // black //
    .{  0.5, 0.5, -0.5, 1.0, 1.0, 0.0 }, // yellow //

    // Right face //
    // Bottom left //
    .{ 0.5,  0.5, -0.5, 1.0, 1.0, 0.0 }, // yellow //
    .{ 0.5, -0.5,  0.5, 1.0, 0.0, 1.0 }, // magenta //
    .{ 0.5, -0.5, -0.5, 0.0, 0.0, 1.0 }, // blue //

    // Top right //
    .{ 0.5,  0.5, -0.5, 1.0, 1.0, 0.0 }, // yellow //
    .{ 0.5,  0.5,  0.5, 0.0, 0.0, 0.0 }, // black //
    .{ 0.5, -0.5,  0.5, 1.0, 0.0, 1.0 }, // magenta //

    // Back face //
    // Bottom left //
    .{  0.5,  0.5, 0.5, 0.0, 0.0, 0.0 }, // black //
    .{ -0.5, -0.5, 0.5, 0.0, 1.0, 1.0 }, // cyan //
    .{  0.5, -0.5, 0.5, 1.0, 0.0, 1.0 }, // magenta //

    // Top right //
    .{  0.5,  0.5,  0.5, 0.0, 0.0, 0.0 }, // black //
    .{ -0.5,  0.5,  0.5, 1.0, 1.0, 1.0 }, // white //
    .{ -0.5, -0.5,  0.5, 0.0, 1.0, 1.0 }, // cyan //

    // Bottom face //
    // Bottom left //
    .{ -0.5, -0.5, -0.5, 0.0, 1.0, 0.0 }, // green //
    .{  0.5, -0.5,  0.5, 1.0, 0.0, 1.0 }, // magenta //
    .{ -0.5, -0.5,  0.5, 0.0, 1.0, 1.0 }, // cyan //

    // Top right //
    .{ -0.5, -0.5, -0.5, 0.0, 1.0, 0.0 }, // green //
    .{  0.5, -0.5, -0.5, 0.0, 0.0, 1.0 }, // blue //
    .{  0.5, -0.5,  0.5, 1.0, 0.0, 1.0 } // magenta //
};


var gpu_device: *sdl.gpu.Device = undefined;
pub var render_state: RenderState = .{};
pub var window_state: WindowState = .{};

pub var speed: f32 = 1;

pub fn init(hdl_window: *sdl.Window) !void {
    window_state.hdl_window = hdl_window;

    const formats: sdl.gpu.ShaderFormat = sdl.gpu.ShaderFormatNames.dxbc |
                                          sdl.gpu.ShaderFormatNames.dxil |
                                          sdl.gpu.ShaderFormatNames.spirv;

    gpu_device = sdl.gpu.createDevice(formats, true, null) orelse {
        std.log.debug("Could not create GPU device: {s}", .{ sdl.c.SDL_GetError() });
        unreachable;
    };

    if (!sdl.gpu.claimWindowForDevice(gpu_device, hdl_window)) {
        std.log.debug("Could not claim window for GPU device: {s}", .{ sdl.c.SDL_GetError() });
    }

    const vertex_shader = try loadShader(.vertex);
    defer sdl.gpu.releaseShader(gpu_device, vertex_shader);
    const fragment_shader = try loadShader(.fragment);
    defer sdl.gpu.releaseShader(gpu_device, fragment_shader);

    var buffer_desc = sdl.gpu.BufferCreateInfo {
        .usage = sdl.gpu.BufferUsageNames.vertex,
        .size = @sizeOf(@TypeOf(vertex_data)),
        .props = 0,
    };

    render_state.buf_vertex = sdl.gpu.createBuffer(gpu_device, &buffer_desc) orelse {
        std.log.err("failed to create buffer: {s}", .{ sdl.getError() });
        return error.BufferCreateFailed;
    };

    sdl.gpu.setBufferName(gpu_device, render_state.buf_vertex, "mybuffer");

    const transfer_buffer_desc = sdl.gpu.TransferBufferCreateInfo {
        .usage = .upload,
        .size = @sizeOf(@TypeOf(vertex_data)),
        .props = 0,
    };

    const buf_transfer = sdl.gpu.createTransferBuffer(gpu_device, &transfer_buffer_desc) orelse {
        std.log.err("failed to create transfer buffer: {s}", .{ sdl.getError() });
        return error.BufferCreateFailed;
    };
    defer sdl.gpu.releaseTransferBuffer(gpu_device, buf_transfer);

    const map: [*]u8 = @ptrCast(sdl.gpu.mapTransferBuffer(gpu_device, buf_transfer, false).?);
    @memcpy(map, std.mem.asBytes(&vertex_data));
    sdl.gpu.unmapTransferBuffer(gpu_device, buf_transfer);

    const cmd = sdl.gpu.acquireCommandBuffer(gpu_device) orelse {
        std.log.err("failed to acquire command buffer: {s}", .{ sdl.getError() });
        return error.BeginCopyPassFailed;
    };

    const copy_pass = sdl.gpu.beginCopyPass(cmd) orelse {
        std.log.err("failed to begin copy pass: {s}", .{ sdl.getError() });
        return error.BeginCopyPassFailed;
    };

    var buf_location = sdl.gpu.TransferBufferLocation {
        .transfer_buffer = buf_transfer,
        .offset = 0,
    };

    var dst_region = sdl.gpu.BufferRegion {
        .buffer = render_state.buf_vertex,
        .offset = 0,
        .size = @sizeOf(@TypeOf(vertex_data)),
    };

    
    sdl.gpu.uploadToBuffer(copy_pass, &buf_location, &dst_region, false);
    sdl.gpu.endCopyPass(copy_pass);
    sdl.gpu.submitCommandBuffer(cmd);

    render_state.sample_count = .@"1";

    const color_target_desc: []const sdl.gpu.ColorTargetDescription = &.{.{ .format = sdl.gpu.getSwapchainTextureFormat(gpu_device, hdl_window) }};

    const vertex_buffer_desc: []const sdl.gpu.VertexBufferDescription = &.{.{
        .slot = 0,
        .input_rate = .vertex,
        .instance_step_rate = 0,
        .pitch = @sizeOf(@TypeOf(vertex_data[0])),
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
    };

    var pipeline_desc = sdl.gpu.GraphicsPipelineCreateInfo {
        .target_info = .{
            .num_color_targets = @intCast(color_target_desc.len),
            .color_target_descriptions = color_target_desc.ptr,
            .depth_stencil_format = .d16_unorm,
            .has_depth_stencil_target = true,
        },
        .depth_stencil_state = .{
            .enable_depth_test = true,
            .enable_depth_write = true,
            .compare_op = .less_or_equal,
        },
        .multisample_state = .{ .sample_count = render_state.sample_count },
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

    render_state.pipeline = sdl.gpu.createGraphicsPipeline(gpu_device, &pipeline_desc) orelse {
        std.log.err("Could not create pipeline: {s}", .{ sdl.getError() });
        unreachable;
    };

    var w: c_int = 0;
    var h: c_int = 0;
    _ = sdl.video.getWindowSizeInPixels(hdl_window, &w, &h);
    window_state.tex_depth = try createDepthTexture(@intCast(w), @intCast(h));

}

pub fn render() !void {
    const cmd = sdl.gpu.acquireCommandBuffer(gpu_device) orelse {
        std.log.err("could not acquire command buffer", .{});
        return error.SDLError;
    };
    defer sdl.gpu.submitCommandBuffer(cmd);

    var drawable_w: u32 = undefined;
    var drawable_h: u32 = undefined;

    const swapchain = sdl.gpu.acquireSwapchainTexture(cmd, window_state.hdl_window, &drawable_w, &drawable_h) orelse {
        // No swapchain was acquired, probably too many frames in flight.
        return;
    };

    // Resize the depth buffer if the window size changed

    if (window_state.prev_drawable_w != drawable_w or window_state.prev_drawable_h != drawable_h) {
        sdl.gpu.releaseTexture(gpu_device, window_state.tex_depth);
        window_state.tex_depth = try createDepthTexture(drawable_w, drawable_h);
    }
    window_state.prev_drawable_w = drawable_w;
    window_state.prev_drawable_h = drawable_h;

    var color_target = [1]sdl.gpu.ColorTargetInfo {.{
        .clear_color = .{ .r = 0, .g = 0.2, .b = 0.4, .a = 1 },
        .load_op = .clear,
        .store_op = .dont_care,
        .texture = swapchain,
        .cycle = false,
    }};

    var depth_target = sdl.gpu.DepthStencilTargetInfo {
        .clear_depth = 1,
        .load_op = .clear,
        .store_op = .dont_care,
        .texture = window_state.tex_depth,
        .cycle = true,
    };

    const vertex_binding = [1]sdl.gpu.BufferBinding {.{
        .buffer = render_state.buf_vertex,
        .offset = 0,
    }};

    const w: f32 = @floatFromInt(drawable_w);
    const h: f32 = @floatFromInt(drawable_h);

    var cam_pos = vec3.mul(vec3.x, window_state.distance);
    cam_pos.rotate(vec3.y, -window_state.angle.y());
    cam_pos.rotate(vec3.x, window_state.angle.x());
    // cam_pos.rotate(vec3.z, window_state.angle.z());

    const view = cam.lookAt(cam_pos, vec3.zero, vec3.y);
    const persp = cam.perspectiveMatrix(45, w / h, 0.01, 100);
    const matrix_final = mat4.mul(view, persp);

    sdl.gpu.pushVertexUniformData(cmd, 0, std.mem.asBytes(&matrix_final), @sizeOf(@TypeOf(matrix_final)));

    const pass = sdl.gpu.beginRenderPass(cmd, &color_target, 1, &depth_target) orelse {
        std.log.err("could not begin render pass: {s}", .{ sdl.getError() });
        return error.SDLError;
    };
    defer sdl.gpu.endRenderPass(pass);

    sdl.gpu.bindGraphicsPipeline(pass, render_state.pipeline);
    sdl.gpu.bindVertexBuffers(pass, 0, &vertex_binding, 1);
    sdl.gpu.drawPrimitives(pass, 36, 1, 0, 0);

    render_state.frames += 1;
}

pub fn createDepthTexture(w: u32, h: u32) (error{SDLError}!*sdl.gpu.Texture) {
    var depthtex_createinfo = sdl.gpu.TextureCreateInfo {
        .type = .@"2d",
        .format = .d16_unorm,
        .width = @intCast(w),
        .height = @intCast(h),
        .layer_count_or_depth = 1,
        .num_levels = 1,
        .sample_count = render_state.sample_count,
        .usage = sdl.gpu.TextureUsageNames.depth_stencil_target,
        .props = 0,
    };

    return sdl.gpu.createTexture(gpu_device, &depthtex_createinfo) orelse {
        std.log.err("could not create depth texture: {s}", .{ sdl.getError() });
        return error.SDLError;
    };
}

fn loadShader(shader_type: ShaderType) !*sdl.gpu.Shader {
    const format: sdl.gpu.ShaderFormat = sdl.gpu.getShaderFormats(gpu_device);
    std.log.debug("selected format: {}", .{ format });

    var create_info: sdl.gpu.ShaderCreateInfo = undefined;
    if (format & sdl.gpu.ShaderFormatNames.dxbc != 0) {
        create_info = .{
            .num_samplers = 0,
            .num_storage_buffers = 0,
            .num_storage_textures = 0,
            .num_uniform_buffers = if (shader_type == .vertex) 1 else 0,
            .props = 0,
            .format = sdl.gpu.ShaderFormatNames.dxbc,
            .code = if (shader_type == .vertex) dxbc.D3D11_CubeVert else dxbc.D3D11_CubeFrag,
            .code_size = if (shader_type == .vertex) dxbc.D3D11_CubeVert.len else dxbc.D3D11_CubeFrag.len,
            .entrypoint = if (shader_type == .vertex) "VSMain" else "PSMain",
            .stage = if (shader_type == .vertex) .vertex else .fragment,
        };
    } else if (format & sdl.gpu.ShaderFormatNames.dxil != 0) {
        create_info = .{
            .num_samplers = 0,
            .num_storage_buffers = 0,
            .num_storage_textures = 0,
            .num_uniform_buffers = if (shader_type == .vertex) 1 else 0,
            .props = 0,
            .format = sdl.gpu.ShaderFormatNames.dxil,
            .code = if (shader_type == .vertex) dxil.D3D12_CubeVert else dxil.D3D12_CubeFrag,
            .code_size = if (shader_type == .vertex) dxil.D3D12_CubeVert.len else dxil.D3D12_CubeFrag.len,
            .entrypoint = if (shader_type == .vertex) "VSMain" else "PSMain",
            .stage = if (shader_type == .vertex) .vertex else .fragment,
        };
    } else if (format & sdl.gpu.ShaderFormatNames.metallib != 0) {
        std.log.debug("selected format: metallib", .{});
        create_info = .{
            .num_samplers = 0,
            .num_storage_buffers = 0,
            .num_storage_textures = 0,
            .num_uniform_buffers = if (shader_type == .vertex) 1 else 0,
            .props = 0,
            .format = sdl.gpu.ShaderFormatNames.metallib,
            .code = undefined,
            .code_size = 0,
            .entrypoint = "",
            .stage = if (shader_type == .vertex) .vertex else .fragment,
        };
        unreachable; //TODO: - add metal support
    } else {
        create_info = .{
            .num_samplers = 0,
            .num_storage_buffers = 0,
            .num_storage_textures = 0,
            .num_uniform_buffers = if (shader_type == .vertex) 1 else 0,
            .props = 0,
            .format = sdl.gpu.ShaderFormatNames.spirv,
            .code = if (shader_type == .vertex) spirv.cube_vert_spv else spirv.cube_frag_spv,
            .code_size = if (shader_type == .vertex) spirv.cube_vert_spv.len else spirv.cube_frag_spv.len,
            .entrypoint = "main",
            .stage = if (shader_type == .vertex) .vertex else .fragment,
        };
    }

    return sdl.gpu.createShader(gpu_device, &create_info) orelse {
        std.log.debug("Failed to load shader: {s}", .{ sdl.getError() });
        return error.LoadShaderFailed;
    };
}
