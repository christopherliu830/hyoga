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
pub const @"type" = struct {
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
	pub const render_device_lost = 8194;
	pub const private0 = 16384;
	pub const private1 = 16385;
	pub const private2 = 16386;
	pub const private3 = 16387;
	pub const poll_sentinel = 32512;
	pub const user = 32768;
	pub const last = 65535;
	pub const enum_padding = 2147483647;
};

pub const EventAction = enum (c_uint) {
	addevent,
	peekevent,
	getevent,
};

pub const CommonEvent = extern struct {
	type: u32 = @import("std").mem.zeroes(u32),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
};

pub const DisplayEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	displayID: DisplayID = @import("std").mem.zeroes(DisplayID),
	data1: i32 = @import("std").mem.zeroes(i32),
	data2: i32 = @import("std").mem.zeroes(i32),
};

pub const WindowEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	windowID: WindowID = @import("std").mem.zeroes(WindowID),
	data1: i32 = @import("std").mem.zeroes(i32),
	data2: i32 = @import("std").mem.zeroes(i32),
};

pub const KeyboardDeviceEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	which: KeyboardID = @import("std").mem.zeroes(KeyboardID),
};

pub const KeyboardEventEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	windowID: WindowID = @import("std").mem.zeroes(WindowID),
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
	windowID: WindowID = @import("std").mem.zeroes(WindowID),
	text: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
	start: i32 = @import("std").mem.zeroes(i32),
	length: i32 = @import("std").mem.zeroes(i32),
};

pub const TextEditingCandidatesEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	windowID: WindowID = @import("std").mem.zeroes(WindowID),
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
	windowID: WindowID = @import("std").mem.zeroes(WindowID),
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
	windowID: WindowID = @import("std").mem.zeroes(WindowID),
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
	windowID: WindowID = @import("std").mem.zeroes(WindowID),
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
	windowID: WindowID = @import("std").mem.zeroes(WindowID),
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
	percent: i32 = @import("std").mem.zeroes(i32),
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
	touchID: TouchID = @import("std").mem.zeroes(TouchID),
	fingerID: FingerID = @import("std").mem.zeroes(FingerID),
	x: f32 = @import("std").mem.zeroes(f32),
	y: f32 = @import("std").mem.zeroes(f32),
	dx: f32 = @import("std").mem.zeroes(f32),
	dy: f32 = @import("std").mem.zeroes(f32),
	pressure: f32 = @import("std").mem.zeroes(f32),
	windowID: WindowID = @import("std").mem.zeroes(WindowID),
};

pub const PenProximityEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	windowID: WindowID = @import("std").mem.zeroes(WindowID),
	which: PenID = @import("std").mem.zeroes(PenID),
};

pub const PenMotionEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	windowID: WindowID = @import("std").mem.zeroes(WindowID),
	which: PenID = @import("std").mem.zeroes(PenID),
	pen_state: PenInputFlags = @import("std").mem.zeroes(PenInputFlags),
	x: f32 = @import("std").mem.zeroes(f32),
	y: f32 = @import("std").mem.zeroes(f32),
};

pub const PenTouchEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	windowID: WindowID = @import("std").mem.zeroes(WindowID),
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
	windowID: WindowID = @import("std").mem.zeroes(WindowID),
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
	windowID: WindowID = @import("std").mem.zeroes(WindowID),
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
	windowID: WindowID = @import("std").mem.zeroes(WindowID),
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
	mime_types: ?*[*c]const u8 = @import("std").mem.zeroes(?*[*c]const u8),
};

pub const SensorEvent = extern struct {
	type: EventType = @import("std").mem.zeroes(EventType),
	reserved: u32 = @import("std").mem.zeroes(u32),
	timestamp: u64 = @import("std").mem.zeroes(u64),
	which: SensorID = @import("std").mem.zeroes(SensorID),
	data: [3]f32 = @import("std").mem.zeroes([3]f32),
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
	windowID: WindowID = @import("std").mem.zeroes(WindowID),
	code: i32 = @import("std").mem.zeroes(i32),
	data1: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
	data2: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
};

pub const Event = extern union {
	type: u32,
	common: CommonEvent,
	display: DisplayEvent,
	window: WindowEvent,
	kdevice: KeyboardDeviceEvent,
	key: KeyboardEventEvent,
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
	padding: [3]u8,
};

pub const EventFilter = ?*const fn (?*anyopaque, ?*Event) callconv(.C) bool;

extern fn SDL_PumpEvents() void;
extern fn SDL_PeepEvents(events: ?*Event, numevents: i32, action: EventAction, minType: u32, maxType: u32) i32;
extern fn SDL_HasEvent(type: u32) bool;
extern fn SDL_HasEvents(minType: u32, maxType: u32) bool;
extern fn SDL_FlushEvent(type: u32) void;
extern fn SDL_FlushEvents(minType: u32, maxType: u32) void;
extern fn SDL_PollEvent(event: ?*Event) bool;
extern fn SDL_WaitEvent(event: ?*Event) bool;
extern fn SDL_WaitEventTimeout(event: ?*Event, timeoutMS: i32) bool;
extern fn SDL_PushEvent(event: ?*Event) bool;
extern fn SDL_SetEventFilter(filter: EventFilter, userdata: ?*anyopaque) void;
extern fn SDL_GetEventFilter(filter: ?*EventFilter, userdata: ?*?*anyopaque) bool;
extern fn SDL_AddEventWatch(filter: EventFilter, userdata: ?*anyopaque) bool;
extern fn SDL_RemoveEventWatch(filter: EventFilter, userdata: ?*anyopaque) void;
extern fn SDL_FilterEvents(filter: EventFilter, userdata: ?*anyopaque) void;
extern fn SDL_SetEventEnabled(type: u32, enabled: bool) void;
extern fn SDL_EventEnabled(type: u32) bool;
extern fn SDL_RegisterEvents(numevents: i32) u32;
extern fn SDL_GetWindowFromEvent(event: [*c]const Event) ?*Window;
pub const pump = SDL_PumpEvents;
pub const peep = SDL_PeepEvents;
pub const hasEvent = SDL_HasEvent;
pub const hasEvents = SDL_HasEvents;
pub const flushEvent = SDL_FlushEvent;
pub const flushEvents = SDL_FlushEvents;
pub const poll = SDL_PollEvent;
pub const wait = SDL_WaitEvent;
pub const waitEventTimeout = SDL_WaitEventTimeout;
pub const push = SDL_PushEvent;
pub const setEventFilter = SDL_SetEventFilter;
pub const getEventFilter = SDL_GetEventFilter;
pub const addEventWatch = SDL_AddEventWatch;
pub const removeEventWatch = SDL_RemoveEventWatch;
pub const filterEvents = SDL_FilterEvents;
pub const setEventEnabled = SDL_SetEventEnabled;
pub const eventEnabled = SDL_EventEnabled;
pub const register = SDL_RegisterEvents;
pub const getWindowFromEvent = SDL_GetWindowFromEvent;
