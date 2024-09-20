const AudioDeviceID = @import("audio.zig").DeviceID;
const CameraID = @import("camera.zig").CameraID;
const DisplayID = @import("video.zig").DisplayID;
const FingerID = @import("touch.zig").FingerID;
const JoystickID = @import("joystick.zig").JoystickID;
const KeyboardID = @import("keyboard.zig").ID;
const Keycode = @import("keycode.zig").Keycode;
const Keymod = @import("keycode.zig").Keymod;
const MouseButtonFlags = @import("mouse.zig").MouseButtonFlags;
const MouseID = @import("mouse.zig").MouseID;
const MouseWheelDirection = @import("mouse.zig").MouseWheelDirection;
const PenAxis = @import("pen.zig").Axis;
const PenID = @import("pen.zig").PenID;
const PenInputFlags = @import("pen.zig").InputFlags;
const PowerState = @import("power.zig").PowerState;
const Scancode = @import("scancode.zig").Scancode;
const SensorID = @import("sensor.zig").SensorID;
const TouchID = @import("touch.zig").TouchID;
const WindowID = @import("video.zig").WindowID;
const Window = @import("video.zig").Window;

pub const EventType = u32;
pub const first: c_int = 0;
pub const quit: c_int = 256;
pub const terminating: c_int = 257;
pub const low_memory: c_int = 258;
pub const will_enter_background: c_int = 259;
pub const did_enter_background: c_int = 260;
pub const will_enter_foreground: c_int = 261;
pub const did_enter_foreground: c_int = 262;
pub const locale_changed: c_int = 263;
pub const system_theme_changed: c_int = 264;
pub const display_orientation: c_int = 337;
pub const display_added: c_int = 338;
pub const display_removed: c_int = 339;
pub const display_moved: c_int = 340;
pub const display_desktop_mode_changed: c_int = 341;
pub const display_current_mode_changed: c_int = 342;
pub const display_content_scale_changed: c_int = 343;
pub const display_first: c_int = 337;
pub const display_last: c_int = 343;
pub const window_shown: c_int = 514;
pub const window_hidden: c_int = 515;
pub const window_exposed: c_int = 516;
pub const window_moved: c_int = 517;
pub const window_resized: c_int = 518;
pub const window_pixel_size_changed: c_int = 519;
pub const window_metal_view_resized: c_int = 520;
pub const window_minimized: c_int = 521;
pub const window_maximized: c_int = 522;
pub const window_restored: c_int = 523;
pub const window_mouse_enter: c_int = 524;
pub const window_mouse_leave: c_int = 525;
pub const window_focus_gained: c_int = 526;
pub const window_focus_lost: c_int = 527;
pub const window_close_requested: c_int = 528;
pub const window_hit_test: c_int = 529;
pub const window_iccprof_changed: c_int = 530;
pub const window_display_changed: c_int = 531;
pub const window_display_scale_changed: c_int = 532;
pub const window_safe_area_changed: c_int = 533;
pub const window_occluded: c_int = 534;
pub const window_enter_fullscreen: c_int = 535;
pub const window_leave_fullscreen: c_int = 536;
pub const window_destroyed: c_int = 537;
pub const window_hdr_state_changed: c_int = 538;
pub const window_first: c_int = 514;
pub const window_last: c_int = 538;
pub const key_down: c_int = 768;
pub const key_up: c_int = 769;
pub const text_editing: c_int = 770;
pub const text_input: c_int = 771;
pub const keymap_changed: c_int = 772;
pub const keyboard_added: c_int = 773;
pub const keyboard_removed: c_int = 774;
pub const text_editing_candidates: c_int = 775;
pub const mouse_motion: c_int = 1024;
pub const mouse_button_down: c_int = 1025;
pub const mouse_button_up: c_int = 1026;
pub const mouse_wheel: c_int = 1027;
pub const mouse_added: c_int = 1028;
pub const mouse_removed: c_int = 1029;
pub const joystick_axis_motion: c_int = 1536;
pub const joystick_ball_motion: c_int = 1537;
pub const joystick_hat_motion: c_int = 1538;
pub const joystick_button_down: c_int = 1539;
pub const joystick_button_up: c_int = 1540;
pub const joystick_added: c_int = 1541;
pub const joystick_removed: c_int = 1542;
pub const joystick_battery_updated: c_int = 1543;
pub const joystick_update_complete: c_int = 1544;
pub const gamepad_axis_motion: c_int = 1616;
pub const gamepad_button_down: c_int = 1617;
pub const gamepad_button_up: c_int = 1618;
pub const gamepad_added: c_int = 1619;
pub const gamepad_removed: c_int = 1620;
pub const gamepad_remapped: c_int = 1621;
pub const gamepad_touchpad_down: c_int = 1622;
pub const gamepad_touchpad_motion: c_int = 1623;
pub const gamepad_touchpad_up: c_int = 1624;
pub const gamepad_sensor_update: c_int = 1625;
pub const gamepad_update_complete: c_int = 1626;
pub const gamepad_steam_handle_updated: c_int = 1627;
pub const finger_down: c_int = 1792;
pub const finger_up: c_int = 1793;
pub const finger_motion: c_int = 1794;
pub const clipboard_update: c_int = 2304;
pub const drop_file: c_int = 4096;
pub const drop_text: c_int = 4097;
pub const drop_begin: c_int = 4098;
pub const drop_complete: c_int = 4099;
pub const drop_position: c_int = 4100;
pub const audio_device_added: c_int = 4352;
pub const audio_device_removed: c_int = 4353;
pub const audio_device_format_changed: c_int = 4354;
pub const sensor_update: c_int = 4608;
pub const pen_proximity_in: c_int = 4864;
pub const pen_proximity_out: c_int = 4865;
pub const pen_down: c_int = 4866;
pub const pen_up: c_int = 4867;
pub const pen_button_down: c_int = 4868;
pub const pen_button_up: c_int = 4869;
pub const pen_motion: c_int = 4870;
pub const pen_axis: c_int = 4871;
pub const camera_device_added: c_int = 5120;
pub const camera_device_removed: c_int = 5121;
pub const camera_device_approved: c_int = 5122;
pub const camera_device_denied: c_int = 5123;
pub const render_targets_reset: c_int = 8192;
pub const render_device_reset: c_int = 8193;
pub const poll_sentinel: c_int = 32512;
pub const user: c_int = 32768;
pub const last: c_int = 65535;
// pub const enum_padding: c_int = 2147483647;

