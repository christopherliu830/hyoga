const std = @import("std");
const hy = @import("hyoga-lib");
const hym = hy.math;
pub const b2 = @import("box2d");

const Phys2 = @This();

allocator: std.mem.Allocator,
world: b2.World,
timestep: f32 = 1.0 / 120.0,
interp_alpha: f32 = 1,
hit_callbacks: std.AutoHashMapUnmanaged(Body, CallbackSet) = .{},
prev_positions: std.AutoArrayHashMapUnmanaged(Body, hym.Vec2) = .{},

/// accumulated time of simulation in ns since engine start.
current_time: u64 = 0,

sub_step_count: c_int = 4,

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

pub const RaycastHit = struct {
    shape: b2.Shape,
    point: hym.Vec2,
    normal: hym.Vec2,
    fraction: f32,
};

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
    self.prev_positions.deinit(self.allocator);
}

pub fn eventsReset(self: *Phys2) void {
    var it = self.hit_callbacks.valueIterator();
    while (it.next()) |cbs| {
        cbs.deinit(self.allocator);
    }
    self.hit_callbacks.clearRetainingCapacity();
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
    type: ShapeConfig,
    density: f32,
    sensor: bool = false,
    filter: b2.Filter = .{},

    comptime {
        hy.meta.assertMatches(AddShapeOptions, hy.Phys2.Body.AddShapeOptions);
    }
};

pub const ShapeConfig = hy.ExternTaggedUnion(union(enum) {
    circle: extern struct {
        radius: f32,
        center: hym.Vec2,
    },
    box: extern struct {
        width: f32,
        height: f32,
        rot: f32,
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
                .is_sensor = opts.shape.sensor,
                .enable_hit_events = true,
                .filter = opts.shape.filter,
            }, &circle);
        },
        .box => |b| {
            const box: b2.Shape.Polygon = .makeBox(b.width, b.height);
            _ = b2.Shape.createPolygonShape(body, &.{
                .density = opts.shape.density,
                .enable_hit_events = true,
                .filter = opts.shape.filter,
            }, &box);
        },
    }

    self.prev_positions.put(self.allocator, body, @bitCast(body.getPosition())) catch hy.err.oom();
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
    var it = self.prev_positions.iterator();
    while (it.next()) |entry| {
        const body = entry.key_ptr;
        const position = entry.value_ptr;
        if (body.isValid()) {
            position.* = @bitCast(body.getPosition());
        } else {
            it.index -= 1;
            it.len -= 1;
            _ = self.prev_positions.swapRemoveAt(it.index);
        }
    }

    self.world.step(self.timestep, self.sub_step_count);
    self.current_time += @intFromFloat(self.timestep * std.time.ns_per_s);

    self.emitContacts();
    self.emitOverlaps();
}

/// Returns an interpolated body position between the last and
/// current physics step. If the most up to date physics position is needed,
/// use Body.position(). NOTE: Body.position() may return a result in the future
/// wrt the current game time.
pub fn bodyPosition(self: *Phys2, body: Body) hym.Vec2 {
    const old_pos = self.prev_positions.get(body);
    const new_pos = body.getPosition();
    if (old_pos) |old| {
        return old.lerp(@bitCast(new_pos), self.interp_alpha);
    }
    return @bitCast(body.getPosition());
}

pub fn bodyPositionSet(body: Body, pos: hym.Vec2) void {
    body.setTransform(@bitCast(pos), body.getRotation());
}

const OverlapContext = struct {
    arena: std.mem.Allocator,
    results: std.ArrayListUnmanaged(b2.Shape),
};

pub fn overlapLeaky(self: *Phys2, arena: std.mem.Allocator, shape: ShapeConfig, origin: hym.Vec2) []b2.Shape {
    var ctx: OverlapContext = .{ .arena = arena, .results = .empty };

    switch (shape.revert()) {
        .circle => |c| {
            const circle: b2.Shape.Circle = .{
                .radius = @bitCast(c.radius),
                .center = @bitCast(c.center),
            };
            const transform: b2.Transform = .{
                .p = @bitCast(origin),
                .q = .identity,
            };
            const filter: b2.QueryFilter = .{};
            _ = self.world.overlapCircle(&circle, transform, filter, overlapsCollect, &ctx);
        },
        .box => |b| {
            const box: b2.Shape.Polygon = .makeBox(b.width, b.height);
            const transform: b2.Transform = .{
                .p = @bitCast(origin),
                .q = b2.makeRot(b.rot),
            };
            const filter: b2.QueryFilter = .{};
            _ = self.world.overlapPolygon(&box, transform, filter, overlapsCollect, &ctx);
        },
    }

    return ctx.results.toOwnedSlice(arena) catch unreachable;
}

