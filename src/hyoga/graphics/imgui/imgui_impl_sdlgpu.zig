const std = @import("std");
const sdl = @import("sdl");
const gpu = @import("../gpu.zig");
const imgui = @import("imgui.zig");
const spirv = @import("spirv.zig");
const shader_code = @import("../shaders/imgui_shader.zig");

const ShaderType = enum { vertex, fragment };

const ImplData = struct {
    allocator: std.mem.Allocator,
    device: *sdl.gpu.Device,
    window: *sdl.Window,
    pipeline: *sdl.gpu.GraphicsPipeline,
    font_texture: *sdl.gpu.Texture,
    buf_vertex: ?*sdl.gpu.Buffer = null,
    size_buf_vertex: u32 = 0,
    buf_index: ?*sdl.gpu.Buffer = null,
    size_buf_index: u32 = 0,
    sampler: *sdl.gpu.Sampler,
};

pub const InitInfo = struct {
    device: *sdl.gpu.Device,
    window: *sdl.Window,
};

pub fn getBackendData() ?*ImplData {
    return if (imgui.getCurrentContext() != null) @alignCast(@ptrCast(imgui.getIO().BackendRendererUserData)) else null;
}

pub fn init(info: *const InitInfo, allocator: std.mem.Allocator) !void {
    const io = imgui.getIO();
    std.debug.assert(io.BackendRendererUserData == null);

    const bd = try allocator.create(ImplData);
    io.BackendRendererUserData = @ptrCast(bd);
    bd.device = info.device;

    bd.* = .{
        .allocator = allocator,
        .device = info.device,
        .window = info.window,
        .pipeline = try createPipeline(),
        .font_texture = try createFontsTexture(),
        .sampler = createSampler(),
    };

    io.BackendRendererName = "imgui_impl_sdlgpu";
    io.BackendFlags |= imgui.backend_flags_renderer_has_vtx_offset;
}

pub fn shutdown() void {
    const bd = getBackendData().?;
    const io = imgui.getIO();

    io.BackendRendererUserData = null;
    io.BackendRendererName = null;
    io.BackendFlags &= ~(imgui.backend_flags_renderer_has_vtx_offset);

    bd.device.releaseSampler(bd.sampler);
    bd.device.releaseTexture(bd.font_texture);
    bd.device.releaseGraphicsPipeline(bd.pipeline);
    if (bd.buf_vertex) |buf| { bd.device.releaseBuffer(buf);}
    if (bd.buf_index) |buf| { bd.device.releaseBuffer(buf); }

    bd.allocator.destroy(bd);
}

pub fn newFrame() !void {
    // do nothing
}

