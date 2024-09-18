const c = @import("c.zig");
const keyboard = @import("keyboard.zig");
const video = @import("video.zig");
const scancode = @import("Scancode.zig");
const keycode = @import("keycode.zig");

pub const Names = struct {
    pub const first = 0;
    pub const quit = 256;
    pub const terminating = 257;
    pub const low_memory = 258;
    pub const will_enter_background = 259;
    pub const did_enter_background = 260;
    pub const will_enter_foreground = 261;
    pub const did_enter_foreground = 262;
    pub const locale_changed = 263;
    pub const system_theme_changed = 264;
    pub const display_orientation = 337;
    pub const display_added = 338;
    pub const display_removed = 339;
    pub const display_moved = 340;
    pub const display_desktop_mode_changed = 341;
    pub const display_current_mode_changed = 342;
    pub const display_content_scale_changed = 343;
    pub const display_first = 337;
    pub const display_last = 343;
    pub const window_shown = 514;
    pub const window_hidden = 515;
    pub const window_exposed = 516;
    pub const window_moved = 517;
    pub const window_resized = 518;
    pub const window_pixel_size_changed = 519;
    pub const window_metal_view_resized = 520;
    pub const window_minimized = 521;
    pub const window_maximized = 522;
    pub const window_restored = 523;
    pub const window_mouse_enter = 524;
    pub const window_mouse_leave = 525;
    pub const window_focus_gained = 526;
    pub const window_focus_lost = 527;
    pub const window_close_requested = 528;
    pub const window_hit_test = 529;
    pub const window_iccprof_changed = 530;
    pub const window_display_changed = 531;
    pub const window_display_scale_changed = 532;
    pub const window_safe_area_changed = 533;
    pub const window_occluded = 534;
    pub const window_enter_fullscreen = 535;
    pub const window_leave_fullscreen = 536;
    pub const window_destroyed = 537;
    pub const window_hdr_state_changed = 538;
    pub const window_first = 514;
    pub const window_last = 538;
    pub const key_down = 768;
    pub const key_up = 769;
    pub const text_editing = 770;
    pub const text_input = 771;
    pub const keymap_changed = 772;
    pub const keyboard_added = 773;
    pub const keyboard_removed = 774;
    pub const text_editing_candidates = 775;
    pub const mouse_motion = 1024;
    pub const mouse_button_down = 1025;
    pub const mouse_button_up = 1026;
    pub const mouse_wheel = 1027;
    pub const mouse_added = 1028;
    pub const mouse_removed = 1029;
    pub const joystick_axis_motion = 1536;
    pub const joystick_ball_motion = 1537;
    pub const joystick_hat_motion = 1538;
    pub const joystick_button_down = 1539;
    pub const joystick_button_up = 1540;
    pub const joystick_added = 1541;
    pub const joystick_removed = 1542;
    pub const joystick_battery_updated = 1543;
    pub const joystick_update_complete = 1544;
    pub const gamepad_axis_motion = 1616;
    pub const gamepad_button_down = 1617;
    pub const gamepad_button_up = 1618;
    pub const gamepad_added = 1619;
    pub const gamepad_removed = 1620;
    pub const gamepad_remapped = 1621;
    pub const gamepad_touchpad_down = 1622;
    pub const gamepad_touchpad_motion = 1623;
    pub const gamepad_touchpad_up = 1624;
    pub const gamepad_sensor_update = 1625;
    pub const gamepad_update_complete = 1626;
    pub const gamepad_steam_handle_updated = 1627;
    pub const finger_down = 1792;
    pub const finger_up = 1793;
    pub const finger_motion = 1794;
    pub const clipboard_update = 2304;
    pub const drop_file = 4096;
    pub const drop_text = 4097;
    pub const drop_begin = 4098;
    pub const drop_complete = 4099;
    pub const drop_position = 4100;
    pub const audio_device_added = 4352;
    pub const audio_device_removed = 4353;
    pub const audio_device_format_changed = 4354;
    pub const sensor_update = 4608;
    pub const pen_proximity_in = 4864;
    pub const pen_proximity_out = 4865;
    pub const pen_down = 4866;
    pub const pen_up = 4867;
    pub const pen_button_down = 4868;
    pub const pen_button_up = 4869;
    pub const pen_motion = 4870;
    pub const pen_axis = 4871;
    pub const camera_device_added = 5120;
    pub const camera_device_removed = 5121;
    pub const camera_device_approved = 5122;
    pub const camera_device_denied = 5123;
    pub const render_targets_reset = 8192;
    pub const render_device_reset = 8193;
    pub const poll_sentinel = 32512;
    pub const user = 32768;
    pub const last = 65535;
    pub const enum_padding = 2147483647;
};
pub usingnamespace Names;

pub const KeyboardEvent = extern struct {
    type: c.SDL_EventType = Names.first,
    reserved: u32 = 0,
    timestamp: u64 = 0,
    windowID: video.Id = 0,
    which: keyboard.Id = 0,
    scancode: scancode.Scancode,
    key: keycode.Keycode,
    mod: keycode.Keymod,
    raw: u16,
    down: bool,
    repeat: bool,
};

pub const union_SDL_Event = extern union {
    type: u32,
    common: c.SDL_CommonEvent,
    display: c.SDL_DisplayEvent,
    window: c.SDL_WindowEvent,
    kdevice: c.SDL_KeyboardDeviceEvent,
    key: KeyboardEvent,
    edit: c.SDL_TextEditingEvent,
    edit_candidates: c.SDL_TextEditingCandidatesEvent,
    text: c.SDL_TextInputEvent,
    mdevice: c.SDL_MouseDeviceEvent,
    motion: c.SDL_MouseMotionEvent,
    button: c.SDL_MouseButtonEvent,
    wheel: c.SDL_MouseWheelEvent,
    jdevice: c.SDL_JoyDeviceEvent,
    jaxis: c.SDL_JoyAxisEvent,
    jball: c.SDL_JoyBallEvent,
    jhat: c.SDL_JoyHatEvent,
    jbutton: c.SDL_JoyButtonEvent,
    jbattery: c.SDL_JoyBatteryEvent,
    gdevice: c.SDL_GamepadDeviceEvent,
    gaxis: c.SDL_GamepadAxisEvent,
    gbutton: c.SDL_GamepadButtonEvent,
    gtouchpad: c.SDL_GamepadTouchpadEvent,
    gsensor: c.SDL_GamepadSensorEvent,
    adevice: c.SDL_AudioDeviceEvent,
    cdevice: c.SDL_CameraDeviceEvent,
    sensor: c.SDL_SensorEvent,
    quit: c.SDL_QuitEvent,
    user: c.SDL_UserEvent,
    tfinger: c.SDL_TouchFingerEvent,
    pproximity: c.SDL_PenProximityEvent,
    ptouch: c.SDL_PenTouchEvent,
    pmotion: c.SDL_PenMotionEvent,
    pbutton: c.SDL_PenButtonEvent,
    paxis: c.SDL_PenAxisEvent,
    drop: c.SDL_DropEvent,
    clipboard: c.SDL_ClipboardEvent,
    padding: [128]u8,
};
pub const Event = union_SDL_Event;

extern fn SDL_PollEvent(event: *Event) bool;
pub const poll = SDL_PollEvent;