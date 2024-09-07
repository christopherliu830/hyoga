const std = @import("std");
const c = @import("c.zig");
const window = @import("window.zig");
const hym = @import("hym/hym.zig");
const spirv = @import("cube_spirv.zig");

const GpuDriver = enum (u8) {
    d3d11 = c.SDL_GPU_DRIVER_D3D11,
    d3d12 = c.SDL_GPU_DRIVER_D3D12,
    metal = c.SDL_GPU_DRIVER_METAL,
    _,
};


const gpu_supported_formats = c.SDL_GPU_SHADERFORMAT_DXBC |
                              c.SDL_GPU_SHADERFORMAT_DXIL |
                              c.SDL_GPU_SHADERFORMAT_SPIRV |
                              c.SDL_GPU_DRIVER_METAL;
const ShaderType = enum {
    vertex,
    fragment
};

const RenderState = struct {
    buf_vertex: *c.SDL_GPUBuffer = undefined,
    pipeline: *c.SDL_GPUGraphicsPipeline = undefined,
    sample_count: c.SDL_GPUSampleCount = 0,
    frames: u32 = 0,
};

const WindowState = struct {
    hdl_window: window.Handle = undefined,
    angle: hym.Vec3 = hym.vec3.zero,
    tex_depth: *c.SDL_GPUTexture = undefined,
    msaa_tex: *c.SDL_GPUTexture = undefined,
    prev_drawable_w: u32 = 0,
    prev_drawable_h: u32 = 0,
};

const vertex_data = [_][6]f32 {
    // Front face.
    // Bottom left */
    .{ -0.5,  0.5, -0.5, 1.0, 0.0, 0.0 }, // red */
    .{  0.5, -0.5, -0.5, 0.0, 0.0, 1.0 }, // blue */
    .{ -0.5, -0.5, -0.5, 0.0, 1.0, 0.0 }, // green */

    // Top right */
    .{ -0.5, 0.5, -0.5, 1.0, 0.0, 0.0 }, // red */
    .{ 0.5,  0.5, -0.5, 1.0, 1.0, 0.0 }, // yellow */
    .{ 0.5, -0.5, -0.5, 0.0, 0.0, 1.0 }, // blue */

    // Left face */
    // Bottom left */
    .{ -0.5,  0.5,  0.5, 1.0, 1.0, 1.0 }, // white */
    .{ -0.5, -0.5, -0.5, 0.0, 1.0, 0.0 }, // green */
    .{ -0.5, -0.5,  0.5, 0.0, 1.0, 1.0 }, // cyan */

    // Top right */
    .{ -0.5,  0.5,  0.5, 1.0, 1.0, 1.0 }, // white */
    .{ -0.5,  0.5, -0.5, 1.0, 0.0, 0.0 }, // red */
    .{ -0.5, -0.5, -0.5, 0.0, 1.0, 0.0 }, // green */

    // Top face */
    // Bottom left */
    .{ -0.5, 0.5,  0.5, 1.0, 1.0, 1.0 }, // white */
    .{  0.5, 0.5, -0.5, 1.0, 1.0, 0.0 }, // yellow */
    .{ -0.5, 0.5, -0.5, 1.0, 0.0, 0.0 }, // red */

    // Top right */
    .{ -0.5, 0.5,  0.5, 1.0, 1.0, 1.0 }, // white */
    .{  0.5, 0.5,  0.5, 0.0, 0.0, 0.0 }, // black */
    .{  0.5, 0.5, -0.5, 1.0, 1.0, 0.0 }, // yellow */

    // Right face */
    // Bottom left */
    .{ 0.5,  0.5, -0.5, 1.0, 1.0, 0.0 }, // yellow */
    .{ 0.5, -0.5,  0.5, 1.0, 0.0, 1.0 }, // magenta */
    .{ 0.5, -0.5, -0.5, 0.0, 0.0, 1.0 }, // blue */

    // Top right */
    .{ 0.5,  0.5, -0.5, 1.0, 1.0, 0.0 }, // yellow */
    .{ 0.5,  0.5,  0.5, 0.0, 0.0, 0.0 }, // black */
    .{ 0.5, -0.5,  0.5, 1.0, 0.0, 1.0 }, // magenta */

    // Back face */
    // Bottom left */
    .{  0.5,  0.5, 0.5, 0.0, 0.0, 0.0 }, // black */
    .{ -0.5, -0.5, 0.5, 0.0, 1.0, 1.0 }, // cyan */
    .{  0.5, -0.5, 0.5, 1.0, 0.0, 1.0 }, // magenta */

    // Top right */
    .{  0.5,  0.5,  0.5, 0.0, 0.0, 0.0 }, // black */
    .{ -0.5,  0.5,  0.5, 1.0, 1.0, 1.0 }, // white */
    .{ -0.5, -0.5,  0.5, 0.0, 1.0, 1.0 }, // cyan */

    // Bottom face */
    // Bottom left */
    .{ -0.5, -0.5, -0.5, 0.0, 1.0, 0.0 }, // green */
    .{  0.5, -0.5,  0.5, 1.0, 0.0, 1.0 }, // magenta */
    .{ -0.5, -0.5,  0.5, 0.0, 1.0, 1.0 }, // cyan */

    // Top right */
    .{ -0.5, -0.5, -0.5, 0.0, 1.0, 0.0 }, // green */
    .{  0.5, -0.5, -0.5, 0.0, 0.0, 1.0 }, // blue */
    .{  0.5, -0.5,  0.5, 1.0, 0.0, 1.0 }  // magenta */
};