//pub const enum_SDL_EventType = c_uint;
//pub const SDL_EventType = enum_SDL_EventType;
//pub const struct_SDL_CommonEvent = extern struct {
pub const CommonEvent = extern struct {
//    type: Uint32 = @import("std").mem.zeroes(Uint32),
	type: u32 = @import("std").mem.zeroes(u32),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//};
};
//pub const SDL_CommonEvent = struct_SDL_CommonEvent;
//pub const struct_SDL_DisplayEvent = extern struct {
pub const DisplayEvent = extern struct {
//    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
	type: EventType = @import("std").mem.zeroes(EventType),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//    displayID: SDL_DisplayID = @import("std").mem.zeroes(SDL_DisplayID),
	displayid: DisplayID = @import("std").mem.zeroes(DisplayID),
//    data1: Sint32 = @import("std").mem.zeroes(Sint32),
	data1: i32 = @import("std").mem.zeroes(i32),
//    data2: Sint32 = @import("std").mem.zeroes(Sint32),
	data2: i32 = @import("std").mem.zeroes(i32),
//};
};
//pub const SDL_DisplayEvent = struct_SDL_DisplayEvent;
//pub const struct_SDL_WindowEvent = extern struct {
pub const WindowEvent = extern struct {
//    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
	type: EventType = @import("std").mem.zeroes(EventType),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//    windowID: SDL_WindowID = @import("std").mem.zeroes(SDL_WindowID),
	windowid: WindowID = @import("std").mem.zeroes(WindowID),
//    data1: Sint32 = @import("std").mem.zeroes(Sint32),
	data1: i32 = @import("std").mem.zeroes(i32),
//    data2: Sint32 = @import("std").mem.zeroes(Sint32),
	data2: i32 = @import("std").mem.zeroes(i32),
//};
};
//pub const SDL_WindowEvent = struct_SDL_WindowEvent;
//pub const struct_SDL_KeyboardDeviceEvent = extern struct {
pub const KeyboardDeviceEvent = extern struct {
//    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
	type: EventType = @import("std").mem.zeroes(EventType),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//    which: SDL_KeyboardID = @import("std").mem.zeroes(SDL_KeyboardID),
	which: KeyboardID = @import("std").mem.zeroes(KeyboardID),
//};
};
//pub const SDL_KeyboardDeviceEvent = struct_SDL_KeyboardDeviceEvent;
//pub const struct_SDL_KeyboardEvent = extern struct {
pub const KeyboardEvent = extern struct {
//    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
	type: EventType = @import("std").mem.zeroes(EventType),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//    windowID: SDL_WindowID = @import("std").mem.zeroes(SDL_WindowID),
	windowid: WindowID = @import("std").mem.zeroes(WindowID),
//    which: SDL_KeyboardID = @import("std").mem.zeroes(SDL_KeyboardID),
	which: KeyboardID = @import("std").mem.zeroes(KeyboardID),
//    scancode: SDL_Scancode = @import("std").mem.zeroes(SDL_Scancode),
	scancode: Scancode = @import("std").mem.zeroes(Scancode),
//    key: SDL_Keycode = @import("std").mem.zeroes(SDL_Keycode),
	key: Keycode = @import("std").mem.zeroes(Keycode),
//    mod: SDL_Keymod = @import("std").mem.zeroes(SDL_Keymod),
	mod: Keymod = @import("std").mem.zeroes(Keymod),
//    raw: Uint16 = @import("std").mem.zeroes(Uint16),
	raw: u16 = @import("std").mem.zeroes(u16),
//    down: SDL_bool = @import("std").mem.zeroes(SDL_bool),
	down: bool = @import("std").mem.zeroes(bool),
//    repeat: SDL_bool = @import("std").mem.zeroes(SDL_bool),
	repeat: bool = @import("std").mem.zeroes(bool),
//};
};
//pub const SDL_KeyboardEvent = struct_SDL_KeyboardEvent;
//pub const struct_SDL_TextEditingEvent = extern struct {
pub const TextEditingEvent = extern struct {
//    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
	type: EventType = @import("std").mem.zeroes(EventType),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//    windowID: SDL_WindowID = @import("std").mem.zeroes(SDL_WindowID),
	windowid: WindowID = @import("std").mem.zeroes(WindowID),
//    text: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
	text: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
//    start: Sint32 = @import("std").mem.zeroes(Sint32),
	start: i32 = @import("std").mem.zeroes(i32),
//    length: Sint32 = @import("std").mem.zeroes(Sint32),
	length: i32 = @import("std").mem.zeroes(i32),
//};
};
//pub const SDL_TextEditingEvent = struct_SDL_TextEditingEvent;
//pub const struct_SDL_TextEditingCandidatesEvent = extern struct {
pub const TextEditingCandidatesEvent = extern struct {
//    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
	type: EventType = @import("std").mem.zeroes(EventType),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//    windowID: SDL_WindowID = @import("std").mem.zeroes(SDL_WindowID),
	windowid: WindowID = @import("std").mem.zeroes(WindowID),
//    candidates: [*c]const [*c]const u8 = @import("std").mem.zeroes([*c]const [*c]const u8),
	candidates: [*c]const [*c]const u8 = @import("std").mem.zeroes([*c]const [*c]const u8),
//    num_candidates: Sint32 = @import("std").mem.zeroes(Sint32),
	num_candidates: i32 = @import("std").mem.zeroes(i32),
//    selected_candidate: Sint32 = @import("std").mem.zeroes(Sint32),
	selected_candidate: i32 = @import("std").mem.zeroes(i32),
//    horizontal: SDL_bool = @import("std").mem.zeroes(SDL_bool),
	horizontal: bool = @import("std").mem.zeroes(bool),
//    padding1: Uint8 = @import("std").mem.zeroes(Uint8),
	padding1: u8 = @import("std").mem.zeroes(u8),
//    padding2: Uint8 = @import("std").mem.zeroes(Uint8),
	padding2: u8 = @import("std").mem.zeroes(u8),
//    padding3: Uint8 = @import("std").mem.zeroes(Uint8),
	padding3: u8 = @import("std").mem.zeroes(u8),
//};
};
//pub const SDL_TextEditingCandidatesEvent = struct_SDL_TextEditingCandidatesEvent;
//pub const struct_SDL_TextInputEvent = extern struct {
pub const TextInputEvent = extern struct {
//    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
	type: EventType = @import("std").mem.zeroes(EventType),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//    windowID: SDL_WindowID = @import("std").mem.zeroes(SDL_WindowID),
	windowid: WindowID = @import("std").mem.zeroes(WindowID),
//    text: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
	text: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
//};
};
//pub const SDL_TextInputEvent = struct_SDL_TextInputEvent;
//pub const struct_SDL_MouseDeviceEvent = extern struct {
pub const MouseDeviceEvent = extern struct {
//    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
	type: EventType = @import("std").mem.zeroes(EventType),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//    which: SDL_MouseID = @import("std").mem.zeroes(SDL_MouseID),
	which: MouseID = @import("std").mem.zeroes(MouseID),
//};
};
//pub const SDL_MouseDeviceEvent = struct_SDL_MouseDeviceEvent;
//pub const struct_SDL_MouseMotionEvent = extern struct {
pub const MouseMotionEvent = extern struct {
//    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
	type: EventType = @import("std").mem.zeroes(EventType),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//    windowID: SDL_WindowID = @import("std").mem.zeroes(SDL_WindowID),
	windowid: WindowID = @import("std").mem.zeroes(WindowID),
//    which: SDL_MouseID = @import("std").mem.zeroes(SDL_MouseID),
	which: MouseID = @import("std").mem.zeroes(MouseID),
//    state: SDL_MouseButtonFlags = @import("std").mem.zeroes(SDL_MouseButtonFlags),
	state: MouseButtonFlags = @import("std").mem.zeroes(MouseButtonFlags),
//    x: f32 = @import("std").mem.zeroes(f32),
	x: f32 = @import("std").mem.zeroes(f32),
//    y: f32 = @import("std").mem.zeroes(f32),
	y: f32 = @import("std").mem.zeroes(f32),
//    xrel: f32 = @import("std").mem.zeroes(f32),
	xrel: f32 = @import("std").mem.zeroes(f32),
//    yrel: f32 = @import("std").mem.zeroes(f32),
	yrel: f32 = @import("std").mem.zeroes(f32),
//};
};
//pub const SDL_MouseMotionEvent = struct_SDL_MouseMotionEvent;
//pub const struct_SDL_MouseButtonEvent = extern struct {
pub const MouseButtonEvent = extern struct {
//    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
	type: EventType = @import("std").mem.zeroes(EventType),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//    windowID: SDL_WindowID = @import("std").mem.zeroes(SDL_WindowID),
	windowid: WindowID = @import("std").mem.zeroes(WindowID),
//    which: SDL_MouseID = @import("std").mem.zeroes(SDL_MouseID),
	which: MouseID = @import("std").mem.zeroes(MouseID),
//    button: Uint8 = @import("std").mem.zeroes(Uint8),
	button: u8 = @import("std").mem.zeroes(u8),
//    down: SDL_bool = @import("std").mem.zeroes(SDL_bool),
	down: bool = @import("std").mem.zeroes(bool),
//    clicks: Uint8 = @import("std").mem.zeroes(Uint8),
	clicks: u8 = @import("std").mem.zeroes(u8),
//    padding: Uint8 = @import("std").mem.zeroes(Uint8),
	padding: u8 = @import("std").mem.zeroes(u8),
//    x: f32 = @import("std").mem.zeroes(f32),
	x: f32 = @import("std").mem.zeroes(f32),
//    y: f32 = @import("std").mem.zeroes(f32),
	y: f32 = @import("std").mem.zeroes(f32),
//};
};
//pub const SDL_MouseButtonEvent = struct_SDL_MouseButtonEvent;
//pub const struct_SDL_MouseWheelEvent = extern struct {
pub const MouseWheelEvent = extern struct {
//    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
	type: EventType = @import("std").mem.zeroes(EventType),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//    windowID: SDL_WindowID = @import("std").mem.zeroes(SDL_WindowID),
	windowid: WindowID = @import("std").mem.zeroes(WindowID),
//    which: SDL_MouseID = @import("std").mem.zeroes(SDL_MouseID),
	which: MouseID = @import("std").mem.zeroes(MouseID),
//    x: f32 = @import("std").mem.zeroes(f32),
	x: f32 = @import("std").mem.zeroes(f32),
//    y: f32 = @import("std").mem.zeroes(f32),
	y: f32 = @import("std").mem.zeroes(f32),
//    direction: SDL_MouseWheelDirection = @import("std").mem.zeroes(SDL_MouseWheelDirection),
	direction: MouseWheelDirection = @import("std").mem.zeroes(MouseWheelDirection),
//    mouse_x: f32 = @import("std").mem.zeroes(f32),
	mouse_x: f32 = @import("std").mem.zeroes(f32),
//    mouse_y: f32 = @import("std").mem.zeroes(f32),
	mouse_y: f32 = @import("std").mem.zeroes(f32),
//};
};
//pub const SDL_MouseWheelEvent = struct_SDL_MouseWheelEvent;
//pub const struct_SDL_JoyAxisEvent = extern struct {
pub const JoyAxisEvent = extern struct {
//    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
	type: EventType = @import("std").mem.zeroes(EventType),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//    which: SDL_JoystickID = @import("std").mem.zeroes(SDL_JoystickID),
	which: JoystickID = @import("std").mem.zeroes(JoystickID),
//    axis: Uint8 = @import("std").mem.zeroes(Uint8),
	axis: u8 = @import("std").mem.zeroes(u8),
//    padding1: Uint8 = @import("std").mem.zeroes(Uint8),
	padding1: u8 = @import("std").mem.zeroes(u8),
//    padding2: Uint8 = @import("std").mem.zeroes(Uint8),
	padding2: u8 = @import("std").mem.zeroes(u8),
//    padding3: Uint8 = @import("std").mem.zeroes(Uint8),
	padding3: u8 = @import("std").mem.zeroes(u8),
//    value: Sint16 = @import("std").mem.zeroes(Sint16),
	value: i16 = @import("std").mem.zeroes(i16),
//    padding4: Uint16 = @import("std").mem.zeroes(Uint16),
	padding4: u16 = @import("std").mem.zeroes(u16),
//};
};
//pub const SDL_JoyAxisEvent = struct_SDL_JoyAxisEvent;
//pub const struct_SDL_JoyBallEvent = extern struct {
pub const JoyBallEvent = extern struct {
//    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
	type: EventType = @import("std").mem.zeroes(EventType),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//    which: SDL_JoystickID = @import("std").mem.zeroes(SDL_JoystickID),
	which: JoystickID = @import("std").mem.zeroes(JoystickID),
//    ball: Uint8 = @import("std").mem.zeroes(Uint8),
	ball: u8 = @import("std").mem.zeroes(u8),
//    padding1: Uint8 = @import("std").mem.zeroes(Uint8),
	padding1: u8 = @import("std").mem.zeroes(u8),
//    padding2: Uint8 = @import("std").mem.zeroes(Uint8),
	padding2: u8 = @import("std").mem.zeroes(u8),
//    padding3: Uint8 = @import("std").mem.zeroes(Uint8),
	padding3: u8 = @import("std").mem.zeroes(u8),
//    xrel: Sint16 = @import("std").mem.zeroes(Sint16),
	xrel: i16 = @import("std").mem.zeroes(i16),
//    yrel: Sint16 = @import("std").mem.zeroes(Sint16),
	yrel: i16 = @import("std").mem.zeroes(i16),
//};
};
//pub const SDL_JoyBallEvent = struct_SDL_JoyBallEvent;
//pub const struct_SDL_JoyHatEvent = extern struct {
pub const JoyHatEvent = extern struct {
//    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
	type: EventType = @import("std").mem.zeroes(EventType),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//    which: SDL_JoystickID = @import("std").mem.zeroes(SDL_JoystickID),
	which: JoystickID = @import("std").mem.zeroes(JoystickID),
//    hat: Uint8 = @import("std").mem.zeroes(Uint8),
	hat: u8 = @import("std").mem.zeroes(u8),
//    value: Uint8 = @import("std").mem.zeroes(Uint8),
	value: u8 = @import("std").mem.zeroes(u8),
//    padding1: Uint8 = @import("std").mem.zeroes(Uint8),
	padding1: u8 = @import("std").mem.zeroes(u8),
//    padding2: Uint8 = @import("std").mem.zeroes(Uint8),
	padding2: u8 = @import("std").mem.zeroes(u8),
//};
};
//pub const SDL_JoyHatEvent = struct_SDL_JoyHatEvent;
//pub const struct_SDL_JoyButtonEvent = extern struct {
pub const JoyButtonEvent = extern struct {
//    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
	type: EventType = @import("std").mem.zeroes(EventType),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//    which: SDL_JoystickID = @import("std").mem.zeroes(SDL_JoystickID),
	which: JoystickID = @import("std").mem.zeroes(JoystickID),
//    button: Uint8 = @import("std").mem.zeroes(Uint8),
	button: u8 = @import("std").mem.zeroes(u8),
//    down: SDL_bool = @import("std").mem.zeroes(SDL_bool),
	down: bool = @import("std").mem.zeroes(bool),
//    padding1: Uint8 = @import("std").mem.zeroes(Uint8),
	padding1: u8 = @import("std").mem.zeroes(u8),
//    padding2: Uint8 = @import("std").mem.zeroes(Uint8),
	padding2: u8 = @import("std").mem.zeroes(u8),
//};
};
//pub const SDL_JoyButtonEvent = struct_SDL_JoyButtonEvent;
//pub const struct_SDL_JoyDeviceEvent = extern struct {
pub const JoyDeviceEvent = extern struct {
//    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
	type: EventType = @import("std").mem.zeroes(EventType),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//    which: SDL_JoystickID = @import("std").mem.zeroes(SDL_JoystickID),
	which: JoystickID = @import("std").mem.zeroes(JoystickID),
//};
};
//pub const SDL_JoyDeviceEvent = struct_SDL_JoyDeviceEvent;
//pub const struct_SDL_JoyBatteryEvent = extern struct {
pub const JoyBatteryEvent = extern struct {
//    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
	type: EventType = @import("std").mem.zeroes(EventType),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//    which: SDL_JoystickID = @import("std").mem.zeroes(SDL_JoystickID),
	which: JoystickID = @import("std").mem.zeroes(JoystickID),
//    state: SDL_PowerState = @import("std").mem.zeroes(SDL_PowerState),
	state: PowerState = @import("std").mem.zeroes(PowerState),
//    percent: c_int = @import("std").mem.zeroes(c_int),
	percent: c_int = @import("std").mem.zeroes(c_int),
//};
};
//pub const SDL_JoyBatteryEvent = struct_SDL_JoyBatteryEvent;
//pub const struct_SDL_GamepadAxisEvent = extern struct {
pub const GamepadAxisEvent = extern struct {
//    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
	type: EventType = @import("std").mem.zeroes(EventType),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//    which: SDL_JoystickID = @import("std").mem.zeroes(SDL_JoystickID),
	which: JoystickID = @import("std").mem.zeroes(JoystickID),
//    axis: Uint8 = @import("std").mem.zeroes(Uint8),
	axis: u8 = @import("std").mem.zeroes(u8),
//    padding1: Uint8 = @import("std").mem.zeroes(Uint8),
	padding1: u8 = @import("std").mem.zeroes(u8),
//    padding2: Uint8 = @import("std").mem.zeroes(Uint8),
	padding2: u8 = @import("std").mem.zeroes(u8),
//    padding3: Uint8 = @import("std").mem.zeroes(Uint8),
	padding3: u8 = @import("std").mem.zeroes(u8),
//    value: Sint16 = @import("std").mem.zeroes(Sint16),
	value: i16 = @import("std").mem.zeroes(i16),
//    padding4: Uint16 = @import("std").mem.zeroes(Uint16),
	padding4: u16 = @import("std").mem.zeroes(u16),
//};
};
//pub const SDL_GamepadAxisEvent = struct_SDL_GamepadAxisEvent;
//pub const struct_SDL_GamepadButtonEvent = extern struct {
pub const GamepadButtonEvent = extern struct {
//    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
	type: EventType = @import("std").mem.zeroes(EventType),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//    which: SDL_JoystickID = @import("std").mem.zeroes(SDL_JoystickID),
	which: JoystickID = @import("std").mem.zeroes(JoystickID),
//    button: Uint8 = @import("std").mem.zeroes(Uint8),
	button: u8 = @import("std").mem.zeroes(u8),
//    down: SDL_bool = @import("std").mem.zeroes(SDL_bool),
	down: bool = @import("std").mem.zeroes(bool),
//    padding1: Uint8 = @import("std").mem.zeroes(Uint8),
	padding1: u8 = @import("std").mem.zeroes(u8),
//    padding2: Uint8 = @import("std").mem.zeroes(Uint8),
	padding2: u8 = @import("std").mem.zeroes(u8),
//};
};
//pub const SDL_GamepadButtonEvent = struct_SDL_GamepadButtonEvent;
//pub const struct_SDL_GamepadDeviceEvent = extern struct {
pub const GamepadDeviceEvent = extern struct {
//    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
	type: EventType = @import("std").mem.zeroes(EventType),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//    which: SDL_JoystickID = @import("std").mem.zeroes(SDL_JoystickID),
	which: JoystickID = @import("std").mem.zeroes(JoystickID),
//};
};
//pub const SDL_GamepadDeviceEvent = struct_SDL_GamepadDeviceEvent;
//pub const struct_SDL_GamepadTouchpadEvent = extern struct {
pub const GamepadTouchpadEvent = extern struct {
//    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
	type: EventType = @import("std").mem.zeroes(EventType),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//    which: SDL_JoystickID = @import("std").mem.zeroes(SDL_JoystickID),
	which: JoystickID = @import("std").mem.zeroes(JoystickID),
//    touchpad: Sint32 = @import("std").mem.zeroes(Sint32),
	touchpad: i32 = @import("std").mem.zeroes(i32),
//    finger: Sint32 = @import("std").mem.zeroes(Sint32),
	finger: i32 = @import("std").mem.zeroes(i32),
//    x: f32 = @import("std").mem.zeroes(f32),
	x: f32 = @import("std").mem.zeroes(f32),
//    y: f32 = @import("std").mem.zeroes(f32),
	y: f32 = @import("std").mem.zeroes(f32),
//    pressure: f32 = @import("std").mem.zeroes(f32),
	pressure: f32 = @import("std").mem.zeroes(f32),
//};
};
//pub const SDL_GamepadTouchpadEvent = struct_SDL_GamepadTouchpadEvent;
//pub const struct_SDL_GamepadSensorEvent = extern struct {
pub const GamepadSensorEvent = extern struct {
//    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
	type: EventType = @import("std").mem.zeroes(EventType),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//    which: SDL_JoystickID = @import("std").mem.zeroes(SDL_JoystickID),
	which: JoystickID = @import("std").mem.zeroes(JoystickID),
//    sensor: Sint32 = @import("std").mem.zeroes(Sint32),
	sensor: i32 = @import("std").mem.zeroes(i32),
//    data: [3]f32 = @import("std").mem.zeroes([3]f32),
	data: [3]f32 = @import("std").mem.zeroes([3]f32),
//    sensor_timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	sensor_timestamp: u64 = @import("std").mem.zeroes(u64),
//};
};
//pub const SDL_GamepadSensorEvent = struct_SDL_GamepadSensorEvent;
//pub const struct_SDL_AudioDeviceEvent = extern struct {
pub const AudioDeviceEvent = extern struct {
//    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
	type: EventType = @import("std").mem.zeroes(EventType),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//    which: SDL_AudioDeviceID = @import("std").mem.zeroes(SDL_AudioDeviceID),
	which: AudioDeviceID = @import("std").mem.zeroes(AudioDeviceID),
//    recording: SDL_bool = @import("std").mem.zeroes(SDL_bool),
	recording: bool = @import("std").mem.zeroes(bool),
//    padding1: Uint8 = @import("std").mem.zeroes(Uint8),
	padding1: u8 = @import("std").mem.zeroes(u8),
//    padding2: Uint8 = @import("std").mem.zeroes(Uint8),
	padding2: u8 = @import("std").mem.zeroes(u8),
//    padding3: Uint8 = @import("std").mem.zeroes(Uint8),
	padding3: u8 = @import("std").mem.zeroes(u8),
//};
};
//pub const SDL_AudioDeviceEvent = struct_SDL_AudioDeviceEvent;
//pub const struct_SDL_CameraDeviceEvent = extern struct {
pub const CameraDeviceEvent = extern struct {
//    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
	type: EventType = @import("std").mem.zeroes(EventType),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//    which: SDL_CameraID = @import("std").mem.zeroes(SDL_CameraID),
	which: CameraID = @import("std").mem.zeroes(CameraID),
//};
};
//pub const SDL_CameraDeviceEvent = struct_SDL_CameraDeviceEvent;
//pub const struct_SDL_TouchFingerEvent = extern struct {
pub const TouchFingerEvent = extern struct {
//    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
	type: EventType = @import("std").mem.zeroes(EventType),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//    touchID: SDL_TouchID = @import("std").mem.zeroes(SDL_TouchID),
	touchid: TouchID = @import("std").mem.zeroes(TouchID),
//    fingerID: SDL_FingerID = @import("std").mem.zeroes(SDL_FingerID),
	fingerid: FingerID = @import("std").mem.zeroes(FingerID),
//    x: f32 = @import("std").mem.zeroes(f32),
	x: f32 = @import("std").mem.zeroes(f32),
//    y: f32 = @import("std").mem.zeroes(f32),
	y: f32 = @import("std").mem.zeroes(f32),
//    dx: f32 = @import("std").mem.zeroes(f32),
	dx: f32 = @import("std").mem.zeroes(f32),
//    dy: f32 = @import("std").mem.zeroes(f32),
	dy: f32 = @import("std").mem.zeroes(f32),
//    pressure: f32 = @import("std").mem.zeroes(f32),
	pressure: f32 = @import("std").mem.zeroes(f32),
//    windowID: SDL_WindowID = @import("std").mem.zeroes(SDL_WindowID),
	windowid: WindowID = @import("std").mem.zeroes(WindowID),
//};
};
//pub const SDL_TouchFingerEvent = struct_SDL_TouchFingerEvent;
//pub const struct_SDL_PenProximityEvent = extern struct {
pub const PenProximityEvent = extern struct {
//    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
	type: EventType = @import("std").mem.zeroes(EventType),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//    windowID: SDL_WindowID = @import("std").mem.zeroes(SDL_WindowID),
	windowid: WindowID = @import("std").mem.zeroes(WindowID),
//    which: SDL_PenID = @import("std").mem.zeroes(SDL_PenID),
	which: PenID = @import("std").mem.zeroes(PenID),
//};
};
//pub const SDL_PenProximityEvent = struct_SDL_PenProximityEvent;
//pub const struct_SDL_PenMotionEvent = extern struct {
pub const PenMotionEvent = extern struct {
//    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
	type: EventType = @import("std").mem.zeroes(EventType),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//    windowID: SDL_WindowID = @import("std").mem.zeroes(SDL_WindowID),
	windowid: WindowID = @import("std").mem.zeroes(WindowID),
//    which: SDL_PenID = @import("std").mem.zeroes(SDL_PenID),
	which: PenID = @import("std").mem.zeroes(PenID),
//    pen_state: SDL_PenInputFlags = @import("std").mem.zeroes(SDL_PenInputFlags),
	pen_state: PenInputFlags = @import("std").mem.zeroes(PenInputFlags),
//    x: f32 = @import("std").mem.zeroes(f32),
	x: f32 = @import("std").mem.zeroes(f32),
//    y: f32 = @import("std").mem.zeroes(f32),
	y: f32 = @import("std").mem.zeroes(f32),
//};
};
//pub const SDL_PenMotionEvent = struct_SDL_PenMotionEvent;
//pub const struct_SDL_PenTouchEvent = extern struct {
pub const PenTouchEvent = extern struct {
//    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
	type: EventType = @import("std").mem.zeroes(EventType),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//    windowID: SDL_WindowID = @import("std").mem.zeroes(SDL_WindowID),
	windowid: WindowID = @import("std").mem.zeroes(WindowID),
//    which: SDL_PenID = @import("std").mem.zeroes(SDL_PenID),
	which: PenID = @import("std").mem.zeroes(PenID),
//    pen_state: SDL_PenInputFlags = @import("std").mem.zeroes(SDL_PenInputFlags),
	pen_state: PenInputFlags = @import("std").mem.zeroes(PenInputFlags),
//    x: f32 = @import("std").mem.zeroes(f32),
	x: f32 = @import("std").mem.zeroes(f32),
//    y: f32 = @import("std").mem.zeroes(f32),
	y: f32 = @import("std").mem.zeroes(f32),
//    eraser: SDL_bool = @import("std").mem.zeroes(SDL_bool),
	eraser: bool = @import("std").mem.zeroes(bool),
//    down: SDL_bool = @import("std").mem.zeroes(SDL_bool),
	down: bool = @import("std").mem.zeroes(bool),
//};
};
//pub const SDL_PenTouchEvent = struct_SDL_PenTouchEvent;
//pub const struct_SDL_PenButtonEvent = extern struct {
pub const PenButtonEvent = extern struct {
//    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
	type: EventType = @import("std").mem.zeroes(EventType),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//    windowID: SDL_WindowID = @import("std").mem.zeroes(SDL_WindowID),
	windowid: WindowID = @import("std").mem.zeroes(WindowID),
//    which: SDL_PenID = @import("std").mem.zeroes(SDL_PenID),
	which: PenID = @import("std").mem.zeroes(PenID),
//    pen_state: SDL_PenInputFlags = @import("std").mem.zeroes(SDL_PenInputFlags),
	pen_state: PenInputFlags = @import("std").mem.zeroes(PenInputFlags),
//    x: f32 = @import("std").mem.zeroes(f32),
	x: f32 = @import("std").mem.zeroes(f32),
//    y: f32 = @import("std").mem.zeroes(f32),
	y: f32 = @import("std").mem.zeroes(f32),
//    button: Uint8 = @import("std").mem.zeroes(Uint8),
	button: u8 = @import("std").mem.zeroes(u8),
//    down: SDL_bool = @import("std").mem.zeroes(SDL_bool),
	down: bool = @import("std").mem.zeroes(bool),
//};
};
//pub const SDL_PenButtonEvent = struct_SDL_PenButtonEvent;
//pub const struct_SDL_PenAxisEvent = extern struct {
pub const PenAxisEvent = extern struct {
//    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
	type: EventType = @import("std").mem.zeroes(EventType),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//    windowID: SDL_WindowID = @import("std").mem.zeroes(SDL_WindowID),
	windowid: WindowID = @import("std").mem.zeroes(WindowID),
//    which: SDL_PenID = @import("std").mem.zeroes(SDL_PenID),
	which: PenID = @import("std").mem.zeroes(PenID),
//    pen_state: SDL_PenInputFlags = @import("std").mem.zeroes(SDL_PenInputFlags),
	pen_state: PenInputFlags = @import("std").mem.zeroes(PenInputFlags),
//    x: f32 = @import("std").mem.zeroes(f32),
	x: f32 = @import("std").mem.zeroes(f32),
//    y: f32 = @import("std").mem.zeroes(f32),
	y: f32 = @import("std").mem.zeroes(f32),
//    axis: SDL_PenAxis = @import("std").mem.zeroes(SDL_PenAxis),
	axis: PenAxis = @import("std").mem.zeroes(PenAxis),
//    value: f32 = @import("std").mem.zeroes(f32),
	value: f32 = @import("std").mem.zeroes(f32),
//};
};
//pub const SDL_PenAxisEvent = struct_SDL_PenAxisEvent;
//pub const struct_SDL_DropEvent = extern struct {
pub const DropEvent = extern struct {
//    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
	type: EventType = @import("std").mem.zeroes(EventType),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//    windowID: SDL_WindowID = @import("std").mem.zeroes(SDL_WindowID),
	windowid: WindowID = @import("std").mem.zeroes(WindowID),
//    x: f32 = @import("std").mem.zeroes(f32),
	x: f32 = @import("std").mem.zeroes(f32),
//    y: f32 = @import("std").mem.zeroes(f32),
	y: f32 = @import("std").mem.zeroes(f32),
//    source: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
	source: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
//    data: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
	data: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
//};
};
//pub const SDL_DropEvent = struct_SDL_DropEvent;
//pub const struct_SDL_ClipboardEvent = extern struct {
pub const ClipboardEvent = extern struct {
//    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
	type: EventType = @import("std").mem.zeroes(EventType),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//};
};
//pub const SDL_ClipboardEvent = struct_SDL_ClipboardEvent;
//pub const struct_SDL_SensorEvent = extern struct {
pub const SensorEvent = extern struct {
//    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
	type: EventType = @import("std").mem.zeroes(EventType),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//    which: SDL_SensorID = @import("std").mem.zeroes(SDL_SensorID),
	which: SensorID = @import("std").mem.zeroes(SensorID),
//    data: [6]f32 = @import("std").mem.zeroes([6]f32),
	data: [6]f32 = @import("std").mem.zeroes([6]f32),
//    sensor_timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	sensor_timestamp: u64 = @import("std").mem.zeroes(u64),
//};
};
//pub const SDL_SensorEvent = struct_SDL_SensorEvent;
//pub const struct_SDL_QuitEvent = extern struct {
pub const QuitEvent = extern struct {
//    type: SDL_EventType = @import("std").mem.zeroes(SDL_EventType),
	type: EventType = @import("std").mem.zeroes(EventType),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//};
};
//pub const SDL_QuitEvent = struct_SDL_QuitEvent;
//pub const struct_SDL_UserEvent = extern struct {
pub const UserEvent = extern struct {
//    type: Uint32 = @import("std").mem.zeroes(Uint32),
	type: u32 = @import("std").mem.zeroes(u32),
//    reserved: Uint32 = @import("std").mem.zeroes(Uint32),
	reserved: u32 = @import("std").mem.zeroes(u32),
//    timestamp: Uint64 = @import("std").mem.zeroes(Uint64),
	timestamp: u64 = @import("std").mem.zeroes(u64),
//    windowID: SDL_WindowID = @import("std").mem.zeroes(SDL_WindowID),
	windowid: WindowID = @import("std").mem.zeroes(WindowID),
//    code: Sint32 = @import("std").mem.zeroes(Sint32),
	code: i32 = @import("std").mem.zeroes(i32),
//    data1: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
	data1: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
//    data2: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
	data2: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
//};
};
//pub const SDL_UserEvent = struct_SDL_UserEvent;
pub const Event = extern union {
   type: EventType,
   common: CommonEvent,
   display: DisplayEvent,
   window: WindowEvent,
   kdevice: KeyboardDeviceEvent,
   key: KeyboardEvent,
   edit: TextEditingEvent,
   edit_candidates: TextEditingCandidatesEvent,
   text: TextInputEvent,
   mdevice: MouseDeviceEvent,
   motion: MouseMotionEvent,
   button: MouseButtonEvent,
   wheel: MouseWheelEvent,
   jdevice: JoyDeviceEvent,
   jaxis: JoyAxisEvent,
   jball: JoyBallEvent,
   jhat: JoyHatEvent,
   jbutton: JoyButtonEvent,
   jbattery: JoyBatteryEvent,
   gdevice: GamepadDeviceEvent,
   gaxis: GamepadAxisEvent,
   gbutton: GamepadButtonEvent,
   gtouchpad: GamepadTouchpadEvent,
   gsensor: GamepadSensorEvent,
   adevice: AudioDeviceEvent,
   cdevice: CameraDeviceEvent,
   sensor: SensorEvent,
   quit: QuitEvent,
   user: UserEvent,
   tfinger: TouchFingerEvent,
   pproximity: PenProximityEvent,
   ptouch: PenTouchEvent,
   pmotion: PenMotionEvent,
   pbutton: PenButtonEvent,
   paxis: PenAxisEvent,
   drop: DropEvent,
   clipboard: ClipboardEvent,
   padding: [128]u8,
};

