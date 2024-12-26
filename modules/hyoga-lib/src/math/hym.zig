pub const cam = @import("cam.zig");

pub const vec2 = @import("vec2.zig");

pub const vec3 = @import("vec3.zig");
pub const vec4 = @import("vec4.zig");
pub const mat4 = @import("mat4.zig");

pub const Vec2 = vec2.Vec2;
pub const Vec3 = vec3.Vec3;
pub const Vec4 = vec4.Vec4;

pub const Mat4 = mat4.Mat4;

pub fn VectorType(v: anytype) type {
    const len = @typeInfo(@TypeOf(v)).@"struct".fields.len;
    return switch (len) {
        2 => Vec2,
        3 => Vec3,
        4 => Vec4,
        else => comptime unreachable,
    };
}

pub fn vec(v: anytype) VectorType(v) {
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