var gpu_device: *c.SDL_GPUDevice = undefined;
var render_state: RenderState = .{};
var window_state: WindowState = .{};

pub fn init(hdl_window: window.Handle) !void {
    window_state.hdl_window = hdl_window;

    gpu_device = c.SDL_CreateGPUDevice(
        gpu_supported_formats,
        true,
        null
    ) orelse unreachable;

    if (!c.SDL_ClaimWindowForGPUDevice(
        gpu_device,
        hdl_window
    )) {
        c.SDL_Log("Could not claim window for GPU device: %s", c.SDL_GetError());
    }

    const vertex_shader = try loadShader(.vertex);
    defer c.SDL_ReleaseGPUShader(gpu_device, vertex_shader);
    const fragment_shader = try loadShader(.fragment);
    defer c.SDL_ReleaseGPUShader(gpu_device, fragment_shader);

    var buffer_desc = c.SDL_GPUBufferCreateInfo {
        .usageFlags = c.SDL_GPU_BUFFERUSAGE_VERTEX,
        .sizeInBytes = @sizeOf(@TypeOf(vertex_data)),
        .props = 0,
    };

    render_state.buf_vertex = c.SDL_CreateGPUBuffer(gpu_device, &buffer_desc) orelse {
        c.SDL_Log("failed to create buffer: %s", c.SDL_GetError());
        unreachable;
    };

    c.SDL_SetGPUBufferName(gpu_device, render_state.buf_vertex, "mybuffer");

    var transfer_buffer_desc = c.SDL_GPUTransferBufferCreateInfo {
        .usage = c.SDL_GPU_TRANSFERBUFFERUSAGE_UPLOAD,
        .sizeInBytes = @sizeOf(@TypeOf(vertex_data)),
        .props = 0,
    };

    const buf_transfer = c.SDL_CreateGPUTransferBuffer(gpu_device, &transfer_buffer_desc) orelse {
        c.SDL_Log("failed to create transfer buffer: %s", c.SDL_GetError());
        unreachable;
    };
    defer c.SDL_ReleaseGPUTransferBuffer(gpu_device, buf_transfer);


    const map: [*]u8 = @ptrCast(c.SDL_MapGPUTransferBuffer(gpu_device, buf_transfer, false).?);
    @memcpy(map, std.mem.asBytes(&vertex_data));
    c.SDL_UnmapGPUTransferBuffer(gpu_device, buf_transfer);

    const cmd = c.SDL_AcquireGPUCommandBuffer(gpu_device);
    const copy_pass = c.SDL_BeginGPUCopyPass(cmd);

    var buf_location = c.SDL_GPUTransferBufferLocation {
        .transferBuffer = buf_transfer,
        .offset = 0,
    };

    var dst_region = c.SDL_GPUBufferRegion {
        .buffer = render_state.buf_vertex,
        .offset = 0,
        .size = @sizeOf(@TypeOf(vertex_data)),
    };

    c.SDL_UploadToGPUBuffer(copy_pass, &buf_location, &dst_region, false);
    c.SDL_EndGPUCopyPass(copy_pass);
    c.SDL_SubmitGPUCommandBuffer(cmd);

    render_state.sample_count = c.SDL_GPU_SAMPLECOUNT_1;

    var pipeline_desc = c.SDL_GPUGraphicsPipelineCreateInfo { };

    var color_attachment_desc = c.SDL_GPUColorAttachmentDescription {
        .format = c.SDL_GetGPUSwapchainTextureFormat(gpu_device, hdl_window),
        .blendState = .{
            .blendEnable = false,
            .alphaBlendOp = c.SDL_GPU_BLENDOP_ADD,
            .colorBlendOp = c.SDL_GPU_BLENDOP_ADD,
            .colorWriteMask = 0xF,
            .srcAlphaBlendFactor = c.SDL_BLENDFACTOR_ONE,
            .dstAlphaBlendFactor = c.SDL_BLENDFACTOR_ZERO,
            .srcColorBlendFactor = c.SDL_BLENDFACTOR_ONE,
            .dstColorBlendFactor = c.SDL_BLENDFACTOR_ZERO,
        }
    };

    pipeline_desc.attachmentInfo.colorAttachmentCount = 1;
    pipeline_desc.attachmentInfo.colorAttachmentDescriptions = &color_attachment_desc;
    pipeline_desc.attachmentInfo.depthStencilFormat = c.SDL_GPU_TEXTUREFORMAT_D16_UNORM;
    pipeline_desc.attachmentInfo.hasDepthStencilAttachment = true;

    pipeline_desc.depthStencilState.depthTestEnable = true;
    pipeline_desc.depthStencilState.depthWriteEnable = true;
    pipeline_desc.depthStencilState.compareOp = c.SDL_GPU_COMPAREOP_LESS_OR_EQUAL;

    pipeline_desc.multisampleState.sampleCount = render_state.sample_count;
    pipeline_desc.multisampleState.sampleMask = 0xF;

    pipeline_desc.primitiveType = c.SDL_GPU_PRIMITIVETYPE_TRIANGLELIST;

    pipeline_desc.vertexShader = vertex_shader;
    pipeline_desc.fragmentShader = fragment_shader;

    var vertex_binding = c.SDL_GPUVertexBinding {
        .binding = 0,
        .inputRate = c.SDL_GPU_VERTEXINPUTRATE_VERTEX,
        .instanceStepRate = 0,
        .stride = @sizeOf(@TypeOf(vertex_data[0])),
    };

    var vertex_attributes = [_]c.SDL_GPUVertexAttribute {
        .{
            .binding = 0,
            .format = c.SDL_GPU_VERTEXELEMENTFORMAT_FLOAT3,
            .location = 0,
            .offset = 0,
        },
        .{
            .binding = 0,
            .format = c.SDL_GPU_VERTEXELEMENTFORMAT_FLOAT3,
            .location = 1,
            .offset = @sizeOf(f32) * 3,
        },
    };

    pipeline_desc.vertexInputState.vertexBindingCount = 1;
    pipeline_desc.vertexInputState.vertexBindings = &vertex_binding;
    pipeline_desc.vertexInputState.vertexAttributeCount = 2;
    pipeline_desc.vertexInputState.vertexAttributes = &vertex_attributes;

    pipeline_desc.props = 0;

    render_state.pipeline = c.SDL_CreateGPUGraphicsPipeline(gpu_device, &pipeline_desc).?;

    var w: c_int = 0;
    var h: c_int = 0;
    _ = c.SDL_GetWindowSizeInPixels(hdl_window, &w,&h);
    window_state.tex_depth = try createDepthTexture(@intCast(w), @intCast(h));
}

