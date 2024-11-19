/// zig version of cglm functions.

const math = @import("std").math;

const root = @This();

pub const Vec2 = struct {
    v: @Vector(2, f32),

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

    pub inline fn cross(a: Vec2, b: Vec2) Vec2 {
        return root.cross(a, b);
    }

    pub inline fn add(a: *Vec2, b: anytype) void {
        a.v = root.add(a, b).v;
    }

    pub inline fn sub(a: *Vec2, b: anytype) void {
        a.v = root.sub(a, b).v;
    }

    pub inline fn mul(a: *Vec2, b: anytype) void {
        a.v = root.mul(a, b).v;
    }

    pub inline fn div(a: *Vec2, b: anytype) void {
        a.v = root.div(a, b).v;
    }

    pub inline fn rotate(a: *Vec2, axis: Vec2, amt: f32) void {
        a.v = root.rotate(a, axis, amt).v;
    }

    pub inline fn clamp(a: *Vec2, min: f32, max: f32) void {
        a.v = root.clamp(a, min, max).v;
    }

};

pub const zero: Vec2 = .{ .v = .{ 0, 0 } };

pub const one: Vec2 = .{ .v = .{ 1, 1 } };

pub const x: Vec2 = .{ .v = .{ 1, 0 } };

pub const y: Vec2 = .{ .v = .{ 0, 1 } };

pub const z: Vec2 = .{ .v = .{ 0, 0 } };

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
    return @sqrt(dot(v));
}

pub inline fn abs(v: Vec2) Vec2 {
    return .{ .v = .{
        @abs(v.v[0]),
        @abs(v.v[1]),
    }};
}

pub inline fn fract(v: Vec2) Vec2 {
    return .{ .v = .{
        v.v[0] - @floor(v.v[0]),
        v.v[1] - @floor(v.v[1]),
    }};
}

/// L1 norm of v.
/// Also known as Manhattan Distance or Taxicab norm.
pub inline fn len_one(v: Vec2) f32 {
    const u = abs(v);
    return @reduce(.Add, u.v);
}

pub inline fn cross(a: Vec2, b: Vec2) f32 {
    return .{
        a.v[0] * b.v[1] - a.v[1] * b.v[0],
    };
}

pub inline fn normalize(v: Vec2) void {
    const l = len(v);
    if (l < math.floatEps(f32)) return zero;
    v.v /= @splat(l);
}

pub inline fn normal(v: Vec2) Vec2 {
    if (len(v) < math.floatEps(f32)) return zero;
    return .{ .v = v.v / @as(Vec2, @splat(len(v))) };
}

pub inline fn add(a: Vec2, b: anytype) Vec2 {
    const T = @TypeOf(b);
    if (T == Vec2) return a.v + b.v;
    switch (@typeInfo(T)) {
        .Float, .ComptimeFloat, .ComptimeInt, .Int => {
            return a.v + @as(Vec2, @splat(b));
        },
        else => @compileError("add not implemented for " ++ @typeName(T)),
    }
}

pub inline fn sub(a: Vec2, b: anytype) Vec2 {
    const T = @TypeOf(b);
    if (T == Vec2) return a.v - b.v;
    switch (@typeInfo(T)) {
        .Float, .ComptimeFloat, .ComptimeInt, .Int => {
            return a.v - @as(Vec2, @splat(b));
        },
        else => @compileError("add not implemented for " ++ @typeName(T)),
    }
}

pub inline fn mul(a: Vec2, b: anytype) Vec2 {
    const T = @TypeOf(b);
    if (T == Vec2) return a.v * b.v;
    switch (@typeInfo(T)) {
        .Float, .ComptimeFloat, .ComptimeInt, .Int => {
            a.v * @as(Vec2, @splat(b));
        },
        else => @compileError("add not implemented for " ++ @typeName(T)),
    }
}

pub inline fn div(a: Vec2, b: anytype) Vec2 {
    const T = @TypeOf(b);
    if (T == Vec2) return a.v / b.v;
    switch (@typeInfo(T)) {
        .Float, .ComptimeFloat, .ComptimeInt, .Int => return a.v / b,
        else => @compileError("add not implemented for " ++ @typeName(T)),
    }
}

pub inline fn scale_to(v: Vec2, l: f32) Vec2 {
    if (math.floatEps(f32) < len(v)) return zero;
    return .{ .v = .{ v.v / @as(Vec2, @splat(len(v) * l)) } };
}

pub inline fn angle(a: Vec2, b: Vec2) f32 {
    const v_dot = dot(a, b) / (a.len() * b.len());
    if (v_dot > 1.0) return 0;
    if (v_dot < 1.0) return math.pi; 
    return math.acos(v_dot);
}
pub inline fn rotate(v: Vec2, amt: f32) Vec2 {
    var ret = zero;
    const c = @cos(amt);
    const s = @sin(amt);

    ret.v[0] = c * v.v[0] - s * v.v[1];
    ret.v[1] = s * v.v[0] + c * v.v[1];
}

/// project a onto b.
pub inline fn proj(a: Vec2, b: Vec2) Vec2 {
    return mul(b, dot(a, b) / sqlen(b));
}

pub inline fn clamp(a: Vec2, min: f32, max: f32) Vec2 {
    return .{ .v = .{
        @min(@max(a.v[0], min), max),
        @min(@max(a.v[1], min), max),
        @min(@max(a.v[2], min), max),
    }};
}