//pub const SDL_Event = union_SDL_Event;
//// ./include/SDL3/SDL_stdinc.h:561:42: warning: ignoring StaticAssert declaration
//pub extern fn SDL_PumpEvents() void;
pub extern fn SDL_PumpEvents() void;
pub const pumpEvents = SDL_PumpEvents;
//pub const SDL_ADDEVENT: c_int = 0;
//pub const SDL_PEEKEVENT: c_int = 1;
//pub const SDL_GETEVENT: c_int = 2;
//pub const enum_SDL_EventAction = c_uint;
pub const EventAction = enum (c_uint) {
	addevent,
	peekevent,
	getevent,
};

//pub const SDL_EventAction = enum_SDL_EventAction;
//pub extern fn SDL_PeepEvents(events: [*c]SDL_Event, numevents: c_int, action: SDL_EventAction, minType: Uint32, maxType: Uint32) c_int;
pub extern fn SDL_PeepEvents(events: [*c]Event, numevents: c_int, action: EventAction, minType: u32, maxType: u32) c_int;
pub const peepEvents = SDL_PeepEvents;
//pub extern fn SDL_HasEvent(@"type": Uint32) SDL_bool;
pub extern fn SDL_HasEvent(@"type": u32) bool;
pub const hasEvent = SDL_HasEvent;
//pub extern fn SDL_HasEvents(minType: Uint32, maxType: Uint32) SDL_bool;
pub extern fn SDL_HasEvents(minType: u32, maxType: u32) bool;
pub const hasEvents = SDL_HasEvents;
//pub extern fn SDL_FlushEvent(@"type": Uint32) void;
pub extern fn SDL_FlushEvent(@"type": u32) void;
pub const flushEvent = SDL_FlushEvent;
//pub extern fn SDL_FlushEvents(minType: Uint32, maxType: Uint32) void;
pub extern fn SDL_FlushEvents(minType: u32, maxType: u32) void;
pub const flushEvents = SDL_FlushEvents;
//pub extern fn SDL_PollEvent(event: [*c]SDL_Event) SDL_bool;
pub extern fn SDL_PollEvent(event: [*c]Event) bool;
pub const pollEvent = SDL_PollEvent;
//pub extern fn SDL_WaitEvent(event: [*c]SDL_Event) SDL_bool;
pub extern fn SDL_WaitEvent(event: [*c]Event) bool;
pub const waitEvent = SDL_WaitEvent;
//pub extern fn SDL_WaitEventTimeout(event: [*c]SDL_Event, timeoutMS: Sint32) SDL_bool;
pub extern fn SDL_WaitEventTimeout(event: [*c]Event, timeoutMS: i32) bool;
pub const waitEventTimeout = SDL_WaitEventTimeout;
//pub extern fn SDL_PushEvent(event: [*c]SDL_Event) SDL_bool;
pub extern fn SDL_PushEvent(event: [*c]Event) bool;
pub const pushEvent = SDL_PushEvent;
//pub const SDL_EventFilter = ?*const fn (?*anyopaque, [*c]SDL_Event) callconv(.C) SDL_bool;
pub const EventFilter = ?*const fn (?*anyopaque, [*c]Event) callconv(.C) bool;
//pub extern fn SDL_SetEventFilter(filter: SDL_EventFilter, userdata: ?*anyopaque) void;
pub extern fn SDL_SetEventFilter(filter: EventFilter, userdata: ?*anyopaque) void;
pub const setEventFilter = SDL_SetEventFilter;
//pub extern fn SDL_GetEventFilter(filter: [*c]SDL_EventFilter, userdata: [*c]?*anyopaque) SDL_bool;
pub extern fn SDL_GetEventFilter(filter: [*c]EventFilter, userdata: [*c]?*anyopaque) bool;
pub const getEventFilter = SDL_GetEventFilter;
//pub extern fn SDL_AddEventWatch(filter: SDL_EventFilter, userdata: ?*anyopaque) SDL_bool;
pub extern fn SDL_AddEventWatch(filter: EventFilter, userdata: ?*anyopaque) bool;
pub const addEventWatch = SDL_AddEventWatch;
//pub extern fn SDL_RemoveEventWatch(filter: SDL_EventFilter, userdata: ?*anyopaque) void;
pub extern fn SDL_RemoveEventWatch(filter: EventFilter, userdata: ?*anyopaque) void;
pub const removeEventWatch = SDL_RemoveEventWatch;
//pub extern fn SDL_FilterEvents(filter: SDL_EventFilter, userdata: ?*anyopaque) void;
pub extern fn SDL_FilterEvents(filter: EventFilter, userdata: ?*anyopaque) void;
pub const filterEvents = SDL_FilterEvents;
//pub extern fn SDL_SetEventEnabled(@"type": Uint32, enabled: SDL_bool) void;
pub extern fn SDL_SetEventEnabled(@"type": u32, enabled: bool) void;
pub const setEventEnabled = SDL_SetEventEnabled;
//pub extern fn SDL_EventEnabled(@"type": Uint32) SDL_bool;
pub extern fn SDL_EventEnabled(@"type": u32) bool;
pub const eventEnabled = SDL_EventEnabled;
//pub extern fn SDL_RegisterEvents(numevents: c_int) Uint32;
pub extern fn SDL_RegisterEvents(numevents: c_int) u32;
pub const registerEvents = SDL_RegisterEvents;
//pub extern fn SDL_GetWindowFromEvent(event: [*c]const SDL_Event) ?*SDL_Window;
pub extern fn SDL_GetWindowFromEvent(event: [*c]const Event) ?*Window;
pub const getWindowFromEvent = SDL_GetWindowFromEvent;