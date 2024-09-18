const vec3 = @import("vec3.zig");
const mat4 = @import("mat4.zig");

pub inline fn perspectiveMatrix(fovy: f32, aspect: f32, z_near: f32, z_far: f32) mat4.Mat4 {
    var m: mat4.Mat4 = mat4.zero;

    const f  = 1 / @tan(fovy * 0.5);
    const f_n = 1 / (z_near - z_far);

    m.m[0][0] = f / aspect;
    m.m[1][1] = f;
    m.m[2][2] = (z_near + z_far) * f_n;
    m.m[2][3] = -1;
    m.m[3][2] = 2 * z_near * z_far * f_n;

    return m;
}

// create view matrix with right handed coordinate system
pub inline fn lookAt(eye: vec3.Vec3, center: vec3.Vec3, up: vec3.Vec3) mat4.Mat4 {
    var m = mat4.zero;
    const f = vec3.sub(center, eye).normal();
    const s = vec3.cross(f, up).normal();
    const u = vec3.cross(s, f);
    const fv = f.v;
    const sv = s.v;
    const uv = u.v;

    m.m[0][0] = sv[0];
    m.m[0][1] = uv[0];

    m.m[0] = .{  sv[0], uv[0], -fv[0], 0 };
    m.m[1] = .{  sv[1], uv[1], -fv[1], 0 };
    m.m[2] = .{  sv[2], uv[2], -fv[2], 0 };
    m.m[3][0] = -vec3.dot(s, eye);
    m.m[3][1] = -vec3.dot(u, eye);
    m.m[3][2] = vec3.dot(f, eye);
    m.m[3][3] = 1;
    return m;
}
