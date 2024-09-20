pub const TouchID = u32;

pub const FingerID = u32;

pub const DeviceType = enum (c_uint) {
	invalid = -1,
	direct = 0,
	indirect_absolute = 1,
	indirect_relative = 2,
};

pub const Finger = extern struct {
	id: FingerID = @import("std").mem.zeroes(FingerID),
	x: f32 = @import("std").mem.zeroes(f32),
	y: f32 = @import("std").mem.zeroes(f32),
	pressure: f32 = @import("std").mem.zeroes(f32),
};

pub extern fn SDL_GetTouchDevices(count: [*c]c_int) [*c]TouchID;
pub const getTouchDevices = SDL_GetTouchDevices;

pub extern fn SDL_GetTouchDeviceName(touchID: TouchID) [*c]const u8;
pub const getTouchDeviceName = SDL_GetTouchDeviceName;

pub extern fn SDL_GetTouchDeviceType(touchID: TouchID) DeviceType;
pub const getTouchDeviceType = SDL_GetTouchDeviceType;

pub extern fn SDL_GetTouchFingers(touchID: TouchID, count: [*c]c_int) [*c][*c]Finger;
pub const getTouchFingers = SDL_GetTouchFingers;
