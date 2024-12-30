//! All datatypes within this file are hand-written
//! and must be manually kept in sync with the runtime datatypes!

pub const input = @import("runtime/input.zig");
pub const gpu = @import("runtime/gpu.zig");
pub const strint = @import("runtime/strint.zig");
pub const ui = @import("runtime/ui.zig");
pub const w = @import("runtime/window.zig");

pub const Input = input.Input;
pub const Gpu = gpu.Gpu;
pub const Strint = strint;
pub const Window = w.Window;
pub const UI = ui;

const math = @import("math/hym.zig");
const key = @import("key.zig");
const closure = @import("closure.zig");

pub const Scene = extern struct {
    view_proj: math.Mat4,
    light_dir: math.Vec3,
    camera_world_pos: math.Vec3,
};

pub const World = extern struct {
    quit: bool = false,
    restart: bool = false,
    scene: Scene,
    frame_time: u64 = 0,
    memory: *anyopaque,
};

pub const GameInterface = extern struct {
    init: *const fn(*Engine) callconv(.C) World,
    shutdown: *const fn(*Engine, World) callconv(.C) void,
    update: *const fn (*Engine, World) callconv(.C) World,
    render: *const fn (*Engine, World) callconv(.C) void,
    reload: *const fn (*Engine, World) callconv (.C) bool,
};

pub const Engine = opaque {
    pub const shutdown = hyeShutdown;
    pub const update = hyeUpdate;
    pub const gpu = hyeGpu;
    pub const input = hyeInput;
    pub const strint = hyeStrint;
    pub const ui = hyeUI;
    pub const window = hyeWindow;
};

pub const init = hyInit;

extern fn hyInit() *Engine;
extern fn hyeShutdown(*Engine) void;
extern fn hyeUpdate(*Engine, World, GameInterface) World;
extern fn hyeGpu(*Engine) *gpu.Gpu;
extern fn hyeInput(*Engine) *input.Input;
extern fn hyeStrint(*Engine) *Strint;
extern fn hyeWindow(*Engine) *Window;
extern fn hyeUI(*Engine) *ui.UI;
