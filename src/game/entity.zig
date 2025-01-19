const std = @import("std");
const hy = @import("hyoga-lib");
const hym = hy.math;

const Mat4 = hym.Mat4;

pub const Transform = struct {};

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

pub fn createCube(gpu: *hy.Gpu) Entity {
    const cube = gpu.modelPrimitive(.cube);
    const renderable = gpu.addRenderable(.{ .model = cube });
    return .{ .gpu = gpu, .renderable = renderable };
}

pub fn createPlayer(gpu: *hy.Gpu) Entity {
    const cube_entity = createCube(gpu);
    return cube_entity;
}

pub fn registerInputs(player: Entity, input: *hy.Input) void {
    const group = input.getGroup(player.input_group);

    if (player.input_group == group) {
        return;
    }

    player.input_group = group;
}
