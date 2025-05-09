const std = @import("std");
const rt = @import("../runtime.zig");
const closure = @import("../closure.zig");
const hym = @import("../math/math.zig");

pub const Phys2 = struct {
    pub const ShapeOptions = rt.ExternTaggedUnion(union(enum) {
        circle: extern struct {
            radius: f32,
            center: hym.Vec2,
        },
        box: extern struct {
            width: f32,
            height: f32,
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

        pub const ShapeType = enum(u32) {
            circle,
            box,
            capsule,
            segment,
            polygon,
            chain_segment,
            count,
        };

        pub const Filter = extern struct {
            category_bits: u64 = 1,
            mask_bits: u64 = std.math.maxInt(u64),
            group_index: i32 = 0,
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
            shape: AddShapeOptions,
            bullet: bool = false,
            user_data: ?*anyopaque = null,
        };

        pub const velocity = hyp2BodyGetVelocity;
        pub const userData = hyp2BodyUserData;
        pub const setVelocity = hyp2BodySetVelocity;
        pub const destroy = hyp2BodyDestroy;
        pub const position = hyp2BodyRealPosition;
        pub const getType = hyp2BodyGetType;
        pub const setType = hyp2BodySetType;

        extern fn hyp2BodyGetType(Body) Type;
        extern fn hyp2BodySetType(Body, Type) void;
        extern fn hyp2BodyGetVelocity(Body) hym.Vec2;
        extern fn hyp2BodySetVelocity(Body, hym.Vec2) void;
        extern fn hyp2BodyUserData(Body) ?*anyopaque;
        extern fn hyp2BodyDestroy(Body) void;
        extern fn hyp2BodyRealPosition(Body) hym.Vec2;
    };

    pub const Shape = packed struct(u64) { _padding: u64 };

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
    };

    pub const OverlapCallback = *const fn (Body, ?*anyopaque) callconv(.C) bool;

    pub const bodyAdd = hyp2BodyAdd;
    pub const bodyPosition = hyp2BodyGetPosition;
    pub const eventsReset = hyp2EventsReset;
    pub const hitEventRegister = hyp2HitEventRegister;
    pub const hitEventDeregister = hyp2HitEventDeregister;
    pub const hitEventDeregisterAll = hyp2HitEventDeregisterAll;
    pub const overlap = hyp2Overlap;
    pub fn raycast(phys2: *Phys2, arena: std.mem.Allocator, opts: RaycastOptions) []RaycastHit {
        return hyp2Raycast(phys2, .of(arena), opts).asSlice();
    }

    extern fn hyp2BodyAdd(*Phys2, Body.AddOptions) Body;
    extern fn hyp2BodyGetPosition(*Phys2, Body) hym.Vec2;
    extern fn hyp2EventsReset(*Phys2) void;
    extern fn hyp2HitEventRegister(*Phys2, Body, *closure.Runnable(HitEvent)) void;
    extern fn hyp2HitEventDeregister(*Phys2, Body, *closure.Runnable(HitEvent)) void;
    extern fn hyp2HitEventDeregisterAll(*Phys2, Body) void;
    extern fn hyp2Overlap(*Phys2, ShapeOptions, hym.Vec2, OverlapCallback, ?*anyopaque) void;

    extern fn hyp2Raycast(phys2: *Phys2, arena: rt.ExternAllocator, opts: RaycastOptions) rt.ExternSlice(RaycastHit);
};
