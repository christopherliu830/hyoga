const std = @import("std");
const sdl = @import("sdl.zig");
const PixelFormat = @import("pixels.zig").PixelFormat;
const Rect = @import("rect.zig").Rect;
const PropertiesID = @import("properties.zig").PropertiesID;
const Surface = @import("surface.zig").Surface;
const FunctionPointer = fn (*anyopaque) void;

const GLContext = unreachable;
const EGLDisplay = unreachable;
const EGLSurface = unreachable;
const EGLConfig = unreachable;
const EGLAttrib = unreachable;
const EGLint = unreachable;

const Point = extern struct { x: i32, y: i32 };

//pub const SDL_DisplayID = Uint32;
pub const DisplayID = u32;
//pub const SDL_WindowID = Uint32;
pub const WindowID = u32;
//pub const SDL_SYSTEM_THEME_UNKNOWN: c_int = 0;
//pub const SDL_SYSTEM_THEME_LIGHT: c_int = 1;
//pub const SDL_SYSTEM_THEME_DARK: c_int = 2;
//pub const enum_SDL_SystemTheme = c_uint;
pub const SystemTheme = enum(c_uint) {
    unknown,
    light,
    dark,
};

//pub const SDL_SystemTheme = enum_SDL_SystemTheme;
//pub const struct_SDL_DisplayModeData = opaque {};
pub const DisplayModeData = opaque {};

//pub const SDL_DisplayModeData = struct_SDL_DisplayModeData;
//pub const struct_SDL_DisplayMode = extern struct {
pub const DisplayMode = extern struct {
    //    displayID: SDL_DisplayID = @import("std").mem.zeroes(SDL_DisplayID),
    displayid: DisplayID = @import("std").mem.zeroes(DisplayID),
    //    format: SDL_PixelFormat = @import("std").mem.zeroes(SDL_PixelFormat),
    format: PixelFormat = @import("std").mem.zeroes(PixelFormat),
    //    w: c_int = @import("std").mem.zeroes(c_int),
    w: c_int = @import("std").mem.zeroes(c_int),
    //    h: c_int = @import("std").mem.zeroes(c_int),
    h: c_int = @import("std").mem.zeroes(c_int),
    //    pixel_density: f32 = @import("std").mem.zeroes(f32),
    pixel_density: f32 = @import("std").mem.zeroes(f32),
    //    refresh_rate: f32 = @import("std").mem.zeroes(f32),
    refresh_rate: f32 = @import("std").mem.zeroes(f32),
    //    refresh_rate_numerator: c_int = @import("std").mem.zeroes(c_int),
    refresh_rate_numerator: c_int = @import("std").mem.zeroes(c_int),
    //    refresh_rate_denominator: c_int = @import("std").mem.zeroes(c_int),
    refresh_rate_denominator: c_int = @import("std").mem.zeroes(c_int),
    //    internal: ?*SDL_DisplayModeData = @import("std").mem.zeroes(?*SDL_DisplayModeData),
    internal: ?*DisplayModeData = @import("std").mem.zeroes(?*DisplayModeData),
    //};
};
//pub const SDL_DisplayMode = struct_SDL_DisplayMode;
//pub const SDL_ORIENTATION_UNKNOWN: c_int = 0;
//pub const SDL_ORIENTATION_LANDSCAPE: c_int = 1;
//pub const SDL_ORIENTATION_LANDSCAPE_FLIPPED: c_int = 2;
//pub const SDL_ORIENTATION_PORTRAIT: c_int = 3;
//pub const SDL_ORIENTATION_PORTRAIT_FLIPPED: c_int = 4;
//pub const enum_SDL_DisplayOrientation = c_uint;
pub const DisplayOrientation = enum(c_uint) {
    orientation_unknown,
    orientation_landscape,
    orientation_landscape_flipped,
    orientation_portrait,
    orientation_portrait_flipped,
};

pub const Window = opaque {
    pub const positionSet = setWindowPosition;
    pub const show = showWindow;
};

pub const WindowFlags = packed struct(u64) {
    fullscreen: bool = false,
    opengl: bool = false,
    occluded: bool = false,
    hidden: bool = false,
    borderless: bool = false,
    resizeable: bool = false,
    minimized: bool = false,
    maximized: bool = false,
    mouse_grabbed: bool = false,
    input_focus: bool = false,
    mouse_focus: bool = false,
    external: bool = false,
    modal: bool = false,
    high_pixel_density: bool = false,
    mouse_capture: bool = false,
    mouse_relative_mode: bool = false,
    always_on_top: bool = false,
    utility: bool = false,
    tooltip: bool = false,
    popup_menu: bool = false,
    keyboard_grabbed: bool = false,
    vulkan: bool = false,
    metal: bool = false,
    transparent: bool = false,
    not_focusable: bool = false,
    _padding: u39 = 0,
};

pub inline fn windowPosCenteredDisplay(id: u32) u32 {
    const centered_mask: comptime_int = 0x2FFF0000;
    return centered_mask & id;
}

//pub const SDL_FLASH_CANCEL: c_int = 0;
//pub const SDL_FLASH_BRIEFLY: c_int = 1;
//pub const SDL_FLASH_UNTIL_FOCUSED: c_int = 2;
//pub const enum_SDL_FlashOperation = c_uint;
pub const FlashOperation = enum(c_uint) {
    flash_cancel,
    flash_briefly,
    flash_until_focused,
};

//pub const SDL_FlashOperation = enum_SDL_FlashOperation;
//pub const struct_SDL_GLContextState = opaque {};
pub const GLContextState = opaque {};

//pub const SDL_GLContext = ?*struct_SDL_GLContextState;
//pub const SDL_EGLDisplay = ?*anyopaque;
//pub const SDL_EGLConfig = ?*anyopaque;
//pub const SDL_EGLSurface = ?*anyopaque;
//pub const SDL_EGLAttrib = isize;
//pub const SDL_EGLint = c_int;
//pub const SDL_EGLAttribArrayCallback = ?*const fn () callconv(.c) [*c]SDL_EGLAttrib;
pub const EGLAttribArrayCallback = ?*const fn () callconv(.c) [*c]EGLAttrib;
//pub const SDL_EGLIntArrayCallback = ?*const fn () callconv(.c) [*c]SDL_EGLint;
pub const EGLIntArrayCallback = ?*const fn () callconv(.c) [*c]EGLint;
//pub const SDL_GL_RED_SIZE: c_int = 0;
//pub const SDL_GL_GREEN_SIZE: c_int = 1;
//pub const SDL_GL_BLUE_SIZE: c_int = 2;
//pub const SDL_GL_ALPHA_SIZE: c_int = 3;
//pub const SDL_GL_BUFFER_SIZE: c_int = 4;
//pub const SDL_GL_DOUBLEBUFFER: c_int = 5;
//pub const SDL_GL_DEPTH_SIZE: c_int = 6;
//pub const SDL_GL_STENCIL_SIZE: c_int = 7;
//pub const SDL_GL_ACCUM_RED_SIZE: c_int = 8;
//pub const SDL_GL_ACCUM_GREEN_SIZE: c_int = 9;
//pub const SDL_GL_ACCUM_BLUE_SIZE: c_int = 10;
//pub const SDL_GL_ACCUM_ALPHA_SIZE: c_int = 11;
//pub const SDL_GL_STEREO: c_int = 12;
//pub const SDL_GL_MULTISAMPLEBUFFERS: c_int = 13;
//pub const SDL_GL_MULTISAMPLESAMPLES: c_int = 14;
//pub const SDL_GL_ACCELERATED_VISUAL: c_int = 15;
//pub const SDL_GL_RETAINED_BACKING: c_int = 16;
//pub const SDL_GL_CONTEXT_MAJOR_VERSION: c_int = 17;
//pub const SDL_GL_CONTEXT_MINOR_VERSION: c_int = 18;
//pub const SDL_GL_CONTEXT_FLAGS: c_int = 19;
//pub const SDL_GL_CONTEXT_PROFILE_MASK: c_int = 20;
//pub const SDL_GL_SHARE_WITH_CURRENT_CONTEXT: c_int = 21;
//pub const SDL_GL_FRAMEBUFFER_SRGB_CAPABLE: c_int = 22;
//pub const SDL_GL_CONTEXT_RELEASE_BEHAVIOR: c_int = 23;
//pub const SDL_GL_CONTEXT_RESET_NOTIFICATION: c_int = 24;
//pub const SDL_GL_CONTEXT_NO_ERROR: c_int = 25;
//pub const SDL_GL_FLOATBUFFERS: c_int = 26;
//pub const SDL_GL_EGL_PLATFORM: c_int = 27;
//pub const enum_SDL_GLattr = c_uint;
pub const GLattr = enum(c_uint) {
    gl_red_size,
    gl_green_size,
    gl_blue_size,
    gl_alpha_size,
    gl_buffer_size,
    gl_doublebuffer,
    gl_depth_size,
    gl_stencil_size,
    gl_accum_red_size,
    gl_accum_green_size,
    gl_accum_blue_size,
    gl_accum_alpha_size,
    gl_stereo,
    gl_multisamplebuffers,
    gl_multisamplesamples,
    gl_accelerated_visual,
    gl_retained_backing,
    gl_context_major_version,
    gl_context_minor_version,
    gl_context_flags,
    gl_context_profile_mask,
    gl_share_with_current_context,
    gl_framebuffer_srgb_capable,
    gl_context_release_behavior,
    gl_context_reset_notification,
    gl_context_no_error,
    gl_floatbuffers,
    gl_egl_platform,
};

//pub const SDL_GLattr = enum_SDL_GLattr;
//pub const SDL_GL_CONTEXT_PROFILE_CORE: c_int = 1;
//pub const SDL_GL_CONTEXT_PROFILE_COMPATIBILITY: c_int = 2;
//pub const SDL_GL_CONTEXT_PROFILE_ES: c_int = 4;
//pub const enum_SDL_GLprofile = c_uint;
pub const GLprofile = enum(c_uint) {
    gl_context_profile_core = 1,
    gl_context_profile_compatibility = 2,
    gl_context_profile_es = 4,
};

//pub const SDL_GLprofile = enum_SDL_GLprofile;
//pub const SDL_GL_CONTEXT_DEBUG_FLAG: c_int = 1;
//pub const SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG: c_int = 2;
//pub const SDL_GL_CONTEXT_ROBUST_ACCESS_FLAG: c_int = 4;
//pub const SDL_GL_CONTEXT_RESET_ISOLATION_FLAG: c_int = 8;
//pub const enum_SDL_GLcontextFlag = c_uint;
pub const GLcontextFlag = enum(c_uint) {
    gl_context_debug_flag = 1,
    gl_context_forward_compatible_flag = 2,
    gl_context_robust_access_flag = 4,
    gl_context_reset_isolation_flag = 8,
};

//pub const SDL_GLcontextFlag = enum_SDL_GLcontextFlag;
//pub const SDL_GL_CONTEXT_RELEASE_BEHAVIOR_NONE: c_int = 0;
//pub const SDL_GL_CONTEXT_RELEASE_BEHAVIOR_FLUSH: c_int = 1;
//pub const enum_SDL_GLcontextReleaseFlag = c_uint;
pub const GLcontextReleaseFlag = enum(c_uint) {
    gl_context_release_behavior_none,
    gl_context_release_behavior_flush,
};

//pub const SDL_GLcontextReleaseFlag = enum_SDL_GLcontextReleaseFlag;
//pub const SDL_GL_CONTEXT_RESET_NO_NOTIFICATION: c_int = 0;
//pub const SDL_GL_CONTEXT_RESET_LOSE_CONTEXT: c_int = 1;
//pub const enum_SDL_GLContextResetNotification = c_uint;
pub const GLContextResetNotification = enum(c_uint) {
    gl_context_reset_no_notification,
    gl_context_reset_lose_context,
};

pub fn windowSizeInPixels(window: *Window) ![2]u32 {
    var w: c_int = 0;
    var h: c_int = 0;
    if (!SDL_GetWindowSizeInPixels(window, &w, &h)) {
        sdl.log("Error getting window size: %s", sdl.getError());
        return error.SdlError;
    }
    return .{ @intCast(w), @intCast(h) };
}

//pub const SDL_GLContextResetNotification = enum_SDL_GLContextResetNotification;
//pub extern fn SDL_GetNumVideoDrivers() c_int;
pub extern fn SDL_GetNumVideoDrivers() c_int;
pub const getNumVideoDrivers = SDL_GetNumVideoDrivers;
//pub extern fn SDL_GetVideoDriver(index: c_int) [*c]const u8;
pub extern fn SDL_GetVideoDriver(index: c_int) [*c]const u8;
pub const getVideoDriver = SDL_GetVideoDriver;
//pub extern fn SDL_GetCurrentVideoDriver() [*c]const u8;
pub extern fn SDL_GetCurrentVideoDriver() [*c]const u8;
pub const getCurrentVideoDriver = SDL_GetCurrentVideoDriver;
//pub extern fn SDL_GetSystemTheme() SDL_SystemTheme;
pub extern fn SDL_GetSystemTheme() SystemTheme;
pub const getSystemTheme = SDL_GetSystemTheme;
//pub extern fn SDL_GetDisplays(count: [*c]c_int) [*c]SDL_DisplayID;
pub extern fn SDL_GetDisplays(count: [*c]c_int) [*c]DisplayID;
pub const getDisplays = SDL_GetDisplays;
//pub extern fn SDL_GetPrimaryDisplay() SDL_DisplayID;
pub extern fn SDL_GetPrimaryDisplay() DisplayID;
pub const getPrimaryDisplay = SDL_GetPrimaryDisplay;
//pub extern fn SDL_GetDisplayProperties(displayID: SDL_DisplayID) SDL_PropertiesID;
pub extern fn SDL_GetDisplayProperties(displayID: DisplayID) PropertiesID;
pub const getDisplayProperties = SDL_GetDisplayProperties;
//pub extern fn SDL_GetDisplayName(displayID: SDL_DisplayID) [*c]const u8;
pub extern fn SDL_GetDisplayName(displayID: DisplayID) [*c]const u8;
pub const getDisplayName = SDL_GetDisplayName;
//pub extern fn SDL_GetDisplayBounds(displayID: SDL_DisplayID, rect: [*c]SDL_Rect) SDL_bool;
pub extern fn SDL_GetDisplayBounds(displayID: DisplayID, rect: [*c]Rect) bool;
pub const getDisplayBounds = SDL_GetDisplayBounds;
//pub extern fn SDL_GetDisplayUsableBounds(displayID: SDL_DisplayID, rect: [*c]SDL_Rect) SDL_bool;
pub extern fn SDL_GetDisplayUsableBounds(displayID: DisplayID, rect: [*c]Rect) bool;
pub const getDisplayUsableBounds = SDL_GetDisplayUsableBounds;
//pub extern fn SDL_GetNaturalDisplayOrientation(displayID: SDL_DisplayID) SDL_DisplayOrientation;
pub extern fn SDL_GetNaturalDisplayOrientation(displayID: DisplayID) DisplayOrientation;
pub const getNaturalDisplayOrientation = SDL_GetNaturalDisplayOrientation;
//pub extern fn SDL_GetCurrentDisplayOrientation(displayID: SDL_DisplayID) SDL_DisplayOrientation;
pub extern fn SDL_GetCurrentDisplayOrientation(displayID: DisplayID) DisplayOrientation;
pub const getCurrentDisplayOrientation = SDL_GetCurrentDisplayOrientation;
//pub extern fn SDL_GetDisplayContentScale(displayID: SDL_DisplayID) f32;
pub extern fn SDL_GetDisplayContentScale(displayID: DisplayID) f32;
pub const getDisplayContentScale = SDL_GetDisplayContentScale;
//pub extern fn SDL_GetFullscreenDisplayModes(displayID: SDL_DisplayID, count: [*c]c_int) [*c][*c]SDL_DisplayMode;
pub extern fn SDL_GetFullscreenDisplayModes(displayID: DisplayID, count: [*c]c_int) [*c][*c]DisplayMode;
pub const getFullscreenDisplayModes = SDL_GetFullscreenDisplayModes;
//pub extern fn SDL_GetClosestFullscreenDisplayMode(displayID: SDL_DisplayID, w: c_int, h: c_int, refresh_rate: f32, include_high_density_modes: SDL_bool, mode: [*c]SDL_DisplayMode) SDL_bool;
pub extern fn SDL_GetClosestFullscreenDisplayMode(displayID: DisplayID, w: c_int, h: c_int, refresh_rate: f32, include_high_density_modes: bool, mode: [*c]DisplayMode) bool;
pub const getClosestFullscreenDisplayMode = SDL_GetClosestFullscreenDisplayMode;
//pub extern fn SDL_GetDesktopDisplayMode(displayID: SDL_DisplayID) [*c]const SDL_DisplayMode;
pub extern fn SDL_GetDesktopDisplayMode(displayID: DisplayID) [*c]const DisplayMode;
pub const getDesktopDisplayMode = SDL_GetDesktopDisplayMode;
//pub extern fn SDL_GetCurrentDisplayMode(displayID: SDL_DisplayID) [*c]const SDL_DisplayMode;
pub extern fn SDL_GetCurrentDisplayMode(displayID: DisplayID) [*c]const DisplayMode;
pub const getCurrentDisplayMode = SDL_GetCurrentDisplayMode;
//pub extern fn SDL_GetDisplayForPoint(point: [*c]const SDL_Point) SDL_DisplayID;
pub extern fn SDL_GetDisplayForPoint(point: [*c]const Point) DisplayID;
pub const getDisplayForPoint = SDL_GetDisplayForPoint;
//pub extern fn SDL_GetDisplayForRect(rect: [*c]const SDL_Rect) SDL_DisplayID;
pub extern fn SDL_GetDisplayForRect(rect: [*c]const Rect) DisplayID;
pub const getDisplayForRect = SDL_GetDisplayForRect;
//pub extern fn SDL_GetDisplayForWindow(window: ?*SDL_Window) SDL_DisplayID;
pub extern fn SDL_GetDisplayForWindow(window: ?*Window) DisplayID;
pub const getDisplayForWindow = SDL_GetDisplayForWindow;
//pub extern fn SDL_GetWindowPixelDensity(window: ?*SDL_Window) f32;
pub extern fn SDL_GetWindowPixelDensity(window: ?*Window) f32;
pub const getWindowPixelDensity = SDL_GetWindowPixelDensity;
//pub extern fn SDL_GetWindowDisplayScale(window: ?*SDL_Window) f32;
pub extern fn SDL_GetWindowDisplayScale(window: ?*Window) f32;
pub const getWindowDisplayScale = SDL_GetWindowDisplayScale;
//pub extern fn SDL_SetWindowFullscreenMode(window: ?*SDL_Window, mode: [*c]const SDL_DisplayMode) SDL_bool;
pub extern fn SDL_SetWindowFullscreenMode(window: ?*Window, mode: [*c]const DisplayMode) bool;
pub const setWindowFullscreenMode = SDL_SetWindowFullscreenMode;
//pub extern fn SDL_GetWindowFullscreenMode(window: ?*SDL_Window) [*c]const SDL_DisplayMode;
pub extern fn SDL_GetWindowFullscreenMode(window: ?*Window) [*c]const DisplayMode;
pub const getWindowFullscreenMode = SDL_GetWindowFullscreenMode;
//pub extern fn SDL_GetWindowICCProfile(window: ?*SDL_Window, size: [*c]usize) ?*anyopaque;
pub extern fn SDL_GetWindowICCProfile(window: ?*Window, size: [*c]usize) ?*anyopaque;
pub const getWindowICCProfile = SDL_GetWindowICCProfile;
//pub extern fn SDL_GetWindowPixelFormat(window: ?*SDL_Window) SDL_PixelFormat;
pub extern fn SDL_GetWindowPixelFormat(window: ?*Window) PixelFormat;
pub const getWindowPixelFormat = SDL_GetWindowPixelFormat;
//pub extern fn SDL_GetWindows(count: [*c]c_int) [*c]?*SDL_Window;
pub extern fn SDL_GetWindows(count: [*c]c_int) [*c]?*Window;
pub const getWindows = SDL_GetWindows;

extern fn SDL_CreateWindow(title: [*c]const u8, w: c_int, h: c_int, flags: WindowFlags) ?*Window;
pub fn createWindow(title: [:0]const u8, w: u16, h: u16, flags: WindowFlags) !*Window {
    return SDL_CreateWindow(title.ptr, @intCast(w), @intCast(h), flags) orelse {
        std.log.err("SDL create window failure: {s}", .{sdl.getError()});
        return error.SdlError;
    };
}

