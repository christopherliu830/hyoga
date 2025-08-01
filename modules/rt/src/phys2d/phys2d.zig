const std = @import("std");
const hy = @import("hyoga-lib");
const hym = hy.math;
pub const b2 = @import("box2d");

const Phys2 = @This();
const gfx = @import("../graphics/root.zig");

allocator: std.mem.Allocator,
world: b2.World,
timestep: f32 = 1.0 / 120.0,
interp_alpha: f32 = 1,
hit_callbacks: std.AutoHashMapUnmanaged(Body, CallbackSet) = .{},
prev_positions: std.AutoArrayHashMapUnmanaged(Body, hym.Vec2) = .{},
gpu: *gfx.Gpu,

/// accumulated time of simulation in ns since engine start.
current_time: u64 = 0,

sub_step_count: c_int = 4,

pub const Body = b2.Body;

pub const HitEvent = extern struct {
    other: b2.Body,
    normal: hym.Vec2,
    point: hym.Vec2,

    comptime {
        hy.meta.assertMatches(HitEvent, hy.p2.HitEvent);
    }
};

comptime {
    hym.assertMetaEql(hym.Vec2, b2.Vec2);
}

const CallbackSet = std.AutoArrayHashMapUnmanaged(*hy.closure.Runnable(HitEvent), void);

pub const RaycastHit = struct {
    shape: b2.Shape,
    point: hym.Vec2,
    normal: hym.Vec2,
    fraction: f32,
};

pub fn init(allocator: std.mem.Allocator, gpu: *gfx.Gpu) Phys2 {
    return .{
        .allocator = allocator,
        .world = .create(&.{
            .gravity = .zero,
        }),
        .gpu = gpu,
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
        hy.meta.assertMatches(AddShapeOptions, hy.p2.Body.AddShapeOptions);
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
    polygon: extern struct {
        points: hy.ExternSliceConst(hym.Vec2),
    },
});

pub const ShapeExtra = hy.p2.ShapeExtra;

