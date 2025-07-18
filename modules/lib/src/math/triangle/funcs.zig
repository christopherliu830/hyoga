const std = @import("std");
const hym = @import("../math.zig");

pub inline fn ccw(a: hym.Vec2, b: hym.Vec2, c: hym.Vec2) bool {
    return determinant(a, b, c) > 0.0;
}

pub inline fn determinant(a: hym.Vec2, b: hym.Vec2, c: hym.Vec2) f32 {
    return (b.x() - a.x()) * (c.y() - a.y()) -
        (b.y() - a.y()) * (c.x() - a.x());
}

pub inline fn incircle(a: hym.Vec2, b: hym.Vec2, c: hym.Vec2, d: hym.Vec2) bool {
    const ax, const ay = a.v;
    const bx, const by = b.v;
    const cx, const cy = c.v;
    const dx, const dy = d.v;

    const ax_ = ax - dx;
    const ay_ = ay - dy;
    const bx_ = bx - dx;
    const by_ = by - dy;
    const cx_ = cx - dx;
    const cy_ = cy - dy;

    const det = (ax_ * ax_ + ay_ * ay_) * (bx_ * cy_ - cx_ * by_) -
        (bx_ * bx_ + by_ * by_) * (ax_ * cy_ - cx_ * ay_) +
        (cx_ * cx_ + cy_ * cy_) * (ax_ * by_ - bx_ * ay_);
    return det > 0.0;
}

// Returns true if a is right of line b -> c.
pub fn rightOf(a: hym.Vec2, b: hym.Vec2, c: hym.Vec2) bool {
    return ccw(a, c, b);
}

// Returns true if a is left of line b -> c.
pub fn leftOf(a: hym.Vec2, b: hym.Vec2, c: hym.Vec2) bool {
    return ccw(a, b, c);
}

pub fn raySegmentIntersect(o: hym.Vec2, d: hym.Vec2, a: hym.Vec2, b: hym.Vec2) [2]f32 {
    const v_1 = o.sub(a);
    const v_2 = b.sub(a);
    const v_3 = hym.vec2.create(-d.y(), d.x());

    const t_1 = v_2.cross(v_1) / v_2.dot(v_3);
    const t_2 = v_1.dot(v_3) / v_2.dot(v_3);
    return .{ t_1, t_2 };
}