pub fn createPipeline() !*sdl.gpu.GraphicsPipeline {
    const bd = getBackendData().?;

    const vert_shader = bd.device.createShader(&shader_code.vert_info).?;
    defer bd.device.releaseShader(vert_shader);

    const frag_shader = bd.device.createShader(&shader_code.frag_info).?;
    defer bd.device.releaseShader(frag_shader);

    const vertex_buffer_desc: []const sdl.gpu.VertexBufferDescription = &.{.{
        .slot = 0,
        .input_rate = .vertex,
        .instance_step_rate = 0,
        .pitch = @sizeOf(imgui.ImDrawVert),
    }};

    const vertex_attributes: []const sdl.gpu.VertexAttribute = &.{
        .{
            .buffer_slot = 0,
            .format = .float2,
            .location = 0,
            .offset = @offsetOf(imgui.ImDrawVert, "pos"),
        },
        .{
            .buffer_slot = 0,
            .format = .float2,
            .location = 1,
            .offset = @offsetOf(imgui.ImDrawVert, "uv"),
        },
        .{
            .buffer_slot = 0,
            .format = .ubyte4_norm,
            .location = 2,
            .offset = @offsetOf(imgui.ImDrawVert, "col"),
        },
    };

    const color_target_desc = [_]sdl.gpu.ColorTargetDescription {.{ 
        .format = bd.device.getSwapchainTextureFormat(bd.window),
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

    const pipeline = sdl.gpu.GraphicsPipelineCreateInfo {
        .target_info = .{
            .num_color_targets = 1,
            .color_target_descriptions = &color_target_desc,
            .has_depth_stencil_target = false,
        },
        .rasterizer_state = .{
            .fill_mode = .fill,
            .cull_mode = .none,
            .front_face = .clockwise,
            .depth_bias_constant_factor = 0,
            .depth_bias_clamp = 0,
            .depth_bias_slope_factor = 0,
            .enable_depth_bias = true,
        },
        .depth_stencil_state = .{
            .enable_depth_test = false,
            .enable_depth_write = false,
            .enable_stencil_test = false,
            .compare_op = .never,
        },
        .primitive_type = .trianglelist,
        .vertex_shader = vert_shader,
        .fragment_shader = frag_shader,
        .vertex_input_state = .{
            .num_vertex_buffers = @intCast(vertex_buffer_desc.len),
            .vertex_buffer_descriptions = vertex_buffer_desc.ptr,
            .num_vertex_attributes = vertex_attributes.len,
            .vertex_attributes = vertex_attributes.ptr,
        },
        .props = 0,
    };

    return bd.device.createGraphicsPipeline(&pipeline).?;
}

pub fn createDeviceObjects() !void {
    const bd = getBackendData().?;
    bd.pipeline = try createPipeline();
    bd.color_target = sdl.gpu.ColorTargetInfo {

    };
    bd.font_texture = try createFontsTexture();
    bd.sampler = try createSampler();
}

pub fn createFontsTexture() !*sdl.gpu.Texture {
    const io = imgui.getIO();
    const bd = getBackendData().?;

    // get texture data
    var pixels: [*c]u8 = undefined;
    var out_width: c_int = 0;
    var out_height: c_int = 0;
    imgui.ImFontAtlas_GetTexDataAsRGBA32(io.Fonts, &pixels, &out_width, &out_height, null);
    const w: u32 = @intCast(out_width);
    const h: u32 = @intCast(out_height);

    const texture = bd.device.createTexture(&.{
        .type = .@"2d",
        .format = .r8g8b8a8_unorm,
        .usage = .{ .sampler = true },
        .width = w,
        .height = h,
        .layer_count_or_depth = 1,
        .num_levels = 1,
    }).?;

    // const buf_transfer = try bd.device.createTransferBuffer(.{
    //     .size = @intCast(out_width * out_height * 4),
    //     .usage = .upload
    // });

    try gpu.uploadToTexture(texture, w, h, pixels[0..@intCast(out_width * out_height * 4)]);
    // defer bd.device.releaseTransferBuffer(buf_transfer);
    // const ptr_transfer = bd.device.mapTransferBuffer(buf_transfer, false);
    // @memcpy(ptr_transfer, pixels[0..@intCast(out_width * out_height * 4)]);
    // bd.device.unmapTransferBuffer(buf_transfer);

    // // copy to transfer buffer
    // const cmd = try bd.device.acquireCommandBuffer();
    // const copy_pass = try cmd.beginCopyPass();

    // const buf_src = gpu.TextureTransferInfo {
    //     .transfer_buffer = buf_transfer,
    //     .offset = 0,
    //     .pixels_per_row = @intCast(out_width),
    //     .rows_per_layer = @intCast(out_height),
    // };

    // const buf_dst = gpu.TextureRegion {
    //     .texture = texture,
    //     .w = @intCast(out_width),
    //     .h = @intCast(out_height),
    //     .d = 1,
    // };

    // gpu.uploadToTexture(copy_pass, &buf_src, &buf_dst, false);

    return texture;

    // bd.font_texture = texture;

    // const sampler_info = gpu.SamplerCreateInfo {
    //     .mag_filter = .linear,
    //     .min_filter = .linear,
    //     .mipmap_mode = .linear,
    //     .address_mode_u = .repeat,
    //     .address_mode_v = .repeat,
    //     .address_mode_w = .repeat,
    //     .min_lod = -1000,
    //     .max_lod = 1000,
    //     .max_anisotropy = 1,
    //     .mip_lod_bias = 0,
    //     .enable_anisotropy = false,
    //     .enable_compare = false,
    //     .compare_op = .never,
    // };

    // const sampler = gpu.createSampler(bd.device, &sampler_info).?;
    // bd.sampler = sampler;

    // copy_pass.end();
    // cmd.submit();
}

pub fn createSampler() *sdl.gpu.Sampler {
    const bd = getBackendData().?;
    return bd.device.createSampler(&.{
        .mag_filter = .linear,
        .min_filter = .linear,
        .mipmap_mode = .linear,
        .address_mode_u = .repeat,
        .address_mode_v = .repeat,
        .address_mode_w = .repeat,
        .min_lod = -1000,
        .max_lod = 1000,
        .max_anisotropy = 1,
        .mip_lod_bias = 0,
        .enable_anisotropy = false,
        .enable_compare = false,
        .compare_op = .never,
    }).?;
}
pub fn renderDrawData(draw_data: *imgui.ImDrawData, cmd: *sdl.gpu.CommandBuffer) !void {
    const bd = getBackendData().?;

    const color_target = [1]sdl.gpu.ColorTargetInfo {.{
        .texture = gpu.activeRenderTarget(),
        .clear_color = .{ .r = 0, .g = 0, .b = 0, .a = 0},
        .load_op = .load,
        .store_op = .store,
        .cycle = false,
    }};

    const pass = cmd.beginRenderPass(&color_target, 1, null).?;
    defer pass.end();

    const fb_width = draw_data.DisplaySize.x * draw_data.FramebufferScale.x;
    const fb_height = draw_data.DisplaySize.y * draw_data.FramebufferScale.y;

    if (fb_width <= 0 or fb_height <= 0) {
        return;
    }

    if (draw_data.TotalVtxCount > 0) {
        if (bd.buf_vertex == null or bd.size_buf_vertex < draw_data.TotalVtxCount * @sizeOf(imgui.ImDrawVert)) {

            // create vertex buffer
            if (bd.buf_vertex != null) bd.device.releaseBuffer(bd.buf_vertex.?);
            const new_vtx_size: u32 = @intCast((draw_data.TotalVtxCount + 5000) * @sizeOf(imgui.ImDrawVert));

            const vtx_buf_info = sdl.gpu.BufferCreateInfo {
                .usage = .{ .vertex = true },
                .size = new_vtx_size
            };

            const buf_vertex = bd.device.createBuffer(&vtx_buf_info).?;
            bd.buf_vertex = buf_vertex;
            bd.size_buf_vertex = new_vtx_size;
        }

        if (bd.buf_index == null or bd.size_buf_index < draw_data.TotalIdxCount * @sizeOf(imgui.ImDrawIdx)) {
            // create index buffer
            if (bd.buf_index != null) bd.device.releaseBuffer(bd.buf_index.?);
            const new_idx_size: u32 = @intCast((draw_data.TotalIdxCount + 10000) * @sizeOf(imgui.ImDrawIdx));
            const idx_buf_info = sdl.gpu.BufferCreateInfo {
                .usage = .{ .index = true },
                .size = new_idx_size,
            };
            const buf_index = bd.device.createBuffer(&idx_buf_info);
            bd.buf_index = buf_index;
            bd.size_buf_index = new_idx_size;
        }

        // create transfer buffer
        const buf_transfer_desc = sdl.gpu.TransferBufferCreateInfo {
            .size = bd.size_buf_vertex + bd.size_buf_index,
            .usage = .upload
        };
        const buf_transfer = bd.device.createTransferBuffer(&buf_transfer_desc).?;
        defer bd.device.releaseTransferBuffer(buf_transfer);

        // var vtx_mapped_ptr : [*]imgui.ImDrawVert = @alignCast(@ptrCast(sdl.gpu.mapTransferBuffer(bd.device, buf_transfer, false)));
        const ptr: [*]u8 = @ptrCast(@alignCast(bd.device.mapTransferBuffer(buf_transfer, false).?));
        defer bd.device.unmapTransferBuffer(buf_transfer);
        var vtx_mapped_ptr: [*]imgui.ImDrawVert = @alignCast(@ptrCast(ptr));
        var idx_mapped_ptr: [*]imgui.ImDrawIdx = @alignCast(@ptrCast(ptr + bd.size_buf_vertex));

        const len: usize = @intCast(draw_data.CmdListsCount);
        for(0..len) |cmd_list_idx| {
            const cmd_list = draw_data.CmdLists.Data[cmd_list_idx];
            const vtx_size: usize = @intCast(cmd_list.VtxBuffer.Size);
            const idx_size: usize = @intCast(cmd_list.IdxBuffer.Size);
            for(0..vtx_size) |vtx| {
                vtx_mapped_ptr[vtx] = cmd_list.VtxBuffer.Data[vtx];
            }
            for(0..idx_size) |idx| {
                idx_mapped_ptr[idx] = cmd_list.IdxBuffer.Data[idx];
            }
            vtx_mapped_ptr += vtx_size;
            idx_mapped_ptr += idx_size;
        }

        const copy_cmd = bd.device.acquireCommandBuffer().?;
        defer _ = copy_cmd.submit();
        const cpass = copy_cmd.beginCopyPass().?;
        defer cpass.end();

        const vtx_src = sdl.gpu.TransferBufferLocation {
            .transfer_buffer = buf_transfer,
            .offset = 0,
        };

        const vtx_dst = sdl.gpu.BufferRegion {
            .buffer = bd.buf_vertex,
            .offset = 0,
            .size = bd.size_buf_vertex,
        };

        cpass.uploadToBuffer(&vtx_src, &vtx_dst, false);

        const idx_src = sdl.gpu.TransferBufferLocation {
            .transfer_buffer = buf_transfer,
            .offset = bd.size_buf_vertex,
        };

        const idx_dst = sdl.gpu.BufferRegion {
            .buffer = bd.buf_index,
            .offset = 0,
            .size = bd.size_buf_index,
        };

        cpass.uploadToBuffer(&idx_src, &idx_dst, false);
    }

    // Setup render state
    setupRenderState(cmd, pass, draw_data);

    const clip_off = draw_data.DisplayPos;
    const clip_scale = draw_data.FramebufferScale;

    var global_vtx_offset: c_uint = 0;
    var global_idx_offset: c_uint = 0;

    for(draw_data.CmdLists.Data[0..@intCast(draw_data.CmdLists.Size)]) |cmd_list| {
        for(cmd_list.CmdBuffer.Data[0..@intCast(cmd_list.CmdBuffer.Size)]) |pcmd| {
            var clip_min = imgui.Vec2 {
                .x = (pcmd.ClipRect.x - clip_off.x) * clip_scale.x,
                .y = (pcmd.ClipRect.y - clip_off.y) * clip_scale.y,
            };
            var clip_max = imgui.Vec2 {
                .x = (pcmd.ClipRect.z - clip_off.x) * clip_scale.x,
                .y = (pcmd.ClipRect.w - clip_off.y) * clip_scale.y,
            };

            clip_min.x = @max(clip_min.x, 0);
            clip_min.y = @max(clip_min.y, 0);
            clip_max.x = @min(clip_max.x, fb_width);
            clip_max.y = @min(clip_max.y, fb_height);
            if (clip_max.x <= clip_min.x or clip_max.y <= clip_min.y) continue;

            const scissor = sdl.gpu.Rect {
                .x = @intFromFloat(clip_min.x),
                .y = @intFromFloat(clip_min.y),
                .w = @intFromFloat(clip_max.x - clip_min.x),
                .h = @intFromFloat(clip_max.y - clip_min.y),
            };
            pass.setScissor(&scissor);
            const binding = [_]sdl.gpu.TextureSamplerBinding {.{
                .sampler = bd.sampler,
                .texture = bd.font_texture,
            }};
            pass.bindFragmentSamplers(0, &binding, 1);
            pass.drawIndexedPrimitives(
                pcmd.ElemCount,
                1,
                @intCast(pcmd.IdxOffset + global_idx_offset),
                @intCast(pcmd.VtxOffset + global_vtx_offset),
                0);
        }
        global_vtx_offset += if (cmd_list.*.VtxBuffer.Size > 0) @intCast(cmd_list.*.VtxBuffer.Size) else unreachable;
        global_idx_offset += if (cmd_list.*.IdxBuffer.Size > 0) @intCast(cmd_list.*.IdxBuffer.Size) else unreachable;
    }

    const scissor = sdl.gpu.Rect {
        .x = 0,
        .y = 0,
        .w = @intFromFloat(fb_width),
        .h = @intFromFloat(fb_height),
    };
    pass.setScissor(&scissor);
}

pub fn setupRenderState(cmd: *sdl.gpu.CommandBuffer, render_pass: *sdl.gpu.RenderPass, draw_data: *imgui.ImDrawData) void {
    const bd = getBackendData().?;
    const fb_width = draw_data.DisplaySize.x * draw_data.FramebufferScale.x;
    const fb_height = draw_data.DisplaySize.y * draw_data.FramebufferScale.y;

    render_pass.bindGraphicsPipeline(bd.*.pipeline);
    if (draw_data.*.TotalVtxCount > 0) {
        const vertex_buffers = [1]sdl.gpu.BufferBinding {.{ 
            .buffer = bd.*.buf_vertex,
            .offset = 0
        }};
        const index_buffers = [1]sdl.gpu.BufferBinding {.{ 
            .buffer = bd.*.buf_index,
            .offset = 0,
        }};
        render_pass.bindVertexBuffers(0, &vertex_buffers, 1);
        render_pass.bindIndexBuffer(&index_buffers, if (@sizeOf(imgui.ImDrawIdx) == 2) .@"16bit" else .@"32bit");
        render_pass.bindFragmentSamplers(0, &[_]sdl.gpu.TextureSamplerBinding{.{ .sampler = bd.sampler, .texture = bd.font_texture }}, 1);

        // Setup viewport
        const l = draw_data.DisplayPos.x;
        const r = draw_data.DisplayPos.x + draw_data.DisplaySize.x;
        const t = draw_data.DisplayPos.y;
        const b = draw_data.DisplayPos.y + draw_data.DisplaySize.y;
        const proj = [4][4]f32 {
            .{     2/(r-l),           0,  0,  0 },
            .{           0,     2/(t-b),  0,  0 },
            .{           0,           0, -1,  0 },
            .{ (r+l)/(l-r), (t+b)/(b-t),  0,  1 },
        };

        const viewport= sdl.gpu.Viewport {
            .x = 0,
            .y = 0,
            .w = fb_width,
            .h = fb_height,
            .min_depth = 0,
            .max_depth = 1,
        };
        render_pass.setViewport(&viewport);

        cmd.pushVertexUniformData(0, &proj, @sizeOf(f32) * 16);
    }
}

fn loadShader(device: *sdl.gpu.Device, shader_type: ShaderType) !*sdl.gpu.Shader {
    const format: sdl.gpu.ShaderFormat = sdl.gpu.getShaderFormats(device);

    var create_info: sdl.gpu.ShaderCreateInfo = undefined;
    if (format.dxbc) {
        unreachable;
    } else if (format.dxil) {
        unreachable;
    } else if (format.metallib) {
        unreachable; //TODO: - add metal support
    } else {
        if (shader_type == .fragment) {
            create_info = shader_code.getFragmentCreateInfo();
        }
        else {
            create_info = shader_code.getVertexCreateInfo();
        }
    }

    return sdl.gpu.createShader(device, &create_info) orelse {
        std.log.debug("Failed to load shader: {s}", .{sdl.getError()});
        return error.LoadShaderFailed;
    };
}