pub extern fn SDL_CreatePopupWindow(parent: ?*Window, offset_x: c_int, offset_y: c_int, w: c_int, h: c_int, flags: WindowFlags) ?*Window;
pub const createPopupWindow = SDL_CreatePopupWindow;
//pub extern fn SDL_CreateWindowWithProperties(props: SDL_PropertiesID) ?*SDL_Window;
pub extern fn SDL_CreateWindowWithProperties(props: PropertiesID) ?*Window;
pub const createWindowWithProperties = SDL_CreateWindowWithProperties;
//pub extern fn SDL_GetWindowID(window: ?*SDL_Window) SDL_WindowID;
pub extern fn SDL_GetWindowID(window: *Window) WindowID;
pub const getWindowID = SDL_GetWindowID;
//pub extern fn SDL_GetWindowFromID(id: SDL_WindowID) ?*SDL_Window;
pub extern fn SDL_GetWindowFromID(id: WindowID) ?*Window;
pub const getWindowFromID = SDL_GetWindowFromID;
//pub extern fn SDL_GetWindowParent(window: ?*SDL_Window) ?*SDL_Window;
pub extern fn SDL_GetWindowParent(window: ?*Window) ?*Window;
pub const getWindowParent = SDL_GetWindowParent;
//pub extern fn SDL_GetWindowProperties(window: ?*SDL_Window) SDL_PropertiesID;
pub extern fn SDL_GetWindowProperties(window: ?*Window) PropertiesID;
pub const getWindowProperties = SDL_GetWindowProperties;
//pub extern fn SDL_GetWindowFlags(window: ?*SDL_Window) SDL_WindowFlags;
pub extern fn SDL_GetWindowFlags(window: ?*Window) WindowFlags;
pub const getWindowFlags = SDL_GetWindowFlags;
//pub extern fn SDL_SetWindowTitle(window: ?*SDL_Window, title: [*c]const u8) SDL_bool;
pub extern fn SDL_SetWindowTitle(window: ?*Window, title: [*c]const u8) bool;
pub const setWindowTitle = SDL_SetWindowTitle;
//pub extern fn SDL_GetWindowTitle(window: ?*SDL_Window) [*c]const u8;
pub extern fn SDL_GetWindowTitle(window: ?*Window) [*c]const u8;
pub const getWindowTitle = SDL_GetWindowTitle;
//pub extern fn SDL_SetWindowIcon(window: ?*SDL_Window, icon: [*c]SDL_Surface) SDL_bool;
pub extern fn SDL_SetWindowIcon(window: ?*Window, icon: [*c]Surface) bool;
pub const setWindowIcon = SDL_SetWindowIcon;
//pub extern fn SDL_SetWindowPosition(window: ?*SDL_Window, x: c_int, y: c_int) SDL_bool;
pub extern fn SDL_SetWindowPosition(window: ?*Window, x: c_int, y: c_int) bool;
pub const setWindowPosition = SDL_SetWindowPosition;
//pub extern fn SDL_GetWindowPosition(window: ?*SDL_Window, x: [*c]c_int, y: [*c]c_int) SDL_bool;
pub extern fn SDL_GetWindowPosition(window: ?*Window, x: [*c]c_int, y: [*c]c_int) bool;
pub const getWindowPosition = SDL_GetWindowPosition;
//pub extern fn SDL_SetWindowSize(window: ?*SDL_Window, w: c_int, h: c_int) SDL_bool;
pub extern fn SDL_SetWindowSize(window: ?*Window, w: c_int, h: c_int) bool;
pub const setWindowSize = SDL_SetWindowSize;
//pub extern fn SDL_GetWindowSize(window: ?*SDL_Window, w: [*c]c_int, h: [*c]c_int) SDL_bool;
pub extern fn SDL_GetWindowSize(window: ?*Window, w: [*c]c_int, h: [*c]c_int) bool;
pub const getWindowSize = SDL_GetWindowSize;
//pub extern fn SDL_GetWindowSafeArea(window: ?*SDL_Window, rect: [*c]SDL_Rect) SDL_bool;
pub extern fn SDL_GetWindowSafeArea(window: ?*Window, rect: [*c]Rect) bool;
pub const getWindowSafeArea = SDL_GetWindowSafeArea;
//pub extern fn SDL_SetWindowAspectRatio(window: ?*SDL_Window, min_aspect: f32, max_aspect: f32) SDL_bool;
pub extern fn SDL_SetWindowAspectRatio(window: ?*Window, min_aspect: f32, max_aspect: f32) bool;
pub const setWindowAspectRatio = SDL_SetWindowAspectRatio;
//pub extern fn SDL_GetWindowAspectRatio(window: ?*SDL_Window, min_aspect: [*c]f32, max_aspect: [*c]f32) SDL_bool;
pub extern fn SDL_GetWindowAspectRatio(window: ?*Window, min_aspect: [*c]f32, max_aspect: [*c]f32) bool;
pub const getWindowAspectRatio = SDL_GetWindowAspectRatio;
//pub extern fn SDL_GetWindowBordersSize(window: ?*SDL_Window, top: [*c]c_int, left: [*c]c_int, bottom: [*c]c_int, right: [*c]c_int) SDL_bool;
pub extern fn SDL_GetWindowBordersSize(window: ?*Window, top: [*c]c_int, left: [*c]c_int, bottom: [*c]c_int, right: [*c]c_int) bool;
pub const getWindowBordersSize = SDL_GetWindowBordersSize;

pub extern fn SDL_GetWindowSizeInPixels(window: *Window, w: [*c]c_int, h: [*c]c_int) bool;

pub extern fn SDL_SetWindowMinimumSize(window: ?*Window, min_w: c_int, min_h: c_int) bool;
pub const setWindowMinimumSize = SDL_SetWindowMinimumSize;
//pub extern fn SDL_GetWindowMinimumSize(window: ?*SDL_Window, w: [*c]c_int, h: [*c]c_int) SDL_bool;
pub extern fn SDL_GetWindowMinimumSize(window: ?*Window, w: [*c]c_int, h: [*c]c_int) bool;
pub const getWindowMinimumSize = SDL_GetWindowMinimumSize;
//pub extern fn SDL_SetWindowMaximumSize(window: ?*SDL_Window, max_w: c_int, max_h: c_int) SDL_bool;
pub extern fn SDL_SetWindowMaximumSize(window: ?*Window, max_w: c_int, max_h: c_int) bool;
pub const setWindowMaximumSize = SDL_SetWindowMaximumSize;
//pub extern fn SDL_GetWindowMaximumSize(window: ?*SDL_Window, w: [*c]c_int, h: [*c]c_int) SDL_bool;
pub extern fn SDL_GetWindowMaximumSize(window: ?*Window, w: [*c]c_int, h: [*c]c_int) bool;
pub const getWindowMaximumSize = SDL_GetWindowMaximumSize;
//pub extern fn SDL_SetWindowBordered(window: ?*SDL_Window, bordered: SDL_bool) SDL_bool;
pub extern fn SDL_SetWindowBordered(window: ?*Window, bordered: bool) bool;
pub const setWindowBordered = SDL_SetWindowBordered;
//pub extern fn SDL_SetWindowResizable(window: ?*SDL_Window, resizable: SDL_bool) SDL_bool;
pub extern fn SDL_SetWindowResizable(window: ?*Window, resizable: bool) bool;
pub const setWindowResizable = SDL_SetWindowResizable;
//pub extern fn SDL_SetWindowAlwaysOnTop(window: ?*SDL_Window, on_top: SDL_bool) SDL_bool;
pub extern fn SDL_SetWindowAlwaysOnTop(window: ?*Window, on_top: bool) bool;
pub const setWindowAlwaysOnTop = SDL_SetWindowAlwaysOnTop;

extern fn SDL_ShowWindow(window: *Window) bool;
pub const showWindow = SDL_ShowWindow;

//pub extern fn SDL_HideWindow(window: ?*SDL_Window) SDL_bool;
pub extern fn SDL_HideWindow(window: ?*Window) bool;
pub const hideWindow = SDL_HideWindow;
//pub extern fn SDL_RaiseWindow(window: ?*SDL_Window) SDL_bool;
pub extern fn SDL_RaiseWindow(window: ?*Window) bool;
pub const raiseWindow = SDL_RaiseWindow;
//pub extern fn SDL_MaximizeWindow(window: ?*SDL_Window) SDL_bool;
pub extern fn SDL_MaximizeWindow(window: ?*Window) bool;
pub const maximizeWindow = SDL_MaximizeWindow;
//pub extern fn SDL_MinimizeWindow(window: ?*SDL_Window) SDL_bool;
pub extern fn SDL_MinimizeWindow(window: ?*Window) bool;
pub const minimizeWindow = SDL_MinimizeWindow;
//pub extern fn SDL_RestoreWindow(window: ?*SDL_Window) SDL_bool;
pub extern fn SDL_RestoreWindow(window: ?*Window) bool;
pub const restoreWindow = SDL_RestoreWindow;
//pub extern fn SDL_SetWindowFullscreen(window: ?*SDL_Window, fullscreen: SDL_bool) SDL_bool;
pub extern fn SDL_SetWindowFullscreen(window: ?*Window, fullscreen: bool) bool;
pub const setWindowFullscreen = SDL_SetWindowFullscreen;
//pub extern fn SDL_SyncWindow(window: ?*SDL_Window) SDL_bool;
pub extern fn SDL_SyncWindow(window: ?*Window) bool;
pub const syncWindow = SDL_SyncWindow;
//pub extern fn SDL_WindowHasSurface(window: ?*SDL_Window) SDL_bool;
pub extern fn SDL_WindowHasSurface(window: ?*Window) bool;
pub const windowHasSurface = SDL_WindowHasSurface;
//pub extern fn SDL_GetWindowSurface(window: ?*SDL_Window) [*c]SDL_Surface;
pub extern fn SDL_GetWindowSurface(window: ?*Window) [*c]Surface;
pub const getWindowSurface = SDL_GetWindowSurface;
//pub extern fn SDL_SetWindowSurfaceVSync(window: ?*SDL_Window, vsync: c_int) SDL_bool;
pub extern fn SDL_SetWindowSurfaceVSync(window: ?*Window, vsync: c_int) bool;
pub const setWindowSurfaceVSync = SDL_SetWindowSurfaceVSync;
//pub extern fn SDL_GetWindowSurfaceVSync(window: ?*SDL_Window, vsync: [*c]c_int) SDL_bool;
pub extern fn SDL_GetWindowSurfaceVSync(window: ?*Window, vsync: [*c]c_int) bool;
pub const getWindowSurfaceVSync = SDL_GetWindowSurfaceVSync;
//pub extern fn SDL_UpdateWindowSurface(window: ?*SDL_Window) SDL_bool;
pub extern fn SDL_UpdateWindowSurface(window: ?*Window) bool;
pub const updateWindowSurface = SDL_UpdateWindowSurface;
//pub extern fn SDL_UpdateWindowSurfaceRects(window: ?*SDL_Window, rects: [*c]const SDL_Rect, numrects: c_int) SDL_bool;
pub extern fn SDL_UpdateWindowSurfaceRects(window: ?*Window, rects: [*c]const Rect, numrects: c_int) bool;
pub const updateWindowSurfaceRects = SDL_UpdateWindowSurfaceRects;
//pub extern fn SDL_DestroyWindowSurface(window: ?*SDL_Window) SDL_bool;
pub extern fn SDL_DestroyWindowSurface(window: ?*Window) bool;
pub const destroyWindowSurface = SDL_DestroyWindowSurface;
//pub extern fn SDL_SetWindowKeyboardGrab(window: ?*SDL_Window, grabbed: SDL_bool) SDL_bool;
pub extern fn SDL_SetWindowKeyboardGrab(window: ?*Window, grabbed: bool) bool;
pub const setWindowKeyboardGrab = SDL_SetWindowKeyboardGrab;
//pub extern fn SDL_SetWindowMouseGrab(window: ?*SDL_Window, grabbed: SDL_bool) SDL_bool;
pub extern fn SDL_SetWindowMouseGrab(window: ?*Window, grabbed: bool) bool;
pub const setWindowMouseGrab = SDL_SetWindowMouseGrab;
//pub extern fn SDL_GetWindowKeyboardGrab(window: ?*SDL_Window) SDL_bool;
pub extern fn SDL_GetWindowKeyboardGrab(window: ?*Window) bool;
pub const getWindowKeyboardGrab = SDL_GetWindowKeyboardGrab;
//pub extern fn SDL_GetWindowMouseGrab(window: ?*SDL_Window) SDL_bool;
pub extern fn SDL_GetWindowMouseGrab(window: ?*Window) bool;
pub const getWindowMouseGrab = SDL_GetWindowMouseGrab;
//pub extern fn SDL_GetGrabbedWindow() ?*SDL_Window;
pub extern fn SDL_GetGrabbedWindow() ?*Window;
pub const getGrabbedWindow = SDL_GetGrabbedWindow;
//pub extern fn SDL_SetWindowMouseRect(window: ?*SDL_Window, rect: [*c]const SDL_Rect) SDL_bool;
pub extern fn SDL_SetWindowMouseRect(window: ?*Window, rect: [*c]const Rect) bool;
pub const setWindowMouseRect = SDL_SetWindowMouseRect;
//pub extern fn SDL_GetWindowMouseRect(window: ?*SDL_Window) [*c]const SDL_Rect;
pub extern fn SDL_GetWindowMouseRect(window: ?*Window) [*c]const Rect;
pub const getWindowMouseRect = SDL_GetWindowMouseRect;
//pub extern fn SDL_SetWindowOpacity(window: ?*SDL_Window, opacity: f32) SDL_bool;
pub extern fn SDL_SetWindowOpacity(window: ?*Window, opacity: f32) bool;
pub const setWindowOpacity = SDL_SetWindowOpacity;
//pub extern fn SDL_GetWindowOpacity(window: ?*SDL_Window) f32;
pub extern fn SDL_GetWindowOpacity(window: ?*Window) f32;
pub const getWindowOpacity = SDL_GetWindowOpacity;
//pub extern fn SDL_SetWindowParent(window: ?*SDL_Window, parent: ?*SDL_Window) SDL_bool;
pub extern fn SDL_SetWindowParent(window: ?*Window, parent: ?*Window) bool;
pub const setWindowParent = SDL_SetWindowParent;
//pub extern fn SDL_SetWindowModal(window: ?*SDL_Window, modal: SDL_bool) SDL_bool;
pub extern fn SDL_SetWindowModal(window: ?*Window, modal: bool) bool;
pub const setWindowModal = SDL_SetWindowModal;
//pub extern fn SDL_SetWindowFocusable(window: ?*SDL_Window, focusable: SDL_bool) SDL_bool;
pub extern fn SDL_SetWindowFocusable(window: ?*Window, focusable: bool) bool;
pub const setWindowFocusable = SDL_SetWindowFocusable;
//pub extern fn SDL_ShowWindowSystemMenu(window: ?*SDL_Window, x: c_int, y: c_int) SDL_bool;
pub extern fn SDL_ShowWindowSystemMenu(window: ?*Window, x: c_int, y: c_int) bool;
pub const showWindowSystemMenu = SDL_ShowWindowSystemMenu;
//pub const SDL_HITTEST_NORMAL: c_int = 0;
//pub const SDL_HITTEST_DRAGGABLE: c_int = 1;
//pub const SDL_HITTEST_RESIZE_TOPLEFT: c_int = 2;
//pub const SDL_HITTEST_RESIZE_TOP: c_int = 3;
//pub const SDL_HITTEST_RESIZE_TOPRIGHT: c_int = 4;
//pub const SDL_HITTEST_RESIZE_RIGHT: c_int = 5;
//pub const SDL_HITTEST_RESIZE_BOTTOMRIGHT: c_int = 6;
//pub const SDL_HITTEST_RESIZE_BOTTOM: c_int = 7;
//pub const SDL_HITTEST_RESIZE_BOTTOMLEFT: c_int = 8;
//pub const SDL_HITTEST_RESIZE_LEFT: c_int = 9;
//pub const enum_SDL_HitTestResult = c_uint;
pub const HitTestResult = enum(c_uint) {
    hittest_normal = 0,
    hittest_draggable = 1,
    hittest_resize_topleft = 2,
    hittest_resize_top = 3,
    hittest_resize_topright = 4,
    hittest_resize_right = 5,
    hittest_resize_bottomright = 6,
    hittest_resize_bottom = 7,
    hittest_resize_bottomleft = 8,
    hittest_resize_left = 9,
};

