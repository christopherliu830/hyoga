const std = @import("std");
const rt = @import("../runtime.zig");
const hym = @import("../math/math.zig");

pub const Phys2 = struct {
    pub const Body = enum(u64) {
        none = 0,

        pub const Type = enum(c_int) {
            static,
            kinematic,
            dynamic,
            count,
        };

        pub const AddOptions = extern struct {
            type: Type,
            position: hym.Vec2,
        };
    };

    pub const bodyAdd = hyp2BodyAdd;
    pub const bodyPosition = hyp2BodyGetPosition;

    extern fn hyp2BodyAdd(*Phys2, Body.AddOptions) Body;
    extern fn hyp2BodyGetPosition(*Phys2, Body) hym.Vec2;
};
