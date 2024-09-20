const PixelFormat = @import("pixels.zig").PixelFormat;
const Colorspace = @import("pixels.zig").Colorspace;
const PropertiesID = @import("properties.zig").PropertiesID;
const Surface = @import("surface.zig").Surface;

//pub const SDL_CameraID = Uint32;
pub const CameraID = u32;
//pub const struct_SDL_Camera = opaque {};
pub const Camera = opaque {};

//pub const SDL_Camera = struct_SDL_Camera;
//pub const struct_SDL_CameraSpec = extern struct {
pub const CameraSpec = extern struct {
//    format: SDL_PixelFormat = @import("std").mem.zeroes(SDL_PixelFormat),
	format: PixelFormat = @import("std").mem.zeroes(PixelFormat),
//    colorspace: SDL_Colorspace = @import("std").mem.zeroes(SDL_Colorspace),
	colorspace: Colorspace = @import("std").mem.zeroes(Colorspace),
//    width: c_int = @import("std").mem.zeroes(c_int),
	width: c_int = @import("std").mem.zeroes(c_int),
//    height: c_int = @import("std").mem.zeroes(c_int),
	height: c_int = @import("std").mem.zeroes(c_int),
//    framerate_numerator: c_int = @import("std").mem.zeroes(c_int),
	framerate_numerator: c_int = @import("std").mem.zeroes(c_int),
//    framerate_denominator: c_int = @import("std").mem.zeroes(c_int),
	framerate_denominator: c_int = @import("std").mem.zeroes(c_int),
//};
};
//pub const SDL_CameraSpec = struct_SDL_CameraSpec;
//pub const SDL_CAMERA_POSITION_UNKNOWN: c_int = 0;
//pub const SDL_CAMERA_POSITION_FRONT_FACING: c_int = 1;
//pub const SDL_CAMERA_POSITION_BACK_FACING: c_int = 2;
//pub const enum_SDL_CameraPosition = c_uint;
pub const CameraPosition = enum (c_uint) {
	unknown,
	front_facing,
	back_facing,
};

//pub const SDL_CameraPosition = enum_SDL_CameraPosition;
//pub extern fn SDL_GetNumCameraDrivers() c_int;
pub extern fn SDL_GetNumCameraDrivers() c_int;
pub const getNumCameraDrivers = SDL_GetNumCameraDrivers;
//pub extern fn SDL_GetCameraDriver(index: c_int) [*c]const u8;
pub extern fn SDL_GetCameraDriver(index: c_int) [*c]const u8;
pub const getCameraDriver = SDL_GetCameraDriver;
//pub extern fn SDL_GetCurrentCameraDriver() [*c]const u8;
pub extern fn SDL_GetCurrentCameraDriver() [*c]const u8;
pub const getCurrentCameraDriver = SDL_GetCurrentCameraDriver;
//pub extern fn SDL_GetCameras(count: [*c]c_int) [*c]SDL_CameraID;
pub extern fn SDL_GetCameras(count: [*c]c_int) [*c]CameraID;
pub const getCameras = SDL_GetCameras;
//pub extern fn SDL_GetCameraSupportedFormats(devid: SDL_CameraID, count: [*c]c_int) [*c][*c]SDL_CameraSpec;
pub extern fn SDL_GetCameraSupportedFormats(devid: CameraID, count: [*c]c_int) [*c][*c]CameraSpec;
pub const getCameraSupportedFormats = SDL_GetCameraSupportedFormats;
//pub extern fn SDL_GetCameraName(instance_id: SDL_CameraID) [*c]const u8;
pub extern fn SDL_GetCameraName(instance_id: CameraID) [*c]const u8;
pub const getCameraName = SDL_GetCameraName;
//pub extern fn SDL_GetCameraPosition(instance_id: SDL_CameraID) SDL_CameraPosition;
pub extern fn SDL_GetCameraPosition(instance_id: CameraID) CameraPosition;
pub const getCameraPosition = SDL_GetCameraPosition;
//pub extern fn SDL_OpenCamera(instance_id: SDL_CameraID, spec: [*c]const SDL_CameraSpec) ?*SDL_Camera;
pub extern fn SDL_OpenCamera(instance_id: CameraID, spec: [*c]const CameraSpec) ?*Camera;
pub const openCamera = SDL_OpenCamera;
//pub extern fn SDL_GetCameraPermissionState(camera: ?*SDL_Camera) c_int;
pub extern fn SDL_GetCameraPermissionState(camera: ?*Camera) c_int;
pub const getCameraPermissionState = SDL_GetCameraPermissionState;
//pub extern fn SDL_GetCameraID(camera: ?*SDL_Camera) SDL_CameraID;
pub extern fn SDL_GetCameraID(camera: ?*Camera) CameraID;
pub const getCameraID = SDL_GetCameraID;
//pub extern fn SDL_GetCameraProperties(camera: ?*SDL_Camera) SDL_PropertiesID;
pub extern fn SDL_GetCameraProperties(camera: ?*Camera) PropertiesID;
pub const getCameraProperties = SDL_GetCameraProperties;
//pub extern fn SDL_GetCameraFormat(camera: ?*SDL_Camera, spec: [*c]SDL_CameraSpec) SDL_bool;
pub extern fn SDL_GetCameraFormat(camera: ?*Camera, spec: [*c]CameraSpec) bool;
pub const getCameraFormat = SDL_GetCameraFormat;
//pub extern fn SDL_AcquireCameraFrame(camera: ?*SDL_Camera, timestampNS: [*c]Uint64) [*c]SDL_Surface;
pub extern fn SDL_AcquireCameraFrame(camera: ?*Camera, timestampNS: [*c]u64) [*c]Surface;
pub const acquireCameraFrame = SDL_AcquireCameraFrame;
//pub extern fn SDL_ReleaseCameraFrame(camera: ?*SDL_Camera, frame: [*c]SDL_Surface) void;
pub extern fn SDL_ReleaseCameraFrame(camera: ?*Camera, frame: [*c]Surface) void;
pub const releaseCameraFrame = SDL_ReleaseCameraFrame;
//pub extern fn SDL_CloseCamera(camera: ?*SDL_Camera) void;
pub extern fn SDL_CloseCamera(camera: ?*Camera) void;
pub const closeCamera = SDL_CloseCamera;
