const std = @import("std");
const builtin = @import("builtin");
const imgui = @import("imgui.zig");
const sdl = @import("sdl");

pub const GamepadMode = enum(c_int) { auto_first, auto_all, manual };

pub const ImplData = struct {
    allocator: std.mem.Allocator,
    window: ?*sdl.Window = null,
    window_id: sdl.video.WindowID = 0,
    renderer: ?*sdl.c.SDL_Renderer = null,
    time: u64 = 0,
    clipboard_text_data: []const u8 = undefined,
    use_vulkan: bool = false,
    want_update_monitors: bool = false,
    mouse_window_id: u32 = 0,
    mouse_buttons_down: i32 = 0,
    mouse_cursors: [imgui.mouse_cursor_count]?*sdl.mouse.Cursor = undefined,
    mouse_last_cursor: ?*sdl.mouse.Cursor = null,
    mouse_pending_leave_frame: i32 = 0,
    mouse_can_use_global_state: bool = false,
    mouse_can_report_hovered_viewport: bool = false,

    gamepads: std.ArrayList(sdl.c.SDL_Gamepad) = undefined,
    gamepad_mode: GamepadMode = undefined,
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
    bd.* = .{
        .allocator = allocator,
    };

    io.BackendPlatformUserData = bd;
    io.BackendPlatformName = "imgui_impl_sdl3";
    io.BackendFlags |= imgui.backend_flags_has_mouse_cursors;
    io.BackendFlags |= imgui.backend_flags_has_set_mouse_pos;
    if (mouse_can_use_global_state) {
        io.BackendFlags |= imgui.backend_flags_platform_has_viewports;
    }
    bd.window = window;
    bd.window_id = sdl.video.getWindowID(window);
    bd.mouse_can_use_global_state = mouse_can_use_global_state;
    bd.mouse_can_report_hovered_viewport = if (builtin.os.tag != .macos) mouse_can_use_global_state else false;
    bd.want_update_monitors = true;

    bd.gamepad_mode = .auto_first;
    bd.want_update_gamepads_list = true;

    bd.mouse_cursors[imgui.mouse_cursor_arrow] = sdl.mouse.createSystemCursor(.default);
    bd.mouse_cursors[imgui.mouse_cursor_text_input] = sdl.mouse.createSystemCursor(.text);
    bd.mouse_cursors[imgui.mouse_cursor_resize_all] = sdl.mouse.createSystemCursor(.move);
    bd.mouse_cursors[imgui.mouse_cursor_resize_ns] = sdl.mouse.createSystemCursor(.ns_resize);
    bd.mouse_cursors[imgui.mouse_cursor_resize_ew] = sdl.mouse.createSystemCursor(.ew_resize);
    bd.mouse_cursors[imgui.mouse_cursor_resize_nesw] = sdl.mouse.createSystemCursor(.nesw_resize);
    bd.mouse_cursors[imgui.mouse_cursor_resize_nwse] = sdl.mouse.createSystemCursor(.nwse_resize);
    bd.mouse_cursors[imgui.mouse_cursor_not_allowed] = sdl.mouse.createSystemCursor(.not_allowed);

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

pub fn shutdown() void {
    const bd = getBackendData().?;
    const io = imgui.getIO();

    //TODO: free clipboard

    imgui.destroyPlatformWindows();
    for(bd.mouse_cursors) |cursor| {
        sdl.mouse.destroyCursor(cursor);
    }
    //TODO: reset gamepad

    io.BackendPlatformName = null;
    io.BackendPlatformUserData = null;
    io.BackendFlags &= ~(imgui.backend_flags_has_mouse_cursors | imgui.backend_flags_has_set_mouse_pos | imgui.backend_flags_platform_has_viewports);

    bd.allocator.destroy(bd);
}

pub fn getBackendData() ?*ImplData {
    if (imgui.igGetCurrentContext() != null) {
        return @ptrCast(@alignCast(imgui.getIO().BackendPlatformUserData));
    } else return null;
}

pub fn setupPlatformHandles(viewport: *imgui.Viewport, window: *sdl.video.Window) void {
    viewport.PlatformHandle = @ptrFromInt(sdl.video.getWindowID(window));
    if (builtin.os.tag == .windows) {
        viewport.PlatformHandleRaw = sdl.c.SDL_GetPointerProperty(sdl.video.getWindowProperties(window), sdl.c.SDL_PROP_WINDOW_WIN32_HWND_POINTER, null);
    } if (builtin.os.tag == .macos) {
        viewport.PlatformHandleRaw = sdl.c.SDL_GetPointerProperty(sdl.video.getWindowProperties(window), sdl.c.SDL_PROP_WINDOW_COCOA_WINDOW_POINTER, null);
    }
}    

pub fn processEvent(event: *const sdl.events.Event) !bool {
    const bd = getBackendData() orelse return error.NotInitialized;
    const io = imgui.getIO();

    switch (event.type) {
        sdl.events.mouse_motion => {
            if (getViewportForWindowID(event.motion.windowid) == null) {
                return false;
            }

            var mouse_pos = imgui.Vec2 { .x = event.motion.x, .y = event.motion.y };
            if (io.ConfigFlags & imgui.ImGuiConfigFlags_ViewportsEnable != 0) {
                var window_x: c_int = undefined;
                var window_y: c_int = undefined;
                _ = sdl.video.getWindowPosition(sdl.video.getWindowFromID(event.motion.windowid), &window_x, &window_y);
                mouse_pos.x += @floatFromInt(window_x);
                mouse_pos.y += @floatFromInt(window_y);
            }
            const source = if (event.motion.which == sdl.c.SDL_TOUCH_MOUSEID) imgui.ImGuiMouseSource_TouchScreen else imgui.ImGuiMouseSource_Mouse;
            if (source < 0) unreachable; // suppress cast error
            imgui.ImGuiIO_AddMouseSourceEvent(io, @intCast(source));
            imgui.ImGuiIO_AddMousePosEvent(io, mouse_pos.x, mouse_pos.y);
            return true;
        },
        sdl.events.mouse_wheel => {
            if (getViewportForWindowID(event.motion.windowid) == null) {
                return false;
            }

            const wheel_x = event.wheel.x;
            const wheel_y = event.wheel.y;
            const source = if (event.motion.which == sdl.c.SDL_TOUCH_MOUSEID) imgui.ImGuiMouseSource_TouchScreen else imgui.ImGuiMouseSource_Mouse;
            if (source < 0) unreachable; // suppress cast error
            imgui.ImGuiIO_AddMouseSourceEvent(io, @intCast(source));
            imgui.ImGuiIO_AddMouseWheelEvent(io, wheel_x, wheel_y);
            return true;
        },
        sdl.events.mouse_button_down, sdl.events.mouse_button_up => {
            if (getViewportForWindowID(event.motion.windowid) == null) {
                return false;
            }

            var mouse_button: i32 = -1;
            if (event.button.button == sdl.mouse.button_left) { mouse_button = 0; }
            if (event.button.button == sdl.mouse.button_right) { mouse_button = 1; }
            if (event.button.button == sdl.mouse.button_middle) { mouse_button = 2; }
            if (event.button.button == sdl.mouse.button_x1) { mouse_button = 3; }
            if (event.button.button == sdl.mouse.button_x2) { mouse_button = 4; }
            if (mouse_button == -1) {
                return false;
            }

            const source = if (event.motion.which == sdl.c.SDL_TOUCH_MOUSEID) imgui.ImGuiMouseSource_TouchScreen else imgui.ImGuiMouseSource_Mouse;
            if (source < 0) unreachable; // suppress error
            imgui.ImGuiIO_AddMouseSourceEvent(io, @intCast(source));
            imgui.ImGuiIO_AddMouseButtonEvent(io, mouse_button, (event.type == sdl.events.mouse_button_down));
            const mask = @as(i32, 1) << @intCast(mouse_button);
            bd.mouse_buttons_down = if (event.type == sdl.events.mouse_button_down) bd.mouse_buttons_down | mask else bd.mouse_buttons_down & ~mask;
            return true;
        },
        sdl.events.text_input => {
            if (getViewportForWindowID(event.text.windowid) == null) {
                return false;
            }
            imgui.ImGuiIO_AddInputCharactersUTF8(io, event.text.text);
            return true;
        },
        sdl.events.key_down,
        sdl.events.key_up => {
            if (getViewportForWindowID(event.key.windowid) == null) {
                return false;
            }
            updateKeyModifiers(event.key.mod);
            const key = keyEventToImGuiKey(event.key.key, event.key.scancode);
            imgui.ImGuiIO_AddKeyEvent(io, key, event.type == sdl.events.key_down);
        },
        sdl.events.display_orientation,
        sdl.events.display_added,
        sdl.events.display_removed,
        sdl.events.display_moved,
        sdl.events.display_content_scale_changed => {
            bd.want_update_monitors = true;
            return true;
        },
        sdl.events.window_mouse_enter => {
            if (getViewportForWindowID(event.window.windowid) == null) {
                return false;
            }
            bd.mouse_window_id = event.window.windowid;
            bd.mouse_pending_leave_frame = 0;
            return true;
        },
        sdl.events.window_mouse_leave => {
            if (getViewportForWindowID(event.window.windowid) == null) {
                return false;
            }
            bd.mouse_pending_leave_frame = imgui.igGetFrameCount() + 1;
            return true;
        },
        sdl.events.window_focus_gained,
        sdl.events.window_focus_lost => {
            if (getViewportForWindowID(event.window.windowid) == null) {
                return false;
            }
            imgui.ImGuiIO_AddFocusEvent(io, event.type == sdl.events.window_focus_gained);
            return true;
        },
        sdl.events.window_close_requested,
        sdl.events.window_moved,
        sdl.events.window_resized => {
            const viewport = getViewportForWindowID(event.window.windowid) orelse return false;
            if (event.type == sdl.events.window_close_requested) {
                viewport.PlatformRequestClose = true;
            }
            if (event.type == sdl.events.window_moved) {
                viewport.PlatformRequestMove = true;
            }
            if (event.type == sdl.events.window_resized) {
                viewport.PlatformRequestResize = true;
            }
            return true;
        },
        sdl.events.gamepad_added,
        sdl.events.gamepad_removed => {
            bd.want_update_gamepads_list = true;
            return true;
        },
        else => {},
    }
    return false;
}

pub fn newFrame() !void {
    const bd = getBackendData() orelse return error.NotInitialized;
    const io = imgui.getIO();

    var w: i32 = undefined;
    var h: i32 = undefined;
    var display_w: i32 = undefined;
    var display_h: i32 = undefined;
    _ = sdl.video.getWindowSize(bd.window, &w, &h);
    if (sdl.video.getWindowFlags(bd.window).minimized) {
        w = 0;
        h = 0;
    }
    _ = sdl.video.getWindowSizeInPixels(bd.window, &display_w, &display_h);
    io.DisplaySize = imgui.Vec2{ .x = @floatFromInt(w), .y = @floatFromInt(h) };
    if (w > 0 and h > 0) {
        const scale_x: f32 = @as(f32, @floatFromInt(display_w)) / @as(f32, @floatFromInt(w));
        const scale_y: f32 = @as(f32, @floatFromInt(display_h)) / @as(f32, @floatFromInt(h));
        io.DisplayFramebufferScale = .{ .x = scale_x, .y = scale_y };
    }

    if (bd.want_update_monitors) {
        updateMonitors();
    }

    const frequency: u64 = sdl.c.SDL_GetPerformanceFrequency();
    var current_time: u64 = sdl.c.SDL_GetPerformanceCounter();

    if (current_time <= bd.time) {
        current_time = bd.time + 1;
    }
    if (bd.time > 0) {
        const d_current_time: f64 = @floatFromInt(current_time - bd.time);
        const d_frequency: f64 = @floatFromInt(frequency);
        io.DeltaTime = @floatCast(d_current_time / d_frequency);
    } else {
        io.DeltaTime = @as(f32, 1) / 60;
    }

    if (bd.mouse_pending_leave_frame != 0 and bd.mouse_pending_leave_frame > imgui.igGetFrameCount() and bd.mouse_buttons_down == 0) {
        bd.mouse_window_id = 0;
        bd.mouse_pending_leave_frame = 0;
        imgui.ImGuiIO_AddMousePosEvent(io, -std.math.floatMax(f32), -std.math.floatMax(f32));
    }

    if (bd.mouse_can_report_hovered_viewport and imgui.igGetDragDropPayload() == null) {
        io.BackendFlags |= imgui.backend_flags_has_mouse_hovered_viewport;
    } else {
        io.BackendFlags &= ~imgui.backend_flags_has_mouse_hovered_viewport;
    }

    try updateMouseData();
    try updateMouseCursor();

    // updateGamepads();
}

pub fn updateMonitors() void {
    const bd = getBackendData().?;
    const io = imgui.getPlatformIO();
    io.Monitors.Size = 0;
    bd.want_update_monitors = false;

    var display_count: c_int = undefined;
    const displays = sdl.video.getDisplays(&display_count);
    defer sdl.c.SDL_free(displays);
    const len: usize = @intCast(display_count);

    // resize array
    if (io.Monitors.Capacity < display_count) {
        const new_data: [*]imgui.ImGuiPlatformMonitor = @alignCast(@ptrCast(imgui.memAlloc(len * @sizeOf(imgui.ImGuiPlatformMonitor))));
        if (io.Monitors.Data != null) {
            @memcpy(new_data, io.Monitors.Data[0..len]);
            imgui.memFree(io.Monitors.Data);
        }
        io.Monitors.Data = new_data;
        io.Monitors.Capacity = display_count;
    }

    for(displays[0..len], 0..len) |display, i| {
        var rect: sdl.rect.Rect = undefined;
        _ = sdl.video.getDisplayBounds(display, &rect);
        var x: f32 = @floatFromInt(rect.x);
        var y: f32 = @floatFromInt(rect.y);
        var w: f32 = @floatFromInt(rect.w);
        var h: f32 = @floatFromInt(rect.h);

        var monitor = imgui.ImGuiPlatformMonitor {
            .MainPos = .{ .x = x, .y = y },
            .MainSize = .{ .x = w, .y = h },
            .WorkPos = .{ .x = x, .y = y },
            .WorkSize = .{ .x = w, .y = h },
        };

        _ = sdl.video.getDisplayUsableBounds(display, &rect);
        x = @floatFromInt(rect.x);
        y = @floatFromInt(rect.y);
        w = @floatFromInt(rect.w);
        h = @floatFromInt(rect.h);
        monitor.WorkPos = .{ .x = x, .y = y };
        monitor.WorkSize = .{ .x = w, .y = h };

        monitor.DpiScale = sdl.video.getDisplayContentScale(display);
        monitor.PlatformHandle = @ptrFromInt(i);
        if (monitor.DpiScale <= 0) {
            continue;
        }
        io.Monitors.Data[i] = monitor;
    }
}

pub fn updateMouseData() !void {
    const bd = getBackendData() orelse return error.NotInitialized;
    const io = imgui.getIO();

    _ = sdl.mouse.captureMouse(if (bd.mouse_buttons_down != 0) true else false);
    const window: ?*sdl.video.Window = @ptrCast(sdl.c.SDL_GetKeyboardFocus());
    const is_app_focused = window != null and (window == bd.window or getViewportForWindowID(sdl.video.getWindowID(window.?)) != null);
    if (is_app_focused) {
        if (io.WantSetMousePos) {
            if (io.ConfigFlags & imgui.ImGuiConfigFlags_ViewportsEnable != 0) {
                _ = sdl.mouse.warpMouseGlobal(io.MousePos.x, io.MousePos.y);
            } else {
                _ = sdl.mouse.warpMouseInWindow(bd.window, io.MousePos.x, io.MousePos.y);
            }
        }
    }
}

pub fn updateMouseCursor() !void {
    const io = imgui.getIO();
    if (io.ConfigFlags & imgui.ImGuiConfigFlags_NoMouseCursorChange != 0) {
        return;
    }

    const bd = getBackendData() orelse return error.NotInitialized;
    const imgui_cursor: usize = @intCast(imgui.igGetMouseCursor());
    if (io.MouseDrawCursor or imgui_cursor == imgui.mouse_cursor_none) {
        _ = sdl.mouse.hideCursor();
    } else {
        const expected_cursor = bd.mouse_cursors[imgui_cursor];
        if (bd.mouse_last_cursor != expected_cursor) {
            _ = sdl.mouse.setCursor(expected_cursor);
            bd.mouse_last_cursor = expected_cursor;
        }
        _ = sdl.mouse.showCursor();
    }
}

pub fn updateGamepads() void {
    unreachable;
}

pub fn updateKeyModifiers(sdl_key_mods: sdl.keycode.Keymod) void {
    const io = imgui.getIO();
    imgui.ImGuiIO_AddKeyEvent(io, imgui.ImGuiMod_Ctrl, (sdl_key_mods & sdl.keycode.mod_ctrl) != 0);
    imgui.ImGuiIO_AddKeyEvent(io, imgui.ImGuiMod_Shift, (sdl_key_mods & sdl.keycode.mod_shift) != 0);
    imgui.ImGuiIO_AddKeyEvent(io, imgui.ImGuiMod_Alt, (sdl_key_mods & sdl.keycode.mod_alt) != 0);
    imgui.ImGuiIO_AddKeyEvent(io, imgui.ImGuiMod_Super, (sdl_key_mods & sdl.keycode.mod_gui) != 0);
}

pub inline fn keyEventToImGuiKey(keycode: sdl.keycode.Keycode, scancode: sdl.scancode.Scancode) imgui.ImGuiKey {
    const code: ?imgui.ImGuiKey = switch(scancode) {
        sdl.scancode.kp_0 => imgui.ImGuiKey_Keypad0,
        sdl.scancode.kp_1 => imgui.ImGuiKey_Keypad1,
        sdl.scancode.kp_2 => imgui.ImGuiKey_Keypad2,
        sdl.scancode.kp_3 => imgui.ImGuiKey_Keypad3,
        sdl.scancode.kp_4 => imgui.ImGuiKey_Keypad4,
        sdl.scancode.kp_5 => imgui.ImGuiKey_Keypad5,
        sdl.scancode.kp_6 => imgui.ImGuiKey_Keypad6,
        sdl.scancode.kp_7 => imgui.ImGuiKey_Keypad7,
        sdl.scancode.kp_8 => imgui.ImGuiKey_Keypad8,
        sdl.scancode.kp_9 => imgui.ImGuiKey_Keypad9,
        sdl.scancode.kp_period => imgui.ImGuiKey_KeypadDecimal,
        sdl.scancode.kp_divide => imgui.ImGuiKey_KeypadDivide,
        sdl.scancode.kp_multiply => imgui.ImGuiKey_KeypadMultiply,
        sdl.scancode.kp_minus => imgui.ImGuiKey_KeypadSubtract,
        sdl.scancode.kp_plus => imgui.ImGuiKey_KeypadAdd,
        sdl.scancode.kp_enter  => imgui.ImGuiKey_KeypadEnter,
        sdl.scancode.kp_equals  => imgui.ImGuiKey_KeypadEqual,
        else => null,
    };
    return code orelse switch (keycode) {
        sdl.keycode.tab => imgui.ImGuiKey_Tab,
        sdl.keycode.left => imgui.ImGuiKey_LeftArrow,
        sdl.keycode.right => imgui.ImGuiKey_RightArrow,
        sdl.keycode.up => imgui.ImGuiKey_UpArrow,
        sdl.keycode.down => imgui.ImGuiKey_DownArrow,
        sdl.keycode.pageup => imgui.ImGuiKey_PageUp,
        sdl.keycode.pagedown => imgui.ImGuiKey_PageDown,
        sdl.keycode.home => imgui.ImGuiKey_Home,
        sdl.keycode.end => imgui.ImGuiKey_End,
        sdl.keycode.insert => imgui.ImGuiKey_Insert,
        sdl.keycode.delete => imgui.ImGuiKey_Delete,
        sdl.keycode.backspace => imgui.ImGuiKey_Backspace,
        sdl.keycode.space => imgui.ImGuiKey_Space,
        sdl.keycode.@"return" => imgui.ImGuiKey_Enter,
        sdl.keycode.escape => imgui.ImGuiKey_Escape,
        sdl.keycode.apostrophe => imgui.ImGuiKey_Apostrophe,
        sdl.keycode.comma => imgui.ImGuiKey_Comma,
        sdl.keycode.minus => imgui.ImGuiKey_Minus,
        sdl.keycode.period => imgui.ImGuiKey_Period,
        sdl.keycode.slash => imgui.ImGuiKey_Slash,
        sdl.keycode.semicolon => imgui.ImGuiKey_Semicolon,
        sdl.keycode.equals => imgui.ImGuiKey_Equal,
        sdl.keycode.leftbracket => imgui.ImGuiKey_LeftBracket,
        sdl.keycode.backslash => imgui.ImGuiKey_Backslash,
        sdl.keycode.rightbracket => imgui.ImGuiKey_RightBracket,
        sdl.keycode.grave => imgui.ImGuiKey_GraveAccent,
        sdl.keycode.capslock => imgui.ImGuiKey_CapsLock,
        sdl.keycode.scrolllock => imgui.ImGuiKey_ScrollLock,
        sdl.keycode.numlockclear => imgui.ImGuiKey_NumLock,
        sdl.keycode.printscreen => imgui.ImGuiKey_PrintScreen,
        sdl.keycode.pause => imgui.ImGuiKey_Pause,
        sdl.keycode.lctrl => imgui.ImGuiKey_LeftCtrl,
        sdl.keycode.lshift => imgui.ImGuiKey_LeftShift,
        sdl.keycode.lalt => imgui.ImGuiKey_LeftAlt,
        sdl.keycode.lgui => imgui.ImGuiKey_LeftSuper,
        sdl.keycode.rctrl => imgui.ImGuiKey_RightCtrl,
        sdl.keycode.rshift => imgui.ImGuiKey_RightShift,
        sdl.keycode.ralt => imgui.ImGuiKey_RightAlt,
        sdl.keycode.rgui => imgui.ImGuiKey_RightSuper,
        sdl.keycode.application => imgui.ImGuiKey_Menu,
        sdl.keycode.@"0" => imgui.ImGuiKey_0,
        sdl.keycode.@"1" => imgui.ImGuiKey_1,
        sdl.keycode.@"2" => imgui.ImGuiKey_2,
        sdl.keycode.@"3" => imgui.ImGuiKey_3,
        sdl.keycode.@"4" => imgui.ImGuiKey_4,
        sdl.keycode.@"5" => imgui.ImGuiKey_5,
        sdl.keycode.@"6" => imgui.ImGuiKey_6,
        sdl.keycode.@"7" => imgui.ImGuiKey_7,
        sdl.keycode.@"8" => imgui.ImGuiKey_8,
        sdl.keycode.@"9" => imgui.ImGuiKey_9,
        sdl.keycode.a => imgui.ImGuiKey_A,
        sdl.keycode.b => imgui.ImGuiKey_B,
        sdl.keycode.c => imgui.ImGuiKey_C,
        sdl.keycode.d => imgui.ImGuiKey_D,
        sdl.keycode.e => imgui.ImGuiKey_E,
        sdl.keycode.f => imgui.ImGuiKey_F,
        sdl.keycode.g => imgui.ImGuiKey_G,
        sdl.keycode.h => imgui.ImGuiKey_H,
        sdl.keycode.i => imgui.ImGuiKey_I,
        sdl.keycode.j => imgui.ImGuiKey_J,
        sdl.keycode.k => imgui.ImGuiKey_K,
        sdl.keycode.l => imgui.ImGuiKey_L,
        sdl.keycode.m => imgui.ImGuiKey_M,
        sdl.keycode.n => imgui.ImGuiKey_N,
        sdl.keycode.o => imgui.ImGuiKey_O,
        sdl.keycode.p => imgui.ImGuiKey_P,
        sdl.keycode.q => imgui.ImGuiKey_Q,
        sdl.keycode.r => imgui.ImGuiKey_R,
        sdl.keycode.s => imgui.ImGuiKey_S,
        sdl.keycode.t => imgui.ImGuiKey_T,
        sdl.keycode.u => imgui.ImGuiKey_U,
        sdl.keycode.v => imgui.ImGuiKey_V,
        sdl.keycode.w => imgui.ImGuiKey_W,
        sdl.keycode.x => imgui.ImGuiKey_X,
        sdl.keycode.y => imgui.ImGuiKey_Y,
        sdl.keycode.z => imgui.ImGuiKey_Z,
        sdl.keycode.f1 => imgui.ImGuiKey_F1,
        sdl.keycode.f2 => imgui.ImGuiKey_F2,
        sdl.keycode.f3 => imgui.ImGuiKey_F3,
        sdl.keycode.f4 => imgui.ImGuiKey_F4,
        sdl.keycode.f5 => imgui.ImGuiKey_F5,
        sdl.keycode.f6 => imgui.ImGuiKey_F6,
        sdl.keycode.f7 => imgui.ImGuiKey_F7,
        sdl.keycode.f8 => imgui.ImGuiKey_F8,
        sdl.keycode.f9 => imgui.ImGuiKey_F9,
        sdl.keycode.f10 => imgui.ImGuiKey_F10,
        sdl.keycode.f11 => imgui.ImGuiKey_F11,
        sdl.keycode.f12 => imgui.ImGuiKey_F12,
        sdl.keycode.f13 => imgui.ImGuiKey_F13,
        sdl.keycode.f14 => imgui.ImGuiKey_F14,
        sdl.keycode.f15 => imgui.ImGuiKey_F15,
        sdl.keycode.f16 => imgui.ImGuiKey_F16,
        sdl.keycode.f17 => imgui.ImGuiKey_F17,
        sdl.keycode.f18 => imgui.ImGuiKey_F18,
        sdl.keycode.f19 => imgui.ImGuiKey_F19,
        sdl.keycode.f20 => imgui.ImGuiKey_F20,
        sdl.keycode.f21 => imgui.ImGuiKey_F21,
        sdl.keycode.f22 => imgui.ImGuiKey_F22,
        sdl.keycode.f23 => imgui.ImGuiKey_F23,
        sdl.keycode.f24 => imgui.ImGuiKey_F24,
        sdl.keycode.ac_back => imgui.ImGuiKey_AppBack,
        sdl.keycode.ac_forward => imgui.ImGuiKey_AppForward,
        else => imgui.ImGuiKey_None,
    };
}

pub fn getViewportForWindowID(windowid: sdl.video.WindowID) ?*imgui.Viewport {
    return imgui.igFindViewportByPlatformHandle(@ptrFromInt(windowid));
}
