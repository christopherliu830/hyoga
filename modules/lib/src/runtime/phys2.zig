const std = @import("std");
const hy = @import("../root.zig");
const hym = hy.math;
const closure = @import("../closure.zig");

const proc = &@import("proc_table.zig").table;

pub const Transform = extern struct {
    p: hym.Vec2 = .zero,
    q: hym.Vec2 = .zero,
};

pub const Circle = extern struct {
    radius: f32,
    center: hym.Vec2,
};

pub const Polygon = extern struct {
    pub const max_vertices = 8;
    vertices: [max_vertices]hym.Vec2,
    normals: [max_vertices]hym.Vec2,
    centroid: hym.Vec2,
    radius: f32,
    count: u32,
};

pub const ShapeConfig = union(enum) {
    circle: Circle,
    box: Box,
    polygon: []const hym.Vec2,

    pub const Box = struct {
        width: f32,
        height: f32,
        rot: f32 = 0,
    };
};

pub const Body = enum(u64) {
    none = 0,
    _,

    pub const Type = enum(c_int) {
        static,
        kinematic,
        dynamic,
        count,
    };

    pub const Filter = extern struct {
        category_bits: u64 = 1,
        mask_bits: u64 = std.math.maxInt(u64),
        group_index: i32 = 0,

        pub fn category(bits: u64) Filter {
            return .{ .category_bits = bits };
        }
    };

    pub fn shapeAdd(body: Body, opts: BodyAddOptions.ShapeOptions) void {
        proc.hy_p2_bodyShapeAdd(body, opts);
    }

    pub fn destroy(body: Body) void {
        return proc.hy_p2_bodyDestroy(body);
    }

    pub fn velocity(body: Body) hym.Vec2 {
        return proc.hy_p2_bodyVelocity(body);
    }

    pub fn velocitySet(body: Body, v: hym.Vec2) void {
        return proc.hy_p2_bodyVelocitySet(body, v);
    }

    pub fn bodyType(body: Body) Type {
        return proc.hy_p2_bodyType(body);
    }

    pub fn bodyTypeSet(body: Body, body_type: Type) void {
        return proc.hy_p2_bodyTypeSet(body, body_type);
    }

    pub fn position(body: Body) hym.Vec2 {
        return proc.hy_p2_bodyPositionReal(body);
    }

    pub fn positionSet(body: Body, pos: hym.Vec2) void {
        return proc.hy_p2_bodyPositionSet(body, pos);
    }

    pub fn userData(body: Body) ?*anyopaque {
        return proc.hy_p2_bodyUserData(body);
    }

    pub fn userDataSet(body: Body, user_data: ?*anyopaque) void {
        return proc.hy_p2_bodyUserDataSet(body, user_data);
    }
};

pub const Shape = packed struct(u64) {
    _reserved: u64,

    pub fn body(shape: Shape) Body {
        return proc.hy_p2_shapeBody(shape);
    }
    pub fn extra(shape: Shape) ShapeExtra {
        return proc.hy_p2_shapeExtra(shape);
    }
};

pub const ShapeType = enum(u32) {
    circle,
    capsule,
    segment,
    polygon,
    chain_segment,
    count,
};

pub const ShapeExtra = hy.ExternTaggedUnion(union(ShapeType) {
    circle: Circle,
    capsule: void,
    segment: void,
    polygon: Polygon,
    chain_segment: void,
    count: void,
});

pub const HitEvent = struct {
    other: Body,
    normal: hym.Vec2,
    point: hym.Vec2,
};

pub const RaycastHit = struct {
    shape: Shape,
    point: hym.Vec2,
    normal: hym.Vec2,
    fraction: f32,
};

pub const RaycastOptions = extern struct {
    origin: hym.Vec2,
    direction: hym.Vec2,
    category: u64 = 1,
    mask: u64 = std.math.maxInt(u64),
    collection_type: CollectionType,

    pub const CollectionType = enum(u32) { all, first, closest };
};

pub const CastCircleOptions = extern struct {
    circle: Circle,
    direction: hym.Vec2,
    category: u64 = 1,
    mask: u64 = std.math.maxInt(u64),
    collection_type: RaycastOptions.CollectionType,
};

pub const Event = extern struct {
    body: Body,
    other: Body,
    point: hym.Vec2,
    normal: hym.Vec2,
};

pub const OverlapCallback = *const fn (Body, ?*anyopaque) callconv(.c) bool;

pub const BodyAddOptions = struct {
    type: Body.Type = .dynamic,
    position: hym.Vec2 = .zero,
    velocity: hym.Vec2 = .zero,
    shapes: []const ShapeOptions,
    bullet: bool = false,
    user_data: ?*anyopaque = null,

    pub const ShapeOptions = struct {
        config: ShapeConfig,
        density: f32 = 1,
        sensor: bool = false,
        filter: Body.Filter = .{},
    };
};

pub const Context = struct {
    pub fn reset(ctx: *Context) void {
        proc.hy_p2_reset(ctx);
    }

    pub fn bodyAdd(ctx: *Context, opts: *const BodyAddOptions) Body {
        return proc.hy_p2_bodyAdd(ctx, opts);
    }

    pub fn bodyPosition(world: *Context, body: Body) hym.Vec2 {
        return proc.hy_p2_bodyPosition(world, body);
    }

    pub fn eventPump(world: *Context, buffer: []u8) []align(1) Event {
        const len = proc.hy_p2_eventPump(world, .from(buffer));
        return @ptrCast(buffer[0..len]);
    }

    pub fn overlapLeaky(phys2: *Context, arena: std.mem.Allocator, shape: *const ShapeConfig, origin: hym.Vec2) []Shape {
        return proc.hy_p2_overlapLeaky(phys2, .of(arena), shape, origin).asSlice();
    }

    pub fn raycastLeaky(phys2: *Context, arena: std.mem.Allocator, opts: RaycastOptions) []RaycastHit {
        return proc.hy_p2_castRayLeaky(phys2, .of(arena), opts).asSlice();
    }

    pub fn castCircleLeaky(phys2: *Context, arena: std.mem.Allocator, opts: CastCircleOptions) []RaycastHit {
        return proc.hy_p2_castCircleLeaky(phys2, .of(arena), opts).asSlice();
    }
};
