/// zig version of cglm functions.
const std = @import("std");
const math = std.math;

const root = @This();

const vec3 = @import("vec3.zig");
const Vec3 = vec3.Vec3;

pub const Vec2 = extern struct {
    v: @Vector(2, f32),

    pub const zero = Vec2{ .v = .{ 0, 0 } };
    pub const one = Vec2{ .v = .{ 1, 1 } };
    pub const px = Vec2{ .v = .{ 1, 0 } };
    pub const py = Vec2{ .v = .{ 0, 1 } };
    pub const nx = Vec2{ .v = .{ -1, 0 } };
    pub const ny = Vec2{ .v = .{ 0, -1 } };

    pub const of = root.create;

    pub inline fn x(self: Vec2) f32 {
        return self.v[0];
    }
    pub inline fn y(self: Vec2) f32 {
        return self.v[1];
    }

    pub inline fn eql(self: Vec2, other: Vec2) bool {
        return @reduce(.And, self.v == other.v);
    }

    pub inline fn eqlEps(self: Vec2, other: Vec2, eps: f32) bool {
        if (self.eql(other)) return true;

        const diff = @abs(self.v - other.v);
        const norm = @min(
            @abs(self.v + other.v),
            @Vector(2, f32){ std.math.floatMax(f32), std.math.floatMax(f32) },
        );

        return @reduce(.And, diff < @max(@Vector(2, f32){ std.math.floatEps(f32), std.math.floatEps(f32) }, @Vector(2, f32){ eps, eps } * norm));
    }

    pub inline fn dot(a: Vec2, b: Vec2) f32 {
        return root.dot(a, b);
    }

    pub inline fn sqlen(a: Vec2) f32 {
        return root.sqlen(a);
    }

    pub inline fn len(a: Vec2) f32 {
        return root.len(a);
    }

    pub inline fn normalize(a: *Vec2) void {
        root.normalize(a);
    }

    pub inline fn normal(a: Vec2) Vec2 {
        return root.normal(a);
    }

    pub inline fn cross(a: Vec2, b: Vec2) f32 {
        return root.cross(a, b);
    }

    pub inline fn atan(v: Vec2) f32 {
        return std.math.atan2(v.y(), v.x());
    }

    pub const add = root.add;
    pub const addxy = root.addxy;
    pub const sub = root.sub;
    pub const mul = root.mul;
    pub const div = root.div;
    pub const lerp = root.lerp;
    pub const clamp = root.clamp;
    pub const scaleTo = root.scaleTo;
    pub const angle = root.angle;
    pub const angleSlow = root.angleSlow;

    pub inline fn rotate(a: Vec2, amt: f32) Vec2 {
        return root.rotate(a, amt);
    }

    pub inline fn append(v: Vec2, n: f32) Vec3 {
        return vec3.create(v.v[0], v.v[1], n);
    }
};

pub const zero = Vec2{ .v = .{ 0, 0 } };
pub const one = Vec2{ .v = .{ 1, 1 } };
pub const px = Vec2{ .v = .{ 1, 0 } };
pub const py = Vec2{ .v = .{ 0, 1 } };
pub const nx = Vec2{ .v = .{ -1, 0 } };
pub const ny = Vec2{ .v = .{ 0, -1 } };

pub inline fn create(i: f32, j: f32) Vec2 {
    return .{ .v = .{ i, j } };
}

pub inline fn dot(a: Vec2, b: Vec2) f32 {
    return a.v[0] * b.v[0] +
        a.v[1] * b.v[1];
}

pub inline fn sqlen(v: Vec2) f32 {
    return dot(v, v);
}

pub inline fn len(v: Vec2) f32 {
    return @sqrt(dot(v, v));
}

pub inline fn abs(v: Vec2) Vec2 {
    return .{ .v = .{
        @abs(v.v[0]),
        @abs(v.v[1]),
    } };
}

pub inline fn fract(v: Vec2) Vec2 {
    return .{ .v = .{
        v.v[0] - @floor(v.v[0]),
        v.v[1] - @floor(v.v[1]),
    } };
}

/// L1 norm of v.
/// Also known as Manhattan Distance or Taxicab norm.
pub inline fn len_one(v: Vec2) f32 {
    const u = abs(v);
    return @reduce(.Add, u.v);
}

