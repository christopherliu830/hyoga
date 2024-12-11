const std = @import("std");
const input = @import("input.zig");
const math = @import("hyoga-math");
const window = @import("window.zig");

const vec3 = math.vec3;
const vec2 = math.vec2;

pub const Camera = struct {
    position: vec3.Vec3,
    look_direction: vec3.Vec3,

    pending_input: vec2.Vec2 = vec2.zero,
    mouse_lock_position: vec2.Vec2 = vec2.create(-1, -1),

    pub fn registerInputs(self: *Camera) !void {
        _ = try input.bindMouse(.motion, .{ .handler = translate, .ctx = self });
        _ = try input.bindMouse(.left , .{ .handler = lockMouse, .ctx = self });
        _ = try input.bindMouse(.left , .{ .handler = unlockMouse, .ctx = self, .fire_on = .{ .up = true } });
        _ = try input.bindMouse(.middle, .{ .handler = lockMouse, .ctx = self });
        _ = try input.bindMouse(.middle, .{ .handler = unlockMouse, .ctx = self, .fire_on = .{ .up = true } });
        _ = try input.bindMouse(.wheel, .{ .handler = zoom, .ctx = self });
        _ = try input.bind(input.keycode.s, .{ .handler = scrollLeft, .ctx = self, .fire_on = .{ .down = true, .held = true } });
        _ = try input.bind(input.keycode.g, .{ .handler = scrollRight, .ctx = self, .fire_on = .{ .down = true, .held = true } });
        _ = try input.bind(input.keycode.f, .{ .handler = scrollUp, .ctx = self, .fire_on = .{ .down = true, .held = true } });
        _ = try input.bind(input.keycode.d, .{ .handler = scrollDown, .ctx = self, .fire_on = .{ .down = true, .held = true } });
    }

    pub fn flushPendingInput(self: *Camera) void {
        const right = vec3.cross(self.look_direction, vec3.y);
        const up = vec3.cross(self.look_direction, right);
        self.position.add(vec3.mul(right, -self.pending_input.x() / 100.0));
        self.position.add(vec3.mul(up, -self.pending_input.y() / 100.0));
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
        const up = vec3.cross(cam.look_direction, right);
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

fn scrollLeft(ctx: ?*anyopaque) void {
    const cam: *Camera = @ptrCast(@alignCast(ctx.?));
    const right = vec3.cross(cam.look_direction, vec3.y);
    cam.position.add(vec3.mul(right, -1.0 / 5.0));
}

fn scrollRight(ctx: ?*anyopaque) void {
    const cam: *Camera = @ptrCast(@alignCast(ctx.?));
    const right = vec3.cross(cam.look_direction, vec3.y);
    cam.position.add(vec3.mul(right, 1.0 / 5.0));
}

fn scrollUp(ctx: ?*anyopaque) void {
    const cam: *Camera = @ptrCast(@alignCast(ctx.?));
    const right = vec3.cross(cam.look_direction, vec3.y);
    const up = vec3.cross(cam.look_direction, right);
    cam.position.add(vec3.mul(up, 1.0 / 5.0));
}

fn scrollDown(ctx: ?*anyopaque) void {
    const cam: *Camera = @ptrCast(@alignCast(ctx.?));
    const right = vec3.cross(cam.look_direction, vec3.y);
    const up = vec3.cross(cam.look_direction, right);
    cam.position.add(vec3.mul(up, -1.0 / 5.0));
}


fn zoom(ctx: ?*anyopaque, event: input.MouseEvent) void {
    const cam: *Camera = @ptrCast(@alignCast(ctx.?));
    cam.position.add(vec3.mul(cam.look_direction, event.wheel.y));
}