pub fn render() !void {
    const cmd = c.SDL_AcquireGPUCommandBuffer(gpu_device);
    var drawable_w: u32 = undefined;
    var drawable_h: u32 = undefined;

    const swapchain = c.SDL_AcquireGPUSwapchainTexture(cmd, window_state.hdl_window, &drawable_w, &drawable_h) orelse {
        // No swapchain was acquired, probably too many frames in flight.
        return;
    };

    // Resize the depth buffer if the window size changed

    if (window_state.prev_drawable_w != drawable_w or window_state.prev_drawable_h != drawable_h) {
        c.SDL_ReleaseGPUTexture(gpu_device, window_state.tex_depth);
        window_state.tex_depth = try createDepthTexture(drawable_w, drawable_h);
    }
    window_state.prev_drawable_w = drawable_w;
    window_state.prev_drawable_h = drawable_h;

    var color_attachment = c.SDL_GPUColorAttachmentInfo {
        .clearColor = .{ .r = 0, .g = 0.2, .b = 0.4, .a = 1 },
        .loadOp = c.SDL_GPU_LOADOP_CLEAR,
        .storeOp = c.SDL_GPU_STOREOP_DONT_CARE,
        .texture = swapchain,
    };

    var depth_attachment = c.SDL_GPUDepthStencilAttachmentInfo {
        .depthStencilClearValue = .{ .depth = 1 },
        .loadOp = c.SDL_GPU_LOADOP_CLEAR,
        .storeOp = c.SDL_GPU_STOREOP_DONT_CARE,
        .texture = window_state.tex_depth,
        .cycle = true,
    };

    var vertex_binding = c.SDL_GPUBufferBinding {
        .buffer = render_state.buf_vertex,
        .offset = 0,
    };

    const w: f32 = @floatFromInt(drawable_w);
    const h: f32 = @floatFromInt(drawable_h);

    var modelview = hym.mat4.identity;

    modelview.translate(hym.vec(.{ 0, 0, -2.5 }));
    modelview.spin(@as(f32, @floatFromInt(render_state.frames)) / 500, hym.vec(.{ 1, 1, 1 }));

    const persp = hym.cam.perspectiveMatrix(45, w/h, 0.01, 100);
    const matrix_final = hym.mat4.mul(modelview, persp);

    c.SDL_PushGPUVertexUniformData(cmd, 0, std.mem.asBytes(&matrix_final), @sizeOf(hym.Mat4));

    const pass = c.SDL_BeginGPURenderPass(cmd, &color_attachment, 1, &depth_attachment);
    c.SDL_BindGPUGraphicsPipeline(pass, render_state.pipeline);
    c.SDL_BindGPUVertexBuffers(pass, 0, &vertex_binding, 1);
    c.SDL_DrawGPUPrimitives(pass, 36, 1, 0, 0);
    c.SDL_EndGPURenderPass(pass);

    c.SDL_SubmitGPUCommandBuffer(cmd);

    render_state.frames += 1;
}