pub inline fn cross(a: Vec2, b: Vec2) f32 {
    return a.v[0] * b.v[1] - a.v[1] * b.v[0];
}

pub inline fn normalize(v: Vec2) void {
    const l = len(v);
    if (l < math.floatEps(f32)) return zero;
    v.v /= @splat(l);
}

pub inline fn normal(v: Vec2) Vec2 {
    if (len(v) < math.floatEps(f32)) return zero;
    return .{ .v = v.v / @as(@Vector(2, f32), @splat(len(v))) };
}

pub inline fn add(a: Vec2, b: anytype) Vec2 {
    const T = @TypeOf(b);
    if (T == Vec2) return .{ .v = a.v + b.v };
    return switch (@typeInfo(T)) {
        .float, .comptime_float, .comptime_int, .int => blk: {
            const bv: @TypeOf(a.v) = @splat(b);
            break :blk .{ .v = a.v + bv };
        },
        else => @compileError("add not implemented for " ++ @typeName(T)),
    };
}

pub fn addxy(a: Vec2, x: f32, y: f32) Vec2 {
    return a.add(create(x, y));
}

pub inline fn sub(a: Vec2, b: anytype) Vec2 {
    const T = @TypeOf(b);
    if (T == Vec2) return .{ .v = a.v - b.v };
    return switch (@typeInfo(T)) {
        .float, .comptime_float, .comptime_int, .int => blk: {
            const bv: @TypeOf(a.v) = @splat(b);
            break :blk .{ .v = a.v - bv };
        },
        else => @compileError("sub not implemented for " ++ @typeName(T)),
    };
}

pub inline fn mul(a: Vec2, b: anytype) Vec2 {
    const T = @TypeOf(b);
    if (T == Vec2) return .{ .v = a.v * b.v };
    return switch (@typeInfo(T)) {
        .float, .comptime_float, .comptime_int, .int => blk: {
            const bv: @TypeOf(a.v) = @splat(b);
            break :blk .{ .v = a.v * bv };
        },
        else => @compileError("add not implemented for " ++ @typeName(T)),
    };
}

pub inline fn div(a: Vec2, b: anytype) Vec2 {
    const T = @TypeOf(b);
    if (T == Vec2) return .{ .v = a.v / b.v };
    return switch (@typeInfo(T)) {
        .float, .comptime_float, .comptime_int, .int => blk: {
            const bv: @TypeOf(a.v) = @splat(b);
            break :blk .{ .v = a.v / bv };
        },
        else => @compileError("add not implemented for " ++ @typeName(T)),
    };
}

pub inline fn lerp(a: Vec2, b: Vec2, t: f32) Vec2 {
    return b.sub(a).mul(t).add(a);
}

pub inline fn scaleTo(v: Vec2, l: f32) Vec2 {
    if (len(v) < math.floatEps(f32)) return zero;
    return .{ .v = v.v / @as(@Vector(2, f32), @splat(len(v) / l)) };
}

pub inline fn angle(a: Vec2, b: Vec2) f32 {
    const v_dot = dot(a, b) / (a.len() * b.len());
    if (v_dot > 1.0) return 0;
    if (v_dot < -1.0) return math.pi;
    return math.acos(v_dot);
}

pub inline fn angleSlow(a: Vec2, b: Vec2) f32 {
    const atan_a = math.atan2(a.y(), a.x());
    const atan_b = math.atan2(b.y(), b.x());
    return atan_a - atan_b;
}

pub inline fn rotate(v: Vec2, amt: f32) Vec2 {
    var ret = zero;
    const c = @cos(amt);
    const s = @sin(amt);

    ret.v[0] = c * v.v[0] - s * v.v[1];
    ret.v[1] = s * v.v[0] + c * v.v[1];

    return ret;
}

/// project a onto b.
pub inline fn proj(a: Vec2, b: Vec2) Vec2 {
    return mul(b, dot(a, b) / sqlen(b));
}

pub inline fn clamp(a: Vec2, min: f32, max: f32) Vec2 {
    return .{ .v = .{
        @min(@max(a.v[0], min), max),
        @min(@max(a.v[1], min), max),
    } };
}
