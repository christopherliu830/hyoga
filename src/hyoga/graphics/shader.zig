const std = @import("std");
const sdl = @import("sdl");
const hym = @import("hyoga-math");
const gpu = @import("gpu.zig");

const Buffer = @import("buffer.zig").VertexIndexBuffer;
const Mat4 = hym.Mat4;
const Vec3 = hym.Vec3;

/// This struct is sent to shaders as a uniform
/// buffer and fields must be kept in sync.
pub const GpuScene = extern struct {
    view_proj: Mat4,
    camera_world_pos: Vec3,
    viewport_size_x: u16,
    viewport_size_y: u16,
    light_dir: Vec3,
};

