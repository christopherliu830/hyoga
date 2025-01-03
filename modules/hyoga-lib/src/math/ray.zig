const std = @import("std");
const math = @import("math.zig");


pub const Ray = struct {
    origin: math.Vec3,
    direction: math.Vec3,

    // Intersection
    // https://tavianator.com/2022/ray_box_boundary.html

    pub fn intersect(self: Ray, boxes: []const math.bounds.AxisAligned, out: []f32) void {
        std.debug.assert(boxes.len <= out.len);

        const inv_d = math.vec3.one.div(self.direction).v;

        for (boxes, out) |box, *t_out| {
            const min = box.min.sub(self.origin).v * inv_d;
            const max = box.max.sub(self.origin).v * inv_d;

            const signs = @Vector(3, bool) {
                std.math.signbit(inv_d[0]),
                std.math.signbit(inv_d[1]),
                std.math.signbit(inv_d[2]),
            };

            const bounds_min = @select(f32, signs, max, min);
            const bounds_max = @select(f32, signs, min, max);
            const limit_min = @reduce(.Max, bounds_min);
            const limit_max = @reduce(.Min, bounds_max);
            const t_max = @min(t_out.*, limit_max);
            const t_min = @max(0, limit_min);

            t_out.* = if (t_min < t_max) t_min else t_out.*;
        }
    }

    pub const pack_len = std.simd.suggestVectorLength(f32) orelse 8;
    const PackedVec3 = [3]@Vector(pack_len, f32);
    const PackedFloat = @Vector(pack_len, f32);

    const PackedAxisAligned = struct {
        bounds: [2]PackedVec3, 
    };

    /// see intersectPacked().
    pub fn pack(boxes: []const math.bounds.AxisAligned, allocator: std.mem.Allocator) ![]PackedAxisAligned {
        const num_packed_boxes = try std.math.divFloor(usize, (boxes.len + pack_len - 1), pack_len);
        const packed_boxes = try allocator.alloc(PackedAxisAligned, num_packed_boxes);

        for (0..num_packed_boxes) |i| {
            for(0..pack_len, i*pack_len..) |j, k| {
                const idx = if (k >= boxes.len) boxes.len - 1 else k;
                inline for(0..3) |d| {
                    packed_boxes[i].bounds[0][d][j] = boxes[idx].min.v[d];
                    packed_boxes[i].bounds[1][d][j] = boxes[idx].max.v[d];
                }
            }
        }
        return packed_boxes;
    }

    /// This function takes an array of packed AxisAligned (struct { x: []f32, y: []f32, z: []f32 })
    /// and performs intersection tests on N boxes at a time.
    /// Returns an array of N floats, where:
    ///     if box N intersects the ray: the distance along the ray at intersection point.
    ///     else: max_len
    pub fn intersectPacked(self: Ray, boxes: []const PackedAxisAligned, max_len: f32, allocator: std.mem.Allocator) ![]f32 {
        const inv_d = math.vec3.one.div(self.direction).v;

        const t_out = try allocator.alloc(PackedFloat, boxes.len);
        for(t_out) |*t| { t.* = @splat(max_len); }

        const origin: PackedVec3 = .{
            @splat(self.origin.v[0]),
            @splat(self.origin.v[1]),
            @splat(self.origin.v[2]),
        };

        const inv_dir: PackedVec3 = .{
            @splat(inv_d[0]),
            @splat(inv_d[1]),
            @splat(inv_d[2]),
        };

        for (boxes, 0..) |box, i| {
            var t_min: PackedFloat = @splat(0);
            var t_max: PackedFloat = t_out[i];

            const signs = @Vector(3, bool) {
                std.math.signbit(inv_d[0]),
                std.math.signbit(inv_d[1]),
                std.math.signbit(inv_d[2]),
            };

            inline for (0..3) |d| {
                const b_min = box.bounds[@intFromBool(signs[d])][d];
                const b_max = box.bounds[@intFromBool(!signs[d])][d];

                const min = (b_min - origin[d]) * inv_dir[d];
                const max = (b_max - origin[d]) * inv_dir[d];

                t_min = @max(min, t_min);
                t_max = @min(max, t_max);
            }

            const mask = t_min < t_max;
            t_out[i] = @select(f32, mask, t_min, t_out[i]);
        }

        return @as([*]f32, @ptrCast(t_out.ptr))[0..boxes.len * pack_len];
    }
};
