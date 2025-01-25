//! All datatypes within this file are hand-written
//! and must be manually kept in sync with the runtime datatypes!

const std = @import("std");

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
    render_delta_time: u64 = 0,
    update_delta_time: u64 = 0,
    memory: *anyopaque,
};

pub const ExternAllocator = extern struct {
    ptr: *anyopaque,
    vtable: *const std.mem.Allocator.VTable,
};

pub fn ExternSlice(T: type) type {
    return extern struct {
        ptr: [*]T,
        len: usize,

        pub fn make(slice: []T) ExternSlice(T) {
            return .{ .ptr = slice.ptr, .len = slice.len };
        }

        pub fn asSlice(self: ExternSlice(T)) []T {
            return self.ptr[0..self.len];
        }

        pub fn asSliceZ(self: ExternSlice(T)) [:0]T {
            std.debug.assert(self.ptr[self.len] == 0);
            return self.ptr[0..self.len :0];
        }
    };
}

pub const SlotmapHandle = enum(u64) {
    invalid = 0,
};

pub const IndexHandle = enum(u32) {
    invalid = std.math.maxInt(u32),
};

pub const ExternVTable = extern struct {
    alloc: *const fn (ctx: *anyopaque, len: usize, ptr_align: u8, ret_addr: usize) callconv(.C) ?[*]u8,
    resize: *const fn (ctx: *anyopaque, buf: []u8, buf_align: u8, new_len: usize, ret_addr: usize) callconv(.C) bool,
    free: *const fn (ctx: *anyopaque, buf: []u8, buf_align: u8, ret_addr: usize) callconv(.C) void,
};

pub const GameInterface = extern struct {
    init: *const fn (*Engine) callconv(.C) World,
    shutdown: *const fn (*Engine, World) callconv(.C) void,
    update: *const fn (*Engine, World) callconv(.C) World,
    render: *const fn (*Engine, World) callconv(.C) void,
    afterRender: ?*const fn (*Engine, World) callconv(.C) void = null,
    reload: *const fn (*Engine, World) callconv(.C) bool,
};

pub const Engine = opaque {
    pub const shutdown = hyeShutdown;
    pub const update = hyeUpdate;
    pub const gameAllocator = hyeGameAllocator;
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
extern fn hyeGameAllocator(*Engine) ExternAllocator;
extern fn hyeGpu(*Engine) *gpu.Gpu;
extern fn hyeInput(*Engine) *input.Input;
extern fn hyeStrint(*Engine) *Strint;
extern fn hyeWindow(*Engine) *Window;
extern fn hyeUI(*Engine) *ui.UI;
