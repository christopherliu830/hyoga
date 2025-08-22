pub const audio = @import("audio.zig");
pub const c = @import("c");
pub const events = @import("events.zig");
pub const gpu = @import("gpu.zig");
pub const hints = @import("hints.zig");
pub const keyboard = @import("keyboard.zig");
pub const keycode = @import("keycode.zig");
pub const mouse = @import("mouse.zig");
pub const pixels = @import("pixels.zig");
pub const properties = @import("properties.zig");
pub const rect = @import("rect.zig");
pub const scancode = @import("scancode.zig");
pub const video = @import("video.zig");
pub const version = @import("version.zig").version;

const _init = @import("init.zig");

pub const Event = events.Event;
pub const Color = pixels.Color;
pub const FColor = pixels.FColor;
pub const FPoint = rect.FPoint;
pub const Rect = rect.Rect;
pub const Surface = video.Surface;

pub const PropertiesID = properties.PropertiesID;
pub const Window = video.Window;

pub const getError = SDL_GetError;
pub const log = SDL_Log;
pub const init = _init.init;
pub const quit = _init.quit;

pub fn free(ptr: ?*anyopaque) void {
    SDL_free(ptr);
}

extern fn SDL_GetError() [*:0]const u8;
extern fn SDL_Log(fmt: [*c]const u8, ...) void;
extern fn SDL_free(ptr: ?*anyopaque) void;
