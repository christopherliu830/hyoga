//! All datatypes within this file are hand-written
//! and must be manually kept in sync with the runtime datatypes!

const std = @import("std");
const hy = @import("root.zig");

pub const input = @import("runtime/input.zig");
pub const aud = @import("runtime/audio.zig");
pub const gfx = @import("runtime/gpu.zig");
pub const p2 = @import("runtime/phys2.zig");
pub const strint = @import("runtime/strint.zig");
pub const ui = @import("runtime/ui.zig");
pub const w = @import("runtime/window.zig");

pub const Input = input.Input;
pub const Gpu = gfx.Gpu;
pub const Audio = aud;
pub const Phys2 = p2.World;
pub const Strint = strint;
pub const Window = w.Window;
pub const UI = ui.UI;
pub const ProcTable = proc_table.ProcTable;

const runtime = @This();
const math = @import("math/math.zig");
const proc_table = @import("runtime/proc_table.zig");
const proc = &proc_table.table;
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
    procs: *const fn (proc_table.ProcTable) callconv(.c) void,
    shutdown: *const fn (*Engine, World) callconv(.c) void,
    update: *const fn (*Engine, World) callconv(.c) World,
    render: *const fn (*Engine, World) callconv(.c) void,
    afterRender: ?*const fn (*Engine, World) callconv(.c) void = null,
    reload: *const fn (*Engine, World) callconv(.c) bool,
};

pub const Engine = opaque {
    pub fn gameAllocator(engine: *Engine) std.mem.Allocator {
        return proc.hy_engine_gameAllocator(engine).allocator();
    }

    pub fn gpu(engine: *Engine) *gfx.Gpu {
        return proc.hy_engine_gpu(engine);
    }

    pub fn p2(engine: *Engine) *runtime.p2.World {
        return proc.hy_engine_phys2(engine);
    }

    pub fn input(engine: *Engine, T: type) Input(T) {
        return .{ .ctx = proc.hy_engine_input(engine) };
    }

    pub fn window(engine: *Engine) *Window {
        return proc.hy_engine_window(engine);
    }

    pub fn ui(engine: *Engine) *runtime.ui.UI {
        return proc.hy_engine_ui(engine);
    }
};

pub fn init(table: proc_table.ProcTable) void {
    proc_table.load(table);
}
