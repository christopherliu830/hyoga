const std = @import("std");
const hy = @import("hyoga-lib");
const imgui = @import("imgui");
const ent = @import("entity.zig");
const hym = hy.math;

const vec3 = hym.vec3;
const vec2 = hym.vec2;
const mat4 = hym.mat4;

const ViewMatrix = hym.Mat4;

pub const PerspectiveProjection = struct {
    fovy: f32,
    z_near: f32,
    z_far: f32,

    pub const default: PerspectiveProjection = .{
        .fovy = 1,
        .z_near = 0.1,
        .z_far = 1000,
    };
};

pub const OrthographicProjection = struct {
    z_near: f32,
    z_far: f32,
    size: f32,

    pub const default: OrthographicProjection = .{
        .z_near = 0.1,
        .z_far = 1000,
        .size = 10,
    };
};

pub const Projection = union(enum) {
    perspective: PerspectiveProjection,
    orthographic: OrthographicProjection,

    pub const default: Projection = .{
        .perspective = .default,
    };
};

pub const Camera = struct {
    input_group: hy.Input.Group = .none,
    window: *hy.Window,
    position: vec3.Vec3,
    look_direction: vec3.Vec3,
    projection: Projection,
    moveable: ent.Moveable = .{},
    speed: f32,

    pub fn default(window: *hy.runtime.Window) Camera {
        return .{
            .window = window,
            .position = .of(0, 0, 4),
            .look_direction = .of(0, 0, -1),
            .projection = .{ .perspective = .default },
            .speed = 8,
        };
    }

    pub fn defaultOrthographic(window: *hy.runtime.Window) Camera {
        return .{
            .window = window,
            .position = .of(0, 0, 4),
            .look_direction = .of(0, 0, -1),
            .projection = .{ .orthographic = .default },
        };
    }

    pub fn viewProj(self: *const Camera) ViewMatrix {
        const view = hym.cam.lookTo(self.position, self.look_direction, vec3.y);
        const dim = self.window.dimensions();
        const aspect = dim.x() / dim.y();
        const persp = switch (self.projection) {
            .perspective => |p| hym.cam.perspectiveMatrix(p.fovy, aspect, p.z_near, p.z_far),
            .orthographic => |o| blk: {
                break :blk hym.cam.orthographicRh(aspect * o.size, o.size, o.z_near, o.z_far);
            },
        };

        return hym.mul(view, persp);
    }

    pub fn worldRay(self: *const Camera, mouse_position: hym.Vec2) hym.Ray {
        const inv = hym.mat4.inverse(self.viewProj());
        std.mem.doNotOptimizeAway(inv);

        var n = mouse_position
            .div(self.window.dimensions())
            .mul(2)
            .sub(1)
            .mul(hym.vec(.{ 1, -1 }));

        switch (self.projection) {
            .perspective => {
                const clip_end = hym.Vec4.of(n.x(), n.y(), 1, 1);
                const world_end = hym.mul(clip_end, inv);
                const end: hym.Vec3 = .div(world_end.xyz(), world_end.w());

                return .{
                    .origin = self.position,
                    .direction = end.sub(self.position).normal(),
                };
            },
            .orthographic => {
                const clip_start = hym.Vec4.of(n.x(), n.y(), 0, 1);
                const world_start = hym.mul(clip_start, inv);
                const start: hym.Vec3 = .div(world_start.xyz(), world_start.w());

                return .{
                    .origin = start,
                    .direction = self.look_direction,
                };
            },
        }
    }

    pub fn update(self: *Camera, delta_time: f32) void {
        const dir = self.moveable.heading.mul(delta_time * self.speed);
        const right = vec3.cross(self.look_direction, vec3.y);
        const up = vec3.cross(right, self.look_direction);
        self.position = self.position.add(vec3.mul(right, dir.x()));
        self.position = self.position.add(vec3.mul(up, dir.y()));
    }

    pub fn registerInputs(self: *Camera, input: *hy.runtime.Input, arena: std.mem.Allocator) !void {
        const group = input.getGroup(self.input_group);

        if (self.input_group == group) {
            return;
        }

        self.input_group = group;

        const l = hy.closure.create;

        input.bind(group, .mouse(.wheel), try l(zoom, .{self}, arena));
        input.bind(group, .mouse(.motion), try l(translate, .{ self, input }, arena));

        const lock = try l(lockMouse, .{ self, true }, arena);
        const unlock = try l(lockMouse, .{ self, false }, arena);
        input.bind(group, .mouse(.left), lock);
        input.bind(group, .mouse(.middle), lock);
        input.bind(group, .mouseUp(.left), unlock);
        input.bind(group, .mouseUp(.middle), unlock);

        const bindings: []const ent.Moveable.Binding = &.{
            .{ .px = .g },
            .{ .ny = .f },
            .{ .nx = .s },
            .{ .py = .d },
        };

        self.moveable.registerInputs(input, group, bindings, arena);
    }

    pub fn editor(self: *Camera) void {
        if (imgui.Begin("Camera", null, .{ .always_auto_resize = true })) {
            _ = imgui.DragFloat3("Position", @ptrCast(&self.position));

            const items = [_][:0]const u8{ "Perspective", "Orthographic" };
            const selected: u32 = switch (self.projection) {
                .perspective => 0,
                .orthographic => 1,
            };

            if (imgui.BeginCombo("Projection", items[selected].ptr, 0)) {
                inline for (items[0..2], 0..) |label, i| {
                    const is_selected = selected == i;
                    if (imgui.SelectableEx(label, is_selected, 0, .auto) and !is_selected) {
                        switch (i) {
                            0 => {
                                const z_near = self.projection.orthographic.z_near;
                                const z_far = self.projection.orthographic.z_far;
                                self.projection = .{ .perspective = .default };
                                self.projection.perspective.z_near = z_near;
                                self.projection.perspective.z_far = z_far;
                            },
                            1 => {
                                const z_near = self.projection.perspective.z_near;
                                const z_far = self.projection.perspective.z_far;
                                self.projection = .{ .orthographic = .default };
                                self.projection.orthographic.z_near = z_near;
                                self.projection.orthographic.z_far = z_far;
                            },
                            else => comptime unreachable,
                        }
                    }
                }
                imgui.EndCombo();
            }

            switch (self.projection) {
                .perspective => |*projection| {
                    _ = imgui.SliderFloat("Near Plane", @ptrCast(&projection.z_near), 0.1, 1000);
                    _ = imgui.SliderFloat("Far Plane", @ptrCast(&projection.z_far), 0.1, 1000);
                    var fovy = projection.fovy * std.math.deg_per_rad;
                    _ = imgui.SliderFloat("FOV", &fovy, 0, 180);
                    projection.fovy = fovy * std.math.rad_per_deg;
                },
                .orthographic => |*projection| {
                    _ = imgui.SliderFloat("Near Plane", @ptrCast(&projection.z_near), 0.1, 1000);
                    _ = imgui.SliderFloat("Far Plane", @ptrCast(&projection.z_far), 0.1, 1000);
                    _ = imgui.SliderFloat("Size", @ptrCast(&projection.size), 0.1, 100);
                },
            }
        }
        imgui.End();
    }
};

fn lockMouse(cam: *Camera, lock: bool, _: ?*anyopaque) void {
    cam.window.setRelativeMouseMode(lock);
}

fn translate(cam: *Camera, input: *hy.Input, event: ?*anyopaque) void {
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
