//! All datatypes within this file are hand-written
//! and must be manually kept in sync with the runtime datatypes!

const std = @import("std");
const hy = @import("root.zig");

pub const input = @import("runtime/input.zig");
pub const aud = @import("runtime/audio.zig");
pub const gfx = @import("runtime/gpu.zig");
pub const phys2 = @import("runtime/phys2.zig");
pub const strint = @import("runtime/strint.zig");
pub const ui = @import("runtime/ui.zig");
pub const w = @import("runtime/window.zig");

pub const Input = input.Input;
pub const Gpu = gfx.Gpu;
pub const Audio = aud;
pub const Phys2 = phys2.Phys2;
pub const Strint = strint;
pub const Window = w.Window;
pub const UI = ui.UI;

const math = @import("math/math.zig");
const key = @import("key.zig");
const closure = @import("closure.zig");

pub const Scene = extern struct {
    view: math.Mat4,
    proj: math.Mat4,
    light_dir: math.Vec3,
    camera_world_pos: math.Vec3,
};

pub const World = extern struct {
    quit: bool = false,
    restart: bool = false,
    scene: Scene,
    current_time: u64 = 0,
    interp_alpha: f32 = 0,
    render_delta_time: u64 = 0,
    update_delta_time: u64 = 0,
    memory: *anyopaque,
};

pub const IndexHandle = enum(u32) {
    invalid = std.math.maxInt(u32),
};

pub const GameInterface = extern struct {
    init: *const fn (*Engine) callconv(.c) World,
    shutdown: *const fn (*Engine, World) callconv(.c) void,
    update: *const fn (*Engine, World) callconv(.c) World,
    render: *const fn (*Engine, World) callconv(.c) void,
    afterRender: ?*const fn (*Engine, World) callconv(.c) void = null,
    reload: *const fn (*Engine, World) callconv(.c) bool,
};

pub const Engine = opaque {
    pub const shutdown = hyeShutdown;
    pub const update = hyeUpdate;
    pub const gameAllocator = hyeGameAllocator;
    pub const gpu = hyeGpu;
    pub const phys2 = hyePhys2;
    pub const input = hyeInput;
    pub const strint = hyeStrint;
    pub const ui = hyeUI;
    pub const window = hyeWindow;
};

pub const init = hyInit;

extern fn hyInit() *Engine;
extern fn hyeShutdown(*Engine) void;
extern fn hyeUpdate(*Engine, World, GameInterface) World;
extern fn hyeGameAllocator(*Engine) hy.ExternAllocator;
extern fn hyeGpu(*Engine) *gfx.Gpu;
extern fn hyePhys2(*Engine) *phys2.Phys2;
extern fn hyeInput(*Engine) *input.Input;
extern fn hyeStrint(*Engine) *Strint;
extern fn hyeWindow(*Engine) *Window;
extern fn hyeUI(*Engine) *ui.UI;
