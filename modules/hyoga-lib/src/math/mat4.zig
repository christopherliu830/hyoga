/// zig version of cglm functions.
const std = @import("std");
const math = std.math;
const vec3 = @import("vec3.zig");
const vec4 = @import("vec4.zig");
const Vec4 = vec4.Vec4;
const f32x4 = @Vector(4, f32);
const i32x4 = @Vector(4, i32);

const root = @This();

pub const Mat4 = extern struct {
    m: [4]f32x4,
};

pub const zero = Mat4{ .m = .{
    .{ 0, 0, 0, 0 },
    .{ 0, 0, 0, 0 },
    .{ 0, 0, 0, 0 },
    .{ 0, 0, 0, 0 },
} };

pub const identity = Mat4{ .m = .{
    .{ 1, 0, 0, 0 },
    .{ 0, 1, 0, 0 },
    .{ 0, 0, 1, 0 },
    .{ 0, 0, 0, 1 },
} };

pub inline fn transpose(m: Mat4) Mat4 {

    //  0  1  8  9
    //  4  5 12 13
    //  2  3 10 11
    //  6  7 14 15

    const a = @shuffle(f32, m.m[0], m.m[2], [4]i32{ 0, 1, n(0), n(1) });
    const b = @shuffle(f32, m.m[1], m.m[3], [4]i32{ 0, 1, n(0), n(1) });
    const c = @shuffle(f32, m.m[0], m.m[2], [4]i32{ 2, 3, n(2), n(3) });
    const d = @shuffle(f32, m.m[1], m.m[3], [4]i32{ 2, 3, n(2), n(3) });

    //  0  4  8 12
    //  1  5  9 13
    //  2  6 10 14
    //  3  7 11 15

    return .{ .m = .{
        @shuffle(f32, a, b, [4]i32{ 0, n(0), 2, n(2) }),
        @shuffle(f32, a, b, [4]i32{ 1, n(1), 3, n(3) }),
        @shuffle(f32, c, d, [4]i32{ 0, n(0), 2, n(2) }),
        @shuffle(f32, c, d, [4]i32{ 1, n(1), 3, n(3) }),
    } };
}

test "hym.mat4.transpose()" {
    const m = Mat4{ .m = .{
        .{ 0, 1, 2, 3 },
        .{ 4, 5, 6, 7 },
        .{ 8, 9, 10, 11 },
        .{ 12, 13, 14, 15 },
    } };
    const mt = transpose(m);
    try expectVecApproxEqAbs(.{ 0, 4, 8, 12 }, mt.m[0], 0.01);
    try expectVecApproxEqAbs(.{ 1, 5, 9, 13 }, mt.m[1], 0.01);
    try expectVecApproxEqAbs(.{ 2, 6, 10, 14 }, mt.m[2], 0.01);
    try expectVecApproxEqAbs(.{ 3, 7, 11, 15 }, mt.m[3], 0.01);
}

