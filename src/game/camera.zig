const std = @import("std");
const hy = @import("hyoga");
const math = hy.math;

const Event = hy.Input.Event;

const vec3 = math.vec3;
const vec2 = math.vec2;

pub const Camera = struct {
    input: *hy.Input,

    position: vec3.Vec3 = vec3.create(0, 0, 4),
    look_direction: vec3.Vec3 = vec3.create(0, 0, -1),
    pending_input: vec2.Vec2 = vec2.zero,
    mouse_lock_position: vec2.Vec2 = vec2.create(-1, -1),

    pub fn create(input: *hy.Input) Camera {
        return .{
            .input = input,
        };
    }

    pub fn registerInputs(self: *Camera) !void {
        _ = try self.input.bindMouse(.{ .button = .motion}, translate, .{self});
        _ = try self.input.bindMouse(.{ .button = .left }, lockMouse, .{ true });
        _ = try self.input.bindMouse(.{ .button = .middle }, lockMouse, .{ true });
        _ = try self.input.bindMouse(.{ .button = .left, .fire_on = .{ .up = true }}, lockMouse, .{ false });
        _ = try self.input.bindMouse(.{ .button = .middle, .fire_on = .{ .up = true }}, lockMouse, .{ false });
        _ = try self.input.bindMouse(.{ .button = .wheel }, zoom, .{ self });
        _ = try self.input.bindKey(.{ .button = .s }, pan, .{ self, vec2.create(-1,  0)});
        _ = try self.input.bindKey(.{ .button = .d }, pan, .{ self, vec2.create( 0, -1)});
        _ = try self.input.bindKey(.{ .button = .f }, pan, .{ self, vec2.create( 0,  1)});
        _ = try self.input.bindKey(.{ .button = .g }, pan, .{ self, vec2.create( 1,  0)});
    }

    pub fn flushPendingInput(self: *Camera) void {
        const right = vec3.cross(self.look_direction, vec3.y);
        const up = vec3.cross(self.look_direction, right);
        self.position.add(vec3.mul(right, -self.pending_input.x() / 100.0));
        self.position.add(vec3.mul(up, -self.pending_input.y() / 100.0));
    }

};

fn lockMouse(lock: bool, _: Event) void {
    std.debug.print("{}\n", .{lock});
}

fn translate(cam: *Camera, event: Event) void {
    // pan
    if (cam.input.queryMouse(.middle)) {
        pan(cam, vec2.create(event.motion.xrel / 10, event.motion.yrel / 10), event);
    }

    // change look
    if (cam.input.queryMouse(.left)) {
        var direction = cam.look_direction;
        direction.rotate(vec3.y, -event.motion.xrel / 500); 
        direction.rotate(vec3.cross(direction, vec3.y), -event.motion.yrel / 500);
        cam.look_direction = direction;
    }
}

fn pan(cam: *Camera, dir: vec2.Vec2, _: hy.Input.Event) void {
    const right = vec3.cross(cam.look_direction, vec3.y);
    const up = vec3.cross(cam.look_direction, right);
    cam.position.add(vec3.mul(right, dir.x() / 5.0));
    cam.position.add(vec3.mul(up, dir.y() / 5.0));
}

fn zoom(ctx: ?*anyopaque, event: Event) void {
    const cam: *Camera = @ptrCast(@alignCast(ctx.?));
    cam.position.add(vec3.mul(cam.look_direction, event.wheel.y));
}
