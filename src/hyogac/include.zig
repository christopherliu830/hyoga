const hym = @import("hyoga-math");

// pub const Hive = hy.Hive;

pub const Engine = opaque {
    pub const shutdown = hyShutdown;
    pub const update = hyUpdate;
};

pub const Scene = extern struct {
    view_proj: hym.mat4.Mat4,
    light_dir: hym.vec3.Vec3,
};

pub const Game = extern struct {
    quit: bool = false,
    restart: bool = false,
    scene: Scene,
    frame_time: u64 = 0,
    memory: *anyopaque,
};

pub const GameInterface = extern struct {
    init: *const fn(*Engine) callconv(.C) Game,
    shutdown: *const fn(*Engine, Game) callconv(.C) void,
    update: *const fn (*Engine, Game) callconv(.C) Game,
    render: *const fn (*Engine, Game) callconv(.C) void,
    reload: *const fn (*Engine, Game) callconv (.C) bool,
};

pub const init = hyInit;

extern fn hyInit() *Engine;
extern fn hyShutdown(*Engine) void;
extern fn hyUpdate(*Engine, Game, GameInterface) Game;