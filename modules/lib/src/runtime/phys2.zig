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

        pub const AddOptions = extern struct {
            type: Type = .dynamic,
            position: hym.Vec2 = .zero,
            velocity: hym.Vec2 = .zero,
            shape: ShapeOptions.Type,
            bullet: bool = false,
        };

        pub const position = hyp2BodyGetPosition;
        pub const velocity = hyp2BodyGetVelocity;
        pub const setVelocity = hyp2BodySetVelocity;
        pub const destroy = hyp2BodyDestroy;

        extern fn hyp2BodyGetPosition(Body) hym.Vec2;
        extern fn hyp2BodyGetVelocity(Body) hym.Vec2;
        extern fn hyp2BodySetVelocity(Body, hym.Vec2) void;
        extern fn hyp2BodyDestroy(Body) void;
    };

    pub const HitEvent = struct {
        other: Body,
        normal: hym.Vec2,
        point: hym.Vec2,
    };

    pub const bodyAdd = hyp2BodyAdd;
    pub const eventsReset = hyp2EventsReset;
    pub const hitEventRegister = hyp2HitEventRegister;

    extern fn hyp2BodyAdd(*Phys2, Body.AddOptions) Body;
    extern fn hyp2EventsReset(*Phys2) void;
    extern fn hyp2HitEventRegister(*Phys2, Body, *closure.Runnable) void;
};
