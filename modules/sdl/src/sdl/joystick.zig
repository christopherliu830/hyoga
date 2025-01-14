const Guid = @import("guid.zig").Guid;
const SensorType = @import("sensor.zig").SensorType;
const PropertiesID = @import("properties.zig").PropertiesID;
const PowerState = @import("power.zig").PowerState;

//pub const struct_SDL_Joystick = opaque {};
pub const Joystick = opaque {};

//pub const SDL_Joystick = struct_SDL_Joystick;
//pub const SDL_JoystickID = Uint32;
pub const JoystickID = u32;
//pub const SDL_JOYSTICK_TYPE_UNKNOWN: c_int = 0;
//pub const SDL_JOYSTICK_TYPE_GAMEPAD: c_int = 1;
//pub const SDL_JOYSTICK_TYPE_WHEEL: c_int = 2;
//pub const SDL_JOYSTICK_TYPE_ARCADE_STICK: c_int = 3;
//pub const SDL_JOYSTICK_TYPE_FLIGHT_STICK: c_int = 4;
//pub const SDL_JOYSTICK_TYPE_DANCE_PAD: c_int = 5;
//pub const SDL_JOYSTICK_TYPE_GUITAR: c_int = 6;
//pub const SDL_JOYSTICK_TYPE_DRUM_KIT: c_int = 7;
//pub const SDL_JOYSTICK_TYPE_ARCADE_PAD: c_int = 8;
//pub const SDL_JOYSTICK_TYPE_THROTTLE: c_int = 9;
//pub const SDL_JOYSTICK_TYPE_COUNT: c_int = 10;
//pub const enum_SDL_JoystickType = c_uint;
pub const JoystickType = enum(c_uint) {
    unknown,
    gamepad,
    wheel,
    arcade_stick,
    flight_stick,
    dance_pad,
    guitar,
    drum_kit,
    arcade_pad,
    throttle,
    count,
};

