const std = @import("std");
const vec3 = @import("vec3.zig");
const Vec3 = vec3.Vec3;

const f32_max = std.math.floatMax(f32);
const f32_min = -std.math.floatMax(f32);

pub const AxisAligned = extern struct {
    min: Vec3 = vec3.create(f32_max, f32_max, f32_max),
    max: Vec3 = vec3.create(f32_min, f32_min, f32_min),

    pub inline fn extents(self: *const AxisAligned) Vec3 {
        return vec3.sub(self.max, self.min);
    }

    pub inline fn center(self: *const AxisAligned) Vec3 {
        return self.min.add(self.extents().div(2));
    }

    pub fn invalid(self: AxisAligned) bool {
        return self.min.v == .{ f32_max, f32_max, f32_max } and
            self.max.v == .{ f32_min, f32_min, f32_min };
    }
};
