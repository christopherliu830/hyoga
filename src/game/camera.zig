const std = @import("std");
const hy = @import("hyoga-lib");
const imgui = @import("imgui");
const hym = hy.math;

const vec3 = hym.vec3;
const vec2 = hym.vec2;
const mat4 = hym.mat4;

const ViewMatrix = hym.Mat4;

pub const Camera = struct {
    input_group: hy.runtime.Input.Group = .invalid,

    window: *hy.runtime.Window,

    position: vec3.Vec3 = vec3.create(0, 0, 4),
    look_direction: vec3.Vec3 = vec3.create(0, 0, -1),
    pending_input: vec2.Vec2 = vec2.zero,
    mouse_lock_position: vec2.Vec2 = vec2.create(-1, -1),

    fovy: f32 = 1,
    z_near: f32 = 0.1,
    z_far: f32 = 1000,

    pub fn create(input: *hy.runtime.Input, window: *hy.runtime.Window) Camera {
        return .{
            .input_group = input.createGroup(),
            .window = window,
        };
    }

    pub fn viewProj(self: *const Camera) ViewMatrix {
        const view = hym.cam.lookTo(self.position, self.look_direction, vec3.y);
        const dim = self.window.dimensions();
        const aspect = dim.x() / dim.y();
        const persp = hym.cam.perspectiveMatrix(
            self.fovy,
            aspect,
            self.z_near,
            self.z_far,
        );
        return hym.mul(view, persp);
    }

    pub fn worldRay(self: *const Camera, mouse_position: hym.Vec2) hym.Ray {
        const inv = hym.mat4.inverse(self.viewProj());

        var dims = mouse_position
            .div(self.window.dimensions())
            .mul(2)
            .sub(1)
            .mul(hym.vec(.{ 1, -1 }));

        const world_end = hym.mul(hym.vec4.create(dims.x(), dims.y(), 1, 1), inv);
        const end = hym.vec3.div(world_end.xyz(), world_end.w());

        return .{
            .origin = self.position,
            .direction = end.sub(self.position).normal(),
        };
    }

    pub fn registerInputs(self: *Camera, input: *hy.runtime.Input, arena: std.mem.Allocator) !void {
        const group = input.getGroup(self.input_group);

        if (self.input_group == group) {
            return;
        } else {
            self.input_group = group;
        }

        const l = hy.closure.create;

        input.bindMouse(
            .{ .group = self.input_group, .button = .wheel },
            try l(zoom, .{self}, arena),
        );

        input.bindMouse(
            .{ .group = self.input_group, .button = .motion },
            try l(translate, .{ self, input }, arena),
        );

        input.bindMouse(
            .{ .group = self.input_group, .button = .left },
            try l(lockMouse, .{ self, true }, arena),
        );

        input.bindMouse(
            .{ .group = self.input_group, .button = .left, .fire_on = .{ .up = true } },
            try l(lockMouse, .{ self, false }, arena),
        );

        input.bindMouse(
            .{ .group = self.input_group, .button = .middle },
            try l(lockMouse, .{ self, true }, arena),
        );

        input.bindMouse(
            .{ .group = self.input_group, .button = .middle, .fire_on = .{ .up = true } },
            try l(lockMouse, .{ self, false }, arena),
        );

        input.bindKey(
            .{ .group = self.input_group, .button = .s, .fire_on = .{ .down = true, .held = true } },
            try l(pan, .{ self, vec2.create(-1, 0) }, arena),
        );

        input.bindKey(
            .{ .group = self.input_group, .button = .d, .fire_on = .{ .down = true, .held = true } },
            try l(pan, .{ self, vec2.create(0, -1) }, arena),
        );

        input.bindKey(
            .{ .group = self.input_group, .button = .f, .fire_on = .{ .down = true, .held = true } },
            try l(pan, .{ self, vec2.create(0, 1) }, arena),
        );

        input.bindKey(
            .{ .group = self.input_group, .button = .g, .fire_on = .{ .down = true, .held = true } },
            try l(pan, .{ self, vec2.create(1, 0) }, arena),
        );
    }

    pub fn editor(self: *Camera) void {
        if (imgui.Begin("Camera", null, imgui.WindowFlag.always_auto_resize)) {
            _ = imgui.DragFloat3("Position", @ptrCast(&self.position));
            _ = imgui.SliderFloat("Near Plane", @ptrCast(&self.z_near), 0.1, 1000);
            _ = imgui.SliderFloat("Far Plane", @ptrCast(&self.z_far), 0.1, 1000);
            var fovy = self.fovy * std.math.deg_per_rad;
            _ = imgui.SliderFloat("FOV", &fovy, 0, 180);
            self.fovy = fovy * std.math.rad_per_deg;
        }
        imgui.End();
    }
};

fn lockMouse(cam: *Camera, lock: bool, _: ?*anyopaque) void {
    cam.window.setRelativeMouseMode(lock);
}

fn translate(cam: *Camera, input: *hy.runtime.Input, event: ?*anyopaque) void {
    const motion: *hy.event.MouseMotion = @ptrCast(@alignCast(event));

    // pan
    if (input.queryMouse(.middle)) {
        pan(cam, vec2.create(motion.delta.x() / 10, motion.delta.y() / 10), event);
    }

    // change look
    if (input.queryMouse(.left)) {
        var direction = cam.look_direction;
        direction.rotate(vec3.y, -motion.delta.x() / 500);
        direction.rotate(vec3.cross(direction, vec3.y), -motion.delta.y() / 500);
        cam.look_direction = direction;
    }
}

fn pan(cam: *Camera, dir: vec2.Vec2, _: ?*anyopaque) void {
    const right = vec3.cross(cam.look_direction, vec3.y);
    const up = vec3.cross(cam.look_direction, right);
    cam.position = cam.position.add(vec3.mul(right, dir.x() / 5.0));
    cam.position = cam.position.add(vec3.mul(up, dir.y() / 5.0));
}

fn zoom(cam: *Camera, event: ?*anyopaque) void {
    const wheel: *hy.event.MouseWheel = @ptrCast(@alignCast(event));
    cam.position = cam.position.add(vec3.mul(cam.look_direction, wheel.delta));
}
