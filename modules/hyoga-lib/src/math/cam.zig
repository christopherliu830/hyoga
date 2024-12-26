const std = @import("std");

const vec3 = @import("vec3.zig");
const mat4 = @import("mat4.zig");

const math = std.math;

pub inline fn perspectiveMatrix(fovy: f32, aspect: f32, z_near: f32, z_far: f32) mat4.Mat4 {
    var m: mat4.Mat4 = mat4.zero;

    const f = 1 / @tan(fovy * 0.5);
    const f_n = 1 / (z_near - z_far);

    m.m[0][0] = f / aspect;
    m.m[1][1] = f;
    m.m[2][2] = (z_far) * f_n;
    m.m[2][3] = -1;
    m.m[3][2] = z_near * z_far * f_n;

    return m;
}

pub fn orthographicRh(w: f32, h: f32, near: f32, far: f32) mat4.Mat4 {
    const r = 1 / (near - far);
    return .{ .m = .{
        .{ 2 / w, 0.0, 0.0, 0.0 },
        .{ 0.0, 2 / h, 0.0, 0.0 },
        .{ 0.0, 0.0, r, 0.0 },
        .{ 0.0, 0.0, r * near, 1.0 },
    } };
}

// create view matrix with right handed coordinate system
// (row-major layout)
pub inline fn lookTo(eye: vec3.Vec3, dir: vec3.Vec3, up: vec3.Vec3) mat4.Mat4 {
    var m = mat4.zero;

    const f = dir.normal();
    const s = vec3.cross(f, up).normal();
    const u = vec3.cross(s, f);
    const fv = f.v;
    const sv = s.v;
    const uv = u.v;

    m.m[0] = .{ sv[0], uv[0], -fv[0], 0 };
    m.m[1] = .{ sv[1], uv[1], -fv[1], 0 };
    m.m[2] = .{ sv[2], uv[2], -fv[2], 0 };
    m.m[3] = .{ -vec3.dot(s, eye), -vec3.dot(u, eye), vec3.dot(f, eye), 1 };

    return m;
}
