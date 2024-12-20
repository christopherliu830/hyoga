const std = @import("std");
const sdl = @import("sdl");
const hym = @import("hyoga-math");
const gpu = @import("gpu.zig");
const Mat4 = hym.Mat4;
const Vec3 = hym.Vec3;

pub const Scene = extern struct {
    // Global data, changes rarely
    viewport_size_x: u16,
    viewport_size_y: u16,

    // Global data, changes every frame
    view_proj: Mat4,
    light_dir: Vec3,
    renderables: [*]const Mat4 // Object model matrix
};

pub const SceneBuffer = struct {
    buffer: gpu.Buffer,
    scene: Scene,
};
