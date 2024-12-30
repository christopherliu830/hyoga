const std = @import("std");
const builtin = @import("builtin");
const imgui = @import("imgui");
const sdl = @import("sdl");

const Window = @import("../../window.zig");

pub const GamepadMode = enum(c_int) { auto_first, auto_all, manual };

pub const ImplData = struct {
    allocator: std.mem.Allocator,
    window: ?*sdl.Window = null,
    window_id: sdl.video.WindowID = 0,
    time: u64 = 0,
    clipboard_text_data: []const u8 = undefined,
    use_vulkan: bool = false,
    want_update_monitors: bool = false,
    ime_window: ?*sdl.video.Window,
    mouse_window_id: u32 = 0,
    mouse_buttons_down: i32 = 0,
    mouse_cursors: [@intFromEnum(imgui.MouseCursor.count)]?*sdl.mouse.Cursor = undefined,
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

pub fn init(window: *Window, allocator: std.mem.Allocator) !void {
    const io = imgui.GetIO().?;
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
        .ime_window = null,
    };

    io.BackendPlatformUserData = bd;
    io.BackendPlatformName = "imgui_impl_sdl3";
    io.BackendFlags |= imgui.BackendFlag.has_mouse_cursors;
    io.BackendFlags |= imgui.BackendFlag.has_set_mouse_pos;
    if (mouse_can_use_global_state) {
        io.BackendFlags |= imgui.BackendFlag.platform_has_viewports;
    }
    bd.window = window.hdl;
    bd.window_id = sdl.video.getWindowID(window.hdl);
    bd.mouse_can_use_global_state = mouse_can_use_global_state;
    bd.mouse_can_report_hovered_viewport = if (builtin.os.tag != .macos) mouse_can_use_global_state else false;
    bd.want_update_monitors = true;

    const platform_io = imgui.GetPlatformIO().?;
    platform_io.Platform_SetClipboardTextFn = undefined;
    platform_io.Platform_SetClipboardTextFn = undefined;
    platform_io.Platform_SetImeDataFn = platformSetImeData;

    bd.gamepad_mode = .auto_first;
    bd.want_update_gamepads_list = true;

    bd.mouse_cursors[@intFromEnum(imgui.MouseCursor.arrow)] = sdl.mouse.createSystemCursor(.default);
    bd.mouse_cursors[@intFromEnum(imgui.MouseCursor.text_input)] = sdl.mouse.createSystemCursor(.text);
    bd.mouse_cursors[@intFromEnum(imgui.MouseCursor.resize_all)] = sdl.mouse.createSystemCursor(.move);
    bd.mouse_cursors[@intFromEnum(imgui.MouseCursor.resize_ns)] = sdl.mouse.createSystemCursor(.ns_resize);
    bd.mouse_cursors[@intFromEnum(imgui.MouseCursor.resize_ew)] = sdl.mouse.createSystemCursor(.ew_resize);
    bd.mouse_cursors[@intFromEnum(imgui.MouseCursor.resize_nesw)] = sdl.mouse.createSystemCursor(.nesw_resize);
    bd.mouse_cursors[@intFromEnum(imgui.MouseCursor.resize_nwse)] = sdl.mouse.createSystemCursor(.nwse_resize);
    bd.mouse_cursors[@intFromEnum(imgui.MouseCursor.not_allowed)] = sdl.mouse.createSystemCursor(.not_allowed);

    const main_viewport = imgui.GetMainViewport().?;
    setupPlatformHandles(main_viewport, window.hdl);

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
    const io = imgui.GetIO().?;

    //TODO: free clipboard

    imgui.DestroyPlatformWindows();
    for(bd.mouse_cursors) |cursor| {
        sdl.mouse.destroyCursor(cursor);
    }
    //TODO: reset gamepad

    io.BackendPlatformName = null;
    io.BackendPlatformUserData = null;
    io.BackendFlags &= ~(@as(c_int, imgui.BackendFlag.has_mouse_cursors) | 
                         @as(c_int, imgui.BackendFlag.has_set_mouse_pos) | 
                         @as(c_int, imgui.BackendFlag.platform_has_viewports));

    bd.allocator.destroy(bd);
}

fn getBackendData() ?*ImplData {
    if (imgui.GetCurrentContext() != null) {
        return @ptrCast(@alignCast(imgui.GetIO().?.BackendPlatformUserData));
    } else return null;
}