//pub const SDL_HitTestResult = enum_SDL_HitTestResult;
//pub const SDL_HitTest = ?*const fn (?*SDL_Window, [*c]const SDL_Point, ?*anyopaque) callconv(.c) SDL_HitTestResult;
pub const HitTest = ?*const fn (?*Window, [*c]const Point, ?*anyopaque) callconv(.c) HitTestResult;
//pub extern fn SDL_SetWindowHitTest(window: ?*SDL_Window, callback: SDL_HitTest, callback_data: ?*anyopaque) SDL_bool;
pub extern fn SDL_SetWindowHitTest(window: ?*Window, callback: HitTest, callback_data: ?*anyopaque) bool;
pub const setWindowHitTest = SDL_SetWindowHitTest;
//pub extern fn SDL_SetWindowShape(window: ?*SDL_Window, shape: [*c]SDL_Surface) SDL_bool;
pub extern fn SDL_SetWindowShape(window: ?*Window, shape: [*c]Surface) bool;
pub const setWindowShape = SDL_SetWindowShape;
//pub extern fn SDL_FlashWindow(window: ?*SDL_Window, operation: SDL_FlashOperation) SDL_bool;
pub extern fn SDL_FlashWindow(window: ?*Window, operation: FlashOperation) bool;
pub const flashWindow = SDL_FlashWindow;
//pub extern fn SDL_DestroyWindow(window: ?*SDL_Window) void;
pub extern fn SDL_DestroyWindow(window: ?*Window) void;
pub const destroyWindow = SDL_DestroyWindow;
//pub extern fn SDL_ScreenSaverEnabled() SDL_bool;
pub extern fn SDL_ScreenSaverEnabled() bool;
pub const screenSaverEnabled = SDL_ScreenSaverEnabled;
//pub extern fn SDL_EnableScreenSaver() SDL_bool;
pub extern fn SDL_EnableScreenSaver() bool;
pub const enableScreenSaver = SDL_EnableScreenSaver;
//pub extern fn SDL_DisableScreenSaver() SDL_bool;
pub extern fn SDL_DisableScreenSaver() bool;
pub const disableScreenSaver = SDL_DisableScreenSaver;
//pub extern fn SDL_GL_LoadLibrary(path: [*c]const u8) SDL_bool;
pub extern fn SDL_GL_LoadLibrary(path: [*c]const u8) bool;
pub const glLoadLibrary = SDL_GL_LoadLibrary;
//pub extern fn SDL_GL_GetProcAddress(proc: [*c]const u8) SDL_FunctionPointer;
pub extern fn SDL_GL_GetProcAddress(proc: [*c]const u8) FunctionPointer;
pub const glGetProcAddress = SDL_GL_GetProcAddress;
//pub extern fn SDL_EGL_GetProcAddress(proc: [*c]const u8) SDL_FunctionPointer;
pub extern fn SDL_EGL_GetProcAddress(proc: [*c]const u8) FunctionPointer;
pub const eglGetProcAddress = SDL_EGL_GetProcAddress;
//pub extern fn SDL_GL_UnloadLibrary() void;
pub extern fn SDL_GL_UnloadLibrary() void;
pub const glUnloadLibrary = SDL_GL_UnloadLibrary;
//pub extern fn SDL_GL_ExtensionSupported(extension: [*c]const u8) SDL_bool;
pub extern fn SDL_GL_ExtensionSupported(extension: [*c]const u8) bool;
pub const glExtensionSupported = SDL_GL_ExtensionSupported;
//pub extern fn SDL_GL_ResetAttributes() void;
pub extern fn SDL_GL_ResetAttributes() void;
pub const glResetAttributes = SDL_GL_ResetAttributes;
//pub extern fn SDL_GL_SetAttribute(attr: SDL_GLattr, value: c_int) SDL_bool;
pub extern fn SDL_GL_SetAttribute(attr: GLattr, value: c_int) bool;
pub const glSetAttribute = SDL_GL_SetAttribute;
//pub extern fn SDL_GL_GetAttribute(attr: SDL_GLattr, value: [*c]c_int) SDL_bool;
pub extern fn SDL_GL_GetAttribute(attr: GLattr, value: [*c]c_int) bool;
pub const glGetAttribute = SDL_GL_GetAttribute;
//pub extern fn SDL_GL_CreateContext(window: ?*SDL_Window) SDL_GLContext;
pub extern fn SDL_GL_CreateContext(window: ?*Window) GLContext;
pub const glCreateContext = SDL_GL_CreateContext;
//pub extern fn SDL_GL_MakeCurrent(window: ?*SDL_Window, context: SDL_GLContext) SDL_bool;
pub extern fn SDL_GL_MakeCurrent(window: ?*Window, context: GLContext) bool;
pub const glMakeCurrent = SDL_GL_MakeCurrent;
//pub extern fn SDL_GL_GetCurrentWindow() ?*SDL_Window;
pub extern fn SDL_GL_GetCurrentWindow() ?*Window;
pub const glGetCurrentWindow = SDL_GL_GetCurrentWindow;
//pub extern fn SDL_GL_GetCurrentContext() SDL_GLContext;
pub extern fn SDL_GL_GetCurrentContext() GLContext;
pub const glGetCurrentContext = SDL_GL_GetCurrentContext;
//pub extern fn SDL_EGL_GetCurrentDisplay() SDL_EGLDisplay;
pub extern fn SDL_EGL_GetCurrentDisplay() EGLDisplay;
pub const eglGetCurrentDisplay = SDL_EGL_GetCurrentDisplay;
//pub extern fn SDL_EGL_GetCurrentConfig() SDL_EGLConfig;
pub extern fn SDL_EGL_GetCurrentConfig() EGLConfig;
pub const eglGetCurrentConfig = SDL_EGL_GetCurrentConfig;
//pub extern fn SDL_EGL_GetWindowSurface(window: ?*SDL_Window) SDL_EGLSurface;
pub extern fn SDL_EGL_GetWindowSurface(window: ?*Window) EGLSurface;
pub const eglGetWindowSurface = SDL_EGL_GetWindowSurface;
//pub extern fn SDL_EGL_SetAttributeCallbacks(platformAttribCallback: SDL_EGLAttribArrayCallback, surfaceAttribCallback: SDL_EGLIntArrayCallback, contextAttribCallback: SDL_EGLIntArrayCallback) void;
pub extern fn SDL_EGL_SetAttributeCallbacks(platformAttribCallback: EGLAttribArrayCallback, surfaceAttribCallback: EGLIntArrayCallback, contextAttribCallback: EGLIntArrayCallback) void;
pub const eglSetAttributeCallbacks = SDL_EGL_SetAttributeCallbacks;
//pub extern fn SDL_GL_SetSwapInterval(interval: c_int) SDL_bool;
pub extern fn SDL_GL_SetSwapInterval(interval: c_int) bool;
pub const glSetSwapInterval = SDL_GL_SetSwapInterval;
//pub extern fn SDL_GL_GetSwapInterval(interval: [*c]c_int) SDL_bool;
pub extern fn SDL_GL_GetSwapInterval(interval: [*c]c_int) bool;
pub const glGetSwapInterval = SDL_GL_GetSwapInterval;
//pub extern fn SDL_GL_SwapWindow(window: ?*SDL_Window) SDL_bool;
pub extern fn SDL_GL_SwapWindow(window: ?*Window) bool;
pub const glSwapWindow = SDL_GL_SwapWindow;
//pub extern fn SDL_GL_DestroyContext(context: SDL_GLContext) SDL_bool;
pub extern fn SDL_GL_DestroyContext(context: GLContext) bool;
pub const glDestroyContext = SDL_GL_DestroyContext;
//pub const __llvm__ = @as(c_int, 1);
//pub const __clang__ = @as(c_int, 1);
//pub const __clang_major__ = @as(c_int, 18);
//pub const __clang_minor__ = @as(c_int, 1);
//pub const __clang_patchlevel__ = @as(c_int, 6);
//pub const __clang_version__ = "18.1.6 (https://github.com/ziglang/zig-bootstrap 98bc6bf4fc4009888d33941daf6b600d20a42a56)";
//pub const __GNUC__ = @as(c_int, 4);
//pub const __GNUC_MINOR__ = @as(c_int, 2);
//pub const __GNUC_PATCHLEVEL__ = @as(c_int, 1);
//pub const __GXX_ABI_VERSION = @as(c_int, 1002);
//pub const __ATOMIC_RELAXED = @as(c_int, 0);
//pub const __ATOMIC_CONSUME = @as(c_int, 1);
//pub const __ATOMIC_ACQUIRE = @as(c_int, 2);
//pub const __ATOMIC_RELEASE = @as(c_int, 3);
//pub const __ATOMIC_ACQ_REL = @as(c_int, 4);
//pub const __ATOMIC_SEQ_CST = @as(c_int, 5);
//pub const __MEMORY_SCOPE_SYSTEM = @as(c_int, 0);
//pub const __MEMORY_SCOPE_DEVICE = @as(c_int, 1);
//pub const __MEMORY_SCOPE_WRKGRP = @as(c_int, 2);
//pub const __MEMORY_SCOPE_WVFRNT = @as(c_int, 3);
//pub const __MEMORY_SCOPE_SINGLE = @as(c_int, 4);
//pub const __OPENCL_MEMORY_SCOPE_WORK_ITEM = @as(c_int, 0);
//pub const __OPENCL_MEMORY_SCOPE_WORK_GROUP = @as(c_int, 1);
//pub const __OPENCL_MEMORY_SCOPE_DEVICE = @as(c_int, 2);
//pub const __OPENCL_MEMORY_SCOPE_ALL_SVM_DEVICES = @as(c_int, 3);
//pub const __OPENCL_MEMORY_SCOPE_SUB_GROUP = @as(c_int, 4);
//pub const __FPCLASS_SNAN = @as(c_int, 0x0001);
//pub const __FPCLASS_QNAN = @as(c_int, 0x0002);
//pub const __FPCLASS_NEGINF = @as(c_int, 0x0004);
//pub const __FPCLASS_NEGNORMAL = @as(c_int, 0x0008);
//pub const __FPCLASS_NEGSUBNORMAL = @as(c_int, 0x0010);
//pub const __FPCLASS_NEGZERO = @as(c_int, 0x0020);
//pub const __FPCLASS_POSZERO = @as(c_int, 0x0040);
//pub const __FPCLASS_POSSUBNORMAL = @as(c_int, 0x0080);
//pub const __FPCLASS_POSNORMAL = @as(c_int, 0x0100);
//pub const __FPCLASS_POSINF = @as(c_int, 0x0200);
//pub const __PRAGMA_REDEFINE_EXTNAME = @as(c_int, 1);
//pub const __VERSION__ = "Clang 18.1.6 (https://github.com/ziglang/zig-bootstrap 98bc6bf4fc4009888d33941daf6b600d20a42a56)";
//pub const __OBJC_BOOL_IS_BOOL = @as(c_int, 0);
//pub const __CONSTANT_CFSTRINGS__ = @as(c_int, 1);
//pub const __SEH__ = @as(c_int, 1);
//pub const __clang_literal_encoding__ = "UTF-8";
//pub const __clang_wide_literal_encoding__ = "UTF-16";
//pub const __ORDER_LITTLE_ENDIAN__ = @as(c_int, 1234);
//pub const __ORDER_BIG_ENDIAN__ = @as(c_int, 4321);
//pub const __ORDER_PDP_ENDIAN__ = @as(c_int, 3412);
//pub const __BYTE_ORDER__ = __ORDER_LITTLE_ENDIAN__;
//pub const __LITTLE_ENDIAN__ = @as(c_int, 1);
//pub const __CHAR_BIT__ = @as(c_int, 8);
//pub const __BOOL_WIDTH__ = @as(c_int, 8);
//pub const __SHRT_WIDTH__ = @as(c_int, 16);
//pub const __INT_WIDTH__ = @as(c_int, 32);
//pub const __LONG_WIDTH__ = @as(c_int, 32);
//pub const __LLONG_WIDTH__ = @as(c_int, 64);
//pub const __BITINT_MAXWIDTH__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 8388608, .decimal);
//pub const __SCHAR_MAX__ = @as(c_int, 127);
//pub const __SHRT_MAX__ = @as(c_int, 32767);
//pub const __INT_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
//pub const __LONG_MAX__ = @as(c_long, 2147483647);
//pub const __LONG_LONG_MAX__ = @as(c_longlong, 9223372036854775807);
//pub const __WCHAR_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
//pub const __WCHAR_WIDTH__ = @as(c_int, 16);
//pub const __WINT_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
//pub const __WINT_WIDTH__ = @as(c_int, 16);
//pub const __INTMAX_MAX__ = @as(c_longlong, 9223372036854775807);
//pub const __INTMAX_WIDTH__ = @as(c_int, 64);
//pub const __SIZE_MAX__ = @as(c_ulonglong, 18446744073709551615);
//pub const __SIZE_WIDTH__ = @as(c_int, 64);
//pub const __UINTMAX_MAX__ = @as(c_ulonglong, 18446744073709551615);
//pub const __UINTMAX_WIDTH__ = @as(c_int, 64);
//pub const __PTRDIFF_MAX__ = @as(c_longlong, 9223372036854775807);
//pub const __PTRDIFF_WIDTH__ = @as(c_int, 64);
//pub const __INTPTR_MAX__ = @as(c_longlong, 9223372036854775807);
//pub const __INTPTR_WIDTH__ = @as(c_int, 64);
//pub const __UINTPTR_MAX__ = @as(c_ulonglong, 18446744073709551615);
//pub const __UINTPTR_WIDTH__ = @as(c_int, 64);
//pub const __SIZEOF_DOUBLE__ = @as(c_int, 8);
//pub const __SIZEOF_FLOAT__ = @as(c_int, 4);
//pub const __SIZEOF_INT__ = @as(c_int, 4);
//pub const __SIZEOF_LONG__ = @as(c_int, 4);
//pub const __SIZEOF_LONG_DOUBLE__ = @as(c_int, 16);
//pub const __SIZEOF_LONG_LONG__ = @as(c_int, 8);
//pub const __SIZEOF_POINTER__ = @as(c_int, 8);
//pub const __SIZEOF_SHORT__ = @as(c_int, 2);
//pub const __SIZEOF_PTRDIFF_T__ = @as(c_int, 8);
//pub const __SIZEOF_SIZE_T__ = @as(c_int, 8);
//pub const __SIZEOF_WCHAR_T__ = @as(c_int, 2);
//pub const __SIZEOF_WINT_T__ = @as(c_int, 2);
//pub const __SIZEOF_INT128__ = @as(c_int, 16);
//pub const __INTMAX_TYPE__ = c_longlong;
//pub const __INTMAX_FMTd__ = "lld";
//pub const __INTMAX_FMTi__ = "lli";
//pub const __INTMAX_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `LL`");
//// (no file):94:9
//pub const __UINTMAX_TYPE__ = c_ulonglong;
//pub const __UINTMAX_FMTo__ = "llo";
//pub const __UINTMAX_FMTu__ = "llu";
//pub const __UINTMAX_FMTx__ = "llx";
//pub const __UINTMAX_FMTX__ = "llX";
//pub const __UINTMAX_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `ULL`");
//// (no file):100:9
//pub const __PTRDIFF_TYPE__ = c_longlong;
//pub const __PTRDIFF_FMTd__ = "lld";
//pub const __PTRDIFF_FMTi__ = "lli";
//pub const __INTPTR_TYPE__ = c_longlong;
//pub const __INTPTR_FMTd__ = "lld";
//pub const __INTPTR_FMTi__ = "lli";
//pub const __SIZE_TYPE__ = c_ulonglong;
//pub const __SIZE_FMTo__ = "llo";
//pub const __SIZE_FMTu__ = "llu";
//pub const __SIZE_FMTx__ = "llx";
//pub const __SIZE_FMTX__ = "llX";
//pub const __WCHAR_TYPE__ = c_ushort;
//pub const __WINT_TYPE__ = c_ushort;
//pub const __SIG_ATOMIC_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
//pub const __SIG_ATOMIC_WIDTH__ = @as(c_int, 32);
//pub const __CHAR16_TYPE__ = c_ushort;
//pub const __CHAR32_TYPE__ = c_uint;
//pub const __UINTPTR_TYPE__ = c_ulonglong;
//pub const __UINTPTR_FMTo__ = "llo";
//pub const __UINTPTR_FMTu__ = "llu";
//pub const __UINTPTR_FMTx__ = "llx";
//pub const __UINTPTR_FMTX__ = "llX";
//pub const __FLT16_DENORM_MIN__ = @as(f16, 5.9604644775390625e-8);
//pub const __FLT16_HAS_DENORM__ = @as(c_int, 1);
//pub const __FLT16_DIG__ = @as(c_int, 3);
//pub const __FLT16_DECIMAL_DIG__ = @as(c_int, 5);
//pub const __FLT16_EPSILON__ = @as(f16, 9.765625e-4);
//pub const __FLT16_HAS_INFINITY__ = @as(c_int, 1);
//pub const __FLT16_HAS_QUIET_NAN__ = @as(c_int, 1);
//pub const __FLT16_MANT_DIG__ = @as(c_int, 11);
//pub const __FLT16_MAX_10_EXP__ = @as(c_int, 4);
//pub const __FLT16_MAX_EXP__ = @as(c_int, 16);
//pub const __FLT16_MAX__ = @as(f16, 6.5504e+4);
//pub const __FLT16_MIN_10_EXP__ = -@as(c_int, 4);
//pub const __FLT16_MIN_EXP__ = -@as(c_int, 13);
//pub const __FLT16_MIN__ = @as(f16, 6.103515625e-5);
//pub const __FLT_DENORM_MIN__ = @as(f32, 1.40129846e-45);
//pub const __FLT_HAS_DENORM__ = @as(c_int, 1);
//pub const __FLT_DIG__ = @as(c_int, 6);
//pub const __FLT_DECIMAL_DIG__ = @as(c_int, 9);
//pub const __FLT_EPSILON__ = @as(f32, 1.19209290e-7);
//pub const __FLT_HAS_INFINITY__ = @as(c_int, 1);
//pub const __FLT_HAS_QUIET_NAN__ = @as(c_int, 1);
//pub const __FLT_MANT_DIG__ = @as(c_int, 24);
//pub const __FLT_MAX_10_EXP__ = @as(c_int, 38);
//pub const __FLT_MAX_EXP__ = @as(c_int, 128);
//pub const __FLT_MAX__ = @as(f32, 3.40282347e+38);
//pub const __FLT_MIN_10_EXP__ = -@as(c_int, 37);
//pub const __FLT_MIN_EXP__ = -@as(c_int, 125);
//pub const __FLT_MIN__ = @as(f32, 1.17549435e-38);
//pub const __DBL_DENORM_MIN__ = @as(f64, 4.9406564584124654e-324);
//pub const __DBL_HAS_DENORM__ = @as(c_int, 1);
//pub const __DBL_DIG__ = @as(c_int, 15);
//pub const __DBL_DECIMAL_DIG__ = @as(c_int, 17);
//pub const __DBL_EPSILON__ = @as(f64, 2.2204460492503131e-16);
//pub const __DBL_HAS_INFINITY__ = @as(c_int, 1);
//pub const __DBL_HAS_QUIET_NAN__ = @as(c_int, 1);
//pub const __DBL_MANT_DIG__ = @as(c_int, 53);
//pub const __DBL_MAX_10_EXP__ = @as(c_int, 308);
//pub const __DBL_MAX_EXP__ = @as(c_int, 1024);
//pub const __DBL_MAX__ = @as(f64, 1.7976931348623157e+308);
//pub const __DBL_MIN_10_EXP__ = -@as(c_int, 307);
//pub const __DBL_MIN_EXP__ = -@as(c_int, 1021);
//pub const __DBL_MIN__ = @as(f64, 2.2250738585072014e-308);
//pub const __LDBL_DENORM_MIN__ = @as(c_longdouble, 3.64519953188247460253e-4951);
//pub const __LDBL_HAS_DENORM__ = @as(c_int, 1);
//pub const __LDBL_DIG__ = @as(c_int, 18);
//pub const __LDBL_DECIMAL_DIG__ = @as(c_int, 21);
//pub const __LDBL_EPSILON__ = @as(c_longdouble, 1.08420217248550443401e-19);
//pub const __LDBL_HAS_INFINITY__ = @as(c_int, 1);
//pub const __LDBL_HAS_QUIET_NAN__ = @as(c_int, 1);
//pub const __LDBL_MANT_DIG__ = @as(c_int, 64);
//pub const __LDBL_MAX_10_EXP__ = @as(c_int, 4932);
//pub const __LDBL_MAX_EXP__ = @as(c_int, 16384);
//pub const __LDBL_MAX__ = @as(c_longdouble, 1.18973149535723176502e+4932);
//pub const __LDBL_MIN_10_EXP__ = -@as(c_int, 4931);
//pub const __LDBL_MIN_EXP__ = -@as(c_int, 16381);
//pub const __LDBL_MIN__ = @as(c_longdouble, 3.36210314311209350626e-4932);
//pub const __POINTER_WIDTH__ = @as(c_int, 64);
//pub const __BIGGEST_ALIGNMENT__ = @as(c_int, 16);
//pub const __WCHAR_UNSIGNED__ = @as(c_int, 1);
//pub const __WINT_UNSIGNED__ = @as(c_int, 1);
//pub const __INT8_TYPE__ = i8;
//pub const __INT8_FMTd__ = "hhd";
//pub const __INT8_FMTi__ = "hhi";
//pub const __INT8_C_SUFFIX__ = "";
//pub const __INT16_TYPE__ = c_short;
//pub const __INT16_FMTd__ = "hd";
//pub const __INT16_FMTi__ = "hi";
//pub const __INT16_C_SUFFIX__ = "";
//pub const __INT32_TYPE__ = c_int;
//pub const __INT32_FMTd__ = "d";
//pub const __INT32_FMTi__ = "i";
//pub const __INT32_C_SUFFIX__ = "";
//pub const __INT64_TYPE__ = c_longlong;
//pub const __INT64_FMTd__ = "lld";
//pub const __INT64_FMTi__ = "lli";
//pub const __INT64_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `LL`");
//// (no file):198:9
//pub const __UINT8_TYPE__ = u8;
//pub const __UINT8_FMTo__ = "hho";
//pub const __UINT8_FMTu__ = "hhu";
//pub const __UINT8_FMTx__ = "hhx";
//pub const __UINT8_FMTX__ = "hhX";
//pub const __UINT8_C_SUFFIX__ = "";
//pub const __UINT8_MAX__ = @as(c_int, 255);
//pub const __INT8_MAX__ = @as(c_int, 127);
//pub const __UINT16_TYPE__ = c_ushort;
//pub const __UINT16_FMTo__ = "ho";
//pub const __UINT16_FMTu__ = "hu";
//pub const __UINT16_FMTx__ = "hx";
//pub const __UINT16_FMTX__ = "hX";
//pub const __UINT16_C_SUFFIX__ = "";
//pub const __UINT16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
//pub const __INT16_MAX__ = @as(c_int, 32767);
//pub const __UINT32_TYPE__ = c_uint;
//pub const __UINT32_FMTo__ = "o";
//pub const __UINT32_FMTu__ = "u";
//pub const __UINT32_FMTx__ = "x";
//pub const __UINT32_FMTX__ = "X";
//pub const __UINT32_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `U`");
//// (no file):220:9
//pub const __UINT32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
//pub const __INT32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
//pub const __UINT64_TYPE__ = c_ulonglong;
//pub const __UINT64_FMTo__ = "llo";
//pub const __UINT64_FMTu__ = "llu";
//pub const __UINT64_FMTx__ = "llx";
//pub const __UINT64_FMTX__ = "llX";
//pub const __UINT64_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `ULL`");
//// (no file):228:9
//pub const __UINT64_MAX__ = @as(c_ulonglong, 18446744073709551615);
//pub const __INT64_MAX__ = @as(c_longlong, 9223372036854775807);
//pub const __INT_LEAST8_TYPE__ = i8;
//pub const __INT_LEAST8_MAX__ = @as(c_int, 127);
//pub const __INT_LEAST8_WIDTH__ = @as(c_int, 8);
//pub const __INT_LEAST8_FMTd__ = "hhd";
//pub const __INT_LEAST8_FMTi__ = "hhi";
//pub const __UINT_LEAST8_TYPE__ = u8;
//pub const __UINT_LEAST8_MAX__ = @as(c_int, 255);
//pub const __UINT_LEAST8_FMTo__ = "hho";
//pub const __UINT_LEAST8_FMTu__ = "hhu";
//pub const __UINT_LEAST8_FMTx__ = "hhx";
//pub const __UINT_LEAST8_FMTX__ = "hhX";
//pub const __INT_LEAST16_TYPE__ = c_short;
//pub const __INT_LEAST16_MAX__ = @as(c_int, 32767);
//pub const __INT_LEAST16_WIDTH__ = @as(c_int, 16);
//pub const __INT_LEAST16_FMTd__ = "hd";
//pub const __INT_LEAST16_FMTi__ = "hi";
//pub const __UINT_LEAST16_TYPE__ = c_ushort;
//pub const __UINT_LEAST16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
//pub const __UINT_LEAST16_FMTo__ = "ho";
//pub const __UINT_LEAST16_FMTu__ = "hu";
//pub const __UINT_LEAST16_FMTx__ = "hx";
//pub const __UINT_LEAST16_FMTX__ = "hX";
//pub const __INT_LEAST32_TYPE__ = c_int;
//pub const __INT_LEAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
//pub const __INT_LEAST32_WIDTH__ = @as(c_int, 32);
//pub const __INT_LEAST32_FMTd__ = "d";
//pub const __INT_LEAST32_FMTi__ = "i";
//pub const __UINT_LEAST32_TYPE__ = c_uint;
//pub const __UINT_LEAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
//pub const __UINT_LEAST32_FMTo__ = "o";
//pub const __UINT_LEAST32_FMTu__ = "u";
//pub const __UINT_LEAST32_FMTx__ = "x";
//pub const __UINT_LEAST32_FMTX__ = "X";
//pub const __INT_LEAST64_TYPE__ = c_longlong;
//pub const __INT_LEAST64_MAX__ = @as(c_longlong, 9223372036854775807);
//pub const __INT_LEAST64_WIDTH__ = @as(c_int, 64);
//pub const __INT_LEAST64_FMTd__ = "lld";
//pub const __INT_LEAST64_FMTi__ = "lli";
//pub const __UINT_LEAST64_TYPE__ = c_ulonglong;
//pub const __UINT_LEAST64_MAX__ = @as(c_ulonglong, 18446744073709551615);
//pub const __UINT_LEAST64_FMTo__ = "llo";
//pub const __UINT_LEAST64_FMTu__ = "llu";
//pub const __UINT_LEAST64_FMTx__ = "llx";
//pub const __UINT_LEAST64_FMTX__ = "llX";
//pub const __INT_FAST8_TYPE__ = i8;
//pub const __INT_FAST8_MAX__ = @as(c_int, 127);
//pub const __INT_FAST8_WIDTH__ = @as(c_int, 8);
//pub const __INT_FAST8_FMTd__ = "hhd";
//pub const __INT_FAST8_FMTi__ = "hhi";
//pub const __UINT_FAST8_TYPE__ = u8;
//pub const __UINT_FAST8_MAX__ = @as(c_int, 255);
//pub const __UINT_FAST8_FMTo__ = "hho";
//pub const __UINT_FAST8_FMTu__ = "hhu";
//pub const __UINT_FAST8_FMTx__ = "hhx";
//pub const __UINT_FAST8_FMTX__ = "hhX";
//pub const __INT_FAST16_TYPE__ = c_short;
//pub const __INT_FAST16_MAX__ = @as(c_int, 32767);
//pub const __INT_FAST16_WIDTH__ = @as(c_int, 16);
//pub const __INT_FAST16_FMTd__ = "hd";
//pub const __INT_FAST16_FMTi__ = "hi";
//pub const __UINT_FAST16_TYPE__ = c_ushort;
//pub const __UINT_FAST16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
//pub const __UINT_FAST16_FMTo__ = "ho";
//pub const __UINT_FAST16_FMTu__ = "hu";
//pub const __UINT_FAST16_FMTx__ = "hx";
//pub const __UINT_FAST16_FMTX__ = "hX";
//pub const __INT_FAST32_TYPE__ = c_int;
//pub const __INT_FAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
//pub const __INT_FAST32_WIDTH__ = @as(c_int, 32);
//pub const __INT_FAST32_FMTd__ = "d";
//pub const __INT_FAST32_FMTi__ = "i";
//pub const __UINT_FAST32_TYPE__ = c_uint;
//pub const __UINT_FAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
//pub const __UINT_FAST32_FMTo__ = "o";
//pub const __UINT_FAST32_FMTu__ = "u";
//pub const __UINT_FAST32_FMTx__ = "x";
//pub const __UINT_FAST32_FMTX__ = "X";
//pub const __INT_FAST64_TYPE__ = c_longlong;
//pub const __INT_FAST64_MAX__ = @as(c_longlong, 9223372036854775807);
//pub const __INT_FAST64_WIDTH__ = @as(c_int, 64);
//pub const __INT_FAST64_FMTd__ = "lld";
//pub const __INT_FAST64_FMTi__ = "lli";
//pub const __UINT_FAST64_TYPE__ = c_ulonglong;
//pub const __UINT_FAST64_MAX__ = @as(c_ulonglong, 18446744073709551615);
//pub const __UINT_FAST64_FMTo__ = "llo";
//pub const __UINT_FAST64_FMTu__ = "llu";
//pub const __UINT_FAST64_FMTx__ = "llx";
//pub const __UINT_FAST64_FMTX__ = "llX";
//pub const __USER_LABEL_PREFIX__ = "";
//pub const __FINITE_MATH_ONLY__ = @as(c_int, 0);
//pub const __GNUC_STDC_INLINE__ = @as(c_int, 1);
//pub const __GCC_ATOMIC_TEST_AND_SET_TRUEVAL = @as(c_int, 1);
//pub const __CLANG_ATOMIC_BOOL_LOCK_FREE = @as(c_int, 2);
//pub const __CLANG_ATOMIC_CHAR_LOCK_FREE = @as(c_int, 2);
//pub const __CLANG_ATOMIC_CHAR16_T_LOCK_FREE = @as(c_int, 2);
//pub const __CLANG_ATOMIC_CHAR32_T_LOCK_FREE = @as(c_int, 2);
//pub const __CLANG_ATOMIC_WCHAR_T_LOCK_FREE = @as(c_int, 2);
//pub const __CLANG_ATOMIC_SHORT_LOCK_FREE = @as(c_int, 2);
//pub const __CLANG_ATOMIC_INT_LOCK_FREE = @as(c_int, 2);
//pub const __CLANG_ATOMIC_LONG_LOCK_FREE = @as(c_int, 2);
//pub const __CLANG_ATOMIC_LLONG_LOCK_FREE = @as(c_int, 2);
//pub const __CLANG_ATOMIC_POINTER_LOCK_FREE = @as(c_int, 2);
//pub const __GCC_ATOMIC_BOOL_LOCK_FREE = @as(c_int, 2);
//pub const __GCC_ATOMIC_CHAR_LOCK_FREE = @as(c_int, 2);
//pub const __GCC_ATOMIC_CHAR16_T_LOCK_FREE = @as(c_int, 2);
//pub const __GCC_ATOMIC_CHAR32_T_LOCK_FREE = @as(c_int, 2);
//pub const __GCC_ATOMIC_WCHAR_T_LOCK_FREE = @as(c_int, 2);
//pub const __GCC_ATOMIC_SHORT_LOCK_FREE = @as(c_int, 2);
//pub const __GCC_ATOMIC_INT_LOCK_FREE = @as(c_int, 2);
//pub const __GCC_ATOMIC_LONG_LOCK_FREE = @as(c_int, 2);
//pub const __GCC_ATOMIC_LLONG_LOCK_FREE = @as(c_int, 2);
//pub const __GCC_ATOMIC_POINTER_LOCK_FREE = @as(c_int, 2);
//pub const __NO_INLINE__ = @as(c_int, 1);
//pub const __PIC__ = @as(c_int, 2);
//pub const __pic__ = @as(c_int, 2);
//pub const __FLT_RADIX__ = @as(c_int, 2);
//pub const __DECIMAL_DIG__ = __LDBL_DECIMAL_DIG__;
//pub const __SSP_STRONG__ = @as(c_int, 2);
//pub const __GCC_ASM_FLAG_OUTPUTS__ = @as(c_int, 1);
//pub const __code_model_small__ = @as(c_int, 1);
//pub const __amd64__ = @as(c_int, 1);
//pub const __amd64 = @as(c_int, 1);
//pub const __x86_64 = @as(c_int, 1);
//pub const __x86_64__ = @as(c_int, 1);
//pub const __SEG_GS = @as(c_int, 1);
//pub const __SEG_FS = @as(c_int, 1);
//pub const __seg_gs = @compileError("unable to translate macro: undefined identifier `address_space`");
//// (no file):357:9
//pub const __seg_fs = @compileError("unable to translate macro: undefined identifier `address_space`");
//// (no file):358:9
//pub const __k8 = @as(c_int, 1);
//pub const __k8__ = @as(c_int, 1);
//pub const __tune_k8__ = @as(c_int, 1);
//pub const __REGISTER_PREFIX__ = "";
//pub const __NO_MATH_INLINES = @as(c_int, 1);
//pub const __AES__ = @as(c_int, 1);
//pub const __VAES__ = @as(c_int, 1);
//pub const __PCLMUL__ = @as(c_int, 1);
//pub const __VPCLMULQDQ__ = @as(c_int, 1);
//pub const __LAHF_SAHF__ = @as(c_int, 1);
//pub const __LZCNT__ = @as(c_int, 1);
//pub const __RDRND__ = @as(c_int, 1);
//pub const __FSGSBASE__ = @as(c_int, 1);
//pub const __BMI__ = @as(c_int, 1);
//pub const __BMI2__ = @as(c_int, 1);
//pub const __POPCNT__ = @as(c_int, 1);
//pub const __PRFCHW__ = @as(c_int, 1);
//pub const __RDSEED__ = @as(c_int, 1);
//pub const __ADX__ = @as(c_int, 1);
//pub const __MOVBE__ = @as(c_int, 1);
//pub const __FMA__ = @as(c_int, 1);
//pub const __F16C__ = @as(c_int, 1);
//pub const __GFNI__ = @as(c_int, 1);
//pub const __SHA__ = @as(c_int, 1);
//pub const __FXSR__ = @as(c_int, 1);
//pub const __XSAVE__ = @as(c_int, 1);
//pub const __XSAVEOPT__ = @as(c_int, 1);
//pub const __XSAVEC__ = @as(c_int, 1);
//pub const __XSAVES__ = @as(c_int, 1);
//pub const __CLFLUSHOPT__ = @as(c_int, 1);
//pub const __CLWB__ = @as(c_int, 1);
//pub const __SHSTK__ = @as(c_int, 1);
//pub const __RDPID__ = @as(c_int, 1);
//pub const __WAITPKG__ = @as(c_int, 1);
//pub const __MOVDIRI__ = @as(c_int, 1);
//pub const __MOVDIR64B__ = @as(c_int, 1);
//pub const __PTWRITE__ = @as(c_int, 1);
//pub const __INVPCID__ = @as(c_int, 1);
//pub const __AVX2__ = @as(c_int, 1);
//pub const __AVX__ = @as(c_int, 1);
//pub const __SSE4_2__ = @as(c_int, 1);
//pub const __SSE4_1__ = @as(c_int, 1);
//pub const __SSSE3__ = @as(c_int, 1);
//pub const __SSE3__ = @as(c_int, 1);
//pub const __SSE2__ = @as(c_int, 1);
//pub const __SSE2_MATH__ = @as(c_int, 1);
//pub const __SSE__ = @as(c_int, 1);
//pub const __SSE_MATH__ = @as(c_int, 1);
//pub const __MMX__ = @as(c_int, 1);
//pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_1 = @as(c_int, 1);
//pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_2 = @as(c_int, 1);
//pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_4 = @as(c_int, 1);
//pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_8 = @as(c_int, 1);
//pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_16 = @as(c_int, 1);
//pub const __SIZEOF_FLOAT128__ = @as(c_int, 16);
//pub const _WIN32 = @as(c_int, 1);
//pub const _WIN64 = @as(c_int, 1);
//pub const WIN32 = @as(c_int, 1);
//pub const __WIN32 = @as(c_int, 1);
//pub const __WIN32__ = @as(c_int, 1);
//pub const WINNT = @as(c_int, 1);
//pub const __WINNT = @as(c_int, 1);
//pub const __WINNT__ = @as(c_int, 1);
//pub const WIN64 = @as(c_int, 1);
//pub const __WIN64 = @as(c_int, 1);
//pub const __WIN64__ = @as(c_int, 1);
//pub const __MINGW64__ = @as(c_int, 1);
//pub const __MSVCRT__ = @as(c_int, 1);
//pub const __MINGW32__ = @as(c_int, 1);
//pub const __declspec = @compileError("unable to translate C expr: unexpected token '__attribute__'");
//// (no file):428:9
//pub const _cdecl = @compileError("unable to translate macro: undefined identifier `__cdecl__`");
//// (no file):429:9
//pub const __cdecl = @compileError("unable to translate macro: undefined identifier `__cdecl__`");
//// (no file):430:9
//pub const _stdcall = @compileError("unable to translate macro: undefined identifier `__stdcall__`");
//// (no file):431:9
//pub const __stdcall = @compileError("unable to translate macro: undefined identifier `__stdcall__`");
//// (no file):432:9
//pub const _fastcall = @compileError("unable to translate macro: undefined identifier `__fastcall__`");
//// (no file):433:9
//pub const __fastcall = @compileError("unable to translate macro: undefined identifier `__fastcall__`");
//// (no file):434:9
//pub const _thiscall = @compileError("unable to translate macro: undefined identifier `__thiscall__`");
//// (no file):435:9
//pub const __thiscall = @compileError("unable to translate macro: undefined identifier `__thiscall__`");
//// (no file):436:9
//pub const _pascal = @compileError("unable to translate macro: undefined identifier `__pascal__`");
//// (no file):437:9
//pub const __pascal = @compileError("unable to translate macro: undefined identifier `__pascal__`");
//// (no file):438:9
//pub const __STDC__ = @as(c_int, 1);
//pub const __STDC_HOSTED__ = @as(c_int, 1);
//pub const __STDC_VERSION__ = @as(c_long, 201710);
//pub const __STDC_UTF_16__ = @as(c_int, 1);
//pub const __STDC_UTF_32__ = @as(c_int, 1);
//pub const _LIBCPP_DISABLE_VISIBILITY_ANNOTATIONS = @as(c_int, 1);
//pub const _LIBCXXABI_DISABLE_VISIBILITY_ANNOTATIONS = @as(c_int, 1);
//pub const _LIBCPP_HAS_NO_VENDOR_AVAILABILITY_ANNOTATIONS = @as(c_int, 1);
//pub const _LIBCPP_PSTL_CPU_BACKEND_SERIAL = @as(c_int, 1);
//pub const _LIBCPP_ABI_VERSION = @as(c_int, 1);
//pub const _LIBCPP_ABI_NAMESPACE = @compileError("unable to translate macro: undefined identifier `__1`");
//// (no file):450:9
//pub const _LIBCPP_HARDENING_MODE = @compileError("unable to translate macro: undefined identifier `_LIBCPP_HARDENING_MODE_DEBUG`");
//// (no file):451:9
//pub const __MSVCRT_VERSION__ = @as(c_int, 0xE00);
//pub const _WIN32_WINNT = @as(c_int, 0x0a00);
//pub const _DEBUG = @as(c_int, 1);
//pub const SDL_video_h_ = "";
//pub const SDL_stdinc_h_ = "";
//pub const SDL_platform_defines_h_ = "";
//pub const SDL_PLATFORM_WINDOWS = @as(c_int, 1);
//pub const HAVE_WINAPIFAMILY_H = @as(c_int, 0);
//pub const WINAPI_FAMILY_WINRT = @as(c_int, 0);
//pub const SDL_WINAPI_FAMILY_PHONE = @as(c_int, 0);
//pub const SDL_PLATFORM_WIN32 = @as(c_int, 1);
//pub const _LIBCPP_INTTYPES_H = "";
//pub const _LIBCPP___CONFIG = "";
//pub const _LIBCPP_COMPILER_CLANG_BASED = "";
//pub const _LIBCPP_CLANG_VER = (__clang_major__ * @as(c_int, 100)) + __clang_minor__;
//pub const __CLANG_INTTYPES_H = "";
//pub const _INTTYPES_H_ = "";
//pub const _INC_CRTDEFS = "";
//pub const _INC_CORECRT = "";
//pub const _INC__MINGW_H = "";
//pub const _INC_CRTDEFS_MACRO = "";
//pub const __STRINGIFY = @compileError("unable to translate C expr: unexpected token '#'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:10:9
//pub inline fn __MINGW64_STRINGIFY(x: anytype) @TypeOf(__STRINGIFY(x)) {
//    _ = &x;
//    return __STRINGIFY(x);
//}
//pub const __MINGW64_VERSION_MAJOR = @as(c_int, 12);
//pub const __MINGW64_VERSION_MINOR = @as(c_int, 0);
//pub const __MINGW64_VERSION_BUGFIX = @as(c_int, 0);
//pub const __MINGW64_VERSION_RC = @as(c_int, 0);
//pub const __MINGW64_VERSION_STR = __MINGW64_STRINGIFY(__MINGW64_VERSION_MAJOR) ++ "." ++ __MINGW64_STRINGIFY(__MINGW64_VERSION_MINOR) ++ "." ++ __MINGW64_STRINGIFY(__MINGW64_VERSION_BUGFIX);
//pub const __MINGW64_VERSION_STATE = "alpha";
//pub const __MINGW32_MAJOR_VERSION = @as(c_int, 3);
//pub const __MINGW32_MINOR_VERSION = @as(c_int, 11);
//pub const _M_AMD64 = @as(c_int, 100);
//pub const _M_X64 = @as(c_int, 100);
//pub const @"_" = @as(c_int, 1);
//pub const __MINGW_USE_UNDERSCORE_PREFIX = @as(c_int, 0);
//pub const __MINGW_IMP_SYMBOL = @compileError("unable to translate macro: undefined identifier `__imp_`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:119:11
//pub const __MINGW_IMP_LSYMBOL = @compileError("unable to translate macro: undefined identifier `__imp_`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:120:11
//pub inline fn __MINGW_USYMBOL(sym: anytype) @TypeOf(sym) {
//    _ = &sym;
//    return sym;
//}
//pub const __MINGW_LSYMBOL = @compileError("unable to translate C expr: unexpected token '##'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:122:11
//pub const __MINGW_ASM_CALL = @compileError("unable to translate C expr: unexpected token '__asm__'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:130:9
//pub const __MINGW_ASM_CRT_CALL = @compileError("unable to translate C expr: unexpected token '__asm__'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:131:9
//pub const __MINGW_EXTENSION = @compileError("unable to translate C expr: unexpected token '__extension__'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:163:13
//pub const __C89_NAMELESS = __MINGW_EXTENSION;
//pub const __C89_NAMELESSSTRUCTNAME = "";
//pub const __C89_NAMELESSSTRUCTNAME1 = "";
//pub const __C89_NAMELESSSTRUCTNAME2 = "";
//pub const __C89_NAMELESSSTRUCTNAME3 = "";
//pub const __C89_NAMELESSSTRUCTNAME4 = "";
//pub const __C89_NAMELESSSTRUCTNAME5 = "";
//pub const __C89_NAMELESSUNIONNAME = "";
//pub const __C89_NAMELESSUNIONNAME1 = "";
//pub const __C89_NAMELESSUNIONNAME2 = "";
//pub const __C89_NAMELESSUNIONNAME3 = "";
//pub const __C89_NAMELESSUNIONNAME4 = "";
//pub const __C89_NAMELESSUNIONNAME5 = "";
//pub const __C89_NAMELESSUNIONNAME6 = "";
//pub const __C89_NAMELESSUNIONNAME7 = "";
//pub const __C89_NAMELESSUNIONNAME8 = "";
//pub const __GNU_EXTENSION = __MINGW_EXTENSION;
//pub const __MINGW_HAVE_ANSI_C99_PRINTF = @as(c_int, 1);
//pub const __MINGW_HAVE_WIDE_C99_PRINTF = @as(c_int, 1);
//pub const __MINGW_HAVE_ANSI_C99_SCANF = @as(c_int, 1);
//pub const __MINGW_HAVE_WIDE_C99_SCANF = @as(c_int, 1);
//pub const __MINGW_POISON_NAME = @compileError("unable to translate macro: undefined identifier `_layout_has_not_been_verified_and_its_declaration_is_most_likely_incorrect`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:203:11
//pub const __MSABI_LONG = @import("std").zig.c_translation.Macros.L_SUFFIX;
//pub const __MINGW_GCC_VERSION = ((__GNUC__ * @as(c_int, 10000)) + (__GNUC_MINOR__ * @as(c_int, 100))) + __GNUC_PATCHLEVEL__;
//pub inline fn __MINGW_GNUC_PREREQ(major: anytype, minor: anytype) @TypeOf((__GNUC__ > major) or ((__GNUC__ == major) and (__GNUC_MINOR__ >= minor))) {
//    _ = &major;
//    _ = &minor;
//    return (__GNUC__ > major) or ((__GNUC__ == major) and (__GNUC_MINOR__ >= minor));
//}
//pub inline fn __MINGW_MSC_PREREQ(major: anytype, minor: anytype) @TypeOf(@as(c_int, 0)) {
//    _ = &major;
//    _ = &minor;
//    return @as(c_int, 0);
//}
//pub const __MINGW_ATTRIB_DEPRECATED_STR = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:247:11
//pub const __MINGW_SEC_WARN_STR = "This function or variable may be unsafe, use _CRT_SECURE_NO_WARNINGS to disable deprecation";
//pub const __MINGW_MSVC2005_DEPREC_STR = "This POSIX function is deprecated beginning in Visual C++ 2005, use _CRT_NONSTDC_NO_DEPRECATE to disable deprecation";
//pub const __MINGW_ATTRIB_DEPRECATED_MSVC2005 = __MINGW_ATTRIB_DEPRECATED_STR(__MINGW_MSVC2005_DEPREC_STR);
//pub const __MINGW_ATTRIB_DEPRECATED_SEC_WARN = __MINGW_ATTRIB_DEPRECATED_STR(__MINGW_SEC_WARN_STR);
//pub const __MINGW_MS_PRINTF = @compileError("unable to translate macro: undefined identifier `__format__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:270:9
//pub const __MINGW_MS_SCANF = @compileError("unable to translate macro: undefined identifier `__format__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:273:9
//pub const __MINGW_GNU_PRINTF = @compileError("unable to translate macro: undefined identifier `__format__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:276:9
//pub const __MINGW_GNU_SCANF = @compileError("unable to translate macro: undefined identifier `__format__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:279:9
//pub const __mingw_ovr = @compileError("unable to translate macro: undefined identifier `__unused__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:289:11
//pub const __mingw_static_ovr = __mingw_ovr;
//pub const __mingw_attribute_artificial = @compileError("unable to translate macro: undefined identifier `__artificial__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:298:11
//pub const __MINGW_SELECTANY = @compileError("unable to translate macro: undefined identifier `__selectany__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:304:9
//pub const __MINGW_FORTIFY_LEVEL = @as(c_int, 0);
//pub const __mingw_bos_ovr = __mingw_ovr;
//pub const __MINGW_FORTIFY_VA_ARG = @as(c_int, 0);
//pub const _INC_MINGW_SECAPI = "";
//pub const _CRT_SECURE_CPP_OVERLOAD_SECURE_NAMES = @as(c_int, 0);
//pub const _CRT_SECURE_CPP_OVERLOAD_SECURE_NAMES_MEMORY = @as(c_int, 0);
//pub const _CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES = @as(c_int, 0);
//pub const _CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES_COUNT = @as(c_int, 0);
//pub const _CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES_MEMORY = @as(c_int, 0);
//pub const __MINGW_CRT_NAME_CONCAT2 = @compileError("unable to translate macro: undefined identifier `_s`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_secapi.h:41:9
//pub const __CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES_MEMORY_0_3_ = @compileError("unable to translate C expr: unexpected token ';'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_secapi.h:69:9
//pub const __LONG32 = c_long;
//pub const __MINGW_IMPORT = @compileError("unable to translate macro: undefined identifier `__dllimport__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:44:12
//pub const __USE_CRTIMP = @as(c_int, 1);
//pub const _CRTIMP = @compileError("unable to translate macro: undefined identifier `__dllimport__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:52:15
//pub const __DECLSPEC_SUPPORTED = "";
//pub const USE___UUIDOF = @as(c_int, 0);
//pub const _inline = @compileError("unable to translate C expr: unexpected token '__inline'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:74:9
//pub const __CRT_INLINE = @compileError("unable to translate macro: undefined identifier `__gnu_inline__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:83:11
//pub const __MINGW_INTRIN_INLINE = @compileError("unable to translate macro: undefined identifier `__always_inline__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:90:9
//pub const __CRT__NO_INLINE = @as(c_int, 1);
//pub const __UNUSED_PARAM = @compileError("unable to translate macro: undefined identifier `__unused__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:104:11
//pub const __restrict_arr = @compileError("unable to translate C expr: unexpected token '__restrict'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:119:10
//pub const __MINGW_ATTRIB_NORETURN = @compileError("unable to translate macro: undefined identifier `__noreturn__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:135:9
//pub const __MINGW_ATTRIB_CONST = @compileError("unable to translate C expr: unexpected token '__attribute__'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:136:9
//pub const __MINGW_ATTRIB_MALLOC = @compileError("unable to translate macro: undefined identifier `__malloc__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:146:9
//pub const __MINGW_ATTRIB_PURE = @compileError("unable to translate macro: undefined identifier `__pure__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:147:9
//pub const __MINGW_ATTRIB_NONNULL = @compileError("unable to translate macro: undefined identifier `__nonnull__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:160:9
//pub const __MINGW_ATTRIB_UNUSED = @compileError("unable to translate macro: undefined identifier `__unused__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:166:9
//pub const __MINGW_ATTRIB_USED = @compileError("unable to translate macro: undefined identifier `__used__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:172:9
//pub const __MINGW_ATTRIB_DEPRECATED = @compileError("unable to translate macro: undefined identifier `__deprecated__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:173:9
//pub const __MINGW_ATTRIB_DEPRECATED_MSG = @compileError("unable to translate macro: undefined identifier `__deprecated__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:175:9
//pub const __MINGW_NOTHROW = @compileError("unable to translate macro: undefined identifier `__nothrow__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:190:9
//pub const __MINGW_ATTRIB_NO_OPTIMIZE = "";
//pub const __MINGW_PRAGMA_PARAM = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:208:9
//pub const __MINGW_BROKEN_INTERFACE = @compileError("unable to translate macro: undefined identifier `message`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:211:9
//pub const _UCRT = "";
//pub const _INT128_DEFINED = "";
//pub const __int8 = u8;
//pub const __int16 = c_short;
//pub const __int32 = c_int;
//pub const __int64 = c_longlong;
//pub const __ptr32 = "";
//pub const __ptr64 = "";
//pub const __unaligned = "";
//pub const __w64 = "";
//pub const __forceinline = @compileError("unable to translate macro: undefined identifier `__always_inline__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:266:9
//pub const __nothrow = "";
//pub const _INC_VADEFS = "";
//pub const MINGW_SDK_INIT = "";
//pub const MINGW_HAS_SECURE_API = @as(c_int, 1);
//pub const __STDC_SECURE_LIB__ = @as(c_long, 200411);
//pub const __GOT_SECURE_LIB__ = __STDC_SECURE_LIB__;
//pub const MINGW_DDK_H = "";
//pub const MINGW_HAS_DDK_H = @as(c_int, 1);
//pub const _CRT_PACKING = @as(c_int, 8);
//pub const __GNUC_VA_LIST = "";
//pub const _VA_LIST_DEFINED = "";
//pub inline fn _ADDRESSOF(v: anytype) @TypeOf(&v) {
//    _ = &v;
//    return &v;
//}
//pub const _crt_va_start = @compileError("unable to translate macro: undefined identifier `__builtin_va_start`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/vadefs.h:48:9
//pub const _crt_va_arg = @compileError("unable to translate C expr: unexpected token 'an identifier'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/vadefs.h:49:9
//pub const _crt_va_end = @compileError("unable to translate macro: undefined identifier `__builtin_va_end`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/vadefs.h:50:9
//pub const _crt_va_copy = @compileError("unable to translate macro: undefined identifier `__builtin_va_copy`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/vadefs.h:51:9
//pub const __CRT_STRINGIZE = @compileError("unable to translate C expr: unexpected token '#'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:285:9
//pub inline fn _CRT_STRINGIZE(_Value: anytype) @TypeOf(__CRT_STRINGIZE(_Value)) {
//    _ = &_Value;
//    return __CRT_STRINGIZE(_Value);
//}
//pub const __CRT_WIDE = @compileError("unable to translate macro: undefined identifier `L`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:290:9
//pub inline fn _CRT_WIDE(_String: anytype) @TypeOf(__CRT_WIDE(_String)) {
//    _ = &_String;
//    return __CRT_WIDE(_String);
//}
//pub const _W64 = "";
//pub const _CRTIMP_NOIA64 = _CRTIMP;
//pub const _CRTIMP2 = _CRTIMP;
//pub const _CRTIMP_ALTERNATIVE = _CRTIMP;
//pub const _CRT_ALTERNATIVE_IMPORTED = "";
//pub const _MRTIMP2 = _CRTIMP;
//pub const _DLL = "";
//pub const _MT = "";
//pub const _MCRTIMP = _CRTIMP;
//pub const _CRTIMP_PURE = _CRTIMP;
//pub const _PGLOBAL = "";
//pub const _AGLOBAL = "";
//pub const _SECURECRT_FILL_BUFFER_PATTERN = @as(c_int, 0xFD);
//pub const _CRT_DEPRECATE_TEXT = @compileError("unable to translate macro: undefined identifier `deprecated`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:349:9
//pub const _CRT_INSECURE_DEPRECATE_MEMORY = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:352:9
//pub const _CRT_INSECURE_DEPRECATE_GLOBALS = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:356:9
//pub const _CRT_MANAGED_HEAP_DEPRECATE = "";
//pub const _CRT_OBSOLETE = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:364:9
//pub const _CONST_RETURN = "";
//pub const UNALIGNED = "";
//pub const _CRT_ALIGN = @compileError("unable to translate macro: undefined identifier `__aligned__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:391:9
//pub const __CRTDECL = __cdecl;
//pub const _ARGMAX = @as(c_int, 100);
//pub const _TRUNCATE = @import("std").zig.c_translation.cast(usize, -@as(c_int, 1));
//pub inline fn _CRT_UNUSED(x: anytype) anyopaque {
//    _ = &x;
//    return @import("std").zig.c_translation.cast(anyopaque, x);
//}
//pub const __USE_MINGW_ANSI_STDIO = @as(c_int, 0);
//pub const _CRT_glob = @compileError("unable to translate macro: undefined identifier `_dowildcard`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:455:9
//pub const __ANONYMOUS_DEFINED = "";
//pub const _ANONYMOUS_UNION = __MINGW_EXTENSION;
//pub const _ANONYMOUS_STRUCT = __MINGW_EXTENSION;
//pub const _UNION_NAME = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:475:9
//pub const _STRUCT_NAME = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:476:9
//pub const DUMMYUNIONNAME = "";
//pub const DUMMYUNIONNAME1 = "";
//pub const DUMMYUNIONNAME2 = "";
//pub const DUMMYUNIONNAME3 = "";
//pub const DUMMYUNIONNAME4 = "";
//pub const DUMMYUNIONNAME5 = "";
//pub const DUMMYUNIONNAME6 = "";
//pub const DUMMYUNIONNAME7 = "";
//pub const DUMMYUNIONNAME8 = "";
//pub const DUMMYUNIONNAME9 = "";
//pub const DUMMYSTRUCTNAME = "";
//pub const DUMMYSTRUCTNAME1 = "";
//pub const DUMMYSTRUCTNAME2 = "";
//pub const DUMMYSTRUCTNAME3 = "";
//pub const DUMMYSTRUCTNAME4 = "";
//pub const DUMMYSTRUCTNAME5 = "";
//pub const __CRT_UUID_DECL = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:563:9
//pub const __MINGW_DEBUGBREAK_IMPL = !(__has_builtin(__debugbreak) != 0);
//pub const __MINGW_FASTFAIL_IMPL = !(__has_builtin(__fastfail) != 0);
//pub const __MINGW_PREFETCH_IMPL = @compileError("unable to translate macro: undefined identifier `__prefetch`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:620:9
//pub const _CRTNOALIAS = "";
//pub const _CRTRESTRICT = "";
//pub const _SIZE_T_DEFINED = "";
//pub const _SSIZE_T_DEFINED = "";
//pub const _RSIZE_T_DEFINED = "";
//pub const _INTPTR_T_DEFINED = "";
//pub const __intptr_t_defined = "";
//pub const _UINTPTR_T_DEFINED = "";
//pub const __uintptr_t_defined = "";
//pub const _PTRDIFF_T_DEFINED = "";
//pub const _PTRDIFF_T_ = "";
//pub const _WCHAR_T_DEFINED = "";
//pub const _WCTYPE_T_DEFINED = "";
//pub const _WINT_T = "";
//pub const _ERRCODE_DEFINED = "";
//pub const _TIME32_T_DEFINED = "";
//pub const _TIME64_T_DEFINED = "";
//pub const _TIME_T_DEFINED = "";
//pub const _CRT_SECURE_CPP_NOTHROW = @compileError("unable to translate macro: undefined identifier `throw`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:143:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_0 = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:262:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_1 = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:263:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_2 = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:264:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_3 = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:265:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_4 = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:266:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_1_1 = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:267:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_1_2 = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:268:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_1_3 = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:269:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_2_0 = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:270:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_1_ARGLIST = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:271:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_2_ARGLIST = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:272:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_SPLITPATH = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:273:9
//pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_0 = @compileError("unable to translate macro: undefined identifier `__func_name`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:277:9
//pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_1 = @compileError("unable to translate macro: undefined identifier `__func_name`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:279:9
//pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_2 = @compileError("unable to translate macro: undefined identifier `__func_name`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:281:9
//pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_3 = @compileError("unable to translate macro: undefined identifier `__func_name`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:283:9
//pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_4 = @compileError("unable to translate macro: undefined identifier `__func_name`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:285:9
//pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_0_EX = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:422:9
//pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_1_EX = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:423:9
//pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_2_EX = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:424:9
//pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_3_EX = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:425:9
//pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_4_EX = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:426:9
//pub const _TAGLC_ID_DEFINED = "";
//pub const _THREADLOCALEINFO = "";
//pub const __crt_typefix = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:486:9
//pub const _CRT_USE_WINAPI_FAMILY_DESKTOP_APP = "";
//pub const _LIBCPP_STDINT_H = "";
//pub const __CLANG_STDINT_H = "";
//pub const _STDINT_H = "";
//pub const __need_wint_t = "";
//pub const __need_wchar_t = "";
//pub const _WCHAR_T = "";
//pub const _LIBCPP_STDDEF_H = "";
//pub const INT8_MIN = -@as(c_int, 128);
//pub const INT16_MIN = -@import("std").zig.c_translation.promoteIntLiteral(c_int, 32768, .decimal);
//pub const INT32_MIN = -@import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal) - @as(c_int, 1);
//pub const INT64_MIN = -@as(c_longlong, 9223372036854775807) - @as(c_int, 1);
//pub const INT8_MAX = @as(c_int, 127);
//pub const INT16_MAX = @as(c_int, 32767);
//pub const INT32_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
//pub const INT64_MAX = @as(c_longlong, 9223372036854775807);
//pub const UINT8_MAX = @as(c_int, 255);
//pub const UINT16_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
//pub const UINT32_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 0xffffffff, .hex);
//pub const UINT64_MAX = @as(c_ulonglong, 0xffffffffffffffff);
//pub const INT_LEAST8_MIN = INT8_MIN;
//pub const INT_LEAST16_MIN = INT16_MIN;
//pub const INT_LEAST32_MIN = INT32_MIN;
//pub const INT_LEAST64_MIN = INT64_MIN;
//pub const INT_LEAST8_MAX = INT8_MAX;
//pub const INT_LEAST16_MAX = INT16_MAX;
//pub const INT_LEAST32_MAX = INT32_MAX;
//pub const INT_LEAST64_MAX = INT64_MAX;
//pub const UINT_LEAST8_MAX = UINT8_MAX;
//pub const UINT_LEAST16_MAX = UINT16_MAX;
//pub const UINT_LEAST32_MAX = UINT32_MAX;
//pub const UINT_LEAST64_MAX = UINT64_MAX;
//pub const INT_FAST8_MIN = INT8_MIN;
//pub const INT_FAST16_MIN = INT16_MIN;
//pub const INT_FAST32_MIN = INT32_MIN;
//pub const INT_FAST64_MIN = INT64_MIN;
//pub const INT_FAST8_MAX = INT8_MAX;
//pub const INT_FAST16_MAX = INT16_MAX;
//pub const INT_FAST32_MAX = INT32_MAX;
//pub const INT_FAST64_MAX = INT64_MAX;
//pub const UINT_FAST8_MAX = UINT8_MAX;
//pub const UINT_FAST16_MAX = UINT16_MAX;
//pub const UINT_FAST32_MAX = UINT32_MAX;
//pub const UINT_FAST64_MAX = UINT64_MAX;
//pub const INTPTR_MIN = INT64_MIN;
//pub const INTPTR_MAX = INT64_MAX;
//pub const UINTPTR_MAX = UINT64_MAX;
//pub const INTMAX_MIN = INT64_MIN;
//pub const INTMAX_MAX = INT64_MAX;
//pub const UINTMAX_MAX = UINT64_MAX;
//pub const PTRDIFF_MIN = INT64_MIN;
//pub const PTRDIFF_MAX = INT64_MAX;
//pub const SIG_ATOMIC_MIN = INT32_MIN;
//pub const SIG_ATOMIC_MAX = INT32_MAX;
//pub const SIZE_MAX = UINT64_MAX;
//pub const WCHAR_MIN = @as(c_uint, 0);
//pub const WCHAR_MAX = @as(c_uint, 0xffff);
//pub const WINT_MIN = @as(c_uint, 0);
//pub const WINT_MAX = @as(c_uint, 0xffff);
//pub inline fn INT8_C(val: anytype) @TypeOf((INT_LEAST8_MAX - INT_LEAST8_MAX) + val) {
//    _ = &val;
//    return (INT_LEAST8_MAX - INT_LEAST8_MAX) + val;
//}
//pub inline fn INT16_C(val: anytype) @TypeOf((INT_LEAST16_MAX - INT_LEAST16_MAX) + val) {
//    _ = &val;
//    return (INT_LEAST16_MAX - INT_LEAST16_MAX) + val;
//}
//pub inline fn INT32_C(val: anytype) @TypeOf((INT_LEAST32_MAX - INT_LEAST32_MAX) + val) {
//    _ = &val;
//    return (INT_LEAST32_MAX - INT_LEAST32_MAX) + val;
//}
//pub const INT64_C = @import("std").zig.c_translation.Macros.LL_SUFFIX;
//pub inline fn UINT8_C(val: anytype) @TypeOf(val) {
//    _ = &val;
//    return val;
//}
//pub inline fn UINT16_C(val: anytype) @TypeOf(val) {
//    _ = &val;
//    return val;
//}
//pub const UINT32_C = @import("std").zig.c_translation.Macros.U_SUFFIX;
//pub const UINT64_C = @import("std").zig.c_translation.Macros.ULL_SUFFIX;
//pub const INTMAX_C = @import("std").zig.c_translation.Macros.LL_SUFFIX;
//pub const UINTMAX_C = @import("std").zig.c_translation.Macros.ULL_SUFFIX;
//pub const PRId64 = "lld";
//pub const PRIi64 = "lli";
//pub const PRIo64 = "llo";
//pub const PRIu64 = "llu";
//pub const PRIx64 = "llx";
//pub const PRIX64 = "llX";
//pub const PRId8 = "d";
//pub const PRId16 = "d";
//pub const PRId32 = "d";
//pub const PRIdLEAST8 = "d";
//pub const PRIdLEAST16 = "d";
//pub const PRIdLEAST32 = "d";
//pub const PRIdLEAST64 = PRId64;
//pub const PRIdFAST8 = "d";
//pub const PRIdFAST16 = "d";
//pub const PRIdFAST32 = "d";
//pub const PRIdFAST64 = PRId64;
//pub const PRIdMAX = PRId64;
//pub const PRIi8 = "i";
//pub const PRIi16 = "i";
//pub const PRIi32 = "i";
//pub const PRIiLEAST8 = "i";
//pub const PRIiLEAST16 = "i";
//pub const PRIiLEAST32 = "i";
//pub const PRIiLEAST64 = PRIi64;
//pub const PRIiFAST8 = "i";
//pub const PRIiFAST16 = "i";
//pub const PRIiFAST32 = "i";
//pub const PRIiFAST64 = PRIi64;
//pub const PRIiMAX = PRIi64;
//pub const PRIo8 = "o";
//pub const PRIo16 = "o";
//pub const PRIo32 = "o";
//pub const PRIoLEAST8 = "o";
//pub const PRIoLEAST16 = "o";
//pub const PRIoLEAST32 = "o";
//pub const PRIoLEAST64 = PRIo64;
//pub const PRIoFAST8 = "o";
//pub const PRIoFAST16 = "o";
//pub const PRIoFAST32 = "o";
//pub const PRIoFAST64 = PRIo64;
//pub const PRIoMAX = PRIo64;
//pub const PRIu8 = "u";
//pub const PRIu16 = "u";
//pub const PRIu32 = "u";
//pub const PRIuLEAST8 = "u";
//pub const PRIuLEAST16 = "u";
//pub const PRIuLEAST32 = "u";
//pub const PRIuLEAST64 = PRIu64;
//pub const PRIuFAST8 = "u";
//pub const PRIuFAST16 = "u";
//pub const PRIuFAST32 = "u";
//pub const PRIuFAST64 = PRIu64;
//pub const PRIuMAX = PRIu64;
//pub const PRIx8 = "x";
//pub const PRIx16 = "x";
//pub const PRIx32 = "x";
//pub const PRIxLEAST8 = "x";
//pub const PRIxLEAST16 = "x";
//pub const PRIxLEAST32 = "x";
//pub const PRIxLEAST64 = PRIx64;
//pub const PRIxFAST8 = "x";
//pub const PRIxFAST16 = "x";
//pub const PRIxFAST32 = "x";
//pub const PRIxFAST64 = PRIx64;
//pub const PRIxMAX = PRIx64;
//pub const PRIX8 = "X";
//pub const PRIX16 = "X";
//pub const PRIX32 = "X";
//pub const PRIXLEAST8 = "X";
//pub const PRIXLEAST16 = "X";
//pub const PRIXLEAST32 = "X";
//pub const PRIXLEAST64 = PRIX64;
//pub const PRIXFAST8 = "X";
//pub const PRIXFAST16 = "X";
//pub const PRIXFAST32 = "X";
//pub const PRIXFAST64 = PRIX64;
//pub const PRIXMAX = PRIX64;
//pub const SCNd16 = "hd";
//pub const SCNd32 = "d";
//pub const SCNd64 = PRId64;
//pub const SCNdLEAST16 = "hd";
//pub const SCNdLEAST32 = "d";
//pub const SCNdLEAST64 = PRId64;
//pub const SCNdFAST16 = "hd";
//pub const SCNdFAST32 = "d";
//pub const SCNdFAST64 = PRId64;
//pub const SCNdMAX = PRId64;
//pub const SCNi16 = "hi";
//pub const SCNi32 = "i";
//pub const SCNi64 = PRIi64;
//pub const SCNiLEAST16 = "hi";
//pub const SCNiLEAST32 = "i";
//pub const SCNiLEAST64 = PRIi64;
//pub const SCNiFAST16 = "hi";
//pub const SCNiFAST32 = "i";
//pub const SCNiFAST64 = PRIi64;
//pub const SCNiMAX = PRIi64;
//pub const SCNo16 = "ho";
//pub const SCNo32 = "o";
//pub const SCNo64 = PRIo64;
//pub const SCNoLEAST16 = "ho";
//pub const SCNoLEAST32 = "o";
//pub const SCNoLEAST64 = PRIo64;
//pub const SCNoFAST16 = "ho";
//pub const SCNoFAST32 = "o";
//pub const SCNoFAST64 = PRIo64;
//pub const SCNoMAX = PRIo64;
//pub const SCNx16 = "hx";
//pub const SCNx32 = "x";
//pub const SCNx64 = PRIx64;
//pub const SCNxLEAST16 = "hx";
//pub const SCNxLEAST32 = "x";
//pub const SCNxLEAST64 = PRIx64;
//pub const SCNxFAST16 = "hx";
//pub const SCNxFAST32 = "x";
//pub const SCNxFAST64 = PRIx64;
//pub const SCNxMAX = PRIx64;
//pub const SCNu16 = "hu";
//pub const SCNu32 = "u";
//pub const SCNu64 = PRIu64;
//pub const SCNuLEAST16 = "hu";
//pub const SCNuLEAST32 = "u";
//pub const SCNuLEAST64 = PRIu64;
//pub const SCNuFAST16 = "hu";
//pub const SCNuFAST32 = "u";
//pub const SCNuFAST64 = PRIu64;
//pub const SCNuMAX = PRIu64;
//pub const PRIdPTR = PRId64;
//pub const PRIiPTR = PRIi64;
//pub const PRIoPTR = PRIo64;
//pub const PRIuPTR = PRIu64;
//pub const PRIxPTR = PRIx64;
//pub const PRIXPTR = PRIX64;
//pub const SCNdPTR = PRId64;
//pub const SCNiPTR = PRIi64;
//pub const SCNoPTR = PRIo64;
//pub const SCNxPTR = PRIx64;
//pub const SCNuPTR = PRIu64;
//pub const SCNd8 = "hhd";
//pub const SCNdLEAST8 = "hhd";
//pub const SCNdFAST8 = "hhd";
//pub const SCNi8 = "hhi";
//pub const SCNiLEAST8 = "hhi";
//pub const SCNiFAST8 = "hhi";
//pub const SCNo8 = "hho";
//pub const SCNoLEAST8 = "hho";
//pub const SCNoFAST8 = "hho";
//pub const SCNx8 = "hhx";
//pub const SCNxLEAST8 = "hhx";
//pub const SCNxFAST8 = "hhx";
//pub const SCNu8 = "hhu";
//pub const SCNuLEAST8 = "hhu";
//pub const SCNuFAST8 = "hhu";
//pub const __STDARG_H = "";
//pub const __need___va_list = "";
//pub const __need_va_list = "";
//pub const __need_va_arg = "";
//pub const __need___va_copy = "";
//pub const __need_va_copy = "";
//pub const _VA_LIST = "";
//pub const va_start = @compileError("unable to translate macro: undefined identifier `__builtin_va_start`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\include/__stdarg_va_arg.h:17:9
//pub const va_end = @compileError("unable to translate macro: undefined identifier `__builtin_va_end`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\include/__stdarg_va_arg.h:19:9
//pub const va_arg = @compileError("unable to translate C expr: unexpected token 'an identifier'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\include/__stdarg_va_arg.h:20:9
//pub const __va_copy = @compileError("unable to translate macro: undefined identifier `__builtin_va_copy`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\include/__stdarg___va_copy.h:11:9
//pub const va_copy = @compileError("unable to translate macro: undefined identifier `__builtin_va_copy`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\include/__stdarg_va_copy.h:11:9
//pub const _LIBCPP_STDBOOL_H = "";
//pub const __STDBOOL_H = "";
//pub const __bool_true_false_are_defined = @as(c_int, 1);
//pub const @"bool" = bool;
//pub const @"true" = @as(c_int, 1);
//pub const @"false" = @as(c_int, 0);
//pub const _LIBCPP_STRING_H = "";
//pub const _INC_STRING = "";
//pub const _SECIMP = @compileError("unable to translate macro: undefined identifier `dllimport`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/string.h:16:9
//pub const _NLSCMP_DEFINED = "";
//pub const _NLSCMPERROR = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
//pub const NULL = @import("std").zig.c_translation.cast(?*anyopaque, @as(c_int, 0));
//pub const _WConst_return = "";
//pub const _CRT_MEMORY_DEFINED = "";
//pub const _WSTRING_DEFINED = "";
//pub const wcswcs = wcsstr;
//pub const _INC_STRING_S = "";
//pub const _WSTRING_S_DEFINED = "";
//pub const _LIBCPP_WCHAR_H = "";
//pub const __STDDEF_H = "";
//pub const __need_ptrdiff_t = "";
//pub const __need_size_t = "";
//pub const __need_NULL = "";
//pub const __need_max_align_t = "";
//pub const __need_offsetof = "";
//pub const _PTRDIFF_T = "";
//pub const _SIZE_T = "";
//pub const __CLANG_MAX_ALIGN_T_DEFINED = "";
//pub const offsetof = @compileError("unable to translate C expr: unexpected token 'an identifier'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\include/__stddef_offsetof.h:16:9
//pub const _INC_WCHAR = "";
//pub const _STDIO_CONFIG_DEFINED = "";
//pub const _CRT_INTERNAL_PRINTF_LEGACY_VSPRINTF_NULL_TERMINATION = @as(c_ulonglong, 0x0001);
//pub const _CRT_INTERNAL_PRINTF_STANDARD_SNPRINTF_BEHAVIOR = @as(c_ulonglong, 0x0002);
//pub const _CRT_INTERNAL_PRINTF_LEGACY_WIDE_SPECIFIERS = @as(c_ulonglong, 0x0004);
//pub const _CRT_INTERNAL_PRINTF_LEGACY_MSVCRT_COMPATIBILITY = @as(c_ulonglong, 0x0008);
//pub const _CRT_INTERNAL_PRINTF_LEGACY_THREE_DIGIT_EXPONENTS = @as(c_ulonglong, 0x0010);
//pub const _CRT_INTERNAL_SCANF_SECURECRT = @as(c_ulonglong, 0x0001);
//pub const _CRT_INTERNAL_SCANF_LEGACY_WIDE_SPECIFIERS = @as(c_ulonglong, 0x0002);
//pub const _CRT_INTERNAL_SCANF_LEGACY_MSVCRT_COMPATIBILITY = @as(c_ulonglong, 0x0004);
//pub const _CRT_INTERNAL_LOCAL_PRINTF_OPTIONS = _CRT_INTERNAL_PRINTF_LEGACY_WIDE_SPECIFIERS;
//pub const _CRT_INTERNAL_LOCAL_SCANF_OPTIONS = _CRT_INTERNAL_SCANF_LEGACY_WIDE_SPECIFIERS;
//pub const _INC_CORECRT_WSTDLIB = "";
//pub const WEOF = @import("std").zig.c_translation.cast(wint_t, @import("std").zig.c_translation.promoteIntLiteral(c_int, 0xFFFF, .hex));
//pub const _FILE_DEFINED = "";
//pub const _iob = __iob_func();
//pub const stdin = __acrt_iob_func(@as(c_int, 0));
//pub const stdout = __acrt_iob_func(@as(c_int, 1));
//pub const stderr = __acrt_iob_func(@as(c_int, 2));
//pub const _STDSTREAM_DEFINED = "";
//pub const _FSIZE_T_DEFINED = "";
//pub const _wfinddata_t = _wfinddata64i32_t;
//pub const _wfinddatai64_t = _wfinddata64_t;
//pub const _wfindfirst = _wfindfirst64i32;
//pub const _wfindnext = _wfindnext64i32;
//pub const _wfindfirsti64 = _wfindfirst64;
//pub const _wfindnexti64 = _wfindnext64;
//pub const _WFINDDATA_T_DEFINED = "";
//pub const _CRT_CTYPEDATA_DEFINED = "";
//pub const __PCTYPE_FUNC = __pctype_func();
//pub const _pctype = __pctype_func();
//pub const _CRT_WCTYPEDATA_DEFINED = "";
//pub const _wctype = __MINGW_IMP_SYMBOL(_wctype).*;
//pub inline fn __pwctype_func() @TypeOf(__MINGW_IMP_SYMBOL(_pwctype).*) {
//    return __MINGW_IMP_SYMBOL(_pwctype).*;
//}
//pub const _pwctype = __MINGW_IMP_SYMBOL(_pwctype).*;
//pub const _UPPER = @as(c_int, 0x1);
//pub const _LOWER = @as(c_int, 0x2);
//pub const _DIGIT = @as(c_int, 0x4);
//pub const _SPACE = @as(c_int, 0x8);
//pub const _PUNCT = @as(c_int, 0x10);
//pub const _CONTROL = @as(c_int, 0x20);
//pub const _BLANK = @as(c_int, 0x40);
//pub const _HEX = @as(c_int, 0x80);
//pub const _LEADBYTE = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x8000, .hex);
//pub const _ALPHA = (@as(c_int, 0x0100) | _UPPER) | _LOWER;
//pub const _WCTYPE_DEFINED = "";
//pub const _WDIRECT_DEFINED = "";
//pub const _WIO_DEFINED = "";
//pub const _WLOCALE_DEFINED = "";
//pub const _WEXEC_DEFINED = "";
//pub const _WSPAWN_DEFINED = "";
//pub const _CRT_WSYSTEM_DEFINED = "";
//pub const _WCTYPE_INLINE_DEFINED = "";
//pub const _INO_T_DEFINED = "";
//pub const _DEV_T_DEFINED = "";
//pub const _OFF_T_DEFINED = "";
//pub const _OFF_T_ = "";
//pub const _OFF64_T_DEFINED = "";
//pub const _FILE_OFFSET_BITS_SET_OFFT = "";
//pub const _fstat = @compileError("unable to translate macro: undefined identifier `_fstat64i32`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_stat64.h:17:9
//pub const _fstati64 = @compileError("unable to translate macro: undefined identifier `_fstat64`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_stat64.h:18:9
//pub const _stat = _stat64i32;
//pub const _stati64 = _stat64;
//pub const _wstat = _wstat64i32;
//pub const _wstati64 = _wstat64;
//pub const __stat64 = _stat64;
//pub const stat64 = _stat64;
//pub const fstat64 = @compileError("unable to translate macro: undefined identifier `_fstat64`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_stat64.h:99:9
//pub const _STAT_DEFINED = "";
//pub const _WSTAT_DEFINED = "";
//pub const _WCONIO_DEFINED = "";
//pub const _WSTDIO_DEFINED = "";
//pub const _INC_SWPRINTF_INL = "";
//pub const _CRT_WPERROR_DEFINED = "";
//pub const wpopen = _wpopen;
//pub inline fn _putwc_nolock(_c: anytype, _stm: anytype) @TypeOf(_fputwc_nolock(_c, _stm)) {
//    _ = &_c;
//    _ = &_stm;
//    return _fputwc_nolock(_c, _stm);
//}
//pub inline fn _getwc_nolock(_c: anytype) @TypeOf(_fgetwc_nolock(_c)) {
//    _ = &_c;
//    return _fgetwc_nolock(_c);
//}
//pub const _WSTDLIB_DEFINED = "";
//pub const _WSTDLIBP_DEFINED = "";
//pub const _TM_DEFINED = "";
//pub const _WTIME_DEFINED = "";
//pub const _INC_WTIME_INL = "";
//pub const _INC_WTIME_S_INL = "";
//pub const __MINGW_MBWC_CONVERT_DEFINED = "";
//pub const _INC_WCHAR_S = "";
//pub const _WIO_S_DEFINED = "";
//pub const _WCONIO_S_DEFINED = "";
//pub const _WSTDIO_S_DEFINED = "";
//pub const _WTIME_S_DEFINED = "";
//pub const alloca = @compileError("unable to translate macro: undefined identifier `__builtin_alloca`");
//// ./include/SDL3/SDL_stdinc.h:59:12
//pub const SDL_SIZE_MAX = SIZE_MAX;
//pub inline fn SDL_HAS_BUILTIN(x: anytype) @TypeOf(__has_builtin(x)) {
//    _ = &x;
//    return __has_builtin(x);
//}
//pub const SDL_arraysize = @compileError("unable to translate C expr: expected ')' instead got '['");
//// ./include/SDL3/SDL_stdinc.h:105:9
//pub const SDL_STRINGIFY_ARG = @compileError("unable to translate C expr: unexpected token '#'");
//// ./include/SDL3/SDL_stdinc.h:118:9
//pub const SDL_reinterpret_cast = @import("std").zig.c_translation.Macros.CAST_OR_CALL;
//pub const SDL_static_cast = @import("std").zig.c_translation.Macros.CAST_OR_CALL;
//pub const SDL_const_cast = @import("std").zig.c_translation.Macros.CAST_OR_CALL;
//pub inline fn SDL_FOURCC(A: anytype, B: anytype, C: anytype, D: anytype) @TypeOf((((SDL_static_cast(Uint32, SDL_static_cast(Uint8, A)) << @as(c_int, 0)) | (SDL_static_cast(Uint32, SDL_static_cast(Uint8, B)) << @as(c_int, 8))) | (SDL_static_cast(Uint32, SDL_static_cast(Uint8, C)) << @as(c_int, 16))) | (SDL_static_cast(Uint32, SDL_static_cast(Uint8, D)) << @as(c_int, 24))) {
//    _ = &A;
//    _ = &B;
//    _ = &C;
//    _ = &D;
//    return (((SDL_static_cast(Uint32, SDL_static_cast(Uint8, A)) << @as(c_int, 0)) | (SDL_static_cast(Uint32, SDL_static_cast(Uint8, B)) << @as(c_int, 8))) | (SDL_static_cast(Uint32, SDL_static_cast(Uint8, C)) << @as(c_int, 16))) | (SDL_static_cast(Uint32, SDL_static_cast(Uint8, D)) << @as(c_int, 24));
//}
//pub inline fn SDL_SINT64_C(c: anytype) @TypeOf(INT64_C(c)) {
//    _ = &c;
//    return INT64_C(c);
//}
//pub inline fn SDL_UINT64_C(c: anytype) @TypeOf(UINT64_C(c)) {
//    _ = &c;
//    return UINT64_C(c);
//}
//pub const SDL_FALSE = @"false";
//pub const SDL_TRUE = @"true";
//pub const SDL_MAX_SINT8 = @import("std").zig.c_translation.cast(Sint8, @as(c_int, 0x7F));
//pub const SDL_MIN_SINT8 = @import("std").zig.c_translation.cast(Sint8, ~@as(c_int, 0x7F));
//pub const SDL_MAX_UINT8 = @import("std").zig.c_translation.cast(Uint8, @as(c_int, 0xFF));
//pub const SDL_MIN_UINT8 = @import("std").zig.c_translation.cast(Uint8, @as(c_int, 0x00));
//pub const SDL_MAX_SINT16 = @import("std").zig.c_translation.cast(Sint16, @as(c_int, 0x7FFF));
//pub const SDL_MIN_SINT16 = @import("std").zig.c_translation.cast(Sint16, ~@as(c_int, 0x7FFF));
//pub const SDL_MAX_UINT16 = @import("std").zig.c_translation.cast(Uint16, @import("std").zig.c_translation.promoteIntLiteral(c_int, 0xFFFF, .hex));
//pub const SDL_MIN_UINT16 = @import("std").zig.c_translation.cast(Uint16, @as(c_int, 0x0000));
//pub const SDL_MAX_SINT32 = @import("std").zig.c_translation.cast(Sint32, @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x7FFFFFFF, .hex));
//pub const SDL_MIN_SINT32 = @import("std").zig.c_translation.cast(Sint32, ~@import("std").zig.c_translation.promoteIntLiteral(c_int, 0x7FFFFFFF, .hex));
//pub const SDL_MAX_UINT32 = @import("std").zig.c_translation.cast(Uint32, @import("std").zig.c_translation.promoteIntLiteral(c_uint, 0xFFFFFFFF, .hex));
//pub const SDL_MIN_UINT32 = @import("std").zig.c_translation.cast(Uint32, @as(c_int, 0x00000000));
//pub const SDL_MAX_SINT64 = SDL_SINT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 0x7FFFFFFFFFFFFFFF, .hex));
//pub const SDL_MIN_SINT64 = ~SDL_SINT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 0x7FFFFFFFFFFFFFFF, .hex));
//pub const SDL_MAX_UINT64 = SDL_UINT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 0xFFFFFFFFFFFFFFFF, .hex));
//pub const SDL_MIN_UINT64 = SDL_UINT64_C(@as(c_int, 0x0000000000000000));
//pub const SDL_MAX_TIME = SDL_MAX_SINT64;
//pub const SDL_MIN_TIME = SDL_MIN_SINT64;
//pub const SDL_FLT_EPSILON = @as(f32, 1.1920928955078125e-07);
//pub const SDL_PRIs64 = "I64d";
//pub const SDL_PRIu64 = "I64u";
//pub const SDL_PRIx64 = "I64x";
//pub const SDL_PRIX64 = "I64X";
//pub const SDL_PRIs32 = PRId32;
//pub const SDL_PRIu32 = PRIu32;
//pub const SDL_PRIx32 = PRIx32;
//pub const SDL_PRIX32 = PRIX32;
//pub const SDL_IN_BYTECAP = @compileError("unable to translate C expr: unexpected token ''");
//// ./include/SDL3/SDL_stdinc.h:526:9
//pub const SDL_INOUT_Z_CAP = @compileError("unable to translate C expr: unexpected token ''");
//// ./include/SDL3/SDL_stdinc.h:527:9
//pub const SDL_OUT_Z_CAP = @compileError("unable to translate C expr: unexpected token ''");
//// ./include/SDL3/SDL_stdinc.h:528:9
//pub const SDL_OUT_CAP = @compileError("unable to translate C expr: unexpected token ''");
//// ./include/SDL3/SDL_stdinc.h:529:9
//pub const SDL_OUT_BYTECAP = @compileError("unable to translate C expr: unexpected token ''");
//// ./include/SDL3/SDL_stdinc.h:530:9
//pub const SDL_OUT_Z_BYTECAP = @compileError("unable to translate C expr: unexpected token ''");
//// ./include/SDL3/SDL_stdinc.h:531:9
//pub const SDL_PRINTF_FORMAT_STRING = "";
//pub const SDL_SCANF_FORMAT_STRING = "";
//pub const SDL_PRINTF_VARARG_FUNC = @compileError("unable to translate macro: undefined identifier `format`");
//// ./include/SDL3/SDL_stdinc.h:536:9
//pub const SDL_PRINTF_VARARG_FUNCV = @compileError("unable to translate macro: undefined identifier `format`");
//// ./include/SDL3/SDL_stdinc.h:537:9
//pub const SDL_SCANF_VARARG_FUNC = @compileError("unable to translate macro: undefined identifier `format`");
//// ./include/SDL3/SDL_stdinc.h:538:9
//pub const SDL_SCANF_VARARG_FUNCV = @compileError("unable to translate macro: undefined identifier `format`");
//// ./include/SDL3/SDL_stdinc.h:539:9
//pub const SDL_WPRINTF_VARARG_FUNC = @compileError("unable to translate C expr: unexpected token ''");
//// ./include/SDL3/SDL_stdinc.h:540:9
//pub const SDL_WPRINTF_VARARG_FUNCV = @compileError("unable to translate C expr: unexpected token ''");
//// ./include/SDL3/SDL_stdinc.h:541:9
//pub const SDL_COMPILE_TIME_ASSERT = @compileError("unable to translate C expr: unexpected token '_Static_assert'");
//// ./include/SDL3/SDL_stdinc.h:561:9
//pub const SDL_begin_code_h = "";
//pub const SDL_DEPRECATED = @compileError("unable to translate macro: undefined identifier `deprecated`");
//// ./include/SDL3/SDL_begin_code.h:38:13
//pub const SDL_UNUSED = @compileError("unable to translate macro: undefined identifier `unused`");
//// ./include/SDL3/SDL_begin_code.h:48:13
//pub const SDL_DECLSPEC = "";
//pub const SDLCALL = "";
//pub const SDL_INLINE = @compileError("unable to translate C expr: unexpected token '__inline__'");
//// ./include/SDL3/SDL_begin_code.h:105:9
//pub const SDL_FORCE_INLINE = @compileError("unable to translate macro: undefined identifier `always_inline`");
//// ./include/SDL3/SDL_begin_code.h:126:9
//pub const SDL_NORETURN = @compileError("unable to translate macro: undefined identifier `noreturn`");
//// ./include/SDL3/SDL_begin_code.h:134:9
//pub const SDL_ANALYZER_NORETURN = @compileError("unable to translate macro: undefined identifier `analyzer_noreturn`");
//// ./include/SDL3/SDL_begin_code.h:144:9
//pub const SDL_HAS_FALLTHROUGH = @compileError("unable to translate macro: undefined identifier `__has_attribute`");
//// ./include/SDL3/SDL_begin_code.h:169:9
//pub const SDL_FALLTHROUGH = @compileError("unable to translate macro: undefined identifier `__fallthrough__`");
//// ./include/SDL3/SDL_begin_code.h:176:9
//pub const SDL_NODISCARD = @compileError("unable to translate macro: undefined identifier `warn_unused_result`");
//// ./include/SDL3/SDL_begin_code.h:189:9
//pub const SDL_MALLOC = @compileError("unable to translate macro: undefined identifier `malloc`");
//// ./include/SDL3/SDL_begin_code.h:199:9
//pub const SDL_ALLOC_SIZE = @compileError("unable to translate macro: undefined identifier `alloc_size`");
//// ./include/SDL3/SDL_begin_code.h:211:9
//pub const SDL_ALLOC_SIZE2 = @compileError("unable to translate macro: undefined identifier `alloc_size`");
//// ./include/SDL3/SDL_begin_code.h:221:9
//pub const SDL_INIT_INTERFACE = @compileError("unable to translate C expr: unexpected token 'do'");
//// ./include/SDL3/SDL_stdinc.h:658:9
//pub const SDL_stack_alloc = @compileError("unable to translate C expr: unexpected token ')'");
//// ./include/SDL3/SDL_stdinc.h:666:9
//pub const SDL_stack_free = @compileError("unable to translate C expr: unexpected token ''");
//// ./include/SDL3/SDL_stdinc.h:667:9
//pub inline fn SDL_min(x: anytype, y: anytype) @TypeOf(if (x < y) x else y) {
//    _ = &x;
//    _ = &y;
//    return if (x < y) x else y;
//}
//pub inline fn SDL_max(x: anytype, y: anytype) @TypeOf(if (x > y) x else y) {
//    _ = &x;
//    _ = &y;
//    return if (x > y) x else y;
//}
//pub inline fn SDL_clamp(x: anytype, a: anytype, b: anytype) @TypeOf(if (x < a) a else if (x > b) b else x) {
//    _ = &x;
//    _ = &a;
//    _ = &b;
//    return if (x < a) a else if (x > b) b else x;
//}
//pub const SDL_copyp = @compileError("unable to translate C expr: unexpected token '{'");
//// ./include/SDL3/SDL_stdinc.h:1471:9
//pub const SDL_zero = @compileError("unable to translate C expr: unexpected token '('");
//// ./include/SDL3/SDL_stdinc.h:1513:9
//pub const SDL_zerop = @compileError("unable to translate C expr: unexpected token '*'");
//// ./include/SDL3/SDL_stdinc.h:1514:9
//pub const SDL_zeroa = @compileError("unable to translate C expr: unexpected token '('");
//// ./include/SDL3/SDL_stdinc.h:1515:9
//pub const SDL_INVALID_UNICODE_CODEPOINT = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0xFFFD, .hex);
//pub const SDL_PI_D = @as(f64, 3.141592653589793238462643383279502884);
//pub const SDL_PI_F = @as(f32, 3.141592653589793238462643383279502884);
//pub const SDL_ICONV_ERROR = @import("std").zig.c_translation.cast(usize, -@as(c_int, 1));
//pub const SDL_ICONV_E2BIG = @import("std").zig.c_translation.cast(usize, -@as(c_int, 2));
//pub const SDL_ICONV_EILSEQ = @import("std").zig.c_translation.cast(usize, -@as(c_int, 3));
//pub const SDL_ICONV_EINVAL = @import("std").zig.c_translation.cast(usize, -@as(c_int, 4));
//pub inline fn SDL_iconv_utf8_locale(S: anytype) @TypeOf(SDL_iconv_string("", "UTF-8", S, SDL_strlen(S) + @as(c_int, 1))) {
//    _ = &S;
//    return SDL_iconv_string("", "UTF-8", S, SDL_strlen(S) + @as(c_int, 1));
//}
//pub inline fn SDL_iconv_utf8_ucs2(S: anytype) [*c]Uint16 {
//    _ = &S;
//    return @import("std").zig.c_translation.cast([*c]Uint16, SDL_iconv_string("UCS-2", "UTF-8", S, SDL_strlen(S) + @as(c_int, 1)));
//}
//pub inline fn SDL_iconv_utf8_ucs4(S: anytype) [*c]Uint32 {
//    _ = &S;
//    return @import("std").zig.c_translation.cast([*c]Uint32, SDL_iconv_string("UCS-4", "UTF-8", S, SDL_strlen(S) + @as(c_int, 1)));
//}
//pub inline fn SDL_iconv_wchar_utf8(S: anytype) @TypeOf(SDL_iconv_string("UTF-8", "WCHAR_T", @import("std").zig.c_translation.cast([*c]u8, S), (SDL_wcslen(S) + @as(c_int, 1)) * @import("std").zig.c_translation.sizeof(wchar_t))) {
//    _ = &S;
//    return SDL_iconv_string("UTF-8", "WCHAR_T", @import("std").zig.c_translation.cast([*c]u8, S), (SDL_wcslen(S) + @as(c_int, 1)) * @import("std").zig.c_translation.sizeof(wchar_t));
//}
//pub const SDL_error_h_ = "";
//pub inline fn SDL_Unsupported() @TypeOf(SDL_SetError("That operation is not supported")) {
//    return SDL_SetError("That operation is not supported");
//}
//pub inline fn SDL_InvalidParamError(param: anytype) @TypeOf(SDL_SetError("Parameter '%s' is invalid", param)) {
//    _ = &param;
//    return SDL_SetError("Parameter '%s' is invalid", param);
//}
//pub const SDL_pixels_h_ = "";
//pub const SDL_endian_h_ = "";
//pub const SDL_LIL_ENDIAN = @as(c_int, 1234);
//pub const SDL_BIG_ENDIAN = @as(c_int, 4321);
//pub const SDL_BYTEORDER = SDL_LIL_ENDIAN;
//pub const SDL_FLOATWORDORDER = SDL_BYTEORDER;
//pub const HAS_BUILTIN_BSWAP16 = (SDL_HAS_BUILTIN(__builtin_bswap16) != 0) or ((__GNUC__ > @as(c_int, 4)) or ((__GNUC__ == @as(c_int, 4)) and (__GNUC_MINOR__ >= @as(c_int, 8))));
//pub const HAS_BUILTIN_BSWAP32 = (SDL_HAS_BUILTIN(__builtin_bswap32) != 0) or ((__GNUC__ > @as(c_int, 4)) or ((__GNUC__ == @as(c_int, 4)) and (__GNUC_MINOR__ >= @as(c_int, 3))));
//pub const HAS_BUILTIN_BSWAP64 = (SDL_HAS_BUILTIN(__builtin_bswap64) != 0) or ((__GNUC__ > @as(c_int, 4)) or ((__GNUC__ == @as(c_int, 4)) and (__GNUC_MINOR__ >= @as(c_int, 3))));
//pub const HAS_BROKEN_BSWAP = (__GNUC__ == @as(c_int, 2)) and (__GNUC_MINOR__ <= @as(c_int, 95));
//pub inline fn SDL_Swap16(x: anytype) @TypeOf(__builtin_bswap16(x)) {
//    _ = &x;
//    return __builtin_bswap16(x);
//}
//pub inline fn SDL_Swap32(x: anytype) @TypeOf(__builtin_bswap32(x)) {
//    _ = &x;
//    return __builtin_bswap32(x);
//}
//pub inline fn SDL_Swap64(x: anytype) @TypeOf(__builtin_bswap64(x)) {
//    _ = &x;
//    return __builtin_bswap64(x);
//}
//pub inline fn SDL_Swap16LE(x: anytype) @TypeOf(x) {
//    _ = &x;
//    return x;
//}
//pub inline fn SDL_Swap32LE(x: anytype) @TypeOf(x) {
//    _ = &x;
//    return x;
//}
//pub inline fn SDL_Swap64LE(x: anytype) @TypeOf(x) {
//    _ = &x;
//    return x;
//}
//pub inline fn SDL_SwapFloatLE(x: anytype) @TypeOf(x) {
//    _ = &x;
//    return x;
//}
//pub inline fn SDL_Swap16BE(x: anytype) @TypeOf(SDL_Swap16(x)) {
//    _ = &x;
//    return SDL_Swap16(x);
//}
//pub inline fn SDL_Swap32BE(x: anytype) @TypeOf(SDL_Swap32(x)) {
//    _ = &x;
//    return SDL_Swap32(x);
//}
//pub inline fn SDL_Swap64BE(x: anytype) @TypeOf(SDL_Swap64(x)) {
//    _ = &x;
//    return SDL_Swap64(x);
//}
//pub inline fn SDL_SwapFloatBE(x: anytype) @TypeOf(SDL_SwapFloat(x)) {
//    _ = &x;
//    return SDL_SwapFloat(x);
//}
//pub const SDL_ALPHA_OPAQUE = @as(c_int, 255);
//pub const SDL_ALPHA_OPAQUE_FLOAT = @as(f32, 1.0);
//pub const SDL_ALPHA_TRANSPARENT = @as(c_int, 0);
//pub const SDL_ALPHA_TRANSPARENT_FLOAT = @as(f32, 0.0);
//pub inline fn SDL_DEFINE_PIXELFOURCC(A: anytype, B: anytype, C: anytype, D: anytype) @TypeOf(SDL_FOURCC(A, B, C, D)) {
//    _ = &A;
//    _ = &B;
//    _ = &C;
//    _ = &D;
//    return SDL_FOURCC(A, B, C, D);
//}
//pub inline fn SDL_DEFINE_PIXELFORMAT(@"type": anytype, order: anytype, layout: anytype, bits: anytype, bytes: anytype) @TypeOf((((((@as(c_int, 1) << @as(c_int, 28)) | (@"type" << @as(c_int, 24))) | (order << @as(c_int, 20))) | (layout << @as(c_int, 16))) | (bits << @as(c_int, 8))) | (bytes << @as(c_int, 0))) {
//    _ = &@"type";
//    _ = &order;
//    _ = &layout;
//    _ = &bits;
//    _ = &bytes;
//    return (((((@as(c_int, 1) << @as(c_int, 28)) | (@"type" << @as(c_int, 24))) | (order << @as(c_int, 20))) | (layout << @as(c_int, 16))) | (bits << @as(c_int, 8))) | (bytes << @as(c_int, 0));
//}
//pub inline fn SDL_PIXELFLAG(X: anytype) @TypeOf((X >> @as(c_int, 28)) & @as(c_int, 0x0F)) {
//    _ = &X;
//    return (X >> @as(c_int, 28)) & @as(c_int, 0x0F);
//}
//pub inline fn SDL_PIXELTYPE(X: anytype) @TypeOf((X >> @as(c_int, 24)) & @as(c_int, 0x0F)) {
//    _ = &X;
//    return (X >> @as(c_int, 24)) & @as(c_int, 0x0F);
//}
//pub inline fn SDL_PIXELORDER(X: anytype) @TypeOf((X >> @as(c_int, 20)) & @as(c_int, 0x0F)) {
//    _ = &X;
//    return (X >> @as(c_int, 20)) & @as(c_int, 0x0F);
//}
//pub inline fn SDL_PIXELLAYOUT(X: anytype) @TypeOf((X >> @as(c_int, 16)) & @as(c_int, 0x0F)) {
//    _ = &X;
//    return (X >> @as(c_int, 16)) & @as(c_int, 0x0F);
//}
//pub inline fn SDL_BITSPERPIXEL(X: anytype) @TypeOf(if (SDL_ISPIXELFORMAT_FOURCC(X)) @as(c_int, 0) else (X >> @as(c_int, 8)) & @as(c_int, 0xFF)) {
//    _ = &X;
//    return if (SDL_ISPIXELFORMAT_FOURCC(X)) @as(c_int, 0) else (X >> @as(c_int, 8)) & @as(c_int, 0xFF);
//}
//pub inline fn SDL_BYTESPERPIXEL(X: anytype) @TypeOf(if (SDL_ISPIXELFORMAT_FOURCC(X)) if ((((X == SDL_PIXELFORMAT_YUY2) or (X == SDL_PIXELFORMAT_UYVY)) or (X == SDL_PIXELFORMAT_YVYU)) or (X == SDL_PIXELFORMAT_P010)) @as(c_int, 2) else @as(c_int, 1) else (X >> @as(c_int, 0)) & @as(c_int, 0xFF)) {
//    _ = &X;
//    return if (SDL_ISPIXELFORMAT_FOURCC(X)) if ((((X == SDL_PIXELFORMAT_YUY2) or (X == SDL_PIXELFORMAT_UYVY)) or (X == SDL_PIXELFORMAT_YVYU)) or (X == SDL_PIXELFORMAT_P010)) @as(c_int, 2) else @as(c_int, 1) else (X >> @as(c_int, 0)) & @as(c_int, 0xFF);
//}
//pub inline fn SDL_ISPIXELFORMAT_INDEXED(format: anytype) @TypeOf(!(SDL_ISPIXELFORMAT_FOURCC(format) != 0) and ((((SDL_PIXELTYPE(format) == SDL_PIXELTYPE_INDEX1) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_INDEX2)) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_INDEX4)) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_INDEX8))) {
//    _ = &format;
//    return !(SDL_ISPIXELFORMAT_FOURCC(format) != 0) and ((((SDL_PIXELTYPE(format) == SDL_PIXELTYPE_INDEX1) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_INDEX2)) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_INDEX4)) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_INDEX8));
//}
//pub inline fn SDL_ISPIXELFORMAT_PACKED(format: anytype) @TypeOf(!(SDL_ISPIXELFORMAT_FOURCC(format) != 0) and (((SDL_PIXELTYPE(format) == SDL_PIXELTYPE_PACKED8) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_PACKED16)) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_PACKED32))) {
//    _ = &format;
//    return !(SDL_ISPIXELFORMAT_FOURCC(format) != 0) and (((SDL_PIXELTYPE(format) == SDL_PIXELTYPE_PACKED8) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_PACKED16)) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_PACKED32));
//}
//pub inline fn SDL_ISPIXELFORMAT_ARRAY(format: anytype) @TypeOf(!(SDL_ISPIXELFORMAT_FOURCC(format) != 0) and (((((SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYU8) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYU16)) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYU32)) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYF16)) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYF32))) {
//    _ = &format;
//    return !(SDL_ISPIXELFORMAT_FOURCC(format) != 0) and (((((SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYU8) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYU16)) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYU32)) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYF16)) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYF32));
//}
//pub inline fn SDL_ISPIXELFORMAT_ALPHA(format: anytype) @TypeOf((SDL_ISPIXELFORMAT_PACKED(format) != 0) and ((((SDL_PIXELORDER(format) == SDL_PACKEDORDER_ARGB) or (SDL_PIXELORDER(format) == SDL_PACKEDORDER_RGBA)) or (SDL_PIXELORDER(format) == SDL_PACKEDORDER_ABGR)) or (SDL_PIXELORDER(format) == SDL_PACKEDORDER_BGRA))) {
//    _ = &format;
//    return (SDL_ISPIXELFORMAT_PACKED(format) != 0) and ((((SDL_PIXELORDER(format) == SDL_PACKEDORDER_ARGB) or (SDL_PIXELORDER(format) == SDL_PACKEDORDER_RGBA)) or (SDL_PIXELORDER(format) == SDL_PACKEDORDER_ABGR)) or (SDL_PIXELORDER(format) == SDL_PACKEDORDER_BGRA));
//}
//pub inline fn SDL_ISPIXELFORMAT_10BIT(format: anytype) @TypeOf(!(SDL_ISPIXELFORMAT_FOURCC(format) != 0) and ((SDL_PIXELTYPE(format) == SDL_PIXELTYPE_PACKED32) and (SDL_PIXELLAYOUT(format) == SDL_PACKEDLAYOUT_2101010))) {
//    _ = &format;
//    return !(SDL_ISPIXELFORMAT_FOURCC(format) != 0) and ((SDL_PIXELTYPE(format) == SDL_PIXELTYPE_PACKED32) and (SDL_PIXELLAYOUT(format) == SDL_PACKEDLAYOUT_2101010));
//}
//pub inline fn SDL_ISPIXELFORMAT_FLOAT(format: anytype) @TypeOf(!(SDL_ISPIXELFORMAT_FOURCC(format) != 0) and ((SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYF16) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYF32))) {
//    _ = &format;
//    return !(SDL_ISPIXELFORMAT_FOURCC(format) != 0) and ((SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYF16) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYF32));
//}
//pub inline fn SDL_ISPIXELFORMAT_FOURCC(format: anytype) @TypeOf((format != 0) and (SDL_PIXELFLAG(format) != @as(c_int, 1))) {
//    _ = &format;
//    return (format != 0) and (SDL_PIXELFLAG(format) != @as(c_int, 1));
//}
//pub const SDL_PIXELFORMAT_RGBA32 = SDL_PIXELFORMAT_ABGR8888;
//pub const SDL_PIXELFORMAT_ARGB32 = SDL_PIXELFORMAT_BGRA8888;
//pub const SDL_PIXELFORMAT_BGRA32 = SDL_PIXELFORMAT_ARGB8888;
//pub const SDL_PIXELFORMAT_ABGR32 = SDL_PIXELFORMAT_RGBA8888;
//pub const SDL_PIXELFORMAT_RGBX32 = SDL_PIXELFORMAT_XBGR8888;
//pub const SDL_PIXELFORMAT_XRGB32 = SDL_PIXELFORMAT_BGRX8888;
//pub const SDL_PIXELFORMAT_BGRX32 = SDL_PIXELFORMAT_XRGB8888;
//pub const SDL_PIXELFORMAT_XBGR32 = SDL_PIXELFORMAT_RGBX8888;
//pub inline fn SDL_DEFINE_COLORSPACE(@"type": anytype, range: anytype, primaries: anytype, transfer: anytype, matrix: anytype, chroma: anytype) @TypeOf((((((@import("std").zig.c_translation.cast(Uint32, @"type") << @as(c_int, 28)) | (@import("std").zig.c_translation.cast(Uint32, range) << @as(c_int, 24))) | (@import("std").zig.c_translation.cast(Uint32, chroma) << @as(c_int, 20))) | (@import("std").zig.c_translation.cast(Uint32, primaries) << @as(c_int, 10))) | (@import("std").zig.c_translation.cast(Uint32, transfer) << @as(c_int, 5))) | (@import("std").zig.c_translation.cast(Uint32, matrix) << @as(c_int, 0))) {
//    _ = &@"type";
//    _ = &range;
//    _ = &primaries;
//    _ = &transfer;
//    _ = &matrix;
//    _ = &chroma;
//    return (((((@import("std").zig.c_translation.cast(Uint32, @"type") << @as(c_int, 28)) | (@import("std").zig.c_translation.cast(Uint32, range) << @as(c_int, 24))) | (@import("std").zig.c_translation.cast(Uint32, chroma) << @as(c_int, 20))) | (@import("std").zig.c_translation.cast(Uint32, primaries) << @as(c_int, 10))) | (@import("std").zig.c_translation.cast(Uint32, transfer) << @as(c_int, 5))) | (@import("std").zig.c_translation.cast(Uint32, matrix) << @as(c_int, 0));
//}
//pub inline fn SDL_COLORSPACETYPE(X: anytype) SDL_ColorType {
//    _ = &X;
//    return @import("std").zig.c_translation.cast(SDL_ColorType, (X >> @as(c_int, 28)) & @as(c_int, 0x0F));
//}
//pub inline fn SDL_COLORSPACERANGE(X: anytype) SDL_ColorRange {
//    _ = &X;
//    return @import("std").zig.c_translation.cast(SDL_ColorRange, (X >> @as(c_int, 24)) & @as(c_int, 0x0F));
//}
//pub inline fn SDL_COLORSPACECHROMA(X: anytype) SDL_ChromaLocation {
//    _ = &X;
//    return @import("std").zig.c_translation.cast(SDL_ChromaLocation, (X >> @as(c_int, 20)) & @as(c_int, 0x0F));
//}
//pub inline fn SDL_COLORSPACEPRIMARIES(X: anytype) SDL_ColorPrimaries {
//    _ = &X;
//    return @import("std").zig.c_translation.cast(SDL_ColorPrimaries, (X >> @as(c_int, 10)) & @as(c_int, 0x1F));
//}
//pub inline fn SDL_COLORSPACETRANSFER(X: anytype) SDL_TransferCharacteristics {
//    _ = &X;
//    return @import("std").zig.c_translation.cast(SDL_TransferCharacteristics, (X >> @as(c_int, 5)) & @as(c_int, 0x1F));
//}
//pub inline fn SDL_COLORSPACEMATRIX(X: anytype) SDL_MatrixCoefficients {
//    _ = &X;
//    return @import("std").zig.c_translation.cast(SDL_MatrixCoefficients, X & @as(c_int, 0x1F));
//}
//pub inline fn SDL_ISCOLORSPACE_MATRIX_BT601(X: anytype) @TypeOf((SDL_COLORSPACEMATRIX(X) == SDL_MATRIX_COEFFICIENTS_BT601) or (SDL_COLORSPACEMATRIX(X) == SDL_MATRIX_COEFFICIENTS_BT470BG)) {
//    _ = &X;
//    return (SDL_COLORSPACEMATRIX(X) == SDL_MATRIX_COEFFICIENTS_BT601) or (SDL_COLORSPACEMATRIX(X) == SDL_MATRIX_COEFFICIENTS_BT470BG);
//}
//pub inline fn SDL_ISCOLORSPACE_MATRIX_BT709(X: anytype) @TypeOf(SDL_COLORSPACEMATRIX(X) == SDL_MATRIX_COEFFICIENTS_BT709) {
//    _ = &X;
//    return SDL_COLORSPACEMATRIX(X) == SDL_MATRIX_COEFFICIENTS_BT709;
//}
//pub inline fn SDL_ISCOLORSPACE_MATRIX_BT2020_NCL(X: anytype) @TypeOf(SDL_COLORSPACEMATRIX(X) == SDL_MATRIX_COEFFICIENTS_BT2020_NCL) {
//    _ = &X;
//    return SDL_COLORSPACEMATRIX(X) == SDL_MATRIX_COEFFICIENTS_BT2020_NCL;
//}
//pub inline fn SDL_ISCOLORSPACE_LIMITED_RANGE(X: anytype) @TypeOf(SDL_COLORSPACERANGE(X) != SDL_COLOR_RANGE_FULL) {
//    _ = &X;
//    return SDL_COLORSPACERANGE(X) != SDL_COLOR_RANGE_FULL;
//}
//pub inline fn SDL_ISCOLORSPACE_FULL_RANGE(X: anytype) @TypeOf(SDL_COLORSPACERANGE(X) == SDL_COLOR_RANGE_FULL) {
//    _ = &X;
//    return SDL_COLORSPACERANGE(X) == SDL_COLOR_RANGE_FULL;
//}
//pub const SDL_COLORSPACE_RGB_DEFAULT = SDL_COLORSPACE_SRGB;
//pub const SDL_COLORSPACE_YUV_DEFAULT = SDL_COLORSPACE_JPEG;
//pub const SDL_properties_h_ = "";
//pub const SDL_rect_h_ = "";
//pub const SDL_surface_h_ = "";
//pub const SDL_blendmode_h_ = "";
//pub const SDL_BLENDMODE_NONE = @as(c_uint, 0x00000000);
//pub const SDL_BLENDMODE_BLEND = @as(c_uint, 0x00000001);
//pub const SDL_BLENDMODE_BLEND_PREMULTIPLIED = @as(c_uint, 0x00000010);
//pub const SDL_BLENDMODE_ADD = @as(c_uint, 0x00000002);
//pub const SDL_BLENDMODE_ADD_PREMULTIPLIED = @as(c_uint, 0x00000020);
//pub const SDL_BLENDMODE_MOD = @as(c_uint, 0x00000004);
//pub const SDL_BLENDMODE_MUL = @as(c_uint, 0x00000008);
//pub const SDL_BLENDMODE_INVALID = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 0x7FFFFFFF, .hex);
//pub const SDL_iostream_h_ = "";
//pub const SDL_PROP_IOSTREAM_WINDOWS_HANDLE_POINTER = "SDL.iostream.windows.handle";
//pub const SDL_PROP_IOSTREAM_STDIO_FILE_POINTER = "SDL.iostream.stdio.file";
//pub const SDL_PROP_IOSTREAM_FILE_DESCRIPTOR_NUMBER = "SDL.iostream.file_descriptor";
//pub const SDL_PROP_IOSTREAM_ANDROID_AASSET_POINTER = "SDL.iostream.android.aasset";
//pub const SDL_PROP_IOSTREAM_DYNAMIC_MEMORY_POINTER = "SDL.iostream.dynamic.memory";
//pub const SDL_PROP_IOSTREAM_DYNAMIC_CHUNKSIZE_NUMBER = "SDL.iostream.dynamic.chunksize";
//pub const SDL_SURFACE_PREALLOCATED = @as(c_uint, 0x00000001);
//pub const SDL_SURFACE_LOCK_NEEDED = @as(c_uint, 0x00000002);
//pub const SDL_SURFACE_LOCKED = @as(c_uint, 0x00000004);
//pub const SDL_SURFACE_SIMD_ALIGNED = @as(c_uint, 0x00000008);
//pub inline fn SDL_MUSTLOCK(S: anytype) @TypeOf((S.*.flags & SDL_SURFACE_LOCK_NEEDED) == SDL_SURFACE_LOCK_NEEDED) {
//    _ = &S;
//    return (S.*.flags & SDL_SURFACE_LOCK_NEEDED) == SDL_SURFACE_LOCK_NEEDED;
//}
//pub const SDL_PROP_SURFACE_SDR_WHITE_POINT_FLOAT = "SDL.surface.SDR_white_point";
//pub const SDL_PROP_SURFACE_HDR_HEADROOM_FLOAT = "SDL.surface.HDR_headroom";
//pub const SDL_PROP_SURFACE_TONEMAP_OPERATOR_STRING = "SDL.surface.tonemap";
//pub const SDL_PROP_GLOBAL_VIDEO_WAYLAND_WL_DISPLAY_POINTER = "SDL.video.wayland.wl_display";
//pub const SDL_WINDOW_FULLSCREEN = SDL_UINT64_C(@as(c_int, 0x0000000000000001));
//pub const SDL_WINDOW_OPENGL = SDL_UINT64_C(@as(c_int, 0x0000000000000002));
//pub const SDL_WINDOW_OCCLUDED = SDL_UINT64_C(@as(c_int, 0x0000000000000004));
//pub const SDL_WINDOW_HIDDEN = SDL_UINT64_C(@as(c_int, 0x0000000000000008));
//pub const SDL_WINDOW_BORDERLESS = SDL_UINT64_C(@as(c_int, 0x0000000000000010));
//pub const SDL_WINDOW_RESIZABLE = SDL_UINT64_C(@as(c_int, 0x0000000000000020));
//pub const SDL_WINDOW_MINIMIZED = SDL_UINT64_C(@as(c_int, 0x0000000000000040));
//pub const SDL_WINDOW_MAXIMIZED = SDL_UINT64_C(@as(c_int, 0x0000000000000080));
//pub const SDL_WINDOW_MOUSE_GRABBED = SDL_UINT64_C(@as(c_int, 0x0000000000000100));
//pub const SDL_WINDOW_INPUT_FOCUS = SDL_UINT64_C(@as(c_int, 0x0000000000000200));
//pub const SDL_WINDOW_MOUSE_FOCUS = SDL_UINT64_C(@as(c_int, 0x0000000000000400));
//pub const SDL_WINDOW_EXTERNAL = SDL_UINT64_C(@as(c_int, 0x0000000000000800));
//pub const SDL_WINDOW_MODAL = SDL_UINT64_C(@as(c_int, 0x0000000000001000));
//pub const SDL_WINDOW_HIGH_PIXEL_DENSITY = SDL_UINT64_C(@as(c_int, 0x0000000000002000));
//pub const SDL_WINDOW_MOUSE_CAPTURE = SDL_UINT64_C(@as(c_int, 0x0000000000004000));
//pub const SDL_WINDOW_MOUSE_RELATIVE_MODE = SDL_UINT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 0x0000000000008000, .hex));
//pub const SDL_WINDOW_ALWAYS_ON_TOP = SDL_UINT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 0x0000000000010000, .hex));
//pub const SDL_WINDOW_UTILITY = SDL_UINT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 0x0000000000020000, .hex));
//pub const SDL_WINDOW_TOOLTIP = SDL_UINT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 0x0000000000040000, .hex));
//pub const SDL_WINDOW_POPUP_MENU = SDL_UINT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 0x0000000000080000, .hex));
//pub const SDL_WINDOW_KEYBOARD_GRABBED = SDL_UINT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 0x0000000000100000, .hex));
//pub const SDL_WINDOW_VULKAN = SDL_UINT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 0x0000000010000000, .hex));
//pub const SDL_WINDOW_METAL = SDL_UINT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 0x0000000020000000, .hex));
//pub const SDL_WINDOW_TRANSPARENT = SDL_UINT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 0x0000000040000000, .hex));
//pub const SDL_WINDOW_NOT_FOCUSABLE = SDL_UINT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 0x0000000080000000, .hex));
//pub const SDL_WINDOWPOS_UNDEFINED_MASK = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 0x1FFF0000, .hex);
//pub inline fn SDL_WINDOWPOS_UNDEFINED_DISPLAY(X: anytype) @TypeOf(SDL_WINDOWPOS_UNDEFINED_MASK | X) {
//    _ = &X;
//    return SDL_WINDOWPOS_UNDEFINED_MASK | X;
//}
//pub const SDL_WINDOWPOS_UNDEFINED = SDL_WINDOWPOS_UNDEFINED_DISPLAY(@as(c_int, 0));
//pub inline fn SDL_WINDOWPOS_ISUNDEFINED(X: anytype) @TypeOf((X & @import("std").zig.c_translation.promoteIntLiteral(c_int, 0xFFFF0000, .hex)) == SDL_WINDOWPOS_UNDEFINED_MASK) {
//    _ = &X;
//    return (X & @import("std").zig.c_translation.promoteIntLiteral(c_int, 0xFFFF0000, .hex)) == SDL_WINDOWPOS_UNDEFINED_MASK;
//}
//pub const SDL_WINDOWPOS_CENTERED_MASK = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 0x2FFF0000, .hex);
//pub inline fn SDL_WINDOWPOS_CENTERED_DISPLAY(X: anytype) @TypeOf(SDL_WINDOWPOS_CENTERED_MASK | X) {
//    _ = &X;
//    return SDL_WINDOWPOS_CENTERED_MASK | X;
//}
//pub const SDL_WINDOWPOS_CENTERED = SDL_WINDOWPOS_CENTERED_DISPLAY(@as(c_int, 0));
//pub inline fn SDL_WINDOWPOS_ISCENTERED(X: anytype) @TypeOf((X & @import("std").zig.c_translation.promoteIntLiteral(c_int, 0xFFFF0000, .hex)) == SDL_WINDOWPOS_CENTERED_MASK) {
//    _ = &X;
//    return (X & @import("std").zig.c_translation.promoteIntLiteral(c_int, 0xFFFF0000, .hex)) == SDL_WINDOWPOS_CENTERED_MASK;
//}
//pub const SDL_PROP_DISPLAY_HDR_ENABLED_BOOLEAN = "SDL.display.HDR_enabled";
//pub const SDL_PROP_DISPLAY_KMSDRM_PANEL_ORIENTATION_NUMBER = "SDL.display.KMSDRM.panel_orientation";
//pub const SDL_PROP_WINDOW_CREATE_ALWAYS_ON_TOP_BOOLEAN = "SDL.window.create.always_on_top";
//pub const SDL_PROP_WINDOW_CREATE_BORDERLESS_BOOLEAN = "SDL.window.create.borderless";
//pub const SDL_PROP_WINDOW_CREATE_FOCUSABLE_BOOLEAN = "SDL.window.create.focusable";
//pub const SDL_PROP_WINDOW_CREATE_EXTERNAL_GRAPHICS_CONTEXT_BOOLEAN = "SDL.window.create.external_graphics_context";
//pub const SDL_PROP_WINDOW_CREATE_FLAGS_NUMBER = "SDL.window.create.flags";
//pub const SDL_PROP_WINDOW_CREATE_FULLSCREEN_BOOLEAN = "SDL.window.create.fullscreen";
//pub const SDL_PROP_WINDOW_CREATE_HEIGHT_NUMBER = "SDL.window.create.height";
//pub const SDL_PROP_WINDOW_CREATE_HIDDEN_BOOLEAN = "SDL.window.create.hidden";
//pub const SDL_PROP_WINDOW_CREATE_HIGH_PIXEL_DENSITY_BOOLEAN = "SDL.window.create.high_pixel_density";
//pub const SDL_PROP_WINDOW_CREATE_MAXIMIZED_BOOLEAN = "SDL.window.create.maximized";
//pub const SDL_PROP_WINDOW_CREATE_MENU_BOOLEAN = "SDL.window.create.menu";
//pub const SDL_PROP_WINDOW_CREATE_METAL_BOOLEAN = "SDL.window.create.metal";
//pub const SDL_PROP_WINDOW_CREATE_MINIMIZED_BOOLEAN = "SDL.window.create.minimized";
//pub const SDL_PROP_WINDOW_CREATE_MODAL_BOOLEAN = "SDL.window.create.modal";
//pub const SDL_PROP_WINDOW_CREATE_MOUSE_GRABBED_BOOLEAN = "SDL.window.create.mouse_grabbed";
//pub const SDL_PROP_WINDOW_CREATE_OPENGL_BOOLEAN = "SDL.window.create.opengl";
//pub const SDL_PROP_WINDOW_CREATE_PARENT_POINTER = "SDL.window.create.parent";
//pub const SDL_PROP_WINDOW_CREATE_RESIZABLE_BOOLEAN = "SDL.window.create.resizable";
//pub const SDL_PROP_WINDOW_CREATE_TITLE_STRING = "SDL.window.create.title";
//pub const SDL_PROP_WINDOW_CREATE_TRANSPARENT_BOOLEAN = "SDL.window.create.transparent";
//pub const SDL_PROP_WINDOW_CREATE_TOOLTIP_BOOLEAN = "SDL.window.create.tooltip";
//pub const SDL_PROP_WINDOW_CREATE_UTILITY_BOOLEAN = "SDL.window.create.utility";
//pub const SDL_PROP_WINDOW_CREATE_VULKAN_BOOLEAN = "SDL.window.create.vulkan";
//pub const SDL_PROP_WINDOW_CREATE_WIDTH_NUMBER = "SDL.window.create.width";
//pub const SDL_PROP_WINDOW_CREATE_X_NUMBER = "SDL.window.create.x";
//pub const SDL_PROP_WINDOW_CREATE_Y_NUMBER = "SDL.window.create.y";
//pub const SDL_PROP_WINDOW_CREATE_COCOA_WINDOW_POINTER = "SDL.window.create.cocoa.window";
//pub const SDL_PROP_WINDOW_CREATE_COCOA_VIEW_POINTER = "SDL.window.create.cocoa.view";
//pub const SDL_PROP_WINDOW_CREATE_WAYLAND_SURFACE_ROLE_CUSTOM_BOOLEAN = "SDL.window.create.wayland.surface_role_custom";
//pub const SDL_PROP_WINDOW_CREATE_WAYLAND_CREATE_EGL_WINDOW_BOOLEAN = "SDL.window.create.wayland.create_egl_window";
//pub const SDL_PROP_WINDOW_CREATE_WAYLAND_WL_SURFACE_POINTER = "SDL.window.create.wayland.wl_surface";
//pub const SDL_PROP_WINDOW_CREATE_WIN32_HWND_POINTER = "SDL.window.create.win32.hwnd";
//pub const SDL_PROP_WINDOW_CREATE_WIN32_PIXEL_FORMAT_HWND_POINTER = "SDL.window.create.win32.pixel_format_hwnd";
//pub const SDL_PROP_WINDOW_CREATE_X11_WINDOW_NUMBER = "SDL.window.create.x11.window";
//pub const SDL_PROP_WINDOW_SHAPE_POINTER = "SDL.window.shape";
//pub const SDL_PROP_WINDOW_HDR_ENABLED_BOOLEAN = "SDL.window.HDR_enabled";
//pub const SDL_PROP_WINDOW_SDR_WHITE_LEVEL_FLOAT = "SDL.window.SDR_white_level";
//pub const SDL_PROP_WINDOW_HDR_HEADROOM_FLOAT = "SDL.window.HDR_headroom";
//pub const SDL_PROP_WINDOW_ANDROID_WINDOW_POINTER = "SDL.window.android.window";
//pub const SDL_PROP_WINDOW_ANDROID_SURFACE_POINTER = "SDL.window.android.surface";
//pub const SDL_PROP_WINDOW_UIKIT_WINDOW_POINTER = "SDL.window.uikit.window";
//pub const SDL_PROP_WINDOW_UIKIT_METAL_VIEW_TAG_NUMBER = "SDL.window.uikit.metal_view_tag";
//pub const SDL_PROP_WINDOW_UIKIT_OPENGL_FRAMEBUFFER_NUMBER = "SDL.window.uikit.opengl.framebuffer";
//pub const SDL_PROP_WINDOW_UIKIT_OPENGL_RENDERBUFFER_NUMBER = "SDL.window.uikit.opengl.renderbuffer";
//pub const SDL_PROP_WINDOW_UIKIT_OPENGL_RESOLVE_FRAMEBUFFER_NUMBER = "SDL.window.uikit.opengl.resolve_framebuffer";
//pub const SDL_PROP_WINDOW_KMSDRM_DEVICE_INDEX_NUMBER = "SDL.window.kmsdrm.dev_index";
//pub const SDL_PROP_WINDOW_KMSDRM_DRM_FD_NUMBER = "SDL.window.kmsdrm.drm_fd";
//pub const SDL_PROP_WINDOW_KMSDRM_GBM_DEVICE_POINTER = "SDL.window.kmsdrm.gbm_dev";
//pub const SDL_PROP_WINDOW_COCOA_WINDOW_POINTER = "SDL.window.cocoa.window";
//pub const SDL_PROP_WINDOW_COCOA_METAL_VIEW_TAG_NUMBER = "SDL.window.cocoa.metal_view_tag";
//pub const SDL_PROP_WINDOW_VIVANTE_DISPLAY_POINTER = "SDL.window.vivante.display";
//pub const SDL_PROP_WINDOW_VIVANTE_WINDOW_POINTER = "SDL.window.vivante.window";
//pub const SDL_PROP_WINDOW_VIVANTE_SURFACE_POINTER = "SDL.window.vivante.surface";
//pub const SDL_PROP_WINDOW_WIN32_HWND_POINTER = "SDL.window.win32.hwnd";
//pub const SDL_PROP_WINDOW_WIN32_HDC_POINTER = "SDL.window.win32.hdc";
//pub const SDL_PROP_WINDOW_WIN32_INSTANCE_POINTER = "SDL.window.win32.instance";
//pub const SDL_PROP_WINDOW_WAYLAND_DISPLAY_POINTER = "SDL.window.wayland.display";
//pub const SDL_PROP_WINDOW_WAYLAND_SURFACE_POINTER = "SDL.window.wayland.surface";
//pub const SDL_PROP_WINDOW_WAYLAND_EGL_WINDOW_POINTER = "SDL.window.wayland.egl_window";
//pub const SDL_PROP_WINDOW_WAYLAND_XDG_SURFACE_POINTER = "SDL.window.wayland.xdg_surface";
//pub const SDL_PROP_WINDOW_WAYLAND_XDG_TOPLEVEL_POINTER = "SDL.window.wayland.xdg_toplevel";
//pub const SDL_PROP_WINDOW_WAYLAND_XDG_TOPLEVEL_EXPORT_HANDLE_STRING = "SDL.window.wayland.xdg_toplevel_export_handle";
//pub const SDL_PROP_WINDOW_WAYLAND_XDG_POPUP_POINTER = "SDL.window.wayland.xdg_popup";
//pub const SDL_PROP_WINDOW_WAYLAND_XDG_POSITIONER_POINTER = "SDL.window.wayland.xdg_positioner";
//pub const SDL_PROP_WINDOW_X11_DISPLAY_POINTER = "SDL.window.x11.display";
//pub const SDL_PROP_WINDOW_X11_SCREEN_NUMBER = "SDL.window.x11.screen";
//pub const SDL_PROP_WINDOW_X11_WINDOW_NUMBER = "SDL.window.x11.window";
//pub const SDL_WINDOW_SURFACE_VSYNC_DISABLED = @as(c_int, 0);
//pub const SDL_WINDOW_SURFACE_VSYNC_ADAPTIVE = -@as(c_int, 1);
//pub const threadlocaleinfostruct = struct_threadlocaleinfostruct;
//pub const threadmbcinfostruct = struct_threadmbcinfostruct;
//pub const __lc_time_data = struct___lc_time_data;
//pub const localeinfo_struct = struct_localeinfo_struct;
//pub const tagLC_ID = struct_tagLC_ID;
//pub const _iobuf = struct__iobuf;
//pub const _wfinddata32_t = struct__wfinddata32_t;
//pub const _wfinddata32i64_t = struct__wfinddata32i64_t;
//pub const _wfinddata64i32_t = struct__wfinddata64i32_t;
//pub const _wfinddata64_t = struct__wfinddata64_t;
//pub const _stat32 = struct__stat32;
//pub const stat = struct_stat;
//pub const _stat32i64 = struct__stat32i64;
//pub const _stat64i32 = struct__stat64i32;
//pub const _stat64 = struct__stat64;
//pub const tm = struct_tm;
//pub const SDL_iconv_data_t = struct_SDL_iconv_data_t;
//pub const SDL_GLContextState = struct_SDL_GLContextState;
