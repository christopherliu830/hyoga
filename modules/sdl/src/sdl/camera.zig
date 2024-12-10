const PixelFormat = @import("pixels.zig").PixelFormat;
const Colorspace = @import("pixels.zig").Colorspace;
const PropertiesID = @import("properties.zig").PropertiesID;
const Surface = @import("surface.zig").Surface;

//pub const SDL_CameraID = Uint32;
pub const CameraID = u32;
pub const Camera = opaque {};

pub const CameraSpec = extern struct {
	format: PixelFormat = @import("std").mem.zeroes(PixelFormat),
	colorspace: Colorspace = @import("std").mem.zeroes(Colorspace),
	width: c_int = @import("std").mem.zeroes(c_int),
	height: c_int = @import("std").mem.zeroes(c_int),
	framerate_numerator: c_int = @import("std").mem.zeroes(c_int),
	framerate_denominator: c_int = @import("std").mem.zeroes(c_int),
};
pub const CameraPosition = enum (c_uint) {
	unknown,
	front_facing,
	back_facing,
};

pub extern fn SDL_GetNumCameraDrivers() c_int;
pub const getNumDrivers = SDL_GetNumCameraDrivers;
pub extern fn SDL_GetCameraDriver(index: c_int) [*c]const u8;
pub const getDriver = SDL_GetCameraDriver;
pub extern fn SDL_GetCurrentCameraDriver() [*c]const u8;
pub const getCurrentDriver = SDL_GetCurrentCameraDriver;
pub extern fn SDL_GetCameras(count: [*c]c_int) [*c]CameraID;
pub const gets = SDL_GetCameras;
pub extern fn SDL_GetCameraSupportedFormats(devid: CameraID, count: [*c]c_int) [*c][*c]CameraSpec;
pub const getSupportedFormats = SDL_GetCameraSupportedFormats;
pub extern fn SDL_GetCameraName(instance_id: CameraID) [*c]const u8;
pub const getName = SDL_GetCameraName;
pub extern fn SDL_GetCameraPosition(instance_id: CameraID) CameraPosition;
pub const getPosition = SDL_GetCameraPosition;
pub extern fn SDL_OpenCamera(instance_id: CameraID, spec: [*c]const CameraSpec) ?*Camera;
pub const open = SDL_OpenCamera;
pub extern fn SDL_GetCameraPermissionState(camera: ?*Camera) c_int;
pub const getPermissionState = SDL_GetCameraPermissionState;
pub extern fn SDL_GetCameraID(camera: ?*Camera) CameraID;
pub const getID = SDL_GetCameraID;
pub extern fn SDL_GetCameraProperties(camera: ?*Camera) PropertiesID;
pub const getProperties = SDL_GetCameraProperties;
pub extern fn SDL_GetCameraFormat(camera: ?*Camera, spec: [*c]CameraSpec) bool;
pub const getFormat = SDL_GetCameraFormat;
pub extern fn SDL_AcquireCameraFrame(camera: ?*Camera, timestampNS: [*c]u64) [*c]Surface;
pub const acquireFrame = SDL_AcquireCameraFrame;
pub extern fn SDL_ReleaseCameraFrame(camera: ?*Camera, frame: [*c]Surface) void;
pub const releaseFrame = SDL_ReleaseCameraFrame;
pub extern fn SDL_CloseCamera(camera: ?*Camera) void;
pub const close = SDL_CloseCamera;
