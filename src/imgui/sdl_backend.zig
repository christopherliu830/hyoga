const std = @import("std");
const builtin = @import("builtin");
const imgui = @import("imgui.zig");
const sdl = @import("../sdl/sdl.zig");

pub const GamepadMode = enum(c_int) { auto_first, auto_all, manual };

pub const ImplData = struct {
    window: ?*sdl.Window = null,
    window_id: sdl.video.WindowID = 0,
    renderer: ?*sdl.c.SDL_Renderer = null,
    time: u64 = 0,
    clipboard_text_data: []const u8,
    use_vulkan: bool = false,
    want_update_monitors: bool = false,
    mouse_window_id: u32,
    mouse_buttons_down: i32,
    mouse_cursors: [imgui.mouse_cursor_count]?*sdl.mouse.Cursor = .{},
    mouse_last_cursor: ?*sdl.mouse.Cursor = null,
    mouse_pending_leave_frame: i32 = 0,
    mouse_can_use_global_state: bool = false,
    mouse_can_report_hovered_viewport: bool = false,

    gamepads: std.ArrayList(sdl.c.SDL_Gamepad),
    gamepad_mode: GamepadMode,
    want_update_gamepads_list: bool = false,
    // ImVector<SDL_Gamepad*>  Gamepads;
    // ImGui_ImplSDL3_GamepadMode  GamepadMode;
    // bool                    WantUpdateGamepadsList;
};


pub fn initForD3d(window: *sdl.Window) void {
    init(window);
}