/// https://lxjk.github.io/2017/09/03/Fast-4x4-Matrix-Inverse-with-SSE-SIMD-Explained.html
/// General matrix inverse function
pub inline fn inverse(mat: Mat4) Mat4 {
    const m = mat.m;
    const a = @shuffle(f32, m[0], m[1], i32x4{0, 1, n(0), n(1)});
    const b = @shuffle(f32, m[0], m[1], i32x4{2, 3, n(2), n(3)});
    const c = @shuffle(f32, m[2], m[3], i32x4{0, 1, n(0), n(1)});
    const d = @shuffle(f32, m[2], m[3], i32x4{2, 3, n(2), n(3)});

    // determinant as (|A| |B| |C| |D|)
    const det_sub = @shuffle(f32, m[0], m[2], i32x4{0, 2, n(0), n(2)}) * @shuffle(f32, m[1], m[3], i32x4{1, 3, n(1), n(3)}) -
                    @shuffle(f32, m[0], m[2], i32x4{1, 3, n(1), n(3)}) * @shuffle(f32, m[1], m[3], i32x4{0, 2, n(0), n(2)});

    const det_a: f32x4 = @splat(det_sub[0]);
    const det_b: f32x4 = @splat(det_sub[1]);
    const det_c: f32x4 = @splat(det_sub[2]);
    const det_d: f32x4 = @splat(det_sub[3]);
    const d_c = mat2AdjMul(d, c); // D#C
    const a_b = mat2AdjMul(a, b); // A#B
    var x_ = det_d * a - mat2Mul(b, d_c);
    var w_ = det_a * d - mat2Mul(c, a_b);
    var y_ = det_b * c - mat2MulAdj(d, a_b);
    var z_ = det_c * b - mat2MulAdj(a, d_c);

    const tr: f32x4 = @splat(@reduce(.Add, a_b * swizzle(d_c, .{0, 2, 1, 3})));

    const det_m = det_a * det_d + det_b * det_c - tr;

    const adj_sign_mask: f32x4 = .{ 1, -1, -1, 1};
    const r_det_m = adj_sign_mask / det_m;

    x_ *= r_det_m; 
    y_ *= r_det_m; 
    z_ *= r_det_m; 
    w_ *= r_det_m; 

    return .{ .m = .{
        @shuffle(f32, x_, y_, i32x4{3, 1, n(3), n(1)}),
        @shuffle(f32, x_, y_, i32x4{2, 0, n(2), n(0)}),
        @shuffle(f32, z_, w_, i32x4{3, 1, n(3), n(1)}),
        @shuffle(f32, z_, w_, i32x4{2, 0, n(2), n(0)}),
    }};
}

test "hym.mat4.inverse()" {
    const m = Mat4{ .m = .{
        .{ 1, 4, 2, 3 },
        .{ 0, 1, 4, 4 },
        .{ -1, 0, 1, 0 },
        .{ 2, 0, 4, 1 },
    } };

    const mt = inverse(m);

    try expectVecApproxEqAbs(.{ 1.0 / 65.0, -4.0 / 65.0, -38.0 / 65.0, 13.0 / 65.0 }, mt.m[0], 0.01);
    try expectVecApproxEqAbs(.{ 20.0 / 65.0, -15.0 / 65.0, 20.0 / 65.0, 0 }, mt.m[1], 0.01);
    try expectVecApproxEqAbs(.{ 1.0 / 65.0, -4.0 / 65.0, 27.0 / 65.0, 13.0 / 65.0 }, mt.m[2], 0.01);
    try expectVecApproxEqAbs(.{ -6.0 / 65.0, 24.0 / 65.0, -32.0 / 65.0, -13.0 / 65.0 }, mt.m[3], 0.01);
}


/// https://lxjk.github.io/2017/09/03/Fast-4x4-Matrix-Inverse-with-SSE-SIMD-Explained.html
/// invert a transform matrix.
pub inline fn inverseTransform(mat: Mat4) Mat4 {
    var r: [4]f32x4 = undefined;
    const m = mat.m;

    // Matrix form
    // 00 01 02 03
    // 10 11 12 13
    // 20 21 22 23
    // 30 31 32 33

    // Transpose 3x3, we know m03 = m13 = m23 = 0
    const t0 = @select(f32, [4]bool{ true, true, false, false, }, m[0], m[1]); // 00 01 10 11
    const t1 = @select(f32, [4]bool{ false, false, true, true }, m[0], m[1]);  // 02 03 12 13
    r[0] = @shuffle(f32, t0, m[2], [4]i32{ 0, 2, n(0), n(3) }); // 00 10 20 23(=0)
    r[1] = @shuffle(f32, t0, m[2], [4]i32{ 1, 3, n(1), n(3) }); // 01 11 21 23(=0)
    r[2] = @shuffle(f32, t1, m[2], [4]i32{ 1, 3, n(1), n(3) }); // 02 12 22 23(=0)

    var size_sq =                      r[0] * r[0];
    size_sq = @mulAdd(f32x4, r[1],  r[1], size_sq);
    size_sq = @mulAdd(f32x4, r[2],  r[2], size_sq);

    // optional test to avoid divide by zero:
    // for each component, if sizeSqr < SMALL_NUMBER sizeSqr = 1;
    var r_size_sq = size_sq;
    inline for(0..4) |i| {
        r_size_sq[i] = if (size_sq[i] < std.math.floatEps(f32)) 1 else 1/size_sq[i];
    }

    r[0] *= r_size_sq;
    r[1] *= r_size_sq;
    r[2] *= r_size_sq;

    // r[3] = dot (c, m[3] aka T ) for columns in r
    r[3] =                          r[0] * @as(f32x4, @splat(m[3][0]));
    r[3] = @mulAdd(f32x4, r[1],  @as(f32x4, @splat(m[3][1])), r[3]);
    r[3] = @mulAdd(f32x4, r[2],  @as(f32x4, @splat(m[3][2])), r[3]);
    r[3] *= @splat(-1);
    r[3][3] = 1;

    return .{ .m = r };
}

