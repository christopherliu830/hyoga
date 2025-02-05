const std = @import("std");
const hy = @import("hyoga-lib");
const hym = hy.math;
pub const b2 = @import("box2d");

const Phys2 = @This();

pub const Body = b2.Body;
pub const HitEvent = extern struct {
    other: b2.Body,
    normal: hym.Vec2,
    point: hym.Vec2,

    comptime {
        hy.meta.assertMatches(HitEvent, hy.Phys2.HitEvent);
    }
};

comptime {
    hym.assertMetaEql(hym.Vec2, b2.Vec2);
}

const CallbackSet = std.AutoArrayHashMapUnmanaged(*hy.closure.Runnable(anyopaque), void);

allocator: std.mem.Allocator,
world: b2.World,
timestep: f32 = 1.0 / 60.0,
hit_callbacks: std.AutoHashMapUnmanaged(Body, CallbackSet) = .{},

/// accumulated time of simulation in ns since engine start.
current_time: u64 = 0,

sub_step_count: c_int = 4,

pub fn init(allocator: std.mem.Allocator) Phys2 {
    return .{
        .allocator = allocator,
        .world = .create(&.{
            .gravity = .zero,
        }),
    };
}

pub fn deinit(self: *Phys2) void {
    var it = self.hit_callbacks.valueIterator();
    while (it.next()) |cbs| {
        cbs.deinit(self.allocator);
    }
    self.hit_callbacks.deinit(self.allocator);
}

pub fn eventsReset(self: *Phys2) void {
    var it = self.hit_callbacks.valueIterator();
    while (it.next()) |cbs| {
        cbs.deinit(self.allocator);
    }
    self.hit_callbacks.deinit(self.allocator);
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

pub const AddShapeOptions = extern struct {
    type: ShapeUnion,
    density: f32,

    comptime {
        hy.meta.assertMatches(AddShapeOptions, hy.Phys2.Body.AddShapeOptions);
    }
};

pub const ShapeUnion = hy.runtime.ExternTaggedUnion(union(enum) {
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
    shape: AddShapeOptions,
    bullet: bool = false,
    user_data: ?*anyopaque = null,

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
            .is_bullet = opts.bullet,
            .user_data = opts.user_data,
        });
    };

    switch (opts.shape.type.revert()) {
        .circle => |c| {
            const circle: b2.Shape.Circle = .{
                .radius = c.radius,
                .center = @bitCast(c.center),
            };
            _ = b2.Shape.createCircleShape(body, &.{
                .density = opts.shape.density,
                .enable_hit_events = true,
            }, &circle);
            return body;
        },
        .box => |b| {
            const box: b2.Shape.Polygon = .makeBox(b.width, b.height);
            _ = b2.Shape.createPolygonShape(body, &.{
                .density = opts.shape.density,
                .enable_hit_events = true,
            }, &box);
        },
    }

    return body;
}

pub fn hitEventRegister(
    self: *Phys2,
    body: Body,
    cb: *hy.closure.Runnable(anyopaque),
) void {
    const result = self.hit_callbacks.getOrPut(self.allocator, body) catch hy.err.oom();
    if (!result.found_existing) {
        result.value_ptr.* = .empty;
    }
    const cbs = result.value_ptr;
    cbs.put(self.allocator, cb, {}) catch hy.err.oom();
}

pub fn hitEventDeregister(
    self: *Phys2,
    body: Body,
    cb: *hy.closure.Runnable(anyopaque),
) void {
    var cbs = self.hit_callbacks.get(body);
    if (cbs == null) {
        return;
    }
    _ = cbs.?.swapRemove(cb);
    if (cbs.?.count() == 0) {
        _ = self.hit_callbacks.remove(body);
    }
}

pub fn hitEventDeregisterAll(
    self: *Phys2,
    body: Body,
) void {
    var cbs = self.hit_callbacks.get(body);
    if (cbs == null) {
        return;
    }
    cbs.?.clearAndFree(self.allocator);
    _ = self.hit_callbacks.remove(body);
}

pub fn step(self: *Phys2) void {
    self.world.step(self.timestep, self.sub_step_count);
    self.current_time += @intFromFloat(self.timestep * std.time.ns_per_s);
    self.emitContacts();
}

pub fn emitContacts(self: *Phys2) void {
    const contact_events = self.world.GetContactEvents();
    const hit_events = contact_events.hit_events[0..@intCast(contact_events.hit_count)];

    for (hit_events) |hit| {
        const body_a = hit.shape_a.GetBody();
        const body_b = hit.shape_b.GetBody();

        if (self.hit_callbacks.get(body_a)) |cbs| {
            for (cbs.keys()) |cb| {
                const normal: hym.Vec2 = @bitCast(hit.normal);
                var hit_event: HitEvent = .{
                    .other = body_b,
                    .normal = normal.mul(-1),
                    .point = @bitCast(hit.point),
                };
                @call(.auto, cb.runFn, .{ cb, &hit_event });
            }
        }

        if (self.hit_callbacks.get(body_b)) |cbs| {
            for (cbs.keys()) |cb| {
                var hit_event: HitEvent = .{
                    .other = body_a,
                    .normal = @bitCast(hit.normal),
                    .point = @bitCast(hit.point),
                };
                @call(.auto, cb.runFn, .{ cb, &hit_event });
            }
        }
    }
}
