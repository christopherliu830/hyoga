/// zig version of cglm functions.
const std = @import("std");
const math = std.math;
const vec3 = @import("vec3.zig");
const vec4 = @import("vec4.zig");

const root = @This();

pub const Mat4 = struct {
    m: [4]@Vector(4, f32),

    pub inline fn mul(self: *Mat4, b: Mat4) void {
        self.m = root.mul(self.*, b).m;
    }

    pub inline fn translate(self: *Mat4, v: vec3.Vec3) void {
        self.m[3] += .{ v.v[0], v.v[1], v.v[2], 0 }; 
    }

    pub inline fn scale(self: *Mat4, b: f32) void {
        self.* = root.scale(self.*, b);
    }

    pub inline fn inverse(self: *Mat4) void {
        self.* = root.inverse(self);
    }

    /// Spin around matrix's center point, i.e. a translation-independent 
    /// rotation.
    pub inline fn spin(self: *Mat4, deg: f32, axis: vec3.Vec3) void {
        const t = vec3.create(self.m[3][0], self.m[3][1], self.m[3][2]);
        self.translate(vec3.mul(t, -1));
        self.mul(rotation(deg, axis));
        self.translate(t);
    }
};

pub const zero =  Mat4 { .m = .{
    .{ 0, 0, 0, 0 },
    .{ 0, 0, 0, 0 },
    .{ 0, 0, 0, 0 },
    .{ 0, 0, 0, 0 },
}};

pub const identity = Mat4 { .m = .{
    .{ 1, 0, 0, 0 },
    .{ 0, 1, 0, 0 },
    .{ 0, 0, 1, 0 },
    .{ 0, 0, 0, 1 },
}};

pub inline fn transpose(m: Mat4) Mat4 {

    //  0  1  8  9
    //  4  5 12 13
    //  2  3 10 11
    //  6  7 14 15

    const a = @shuffle(f32, m.m[0], m.m[2], [4]i32{ 0, 1, ~@as(i32, 0), ~@as(i32, 1)});
    const b = @shuffle(f32, m.m[1], m.m[3], [4]i32{ 0, 1, ~@as(i32, 0), ~@as(i32, 1)});
    const c = @shuffle(f32, m.m[0], m.m[2], [4]i32{ 2, 3, ~@as(i32, 2), ~@as(i32, 3)});
    const d = @shuffle(f32, m.m[1], m.m[3], [4]i32{ 2, 3, ~@as(i32, 2), ~@as(i32, 3)});

    //  0  4  8 12
    //  1  5  9 13
    //  2  6 10 14
    //  3  7 11 15

    return .{ .m = .{
        @shuffle(f32, a, b, [4]i32{ 0, ~@as(i32, 0), 2, ~@as(i32, 2) }),
        @shuffle(f32, a, b, [4]i32{ 1, ~@as(i32, 1), 3, ~@as(i32, 3) }),
        @shuffle(f32, c, d, [4]i32{ 0, ~@as(i32, 0), 2, ~@as(i32, 2) }),
        @shuffle(f32, c, d, [4]i32{ 1, ~@as(i32, 1), 3, ~@as(i32, 3) }),
    }};
}

test "hym.mat4.transpose()" {
    const m = Mat4 { .m = .{
        .{  0,  1,  2,  3 },
        .{  4,  5,  6,  7 },
        .{  8,  9, 10, 11 },
        .{ 12, 13, 14, 15 },
    }};
    const mt = transpose(m);
    try expectVecApproxEqAbs(.{ 0, 4, 8, 12}, mt.m[0], 0.01);
    try expectVecApproxEqAbs(.{ 1, 5, 9, 13}, mt.m[1], 0.01);
    try expectVecApproxEqAbs(.{ 2, 6, 10, 14}, mt.m[2], 0.01);
    try expectVecApproxEqAbs(.{ 3, 7, 11, 15}, mt.m[3], 0.01);
}