//pub const SDL_JoystickType = enum_SDL_JoystickType;
//pub const SDL_JOYSTICK_CONNECTION_INVALID: c_int = -1;
//pub const SDL_JOYSTICK_CONNECTION_UNKNOWN: c_int = 0;
//pub const SDL_JOYSTICK_CONNECTION_WIRED: c_int = 1;
//pub const SDL_JOYSTICK_CONNECTION_WIRELESS: c_int = 2;
//pub const enum_SDL_JoystickConnectionState = c_int;
//pub const SDL_JoystickConnectionState = enum_SDL_JoystickConnectionState;
pub const JoystickConnectionState = enum(c_uint) {
    invalid = -1,
    unknown = 0,
    wired = 1,
    wireless = 2,
};
//pub extern fn SDL_LockJoysticks() void;
pub extern fn SDL_LockJoysticks() void;
pub const lockJoysticks = SDL_LockJoysticks;
//pub extern fn SDL_UnlockJoysticks() void;
pub extern fn SDL_UnlockJoysticks() void;
pub const unlockJoysticks = SDL_UnlockJoysticks;
//pub extern fn SDL_HasJoystick() SDL_bool;
pub extern fn SDL_HasJoystick() bool;
pub const hasJoystick = SDL_HasJoystick;
//pub extern fn SDL_GetJoysticks(count: [*c]c_int) [*c]SDL_JoystickID;
pub extern fn SDL_GetJoysticks(count: [*c]c_int) [*c]JoystickID;
pub const getJoysticks = SDL_GetJoysticks;
//pub extern fn SDL_GetJoystickNameForID(instance_id: SDL_JoystickID) [*c]const u8;
pub extern fn SDL_GetJoystickNameForID(instance_id: JoystickID) [*c]const u8;
pub const getJoystickNameForID = SDL_GetJoystickNameForID;
//pub extern fn SDL_GetJoystickPathForID(instance_id: SDL_JoystickID) [*c]const u8;
pub extern fn SDL_GetJoystickPathForID(instance_id: JoystickID) [*c]const u8;
pub const getJoystickPathForID = SDL_GetJoystickPathForID;
//pub extern fn SDL_GetJoystickPlayerIndexForID(instance_id: SDL_JoystickID) c_int;
pub extern fn SDL_GetJoystickPlayerIndexForID(instance_id: JoystickID) c_int;
pub const getJoystickPlayerIndexForID = SDL_GetJoystickPlayerIndexForID;
//pub extern fn SDL_GetJoystickGUIDForID(instance_id: SDL_JoystickID) SDL_GUID;
pub extern fn SDL_GetJoystickGUIDForID(instance_id: JoystickID) Guid;
pub const getJoystickGUIDForID = SDL_GetJoystickGUIDForID;
//pub extern fn SDL_GetJoystickVendorForID(instance_id: SDL_JoystickID) Uint16;
pub extern fn SDL_GetJoystickVendorForID(instance_id: JoystickID) u16;
pub const getJoystickVendorForID = SDL_GetJoystickVendorForID;
//pub extern fn SDL_GetJoystickProductForID(instance_id: SDL_JoystickID) Uint16;
pub extern fn SDL_GetJoystickProductForID(instance_id: JoystickID) u16;
pub const getJoystickProductForID = SDL_GetJoystickProductForID;
//pub extern fn SDL_GetJoystickProductVersionForID(instance_id: SDL_JoystickID) Uint16;
pub extern fn SDL_GetJoystickProductVersionForID(instance_id: JoystickID) u16;
pub const getJoystickProductVersionForID = SDL_GetJoystickProductVersionForID;
//pub extern fn SDL_GetJoystickTypeForID(instance_id: SDL_JoystickID) SDL_JoystickType;
pub extern fn SDL_GetJoystickTypeForID(instance_id: JoystickID) JoystickType;
pub const getJoystickTypeForID = SDL_GetJoystickTypeForID;
//pub extern fn SDL_OpenJoystick(instance_id: SDL_JoystickID) ?*SDL_Joystick;
pub extern fn SDL_OpenJoystick(instance_id: JoystickID) ?*Joystick;
pub const openJoystick = SDL_OpenJoystick;
//pub extern fn SDL_GetJoystickFromID(instance_id: SDL_JoystickID) ?*SDL_Joystick;
pub extern fn SDL_GetJoystickFromID(instance_id: JoystickID) ?*Joystick;
pub const getJoystickFromID = SDL_GetJoystickFromID;
//pub extern fn SDL_GetJoystickFromPlayerIndex(player_index: c_int) ?*SDL_Joystick;
pub extern fn SDL_GetJoystickFromPlayerIndex(player_index: c_int) ?*Joystick;
pub const getJoystickFromPlayerIndex = SDL_GetJoystickFromPlayerIndex;
//pub const struct_SDL_VirtualJoystickTouchpadDesc = extern struct {
pub const VirtualJoystickTouchpadDesc = extern struct {
    //    nfingers: Uint16 = @import("std").mem.zeroes(Uint16),
    nfingers: u16 = @import("std").mem.zeroes(u16),
    //    padding: [3]Uint16 = @import("std").mem.zeroes([3]Uint16),
    padding: [3]u16 = @import("std").mem.zeroes([3]u16),
    //};
};
//pub const SDL_VirtualJoystickTouchpadDesc = struct_SDL_VirtualJoystickTouchpadDesc;
//pub const struct_SDL_VirtualJoystickSensorDesc = extern struct {
pub const VirtualJoystickSensorDesc = extern struct {
    //    type: SDL_SensorType = @import("std").mem.zeroes(SDL_SensorType),
    type: SensorType = @import("std").mem.zeroes(SensorType),
    //    rate: f32 = @import("std").mem.zeroes(f32),
    rate: f32 = @import("std").mem.zeroes(f32),
    //};
};
//pub const SDL_VirtualJoystickSensorDesc = struct_SDL_VirtualJoystickSensorDesc;
//pub const struct_SDL_VirtualJoystickDesc = extern struct {
pub const VirtualJoystickDesc = extern struct {
    //    version: Uint32 = @import("std").mem.zeroes(Uint32),
    version: u32 = @import("std").mem.zeroes(u32),
    //    type: Uint16 = @import("std").mem.zeroes(Uint16),
    type: u16 = @import("std").mem.zeroes(u16),
    //    padding: Uint16 = @import("std").mem.zeroes(Uint16),
    padding: u16 = @import("std").mem.zeroes(u16),
    //    vendor_id: Uint16 = @import("std").mem.zeroes(Uint16),
    vendor_id: u16 = @import("std").mem.zeroes(u16),
    //    product_id: Uint16 = @import("std").mem.zeroes(Uint16),
    product_id: u16 = @import("std").mem.zeroes(u16),
    //    naxes: Uint16 = @import("std").mem.zeroes(Uint16),
    naxes: u16 = @import("std").mem.zeroes(u16),
    //    nbuttons: Uint16 = @import("std").mem.zeroes(Uint16),
    nbuttons: u16 = @import("std").mem.zeroes(u16),
    //    nballs: Uint16 = @import("std").mem.zeroes(Uint16),
    nballs: u16 = @import("std").mem.zeroes(u16),
    //    nhats: Uint16 = @import("std").mem.zeroes(Uint16),
    nhats: u16 = @import("std").mem.zeroes(u16),
    //    ntouchpads: Uint16 = @import("std").mem.zeroes(Uint16),
    ntouchpads: u16 = @import("std").mem.zeroes(u16),
    //    nsensors: Uint16 = @import("std").mem.zeroes(Uint16),
    nsensors: u16 = @import("std").mem.zeroes(u16),
    //    padding2: [2]Uint16 = @import("std").mem.zeroes([2]Uint16),
    padding2: [2]u16 = @import("std").mem.zeroes([2]u16),
    //    button_mask: Uint32 = @import("std").mem.zeroes(Uint32),
    button_mask: u32 = @import("std").mem.zeroes(u32),
    //    axis_mask: Uint32 = @import("std").mem.zeroes(Uint32),
    axis_mask: u32 = @import("std").mem.zeroes(u32),
    //    name: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    name: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    //    touchpads: [*c]const SDL_VirtualJoystickTouchpadDesc = @import("std").mem.zeroes([*c]const SDL_VirtualJoystickTouchpadDesc),
    touchpads: [*c]const VirtualJoystickTouchpadDesc = @import("std").mem.zeroes([*c]const VirtualJoystickTouchpadDesc),
    //    sensors: [*c]const SDL_VirtualJoystickSensorDesc = @import("std").mem.zeroes([*c]const SDL_VirtualJoystickSensorDesc),
    sensors: [*c]const VirtualJoystickSensorDesc = @import("std").mem.zeroes([*c]const VirtualJoystickSensorDesc),
    //    userdata: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    userdata: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    //    Update: ?*const fn (?*anyopaque) callconv(.C) void = @import("std").mem.zeroes(?*const fn (?*anyopaque) callconv(.C) void),
    update: ?*const fn (?*anyopaque) callconv(.C) void = @import("std").mem.zeroes(?*const fn (?*anyopaque) callconv(.C) void),
    //    SetPlayerIndex: ?*const fn (?*anyopaque, c_int) callconv(.C) void = @import("std").mem.zeroes(?*const fn (?*anyopaque, c_int) callconv(.C) void),
    setplayerindex: ?*const fn (?*anyopaque, c_int) callconv(.C) void = @import("std").mem.zeroes(?*const fn (?*anyopaque, c_int) callconv(.C) void),
    //    Rumble: ?*const fn (?*anyopaque, Uint16, Uint16) callconv(.C) SDL_bool = @import("std").mem.zeroes(?*const fn (?*anyopaque, Uint16, Uint16) callconv(.C) SDL_bool),
    rumble: ?*const fn (?*anyopaque, u16, u16) callconv(.C) bool = @import("std").mem.zeroes(?*const fn (?*anyopaque, u16, u16) callconv(.C) bool),
    //    RumbleTriggers: ?*const fn (?*anyopaque, Uint16, Uint16) callconv(.C) SDL_bool = @import("std").mem.zeroes(?*const fn (?*anyopaque, Uint16, Uint16) callconv(.C) SDL_bool),
    rumbletriggers: ?*const fn (?*anyopaque, u16, u16) callconv(.C) bool = @import("std").mem.zeroes(?*const fn (?*anyopaque, u16, u16) callconv(.C) bool),
    //    SetLED: ?*const fn (?*anyopaque, Uint8, Uint8, Uint8) callconv(.C) SDL_bool = @import("std").mem.zeroes(?*const fn (?*anyopaque, Uint8, Uint8, Uint8) callconv(.C) SDL_bool),
    setled: ?*const fn (?*anyopaque, u8, u8, u8) callconv(.C) bool = @import("std").mem.zeroes(?*const fn (?*anyopaque, u8, u8, u8) callconv(.C) bool),
    //    SendEffect: ?*const fn (?*anyopaque, ?*const anyopaque, c_int) callconv(.C) SDL_bool = @import("std").mem.zeroes(?*const fn (?*anyopaque, ?*const anyopaque, c_int) callconv(.C) SDL_bool),
    sendeffect: ?*const fn (?*anyopaque, ?*const anyopaque, c_int) callconv(.C) bool = @import("std").mem.zeroes(?*const fn (?*anyopaque, ?*const anyopaque, c_int) callconv(.C) bool),
    //    SetSensorsEnabled: ?*const fn (?*anyopaque, SDL_bool) callconv(.C) SDL_bool = @import("std").mem.zeroes(?*const fn (?*anyopaque, SDL_bool) callconv(.C) SDL_bool),
    setsensorsenabled: ?*const fn (?*anyopaque, bool) callconv(.C) bool = @import("std").mem.zeroes(?*const fn (?*anyopaque, bool) callconv(.C) bool),
    //    Cleanup: ?*const fn (?*anyopaque) callconv(.C) void = @import("std").mem.zeroes(?*const fn (?*anyopaque) callconv(.C) void),
    cleanup: ?*const fn (?*anyopaque) callconv(.C) void = @import("std").mem.zeroes(?*const fn (?*anyopaque) callconv(.C) void),
    //};
};
//pub const SDL_VirtualJoystickDesc = struct_SDL_VirtualJoystickDesc;
//// ./include/SDL3/SDL_stdinc.h:561:42: warning: ignoring StaticAssert declaration
//pub extern fn SDL_AttachVirtualJoystick(desc: [*c]const SDL_VirtualJoystickDesc) SDL_JoystickID;
pub extern fn SDL_AttachVirtualJoystick(desc: [*c]const VirtualJoystickDesc) JoystickID;
pub const attachVirtualJoystick = SDL_AttachVirtualJoystick;
//pub extern fn SDL_DetachVirtualJoystick(instance_id: SDL_JoystickID) SDL_bool;
pub extern fn SDL_DetachVirtualJoystick(instance_id: JoystickID) bool;
pub const detachVirtualJoystick = SDL_DetachVirtualJoystick;
//pub extern fn SDL_IsJoystickVirtual(instance_id: SDL_JoystickID) SDL_bool;
pub extern fn SDL_IsJoystickVirtual(instance_id: JoystickID) bool;
pub const isJoystickVirtual = SDL_IsJoystickVirtual;
//pub extern fn SDL_SetJoystickVirtualAxis(joystick: ?*SDL_Joystick, axis: c_int, value: Sint16) SDL_bool;
pub extern fn SDL_SetJoystickVirtualAxis(joystick: ?*Joystick, axis: c_int, value: i16) bool;
pub const setJoystickVirtualAxis = SDL_SetJoystickVirtualAxis;
//pub extern fn SDL_SetJoystickVirtualBall(joystick: ?*SDL_Joystick, ball: c_int, xrel: Sint16, yrel: Sint16) SDL_bool;
pub extern fn SDL_SetJoystickVirtualBall(joystick: ?*Joystick, ball: c_int, xrel: i16, yrel: i16) bool;
pub const setJoystickVirtualBall = SDL_SetJoystickVirtualBall;
//pub extern fn SDL_SetJoystickVirtualButton(joystick: ?*SDL_Joystick, button: c_int, down: SDL_bool) SDL_bool;
pub extern fn SDL_SetJoystickVirtualButton(joystick: ?*Joystick, button: c_int, down: bool) bool;
pub const setJoystickVirtualButton = SDL_SetJoystickVirtualButton;
//pub extern fn SDL_SetJoystickVirtualHat(joystick: ?*SDL_Joystick, hat: c_int, value: Uint8) SDL_bool;
pub extern fn SDL_SetJoystickVirtualHat(joystick: ?*Joystick, hat: c_int, value: u8) bool;
pub const setJoystickVirtualHat = SDL_SetJoystickVirtualHat;
//pub extern fn SDL_SetJoystickVirtualTouchpad(joystick: ?*SDL_Joystick, touchpad: c_int, finger: c_int, down: SDL_bool, x: f32, y: f32, pressure: f32) SDL_bool;
pub extern fn SDL_SetJoystickVirtualTouchpad(joystick: ?*Joystick, touchpad: c_int, finger: c_int, down: bool, x: f32, y: f32, pressure: f32) bool;
pub const setJoystickVirtualTouchpad = SDL_SetJoystickVirtualTouchpad;
//pub extern fn SDL_SendJoystickVirtualSensorData(joystick: ?*SDL_Joystick, @"type": SDL_SensorType, sensor_timestamp: Uint64, data: [*c]const f32, num_values: c_int) SDL_bool;
pub extern fn SDL_SendJoystickVirtualSensorData(joystick: ?*Joystick, @"type": SensorType, sensor_timestamp: u64, data: [*c]const f32, num_values: c_int) bool;
pub const sendJoystickVirtualSensorData = SDL_SendJoystickVirtualSensorData;
//pub extern fn SDL_GetJoystickProperties(joystick: ?*SDL_Joystick) SDL_PropertiesID;
pub extern fn SDL_GetJoystickProperties(joystick: ?*Joystick) PropertiesID;
pub const getJoystickProperties = SDL_GetJoystickProperties;
//pub extern fn SDL_GetJoystickName(joystick: ?*SDL_Joystick) [*c]const u8;
pub extern fn SDL_GetJoystickName(joystick: ?*Joystick) [*c]const u8;
pub const getJoystickName = SDL_GetJoystickName;
//pub extern fn SDL_GetJoystickPath(joystick: ?*SDL_Joystick) [*c]const u8;
pub extern fn SDL_GetJoystickPath(joystick: ?*Joystick) [*c]const u8;
pub const getJoystickPath = SDL_GetJoystickPath;
//pub extern fn SDL_GetJoystickPlayerIndex(joystick: ?*SDL_Joystick) c_int;
pub extern fn SDL_GetJoystickPlayerIndex(joystick: ?*Joystick) c_int;
pub const getJoystickPlayerIndex = SDL_GetJoystickPlayerIndex;
//pub extern fn SDL_SetJoystickPlayerIndex(joystick: ?*SDL_Joystick, player_index: c_int) SDL_bool;
pub extern fn SDL_SetJoystickPlayerIndex(joystick: ?*Joystick, player_index: c_int) bool;
pub const setJoystickPlayerIndex = SDL_SetJoystickPlayerIndex;
//pub extern fn SDL_GetJoystickGUID(joystick: ?*SDL_Joystick) SDL_GUID;
pub extern fn SDL_GetJoystickGUID(joystick: ?*Joystick) Guid;
pub const getJoystickGUID = SDL_GetJoystickGUID;
//pub extern fn SDL_GetJoystickVendor(joystick: ?*SDL_Joystick) Uint16;
pub extern fn SDL_GetJoystickVendor(joystick: ?*Joystick) u16;
pub const getJoystickVendor = SDL_GetJoystickVendor;
//pub extern fn SDL_GetJoystickProduct(joystick: ?*SDL_Joystick) Uint16;
pub extern fn SDL_GetJoystickProduct(joystick: ?*Joystick) u16;
pub const getJoystickProduct = SDL_GetJoystickProduct;
//pub extern fn SDL_GetJoystickProductVersion(joystick: ?*SDL_Joystick) Uint16;
pub extern fn SDL_GetJoystickProductVersion(joystick: ?*Joystick) u16;
pub const getJoystickProductVersion = SDL_GetJoystickProductVersion;
//pub extern fn SDL_GetJoystickFirmwareVersion(joystick: ?*SDL_Joystick) Uint16;
pub extern fn SDL_GetJoystickFirmwareVersion(joystick: ?*Joystick) u16;
pub const getJoystickFirmwareVersion = SDL_GetJoystickFirmwareVersion;
//pub extern fn SDL_GetJoystickSerial(joystick: ?*SDL_Joystick) [*c]const u8;
pub extern fn SDL_GetJoystickSerial(joystick: ?*Joystick) [*c]const u8;
pub const getJoystickSerial = SDL_GetJoystickSerial;
//pub extern fn SDL_GetJoystickType(joystick: ?*SDL_Joystick) SDL_JoystickType;
pub extern fn SDL_GetJoystickType(joystick: ?*Joystick) JoystickType;
pub const getJoystickType = SDL_GetJoystickType;
//pub extern fn SDL_GetJoystickGUIDInfo(guid: SDL_GUID, vendor: [*c]Uint16, product: [*c]Uint16, version: [*c]Uint16, crc16: [*c]Uint16) void;
pub extern fn SDL_GetJoystickGUIDInfo(guid: Guid, vendor: [*c]u16, product: [*c]u16, version: [*c]u16, crc16: [*c]u16) void;
pub const getJoystickGUIDInfo = SDL_GetJoystickGUIDInfo;
//pub extern fn SDL_JoystickConnected(joystick: ?*SDL_Joystick) SDL_bool;
pub extern fn SDL_JoystickConnected(joystick: ?*Joystick) bool;
pub const joystickConnected = SDL_JoystickConnected;
//pub extern fn SDL_GetJoystickID(joystick: ?*SDL_Joystick) SDL_JoystickID;
pub extern fn SDL_GetJoystickID(joystick: ?*Joystick) JoystickID;
pub const getJoystickID = SDL_GetJoystickID;
//pub extern fn SDL_GetNumJoystickAxes(joystick: ?*SDL_Joystick) c_int;
pub extern fn SDL_GetNumJoystickAxes(joystick: ?*Joystick) c_int;
pub const getNumJoystickAxes = SDL_GetNumJoystickAxes;
//pub extern fn SDL_GetNumJoystickBalls(joystick: ?*SDL_Joystick) c_int;
pub extern fn SDL_GetNumJoystickBalls(joystick: ?*Joystick) c_int;
pub const getNumJoystickBalls = SDL_GetNumJoystickBalls;
//pub extern fn SDL_GetNumJoystickHats(joystick: ?*SDL_Joystick) c_int;
pub extern fn SDL_GetNumJoystickHats(joystick: ?*Joystick) c_int;
pub const getNumJoystickHats = SDL_GetNumJoystickHats;
//pub extern fn SDL_GetNumJoystickButtons(joystick: ?*SDL_Joystick) c_int;
pub extern fn SDL_GetNumJoystickButtons(joystick: ?*Joystick) c_int;
pub const getNumJoystickButtons = SDL_GetNumJoystickButtons;
//pub extern fn SDL_SetJoystickEventsEnabled(enabled: SDL_bool) void;
pub extern fn SDL_SetJoystickEventsEnabled(enabled: bool) void;
pub const setJoystickEventsEnabled = SDL_SetJoystickEventsEnabled;
//pub extern fn SDL_JoystickEventsEnabled() SDL_bool;
pub extern fn SDL_JoystickEventsEnabled() bool;
pub const joystickEventsEnabled = SDL_JoystickEventsEnabled;
//pub extern fn SDL_UpdateJoysticks() void;
pub extern fn SDL_UpdateJoysticks() void;
pub const updateJoysticks = SDL_UpdateJoysticks;
//pub extern fn SDL_GetJoystickAxis(joystick: ?*SDL_Joystick, axis: c_int) Sint16;
pub extern fn SDL_GetJoystickAxis(joystick: ?*Joystick, axis: c_int) i16;
pub const getJoystickAxis = SDL_GetJoystickAxis;
//pub extern fn SDL_GetJoystickAxisInitialState(joystick: ?*SDL_Joystick, axis: c_int, state: [*c]Sint16) SDL_bool;
pub extern fn SDL_GetJoystickAxisInitialState(joystick: ?*Joystick, axis: c_int, state: [*c]i16) bool;
pub const getJoystickAxisInitialState = SDL_GetJoystickAxisInitialState;
//pub extern fn SDL_GetJoystickBall(joystick: ?*SDL_Joystick, ball: c_int, dx: [*c]c_int, dy: [*c]c_int) SDL_bool;
pub extern fn SDL_GetJoystickBall(joystick: ?*Joystick, ball: c_int, dx: [*c]c_int, dy: [*c]c_int) bool;
pub const getJoystickBall = SDL_GetJoystickBall;
//pub extern fn SDL_GetJoystickHat(joystick: ?*SDL_Joystick, hat: c_int) Uint8;
pub extern fn SDL_GetJoystickHat(joystick: ?*Joystick, hat: c_int) u8;
pub const getJoystickHat = SDL_GetJoystickHat;
//pub extern fn SDL_GetJoystickButton(joystick: ?*SDL_Joystick, button: c_int) SDL_bool;
pub extern fn SDL_GetJoystickButton(joystick: ?*Joystick, button: c_int) bool;
pub const getJoystickButton = SDL_GetJoystickButton;
//pub extern fn SDL_RumbleJoystick(joystick: ?*SDL_Joystick, low_frequency_rumble: Uint16, high_frequency_rumble: Uint16, duration_ms: Uint32) SDL_bool;
pub extern fn SDL_RumbleJoystick(joystick: ?*Joystick, low_frequency_rumble: u16, high_frequency_rumble: u16, duration_ms: u32) bool;
pub const rumbleJoystick = SDL_RumbleJoystick;
//pub extern fn SDL_RumbleJoystickTriggers(joystick: ?*SDL_Joystick, left_rumble: Uint16, right_rumble: Uint16, duration_ms: Uint32) SDL_bool;
pub extern fn SDL_RumbleJoystickTriggers(joystick: ?*Joystick, left_rumble: u16, right_rumble: u16, duration_ms: u32) bool;
pub const rumbleJoystickTriggers = SDL_RumbleJoystickTriggers;
//pub extern fn SDL_SetJoystickLED(joystick: ?*SDL_Joystick, red: Uint8, green: Uint8, blue: Uint8) SDL_bool;
pub extern fn SDL_SetJoystickLED(joystick: ?*Joystick, red: u8, green: u8, blue: u8) bool;
pub const setJoystickLED = SDL_SetJoystickLED;
//pub extern fn SDL_SendJoystickEffect(joystick: ?*SDL_Joystick, data: ?*const anyopaque, size: c_int) SDL_bool;
pub extern fn SDL_SendJoystickEffect(joystick: ?*Joystick, data: ?*const anyopaque, size: c_int) bool;
pub const sendJoystickEffect = SDL_SendJoystickEffect;
//pub extern fn SDL_CloseJoystick(joystick: ?*SDL_Joystick) void;
pub extern fn SDL_CloseJoystick(joystick: ?*Joystick) void;
pub const closeJoystick = SDL_CloseJoystick;
//pub extern fn SDL_GetJoystickConnectionState(joystick: ?*SDL_Joystick) SDL_JoystickConnectionState;
pub extern fn SDL_GetJoystickConnectionState(joystick: ?*Joystick) JoystickConnectionState;
pub const getJoystickConnectionState = SDL_GetJoystickConnectionState;
//pub extern fn SDL_GetJoystickPowerInfo(joystick: ?*SDL_Joystick, percent: [*c]c_int) SDL_PowerState;
pub extern fn SDL_GetJoystickPowerInfo(joystick: ?*Joystick, percent: [*c]c_int) PowerState;
pub const getJoystickPowerInfo = SDL_GetJoystickPowerInfo;