fn platformSetImeData(_: *imgui.Context, viewport: ?*imgui.Viewport, data: ?*imgui.PlatformImeData) callconv(.C) void {
    const bd = getBackendData().?;
    const window_id = @intFromPtr(viewport.?.PlatformHandle);
    const window = sdl.video.getWindowFromID(@intCast(window_id));
    if ((data.?.WantVisible == false or bd.ime_window != window) and bd.ime_window != null) {
        _ = sdl.keyboard.stopTextInput(bd.ime_window);
    }
    if (data.?.WantVisible) {
        const r = sdl.rect.Rect {
            .x = @intFromFloat(data.?.InputPos.x - viewport.?.Pos.x),
            .y = @intFromFloat(data.?.InputPos.y - viewport.?.Pos.y),
            .w = 1,
            .h = @intFromFloat(data.?.InputLineHeight),
        };
        _ = sdl.keyboard.setTextInputArea(window, &r, 0);
        _ = sdl.keyboard.startTextInput(window);
        bd.ime_window = window;
    }
}

fn setupPlatformHandles(viewport: *imgui.Viewport, window: *sdl.video.Window) void {
    viewport.PlatformHandle = @ptrFromInt(sdl.video.getWindowID(window));
    if (builtin.os.tag == .windows) {
        viewport.PlatformHandleRaw = sdl.c.SDL_GetPointerProperty(sdl.video.getWindowProperties(window), sdl.c.SDL_PROP_WINDOW_WIN32_HWND_POINTER, null);
    } if (builtin.os.tag == .macos) {
        viewport.PlatformHandleRaw = sdl.c.SDL_GetPointerProperty(sdl.video.getWindowProperties(window), sdl.c.SDL_PROP_WINDOW_COCOA_WINDOW_POINTER, null);
    }
}    

