const std = @import("std");
const input = @import("input.zig");
const vec3 = @import("hym/vec3.zig");
const vec2 = @import("hym/vec2.zig");
const window = @import("window.zig");

pub const Camera = struct {
    position: vec3.Vec3,
    look_direction: vec3.Vec3,

    mouse_lock_position: vec2.Vec2 = vec2.create(-1, -1),

    pub fn registerInputs(self: *Camera) !void {
        _ = try input.bindMouse(.motion, .{ .handler = translate, .ctx = self });
        _ = try input.bindMouse(.left , .{ .handler = lockMouse, .ctx = self });
        _ = try input.bindMouse(.left , .{ .handler = unlockMouse, .ctx = self, .fire_on = .{ .up = true } });
        _ = try input.bindMouse(.middle, .{ .handler = lockMouse, .ctx = self });
        _ = try input.bindMouse(.middle, .{ .handler = unlockMouse, .ctx = self, .fire_on = .{ .up = true } });
        _ = try input.bindMouse(.wheel, .{ .handler = zoom, .ctx = self });
    }

};

fn lockMouse(_: ?*anyopaque, _: input.MouseEvent) void {
    window.setRelativeMouseMode(true);

}

fn unlockMouse(_: ?*anyopaque, _: input.MouseEvent) void {
    window.setRelativeMouseMode(false);
}


fn translate(ctx: ?*anyopaque, event: input.MouseEvent) void {
    const cam: *Camera = @ptrCast(@alignCast(ctx.?));

    // sliding
    if (input.queryMouse(.middle)) {
        const right = vec3.cross(cam.look_direction, vec3.y);
        const up = vec3.y;
        cam.position.add(vec3.mul(right, -event.motion.xrel / 100));
        cam.position.add(vec3.mul(up, event.motion.yrel / 100));
    }

    // moving
    if (input.queryMouse(.left)) {
        var direction = cam.look_direction;
        direction.rotate(vec3.y, -event.motion.xrel / 500); 
        direction.rotate(vec3.cross(direction, vec3.y), -event.motion.yrel / 500);
        cam.look_direction = direction;
    }
}

fn zoom(ctx: ?*anyopaque, event: input.MouseEvent) void {
    const cam: *Camera = @ptrCast(@alignCast(ctx.?));
    cam.position.add(vec3.mul(cam.look_direction, event.wheel.y));
}
