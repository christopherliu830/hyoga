const std = @import("std");

pub const bounds = @import("bounds.zig");
pub const cam = @import("cam.zig");
pub const mat4 = @import("mat4.zig");
pub const ray = @import("ray.zig");
pub const vec2 = @import("vec2.zig");
pub const vec3 = @import("vec3.zig");
pub const f32x3 = @Vector(3, f32);
pub const vec4 = @import("vec4.zig");
pub const AxisAligned = bounds.AxisAligned;
pub const Mat4 = mat4.Mat4;
pub const Ray = ray.Ray;
pub const Vec2 = vec2.Vec2;
pub const Vec3 = vec3.Vec3;
pub const Vec4 = vec4.Vec4;

pub fn VectorType(comptime v: type) type {
    const len = @typeInfo(v).@"struct".fields.len;
    return switch (len) {
        2 => Vec2,
        3 => Vec3,
        4 => Vec4,
        else => comptime unreachable,
    };
}

pub fn vec(v: anytype) VectorType(@TypeOf(v)) {
    const len = @typeInfo(@TypeOf(v)).@"struct".fields.len;
    return switch (len) {
        2 => vec2.create(v[0], v[1]),
        3 => vec3.create(v[0], v[1], v[2]),
        4 => vec4.create(v[0], v[1], v[2], v[3]),
        else => comptime unreachable,
    };
}

fn MulResult(comptime a: type, comptime b: type) type {
    if (a == Mat4 and b == Mat4) return Mat4;
    if ((a == f32 and b == Mat4) or (a == Mat4 and b == f32)) return Mat4;
    if (a == Vec4 and b == Mat4 or a == Mat4 and b == Vec4) return Vec4;

    @compileError("mul not supported with types" ++ @typeName(a) ++ @typeName(b));
}

pub fn mul(a: anytype, b: anytype) MulResult(@TypeOf(a), @TypeOf(b)) {
    const ta = @TypeOf(a);
    const tb = @TypeOf(b);
    if (ta == Mat4 and tb == Mat4) return mat4.mul(a, b);
    if (ta == f32 and tb == Mat4) {
        return mat4.allScale(b, a);
    }
    if (ta == Mat4 and tb == f32) {
        return mat4.allScale(a, b);
    }
    if (ta == Vec4 and tb == Mat4) return mat4.vmul(b, a);
    if (ta == Mat4 and tb == Vec4) return mat4.mulv(a, b);
}

///
pub fn assertMetaEql(A: type, B: type) void {
    if (A == B) return;

    const vec_len = switch (A) {
        Vec2 => 2,
        Vec3 => 3,
        Vec4 => 4,
        else => @compileError(std.fmt.comptimePrint("{s} is not a hym vector type", .{@typeName(A)})),
    };

    const err_msg = std.fmt.comptimePrint("Vector type {s} not equal to {s}", .{ @typeName(B), @typeName(A) });

    if (@sizeOf(B) != @sizeOf(A)) {
        @compileError(err_msg);
    }

    const type_info = @typeInfo(B);
    switch (type_info) {
        .@"struct" => |s| {
            if (vec_len != s.fields.len) {
                @compileError(err_msg);
            }
            for (s.fields) |f| {
                if (f.type != f32) {
                    @compileError(err_msg);
                }
            }
        },
        .array => |a| {
            if (a.len != vec_len) {
                @compileError(err_msg);
            }
        },
        else => @compileError(std.fmt.comptimePrint("Type {s} is not a vector type", .{@typeName(B)})),
    }
}

pub fn lerp(a: anytype, b: @TypeOf(a), t: f32) @TypeOf(a) {
    return ((b - a) * t) + a;
}

pub fn peak(alpha: anytype, t: anytype) f32 {
    return (alpha * std.math.e) / std.math.pow(f32, std.math.e, alpha * t) * t;
}

pub fn nsTime(ns: u64) f32 {
    const t: f32 = @floatFromInt(ns);
    return t / std.time.ns_per_s;
}

pub inline fn nanos(sec: f32) u64 {
    return @intFromFloat(std.time.ns_per_s * sec);
}
