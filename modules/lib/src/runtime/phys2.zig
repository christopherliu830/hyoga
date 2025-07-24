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

pub const ShapeOptions = hy.ExternTaggedUnion(union(enum) {
    circle: Circle,
    box: extern struct {
        width: f32,
        height: f32,
        rot: f32 = 0,
    },
    polygon: extern struct {
        points: hy.ExternSliceConst(hym.Vec2),
    },
});

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

    pub const AddShapeOptions = extern struct {
        type: ShapeOptions,
        density: f32 = 1,
        sensor: bool = false,
        filter: Filter = .{},
    };

    pub const AddOptions = extern struct {
        type: Type = .dynamic,
        position: hym.Vec2 = .zero,
        velocity: hym.Vec2 = .zero,
        shape: hy.ExternSliceConst(AddShapeOptions),
        bullet: bool = false,
        user_data: ?*anyopaque = null,
    };

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

pub const OverlapCallback = *const fn (Body, ?*anyopaque) callconv(.c) bool;

pub const World = struct {
    pub fn bodyAdd(world: *World, opts: Body.AddOptions) Body {
        return proc.hy_p2_bodyAdd(world, opts);
    }

    pub fn bodyPosition(world: *World, body: Body) hym.Vec2 {
        return proc.hy_p2_bodyPosition(world, body);
    }

    pub fn eventReset(world: *World) void {
        return proc.hy_p2_eventReset(world);
    }

    pub fn eventRegister(world: *World, body: Body, cb: *closure.Runnable(HitEvent)) void {
        proc.hy_p2_eventRegister(world, body, cb);
    }

    pub fn eventDeregister(world: *World, body: Body, cb: *closure.Runnable(HitEvent)) void {
        proc.hy_p2_eventDeregister(world, body, cb);
    }

    pub fn eventDeregisterAll(world: *World, body: Body) void {
        proc.hy_p2_eventDeregisterAll(world, body);
    }

    pub fn overlapLeaky(phys2: *World, arena: std.mem.Allocator, shape: ShapeOptions, origin: hym.Vec2) []Shape {
        return proc.hy_p2_overlapLeaky(phys2, .of(arena), shape, origin).asSlice();
    }

    pub fn raycastLeaky(phys2: *World, arena: std.mem.Allocator, opts: RaycastOptions) []RaycastHit {
        return proc.hy_p2_castRayLeaky(phys2, .of(arena), opts).asSlice();
    }

    pub fn castCircleLeaky(phys2: *World, arena: std.mem.Allocator, opts: CastCircleOptions) []RaycastHit {
        return proc.hy_p2_castCircleLeaky(phys2, .of(arena), opts).asSlice();
    }
};
