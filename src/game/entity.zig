const std = @import("std");
const hy = @import("hyoga-lib");
const imgui = @import("imgui");
const ui = @import("ui.zig");
const hym = hy.math;

const Mat4 = hym.Mat4;

pub const Entity = struct {
    gpu: *hy.Gpu,
    renderable: hy.gpu.RenderItemHandle = .invalid,
    input_group: hy.Input.Group = .none,
    position: hym.Vec3 = .zero,
    rotation: hym.Vec3 = .zero,
    scale: hym.Vec3 = .one,
    bounds: hym.AxisAligned = .{},

    pub fn pushRender(self: *Entity) void {
        const mat = Mat4.identity
            .scale(self.scale)
            .rotate(self.rotation.x(), hym.vec3.x)
            .rotate(self.rotation.y(), hym.vec3.y)
            .rotate(self.rotation.z(), hym.vec3.z)
            .translate(self.position);
        self.gpu.renderableSetTransform(self.renderable, mat);
    }

    pub fn calcBounds(self: *Entity) hym.AxisAligned {
        const scaled_min = self.bounds.min.mul(self.scale);
        const scaled_max = self.bounds.max.mul(self.scale);

        return .{
            .min = scaled_min.add(self.position),
            .max = scaled_max.add(self.position),
        };
    }
};

pub const Player = struct {
    entity: *Entity,
    velocity: hym.Vec3 = .zero,
    move_delta: hym.Vec2 = .zero,
    acceleration: f32 = 0,
    deceleration: f32 = 0,
    max_speed: f32 = 2,

    pub fn default(entity: *Entity) Player {
        return .{
            .entity = entity,
            .acceleration = 145,
            .deceleration = 50,
            .max_speed = 8,
        };
    }

    pub fn update(self: *Player, delta_time: f32) void {
        const accel = self.acceleration * delta_time;
        const decel = self.deceleration * delta_time;

        const move = self.move_delta.mul(accel).append(0);

        const vel = &self.velocity;

        vel.* = vel.add(move);
        const dir = vel.normal();

        if (vel.sqlen() > decel * decel) {
            vel.* = vel.sub(dir.mul(decel));
        }

        if (vel.sqlen() > self.max_speed * self.max_speed) {
            vel.* = vel.normal().mul(self.max_speed);
        }

        self.entity.position = self.entity.position.add(vel.mul(delta_time));
        self.entity.pushRender();
    }

    /// Sets input_group on entity passed in.
    pub fn registerInputs(player: *Player, input: *hy.Input, callback_arena: std.mem.Allocator) void {
        const group = input.getGroup(player.entity.input_group);

        if (player.entity.input_group == group) {
            return;
        }

        player.entity.input_group = group;
        const l: hy.closure.Builder = .{ .allocator = callback_arena };
        input.bind(group, .key(.w), l.make(playerMove, .{ player, Axis.py }));
        input.bind(group, .key(.a), l.make(playerMove, .{ player, Axis.nx }));
        input.bind(group, .key(.s), l.make(playerMove, .{ player, Axis.ny }));
        input.bind(group, .key(.d), l.make(playerMove, .{ player, Axis.px }));

        input.bind(group, .keyUp(.w), l.make(playerMove, .{ player, Axis.ny }));
        input.bind(group, .keyUp(.a), l.make(playerMove, .{ player, Axis.px }));
        input.bind(group, .keyUp(.s), l.make(playerMove, .{ player, Axis.py }));
        input.bind(group, .keyUp(.d), l.make(playerMove, .{ player, Axis.nx }));
    }

    pub fn inspector(self: *Player, _: ?*ui.State) void {
        _ = imgui.DragFloat3("Position", @ptrCast(&self.entity.position));
        _ = imgui.DragFloat2("Heading", @ptrCast(&self.move_delta));
        _ = imgui.DragFloat("Acceleration", @ptrCast(&self.acceleration));
        _ = imgui.DragFloat("Deceleration", @ptrCast(&self.deceleration));
        _ = imgui.DragFloat("Max Speed", @ptrCast(&self.max_speed));
        _ = imgui.DragFloat3("Velocity", @ptrCast(&self.velocity));
    }
};

pub fn createCube(gpu: *hy.Gpu) Entity {
    const cube = gpu.modelPrimitive(.cube);
    const renderable = gpu.addRenderable(.{ .model = cube });
    return .{ .gpu = gpu, .renderable = renderable, .bounds = gpu.modelBounds(cube) };
}

const Axis = enum { px, py, nx, ny };

fn playerMove(player: *Player, axis: Axis, _: ?*anyopaque) void {
    const md = &player.move_delta;
    switch (axis) {
        .px => md.* = md.add(hym.vec2.px),
        .py => md.* = md.add(hym.vec2.py),
        .nx => md.* = md.add(hym.vec2.nx),
        .ny => md.* = md.add(hym.vec2.ny),
    }
    md.v = @min(hym.vec2.one.v, @max(hym.vec2.one.mul(-1).v, md.v));
}
