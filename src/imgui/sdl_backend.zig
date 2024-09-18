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

    bd.*.mouse_cursors[imgui.MouseCursorNames.none] = sdl.c.SDL_CreateSystemCursor(sdl.c.SDL_SYSTEM_CURSOR_DEFAULT);
}