pub inline fn inverse(mat: Mat4) Mat4 {
    var dest: Mat4 = identity;
    var det: f32 = 0;
    var t: [6]f32 = [_]f32 {0} ** 6;

    const a = mat.m[0][0]; const b = mat.m[0][1]; const c = mat.m[0][2]; const d = mat.m[0][3];
    const e = mat.m[1][0]; const f = mat.m[1][1]; const g = mat.m[1][2]; const h = mat.m[1][3];
    const i = mat.m[2][0]; const j = mat.m[2][1]; const k = mat.m[2][2]; const l = mat.m[2][3];
    const m = mat.m[3][0]; const n = mat.m[3][1]; const o = mat.m[3][2]; const p = mat.m[3][3];

    t[0] = k * p - o * l; t[1] = j * p - n * l; t[2] = j * o - n * k;
    t[3] = i * p - m * l; t[4] = i * o - m * k; t[5] = i * n - m * j;

    dest.m[0][0] =  f * t[0] - g * t[1] + h * t[2];
    dest.m[1][0] =-(e * t[0] - g * t[3] + h * t[4]);
    dest.m[2][0] =  e * t[1] - f * t[3] + h * t[5];
    dest.m[3][0] =-(e * t[2] - f * t[4] + g * t[5]);

    dest.m[0][1] =-(b * t[0] - c * t[1] + d * t[2]);
    dest.m[1][1] =  a * t[0] - c * t[3] + d * t[4];
    dest.m[2][1] =-(a * t[1] - b * t[3] + d * t[5]);
    dest.m[3][1] =  a * t[2] - b * t[4] + c * t[5];

    t[0] = g * p - o * h; t[1] = f * p - n * h; t[2] = f * o - n * g;
    t[3] = e * p - m * h; t[4] = e * o - m * g; t[5] = e * n - m * f;

    dest.m[0][2] =  b * t[0] - c * t[1] + d * t[2];
    dest.m[1][2] =-(a * t[0] - c * t[3] + d * t[4]);
    dest.m[2][2] =  a * t[1] - b * t[3] + d * t[5];
    dest.m[3][2] =-(a * t[2] - b * t[4] + c * t[5]);

    t[0] = g * l - k * h; t[1] = f * l - j * h; t[2] = f * k - j * g;
    t[3] = e * l - i * h; t[4] = e * k - i * g; t[5] = e * j - i * f;

    dest.m[0][3] =-(b * t[0] - c * t[1] + d * t[2]);
    dest.m[1][3] =  a * t[0] - c * t[3] + d * t[4];
    dest.m[2][3] =-(a * t[1] - b * t[3] + d * t[5]);
    dest.m[3][3] =  a * t[2] - b * t[4] + c * t[5];

    det = 1.0 / (a * dest.m[0][0] + b * dest.m[1][0]
                + c * dest.m[2][0] + d * dest.m[3][0]);

    dest.scale(det);
    return dest;
}

test "hym.mat4.inverse()" {
    const m = Mat4 { .m = .{
        .{ 1, 4, 2, 3 },
        .{ 0, 1, 4, 4 },
        .{ -1, 0, 1, 0 },
        .{ 2, 0, 4, 1 },
    }};

    const mt = inverse(m);

    try expectVecApproxEqAbs(.{  1.0/65.0,  -4.0/65.0, -38.0/65.0,  13.0/65.0 }, mt.m[0], 0.01);
    try expectVecApproxEqAbs(.{ 20.0/65.0, -15.0/65.0,  20.0/65.0,          0 }, mt.m[1], 0.01);
    try expectVecApproxEqAbs(.{  1.0/65.0,  -4.0/65.0,  27.0/65.0,  13.0/65.0 }, mt.m[2], 0.01);
    try expectVecApproxEqAbs(.{ -6.0/65.0,  24.0/65.0, -32.0/65.0, -13.0/65.0 }, mt.m[3], 0.01);
}

pub inline fn scale(a: Mat4, b: f32) Mat4 {
    return Mat4 { .m = .{
        vec4.mul(.{ .v = a.m[0] }, b).v,
        vec4.mul(.{ .v = a.m[1] }, b).v,
        vec4.mul(.{ .v = a.m[2] }, b).v,
        vec4.mul(.{ .v = a.m[3] }, b).v,
    }};
}

/// zig-gamedev/zmath
pub inline fn mul(a: Mat4, b: Mat4) Mat4 {
    var result: Mat4 = zero;
    comptime var row: u32 = 0;

    inline while (row < 4) : (row += 1) {
        var vx = @shuffle(f32, a.m[row], undefined, [4]i32{ 0, 0, 0, 0 });
        var vy = @shuffle(f32, a.m[row], undefined, [4]i32{ 1, 1, 1, 1 });
        var vz = @shuffle(f32, a.m[row], undefined, [4]i32{ 2, 2, 2, 2 });
        var vw = @shuffle(f32, a.m[row], undefined, [4]i32{ 3, 3, 3, 3 });

        vx = vx * b.m[0];
        vy = vy * b.m[1];
        vz = vz * b.m[2];
        vw = vw * b.m[3];
        vx = vx + vz;
        vy = vy + vw;
        vx = vx + vy;

        result.m[row] = vx;
    }

    return result;
}

pub inline fn rotation(deg: f32, axis: vec3.Vec3) Mat4 {
    var m: Mat4 = zero;
    const c = @cos(std.math.radiansToDegrees(deg));
    const axisn = axis.normal();

    const v = vec3.mul(axisn, 1 - c);
    const vs = vec3.mul(axisn, @sin(std.math.radiansToDegrees(deg)));

    m.m[0] = vec3.append(vec3.mul(axisn, v.v[0]), 0).v;
    m.m[1] = vec3.append(vec3.mul(axisn, v.v[1]), 0).v;
    m.m[2] = vec3.append(vec3.mul(axisn, v.v[2]), 0).v;

    m.m[0][0] += c;         m.m[1][0] -= vs.v[2];   m.m[2][0] += vs.v[1];
    m.m[0][1] += vs.v[2];   m.m[1][1] += c;         m.m[2][1] -= vs.v[0];
    m.m[0][2] -= vs.v[1];   m.m[1][2] += vs.v[0];   m.m[2][2] += c;

    // m.m[0][3] = m.m[1][3] = m.m[2][3] = m.m[3][0] = m.m[3][1] = m.m[3][2] = 0.0f;
    m.m[3][3] = 1;

    return m;
}

pub fn expectVecApproxEqAbs(comptime expected: anytype, actual: anytype, eps: f32) !void {
    inline for (0..expected.len) |i| {
        try std.testing.expectApproxEqAbs(expected[i], actual[i], eps);
    }
}