pub fn processEvent(event: *const sdl.events.Event) !bool {
    const bd = getBackendData() orelse return error.NotInitialized;
    const io = imgui.GetIO().?;

    switch (event.type) {
        sdl.events.type.mouse_motion => {
            if (getViewportForWindowID(event.motion.windowID) == null) {
                return false;
            }

            var mouse_pos = imgui.Vec2 { .x = event.motion.x, .y = event.motion.y };
            if (io.ConfigFlags & imgui.ConfigFlag.viewports_enable != 0) {
                var window_x: c_int = undefined;
                var window_y: c_int = undefined;
                _ = sdl.video.getWindowPosition(sdl.video.getWindowFromID(event.motion.windowID), &window_x, &window_y);
                mouse_pos.x += @floatFromInt(window_x);
                mouse_pos.y += @floatFromInt(window_y);
            }
            const source = if (event.motion.which == sdl.c.SDL_TOUCH_MOUSEID) imgui.MouseSource.touch_screen else imgui.MouseSource.mouse;
            // if (source < 0) unreachable; // suppress cast error
            io.AddMouseSourceEvent(source);
            io.AddMousePosEvent(mouse_pos.x, mouse_pos.y);
            return true;
        },
        sdl.events.type.mouse_wheel => {
            if (getViewportForWindowID(event.motion.windowID) == null) {
                return false;
            }

            const wheel_x = event.wheel.x;
            const wheel_y = event.wheel.y;
            const source = if (event.motion.which == sdl.c.SDL_TOUCH_MOUSEID) imgui.MouseSource.touch_screen else imgui.MouseSource.mouse;
            io.AddMouseSourceEvent(source);
            io.AddMouseWheelEvent(wheel_x, wheel_y);
            return true;
        },
        sdl.events.type.mouse_button_down, sdl.events.type.mouse_button_up => {
            if (getViewportForWindowID(event.motion.windowID) == null) {
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

            const source = if (event.motion.which == sdl.c.SDL_TOUCH_MOUSEID) imgui.MouseSource.touch_screen else imgui.MouseSource.mouse;
            io.AddMouseSourceEvent(source);
            io.AddMouseButtonEvent(mouse_button, (event.type == sdl.events.type.mouse_button_down));
            const mask = @as(i32, 1) << @intCast(mouse_button);
            bd.mouse_buttons_down = if (event.type == sdl.events.type.mouse_button_down) bd.mouse_buttons_down | mask else bd.mouse_buttons_down & ~mask;
            return true;
        },
        sdl.events.type.text_input => {
            if (getViewportForWindowID(event.text.windowID) == null) {
                return false;
            }
            imgui.ImGuiIO_AddInputCharactersUTF8(io, event.text.text);
            return true;
        },
        sdl.events.type.key_down,
        sdl.events.type.key_up => {
            if (getViewportForWindowID(event.key.windowID) == null) {
                return false;
            }
            updateKeyModifiers(event.key.mod);
            const key = keyEventToImGuiKey(event.key.key, event.key.scancode);
            imgui.ImGuiIO_AddKeyEvent(io, key, event.type == sdl.events.type.key_down);
        },
        sdl.events.type.display_orientation,
        sdl.events.type.display_added,
        sdl.events.type.display_removed,
        sdl.events.type.display_moved,
        sdl.events.type.display_content_scale_changed => {
            bd.want_update_monitors = true;
            return true;
        },
        sdl.events.type.window_mouse_enter => {
            if (getViewportForWindowID(event.window.windowID) == null) {
                return false;
            }
            bd.mouse_window_id = event.window.windowID;
            bd.mouse_pending_leave_frame = 0;
            return true;
        },
        sdl.events.type.window_mouse_leave => {
            if (getViewportForWindowID(event.window.windowID) == null) {
                return false;
            }
            bd.mouse_pending_leave_frame = imgui.GetFrameCount() + 1;
            return true;
        },
        sdl.events.type.window_focus_gained,
        sdl.events.type.window_focus_lost => {
            if (getViewportForWindowID(event.window.windowID) == null) {
                return false;
            }
            imgui.ImGuiIO_AddFocusEvent(io, event.type == sdl.events.type.window_focus_gained);
            return true;
        },
        sdl.events.type.window_close_requested,
        sdl.events.type.window_moved,
        sdl.events.type.window_resized => {
            const viewport = getViewportForWindowID(event.window.windowID) orelse return false;
            if (event.type == sdl.events.type.window_close_requested) {
                viewport.PlatformRequestClose = true;
            }
            if (event.type == sdl.events.type.window_moved) {
                viewport.PlatformRequestMove = true;
            }
            if (event.type == sdl.events.type.window_resized) {
                viewport.PlatformRequestResize = true;
            }
            return true;
        },
        sdl.events.type.gamepad_added,
        sdl.events.type.gamepad_removed => {
            bd.want_update_gamepads_list = true;
            return true;
        },
        else => {},
    }
    return false;
}

pub fn newFrame() !void {
    const bd = getBackendData() orelse return error.NotInitialized;
    const io = imgui.GetIO().?;

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

    if (bd.mouse_pending_leave_frame != 0 and bd.mouse_pending_leave_frame > imgui.GetFrameCount() and bd.mouse_buttons_down == 0) {
        bd.mouse_window_id = 0;
        bd.mouse_pending_leave_frame = 0;

        io.AddMousePosEvent(-std.math.floatMax(f32), -std.math.floatMax(f32));
    }

    if (bd.mouse_can_report_hovered_viewport and imgui.GetDragDropPayload() == null) {
        io.BackendFlags |= imgui.BackendFlag.has_mouse_hovered_viewport;
    } else {
        io.BackendFlags &= ~@as(c_int, imgui.BackendFlag.has_mouse_hovered_viewport);
    }

    try updateMouseData();
    try updateMouseCursor();

    // updateGamepads();
}

fn updateMonitors() void {
    const bd = getBackendData().?;
    const io = imgui.GetPlatformIO().?;
    io.Monitors.Size = 0;
    bd.want_update_monitors = false;

    var display_count: c_int = undefined;
    const displays = sdl.video.getDisplays(&display_count);
    defer sdl.c.SDL_free(displays);
    const len: usize = @intCast(display_count);

    // resize array
    if (io.Monitors.Capacity < display_count) {
        const new_data: [*]imgui.PlatformMonitor = @alignCast(@ptrCast(imgui.MemAlloc(len * @sizeOf(imgui.PlatformMonitor))));
        if (io.Monitors.Data != null) {
            @memcpy(new_data, io.Monitors.Data[0..len]);
            imgui.MemFree(io.Monitors.Data);
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

        var monitor = imgui.PlatformMonitor {
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

fn updateMouseData() !void {
    const bd = getBackendData() orelse return error.NotInitialized;
    const io = imgui.GetIO().?;

    _ = sdl.mouse.captureMouse(if (bd.mouse_buttons_down != 0) true else false);
    const window: ?*sdl.video.Window = @ptrCast(sdl.c.SDL_GetKeyboardFocus());
    const is_app_focused = window != null and (window == bd.window or getViewportForWindowID(sdl.video.getWindowID(window.?)) != null);
    if (is_app_focused) {
        if (io.WantSetMousePos) {
            if (io.ConfigFlags & imgui.ConfigFlag.viewports_enable != 0) {
                _ = sdl.mouse.warpMouseGlobal(io.MousePos.x, io.MousePos.y);
            } else {
                _ = sdl.mouse.warpMouseInWindow(bd.window, io.MousePos.x, io.MousePos.y);
            }
        }
    }
}

fn updateMouseCursor() !void {
    const io = imgui.GetIO().?;
    if (io.ConfigFlags & imgui.ConfigFlag.no_mouse_cursor_change != 0) {
        return;
    }

    const bd = getBackendData() orelse return error.NotInitialized;
    const imgui_cursor = imgui.GetMouseCursor();
    const cursor_val: usize = @intCast(@intFromEnum(imgui_cursor));
    if (io.MouseDrawCursor or imgui_cursor == .none) {
        _ = sdl.mouse.hideCursor();
    } else {
        const expected_cursor = bd.mouse_cursors[cursor_val];
        if (bd.mouse_last_cursor != expected_cursor) {
            _ = sdl.mouse.setCursor(expected_cursor);
            bd.mouse_last_cursor = expected_cursor;
        }
        _ = sdl.mouse.showCursor();
    }
}

fn updateGamepads() void {
    unreachable;
}

fn updateKeyModifiers(sdl_key_mods: sdl.keycode.Keymod) void {
    const io = imgui.GetIO().?;
    imgui.ImGuiIO_AddKeyEvent(io, .mod_ctrl, (sdl_key_mods & sdl.keycode.mod_ctrl) != 0);
    imgui.ImGuiIO_AddKeyEvent(io, .mod_shift, (sdl_key_mods & sdl.keycode.mod_shift) != 0);
    imgui.ImGuiIO_AddKeyEvent(io, .mod_alt, (sdl_key_mods & sdl.keycode.mod_alt) != 0);
    imgui.ImGuiIO_AddKeyEvent(io, .mod_super, (sdl_key_mods & sdl.keycode.mod_gui) != 0);
}

inline fn keyEventToImGuiKey(keycode: sdl.keycode.Keycode, scancode: sdl.scancode.Scancode) imgui.Key {
    const code: ?imgui.Key = switch(scancode) {
        sdl.scancode.kp_0 => .keypad0,
        sdl.scancode.kp_1 => .keypad1,
        sdl.scancode.kp_2 => .keypad2,
        sdl.scancode.kp_3 => .keypad3,
        sdl.scancode.kp_4 => .keypad4,
        sdl.scancode.kp_5 => .keypad5,
        sdl.scancode.kp_6 => .keypad6,
        sdl.scancode.kp_7 => .keypad7,
        sdl.scancode.kp_8 => .keypad8,
        sdl.scancode.kp_9 => .keypad9,
        sdl.scancode.kp_period => .keypad_decimal,
        sdl.scancode.kp_divide => .keypad_divide,
        sdl.scancode.kp_multiply => .keypad_multiply,
        sdl.scancode.kp_minus => .keypad_subtract,
        sdl.scancode.kp_plus => .keypad_add,
        sdl.scancode.kp_enter  => .keypad_enter,
        sdl.scancode.kp_equals  => .keypad_equal,
        else => null,
    };
    return code orelse switch (keycode) {
        sdl.keycode.tab => .tab,
        sdl.keycode.left => .left_arrow,
        sdl.keycode.right => .right_arrow,
        sdl.keycode.up => .up_arrow,
        sdl.keycode.down => .down_arrow,
        sdl.keycode.pageup => .page_up,
        sdl.keycode.pagedown => .page_down,
        sdl.keycode.home => .home,
        sdl.keycode.end => .end,
        sdl.keycode.insert => .insert,
        sdl.keycode.delete => .delete,
        sdl.keycode.backspace => .backspace,
        sdl.keycode.space => .space,
        sdl.keycode.@"return" => .enter,
        sdl.keycode.escape => .escape,
        sdl.keycode.apostrophe => .apostrophe,
        sdl.keycode.comma => .comma,
        sdl.keycode.minus => .minus,
        sdl.keycode.period => .period,
        sdl.keycode.slash => .slash,
        sdl.keycode.semicolon => .semicolon,
        sdl.keycode.equals => .equal,
        sdl.keycode.leftbracket => .left_bracket,
        sdl.keycode.backslash => .backslash,
        sdl.keycode.rightbracket => .right_bracket,
        sdl.keycode.grave => .grave_accent,
        sdl.keycode.capslock => .caps_lock,
        sdl.keycode.scrolllock => .scroll_lock,
        sdl.keycode.numlockclear => .num_lock,
        sdl.keycode.printscreen => .print_screen,
        sdl.keycode.pause => .pause,
        sdl.keycode.lctrl => .left_ctrl,
        sdl.keycode.lshift => .left_shift,
        sdl.keycode.lalt => .left_alt,
        sdl.keycode.lgui => .left_super,
        sdl.keycode.rctrl => .right_ctrl,
        sdl.keycode.rshift => .right_shift,
        sdl.keycode.ralt => .right_alt,
        sdl.keycode.rgui => .right_super,
        sdl.keycode.application => .menu,
        sdl.keycode.@"0" => .@"0",
        sdl.keycode.@"1" => .@"1",
        sdl.keycode.@"2" => .@"2",
        sdl.keycode.@"3" => .@"3",
        sdl.keycode.@"4" => .@"4",
        sdl.keycode.@"5" => .@"5",
        sdl.keycode.@"6" => .@"6",
        sdl.keycode.@"7" => .@"7",
        sdl.keycode.@"8" => .@"8",
        sdl.keycode.@"9" => .@"9",
        sdl.keycode.a => .a,
        sdl.keycode.b => .b,
        sdl.keycode.c => .c,
        sdl.keycode.d => .d,
        sdl.keycode.e => .e,
        sdl.keycode.f => .f,
        sdl.keycode.g => .g,
        sdl.keycode.h => .h,
        sdl.keycode.i => .i,
        sdl.keycode.j => .j,
        sdl.keycode.k => .k,
        sdl.keycode.l => .l,
        sdl.keycode.m => .m,
        sdl.keycode.n => .n,
        sdl.keycode.o => .o,
        sdl.keycode.p => .p,
        sdl.keycode.q => .q,
        sdl.keycode.r => .r,
        sdl.keycode.s => .s,
        sdl.keycode.t => .t,
        sdl.keycode.u => .u,
        sdl.keycode.v => .v,
        sdl.keycode.w => .w,
        sdl.keycode.x => .x,
        sdl.keycode.y => .y,
        sdl.keycode.z => .z,
        sdl.keycode.f1 => .f1,
        sdl.keycode.f2 => .f2,
        sdl.keycode.f3 => .f3,
        sdl.keycode.f4 => .f4,
        sdl.keycode.f5 => .f5,
        sdl.keycode.f6 => .f6,
        sdl.keycode.f7 => .f7,
        sdl.keycode.f8 => .f8,
        sdl.keycode.f9 => .f9,
        sdl.keycode.f10 => .f10,
        sdl.keycode.f11 => .f11,
        sdl.keycode.f12 => .f12,
        sdl.keycode.f13 => .f13,
        sdl.keycode.f14 => .f14,
        sdl.keycode.f15 => .f15,
        sdl.keycode.f16 => .f16,
        sdl.keycode.f17 => .f17,
        sdl.keycode.f18 => .f18,
        sdl.keycode.f19 => .f19,
        sdl.keycode.f20 => .f20,
        sdl.keycode.f21 => .f21,
        sdl.keycode.f22 => .f22,
        sdl.keycode.f23 => .f23,
        sdl.keycode.f24 => .f24,
        sdl.keycode.ac_back => .app_back,
        sdl.keycode.ac_forward => .app_forward,
        else => .none,
    };
}

fn getViewportForWindowID(windowid: sdl.video.WindowID) ?*imgui.Viewport {
    return imgui.FindViewportByPlatformHandle(@ptrFromInt(windowid));
}
