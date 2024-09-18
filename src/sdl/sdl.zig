pub const c = @import("c.zig");

pub const events = @import("events.zig");

pub const gpu = @import("gpu.zig");

pub const keycode = @import("keycode.zig");

pub const video = @import("video.zig");

pub const PropertiesID = u32;

pub const FColor = extern struct { r: f32 = 0, g: f32 = 0, b: f32 = 0, a: f32 = 0 };

pub const Rect = extern struct {
    x: i32,
    y: i32,
    w: i32,
    h: i32,
};

pub const Window = video.Window;

extern fn SDL_GetError() [*:0]const u8;
pub const getError = SDL_GetError;
