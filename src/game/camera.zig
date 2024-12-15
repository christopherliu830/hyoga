const std = @import("std");
const hy = @import("hyoga");
const math = hy.math;

const Event = hy.Input.Event;

const vec3 = math.vec3;
const vec2 = math.vec2;

const ViewMatrix = math.Mat4;

pub const Camera = struct {
    input: *hy.Input,
    window: *hy.Window,

    position: vec3.Vec3 = vec3.create(0, 0, 4),
    look_direction: vec3.Vec3 = vec3.create(0, 0, -1),
    pending_input: vec2.Vec2 = vec2.zero,
    mouse_lock_position: vec2.Vec2 = vec2.create(-1, -1),

    fovy: f32 = 1,
    z_near: f32 = 0.1,
    z_far: f32 = 1000,

    pub fn create(input: *hy.Input, window: *hy.Window) Camera {
        return .{
            .input = input,
            .window = window,
        };
    }

    pub fn viewProj(self: Camera) ViewMatrix {
        const view = math.cam.lookAt(self.position, vec3.add(self.position, self.look_direction), vec3.y);
        const persp = math.cam.perspectiveMatrix(self.fovy, self.window.aspect, self.z_near, self.z_far);
        return math.mat4.mul(view, persp);
    }

    pub fn registerInputs(self: *Camera) !void {
        _ = try self.input.bindMouse(.{ .button = .motion}, translate, .{self});
        _ = try self.input.bindMouse(.{ .button = .left }, lockMouse, .{ self, true });
        _ = try self.input.bindMouse(.{ .button = .middle }, lockMouse, .{ self, true });
        _ = try self.input.bindMouse(.{ .button = .left, .fire_on = .{ .up = true }}, lockMouse, .{ self, false });
        _ = try self.input.bindMouse(.{ .button = .middle, .fire_on = .{ .up = true }}, lockMouse, .{ self, false });
        _ = try self.input.bindMouse(.{ .button = .wheel }, zoom, .{ self });
        _ = try self.input.bindKey(.{ .button = .s, .fire_on = .{ .down = true, .held = true} }, pan, .{ self, vec2.create(-1,  0)});
        _ = try self.input.bindKey(.{ .button = .d, .fire_on = .{ .down = true, .held = true}}, pan, .{ self, vec2.create( 0, -1)});
        _ = try self.input.bindKey(.{ .button = .f, .fire_on = .{ .down = true, .held = true} }, pan, .{ self, vec2.create( 0,  1)});
        _ = try self.input.bindKey(.{ .button = .g, .fire_on = .{ .down = true, .held = true} }, pan, .{ self, vec2.create( 1,  0)});
    }

    pub fn editor(self: *Camera) void {
        const imgui = hy.UI.imgui;
        if (imgui.Begin("Camera", null, imgui.WindowFlag.always_auto_resize)) {
            _ = imgui.SliderFloat("Near Plane", @ptrCast(&self.z_near), 0.1, 1000);
            _ = imgui.SliderFloat("Far Plane", @ptrCast(&self.z_far), 0.1, 1000);
            var fovy = self.fovy * std.math.deg_per_rad;
            _ = imgui.SliderFloat("FOV", &fovy, 0, 180);
            self.fovy = fovy * std.math.rad_per_deg;
        }
        imgui.End();
    }
};

fn lockMouse(cam: *Camera, lock: bool, _: Event) void {
    cam.window.setRelativeMouseMode(lock);
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
