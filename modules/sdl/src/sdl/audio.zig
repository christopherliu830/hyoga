const PropertiesID = @import("properties.zig").PropertiesID;
const IOStream = @import("iostream.zig").IOStream;

pub const Format = enum(c_uint) {
    unknown = 0,
    u8 = 8,
    s8 = 32776,
    s16le = 32784,
    s16be = 36880,
    s32le = 32800,
    s32be = 36896,
    f32le = 33056,
    f32be = 37152,
    s16 = 32784,
    s32 = 32800,
    f32 = 33056,
};

pub const DeviceID = u32;
pub const Spec = extern struct {
    format: Format = @import("std").mem.zeroes(Format),
    channels: c_int = @import("std").mem.zeroes(c_int),
    freq: c_int = @import("std").mem.zeroes(c_int),
};
pub const Stream = opaque {};

pub extern fn SDL_GetNumAudioDrivers() c_int;
pub const getNumDrivers = SDL_GetNumAudioDrivers;
pub extern fn SDL_GetAudioDriver(index: c_int) [*c]const u8;
pub const getDriver = SDL_GetAudioDriver;
pub extern fn SDL_GetCurrentAudioDriver() [*c]const u8;
pub const getCurrentDriver = SDL_GetCurrentAudioDriver;
pub extern fn SDL_GetAudioPlaybackDevices(count: [*c]c_int) [*c]DeviceID;
pub const getPlaybackDevices = SDL_GetAudioPlaybackDevices;
pub extern fn SDL_GetAudioRecordingDevices(count: [*c]c_int) [*c]DeviceID;
pub const getRecordingDevices = SDL_GetAudioRecordingDevices;
pub extern fn SDL_GetAudioDeviceName(devid: DeviceID) [*c]const u8;
pub const getDeviceName = SDL_GetAudioDeviceName;
pub extern fn SDL_GetAudioDeviceFormat(devid: DeviceID, spec: [*c]Spec, sample_frames: [*c]c_int) bool;
pub const getDeviceFormat = SDL_GetAudioDeviceFormat;
pub extern fn SDL_GetAudioDeviceChannelMap(devid: DeviceID, count: [*c]c_int) [*c]c_int;
pub const getDeviceChannelMap = SDL_GetAudioDeviceChannelMap;
pub extern fn SDL_OpenAudioDevice(devid: DeviceID, spec: [*c]const Spec) DeviceID;
pub const openDevice = SDL_OpenAudioDevice;
pub extern fn SDL_PauseAudioDevice(dev: DeviceID) bool;
pub const pauseDevice = SDL_PauseAudioDevice;
pub extern fn SDL_ResumeAudioDevice(dev: DeviceID) bool;
pub const resumeDevice = SDL_ResumeAudioDevice;
pub extern fn SDL_AudioDevicePaused(dev: DeviceID) bool;
pub const devicePaused = SDL_AudioDevicePaused;
pub extern fn SDL_GetAudioDeviceGain(devid: DeviceID) f32;
pub const getDeviceGain = SDL_GetAudioDeviceGain;
pub extern fn SDL_SetAudioDeviceGain(devid: DeviceID, gain: f32) bool;
pub const setDeviceGain = SDL_SetAudioDeviceGain;
pub extern fn SDL_CloseAudioDevice(devid: DeviceID) void;
pub const closeDevice = SDL_CloseAudioDevice;
pub extern fn SDL_BindAudioStreams(devid: DeviceID, streams: [*c]?*Stream, num_streams: c_int) bool;
pub const bindStreams = SDL_BindAudioStreams;
pub extern fn SDL_BindAudioStream(devid: DeviceID, stream: ?*Stream) bool;
pub const bindStream = SDL_BindAudioStream;
pub extern fn SDL_UnbindAudioStreams(streams: [*c]?*Stream, num_streams: c_int) void;
pub const unbindStreams = SDL_UnbindAudioStreams;
pub extern fn SDL_UnbindAudioStream(stream: ?*Stream) void;
pub const unbindStream = SDL_UnbindAudioStream;
pub extern fn SDL_GetAudioStreamDevice(stream: ?*Stream) DeviceID;
pub const getStreamDevice = SDL_GetAudioStreamDevice;
pub extern fn SDL_CreateAudioStream(src_spec: [*c]const Spec, dst_spec: [*c]const Spec) ?*Stream;
pub const createStream = SDL_CreateAudioStream;
pub extern fn SDL_GetAudioStreamProperties(stream: ?*Stream) PropertiesID;
pub const getStreamProperties = SDL_GetAudioStreamProperties;
pub extern fn SDL_GetAudioStreamFormat(stream: ?*Stream, src_spec: [*c]Spec, dst_spec: [*c]Spec) bool;
pub const getStreamFormat = SDL_GetAudioStreamFormat;
pub extern fn SDL_SetAudioStreamFormat(stream: ?*Stream, src_spec: [*c]const Spec, dst_spec: [*c]const Spec) bool;
pub const setStreamFormat = SDL_SetAudioStreamFormat;
pub extern fn SDL_GetAudioStreamFrequencyRatio(stream: ?*Stream) f32;
pub const getStreamFrequencyRatio = SDL_GetAudioStreamFrequencyRatio;
pub extern fn SDL_SetAudioStreamFrequencyRatio(stream: ?*Stream, ratio: f32) bool;
pub const setStreamFrequencyRatio = SDL_SetAudioStreamFrequencyRatio;
pub extern fn SDL_GetAudioStreamGain(stream: ?*Stream) f32;
pub const getStreamGain = SDL_GetAudioStreamGain;
pub extern fn SDL_SetAudioStreamGain(stream: ?*Stream, gain: f32) bool;
pub const setStreamGain = SDL_SetAudioStreamGain;
pub extern fn SDL_GetAudioStreamInputChannelMap(stream: ?*Stream, count: [*c]c_int) [*c]c_int;
pub const getStreamInputChannelMap = SDL_GetAudioStreamInputChannelMap;
pub extern fn SDL_GetAudioStreamOutputChannelMap(stream: ?*Stream, count: [*c]c_int) [*c]c_int;
pub const getStreamOutputChannelMap = SDL_GetAudioStreamOutputChannelMap;
pub extern fn SDL_SetAudioStreamInputChannelMap(stream: ?*Stream, chmap: [*c]const c_int, count: c_int) bool;
pub const setStreamInputChannelMap = SDL_SetAudioStreamInputChannelMap;
pub extern fn SDL_SetAudioStreamOutputChannelMap(stream: ?*Stream, chmap: [*c]const c_int, count: c_int) bool;
pub const setStreamOutputChannelMap = SDL_SetAudioStreamOutputChannelMap;
pub extern fn SDL_PutAudioStreamData(stream: ?*Stream, buf: ?*const anyopaque, len: c_int) bool;
pub const putStreamData = SDL_PutAudioStreamData;
pub extern fn SDL_GetAudioStreamData(stream: ?*Stream, buf: ?*anyopaque, len: c_int) c_int;
pub const getStreamData = SDL_GetAudioStreamData;
pub extern fn SDL_GetAudioStreamAvailable(stream: ?*Stream) c_int;
pub const getStreamAvailable = SDL_GetAudioStreamAvailable;
pub extern fn SDL_GetAudioStreamQueued(stream: ?*Stream) c_int;
pub const getStreamQueued = SDL_GetAudioStreamQueued;
pub extern fn SDL_FlushAudioStream(stream: ?*Stream) bool;
pub const flushStream = SDL_FlushAudioStream;
pub extern fn SDL_ClearAudioStream(stream: ?*Stream) bool;
pub const clearStream = SDL_ClearAudioStream;
pub extern fn SDL_PauseAudioStreamDevice(stream: ?*Stream) bool;
pub const pauseStreamDevice = SDL_PauseAudioStreamDevice;
pub extern fn SDL_ResumeAudioStreamDevice(stream: ?*Stream) bool;
pub const resumeStreamDevice = SDL_ResumeAudioStreamDevice;
pub extern fn SDL_LockAudioStream(stream: ?*Stream) bool;
pub const lockStream = SDL_LockAudioStream;
pub extern fn SDL_UnlockAudioStream(stream: ?*Stream) bool;
pub const unlockStream = SDL_UnlockAudioStream;
pub const StreamCallback = ?*const fn (?*anyopaque, ?*Stream, c_int, c_int) callconv(.C) void;
pub extern fn SDL_SetAudioStreamGetCallback(stream: ?*Stream, callback: StreamCallback, userdata: ?*anyopaque) bool;
pub const setStreamGetCallback = SDL_SetAudioStreamGetCallback;
pub extern fn SDL_SetAudioStreamPutCallback(stream: ?*Stream, callback: StreamCallback, userdata: ?*anyopaque) bool;
pub const setStreamPutCallback = SDL_SetAudioStreamPutCallback;
pub extern fn SDL_DestroyAudioStream(stream: ?*Stream) void;
pub const destroyStream = SDL_DestroyAudioStream;
pub extern fn SDL_OpenAudioDeviceStream(devid: DeviceID, spec: [*c]const Spec, callback: StreamCallback, userdata: ?*anyopaque) ?*Stream;
pub const openDeviceStream = SDL_OpenAudioDeviceStream;
pub const PostmixCallback = ?*const fn (?*anyopaque, [*c]const Spec, [*c]f32, c_int) callconv(.C) void;
pub extern fn SDL_SetAudioPostmixCallback(devid: DeviceID, callback: PostmixCallback, userdata: ?*anyopaque) bool;
pub const setPostmixCallback = SDL_SetAudioPostmixCallback;
pub extern fn SDL_LoadWAV_IO(src: ?*IOStream, closeio: bool, spec: [*c]Spec, audio_buf: [*c][*c]u8, audio_len: [*c]u32) bool;
pub const loadWAV_IO = SDL_LoadWAV_IO;
pub extern fn SDL_LoadWAV(path: [*c]const u8, spec: [*c]Spec, audio_buf: [*c][*c]u8, audio_len: [*c]u32) bool;
pub const loadWAV = SDL_LoadWAV;
pub extern fn SDL_MixAudio(dst: [*c]u8, src: [*c]const u8, format: Format, len: u32, volume: f32) bool;
pub const mix = SDL_MixAudio;
pub extern fn SDL_ConvertAudioSamples(src_spec: [*c]const Spec, src_data: [*c]const u8, src_len: c_int, dst_spec: [*c]const Spec, dst_data: [*c][*c]u8, dst_len: [*c]c_int) bool;
pub const convertSamples = SDL_ConvertAudioSamples;
pub extern fn SDL_GetAudioFormatName(format: Format) [*c]const u8;
pub const getFormatName = SDL_GetAudioFormatName;
pub extern fn SDL_GetSilenceValueForFormat(format: Format) c_int;
pub const getSilenceValueForFormat = SDL_GetSilenceValueForFormat;
