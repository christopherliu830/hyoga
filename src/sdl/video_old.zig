const c = @import("c.zig");
pub const Id = u32;

pub const Window = c.SDL_Window;

extern fn SDL_GetCurrentVideoDriver() [*:0]const u8;
pub const getCurrentVideoDriver = SDL_GetCurrentVideoDriver;

extern fn SDL_GetWindowID(window: Window) Id;
pub const getWindowId = SDL_GetWindowID;

const PixelFormat = @import("pixels.zig").PixelFormat;
const Rect = @import("rect.zig").Rect;
const PropertiesID = @import("properties.zig").PropertiesID;
const Surface = @import("surface.zig").Surface;