fn overlapsCollect(hit_shape: b2.Shape, ctx_ptr: ?*anyopaque) callconv(.C) bool {
    const ctx: *OverlapContext = @ptrCast(@alignCast(ctx_ptr));
    ctx.results.append(ctx.arena, hit_shape) catch return false;
    return true;
}

const RaycastContext = struct {
    arena: std.mem.Allocator,
    results: std.ArrayListUnmanaged(RaycastHit),
};

pub const RaycastOptions = extern struct {
    origin: hym.Vec2,
    direction: hym.Vec2,
    category: u64 = 1,
    mask: u64 = std.math.maxInt(u64),

    comptime {
        hy.meta.assertMatches(@This(), hy.Phys2.RaycastOptions);
    }
};

pub fn raycastLeaky(
    self: *Phys2,
    arena: std.mem.Allocator,
    opts: RaycastOptions,
) []RaycastHit {
    var ctx: RaycastContext = .{
        .arena = arena,
        .results = .empty,
    };

    _ = self.world.castRay(
        @bitCast(opts.origin),
        @bitCast(opts.direction),
        .{ .category = opts.category, .mask = opts.mask },
        raycastHitsCollect,
        @ptrCast(&ctx),
    );

    return ctx.results.toOwnedSlice(arena) catch unreachable;
}

fn raycastHitsCollect(shape: b2.Shape, point: b2.Vec2, normal: b2.Vec2, fraction: f32, ctx: ?*anyopaque) callconv(.C) f32 {
    const collector: *RaycastContext = @ptrCast(@alignCast(ctx));

    collector.results.append(collector.arena, .{
        .shape = shape,
        .point = @bitCast(point),
        .normal = @bitCast(normal),
        .fraction = fraction,
    }) catch return 0;

    return 1;
}

fn emitContacts(self: *Phys2) void {
    const contact_events = self.world.getContactEvents();
    const hit_events = contact_events.hit_events[0..@intCast(contact_events.hit_count)];

    for (hit_events) |hit| {
        const body_a = hit.shape_a.getBody();
        const body_b = hit.shape_b.getBody();

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
            const hit_event: HitEvent = .{
                .other = body_a,
                .normal = @bitCast(hit.normal),
                .point = @bitCast(hit.point),
            };
            for (cbs.keys()) |cb| {
                @call(.auto, cb.runFn, .{ cb, &hit_event });
            }
        }
    }
}

fn emitOverlaps(self: *Phys2) void {
    const sensor_events = self.world.getSensorEvents();

    for (sensor_events.begin_events[0..@intCast(sensor_events.begin_count)]) |ev| {
        const sensor_body = ev.sensor_shape.getBody();
        const dynamic_body = ev.visitor_shape.getBody();

        if (self.hit_callbacks.get(sensor_body)) |cbs| {
            const db_pos: hym.Vec2 = @bitCast(dynamic_body.getPosition());
            const s_pos: hym.Vec2 = @bitCast(sensor_body.getPosition());
            const normal = s_pos.sub(db_pos).normal();

            const hit_event: HitEvent = .{
                .other = dynamic_body,
                .normal = normal,
                .point = db_pos,
            };

            for (cbs.keys()) |cb| {
                // if (!dynamic_body.isValid() or !sensor_body.isValid()) { break :blk; }
                @call(.auto, cb.runFn, .{ cb, &hit_event });
            }
        }

        if (self.hit_callbacks.get(dynamic_body)) |cbs| {
            const db_pos: hym.Vec2 = @bitCast(dynamic_body.getPosition());
            const s_pos: hym.Vec2 = @bitCast(sensor_body.getPosition());
            const normal = db_pos.sub(s_pos).normal();

            const hit_event: HitEvent = .{
                .other = sensor_body,
                .normal = normal,
                .point = s_pos,
            };

            for (cbs.keys()) |cb| {
                // if (!dynamic_body.isValid() or !sensor_body.isValid()) break :blk;
                @call(.auto, cb.runFn, .{ cb, &hit_event });
            }
        }
    }
}
