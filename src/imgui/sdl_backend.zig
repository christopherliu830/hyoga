const std = @import("std");
const builtin = @import("builtin");
const imgui = @import("imgui.zig");
const sdl = @import("../sdl/sdl.zig");

pub const GamepadMode = enum (c_int) {
    auto_first,
    auto_all,
    manual
};

pub const ImplData = struct {
    window: ?*sdl.Window = null,
    window_id: sdl.video.Id = 0,
    renderer: ?*sdl.c.SDL_Renderer = null,
    time: u64 = 0,
    clipboard_text_data: []const u8,
    use_vulkan: bool = false,
    want_update_monitors: bool = false,
    mouse_window_id: u32,
    mouse_buttons_down: i32,
    mouse_cursors: [imgui.ImGuiMouseCursor_COUNT]?*sdl.c.SDL_Cursor = .{},
    mouse_can_use_global_state: bool = false,
    mouse_can_report_hovered_viewport: bool = false,

    gamepads: std.ArrayList(sdl.c.SDL_Gamepad),
    gamepad_mode: GamepadMode,
    want_update_gamepads_list: bool = false,
    // ImVector<SDL_Gamepad*>  Gamepads;
    // ImGui_ImplSDL3_GamepadMode  GamepadMode;
    // bool                    WantUpdateGamepadsList;
};

    // SDL_Window*             Window;
    // SDL_WindowID            WindowID;
    // SDL_Renderer*           Renderer;
    // Uint64                  Time;
    // char*                   ClipboardTextData;
    // bool                    UseVulkan;
    // bool                    WantUpdateMonitors;

    // // IME handling
    // SDL_Window*             ImeWindow;

    // // Mouse handling
    // Uint32                  MouseWindowID;
    // int                     MouseButtonsDown;
    // SDL_Cursor*             MouseCursors[ImGuiMouseCursor_COUNT];
    // SDL_Cursor*             MouseLastCursor;
    // int                     MousePendingLeaveFrame;
    // bool                    MouseCanUseGlobalState;
    // bool                    MouseCanReportHoveredViewport;  // This is hard to use/unreliable on SDL so we'll set ImGuiBackendFlags_HasMouseHoveredViewport dynamically based on state.

    // // Gamepad handling
    // ImVector<SDL_Gamepad*>  Gamepads;
    // ImGui_ImplSDL3_GamepadMode  GamepadMode;
    // bool                    WantUpdateGamepadsList;

    // ImGui_ImplSDL3_Data()   { memset((void*)this, 0, sizeof(*this)); }

pub fn initForD3d(window: *sdl.Window) void {
    init(window);
}

pub fn init(window: *sdl.Window, allocator: std.mem.Allocator) void {
    const io = imgui.igGetIO();
    _ = io;
    var mouse_can_use_global_state = false;
    const sdl_backend = sdl.video.getCurrentVideoDriver();
    const global_mouse_whitelist = .{
        "windows",
        "cocoa",
        "x11",
        "DIVE",
        "VMAN"
    };
    for(global_mouse_whitelist) |item| {
        if (item == sdl_backend) {
            mouse_can_use_global_state = true;
        }
    }
    const bd = try allocator.create(ImplData);

    io.*.BackendPlatformUserData = bd;
    io.BackendPlatformName = "imgui_impl_sdl3";
    io.BackendFlags |= imgui.BackendFlagsNames.has_mouse_cursors;
    io.BackendFlags |= imgui.BackendFlagsNames.has_set_mouse_pos;
    if (mouse_can_use_global_state) {
        io.BackendFlags |= imgui.BackendFlagsNames.platform_has_viewports;
    }
    bd.*.window = sdl.video.getWindowId(window);
    bd.*.mouse_can_use_global_state = mouse_can_use_global_state;
    bd.*.mouse_can_report_hovered_viewport = if (builtin.os.tag != .macos) mouse_can_use_global_state else false;
    bd.*.want_update_monitors = true;

    bd.*.gamepad_mode = .auto_first;
    bd.*.want_update_gamepads_list = true;

    bd.*.mouse_cursors[imgui.MouseCursorNames.none] = sdl.mouse.createSystemCursor(.default);
    bd.*.mouse_cursors[imgui.MouseCursorNames.text_input] = sdl.mouse.createSystemCursor(.text);
    bd.*.mouse_cursors[imgui.MouseCursorNames.resize_all] = sdl.mouse.createSystemCursor(.move);
    bd.*.mouse_cursors[imgui.MouseCursorNames.resize_ns] = sdl.mouse.createSystemCursor(.ns_resize);
    bd.*.mouse_cursors[imgui.MouseCursorNames.resize_ew] = sdl.mouse.createSystemCursor(.ew_resize);
    bd.*.mouse_cursors[imgui.MouseCursorNames.resize_nesw] = sdl.mouse.createSystemCursor(.nesw_resize);
    bd.*.mouse_cursors[imgui.MouseCursorNames.resize_nwse] = sdl.mouse.createSystemCursor(.nwse_resize);
    bd.*.mouse_cursors[imgui.MouseCursorNames.not_allowed] = sdl.mouse.createSystemCursor(.not_allowed);

    const main_viewport = imgui.getMainViewport();
    setupPlatformHandles(main_viewport, window);

    // From 2.0.5: Set SDL hint to receive mouse click events on window focus, otherwise SDL doesn't emit the event.
    // Without this, when clicking to gain focus, our widgets wouldn't activate even though they showed as hovered.
    // (This is unfortunately a global SDL setting, so enabling it might have a side-effect on your application.
    // It is unlikely to make a difference, but if your app absolutely needs to ignore the initial on-focus click:
    // you can ignore SDL_EVENT_MOUSE_BUTTON_DOWN events coming right after a SDL_WINDOWEVENT_FOCUS_GAINED)
    sdl.hints.setHint(sdl.hints.mouse_focus_clickthrough, "1");

    // From 2.0.22: Disable auto-capture, this is preventing drag and drop across multiple windows (see #5710)
    sdl.hints.setHint(sdl.hints.mouse_auto_capture, "0");

    // SDL 3.x : see https://github.com/libsdl-org/SDL/issues/6659
    sdl.hints.setHint("SDL_BORDERLESS_WINDOW_STYLE", "0");

    if (io.ConfigFlags & imgui.ImGuiConfigFlags_ViewportsEnable != 0 and io.BackendFlags & imgui.BackendFlagsNames.platform_has_viewports != 0) {

    }

}

pub fn getBackendData() ?*ImplData {
    return if (imgui.igGetCurrentContext()) imgui.getIO().*.BackendPlatformUserData else null;
}

pub fn setupPlatformHandles(viewport: *imgui.Viewport, window: sdl.Window) void {
    viewport.*.PlatformHandle = sdl.video.getWindowID(window);
    viewport.*.PlatformHandleRaw = null;
    if (std.builtin.os.tag == .windows and !std.builtin.os.windows.is_winrt) {
        viewport.*.PlatformHandleRaw = sdl.c.SDL_GetPointerProperty(sdl.video.getWindowProperties(window), sdl.c.SDL_PROP_WINDOW_CREATE_WIN32_HWND_POINTER, null);
    } else if (std.builtin.os.tag == .macos) {
        unreachable;
    }
}

pub fn initPlatformInterface(window: sdl.Window, sdl_gl_context: ?*anyopaque) void {
    var pio = imgui.igGetPlatformIO();
    pio.*.Platform_CreateWindow =; //
    var bd = getBackendData();
    if (!bd) return error.NotInitialized;
}

pub fn newFrame() void {

}