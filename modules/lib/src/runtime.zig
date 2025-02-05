//! All datatypes within this file are hand-written
//! and must be manually kept in sync with the runtime datatypes!

const std = @import("std");

pub const input = @import("runtime/input.zig");
pub const gpu = @import("runtime/gpu.zig");
pub const p2 = @import("runtime/phys2.zig");
pub const strint = @import("runtime/strint.zig");
pub const ui = @import("runtime/ui.zig");
pub const w = @import("runtime/window.zig");

pub const Input = input.Input;
pub const Gpu = gpu.Gpu;
pub const Phys2 = p2.Phys2;
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

    pub fn allocator(self: ExternAllocator) std.mem.Allocator {
        return .{
            .ptr = self.ptr,
            .vtable = self.vtable,
        };
    }
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

pub const IndexHandle = enum(u32) {
    invalid = std.math.maxInt(u32),
};

pub const ExternVTable = extern struct {
    alloc: *const fn (ctx: *anyopaque, len: usize, ptr_align: u8, ret_addr: usize) callconv(.C) ?[*]u8,
    resize: *const fn (ctx: *anyopaque, buf: []u8, buf_align: u8, new_len: usize, ret_addr: usize) callconv(.C) bool,
    free: *const fn (ctx: *anyopaque, buf: []u8, buf_align: u8, ret_addr: usize) callconv(.C) void,
};

pub fn ExternTaggedUnion(Base: type) type {
    const type_info = @typeInfo(Base).@"union";

    var tag_info = @typeInfo(type_info.tag_type.?);
    tag_info.@"enum".tag_type = u32; // Change backing integer to u32
    const BaseTag = @Type(tag_info);

    const Payload = @Type(.{ .@"union" = .{
        .layout = .@"extern",
        .tag_type = null,
        .fields = std.meta.fields(Base),
        .decls = &.{},
    } });

    return extern struct {
        tag: BaseTag,
        payload: Payload,

        pub fn revert(self: @This()) Base {
            switch (self.tag) {
                inline else => |real_tag| {
                    return @unionInit(Base, @tagName(real_tag), @field(self.payload, @tagName(real_tag)));
                },
            }
        }

        pub fn get(comptime tag: BaseTag, self: @This()) std.meta.TagPayloadByName(Base, @tagName(tag)) {
            const val = @unionInit(Base, @tagName(tag), @bitCast(self.payload));
            return @field(val, @tagName(tag));
        }

        pub fn of(comptime tag: BaseTag, value: std.meta.TagPayloadByName(Payload, @tagName(tag))) @This() {
            const payload = @unionInit(Payload, @tagName(tag), value);
            return .{
                .tag = tag,
                .payload = payload,
            };
        }
    };
}

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
    pub const p2 = hyePhys2;
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
extern fn hyePhys2(*Engine) *p2.Phys2;
extern fn hyeInput(*Engine) *input.Input;
extern fn hyeStrint(*Engine) *Strint;
extern fn hyeWindow(*Engine) *Window;
extern fn hyeUI(*Engine) *ui.UI;
