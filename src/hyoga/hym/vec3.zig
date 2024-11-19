/// zig version of cglm functions.

const math = @import("std").math;
const vec4 = @import("vec4.zig");

const root = @This();

pub const Vec3 = extern struct {
    v: @Vector(3, f32),

    pub inline fn x(self: Vec3) f32 { return self.v[0]; }

    pub inline fn y(self: Vec3) f32 { return self.v[1]; }

    pub inline fn z(self: Vec3) f32 { return self.v[2]; }

    pub inline fn dot(a: Vec3, b: Vec3) f32 {
        return root.dot(a, b);
    }

    pub inline fn sqlen(a: Vec3) f32 {
        return root.sqlen(a);
    }

    pub inline fn len(a: Vec3) f32 {
        return root.len(a);
    }

    pub inline fn normalize(a: *Vec3) void {
        root.normalize(a);
    }

    pub inline fn normal(a: Vec3) Vec3 {
        return root.normal(a);
    }

    pub inline fn cross(a: Vec3, b: Vec3) Vec3 {
        return root.cross(a, b);
    }

    pub inline fn add(a: *Vec3, b: anytype) void {
        a.v = root.add(a.*, b).v;
    }

    pub inline fn sub(a: *Vec3, b: anytype) void {
        a.v = root.sub(a.*, b).v;
    }

    pub inline fn mul(a: *Vec3, b: anytype) void {
        a.v = root.mul(a.*, b).v;
    }

    pub inline fn div(a: *Vec3, b: anytype) void {
        a.v = root.div(a.*, b).v;
    }

    pub inline fn rotate(a: *Vec3, axis: Vec3, amt: f32) void {
        a.v = root.rotate(a.*, axis, amt).v;
    }

    pub inline fn clamp(a: *Vec3, min: f32, max: f32) void {
        a.v = root.clamp(a.*, min, max).v;
    }

};

pub const zero = Vec3 { .v = .{ 0, 0, 0 } };

pub const one = Vec3 { .v = .{ 1, 1, 1 } };

pub const x = Vec3 { .v = .{ 1, 0, 0 } };

pub const y = Vec3 { .v = .{ 0, 1, 0 } };

pub const z = Vec3 { .v = .{ 0, 0, 1 } };

pub const nx = Vec3 { .v = .{ -1, 0, 0 }};
pub const ny = Vec3 { .v = .{ 0, -1, 0 }};
pub const nz = Vec3 { .v = .{ 0, 0, -1 }};

pub inline fn create(i: f32, j: f32, k: f32) Vec3 {
    return .{ .v = .{ i, j, k }, };
}

pub inline fn dot(a: Vec3, b: Vec3) f32 {
    return a.v[0] * b.v[0] + 
           a.v[1] * b.v[1] +
           a.v[2] * b.v[2];
}

pub inline fn sqlen(v: Vec3) f32 {
    return dot(v, v);
}

pub inline fn len(v: Vec3) f32 {
    return @sqrt(dot(v, v));
}

pub inline fn abs(v: Vec3) Vec3 {
    return .{ .v = .{
        @abs(v.v[0]),
        @abs(v.v[1]),
        @abs(v.v[2]),
    }};
}

pub inline fn fract(v: Vec3) Vec3 {
    return .{ .v = .{
        v.v[0] - @floor(v.v[0]),
        v.v[1] - @floor(v.v[1]),
        v.v[2] - @floor(v.v[2]),
    }};
}

/// L1 norm of v.
/// Also known as Manhattan Distance or Taxicab norm.
pub inline fn len_one(v: Vec3) f32 {
    const u = abs(v);
    return @reduce(.Add, u.v);
}

pub inline fn cross(a: Vec3, b: Vec3) Vec3 {
    return .{ .v = .{
        a.v[1] * b.v[2] - a.v[2] * b.v[1],
        a.v[2] * b.v[0] - a.v[0] * b.v[2],
        a.v[0] * b.v[1] - a.v[1] * b.v[0],
    }};
}

pub inline fn normalize(v: Vec3) void {
    const l = len(v);
    if (l < math.floatEps(f32)) return zero;
    v.v /= @splat(l);
}

