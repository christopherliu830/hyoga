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
