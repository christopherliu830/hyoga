/// zig version of cglm functions.
const math = @import("std").math;

const root = @This();

const vec3 = @import("vec3.zig");
const vec2 = @import("vec2.zig");
const Vec3 = vec3.Vec3;
const Vec2 = vec2.Vec2;

pub const Vec4 = extern struct {
    v: @Vector(4, f32),

    pub const of = root.create;

    pub const one: Vec4 = .{ .v = .{ 1, 1, 1, 1 } };

    pub inline fn x(self: Vec4) f32 {
        return self.v[0];
    }
    pub inline fn y(self: Vec4) f32 {
        return self.v[1];
    }
    pub inline fn z(self: Vec4) f32 {
        return self.v[2];
    }
    pub inline fn w(self: Vec4) f32 {
        return self.v[3];
    }
    pub inline fn r(self: Vec4) f32 {
        return self.v[0];
    }
    pub inline fn g(self: Vec4) f32 {
        return self.v[1];
    }
    pub inline fn b(self: Vec4) f32 {
        return self.v[2];
    }
    pub inline fn a(self: Vec4) f32 {
        return self.v[3];
    }

    pub inline fn xy(self: Vec4) Vec2 {
        return .of(self.v[0], self.v[1]);
    }
    pub inline fn xyz(self: Vec4) Vec3 {
        return vec3.create(self.v[0], self.v[1], self.v[2]);
    }

    pub inline fn dot(self: Vec4, other: Vec4) f32 {
        return root.dot(self, other);
    }

    pub inline fn sqlen(self: Vec4) f32 {
        return root.sqlen(self);
    }

    pub inline fn len(self: Vec4) f32 {
        return root.len(self);
    }

    pub inline fn normalize(self: *Vec4) void {
        root.normalize(self);
    }

    pub inline fn normal(self: Vec4) Vec4 {
        return root.normal(self);
    }

    pub inline fn cross(self: Vec4, other: Vec4) Vec4 {
        return root.cross(self, other);
    }

    pub inline fn rotate(self: *Vec4, axis: Vec4, amt: f32) void {
        self.v = root.rotate(self, axis, amt).v;
    }

    pub inline fn clamp(self: *Vec4, min: f32, max: f32) void {
        self.v = root.clamp(self, min, max).v;
    }

    pub const add = root.add;
    pub const sub = root.sub;
    pub const mul = root.mul;
    pub const div = root.div;
    pub const lerp = root.lerp;
};

pub const zero: Vec4 = .{ .v = .{ 0, 0, 0, 0 } };

pub const one: Vec4 = .{ .v = .{ 1, 1, 1, 1 } };
pub const x: Vec4 = .{ .v = .{ 1, 0, 0, 0 } };
pub const y: Vec4 = .{ .v = .{ 0, 1, 0, 0 } };
pub const z: Vec4 = .{ .v = .{ 0, 0, 1, 0 } };
pub const w: Vec4 = .{ .v = .{ 0, 0, 0, 1 } };

pub inline fn create(i: f32, j: f32, k: f32, l: f32) Vec4 {
    return .{ .v = .{ i, j, k, l } };
}

pub inline fn dot(a: Vec4, b: Vec4) f32 {
    return a.v[0] * b.v[0] +
        a.v[1] * b.v[1] +
        a.v[2] * b.v[2] +
        a.v[3] * b.v[3];
}

pub inline fn sqlen(v: Vec4) f32 {
    return dot(v, v);
}

pub inline fn len(v: Vec4) f32 {
    return @sqrt(dot(v));
}

pub inline fn abs(v: Vec4) Vec4 {
    return .{ .v = .{
        @abs(v.v[0]),
        @abs(v.v[1]),
        @abs(v.v[2]),
        @abs(v.v[3]),
    } };
}

pub inline fn fract(v: Vec4) Vec4 {
    return .{ .v = .{
        v.v[0] - @floor(v.v[0]),
        v.v[1] - @floor(v.v[1]),
        v.v[2] - @floor(v.v[2]),
        v.v[3] - @floor(v.v[3]),
    } };
}

/// L1 norm of v.
/// Also known as Manhattan Distance or Taxicab norm.
pub inline fn len_one(v: Vec4) f32 {
    const u = abs(v);
    return @reduce(.Add, u.v);
}

pub inline fn normalize(v: Vec4) void {
    const l = len(v);
    if (l < math.floatEps(f32)) return zero;
    v.v /= @splat(l);
}

pub inline fn normal(v: Vec4) Vec4 {
    if (len(v) < math.floatEps(f32)) return zero;
    return .{ .v = v.v / @as(Vec4, @splat(len(v))) };
}

pub inline fn add(a: Vec4, b: anytype) Vec4 {
    const T = @TypeOf(b);
    if (T == Vec4) return .{ .v = a.v + b.v };
    switch (@typeInfo(T)) {
        .Float, .ComptimeFloat, .ComptimeInt, .Int => {
            return a.v + @as(Vec4, @splat(b));
        },
        else => @compileError("add not implemented for " ++ @typeName(T)),
    }
}

pub inline fn sub(a: Vec4, b: anytype) Vec4 {
    const T = @TypeOf(b);
    if (T == Vec4) return .{ .v = a.v - b.v };
    switch (@typeInfo(T)) {
        .float, .comptime_float, .comptime_int, .int => {
            return a.v - @as(Vec4, @splat(b));
        },
        else => @compileError("add not implemented for " ++ @typeName(T)),
    }
}

pub inline fn mul(a: Vec4, b: anytype) Vec4 {
    const T = @TypeOf(b);
    if (T == Vec4) return .{ .v = a.v * b.v };
    return switch (@typeInfo(T)) {
        .float, .comptime_float, .comptime_int, .int => blk: {
            const bv: @TypeOf(a.v) = @splat(b);
            break :blk .{ .v = a.v * bv };
        },
        else => @compileError("add not implemented for " ++ @typeName(T)),
    };
}

pub inline fn div(a: Vec4, b: anytype) Vec4 {
    const T = @TypeOf(b);
    if (T == Vec4) return .{ .v = a.v / b.v };
    switch (@typeInfo(T)) {
        .float, .comptime_float, .comptime_int, .int => return a.v / b,
        else => @compileError("add not implemented for " ++ @typeName(T)),
    }
}

pub inline fn lerp(a: Vec4, b: Vec4, t: f32) Vec4 {
    return b.sub(a).mul(t).add(a);
}

pub inline fn scale_to(v: Vec4, l: f32) Vec4 {
    if (math.floatEps(f32) < len(v)) return zero;
    return .{ .v = .{v.v / @as(Vec4, @splat(len(v) * l))} };
}

pub inline fn clamp(a: Vec4, min: f32, max: f32) Vec4 {
    return .{ .v = .{
        @min(@max(a.v[0], min), max),
        @min(@max(a.v[1], min), max),
        @min(@max(a.v[2], min), max),
        @min(@max(a.v[3], min), max),
    } };
}
