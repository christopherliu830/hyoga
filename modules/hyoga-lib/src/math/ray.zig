const std = @import("std");
const math = @import("math.zig");

pub const Ray = struct {
    origin: math.Vec3,
    direction: math.Vec3,

    // TODO: simd
    pub fn intersect(self: Ray, box: math.bounds.AxisAligned, len: f32) bool {
        const dx = self.direction.x() * len;
        const dy = self.direction.y() * len;
        const dz = self.direction.z() * len;
        var t_min: f32 = 0;
        var t_max: f32 = 0;
        var ty_min: f32 = 0;
        var ty_max: f32 = 0;
        var tz_min: f32 = 0;
        var tz_max: f32 = 0;
        // x = t * dx + origin_x;
        // t = x - origin_x / dx;
        if (dx >= 0) {
            t_min = (box.min.x() - self.origin.x()) / dx;
            t_max = (box.max.x() - self.origin.x()) / dx;
        } else {
            t_max = (box.min.x() - self.origin.x()) / dx;
            t_min = (box.max.x() - self.origin.x()) / dx;
        }

        if (dy >= 0) {
            ty_min = (box.min.y() - self.origin.y()) / dy;
            ty_max = (box.max.y() - self.origin.y()) / dy;
        } else {
            ty_max = (box.min.y() - self.origin.y()) / dy;
            ty_min = (box.max.y() - self.origin.y()) / dy;
        }

        if ((t_max < ty_min) or (ty_max < t_min)) return false;

        t_min = @max(t_min, ty_min);
        t_max = @min(t_max, ty_max);

        if (dz >= 0) {
            tz_min = (box.min.z() - self.origin.z()) / dz;
            tz_max = (box.max.z() - self.origin.z()) / dz;
        } else {
            tz_max = (box.min.z() - self.origin.z()) / dz;
            tz_min = (box.max.z() - self.origin.z()) / dz;
        }

        if ((t_max < tz_min) or (tz_max < t_min)) return false;

        t_min = @max(t_min, tz_min);
        t_max = @min(t_max, tz_max);

        return t_min < len and t_max > 0;
    }
};
