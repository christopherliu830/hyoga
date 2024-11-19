const std = @import("std");
const math = std.math;

pub const Mat4 = Matrix(f32, 4, 4);

pub const Vec3 = struct {
    data: @Vector(3, f32),

    pub fn create(a: f32, b: f32, c: f32) Vec3 { 
        return .{
            .data = .{ a, b, c },
        };
    }

    pub inline fn x(self: *const Vec3) f32 { return self.data[0]; }
    pub inline fn y(self: *const Vec3) f32 { return self.data[1]; }
    pub inline fn z(self: *const Vec3) f32 { return self.data[2]; }
};

pub fn normalize(v: anytype) Vec3 {
    return .{
        .data = v.data * @as(@TypeOf(v.data), @splat(math.sqrt(dot(v, v))))
    };
}

pub fn cross(a: Vec3 , b: Vec3) Vec3 {
    return Vec3.create(
        a.y() * b.z() - a.z() * b.y(),
        a.z() * b.x() - a.x() * b.z(),
        a.x() * b.y() - a.y() * b.x(),
    );
}

pub fn dot(a: anytype, b: anytype) f32 {
    return @reduce(.Add, a.data * b.data);
}

pub fn Matrix(comptime T: type, x: u32, y: u32) type {
    return struct {
        const Self = @This();
        data: [x][y]T = std.mem.zeroes([x][y]T),

        const identity = Self.create();

        pub fn create() Matrix(T, x, y) {
            var mat: Self = .{};
            for(0..x) |v| mat.data[v][v] = 1.0;
            return mat;
        }

        pub fn createLook(eye: Vec3, direction: Vec3, up: Vec3) Self {
            const f = normalize(direction);
            const s = normalize(cross(f, up));
            const u = cross(s, f);

            var result = Self.create();
            result.data[0][0] = s.x();
            result.data[1][0] = s.y();
            result.data[2][0] = s.z();
            result.data[0][1] = u.x();
            result.data[1][1] = u.y();
            result.data[2][1] = u.z();
            result.data[0][2] = - f.x();
            result.data[1][2] = - f.y();
            result.data[2][2] = - f.z();
            result.data[3][0] = - dot(s, eye);
            result.data[3][1] = - dot(u, eye);
            result.data[3][2] = dot(f, eye);
            return result;
        }
    };
}
