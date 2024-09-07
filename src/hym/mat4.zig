/// zig version of cglm functions.
const std = @import("std");
const math = std.math;
const vec3 = @import("vec3.zig");

const root = @This();

pub const Mat4 = struct {
    m: [4]@Vector(4, f32),

    pub inline fn mul(self: *Mat4, b: Mat4) void {
        self.m = root.mul(b, self.*).m;
    }

    pub inline fn translate(self: *Mat4, v: vec3.Vec3) void {
        self.m[3] += .{ v.v[0], v.v[1], v.v[2], 0 }; 
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
    try expectVecApproxEqAbs(.{ 1, 5, 9, 13}, mt.m[0], 0.01);
    try expectVecApproxEqAbs(.{ 2, 6, 10, 14}, mt.m[0], 0.01);
    try expectVecApproxEqAbs(.{ 3, 7, 11, 15}, mt.m[0], 0.01);
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

pub fn veclen(v: anytype) !u32 {
    return @typeInfo(@TypeOf(v)).len;
}

pub fn expectVecApproxEqAbs(expected: anytype, actual: anytype, eps: f32) !void {
    const T = @TypeOf(expected, actual);
    inline for (0..veclen(T)) |i| {
        try std.testing.expectApproxEqAbs(expected[i], actual[i], eps);
    }
}