/// zig-gamedev/zmath
pub inline fn mul(a: Mat4, b: Mat4) Mat4 {
    var result: Mat4 = undefined;
    comptime var row: u32 = 0;
    inline while (row < 4) : (row += 1) {
        const vx = swizzle(a.m[row], .{ 0, 0, 0, 0 });
        const vy = swizzle(a.m[row], .{ 1, 1, 1, 1 });
        const vz = swizzle(a.m[row], .{ 2, 2, 2, 2 });
        const vw = swizzle(a.m[row], .{ 3, 3, 3, 3 });
        result.m[row] = @mulAdd(@Vector(4, f32), vx, b.m[0], vz * b.m[2]) + @mulAdd(@Vector(4, f32), vy, b.m[1], vw * b.m[3]);
    }
    return result;
}

/// Scale each row of matrix A by a constant factor b.
pub inline fn mulf(a: Mat4, b: f32) Mat4 {
    return Mat4{ .m = .{
        vec4.mul(.{ .v = a.m[0] }, b).v,
        vec4.mul(.{ .v = a.m[1] }, b).v,
        vec4.mul(.{ .v = a.m[2] }, b).v,
        vec4.mul(.{ .v = a.m[3] }, b).v,
    } };
}

pub inline fn vmul(m: Mat4, v: Vec4) Vec4 {
    const vx = swizzle(v.v, .{0, 0, 0, 0});
    const vy = swizzle(v.v, .{1, 1, 1, 1});
    const vz = swizzle(v.v, .{2, 2, 2, 2});
    const vw = swizzle(v.v, .{3, 3, 3, 3});
    return .{ .v = vx * m.m[0] + vy * m.m[1] + vz * m.m[2] + vw * m.m[3] };
}

pub inline fn mulv(m: Mat4, v: Vec4) Vec4 {
    return .{ .v = .{
        vec4.dot(.{ .v = m.m[0] }, v),
        vec4.dot(.{ .v = m.m[1] }, v),
        vec4.dot(.{ .v = m.m[2] }, v),
        vec4.dot(.{ .v = m.m[3] }, v),
    }};
}

test "multiply two matrices" {
    const a = Mat4{ .m = .{
        .{ 1, 4, 2, 3 },
        .{ 0, 1, 4, 4 },
        .{ -1, 0, 1, 0 },
        .{ 2, 0, 4, 1 },
    } };

    const b = Mat4{ .m = .{
        .{ 2, 7, 2, 3 },
        .{ 1, 1, 4, 2 },
        .{ -1, 8, 1, 1 },
        .{ 2, 0, 2, 1 },
    } };

    const c = mul(a, b);

    try expectVecApproxEqAbs(.{ 10, 27, 26, 16 }, c.m[0], 0.01);
    try expectVecApproxEqAbs(.{  5, 33, 16, 10 }, c.m[1], 0.01);
    try expectVecApproxEqAbs(.{ -3,  1, -1, -2 }, c.m[2], 0.01);
    try expectVecApproxEqAbs(.{ 2, 8, 10, 7 }, c.m[3], 0.01);
}

pub inline fn translation(m: Mat4, v: vec3.Vec3) Mat4 {
    return .{ .m = .{ m.m[0], m.m[1], m.m[2], m.m[3] + vec3.append(v, 0).v } };
}

