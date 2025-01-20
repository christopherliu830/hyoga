const std = @import("std");
const hy = @import("hyoga-lib");
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
    entity: Entity,
    move_delta: hym.Vec2,

    pub fn update(self: *Player) void {
        // self.entity.position = .add(self.entity.position, self.move_delta.append(0));
        self.entity.pushRender();
    }
};

pub fn createCube(gpu: *hy.Gpu) Entity {
    const cube = gpu.modelPrimitive(.cube);
    const renderable = gpu.addRenderable(.{ .model = cube });
    return .{ .gpu = gpu, .renderable = renderable, .bounds = gpu.modelBounds(cube) };
}

pub fn createPlayer(gpu: *hy.Gpu) Player {
    return .{
        .entity = createCube(gpu),
        .move_delta = .zero,
    };
}

/// Sets input_group on entity passed in.
pub fn playerRegisterInputs(player: *Player, input: *hy.Input, callback_arena: std.mem.Allocator) void {
    const group = input.getGroup(player.entity.input_group);

    if (player.entity.input_group == group) {
        return;
    }

    player.entity.input_group = group;
    const l: hy.closure.Builder = .{ .allocator = callback_arena };
    input.bind(group, .keyOn(.w, .{.down = true }), l.make(playerMove, .{player, hym.vec(.{0, 1})})); 
    input.bind(group, .keyOn(.a, .{.down = true }), l.make(playerMove, .{player, hym.vec(.{-1, 0})})); 
    input.bind(group, .keyOn(.s, .{.down = true }), l.make(playerMove, .{player, hym.vec(.{0, -1})})); 
    input.bind(group, .keyOn(.d, .{.down = true}), l.make(playerMove, .{player, hym.vec(.{1, 0})})); 
}

fn playerMove(player: *Player, delta: hym.Vec2, _: ?*anyopaque) void {
    player.move_delta = delta;
}
