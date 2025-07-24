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

pub const EventType = enum(c_int) {
    first = 0,
    quit = 0x100,
    terminating,
    low_memory,
    will_enter_background,
    did_enter_background,
    will_enter_foreground,
    did_enter_foreground,
    locale_changed,
    system_theme_changed,

    display_orientation = 0x151,
    display_added,
    display_removed,
    display_moved,
    display_desktop_mode_changed,
    display_current_mode_changed,
    display_content_scale_changed,

    window_shown = 0x202,
    window_hidden,
    window_exposed,
    window_moved,
    window_resized,
    window_pixel_size_changed,
    window_metal_view_resized,
    window_minimized,
    window_maximized,
    window_restored,
    window_mouse_enter,
    window_mouse_leave,
    window_focus_gained,
    window_focus_lost,
    window_close_requested,
    window_hit_test,
    window_iccprof_changed,
    window_display_changed,
    window_display_scale_changed,
    window_safe_area_changed,
    window_occluded,
    window_enter_fullscreen,
    window_leave_fullscreen,
    window_destroyed,
    window_hdr_state_changed,

    key_down = 0x300,
    key_up,
    text_editing,
    text_input,
    keymap_changed,
    keyboard_added,
    keyboard_removed,
    text_editing_candidates,

    mouse_motion = 0x400,
    mouse_button_down,
    mouse_button_up,
    mouse_wheel,
    mouse_added,
    mouse_removed,

    joystick_axis_motion = 0x600,
    joystick_ball_motion,
    joystick_hat_motion,
    joystick_button_down,
    joystick_button_up,
    joystick_added,
    joystick_removed,
    joystick_battery_updated,
    joystick_update_complete,

    gamepad_axis_motion = 0x650,
    gamepad_button_down,
    gamepad_button_up,
    gamepad_added,
    gamepad_removed,
    gamepad_remapped,
    gamepad_touchpad_down,
    gamepad_touchpad_motion,
    gamepad_touchpad_up,
    gamepad_sensor_update,
    gamepad_update_complete,
    gamepad_steam_handle_updated,

    finger_down = 0x700,
    finger_up,
    finger_motion,

    clipboard_update = 0x900,

    drop_file = 0x1000,
    drop_text,
    drop_begin,
    drop_complete,
    drop_position,

    audio_device_added = 0x1100,
    audio_device_removed,
    audio_device_format_changed,

    sensor_update = 0x1200,
    pen_proximity_in = 0x1300,
    pen_proximity_out,
    pen_down,
    pen_up,
    pen_button_down,
    pen_button_up,
    pen_motion,
    pen_axis,
    camera_device_added = 0x1400,
    camera_device_removed,
    camera_device_approved,
    camera_device_denied,
    render_targets_reset = 0x2000,
    render_device_reset,
    render_device_lost,
    private0 = 0x4000,
    private1,
    private2,
    private3,
    poll_sentinel = 0x7F00,
    user = 0x8000,
    last = 0xFFFF,
    enum_padding = 0x7FFFFFF,

    pub const display_first: EventType = .display_orientation;
    pub const display_last: EventType = .display_content_scale_changed;
    pub const window_first: EventType = .window_shown;
    pub const window_last: EventType = .window_hdr_state_changed;
};

pub const EventAction = enum(c_uint) {
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
    type: EventType,
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

pub const EventFilter = ?*const fn (?*anyopaque, ?*Event) callconv(.c) bool;

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