pub inline fn rotation(deg: f32, axis: vec3.Vec3) Mat4 {
    var m: Mat4 = zero;
    const c = @cos(std.math.degreesToRadians(deg));
    const axisn = axis.normal();

    const v = vec3.mul(axisn, 1 - c);
    const vs = vec3.mul(axisn, @sin(std.math.radiansToDegrees(deg)));

    m.m[0] = vec3.append(vec3.mul(axisn, v.v[0]), 0).v;
    m.m[1] = vec3.append(vec3.mul(axisn, v.v[1]), 0).v;
    m.m[2] = vec3.append(vec3.mul(axisn, v.v[2]), 0).v;

    m.m[0][0] += c;
    m.m[1][0] -= vs.v[2];
    m.m[2][0] += vs.v[1];
    m.m[0][1] += vs.v[2];
    m.m[1][1] += c;
    m.m[2][1] -= vs.v[0];
    m.m[0][2] -= vs.v[1];
    m.m[1][2] += vs.v[0];
    m.m[2][2] += c;

    m.m[3][3] = 1;

    return m;
}

/// Scale
pub inline fn scale(v: vec3.Vec3) Mat4 {
    return .{ .m = .{
        .{ v.v[0], 0, 0, 0 },
        .{ 0, v.v[1], 0, 0 },
        .{ 0, 0, v.v[2], 0 },
        .{ 0, 0, 0, 1 },
    } };
}

/// Spin around matrix's center point, i.e. a translation-independent
/// rotation.
pub inline fn spin(self: *Mat4, deg: f32, axis: vec3.Vec3) void {
    const t = vec3.create(self.m[3][0], self.m[3][1], self.m[3][2]);
    self.translate(vec3.mul(t, -1));
    self.mul(rotation(deg, axis));
    self.translate(t);
}

pub fn expectVecApproxEqAbs(comptime expected: anytype, actual: anytype, eps: f32) !void {
    inline for (0..expected.len) |i| {
        try std.testing.expectApproxEqAbs(expected[i], actual[i], eps);
    }
}

inline fn swizzle(v: f32x4, mask: [4]i32) f32x4 {
    return @shuffle(f32, v, undefined, mask);
}


/// 2x2 row major matrix fns
/// A*B
/// | a0 a1 | * | b0 b1 | = | a0b0 + a1b2, a0b1 + a1b3 |
/// | a2 a3 |   | b2 b3 |   | a2b0 + a3b2, a2b1 + a3b3 |
inline fn mat2Mul(a: f32x4, b: f32x4) f32x4 {
    return (                        a * swizzle(b, .{0, 3, 0, 3})) +
           (swizzle(a, .{1, 0, 3, 2}) * swizzle(b, .{2, 1, 2, 1}));
}

/// 2x2 row major matrix fns
/// adj(A)*B
/// |  a3 -a1 | * | b0 b1 | = | a3b0 - a1b2, a3b1 - a1b3 |
/// | -a2  a0 |   | b2 b3 |   | a0b2 - a2b0, a0b3 - a2b1 |
inline fn mat2AdjMul(a: f32x4, b: f32x4) f32x4 {
    return (swizzle(a, .{3, 3, 0, 0}) * b                        ) -
           (swizzle(a, .{1, 1, 2, 2}) * swizzle(b, .{2, 3, 0, 1}));
}

/// 2x2 row major matrix fns
/// adj(A)*B
/// | a0 a1 | * |  b3 -b1 | = | a0b3 - a1b2, a1b0 - a0b1 |
/// | a2 a3 |   | -b2  b0 |   | a2b3 - a3b2, a3b0 - a2b1 |
inline fn mat2MulAdj(a: f32x4, b: f32x4) f32x4 {
    return (a                         * swizzle(b, .{3, 0, 3, 0})) -
           (swizzle(a, .{1, 0, 3, 2}) * swizzle(b, .{2, 1, 2, 1}));
}

inline fn n(x: i32) i32 {
    return ~x;
}



