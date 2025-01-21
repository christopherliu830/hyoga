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
    moveable: Moveable = .{},
    input_group: hy.Input.Group = .none,
    velocity: hym.Vec3 = .zero,
    acceleration: f32 = 0,
    deceleration: f32 = 0,
    max_speed: f32 = 2,

    pub fn default(entity: *Entity) Player {
        return .{
            .entity = entity,
            .moveable = .{},
            .acceleration = 145,
            .deceleration = 50,
            .max_speed = 8,
        };
    }

    pub fn update(self: *Player, delta_time: f32) void {
        const accel = self.acceleration * delta_time;
        const decel = self.deceleration * delta_time;

        const move = self.moveable.heading.mul(accel);

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
        const group = input.getGroup(player.input_group);
        if (player.input_group == group) {
            return;
        }
        player.input_group = group;

        const bindings: []const Moveable.Binding = &.{
            .{ .py = .w },
            .{ .ny = .s },
            .{ .px = .d },
            .{ .nx = .a },
        };

        player.moveable.registerInputs(input, group, bindings, callback_arena);
    }

    pub fn inspector(self: *Player, _: ?*ui.State) void {
        _ = imgui.DragFloat3("Position", @ptrCast(&self.entity.position));
        _ = imgui.DragFloat2("Heading", @ptrCast(&self.moveable.heading));
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

pub const Moveable = struct {
    heading: hym.Vec3 = .zero,

    pub const Axis = enum { px, py, pz, nx, ny, nz };

    pub const Binding = union(Axis) {
        px: hy.key.Keycode,
        py: hy.key.Keycode,
        pz: hy.key.Keycode,
        nx: hy.key.Keycode,
        ny: hy.key.Keycode,
        nz: hy.key.Keycode,
    };

    pub fn registerInputs(self: *Moveable, input: *hy.Input, group: hy.Input.Group, bindings: []const Binding, arena: std.mem.Allocator) void {
        const l: hy.closure.Builder = .{ .allocator = arena };
        for (bindings) |binding| {
            switch (binding) {
                .px => |key| {
                    input.bind(group, .key(key), l.make(move, .{ self, Axis.px }));
                    input.bind(group, .keyUp(key), l.make(move, .{ self, Axis.nx }));
                },
                .py => |key| {
                    input.bind(group, .key(key), l.make(move, .{ self, Axis.py }));
                    input.bind(group, .keyUp(key), l.make(move, .{ self, Axis.ny }));
                },
                .pz => |key| {
                    input.bind(group, .key(key), l.make(move, .{ self, Axis.pz }));
                    input.bind(group, .keyUp(key), l.make(move, .{ self, Axis.nz }));
                },
                .nx => |key| {
                    input.bind(group, .key(key), l.make(move, .{ self, Axis.nx }));
                    input.bind(group, .keyUp(key), l.make(move, .{ self, Axis.px }));
                },
                .ny => |key| {
                    input.bind(group, .key(key), l.make(move, .{ self, Axis.ny }));
                    input.bind(group, .keyUp(key), l.make(move, .{ self, Axis.py }));
                },
                .nz => |key| {
                    input.bind(group, .key(key), l.make(move, .{ self, Axis.nz }));
                    input.bind(group, .keyUp(key), l.make(move, .{ self, Axis.pz }));
                },
            }
        }
    }

    fn move(self: *Moveable, axis: Axis, _: ?*anyopaque) void {
        const md = &self.heading;
        switch (axis) {
            .px => md.* = md.add(hym.vec3.px),
            .py => md.* = md.add(hym.vec3.py),
            .pz => md.* = md.add(hym.vec3.pz),
            .nx => md.* = md.add(hym.vec3.nx),
            .ny => md.* = md.add(hym.vec3.ny),
            .nz => md.* = md.add(hym.vec3.nz),
        }

        // Clamp heading to [-1, 1] in each axis.
        md.v = @min(hym.vec3.one.v, @max(hym.vec3.one.mul(-1).v, md.v));
    }
};
