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

pub const CommonEvent = extern struct {
	type: u32 = @import("std").mem.zeroes(u32),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
};
pub const DisplayEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	displayid: DisplayID = @import("std").mem.zeroes(DisplayID),
	data1: i32 = @import("std").mem.zeroes(i32),
	data2: i32 = @import("std").mem.zeroes(i32),
};
pub const WindowEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	windowid: WindowID = @import("std").mem.zeroes(WindowID),
	data1: i32 = @import("std").mem.zeroes(i32),
	data2: i32 = @import("std").mem.zeroes(i32),
};
pub const KeyboardDeviceEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	which: KeyboardID = @import("std").mem.zeroes(KeyboardID),
};
pub const KeyboardEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	windowid: WindowID = @import("std").mem.zeroes(WindowID),
	which: KeyboardID = @import("std").mem.zeroes(KeyboardID),
	scancode: Scancode = @import("std").mem.zeroes(Scancode),
	key: Keycode = @import("std").mem.zeroes(Keycode),
	mod: Keymod = @import("std").mem.zeroes(Keymod),
	raw: u16 = @import("std").mem.zeroes(u16),
	down: bool = @import("std").mem.zeroes(bool),
	repeat: bool = @import("std").mem.zeroes(bool),
};
pub const TextEditingEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	windowid: WindowID = @import("std").mem.zeroes(WindowID),
	text: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
	start: i32 = @import("std").mem.zeroes(i32),
	length: i32 = @import("std").mem.zeroes(i32),
};
pub const TextEditingCandidatesEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	windowid: WindowID = @import("std").mem.zeroes(WindowID),
	candidates: [*c]const [*c]const u8 = @import("std").mem.zeroes([*c]const [*c]const u8),
	num_candidates: i32 = @import("std").mem.zeroes(i32),
	selected_candidate: i32 = @import("std").mem.zeroes(i32),
	horizontal: bool = @import("std").mem.zeroes(bool),
	padding1: u8 = @import("std").mem.zeroes(u8),
	padding2: u8 = @import("std").mem.zeroes(u8),
	padding3: u8 = @import("std").mem.zeroes(u8),
};
pub const TextInputEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	windowid: WindowID = @import("std").mem.zeroes(WindowID),
	text: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
};
pub const MouseDeviceEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	which: MouseID = @import("std").mem.zeroes(MouseID),
};
pub const MouseMotionEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	windowid: WindowID = @import("std").mem.zeroes(WindowID),
	which: MouseID = @import("std").mem.zeroes(MouseID),
	state: MouseButtonFlags = @import("std").mem.zeroes(MouseButtonFlags),
	x: f32 = @import("std").mem.zeroes(f32),
	y: f32 = @import("std").mem.zeroes(f32),
	xrel: f32 = @import("std").mem.zeroes(f32),
	yrel: f32 = @import("std").mem.zeroes(f32),
};
pub const MouseButtonEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	windowid: WindowID = @import("std").mem.zeroes(WindowID),
	which: MouseID = @import("std").mem.zeroes(MouseID),
	button: u8 = @import("std").mem.zeroes(u8),
	down: bool = @import("std").mem.zeroes(bool),
	clicks: u8 = @import("std").mem.zeroes(u8),
	padding: u8 = @import("std").mem.zeroes(u8),
	x: f32 = @import("std").mem.zeroes(f32),
	y: f32 = @import("std").mem.zeroes(f32),
};
pub const MouseWheelEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	windowid: WindowID = @import("std").mem.zeroes(WindowID),
	which: MouseID = @import("std").mem.zeroes(MouseID),
	x: f32 = @import("std").mem.zeroes(f32),
	y: f32 = @import("std").mem.zeroes(f32),
	direction: MouseWheelDirection = @import("std").mem.zeroes(MouseWheelDirection),
	mouse_x: f32 = @import("std").mem.zeroes(f32),
	mouse_y: f32 = @import("std").mem.zeroes(f32),
};
pub const JoyAxisEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	which: JoystickID = @import("std").mem.zeroes(JoystickID),
	axis: u8 = @import("std").mem.zeroes(u8),
	padding1: u8 = @import("std").mem.zeroes(u8),
	padding2: u8 = @import("std").mem.zeroes(u8),
	padding3: u8 = @import("std").mem.zeroes(u8),
	value: i16 = @import("std").mem.zeroes(i16),
	padding4: u16 = @import("std").mem.zeroes(u16),
};
pub const JoyBallEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	which: JoystickID = @import("std").mem.zeroes(JoystickID),
	ball: u8 = @import("std").mem.zeroes(u8),
	padding1: u8 = @import("std").mem.zeroes(u8),
	padding2: u8 = @import("std").mem.zeroes(u8),
	padding3: u8 = @import("std").mem.zeroes(u8),
	xrel: i16 = @import("std").mem.zeroes(i16),
	yrel: i16 = @import("std").mem.zeroes(i16),
};
pub const JoyHatEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	which: JoystickID = @import("std").mem.zeroes(JoystickID),
	hat: u8 = @import("std").mem.zeroes(u8),
	value: u8 = @import("std").mem.zeroes(u8),
	padding1: u8 = @import("std").mem.zeroes(u8),
	padding2: u8 = @import("std").mem.zeroes(u8),
};
pub const JoyButtonEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	which: JoystickID = @import("std").mem.zeroes(JoystickID),
	button: u8 = @import("std").mem.zeroes(u8),
	down: bool = @import("std").mem.zeroes(bool),
	padding1: u8 = @import("std").mem.zeroes(u8),
	padding2: u8 = @import("std").mem.zeroes(u8),
};
pub const JoyDeviceEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	which: JoystickID = @import("std").mem.zeroes(JoystickID),
};
pub const JoyBatteryEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	which: JoystickID = @import("std").mem.zeroes(JoystickID),
	state: PowerState = @import("std").mem.zeroes(PowerState),
	percent: c_int = @import("std").mem.zeroes(c_int),
};
pub const GamepadAxisEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	which: JoystickID = @import("std").mem.zeroes(JoystickID),
	axis: u8 = @import("std").mem.zeroes(u8),
	padding1: u8 = @import("std").mem.zeroes(u8),
	padding2: u8 = @import("std").mem.zeroes(u8),
	padding3: u8 = @import("std").mem.zeroes(u8),
	value: i16 = @import("std").mem.zeroes(i16),
	padding4: u16 = @import("std").mem.zeroes(u16),
};
pub const GamepadButtonEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	which: JoystickID = @import("std").mem.zeroes(JoystickID),
	button: u8 = @import("std").mem.zeroes(u8),
	down: bool = @import("std").mem.zeroes(bool),
	padding1: u8 = @import("std").mem.zeroes(u8),
	padding2: u8 = @import("std").mem.zeroes(u8),
};
pub const GamepadDeviceEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	which: JoystickID = @import("std").mem.zeroes(JoystickID),
};
pub const GamepadTouchpadEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	which: JoystickID = @import("std").mem.zeroes(JoystickID),
	touchpad: i32 = @import("std").mem.zeroes(i32),
	finger: i32 = @import("std").mem.zeroes(i32),
	x: f32 = @import("std").mem.zeroes(f32),
	y: f32 = @import("std").mem.zeroes(f32),
	pressure: f32 = @import("std").mem.zeroes(f32),
};
pub const GamepadSensorEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	which: JoystickID = @import("std").mem.zeroes(JoystickID),
	sensor: i32 = @import("std").mem.zeroes(i32),
	data: [3]f32 = @import("std").mem.zeroes([3]f32),
	sensor_timestamp: u64 = @import("std").mem.zeroes(u64),
};
pub const AudioDeviceEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	which: AudioDeviceID = @import("std").mem.zeroes(AudioDeviceID),
	recording: bool = @import("std").mem.zeroes(bool),
	padding1: u8 = @import("std").mem.zeroes(u8),
	padding2: u8 = @import("std").mem.zeroes(u8),
	padding3: u8 = @import("std").mem.zeroes(u8),
};
pub const CameraDeviceEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	which: CameraID = @import("std").mem.zeroes(CameraID),
};
pub const TouchFingerEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	touchid: TouchID = @import("std").mem.zeroes(TouchID),
	fingerid: FingerID = @import("std").mem.zeroes(FingerID),
	x: f32 = @import("std").mem.zeroes(f32),
	y: f32 = @import("std").mem.zeroes(f32),
	dx: f32 = @import("std").mem.zeroes(f32),
	dy: f32 = @import("std").mem.zeroes(f32),
	pressure: f32 = @import("std").mem.zeroes(f32),
	windowid: WindowID = @import("std").mem.zeroes(WindowID),
};
pub const PenProximityEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	windowid: WindowID = @import("std").mem.zeroes(WindowID),
	which: PenID = @import("std").mem.zeroes(PenID),
};
pub const PenMotionEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	windowid: WindowID = @import("std").mem.zeroes(WindowID),
	which: PenID = @import("std").mem.zeroes(PenID),
	pen_state: PenInputFlags = @import("std").mem.zeroes(PenInputFlags),
	x: f32 = @import("std").mem.zeroes(f32),
	y: f32 = @import("std").mem.zeroes(f32),
};
pub const PenTouchEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	windowid: WindowID = @import("std").mem.zeroes(WindowID),
	which: PenID = @import("std").mem.zeroes(PenID),
	pen_state: PenInputFlags = @import("std").mem.zeroes(PenInputFlags),
	x: f32 = @import("std").mem.zeroes(f32),
	y: f32 = @import("std").mem.zeroes(f32),
	eraser: bool = @import("std").mem.zeroes(bool),
	down: bool = @import("std").mem.zeroes(bool),
};
pub const PenButtonEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	windowid: WindowID = @import("std").mem.zeroes(WindowID),
	which: PenID = @import("std").mem.zeroes(PenID),
	pen_state: PenInputFlags = @import("std").mem.zeroes(PenInputFlags),
	x: f32 = @import("std").mem.zeroes(f32),
	y: f32 = @import("std").mem.zeroes(f32),
	button: u8 = @import("std").mem.zeroes(u8),
	down: bool = @import("std").mem.zeroes(bool),
};
pub const PenAxisEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	windowid: WindowID = @import("std").mem.zeroes(WindowID),
	which: PenID = @import("std").mem.zeroes(PenID),
	pen_state: PenInputFlags = @import("std").mem.zeroes(PenInputFlags),
	x: f32 = @import("std").mem.zeroes(f32),
	y: f32 = @import("std").mem.zeroes(f32),
	axis: PenAxis = @import("std").mem.zeroes(PenAxis),
	value: f32 = @import("std").mem.zeroes(f32),
};
pub const DropEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	windowid: WindowID = @import("std").mem.zeroes(WindowID),
	x: f32 = @import("std").mem.zeroes(f32),
	y: f32 = @import("std").mem.zeroes(f32),
	source: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
	data: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
};
pub const ClipboardEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	owner: bool = @import("std").mem.zeroes(bool),
	n_mime_types: i32 = @import("std").mem.zeroes(i32),
	mime_types: [*c][*c]const u8 = @import("std").mem.zeroes([*c][*c]const u8),
};
pub const SensorEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	which: SensorID = @import("std").mem.zeroes(SensorID),
	data: [6]f32 = @import("std").mem.zeroes([6]f32),
	sensor_timestamp: u64 = @import("std").mem.zeroes(u64),
};
pub const QuitEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
};
pub const UserEvent = extern struct {
	type: u32 = @import("std").mem.zeroes(u32),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	windowid: WindowID = @import("std").mem.zeroes(WindowID),
	code: i32 = @import("std").mem.zeroes(i32),
	data1: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
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
pub const EventAction = enum (c_uint) {
	addevent,
	peekevent,
	getevent,
};

pub extern fn SDL_PeepEvents(events: [*c]Event, numevents: c_int, action: EventAction, minType: u32, maxType: u32) c_int;
pub const peepEvents = SDL_PeepEvents;
pub extern fn SDL_HasEvent(@"type": u32) bool;
pub const hasEvent = SDL_HasEvent;
pub extern fn SDL_HasEvents(minType: u32, maxType: u32) bool;
pub const hasEvents = SDL_HasEvents;
pub extern fn SDL_FlushEvent(@"type": u32) void;
pub const flushEvent = SDL_FlushEvent;
pub extern fn SDL_FlushEvents(minType: u32, maxType: u32) void;
pub const flushEvents = SDL_FlushEvents;
pub extern fn SDL_PollEvent(event: [*c]Event) bool;
pub const pollEvent = SDL_PollEvent;
pub extern fn SDL_WaitEvent(event: [*c]Event) bool;
pub const waitEvent = SDL_WaitEvent;
pub extern fn SDL_WaitEventTimeout(event: [*c]Event, timeoutMS: i32) bool;
pub const waitEventTimeout = SDL_WaitEventTimeout;
pub extern fn SDL_PushEvent(event: [*c]Event) bool;
pub const pushEvent = SDL_PushEvent;
pub const EventFilter = ?*const fn (?*anyopaque, [*c]Event) callconv(.C) bool;
pub extern fn SDL_SetEventFilter(filter: EventFilter, userdata: ?*anyopaque) void;
pub const setEventFilter = SDL_SetEventFilter;
pub extern fn SDL_GetEventFilter(filter: [*c]EventFilter, userdata: [*c]?*anyopaque) bool;
pub const getEventFilter = SDL_GetEventFilter;
pub extern fn SDL_AddEventWatch(filter: EventFilter, userdata: ?*anyopaque) bool;
pub const addEventWatch = SDL_AddEventWatch;
pub extern fn SDL_RemoveEventWatch(filter: EventFilter, userdata: ?*anyopaque) void;
pub const removeEventWatch = SDL_RemoveEventWatch;
pub extern fn SDL_FilterEvents(filter: EventFilter, userdata: ?*anyopaque) void;
pub const filterEvents = SDL_FilterEvents;
pub extern fn SDL_SetEventEnabled(@"type": u32, enabled: bool) void;
pub const setEventEnabled = SDL_SetEventEnabled;
pub extern fn SDL_EventEnabled(@"type": u32) bool;
pub const eventEnabled = SDL_EventEnabled;
pub extern fn SDL_RegisterEvents(numevents: c_int) u32;
pub const registerEvents = SDL_RegisterEvents;
pub extern fn SDL_GetWindowFromEvent(event: [*c]const Event) ?*Window;
pub const getWindowFromEvent = SDL_GetWindowFromEvent;