pub const BodyAddOptions = extern struct {
    type: b2.Body.Type,
    position: hym.Vec2,
    velocity: hym.Vec2 = .zero,
    shape: hy.ExternSliceConst(AddShapeOptions),
    bullet: bool = false,
    user_data: ?*anyopaque = null,

    comptime {
        hy.meta.assertMatches(BodyAddOptions, hy.p2.Body.AddOptions);
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

    for (opts.shape.asSlice()) |shape| {
        switch (shape.type.revert()) {
            .circle => |c| {
                const circle: b2.Shape.Circle = .{
                    .radius = c.radius,
                    .center = @bitCast(c.center),
                };

                _ = b2.Shape.createCircleShape(body, &.{
                    .density = shape.density,
                    .is_sensor = shape.sensor,
                    .enable_hit_events = true,
                    .filter = shape.filter,
                }, &circle);
            },
            .box => |b| {
                const box: b2.Shape.Polygon = .makeBox(b.width, b.height);
                _ = b2.Shape.createPolygonShape(body, &.{
                    .density = shape.density,
                    .enable_hit_events = true,
                    .filter = shape.filter,
                }, &box);
            },
            .polygon => |p| {
                const hull = b2.computeHull(@ptrCast(p.points.ptr), @intCast(p.points.len));
                const polygon = b2.makePolygon(&hull, 0);
                _ = b2.Shape.createPolygonShape(body, &.{
                    .density = shape.density,
                    .enable_hit_events = true,
                    .filter = shape.filter,
                }, &polygon);
            },
        }
    }

    self.prev_positions.put(self.allocator, body, @bitCast(body.getPosition())) catch hy.err.oom();
    return body;
}

pub fn hitEventRegister(
    self: *Phys2,
    body: Body,
    cb: *hy.closure.Runnable(HitEvent),
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
    cb: *hy.closure.Runnable(HitEvent),
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

pub fn shapeExtra(shape: b2.Shape) ShapeExtra {
    const shape_type = shape.getType();
    return blk: switch (shape_type) {
        .circle => {
            const extra = shape.getCircle();
            break :blk .of(.circle, .{
                .center = @bitCast(extra.center),
                .radius = @bitCast(extra.radius),
            });
        },
        .polygon => {
            const extra = shape.getPolygon();
            break :blk .of(.polygon, .{
                .vertices = @bitCast(extra.vertices),
                .normals = @bitCast(extra.normals),
                .centroid = @bitCast(extra.centroid),
                .radius = extra.radius,
                .count = @intCast(extra.count),
            });
        },
        else => unreachable,
    };
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
        .polygon => |p| {
            const transform: b2.Transform = .{
                .p = @bitCast(origin),
                .q = .identity,
            };
            const hull = b2.computeHull(@ptrCast(p.points.ptr), @intCast(p.points.len));
            const polygon = b2.makePolygon(&hull, 0);
            const filter: b2.QueryFilter = .{};
            _ = self.world.overlapPolygon(&polygon, transform, filter, overlapsCollect, &ctx);
        },
    }

    return ctx.results.toOwnedSlice(arena) catch unreachable;
}

fn overlapsCollect(hit_shape: b2.Shape, ctx_ptr: ?*anyopaque) callconv(.c) bool {
    const ctx: *OverlapContext = @ptrCast(@alignCast(ctx_ptr));
    ctx.results.append(ctx.arena, hit_shape) catch return false;
    return true;
}

const RaycastContext = struct {
    arena: std.mem.Allocator,
    results: std.ArrayListUnmanaged(RaycastHit),
    collection_type: RaycastOptions.CollectionType,
};

pub const RaycastOptions = extern struct {
    origin: hym.Vec2,
    direction: hym.Vec2,
    category: u64 = 1,
    mask: u64 = std.math.maxInt(u64),
    collection_type: CollectionType,

    pub const CollectionType = enum(u32) {
        all,
        first,
        closest,
    };

    comptime {
        hy.meta.assertMatches(@This(), hy.p2.RaycastOptions);
    }
};

pub fn raycastLeaky(
    self: *Phys2,
    arena: std.mem.Allocator,
    opts: RaycastOptions,
) []RaycastHit {
    var ctx: RaycastContext = .{
        .arena = arena,
        .collection_type = opts.collection_type,
        .results = .empty,
    };

    if (opts.collection_type == .closest) {
        const result = self.world.castRayClosest(
            @bitCast(opts.origin),
            @bitCast(opts.direction),
            .{ .category = opts.category, .mask = opts.mask },
        );

        if (result.hit) {
            ctx.results.append(arena, .{
                .shape = result.shape,
                .point = @bitCast(result.point),
                .normal = @bitCast(result.normal),
                .fraction = result.fraction,
            }) catch unreachable;
        }
    } else {
        _ = self.world.castRay(
            @bitCast(opts.origin),
            @bitCast(opts.direction),
            .{ .category = opts.category, .mask = opts.mask },
            raycastHitsCollect,
            @ptrCast(&ctx),
        );
    }

    return ctx.results.toOwnedSlice(arena) catch unreachable;
}

pub const CastCircleOptions = extern struct {
    circle: hy.p2.Circle,
    direction: hym.Vec2,
    category: u64 = 1,
    mask: u64 = std.math.maxInt(u64),
    collection_type: RaycastOptions.CollectionType,

    comptime {
        hy.meta.assertMatches(@This(), hy.p2.CastCircleOptions);
    }
};

pub fn castCircleLeaky(self: *Phys2, arena: std.mem.Allocator, opts: CastCircleOptions) []RaycastHit {
    var ctx: RaycastContext = .{
        .arena = arena,
        .collection_type = opts.collection_type,
        .results = .empty,
    };

    const transform: b2.Transform = .{
        .p = .{ .x = 0, .y = 0 },
        .q = b2.makeRot(0),
    };

    _ = self.world.castCircle(
        &.{ .center = @bitCast(opts.circle.center), .radius = @bitCast(opts.circle.radius) },
        transform,
        @bitCast(opts.direction),
        .{ .category = opts.category, .mask = opts.mask },
        raycastHitsCollect,
        &ctx,
    );
    return ctx.results.toOwnedSlice(arena) catch unreachable;
}

pub fn render(self: *Phys2) void {
    self.world.draw(&.{
        .drawSolidPolygon = debugDrawSolidPolygon,
        .drawSolidCircle = drawSolidCircle,
        .context = self,
        .draw_shapes = true,
    });
}

fn raycastHitsCollect(shape: b2.Shape, point: b2.Vec2, normal: b2.Vec2, fraction: f32, ctx: ?*anyopaque) callconv(.c) f32 {
    const collector: *RaycastContext = @ptrCast(@alignCast(ctx));

    collector.results.append(collector.arena, .{
        .shape = shape,
        .point = @bitCast(point),
        .normal = @bitCast(normal),
        .fraction = fraction,
    }) catch {
        std.log.err("Ran out of memory during raycastHitsCollect", .{});
        return 0;
    };

    return switch (collector.collection_type) {
        .first => 0,
        .closest => fraction,
        .all => 1,
    };
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

fn debugDrawSolidPolygon(transform: b2.Transform, vertices: [*]const b2.Vec2, vertex_count: c_int, radius: f32, hex_color: b2.HexColor, context: ?*anyopaque) callconv(.c) void {
    _ = radius;
    const len: u32 = @intCast(vertex_count);
    const p2: *Phys2 = @ptrCast(@alignCast(context));
    const arena = p2.gpu.arena.allocator();

    var verts = arena.alloc(gfx.Gpu.UIVertex, len + 1) catch unreachable;
    var indices = arena.alloc(u32, len * 3) catch unreachable;

    var min_x = vertices[0].x;
    var max_x = vertices[0].x;
    var min_y = vertices[0].y;
    var max_y = vertices[0].y;

    for (vertices[0..len], 0..) |v, i| {
        verts[i] = .{
            .pos = .{ v.x + transform.p.x, v.y + transform.p.y },
            .color = hy.Color.hex(@intCast(@intFromEnum(hex_color))).alphaSet(1).asf32x4Norm(),
        };
        min_x = @min(min_x, vertices[i].x);
        max_x = @max(max_x, vertices[i].x);
        min_y = @min(min_y, vertices[i].y);
        max_y = @max(max_y, vertices[i].y);

        indices[i * 3 + 0] = len; // center
        indices[i * 3 + 1] = @intCast(i); // vertex pos
        indices[i * 3 + 2] = @intCast((i + 1) % len); // next vertex
    }

    const center_x = (min_x + max_x) / 2 + transform.p.x;
    const center_y = (min_y + max_y) / 2 + transform.p.y;

    verts[len] = .{
        .pos = .{ center_x, center_y },
        .color = hy.Color.hex(@intCast(@intFromEnum(hex_color))).alphaSet(0).asf32x4Norm(),
    };

    const view_proj: hym.Mat4 = blk: {
        break :blk .{ .m = (p2.gpu.uniforms.get(p2.gpu.ids.view_projection) orelse break :blk .identity).mat4x4 };
    };
    p2.gpu.im.drawVerts(verts, indices, .{ .transform = view_proj });
}

fn drawPolygon(vertices: [*]const b2.Vec2, vertex_count: c_int, hex_color: b2.HexColor, context: ?*anyopaque) callconv(.c) void {
    _ = vertices; // autofix
    _ = vertex_count; // autofix
    _ = hex_color; // autofix
    _ = context; // autofix
}
fn drawCircle(center: b2.Vec2, radius: f32, color: b2.HexColor, context: ?*anyopaque) callconv(.c) void {
    _ = center; // autofix
    _ = radius; // autofix
    _ = color; // autofix
    _ = context; // autofix
}
fn drawSolidCircle(transform: b2.Transform, radius: f32, color: b2.HexColor, context: ?*anyopaque) callconv(.c) void {
    _ = transform; // autofix
    _ = radius; // autofix
    _ = color; // autofix
    _ = context; // autofix
}
fn drawSolidCapsule(p1: b2.Vec2, p2: b2.Vec2, radius: f32, color: b2.HexColor, context: ?*anyopaque) callconv(.c) void {
    _ = p1; // autofix
    _ = p2; // autofix
    _ = radius; // autofix
    _ = color; // autofix
    _ = context; // autofix
}
fn drawSegment(p1: b2.Vec2, p2: b2.Vec2, color: b2.HexColor, context: ?*anyopaque) callconv(.c) void {
    _ = p1; // autofix
    _ = p2; // autofix
    _ = color; // autofix
    _ = context; // autofix
}
fn drawTransform(transform: b2.Transform, context: ?*anyopaque) callconv(.c) void {
    _ = transform; // autofix
    _ = context; // autofix
}
fn drawPoint(p: b2.Vec2, size: f32, color: b2.HexColor, context: ?*anyopaque) callconv(.c) void {
    _ = p; // autofix
    _ = size; // autofix
    _ = color; // autofix
    _ = context; // autofix
}
fn drawString(p: b2.Vec2, s: [*]const u8, color: b2.HexColor, context: ?*anyopaque) callconv(.c) void {
    _ = p; // autofix
    _ = s; // autofix
    _ = color; // autofix
    _ = context; // autofix
}
