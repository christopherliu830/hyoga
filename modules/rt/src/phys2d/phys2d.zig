const std = @import("std");
const hy = @import("hyoga-lib");
const hym = hy.math;
pub const b2 = @import("box2d");

const Phys2 = @This();

pub const Body = b2.Body;

comptime {
    hym.assertMetaEql(hym.Vec2, b2.Vec2);
}

world: b2.World,
timestep: f32 = 1.0 / 60.0,

/// accumulated time of simulation in ns since engine start.
current_time: u64 = 0,

sub_step_count: c_int = 4,

pub fn init() Phys2 {
    return .{
        .world = .create(&.default),
    };
}

pub const ShapeType = enum(u32) {
    circle,
    box,
    capsule,
    segment,
    polygon,
    chain_segment,
    count,
};

pub const ShapeOptions = hy.runtime.ExternTaggedUnion(union(enum) {
    circle: extern struct {
        radius: f32,
        center: hym.Vec2,
    },
    box: extern struct {
        width: f32,
        height: f32,
    },
});

pub const BodyAddOptions = extern struct {
    type: b2.Body.Type,
    position: hym.Vec2,
    velocity: hym.Vec2 = .zero,
    shape: ShapeOptions.Type,

    comptime {
        hy.meta.assertMatches(BodyAddOptions, hy.Phys2.Body.AddOptions);
    }
};

pub fn addBody(self: *Phys2, opts: BodyAddOptions) b2.Body {
    const body: b2.Body = blk: {
        break :blk .create(self.world, &.{
            .type = opts.type,
            .position = @bitCast(opts.position),
            .linear_velocity = @bitCast(opts.velocity),
        });
    };

    switch (ShapeOptions.revert(opts.shape)) {
        .circle => |c| {
            const circle: b2.Shape.Circle = .{
                .radius = c.radius,
                .center = @bitCast(c.center),
            };
            _ = b2.Shape.createCircleShape(body, &.{}, &circle);
            return body;
        },
        .box => |b| {
            const box: b2.Shape.Polygon = .makeBox(b.width, b.height);
            _ = b2.Shape.createPolygonShape(body, &.{}, &box);
        },
    }

    return body;
}

pub fn step(self: *Phys2) void {
    self.world.step(self.timestep, self.sub_step_count);
    self.current_time += @intFromFloat(self.timestep * std.time.ns_per_s);
}