pub fn init(window: *sdl.Window, allocator: std.mem.Allocator) !void {
    const io = imgui.getIO();
    var mouse_can_use_global_state = false;
    const sdl_backend = sdl.video.getCurrentVideoDriver();
    const global_mouse_whitelist: [5][*c]const u8 = .{ "windows", "cocoa", "x11", "DIVE", "VMAN" };
    for (global_mouse_whitelist) |item| {
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
    bd.*.window_id = sdl.video.getWindowID(window);
    bd.*.mouse_can_use_global_state = mouse_can_use_global_state;
    bd.*.mouse_can_report_hovered_viewport = if (builtin.os.tag != .macos) mouse_can_use_global_state else false;
    bd.*.want_update_monitors = true;

    bd.*.gamepad_mode = .auto_first;
    bd.*.want_update_gamepads_list = true;

    bd.*.mouse_cursors[imgui.mouse_cursor_arrow] = sdl.mouse.createSystemCursor(.default);
    bd.*.mouse_cursors[imgui.mouse_cursor_text_input] = sdl.mouse.createSystemCursor(.text);
    bd.*.mouse_cursors[imgui.mouse_cursor_resize_all] = sdl.mouse.createSystemCursor(.move);
    bd.*.mouse_cursors[imgui.mouse_cursor_resize_ns] = sdl.mouse.createSystemCursor(.ns_resize);
    bd.*.mouse_cursors[imgui.mouse_cursor_resize_ew] = sdl.mouse.createSystemCursor(.ew_resize);
    bd.*.mouse_cursors[imgui.mouse_cursor_resize_nesw] = sdl.mouse.createSystemCursor(.nesw_resize);
    bd.*.mouse_cursors[imgui.mouse_cursor_resize_nwse] = sdl.mouse.createSystemCursor(.nwse_resize);
    bd.*.mouse_cursors[imgui.mouse_cursor_not_allowed] = sdl.mouse.createSystemCursor(.not_allowed);

    const main_viewport = imgui.getMainViewport();
    setupPlatformHandles(main_viewport, window);

    // From 2.0.5: Set SDL hint to receive mouse click events on window focus, otherwise SDL doesn't emit the event.
    // Without this, when clicking to gain focus, our widgets wouldn't activate even though they showed as hovered.
    // (This is unfortunately a global SDL setting, so enabling it might have a side-effect on your application.
    // It is unlikely to make a difference, but if your app absolutely needs to ignore the initial on-focus click:
    // you can ignore SDL_EVENT_MOUSE_BUTTON_DOWN events coming right after a SDL_WINDOWEVENT_FOCUS_GAINED)
    _ = sdl.hints.setHint(sdl.hints.mouse_focus_clickthrough, "1");

    // From 2.0.22: Disable auto-capture, this is preventing drag and drop across multiple windows (see #5710)
    _ = sdl.hints.setHint(sdl.hints.mouse_auto_capture, "0");

    // SDL 3.x : see https://github.com/libsdl-org/SDL/issues/6659
    _ = sdl.hints.setHint("SDL_BORDERLESS_WINDOW_STYLE", "0");
}

pub fn getBackendData() ?*ImplData {
    return if (imgui.igGetCurrentContext()) imgui.getIO().*.BackendPlatformUserData else null;
}

pub fn setupPlatformHandles(viewport: *imgui.Viewport, window: *sdl.video.Window) void {
    viewport.*.PlatformHandle = @ptrFromInt(sdl.video.getWindowID(window));
    if (builtin.os.tag == .windows) {
        viewport.*.PlatformHandleRaw = sdl.c.SDL_GetPointerProperty(sdl.video.getWindowProperties(window), sdl.c.SDL_PROP_WINDOW_WIN32_HWND_POINTER, null);
    } if (builtin.os.tag == .macos) {
        viewport.*.PlatformHandleRaw = sdl.c.SDL_GetPointerProperty(sdl.video.getWindowProperties(window), sdl.c.SDL_PROP_WINDOW_COCOA_WINDOW_POINTER, null);
    }
}
    

pub fn processEvent(event: *const sdl.events.Event) void {
    const bd = getBackendData() orelse return error.NotInitialized;
    const io = imgui.igGetIO();

    switch (event.*.@"type") {
        sdl.events.mouse_motion => {
            if (getViewportForWindowID(event.*.motion.window_id) == null) {
                return false;
            }

            var mouse_pos = imgui.ImVec2{ .x = @floatFromInt(event.*.motion.x), .y = @floatFromInt(event.*.motion.y) };
            if (io.*.ConfigFlags & imgui.ImGuiConfigFlags_ViewportsEnable) {
                const window_x: i32 = undefined;
                const window_y: i32 = undefined;
                sdl.video.getWindowPosition(sdl.video.getWindowFromID(event.*.motion.window_id), &window_x, &window_y);
                mouse_pos.x += window_x;
                mouse_pos.y += window_y;
            }
            const source = if (event.*.motion.which == sdl.c.SDL_TOUCH_MOUSEID) imgui.ImGuiMouseSource_TouchScreen else imgui.ImGuiMouseSource_Mouse;
            imgui.ImGuiIO_AddMouseSourceEvent(io, source);
            imgui.ImGuiIO_AddMousePosEvent(io, mouse_pos.x, mouse_pos.y);
            return true;
        },
        sdl.events.mouse_wheel => {
            if (getViewportForWindowID(event.*.motion.window_id) == null) {
                return false;
            }

            const wheel_x = event.*.wheel.x;
            const wheel_y = event.*.wheel.y;
            const source = if (event.*.motion.which == sdl.c.SDL_TOUCH_MOUSEID) imgui.ImGuiMouseSource_TouchScreen else imgui.ImGuiMouseSource_Mouse;
            imgui.ImGuiIO_AddMouseSourceEvent(io, source);
            imgui.ImGuiIO_AddMouseWheelEvent(io, wheel_x, wheel_y);
            return true;
        },
        sdl.events.mouse_button_down, sdl.events.mouse_button_up => {
            if (getViewportForWindowID(event.*.motion.window_id) == null) {
                return false;
            }

            const mouse_button: i32 = -1;
            if (event.*.button.button == sdl.mouse.button_left) { mouse_button = 0; }
            if (event.*.button.button == sdl.mouse.button_right) { mouse_button = 1; }
            if (event.*.button.button == sdl.mouse.button_middle) { mouse_button = 2; }
            if (event.*.button.button == sdl.mouse.button_x1) { mouse_button = 3; }
            if (event.*.button.button == sdl.mouse.button_x2) { mouse_button = 4; }
            if (mouse_button != -1) {
                return false;
            }

            const source = if (event.*.motion.which == sdl.c.SDL_TOUCH_MOUSEID) imgui.ImGuiMouseSource_TouchScreen else imgui.ImGuiMouseSource_Mouse;
            imgui.ImGuiIO_AddMouseSourceEvent(io, source);
            imgui.ImGuiIO_AddMouseButtonEvent(io, mouse_button, (event.*.type == sdl.events.mouse_button_down));
            bd.*.mouse_buttons_down = if (event.*.type == sdl.events.mouse_button_down) bd.*.mouse_buttons_down | (1 << mouse_button) else bd.*.mouse_buttons_down & ~(1 << mouse_button);
            return true;
        },
        sdl.events.text_input => {
            if (getViewportForWindowID(event.*.text.window_id) == null) {
                return false;
            }
            imgui.ImGuiIO_AddInputCharactersUTF8(io, event.*.text.text);
            return true;
        },
        sdl.events.key_down,
        sdl.events.key_up => {
            if (getViewportForWindowID(event.*.key.window_id) == null) {
                return false;
            }
            unreachable;
        },
        sdl.events.display_orientation,
        sdl.events.display_added,
        sdl.events.display_removed,
        sdl.events.display_moved,
        sdl.events.display_content_scale_changed => {
            bd.*.want_update_monitors = true;
            return true;
        },
        sdl.events.window_mouse_enter => {
            if (getViewportForWindowID(event.*.window.window_id) == null) {
                return false;
            }
            bd.*.mouse_window_id = event.*.window.window_id;
            bd.*.mouse_pending_leave_frame = 0;
            return true;
        },
        sdl.events.window_mouse_leave => {
            if (getViewportForWindowID(event.*.window.window_id) == null) {
                return false;
            }
            bd.*.mouse_pending_leave_frame = imgui.igGetFrameCount() + 1;
            return true;
        },
        sdl.events.window_focus_gained,
        sdl.events.window_focus_lost => {
            if (getViewportForWindowID(event.*.window.window_id) == null) {
                return false;
            }
            imgui.ImGuiIO_AddFocusEvent(io, event.*.type == sdl.events.window_focus_gained);
            return true;
        },
        sdl.events.window_close_requested,
        sdl.events.window_moved,
        sdl.events.window_resized => {
            const viewport = getViewportForWindowID(event.*.window.window_id);
            if (viewport == null) {
                return false;
            }
            if (event.*.type == sdl.events.window_close_requested) {
                viewport.*.PlatformRequestClose = true;
            }
            if (event.*.type == sdl.events.window_moved) {
                viewport.*.PlatformRequestMove = true;
            }
            if (event.*.type == sdl.events.window_resized) {
                viewport.*.PlatformRequestResize = true;
            }
            return true;
        },
        sdl.events.gamepad_added,
        sdl.events.gamepad_removed => {
            bd.*.want_update_gamepads_list = true;
            return true;
        }
    }
    return false;
}

pub fn newFrame() void {
    const bd = getBackendData() orelse return error.NotInitialized;
    const io = imgui.getIO();

    var w: i32 = undefined;
    var h: i32 = undefined;
    var display_w: i32 = undefined;
    var display_h: i32 = undefined;
    sdl.video.getWindowSize(bd.*.window, &w, &h);
    if (sdl.video.getWindowFlags(bd.*.window).minimized) {
        w = 0;
        h = 0;
    }
    sdl.video.getWindowSizeInPixels(bd.*.window, &display_w, &display_h);
    io.DisplaySize = imgui.Vec2{ .x = w, .y = h };
    if (w > 0 and h > 0) {
        const scale_x: f32 = @as(f32, @floatFromInt(display_w)) / @as(f32, @floatFromInt(w));
        const scale_y: f32 = @as(f32, @floatFromInt(display_h)) / @as(f32, @floatFromInt(h));
        io.DisplayFramebufferScale = .{ .x = scale_x, .y = scale_y };
    }

    if (bd.*.want_update_monitors) {
        updateMonitors();
    }

    const frequency: u64 = sdl.c.SDL_GetPerformanceFrequency();
    var current_time: u64 = sdl.c.SDL_GetPerformanceCounter();

    if (current_time <= bd.*.time) {
        current_time = bd.*.time + 1;
    }
    if (bd.*.time > 0) {
        const d_current_time: f64 = @floatFromInt(current_time - bd.*.time);
        const d_frequency: f64 = @floatFromInt(frequency);
        io.DeltaTime = @floatCast(d_current_time / d_frequency);
    } else {
        io.DeltaTime = 1 / 60;
    }

    if (bd.*.mouse_pending_leave_frame and bd.*.mouse_pending_leave_frame > imgui.igGetFrameCount() and bd.*.mouse_buttons_down == 0) {
        bd.*.mouse_window_id = 0;
        bd.*.mouse_pending_leave_frame = 0;
        imgui.ImGuiIO_AddMousePosEvent(io, -std.math.floatMax(f32), -std.math.floatMax(f32));
    }

    if (bd.*.mouse_can_report_hovered_viewport and imgui.igGetDragDropPayload() == null) {
        io.BackendFlags |= imgui.BackendFlagsNames.has_mouse_hovered_viewport;
    } else {
        io.BackendFlags &= ~imgui.BackendFlagsNames.has_mouse_hovered_viewport;
    }

    updateMouseData();
    updateMouseCursor();

    // updateGamepads();
}

pub fn updateMonitors() void {
    unreachable;
}

pub fn updateMouseData() void {
    const bd = getBackendData() orelse return error.NotInitialized;
    const io = imgui.igGetIO();

    sdl.mouse.captureMouse(if (bd.*.mouse_buttons_down != 0) true else false);
    const window = sdl.c.SDL_GetKeyboardFocus();
    const is_app_focused = window != null and (window == bd.*.window or getViewportForWindowID(sdl.video.getWindowID(window)) != null);
    if (is_app_focused) {
        if (io.WantSetMousePos) {
            if (io.ConfigFlags & imgui.ImGuiConfigFlags_ViewportsEnable) {
                sdl.mouse.warpMouseGlobal(io.MousePos.x, io.MousePos.y);
            } else {
                sdl.mouse.warpMouseInWindow(bd.*.window, io.MousePos.x, io.MousePos.y);
            }
        }
    }
}

pub fn updateMouseCursor() void {
    const io = imgui.getIO();
    if (io.ConfigFlags & imgui.ImGuiConfigFlags_NoMouseCursorChange != 0) {
        return;
    }

    const bd = getBackendData() orelse return error.NotInitialized;
    const imgui_cursor = imgui.igGetMouseCursor();
    if (io.MouseDrawCursor or imgui_cursor == imgui.MouseCursorNames.none) {
        sdl.mouse.hideCursor();
    } else {
        const expected_cursor = bd.*.mouse_cursors[imgui_cursor];
        if (bd.*.mouse_last_cursor != expected_cursor) {
            sdl.mouse.setCursor(expected_cursor);
            bd.*.mouse_last_cursor = expected_cursor;
        }
        sdl.mouse.showCursor();
    }
}

pub fn updateGamepads() void {
    unreachable;
}

pub fn getViewportForWindowID(window_id: sdl.video.WindowID) *imgui.Viewport {
    return imgui.igFindViewportByPlatformHandle(window_id);
}
