pub const c = @import("c.zig");
pub const events = @import("events.zig");
pub const gpu = @import("gpu.zig");
pub const hints = @import("hints.zig");
pub const keycode = @import("keycode.zig");
pub const mouse = @import("mouse.zig");
pub const rect = @import("rect.zig");
pub const scancode = @import("scancode.zig");
pub const video = @import("video.zig");

pub const Window = video.Window;

extern fn SDL_GetError() [*:0]const u8;
pub const getError = SDL_GetError;
