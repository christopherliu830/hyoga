const std = @import("std");
const rt = @import("../runtime.zig");
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
        };

        pub const position = hyp2BodyGetPosition;
        pub const velocity = hyp2BodyGetVelocity;
        pub const setVelocity = hyp2BodySetVelocity;

        extern fn hyp2BodyGetPosition(Body) hym.Vec2;
        extern fn hyp2BodyGetVelocity(Body) hym.Vec2;
        extern fn hyp2BodySetVelocity(Body, hym.Vec2) void;
    };

    pub const bodyAdd = hyp2BodyAdd;

    extern fn hyp2BodyAdd(*Phys2, Body.AddOptions) Body;
};
