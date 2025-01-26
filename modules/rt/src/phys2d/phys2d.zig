const std = @import("std");
const hy = @import("hyoga-lib");
const hym = hy.math;
pub const b2 = @import("box2d");

const Phys2 = @This();

pub const Body = b2.Body;

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

pub const BodyAddOptions = extern struct {
    type: b2.Body.Type,
    position: hym.Vec2,

    comptime {
        hy.meta.assertMatches(BodyAddOptions, hy.Phys2.Body.AddOptions);
    }
};

pub fn addBody(self: *Phys2, opts: BodyAddOptions) b2.Body {
    const body: b2.Body = blk: {
        var def: b2.Body.Definition = .default;
        def.type = opts.type;
        def.position = @bitCast(opts.position);
        break :blk .create(self.world, &def);
    };

    const box: b2.Shape.Polygon = .makeBox(0.5, 0.5);
    var shape_def: b2.Shape.Definition = .default;
    shape_def.restitution = 1;
    _ = b2.Shape.createPolygonShape(body, &shape_def, &box);

    return body;
}

pub fn step(self: *Phys2) void {
    self.world.step(self.timestep, self.sub_step_count);
    self.current_time += @intFromFloat(self.timestep * std.time.ns_per_s);
}