pub fn createDepthTexture(w: u32, h: u32) (error{SDLError}!*c.SDL_GPUTexture) {
    var depthtex_createinfo = c.SDL_GPUTextureCreateInfo {
        .type = c.SDL_GPU_TEXTURETYPE_2D,
        .format = c.SDL_GPU_TEXTUREFORMAT_D16_UNORM,
        .width = @intCast(w),
        .height = @intCast(h),
        .layerCountOrDepth = 1,
        .levelCount = 1,
        .sampleCount = render_state.sample_count,
        .usageFlags = c.SDL_GPU_TEXTUREUSAGE_DEPTH_STENCIL_TARGET,
        .props = 0,
    };

    return c.SDL_CreateGPUTexture(gpu_device, &depthtex_createinfo) orelse {
        c.SDL_Log("could not create depth texture: %s", c.SDL_GetError());
        return error.SDLError;
    };
}
    
fn loadShader(shader_type: ShaderType) !*c.SDL_GPUShader {
    var create_info = c.SDL_GPUShaderCreateInfo {
        .samplerCount = 0,
        .storageBufferCount = 0,
        .storageTextureCount = 0,
        .uniformBufferCount = if (shader_type == .vertex) 1 else 0,
        .props = 0,
    };

    const backend: c_int = c.SDL_GetGPUDriver(gpu_device);
    if (backend == c.SDL_GPU_DRIVER_D3D11) {
        create_info.format = c.SDL_GPU_SHADERFORMAT_DXBC;
        create_info.code = 0;
        create_info.codeSize = 0;
        create_info.entryPointName = "";
    } else if (backend == c.SDL_GPU_DRIVER_D3D12) {
        create_info.format = c.SDL_GPU_SHADERFORMAT_DXIL;
        create_info.code = 0;
        create_info.codeSize = 0;
        create_info.entryPointName = "";
    } else if (backend == c.SDL_GPU_SHADERFORMAT_METALLIB) {
        create_info.format = c.SDL_GPU_SHADERFORMAT_METALLIB;
        create_info.code = 0;
        create_info.codeSize = 0;
        create_info.entryPointName = "";
    } else {
        create_info.format = c.SDL_GPU_SHADERFORMAT_SPIRV;
        create_info.code = if (shader_type == .vertex) spirv.cube_vert_spv else spirv.cube_frag_spv;
        create_info.codeSize = if (shader_type == .vertex) spirv.cube_vert_spv.len else spirv.cube_frag_spv.len;
        create_info.entryPointName = "main";
    }

    create_info.stage = if (shader_type == .vertex) c.SDL_GPU_SHADERSTAGE_VERTEX else c.SDL_GPU_SHADERSTAGE_FRAGMENT;
    return c.SDL_CreateGPUShader(gpu_device, &create_info) orelse {
        c.SDL_Log("Failed to load shader: %s", c.SDL_GetError());
        return error.LoadShaderFailed;
    };

}