pub inline fn normal(v: Vec3) Vec3 {
    if (len(v) < math.floatEps(f32)) return zero;
    return div(v, len(v));
}

pub inline fn append(v: Vec3, w: f32) vec4.Vec4 {
    return .{ .v = .{ v.v[0], v.v[1], v.v[2], w } };
}

pub inline fn add(a: Vec3, b: anytype) Vec3 {
    const T = @TypeOf(b);
    if (T == Vec3) return .{ .v = a.v + b.v };
    return switch (@typeInfo(T)) {
        .Float, .ComptimeFloat, .ComptimeInt, .Int => blk: {
            const bv: @TypeOf(a.v) = @splat(b);
            break :blk .{ .v = a.v + bv };
        },
        else => @compileError("add not implemented for " ++ @typeName(T)),
    };
}

pub inline fn sub(a: Vec3, b: anytype) Vec3 {
    const T = @TypeOf(b);
    if (T == Vec3) return .{ .v = a.v - b.v };
    return switch (@typeInfo(T)) {
        .Float, .ComptimeFloat, .ComptimeInt, .Int => blk: {
            const bv: @TypeOf(a.v) = @splat(b);
            break :blk .{ .v = a.v - bv };
        },
        else => @compileError("add not implemented for " ++ @typeName(T)),
    };
}

pub inline fn mul(a: Vec3, b: anytype) Vec3 {
    const T = @TypeOf(b);
    if (T == Vec3) return .{ .v = a.v * b.v };
    return switch (@typeInfo(T)) {
        .Float, .ComptimeFloat, .ComptimeInt, .Int => blk: {
            const bv: @TypeOf(a.v) = @splat(b);
            break :blk .{ .v = a.v * bv };
        },
        else => @compileError("add not implemented for " ++ @typeName(T)),
    };
}

pub inline fn div(a: Vec3, b: anytype) Vec3 {
    const T = @TypeOf(b);
    if (T == Vec3) return a.v / b.v;
    return switch (@typeInfo(T)) {
        .Float, .ComptimeFloat, .ComptimeInt, .Int => blk: {
            const bv: @TypeOf(a.v) = @splat(b);
            break :blk .{ .v = a.v / bv };
        },
        else => @compileError("add not implemented for " ++ @typeName(T)),
    };
}

pub inline fn scale_to(v: Vec3, l: f32) Vec3 {
    if (math.floatEps(f32) < len(v)) return zero;
    return .{ .v = .{ v.v / @as(Vec3, @splat(len(v) * l)) } };
}

pub inline fn angle(a: Vec3, b: Vec3) f32 {
    const v_dot = dot(a, b) / (a.len() * b.len());
    if (v_dot > 1.0) return 0;
    if (v_dot < 1.0) return math.pi; 
    return math.acos(v_dot);
}

/// rotate vec3 around axis by angle using Rodrigues' rotation formula
pub inline fn rotate(v: Vec3, axis: Vec3, amt: f32) Vec3 {
    // const c: @Vector(3, f32) = @splat(@cos(amt));
    // const s: @Vector(3, f32) = @splat(@sin(amt));
    // const k = normal(axis);
    // const kdotv: @Vector(3, f32) = @splat(dot(k, v) * 1 - @cos(amt));
    const c = @cos(amt);
    const s = @sin(amt);
    const k = normal(axis);

    // Right Hand, Rodrigues' rotation formula:
    //    v = v*cos(t) + (kxv)sin(t) + k*(k.v)(1 - cos(t))
    //

    var v1 = mul(v, c);
    var v2 = cross(k, v);
    v2.mul(s);
    v1.add(v2);

    const v3 = mul(k, dot(k, v) * (1 - c));
    v1.add(v3);

    return v1;
}

/// project a onto b.
pub inline fn proj(a: Vec3, b: Vec3) Vec3 {
    return mul(b, dot(a, b) / sqlen(b));
}

pub inline fn clamp(a: Vec3, min: f32, max: f32) Vec3 {
    return .{ .v = .{
        @min(@max(a.v[0], min), max),
        @min(@max(a.v[1], min), max),
        @min(@max(a.v[2], min), max),
    }};
}
