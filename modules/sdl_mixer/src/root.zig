const std = @import("std");
const sdl = @import("sdl");

pub const InitFlags = packed struct(u32) {
    flac: bool = false,
    mod: bool = false,
    mp3: bool = false,
    ogg: bool = false,
    mid: bool = false,
    opus: bool = false,
    wavpack: bool = false,
};

pub const AudioDeviceId = u32;

pub const AudioFormat = enum(c_int) {
    unknown = 0x0000, // < Unspecified audio format */
    u8 = 0x0008, // < Unsigned 8-bit samples */
    s8 = 0x8008, // < Signed 8-bit samples */
    s16le = 0x8010, // < Signed 16-bit samples */
    s16be = 0x9010, // < As above, but big-endian byte order */
    s32le = 0x8020, // < 32-bit integer samples */
    s32be = 0x9020, // < As above, but big-endian byte order */
    f32le = 0x8120, // < 32-bit floating point samples */
    f32be = 0x9120, // < As above, but big-endian byte order */

    pub const s16: AudioFormat = blk: {
        const target = @import("builtin").target.cpu.arch.endian();
        break :blk if (target == .big) .s16be else .s16le;
    };

    pub const s32: AudioFormat = blk: {
        const target = @import("builtin").target.cpu.arch.endian();
        break :blk if (target == .big) .s32be else .s32le;
    };

    pub const @"f32": AudioFormat = blk: {
        const target = @import("builtin").target.cpu.arch.endian();
        break :blk if (target == .big) .f32be else .f32le;
    };
};

/// The internal format for an audio chunk
///
pub const Chunk = struct {
    allocated: c_int,
    abuf: *u8,
    alen: u32,
    volume: u8, // Per-sample volume, 0-128
};

/// The different fading types supported
///
pub const Fading = enum(c_int) {
    none,
    out,
    in,
};

/// These are types of music files (not libraries used to load them)
///
pub const MusicType = enum(c_int) { none, wav, mod, mid, ogg, mp3, mp3_mad_unused, flac, modplug_unused, opus, wavpack, gme };

/// The internal format for a music chunk interpreted via codecs
///
pub const Music = opaque {};

/// Format specifier for audio data.
///
/// \since This struct is available since SDL 3.1.3.
///
/// \sa SDL_AudioFormat
///
const AudioSpec = struct {
    format: AudioFormat, // < Audio data format */
    channels: c_int, // < Number of channels: 1 mono, 2 stereo, etc */
    freq: c_int, // < sample rate: sample frames per second */
};

pub const MixChannel = enum(c_int) {
    /// Magic number for effects to operate on the postmix instead of a channel.
    post = -2,
    _,
};

// Environment variable that makes some mixing effects favor speed over
// quality.
// #define MIX_EFFECTSMAXSPEED  "MIX_EFFECTSMAXSPEED"
// TODO: Implement this

pub const MixCallback = *const fn (udata: ?*anyopaque, stream: [*]u8, len: c_int) callconv(.c) void;
pub const MusicFinishedCallback = *const fn () void;
pub const ChannelFinishedCallback = *const fn (channel: c_int) void;

/// This is the format of a special effect callback:
///
/// myeffect(int chan, void *stream, int len, void *udata);
///
/// (chan) is the channel number that your effect is affecting. (stream) is the
/// buffer of data to work upon. (len) is the size of (stream), and (udata) is
/// a user-defined bit of data, which you pass as the last arg of
/// Mix_RegisterEffect(), and is passed back unmolested to your callback. Your
/// effect changes the contents of (stream) based on whatever parameters are
/// significant, or just leaves it be, if you prefer. You can do whatever you
/// like to the buffer, though, and it will continue in its changed state down
/// the mixing pipeline, through any other effect functions, then finally to be
/// mixed with the rest of the channels and music for the final output stream.
///
pub const EffectFunc = *const fn (chan: c_int, stream: [*]u8, len: c_int, udata: ?*anyopaque) void;

/// This is a callback that signifies that a channel has finished all its loops
/// and has completed playback.
///
/// This gets called if the buffer plays out normally, or if you call
/// Mix_HaltChannel(), implicitly stop a channel via Mix_AllocateChannels(), or
/// unregister a callback while it's still playing.
///
pub const EffectDone = *const fn (chan: c_int, udata: ?*anyopaque) void;

/// Initialize SDL_mixer.
///
/// This function loads dynamic libraries that SDL_mixer needs, and prepares
/// them for use.
///
/// Note that, unlike other SDL libraries, this call is optional! If you load a
/// music file, SDL_mixer will handle initialization on the fly. This function
/// will let you know, up front, whether a specific format will be available
/// for use.
///
/// Flags should be one or more flags from MIX_InitFlags OR'd together. It
/// returns the flags successfully initialized, or 0 on failure.
///
/// Currently, these flags are:
///
/// - `MIX_INIT_FLAC`
/// - `MIX_INIT_MOD`
/// - `MIX_INIT_MP3`
/// - `MIX_INIT_OGG`
/// - `MIX_INIT_MID`
/// - `MIX_INIT_OPUS`
/// - `MIX_INIT_WAVPACK`
///
/// More flags may be added in a future SDL_mixer release.
///
/// This function may need to load external shared libraries to support various
/// codecs, which means this function can fail to initialize that support on an
/// otherwise-reasonable system if the library isn't available; this is not
/// just a question of exceptional circumstances like running out of memory at
/// startup!
///
/// Note that you may call this function more than once to initialize with
/// additional flags. The return value will reflect both new flags that
/// successfully initialized, and also include flags that had previously been
/// initialized as well.
///
/// As this will return previously-initialized flags, it's legal to call this
/// with zero (no flags set). This is a safe no-op that can be used to query
/// the current initialization state without changing it at all.
///
/// Since this returns previously-initialized flags as well as new ones, and
/// you can call this with zero, you should not check for a zero return value
/// to determine an error condition. Instead, you should check to make sure all
/// the flags you require are set in the return value. If you have a game with
/// data in a specific format, this might be a fatal error. If you're a generic
/// media player, perhaps you are fine with only having WAV and MP3 support and
/// can live without Opus playback, even if you request support for everything.
///
/// Unlike other SDL satellite libraries, calls to Mix_Init do not stack; a
/// single call to Mix_Quit() will deinitialize everything and does not have to
/// be paired with a matching Mix_Init call. For that reason, it's considered
/// best practices to have a single Mix_Init and Mix_Quit call in your program.
/// While this isn't required, be aware of the risks of deviating from that
/// behavior.
///
/// After initializing SDL_mixer, the next step is to open an audio device to
/// prepare to play sound (with Mix_OpenAudio()), and load audio data to play
/// with that device.
///
/// \param flags initialization flags, OR'd together.
/// \returns all currently initialized flags.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
/// \sa Mix_Quit
///
extern fn Mix_Init(flags: InitFlags) InitFlags;
pub const init = Mix_Init;

/// Deinitialize SDL_mixer.
///
/// This should be the last function you call in SDL_mixer, after freeing all
/// other resources and closing all audio devices. This will unload any shared
/// libraries it is using for various codecs.
///
/// After this call, a call to Mix_Init(0) will return 0 (no codecs loaded).
///
/// You can safely call Mix_Init() to reload various codec support after this
/// call.
///
/// Unlike other SDL satellite libraries, calls to Mix_Init do not stack; a
/// single call to Mix_Quit() will deinitialize everything and does not have to
/// be paired with a matching Mix_Init call. For that reason, it's considered
/// best practices to have a single Mix_Init and Mix_Quit call in your program.
/// While this isn't required, be aware of the risks of deviating from that
/// behavior.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
/// \sa Mix_Init
///
extern fn Mix_Quit() void;
pub const quit = Mix_Quit;

pub const channels = 8;

// Good default values for a PC soundcard
pub const default_frequency = 44100;
pub const default_format: sdl.audio.Format = .s16;
pub const default_channels = 2;
pub const max_volume = 128; // Volume of a chunk
//

/// Open an audio device for playback.
///
/// An audio device is what generates sound, so the app must open one to make
/// noise.
///
/// This function will check if SDL's audio system is initialized, and if not,
/// it will initialize it by calling `SDL_Init(SDL_INIT_AUDIO)` on your behalf.
/// You are free to (and encouraged to!) initialize it yourself before calling
/// this function, as this gives your program more control over the process.
///
/// If you aren't particularly concerned with the specifics of the audio
/// device, and your data isn't in a specific format, you can pass a NULL for
/// the `spec` parameter and SDL_mixer will choose a reasonable default.
/// SDL_mixer will convert audio data you feed it to the hardware's format
/// behind the scenes.
///
/// That being said, if you have control of your audio data and you know its
/// format ahead of time, you may save CPU time by opening the audio device in
/// that exact format so SDL_mixer does not have to spend time converting
/// anything behind the scenes, and can just pass the data straight through to
/// the hardware.
///
/// The other reason to care about specific formats: if you plan to touch the
/// mix buffer directly (with Mix_SetPostMix, a registered effect, or
/// Mix_HookMusic), you might have code that expects it to be in a specific
/// format, and you should specify that here.
///
/// This function allows you to select specific audio hardware on the system
/// with the `devid` parameter. If you specify 0, SDL_mixer will choose the
/// best default it can on your behalf (which, in many cases, is exactly what
/// you want anyhow). This is equivalent to specifying
/// `SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK`, but is less wordy. SDL_mixer does not
/// offer a mechanism to determine device IDs to open, but you can use
/// SDL_GetAudioOutputDevices() to get a list of available devices. If you do
/// this, be sure to call `SDL_Init(SDL_INIT_AUDIO)` first to initialize SDL's
/// audio system!
///
/// If this function reports success, you are ready to start making noise! Load
/// some audio data and start playing!
///
/// When done with an audio device, probably at the end of the program, the app
/// should close the audio with Mix_CloseAudio().
///
/// \param devid the device name to open, or 0 for a reasonable default.
/// \param spec the audio format you'd like SDL_mixer to work in.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
/// \sa Mix_CloseAudio
/// \sa Mix_QuerySpec
///
extern fn Mix_OpenAudio(devid: AudioDeviceId, spec: ?*const AudioSpec) bool;
pub const open = Mix_OpenAudio;

/// Suspend or resume the whole audio output.
///
/// \param pause_on 1 to pause audio output, or 0 to resume.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_PauseAudio(pause_on: c_int) void;
pub const pause = Mix_PauseAudio;

/// Find out what the actual audio device parameters are.
///
/// Note this is only important if the app intends to touch the audio buffers
/// being sent to the hardware directly. If an app just wants to play audio
/// files and let SDL_mixer handle the low-level details, this function can
/// probably be ignored.
///
/// If the audio device is not opened, this function will return 0.
///
/// \param frequency On return, will be filled with the audio device's
///                  frequency in Hz.
/// \param format On return, will be filled with the audio device's format.
/// \param channels On return, will be filled with the audio device's channel
///                 count.
/// \returns true if the audio device has been opened, false otherwise.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
/// \sa Mix_OpenAudio
///
extern fn Mix_QuerySpec(frequency: *c_int, format: *AudioFormat, channels: *c_int) bool;
pub const querySpec = Mix_QuerySpec;

/// Dynamically change the number of channels managed by the mixer.
///
/// SDL_mixer deals with "channels," which is not the same thing as the
/// mono/stereo channels; they might be better described as "tracks," as each
/// one corresponds to a separate source of audio data. Three different WAV
/// files playing at the same time would be three separate SDL_mixer channels,
/// for example.
///
/// An app needs as many channels as it has audio data it wants to play
/// simultaneously, mixing them into a single stream to send to the audio
/// device.
///
/// SDL_mixer allocates `MIX_CHANNELS` (currently 8) channels when you open an
/// audio device, which may be more than an app needs, but if the app needs
/// more or wants less, this function can change it.
///
/// If decreasing the number of channels, any upper channels currently playing
/// are stopped. This will deregister all effects on those channels and call
/// any callback specified by Mix_ChannelFinished() for each removed channel.
///
/// If `numchans` is less than zero, this will return the current number of
/// channels without changing anything.
///
/// \param numchans the new number of channels, or < 0 to query current channel
///                 count.
/// \returns the new number of allocated channels.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_AllocateChannels(numchans: c_int) c_int;
pub const allocateChannels = Mix_AllocateChannels;

/// Load a supported audio format into a chunk.
///
/// SDL_mixer has two separate data structures for audio data. One it calls a
/// "chunk," which is meant to be a file completely decoded into memory up
/// front, and the other it calls "music" which is a file intended to be
/// decoded on demand. Originally, simple formats like uncompressed WAV files
/// were meant to be chunks and compressed things, like MP3s, were meant to be
/// music, and you would stream one thing for a game's music and make repeating
/// sound effects with the chunks.
///
/// In modern times, this isn't split by format anymore, and most are
/// interchangeable, so the question is what the app thinks is worth
/// predecoding or not. Chunks might take more memory, but once they are loaded
/// won't need to decode again, whereas music always needs to be decoded on the
/// fly. Also, crucially, there are as many channels for chunks as the app can
/// allocate, but SDL_mixer only offers a single "music" channel.
///
/// If `closeio` is true, the IOStream will be closed before returning, whether
/// this function succeeds or not. SDL_mixer reads everything it needs from the
/// IOStream during this call in any case.
///
/// There is a separate function (a macro, before SDL_mixer 3.0.0) to read
/// files from disk without having to deal with SDL_IOStream:
/// `Mix_LoadWAV("filename.wav")` will call this function and manage those
/// details for you.
///
/// When done with a chunk, the app should dispose of it with a call to
/// Mix_FreeChunk().
///
/// \param src an SDL_IOStream that data will be read from.
/// \param closeio true to close the SDL_IOStream before returning, false to
///                leave it open.
/// \returns a new chunk, or NULL on error.
///
/// \since This function is available since SDL_mixer 3.0.0
///
/// \sa Mix_LoadWAV
/// \sa Mix_FreeChunk
///
extern fn Mix_LoadWAV_IO(src: *sdl.iostream.Stream, closeio: bool) *Chunk;
pub const loadWavIo = Mix_LoadWAV_IO;

/// Load a supported audio format into a chunk.
///
/// SDL_mixer has two separate data structures for audio data. One it calls a
/// "chunk," which is meant to be a file completely decoded into memory up
/// front, and the other it calls "music" which is a file intended to be
/// decoded on demand. Originally, simple formats like uncompressed WAV files
/// were meant to be chunks and compressed things, like MP3s, were meant to be
/// music, and you would stream one thing for a game's music and make repeating
/// sound effects with the chunks.
///
/// In modern times, this isn't split by format anymore, and most are
/// interchangeable, so the question is what the app thinks is worth
/// predecoding or not. Chunks might take more memory, but once they are loaded
/// won't need to decode again, whereas music always needs to be decoded on the
/// fly. Also, crucially, there are as many channels for chunks as the app can
/// allocate, but SDL_mixer only offers a single "music" channel.
///
/// If you would rather use the abstract SDL_IOStream interface to load data
/// from somewhere other than the filesystem, you can use Mix_LoadWAV_IO()
/// instead.
///
/// When done with a chunk, the app should dispose of it with a call to
/// Mix_FreeChunk().
///
/// Note that before SDL_mixer 3.0.0, this function was a macro that called
/// Mix_LoadWAV_IO(), creating a IOStream and setting `closeio` to true. This
/// macro has since been promoted to a proper API function. Older binaries
/// linked against a newer SDL_mixer will still call Mix_LoadWAV_IO directly,
/// as they are using the macro, which was available since the dawn of time.
///
/// \param file the filesystem path to load data from.
/// \returns a new chunk, or NULL on error.
///
/// \since This function is available since SDL_mixer 3.0.0
///
/// \sa Mix_LoadWAV_IO
/// \sa Mix_FreeChunk
///
pub extern fn Mix_LoadWAV(file: [*]const u8) ?*Chunk;
pub const loadWav = Mix_LoadWAV;

/// Load a supported audio format into a music object.
///
/// SDL_mixer has two separate data structures for audio data. One it calls a
/// "chunk," which is meant to be a file completely decoded into memory up
/// front, and the other it calls "music" which is a file intended to be
/// decoded on demand. Originally, simple formats like uncompressed WAV files
/// were meant to be chunks and compressed things, like MP3s, were meant to be
/// music, and you would stream one thing for a game's music and make repeating
/// sound effects with the chunks.
///
/// In modern times, this isn't split by format anymore, and most are
/// interchangeable, so the question is what the app thinks is worth
/// predecoding or not. Chunks might take more memory, but once they are loaded
/// won't need to decode again, whereas music always needs to be decoded on the
/// fly. Also, crucially, there are as many channels for chunks as the app can
/// allocate, but SDL_mixer only offers a single "music" channel.
///
/// When done with this music, the app should dispose of it with a call to
/// Mix_FreeMusic().
///
/// \param file a file path from where to load music data.
/// \returns a new music object, or NULL on error.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
/// \sa Mix_FreeMusic
///
pub extern fn Mix_LoadMUS(file: [*]const u8) *Music;
pub const loadMus = Mix_LoadMUS;

/// Load a supported audio format into a music object.
///
/// SDL_mixer has two separate data structures for audio data. One it calls a
/// "chunk," which is meant to be a file completely decoded into memory up
/// front, and the other it calls "music" which is a file intended to be
/// decoded on demand. Originally, simple formats like uncompressed WAV files
/// were meant to be chunks and compressed things, like MP3s, were meant to be
/// music, and you would stream one thing for a game's music and make repeating
/// sound effects with the chunks.
///
/// In modern times, this isn't split by format anymore, and most are
/// interchangeable, so the question is what the app thinks is worth
/// predecoding or not. Chunks might take more memory, but once they are loaded
/// won't need to decode again, whereas music always needs to be decoded on the
/// fly. Also, crucially, there are as many channels for chunks as the app can
/// allocate, but SDL_mixer only offers a single "music" channel.
///
/// If `closeio` is true, the IOStream will be closed before returning, whether
/// this function succeeds or not. SDL_mixer reads everything it needs from the
/// IOStream during this call in any case.
///
/// As a convenience, there is a function to read files from disk without
/// having to deal with SDL_IOStream: `Mix_LoadMUS("filename.mp3")` will manage
/// those details for you.
///
/// This function attempts to guess the file format from incoming data. If the
/// caller knows the format, or wants to force it, it should use
/// Mix_LoadMUSType_IO() instead.
///
/// When done with this music, the app should dispose of it with a call to
/// Mix_FreeMusic().
///
/// \param src an SDL_IOStream that data will be read from.
/// \param closeio true to close the SDL_IOStream before returning, false to
///                leave it open.
/// \returns a new music object, or NULL on error.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
/// \sa Mix_FreeMusic
///
extern fn Mix_LoadMUS_IO(src: *sdl.iostream.Stream, closeio: bool) *Music;
pub const loadMusIo = Mix_LoadMUS_IO;

/// Load an audio format into a music object, assuming a specific format.
///
/// SDL_mixer has two separate data structures for audio data. One it calls a
/// "chunk," which is meant to be a file completely decoded into memory up
/// front, and the other it calls "music" which is a file intended to be
/// decoded on demand. Originally, simple formats like uncompressed WAV files
/// were meant to be chunks and compressed things, like MP3s, were meant to be
/// music, and you would stream one thing for a game's music and make repeating
/// sound effects with the chunks.
///
/// In modern times, this isn't split by format anymore, and most are
/// interchangeable, so the question is what the app thinks is worth
/// predecoding or not. Chunks might take more memory, but once they are loaded
/// won't need to decode again, whereas music always needs to be decoded on the
/// fly. Also, crucially, there are as many channels for chunks as the app can
/// allocate, but SDL_mixer only offers a single "music" channel.
///
/// This function loads music data, and lets the application specify the type
/// of music being loaded, which might be useful if SDL_mixer cannot figure it
/// out from the data stream itself.
///
/// Currently, the following types are supported:
///
/// - `MUS_NONE` (SDL_mixer should guess, based on the data)
/// - `MUS_WAV` (Microsoft WAV files)
/// - `MUS_MOD` (Various tracker formats)
/// - `MUS_MID` (MIDI files)
/// - `MUS_OGG` (Ogg Vorbis files)
/// - `MUS_MP3` (MP3 files)
/// - `MUS_FLAC` (FLAC files)
/// - `MUS_OPUS` (Opus files)
/// - `MUS_WAVPACK` (WavPack files)
///
/// If `closeio` is true, the IOStream will be closed before returning, whether
/// this function succeeds or not. SDL_mixer reads everything it needs from the
/// IOStream during this call in any case.
///
/// As a convenience, there is a function to read files from disk without
/// having to deal with SDL_IOStream: `Mix_LoadMUS("filename.mp3")` will manage
/// those details for you (but not let you specify the music type explicitly)..
///
/// When done with this music, the app should dispose of it with a call to
/// Mix_FreeMusic().
///
/// \param src an SDL_IOStream that data will be read from.
/// \param type the type of audio data provided by `src`.
/// \param closeio true to close the SDL_IOStream before returning, false to
///                leave it open.
/// \returns a new music object, or NULL on error.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
/// \sa Mix_FreeMusic
///
extern fn Mix_LoadMUSType_IO(src: *sdl.iostream.Stream, type: MusicType, closeio: bool) *Music;
pub const loadMusTypeIO = Mix_LoadMUSType_IO;

/// Load a WAV file from memory as quickly as possible.
///
/// Unlike Mix_LoadWAV_IO, this function has several requirements, and unless
/// you control all your audio data and know what you're doing, you should
/// consider this function unsafe and not use it.
///
/// - The provided audio data MUST be in Microsoft WAV format.
/// - The provided audio data shouldn't use any strange WAV extensions.
/// - The audio data MUST be in the exact same format as the audio device. This
///   function will not attempt to convert it, or even verify it's in the right
///   format.
/// - The audio data must be valid; this function does not know the size of the
///   memory buffer, so if the WAV data is corrupted, it can read past the end
///   of the buffer, causing a crash.
/// - The audio data must live at least as long as the returned Mix_Chunk,
///   because SDL_mixer will use that data directly and not make a copy of it.
///
/// This function will do NO error checking! Be extremely careful here!
///
/// (Seriously, use Mix_LoadWAV_IO instead.)
///
/// If this function is successful, the provided memory buffer must remain
/// available until Mix_FreeChunk() is called on the returned chunk.
///
/// \param mem memory buffer containing of a WAV file.
/// \returns a new chunk, or NULL on error.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
/// \sa Mix_LoadWAV_IO
/// \sa Mix_FreeChunk
///
extern fn Mix_QuickLoad_WAV(mem: [*]u8) *Chunk;
pub const quickLoadWav = Mix_QuickLoad_WAV;

/// Load a raw audio data from memory as quickly as possible.
///
/// The audio data MUST be in the exact same format as the audio device. This
/// function will not attempt to convert it, or even verify it's in the right
/// format.
///
/// If this function is successful, the provided memory buffer must remain
/// available until Mix_FreeChunk() is called on the returned chunk.
///
/// \param mem memory buffer containing raw PCM data.
/// \param len length of buffer pointed to by `mem`, in bytes.
/// \returns a new chunk, or NULL on error.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
/// \sa Mix_FreeChunk
///
extern fn Mix_QuickLoad_RAW(mem: [*]u8, len: u32) *Chunk;
pub const quickLoadRaw = Mix_QuickLoad_RAW;

/// Free a music object.
///
/// If this music is currently playing, it will be stopped.
///
/// If this music is in the process of fading out (via Mix_FadeOutMusic()),
/// this function will *block* until the fade completes. If you need to avoid
/// this, be sure to call Mix_HaltMusic() before freeing the music.
///
/// \param music the music object to free.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
/// \sa Mix_LoadMUS
/// \sa Mix_LoadMUS_IO
/// \sa Mix_LoadMUSType_IO
///
///
extern fn Mix_FreeMusic(music: *Music) void;
pub const freeMusic = Mix_FreeMusic;

/// Get a list of chunk decoders that this build of SDL_mixer provides.
///
/// This list can change between builds AND runs of the program, if external
/// libraries that add functionality become available. You must successfully
/// call Mix_OpenAudio() before calling this function, as decoders are
/// activated at device open time.
///
/// Appearing in this list doesn't promise your specific audio file will
/// decode...but it's handy to know if you have, say, a functioning Ogg Vorbis
/// install.
///
/// These return values are static, read-only data; do not modify or free it.
/// The pointers remain valid until you call Mix_CloseAudio().
///
/// \returns number of chunk decoders available.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
/// \sa Mix_GetChunkDecoder
/// \sa Mix_HasChunkDecoder
///
extern fn Mix_GetNumChunkDecoders() c_int;
pub const chunkNumDecoders = Mix_GetNumChunkDecoders;

/// Get a chunk decoder's name.
///
/// The requested decoder's index must be between zero and
/// Mix_GetNumChunkDecoders()-1. It's safe to call this with an invalid index;
/// this function will return NULL in that case.
///
/// This list can change between builds AND runs of the program, if external
/// libraries that add functionality become available. You must successfully
/// call Mix_OpenAudio() before calling this function, as decoders are
/// activated at device open time.
///
/// \param index index of the chunk decoder.
/// \returns the chunk decoder's name.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
/// \sa Mix_GetNumChunkDecoders
///
extern fn Mix_GetChunkDecoder(index: c_int) [*]const u8;
pub const chunkDecoder = Mix_GetChunkDecoder;

/// Check if a chunk decoder is available by name.
///
/// This result can change between builds AND runs of the program, if external
/// libraries that add functionality become available. You must successfully
/// call Mix_OpenAudio() before calling this function, as decoders are
/// activated at device open time.
///
/// Decoder names are arbitrary but also obvious, so you have to know what
/// you're looking for ahead of time, but usually it's the file extension in
/// capital letters (some example names are "AIFF", "VOC", "WAV").
///
/// \param name the decoder name to query.
/// \returns true if a decoder by that name is available, false otherwise.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
/// \sa Mix_GetNumChunkDecoders
/// \sa Mix_GetChunkDecoder
///
extern fn Mix_HasChunkDecoder(name: [*]const u8) bool;
pub const chunkHasDecoder = Mix_HasChunkDecoder;

/// Get a list of music decoders that this build of SDL_mixer provides.
///
/// This list can change between builds AND runs of the program, if external
/// libraries that add functionality become available. You must successfully
/// call Mix_OpenAudio() before calling this function, as decoders are
/// activated at device open time.
///
/// Appearing in this list doesn't promise your specific audio file will
/// decode...but it's handy to know if you have, say, a functioning Ogg Vorbis
/// install.
///
/// These return values are static, read-only data; do not modify or free it.
/// The pointers remain valid until you call Mix_CloseAudio().
///
/// \returns number of music decoders available.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
/// \sa Mix_GetMusicDecoder
/// \sa Mix_HasMusicDecoder
///
extern fn Mix_GetNumMusicDecoders() c_int;
pub const musicNumDecoders = Mix_GetNumMusicDecoders;

/// Get a music decoder's name.
///
/// The requested decoder's index must be between zero and
/// Mix_GetNumMusicDecoders()-1. It's safe to call this with an invalid index;
/// this function will return NULL in that case.
///
/// This list can change between builds AND runs of the program, if external
/// libraries that add functionality become available. You must successfully
/// call Mix_OpenAudio() before calling this function, as decoders are
/// activated at device open time.
///
/// \param index index of the music decoder.
/// \returns the music decoder's name.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
/// \sa Mix_GetNumMusicDecoders
///
extern fn Mix_GetMusicDecoder(index: c_int) [*]const u8;
pub const musicDecoder = Mix_GetMusicDecoder;

/// Check if a music decoder is available by name.
///
/// This result can change between builds AND runs of the program, if external
/// libraries that add functionality become available. You must successfully
/// call Mix_OpenAudio() before calling this function, as decoders are
/// activated at device open time.
///
/// Decoder names are arbitrary but also obvious, so you have to know what
/// you're looking for ahead of time, but usually it's the file extension in
/// capital letters (some example names are "MOD", "MP3", "FLAC").
///
/// \param name the decoder name to query.
/// \returns true if a decoder by that name is available, false otherwise.
///
/// \since This function is available since SDL_mixer 3.0.0
///
/// \sa Mix_GetNumMusicDecoders
/// \sa Mix_GetMusicDecoder
///
extern fn Mix_HasMusicDecoder(name: [*]const u8) bool;
pub const musicHasDecoder = Mix_HasMusicDecoder;

/// Find out the format of a mixer music.
///
/// If `music` is NULL, this will query the currently playing music (and return
/// MUS_NONE if nothing is currently playing).
///
/// \param music the music object to query, or NULL for the currently-playing
///              music.
/// \returns the Mix_MusicType for the music object.
///
/// \since This function is available since SDL_mixer 3.0.0
///
extern fn Mix_GetMusicType(music: *const Music) MusicType;
pub const musicType = Mix_GetMusicType;

/// Get the title for a music object, or its filename.
///
/// This returns format-specific metadata. Not all file formats supply this!
///
/// If `music` is NULL, this will query the currently-playing music.
///
/// If music's title tag is missing or empty, the filename will be returned. If
/// you'd rather have the actual metadata or nothing, use
/// Mix_GetMusicTitleTag() instead.
///
/// Please note that if the music was loaded from an SDL_IOStream instead of a
/// filename, the filename returned will be an empty string ("").
///
/// This function never returns NULL! If no data is available, it will return
/// an empty string ("").
///
/// \param music the music object to query, or NULL for the currently-playing
///              music.
/// \returns the music's title if available, or the filename if not, or "".
///
/// \since This function is available since SDL_mixer 3.0.0.
///
/// \sa Mix_GetMusicTitleTag
/// \sa Mix_GetMusicArtistTag
/// \sa Mix_GetMusicAlbumTag
///
extern fn Mix_GetMusicTitle(music: *const Music) [*]const u8;
pub const musicTitle = Mix_GetMusicTitle;

/// Get the title for a music object.
///
/// This returns format-specific metadata. Not all file formats supply this!
///
/// If `music` is NULL, this will query the currently-playing music.
///
/// Unlike this function, Mix_GetMusicTitle() produce a string with the music's
/// filename if a title isn't available, which might be preferable for some
/// applications.
///
/// This function never returns NULL! If no data is available, it will return
/// an empty string ("").
///
/// \param music the music object to query, or NULL for the currently-playing
///              music.
/// \returns the music's title if available, or "".
///
/// \since This function is available since SDL_mixer 3.0.0.
///
/// \sa Mix_GetMusicTitle
/// \sa Mix_GetMusicArtistTag
/// \sa Mix_GetMusicAlbumTag
/// \sa Mix_GetMusicCopyrightTag
///
extern fn Mix_GetMusicTitleTag(music: *const Music) [*]const u8;
pub const musicTitleTag = Mix_GetMusicTitleTag;

/// Get the artist name for a music object.
///
/// This returns format-specific metadata. Not all file formats supply this!
///
/// If `music` is NULL, this will query the currently-playing music.
///
/// This function never returns NULL! If no data is available, it will return
/// an empty string ("").
///
/// \param music the music object to query, or NULL for the currently-playing
///              music.
/// \returns the music's artist name if available, or "".
///
/// \since This function is available since SDL_mixer 3.0.0.
///
/// \sa Mix_GetMusicTitleTag
/// \sa Mix_GetMusicAlbumTag
/// \sa Mix_GetMusicCopyrightTag
///
extern fn Mix_GetMusicArtistTag(music: *const Music) [*]const u8;
pub const musicArtistTag = Mix_GetMusicArtistTag;

/// Get the album name for a music object.
///
/// This returns format-specific metadata. Not all file formats supply this!
///
/// If `music` is NULL, this will query the currently-playing music.
///
/// This function never returns NULL! If no data is available, it will return
/// an empty string ("").
///
/// \param music the music object to query, or NULL for the currently-playing
///              music.
/// \returns the music's album name if available, or "".
///
/// \since This function is available since SDL_mixer 3.0.0.
///
/// \sa Mix_GetMusicTitleTag
/// \sa Mix_GetMusicArtistTag
/// \sa Mix_GetMusicCopyrightTag
///
extern fn Mix_GetMusicAlbumTag(music: *const Music) [*]const u8;
pub const musicAlbumTag = Mix_GetMusicAlbumTag;

/// Get the copyright text for a music object.
///
/// This returns format-specific metadata. Not all file formats supply this!
///
/// If `music` is NULL, this will query the currently-playing music.
///
/// This function never returns NULL! If no data is available, it will return
/// an empty string ("").
///
/// \param music the music object to query, or NULL for the currently-playing
///              music.
/// \returns the music's copyright text if available, or "".
///
/// \since This function is available since SDL_mixer 3.0.0.
///
/// \sa Mix_GetMusicTitleTag
/// \sa Mix_GetMusicArtistTag
/// \sa Mix_GetMusicAlbumTag
///
extern fn Mix_GetMusicCopyrightTag(music: *const Music) [*]const u8;
pub const musicCopyrightTag = Mix_GetMusicCopyrightTag;

/// Set a function that is called after all mixing is performed.
///
/// This can be used to provide real-time visual display of the audio stream or
/// add a custom mixer filter for the stream data.
///
/// The callback will fire every time SDL_mixer is ready to supply more data to
/// the audio device, after it has finished all its mixing work. This runs
/// inside an SDL audio callback, so it's important that the callback return
/// quickly, or there could be problems in the audio playback.
///
/// The data provided to the callback is in the format that the audio device
/// was opened in, and it represents the exact waveform SDL_mixer has mixed
/// from all playing chunks and music for playback. You are allowed to modify
/// the data, but it cannot be resized (so you can't add a reverb effect that
/// goes past the end of the buffer without saving some state between runs to
/// add it into the next callback, or resample the buffer to a smaller size to
/// speed it up, etc).
///
/// The `arg` pointer supplied here is passed to the callback as-is, for
/// whatever the callback might want to do with it (keep track of some ongoing
/// state, settings, etc).
///
/// Passing a NULL callback disables the post-mix callback until such a time as
/// a new one callback is set.
///
/// There is only one callback available. If you need to mix multiple inputs,
/// be prepared to handle them from a single function.
///
/// \param mix_func the callback function to become the new post-mix callback.
/// \param arg a pointer that is passed, untouched, to the callback.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
/// \sa Mix_HookMusic
///
extern fn Mix_SetPostMix(mix_func: MixCallback, arg: ?*anyopaque) void;
pub const setPostMix = Mix_SetPostMix;

/// Add your own music player or additional mixer function.
///
/// This works something like Mix_SetPostMix(), but it has some crucial
/// differences. Note that an app can use this _and_ Mix_SetPostMix() at the
/// same time. This allows an app to replace the built-in music playback,
/// either with it's own music decoder or with some sort of
/// procedurally-generated audio output.
///
/// The supplied callback will fire every time SDL_mixer is preparing to supply
/// more data to the audio device. This runs inside an SDL audio callback, so
/// it's important that the callback return quickly, or there could be problems
/// in the audio playback.
///
/// Running this callback is the first thing SDL_mixer will do when starting to
/// mix more audio. The buffer will contain silence upon entry, so the callback
/// does not need to mix into existing data or initialize the buffer.
///
/// Note that while a callback is set through this function, SDL_mixer will not
/// mix any playing music; this callback is used instead. To disable this
/// callback (and thus reenable built-in music playback) call this function
/// with a NULL callback.
///
/// The data written to by the callback is in the format that the audio device
/// was opened in, and upon return from the callback, SDL_mixer will mix any
/// playing chunks (but not music!) into the buffer. The callback cannot resize
/// the buffer (so you must be prepared to provide exactly the amount of data
/// demanded or leave it as silence).
///
/// The `arg` pointer supplied here is passed to the callback as-is, for
/// state, settings, etc).
///
/// As there is only one music "channel" mixed, there is only one callback
/// available. If you need to mix multiple inputs, be prepared to handle them
/// from a single function.
///
/// \param mix_func the callback function to become the new post-mix callback.
/// \param arg a pointer that is passed, untouched, to the callback.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
/// \sa Mix_SetPostMix
///
extern fn Mix_HookMusic(mix_func: MixCallback, arg: ?*anyopaque) void;
pub const hookMusic = Mix_HookMusic;

/// Set a callback that runs when a music object has stopped playing.
///
/// This callback will fire when the currently-playing music has completed, or
/// when it has been explicitly stopped from a call to Mix_HaltMusic. As such,
/// this callback might fire from an arbitrary background thread at almost any
/// time; try to limit what you do here.
///
/// It is legal to start a new music object playing in this callback (or
/// restart the one that just stopped). If the music finished normally, this
/// can be used to loop the music without a gap in the audio playback.
///
/// A NULL pointer will disable the callback.
///
/// \param music_finished the callback function to become the new notification
///                       mechanism.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_HookMusicFinished(music_finished: MusicFinishedCallback) void;
pub const hookMusicFinished = Mix_HookMusicFinished;

/// Get a pointer to the user data for the current music hook.
///
/// This returns the `arg` pointer last passed to Mix_HookMusic(), or NULL if
/// that function has never been called.
///
/// \returns pointer to the user data previously passed to Mix_HookMusic.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_GetMusicHookData() ?*anyopaque;

/// Set a callback that runs when a channel has finished playing.
///
/// The callback may be called from the mixer's audio callback or it could be
/// called as a result of Mix_HaltChannel(), etc.
///
/// The callback has a single parameter, `channel`, which says what mixer
/// channel has just stopped.
///
/// A NULL pointer will disable the callback.
///
/// \param channel_finished the callback function to become the new
///                         notification mechanism.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_ChannelFinished(channel_finished: ChannelFinishedCallback) void;

/// Register a special effect function.
///
/// At mixing time, the channel data is copied into a buffer and passed through
/// each registered effect function. After it passes through all the functions,
/// it is mixed into the final output stream. The copy to buffer is performed
/// once, then each effect function performs on the output of the previous
/// effect. Understand that this extra copy to a buffer is not performed if
/// there are no effects registered for a given chunk, which saves CPU cycles,
/// and any given effect will be extra cycles, too, so it is crucial that your
/// code run fast. Also note that the data that your function is given is in
/// the format of the sound device, and not the format you gave to
/// Mix_OpenAudio(), although they may in reality be the same. This is an
/// unfortunate but necessary speed concern. Use Mix_QuerySpec() to determine
/// if you can handle the data before you register your effect, and take
/// appropriate actions.
///
/// You may also specify a callback (Mix_EffectDone_t) that is called when the
/// channel finishes playing. This gives you a more fine-grained control than
/// Mix_ChannelFinished(), in case you need to free effect-specific resources,
/// etc. If you don't need this, you can specify NULL.
///
/// You may set the callbacks before or after calling Mix_PlayChannel().
///
/// Things like Mix_SetPanning() are just internal special effect functions, so
/// if you are using that, you've already incurred the overhead of a copy to a
/// separate buffer, and that these effects will be in the queue with any
/// functions you've registered. The list of registered effects for a channel
/// is reset when a chunk finishes playing, so you need to explicitly set them
/// with each call to Mix_PlayChannel*().
///
/// You may also register a special effect function that is to be run after
/// final mixing occurs. The rules for these callbacks are identical to those
/// music have been mixed into a single stream, whereas channel-specific
/// effects run on a given channel before any other mixing occurs. These global
/// effect callbacks are call "posteffects". Posteffects only have their
/// Mix_EffectDone_t function called when they are unregistered (since the main
/// output stream is never "done" in the same sense as a channel). You must
/// unregister them manually when you've had enough. Your callback will be told
/// that the channel being mixed is `MIX_CHANNEL_POST` if the processing is
/// considered a posteffect.
///
/// After all these effects have finished processing, the callback registered
/// through Mix_SetPostMix() runs, and then the stream goes to the audio
/// device.
///
/// \param chan the channel to register an effect to, or MIX_CHANNEL_POST.
/// \param f effect the callback to run when more of this channel is to be
///          mixed.
/// \param d effect done callback.
/// \param arg argument.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_RegisterEffect(chan: c_int, f: EffectFunc, d: EffectDone, arg: ?*anyopaque) bool;
pub const effectRegister = Mix_RegisterEffect;

/// Explicitly unregister a special effect function.
///
/// You may not need to call this at all, unless you need to stop an effect
/// from processing in the middle of a chunk's playback.
///
/// Posteffects are never implicitly unregistered as they are for channels (as
/// the output stream does not have an end), but they may be explicitly
/// unregistered through this function by specifying MIX_CHANNEL_POST for a
/// channel.
///
/// \param channel the channel to unregister an effect on, or MIX_CHANNEL_POST.
/// \param f effect the callback stop calling in future mixing iterations.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_UnregisterEffect(channel: c_int, f: EffectFunc) bool;
pub const effectUnregister = Mix_UnregisterEffect;

/// Explicitly unregister all special effect functions.
///
/// You may not need to call this at all, unless you need to stop all effects
/// from processing in the middle of a chunk's playback.
///
/// Note that this will also shut off some internal effect processing, since
/// Mix_SetPanning() and others may use this API under the hood. This is called
/// internally when a channel completes playback. Posteffects are never
/// implicitly unregistered as they are for channels, but they may be
/// explicitly unregistered through this function by specifying
/// MIX_CHANNEL_POST for a channel.
///
/// \param channel the channel to unregister all effects on, or
///                MIX_CHANNEL_POST.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_UnregisterAllEffects(channel: c_int) bool;
pub const effectUnregisterAll = Mix_UnregisterAllEffects;

//  These are the internally-defined mixing effects. They use the same API that
//  effects defined in the application use, but are provided here as a
//  convenience. Some effects can reduce their quality or use more memory in
//  the name of speed; to enable this, make sure the environment variable
//  MIX_EFFECTSMAXSPEED (see above) is defined before you call
//  Mix_OpenAudio().

/// Set the panning of a channel.
///
/// The left and right channels are specified as integers between 0 and 255,
/// quietest to loudest, respectively.
///
/// Technically, this is just individual volume control for a sample with two
/// (stereo) channels, so it can be used for more than just panning. If you
/// want real panning, call it like this:
///
/// ```c
/// Mix_SetPanning(channel, left, 255 - left);
/// ```
///
/// Setting `channel` to MIX_CHANNEL_POST registers this as a posteffect, and
/// the panning will be done to the final mixed stream before passing it on to
/// the audio device.
///
/// This uses the Mix_RegisterEffect() API internally, and returns without
/// registering the effect function if the audio device is not configured for
/// stereo output. Setting both `left` and `right` to 255 causes this effect to
/// be unregistered, since that is the data's normal state.
///
/// Note that an audio device in mono mode is a no-op, but this call will
/// return successful in that case. Error messages can be retrieved from
/// Mix_GetError().
///
/// \param channel The mixer channel to pan or MIX_CHANNEL_POST.
/// \param left Volume of stereo left channel, 0 is silence, 255 is full
/// \param right Volume of stereo right channel, 0 is silence, 255 is full
///              volume.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
/// \sa Mix_SetPosition
/// \sa Mix_SetDistance
///
// TODO extern SDL_DECLSPEC bool SDLCALL Mix_SetPanning(int channel, Uint8 left, Uint8 right);

/// Set the position of a channel.
///
/// `angle` is an integer from 0 to 360, that specifies the location of the
/// sound in relation to the listener. `angle` will be reduced as necessary
/// (540 becomes 180 degrees, -100 becomes 260). Angle 0 is due north, and
/// rotates clockwise as the value increases. For efficiency, the precision of
/// this effect may be limited (angles 1 through 7 might all produce the same
/// effect, 8 through 15 are equal, etc). `distance` is an integer between 0
/// and 255 that specifies the space between the sound and the listener. The
/// larger the number, the further away the sound is. Using 255 does not
/// guarantee that the channel will be removed from the mixing process or be
/// completely silent. For efficiency, the precision of this effect may be
/// limited (distance 0 through 5 might all produce the same effect, 6 through
/// 10 are equal, etc). Setting `angle` and `distance` to 0 unregisters this
/// effect, since the data would be unchanged.
///
/// If you need more precise positional audio, consider using OpenAL for
/// spatialized effects instead of SDL_mixer. This is only meant to be a basic
/// effect for simple "3D" games.
///
/// If the audio device is configured for mono output, then you won't get any
/// effectiveness from the angle; however, distance attenuation on the channel
/// will still occur. While this effect will function with stereo voices, it
/// makes more sense to use voices with only one channel of sound, so when they
/// are mixed through this effect, the positioning will sound correct. You can
/// convert them to mono through SDL before giving them to the mixer in the
/// first place if you like.
///
/// Setting the channel to MIX_CHANNEL_POST registers this as a posteffect, and
/// the positioning will be done to the final mixed stream before passing it on
/// to the audio device.
///
/// This is a convenience wrapper over Mix_SetDistance() and Mix_SetPanning().
///
/// \param channel The mixer channel to position, or MIX_CHANNEL_POST.
/// \param angle angle, in degrees. North is 0, and goes clockwise.
/// \param distance distance; 0 is the listener, 255 is maxiumum distance away.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
// TODO extern SDL_DECLSPEC bool SDLCALL Mix_SetPosition(int channel, Sint16 angle, Uint8 distance);

/// Set the "distance" of a channel.
///
/// `distance` is an integer from 0 to 255 that specifies the location of the
/// sound in relation to the listener. Distance 0 is overlapping the listener,
/// and 255 is as far away as possible. A distance of 255 does not guarantee
/// silence; in such a case, you might want to try changing the chunk's volume,
/// or just cull the sample from the mixing process with Mix_HaltChannel(). For
/// efficiency, the precision of this effect may be limited (distances 1
/// through 7 might all produce the same effect, 8 through 15 are equal, etc).
/// (distance) is an integer between 0 and 255 that specifies the space between
/// the sound and the listener. The larger the number, the further away the
/// sound is. Setting the distance to 0 unregisters this effect, since the data
/// would be unchanged. If you need more precise positional audio, consider
/// using OpenAL for spatialized effects instead of SDL_mixer. This is only
/// meant to be a basic effect for simple "3D" games.
///
/// Setting the channel to MIX_CHANNEL_POST registers this as a posteffect, and
/// the distance attenuation will be done to the final mixed stream before
/// passing it on to the audio device.
///
/// This uses the Mix_RegisterEffect() API internally.
///
/// \param channel The mixer channel to attenuate, or MIX_CHANNEL_POST.
/// \param distance distance; 0 is the listener, 255 is maxiumum distance away.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
// TODO extern SDL_DECLSPEC bool SDLCALL Mix_SetDistance(int channel, Uint8 distance);

/// Cause a channel to reverse its stereo.
///
/// This is handy if the user has his speakers hooked up backwards, or you
/// would like to have a trippy sound effect.
///
/// Calling this function with `flip` set to non-zero reverses the chunks's
/// usual channels. If `flip` is zero, the effect is unregistered.
///
/// This uses the Mix_RegisterEffect() API internally, and thus is probably
/// more CPU intensive than having the user just plug in his speakers
/// correctly. Mix_SetReverseStereo() returns without registering the effect
/// function if the audio device is not configured for stereo output.
///
/// If you specify MIX_CHANNEL_POST for `channel`, then this effect is used on
/// the final mixed stream before sending it on to the audio device (a
/// posteffect).
///
/// \param channel The mixer channel to reverse, or MIX_CHANNEL_POST.
/// \param flip non-zero to reverse stereo, zero to disable this effect.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information. Note that an audio device in mono mode is a no-op,
///          but this call will return successful in that case.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
// TODO extern SDL_DECLSPEC bool SDLCALL Mix_SetReverseStereo(int channel, int flip);

// End effects

/// Reserve the first channels for the application.
///
/// While SDL_mixer will use up to the number of channels allocated by
/// Mix_AllocateChannels(), this sets channels aside that will not be available
/// when calling Mix_PlayChannel with a channel of -1 (play on the first unused
/// channel). In this case, SDL_mixer will treat reserved channels as "used"
/// whether anything is playing on them at the moment or not.
///
/// This is useful if you've budgeted some channels for dedicated audio and the
/// rest are just used as they are available.
///
/// Calling this function will set channels 0 to `n - 1` to be reserved. This
/// will not change channel allocations. The number of reserved channels will
/// be clamped to the current number allocated.
///
/// By default, no channels are reserved.
///
/// \param num number of channels to reserve, starting at index zero.
/// \returns the number of reserved channels.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_ReserveChannels(num: c_int) c_int;
pub const channelReserve = Mix_ReserveChannels;

// Channel grouping functions */

/// Assign a tag to a channel.
///
/// A tag is an arbitrary number that can be assigned to several mixer
/// channels, to form groups of channels.
///
/// If 'tag' is -1, the tag is removed (actually -1 is the tag used to
/// represent the group of all the channels).
///
/// This function replaces the requested channel's current tag; you may only
/// have one tag per channel.
///
/// You may not specify MAX_CHANNEL_POST for a channel.
///
/// \param which the channel to set the tag on.
/// \param tag an arbitrary value to assign a channel.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_GroupChannel(which: c_int, tag: c_int) bool;
pub const channelSetGroup = Mix_GroupChannel;

/// Assign several consecutive channels to the same tag.
///
/// A tag is an arbitrary number that can be assigned to several mixer
/// channels, to form groups of channels.
///
/// If 'tag' is -1, the tag is removed (actually -1 is the tag used to
/// represent the group of all the channels).
///
/// This function replaces the requested channels' current tags; you may only
/// have one tag per channel.
///
/// You may not specify MAX_CHANNEL_POST for a channel.
///
/// Note that this returns success and failure in the _opposite_ way from
/// Mix_GroupChannel(). We regret the API design mistake.
///
/// \param from the first channel to set the tag on.
/// \param to the last channel to set the tag on, inclusive.
/// \param tag an arbitrary value to assign a channel.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_GroupChannels(from: c_int, to: c_int, tag: c_int) bool;
pub const channelSetGroupMany = Mix_GroupChannels;

/// Finds the first available channel in a group of channels.
///
/// A tag is an arbitrary number that can be assigned to several mixer
/// channels, to form groups of channels.
///
/// This function searches all channels with a specified tag, and returns the
/// channel number of the first one it finds that is currently unused.
///
/// If no channels with the specified tag are unused, this function returns -1.
///
/// \param tag an arbitrary value, assigned to channels, to search for.
/// \returns first available channel, or -1 if none are available.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_GroupAvailable(tag: c_int) c_int;
pub const channelGroupAvailable = Mix_GroupAvailable;

/// Returns the number of channels in a group.
///
/// If tag is -1, this will return the total number of channels allocated,
/// regardless of what their tag might be.
///
/// \param tag an arbitrary value, assigned to channels, to search for.
/// \returns the number of channels assigned the specified tag.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_GroupCount(tag: c_int) c_int;
pub const channelGroupCount = Mix_GroupCount;

/// Find the "oldest" sample playing in a group of channels.
///
/// Specifically, this function returns the channel number that is assigned the
/// specified tag, is currently playing, and has the lowest start time, based
/// on the value of SDL_GetTicks() when the channel started playing.
///
/// If no channel with this tag is currently playing, this function returns -1.
///
/// \param tag an arbitrary value, assigned to channels, to search through.
/// \returns the "oldest" sample playing in a group of channels.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
/// \sa Mix_GroupNewer
///
extern fn Mix_GroupOldest(tag: c_int) c_int;
pub const channelGroupOldest = Mix_GroupOldest;

/// Find the "most recent" sample playing in a group of channels.
///
/// Specifically, this function returns the channel number that is assigned the
/// specified tag, is currently playing, and has the highest start time, based
/// on the value of SDL_GetTicks() when the channel started playing.
///
/// If no channel with this tag is currently playing, this function returns -1.
///
/// \param tag an arbitrary value, assigned to channels, to search through.
/// \returns the "most recent" sample playing in a group of channels.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
/// \sa Mix_GroupOldest
///
extern fn Mix_GroupNewer(tag: c_int) c_int;
pub const channelGroupNewer = Mix_GroupNewer;

/// Play an audio chunk on a specific channel.
///
/// If the specified channel is -1, play on the first free channel (and return
/// -1 without playing anything new if no free channel was available).
///
/// If a specific channel was requested, and there is a chunk already playing
/// there, that chunk will be halted and the new chunk will take its place.
///
/// If `loops` is greater than zero, loop the sound that many times. If `loops`
/// is -1, loop "infinitely" (~65000 times).
///
/// Note that before SDL_mixer 3.0.0, this function was a macro that called
/// Mix_PlayChannelTimed() with a fourth parameter ("ticks") of -1. This
/// function still does the same thing, but promotes it to a proper API
/// function. Older binaries linked against a newer SDL_mixer will still call
/// Mix_PlayChannelTimed directly, as they are using the macro, which was
/// available since the dawn of time.
///
/// \param channel the channel on which to play the new chunk.
/// \param chunk the new chunk to play.
/// \param loops the number of times the chunk should loop, -1 to loop (not
///              actually) infinitely.
/// \returns which channel was used to play the sound, or -1 if sound could not
///          be played.
/// \since This function is available since SDL_mixer 3.0.0
///
extern fn Mix_PlayChannel(channel: c_int, chunk: *Chunk, loops: c_int) c_int;
pub const channelPlay = Mix_PlayChannel;

/// Play an audio chunk on a specific channel for a maximum time.
///
/// If the specified channel is -1, play on the first free channel (and return
/// -1 without playing anything new if no free channel was available).
///
/// If a specific channel was requested, and there is a chunk already playing
/// there, that chunk will be halted and the new chunk will take its place.
///
/// If `loops` is greater than zero, loop the sound that many times. If `loops`
/// is -1, loop "infinitely" (~65000 times).
///
/// `ticks` specifies the maximum number of milliseconds to play this chunk
/// before halting it. If you want the chunk to play until all data has been
/// mixed, specify -1.
///
/// Note that this function does not block for the number of ticks requested;
/// it just schedules the chunk to play and notes the maximum for the mixer to
/// manage later, and returns immediately.
///
/// \param channel the channel on which to play the new chunk.
/// \param chunk the new chunk to play.
/// \param loops the number of times the chunk should loop, -1 to loop (not
///              actually) infinitely.
/// \param ticks the maximum number of milliseconds of this chunk to mix for
///              playback.
/// \returns which channel was used to play the sound, or -1 if sound could not
///          be played.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_PlayChannelTimed(channel: c_int, chunk: *Chunk, loops: c_int, ticks: c_int) c_int;
pub const channelPlayTimed = Mix_PlayChannelTimed;

/// Play a new music object.
///
/// This will schedule the music object to begin mixing for playback.
///
/// There is only ever one music object playing at a time; if this is called
/// when another music object is playing, the currently-playing music is halted
/// and the new music will replace it.
///
/// Please note that if the currently-playing music is in the process of fading
/// out (via Mix_FadeOutMusic()), this function will *block* until the fade
/// completes. If you need to avoid this, be sure to call Mix_HaltMusic()
/// before starting new music.
///
/// \param music the new music object to schedule for mixing.
/// \param loops the number of loops to play the music for (0 means "play once
///              and stop").
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_PlayMusic(music: *Music, loops: c_int) bool;
pub const musicPlay = Mix_PlayMusic;

/// Play a new music object, fading in the audio.
///
/// This will start the new music playing, much like Mix_PlayMusic() will, but
/// will start the music playing at silence and fade in to its normal volume
/// over the specified number of milliseconds.
///
/// If there is already music playing, that music will be halted and the new
/// music object will take its place.
///
/// If `loops` is greater than zero, loop the music that many times. If `loops`
/// is -1, loop "infinitely" (~65000 times).
///
/// Fading music will change it's volume progressively, as if Mix_VolumeMusic()
/// was called on it (which is to say: you probably shouldn't call
/// Mix_VolumeMusic() on fading music).
///
/// \param music the new music object to play.
/// \param loops the number of times the chunk should loop, -1 to loop (not
///              actually) infinitely.
/// \param ms the number of milliseconds to spend fading in.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_FadeInMusic(music: *Music, loops: c_int, ms: c_int) bool;
pub const musicFadeIn = Mix_FadeInMusic;

/// Play a new music object, fading in the audio, from a starting position.
///
/// This will start the new music playing, much like Mix_PlayMusic() will, but
/// will start the music playing at silence and fade in to its normal volume
/// over the specified number of milliseconds.
///
/// If there is already music playing, that music will be halted and the new
/// music object will take its place.
///
/// If `loops` is greater than zero, loop the music that many times. If `loops`
/// is -1, loop "infinitely" (~65000 times).
///
/// Fading music will change it's volume progressively, as if Mix_VolumeMusic()
/// was called on it (which is to say: you probably shouldn't call
/// Mix_VolumeMusic() on fading music).
///
/// This function allows the caller to start the music playback past the
/// beginning of its audio data. You may specify a start position, in seconds,
/// and the playback and fade-in will start there instead of with the first
/// samples of the music.
///
/// An app can specify a `position` of 0.0 to start at the beginning of the
/// music (or just call Mix_FadeInMusic() instead).
///
/// To convert from milliseconds, divide by 1000.0.
///
/// \param music the new music object to play.
/// \param loops the number of times the chunk should loop, -1 to loop (not
///              actually) infinitely.
/// \param ms the number of milliseconds to spend fading in.
/// \param position the start position within the music, in seconds, where
///                 playback should start.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_FadeInMusicPos(music: *Music, loops: c_int, ms: c_int, position: f64) bool;
pub const musicFadeInPos = Mix_FadeInMusicPos;

/// Play an audio chunk on a specific channel, fading in the audio.
///
/// This will start the new sound playing, much like Mix_PlayChannel() will,
/// but will start the sound playing at silence and fade in to its normal
/// volume over the specified number of milliseconds.
///
/// If the specified channel is -1, play on the first free channel (and return
/// -1 without playing anything new if no free channel was available).
///
/// If a specific channel was requested, and there is a chunk already playing
/// there, that chunk will be halted and the new chunk will take its place.
///
/// If `loops` is greater than zero, loop the sound that many times. If `loops`
/// is -1, loop "infinitely" (~65000 times).
///
/// A fading channel will change it's volume progressively, as if Mix_Volume()
/// was called on it (which is to say: you probably shouldn't call Mix_Volume()
/// on a fading channel).
///
/// Note that before SDL_mixer 3.0.0, this function was a macro that called
/// Mix_FadeInChannelTimed() with a fourth parameter ("ticks") of -1. This
/// function still does the same thing, but promotes it to a proper API
/// function. Older binaries linked against a newer SDL_mixer will still call
/// Mix_FadeInChannelTimed directly, as they are using the macro, which was
/// available since the dawn of time.
///
/// \param channel the channel on which to play the new chunk, or -1 to find
///                any available.
/// \param chunk the new chunk to play.
/// \param loops the number of times the chunk should loop, -1 to loop (not
///              actually) infinitely.
/// \param ms the number of milliseconds to spend fading in.
/// \returns which channel was used to play the sound, or -1 if sound could not
///          be played.
///
/// \since This function is available since SDL_mixer 3.0.0
///
extern fn Mix_FadeInChannel(channel: c_int, chunk: *Chunk, loops: c_int, ms: c_int) c_int;
pub const channelFadeIn = Mix_FadeInChannel;

/// Play an audio chunk on a specific channel, fading in the audio, for a
/// maximum time.
///
/// This will start the new sound playing, much like Mix_PlayChannel() will,
/// but will start the sound playing at silence and fade in to its normal
/// volume over the specified number of milliseconds.
///
/// If the specified channel is -1, play on the first free channel (and return
/// -1 without playing anything new if no free channel was available).
///
/// If a specific channel was requested, and there is a chunk already playing
/// there, that chunk will be halted and the new chunk will take its place.
///
/// If `loops` is greater than zero, loop the sound that many times. If `loops`
/// is -1, loop "infinitely" (~65000 times).
///
/// `ticks` specifies the maximum number of milliseconds to play this chunk
/// before halting it. If you want the chunk to play until all data has been
/// mixed, specify -1.
///
/// Note that this function does not block for the number of ticks requested;
/// it just schedules the chunk to play and notes the maximum for the mixer to
/// manage later, and returns immediately.
///
/// A fading channel will change it's volume progressively, as if Mix_Volume()
/// was called on it (which is to say: you probably shouldn't call Mix_Volume()
/// on a fading channel).
///
/// \param channel the channel on which to play the new chunk, or -1 to find
///                any available.
/// \param chunk the new chunk to play.
/// \param loops the number of times the chunk should loop, -1 to loop (not
///              actually) infinitely.
/// \param ms the number of milliseconds to spend fading in.
/// \param ticks the maximum number of milliseconds of this chunk to mix for
///              playback.
/// \returns which channel was used to play the sound, or -1 if sound could not
///          be played.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_FadeInChannelTimed(channel: c_int, chunk: *Chunk, loops: c_int, ms: c_int, ticks: c_int) c_int;
pub const channelFadeInTimed = Mix_FadeInChannelTimed;

/// Set the volume for a specific channel.
///
/// The volume must be between 0 (silence) and MIX_MAX_VOLUME (full volume).
/// Note that MIX_MAX_VOLUME is 128. Values greater than MIX_MAX_VOLUME are
/// clamped to MIX_MAX_VOLUME.
///
/// Specifying a negative volume will not change the current volume; as such,
/// this can be used to query the current volume without making changes, as
/// this function returns the previous (in this case, still-current) value.
///
/// If the specified channel is -1, this function sets the volume for all
/// channels, and returns _the average_ of all channels' volumes prior to this
/// call.
///
/// The default volume for a channel is MIX_MAX_VOLUME (no attenuation).
///
/// \param channel the channel on set/query the volume on, or -1 for all
///                channels.
/// \param volume the new volume, between 0 and MIX_MAX_VOLUME, or -1 to query.
/// \returns the previous volume. If the specified volume is -1, this returns
///          the current volume. If `channel` is -1, this returns the average
///          of all channels.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_Volume(channel: c_int, volume: c_int) c_int;
pub const channelSetVolume = Mix_Volume;

/// Set the volume for a specific chunk.
///
/// In addition to channels having a volume setting, individual chunks also
/// maintain a separate volume. Both values are considered when mixing, so both
/// affect the final attenuation of the sound. This lets an app adjust the
/// volume for all instances of a sound in addition to specific instances of
/// that sound.
///
/// The volume must be between 0 (silence) and MIX_MAX_VOLUME (full volume).
/// Note that MIX_MAX_VOLUME is 128. Values greater than MIX_MAX_VOLUME are
/// clamped to MIX_MAX_VOLUME.
///
/// Specifying a negative volume will not change the current volume; as such,
/// this can be used to query the current volume without making changes, as
/// this function returns the previous (in this case, still-current) value.
///
/// The default volume for a chunk is MIX_MAX_VOLUME (no attenuation).
///
/// \param chunk the chunk whose volume to adjust.
/// \param volume the new volume, between 0 and MIX_MAX_VOLUME, or -1 to query.
/// \returns the previous volume. If the specified volume is -1, this returns
///          the current volume. If `chunk` is NULL, this returns -1.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_VolumeChunk(chunk: *Chunk, volume: c_int) c_int;
pub const chunkSetVolume = Mix_VolumeChunk;

/// Set the volume for the music channel.
///
/// The volume must be between 0 (silence) and MIX_MAX_VOLUME (full volume).
/// Note that MIX_MAX_VOLUME is 128. Values greater than MIX_MAX_VOLUME are
/// clamped to MIX_MAX_VOLUME.
///
/// Specifying a negative volume will not change the current volume; as such,
/// this can be used to query the current volume without making changes, as
/// this function returns the previous (in this case, still-current) value.
///
/// The default volume for music is MIX_MAX_VOLUME (no attenuation).
///
/// \param volume the new volume, between 0 and MIX_MAX_VOLUME, or -1 to query.
/// \returns the previous volume. If the specified volume is -1, this returns
///          the current volume.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_VolumeMusic(volume: c_int) c_int;
pub const musicSetVolume = Mix_VolumeMusic;

/// Query the current volume value for a music object.
///
/// \param music the music object to query.
/// \returns the music's current volume, between 0 and MIX_MAX_VOLUME (128).
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_GetMusicVolume(volume: c_int) c_int;
pub const musicVolume = Mix_GetMusicVolume;

/// Set the master volume for all channels.
///
/// SDL_mixer keeps a per-channel volume, a per-chunk volume, and a master
/// volume, and considers all three when mixing audio. This function sets the
/// master volume, which is applied to all playing channels when mixing.
///
/// The volume must be between 0 (silence) and MIX_MAX_VOLUME (full volume).
/// Note that MIX_MAX_VOLUME is 128. Values greater than MIX_MAX_VOLUME are
/// clamped to MIX_MAX_VOLUME.
///
/// Specifying a negative volume will not change the current volume; as such,
/// this can be used to query the current volume without making changes, as
/// this function returns the previous (in this case, still-current) value.
///
/// Note that the master volume does not affect any playing music; it is only
/// applied when mixing chunks. Use Mix_VolumeMusic() for that.
///
/// \param volume the new volume, between 0 and MIX_MAX_VOLUME, or -1 to query.
/// \returns the previous volume. If the specified volume is -1, this returns
///          the current volume.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_MasterVolume(volume: c_int) c_int;
pub const setMasterVolume = Mix_MasterVolume;

/// Halt playing of a particular channel.
///
/// This will stop further playback on that channel until a new chunk is
/// started there.
///
/// Specifying a channel of -1 will halt _all_ channels, except for any playing
/// music.
///
/// Any halted channels will have any currently-registered effects
/// deregistered, and will call any callback specified by Mix_ChannelFinished()
/// before this function returns.
///
/// You may not specify MAX_CHANNEL_POST for a channel.
///
/// \param channel channel to halt, or -1 to halt all channels.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_HaltChannel(channel: c_int) void;
pub const channelHalt = Mix_HaltChannel;

/// Halt playing of a group of channels by arbitrary tag.
///
/// This will stop further playback on all channels with a specific tag, until
/// a new chunk is started there.
///
/// A tag is an arbitrary number that can be assigned to several mixer
/// channels, to form groups of channels.
///
/// The default tag for a channel is -1.
///
/// Any halted channels will have any currently-registered effects
/// deregistered, and will call any callback specified by Mix_ChannelFinished()
/// before this function returns.
///
/// \param tag an arbitrary value, assigned to channels, to search for.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_HaltGroup(tag: c_int) void;
pub const channelGroupHalt = Mix_HaltGroup;

/// Halt playing of the music stream.
///
/// This will stop further playback of music until a new music object is
/// started there.
///
/// Any halted music will call any callback specified by
/// Mix_HookMusicFinished() before this function returns.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_HaltMusic() void;
pub const musicHalt = Mix_HaltMusic;

/// Change the expiration delay for a particular channel.
///
/// The channel will halt after the 'ticks' milliseconds have elapsed, or
/// remove the expiration if 'ticks' is -1.
///
/// This overrides the value passed to the fourth parameter of
/// Mix_PlayChannelTimed().
///
/// Specifying a channel of -1 will set an expiration for _all_ channels.
///
/// Any halted channels will have any currently-registered effects
/// deregistered, and will call any callback specified by Mix_ChannelFinished()
/// once the halt occurs.
///
/// Note that this function does not block for the number of ticks requested;
/// it just schedules the chunk to expire and notes the time for the mixer to
/// manage later, and returns immediately.
///
/// \param channel the channel to change the expiration time on.
/// \param ticks number of milliseconds from now to let channel play before
///              halting, -1 to not halt.
/// \returns the number of channels that changed expirations.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_ExpireChannel(channel: c_int, ticks: c_int) c_int;
pub const channelExpire = Mix_ExpireChannel;

/// Halt a channel after fading it out for a specified time.
///
/// This will begin a channel fading from its current volume to silence over
/// `ms` milliseconds. After that time, the channel is halted.
///
/// Any halted channels will have any currently-registered effects
/// deregistered, and will call any callback specified by Mix_ChannelFinished()
/// once the halt occurs.
///
/// A fading channel will change it's volume progressively, as if Mix_Volume()
/// was called on it (which is to say: you probably shouldn't call Mix_Volume()
/// on a fading channel).
///
/// Note that this function does not block for the number of milliseconds
/// requested; it just schedules the chunk to fade and notes the time for the
/// mixer to manage later, and returns immediately.
///
/// \param which the channel to fade out.
/// \param ms number of milliseconds to fade before halting the channel.
/// \returns the number of channels scheduled to fade.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_FadeOutChannel(which: c_int, ms: c_int) c_int;
pub const channelFadeOut = Mix_FadeOutChannel;

/// Halt a playing group of channels by arbitrary tag, after fading them out
/// for a specified time.
///
/// This will begin fading a group of channels with a specific tag from their
/// current volumes to silence over `ms` milliseconds. After that time, those
/// channels are halted.
///
/// A tag is an arbitrary number that can be assigned to several mixer
/// channels, to form groups of channels.
///
/// The default tag for a channel is -1.
///
/// Any halted channels will have any currently-registered effects
/// deregistered, and will call any callback specified by Mix_ChannelFinished()
/// once the halt occurs.
///
/// A fading channel will change it's volume progressively, as if Mix_Volume()
/// was called on it (which is to say: you probably shouldn't call Mix_Volume()
/// on a fading channel).
///
/// Note that this function does not block for the number of milliseconds
/// mixer to manage later, and returns immediately.
///
/// \param tag an arbitrary value, assigned to channels, to search for.
/// \param ms number of milliseconds to fade before halting the group.
/// \returns the number of channels that were scheduled for fading.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_FadeOutGroup(tag: c_int, ms: c_int) c_int;
pub const channelGroupFadeOut = Mix_FadeOutGroup;

/// Halt the music stream after fading it out for a specified time.
///
/// This will begin the music fading from its current volume to silence over
/// `ms` milliseconds. After that time, the music is halted.
///
/// Any halted music will call any callback specified by
/// Mix_HookMusicFinished() once the halt occurs.
///
/// Fading music will change it's volume progressively, as if Mix_VolumeMusic()
/// was called on it (which is to say: you probably shouldn't call
/// Mix_VolumeMusic() on a fading channel).
///
/// Note that this function does not block for the number of milliseconds
/// requested; it just schedules the music to fade and notes the time for the
/// mixer to manage later, and returns immediately.
///
/// \param ms number of milliseconds to fade before halting the channel.
/// \returns true if music was scheduled to fade, false otherwise. If no music
///          is currently playing, this returns false.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_FadeOutMusic(ms: c_int) bool;
pub const musicFadeOut = Mix_FadeOutMusic;

/// Query the fading status of the music stream.
///
/// This reports one of three values:
///
/// - `MIX_NO_FADING`
/// - `MIX_FADING_OUT`
/// - `MIX_FADING_IN`
///
/// If music is not currently playing, this returns `MIX_NO_FADING`.
///
/// \returns the current fading status of the music stream.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_FadingMusic() Fading;
pub const musicFading = Mix_FadingMusic;

/// Query the fading status of a channel.
///
/// This reports one of three values:
///
/// - `MIX_NO_FADING`
/// - `MIX_FADING_OUT`
/// - `MIX_FADING_IN`
///
/// If nothing is currently playing on the channel, or an invalid channel is
/// specified, this returns `MIX_NO_FADING`.
///
/// You may not specify MAX_CHANNEL_POST for a channel.
///
/// You may not specify -1 for all channels; only individual channels may be
/// queried.
///
/// \param which the channel to query.
/// \returns the current fading status of the channel.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_FadingChannel(which: c_int) Fading;
pub const channelFading = Mix_FadingChannel;

/// Pause a particular channel.
///
/// Pausing a channel will prevent further playback of the assigned chunk but
/// will maintain the chunk's current mixing position. When resumed, this
/// channel will continue to mix the chunk where it left off.
///
/// A paused channel can be resumed by calling Mix_Resume().
///
/// A paused channel with an expiration will not expire while paused (the
/// expiration countdown will be adjusted once resumed).
///
/// It is legal to halt a paused channel. Playing a new chunk on a paused
/// channel will replace the current chunk and unpause the channel.
///
/// Specifying a channel of -1 will pause _all_ channels. Any music is
/// unaffected.
///
/// You may not specify MAX_CHANNEL_POST for a channel.
///
/// \param channel the channel to pause, or -1 to pause all channels.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_Pause(channel: c_int) void;
pub const channelPause = Mix_Pause;

/// Pause playing of a group of channels by arbitrary tag.
///
/// Pausing a channel will prevent further playback of the assigned chunk but
/// will maintain the chunk's current mixing position. When resumed, this
/// channel will continue to mix the chunk where it left off.
///
/// A paused channel can be resumed by calling Mix_Resume() or
/// Mix_ResumeGroup().
///
/// A paused channel with an expiration will not expire while paused (the
/// expiration countdown will be adjusted once resumed).
///
/// A tag is an arbitrary number that can be assigned to several mixer
/// channels, to form groups of channels.
///
/// The default tag for a channel is -1.
///
/// \param tag an arbitrary value, assigned to channels, to search for.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_PauseGroup(tag: c_int) void;
pub const channelGroupPause = Mix_PauseGroup;

/// Resume a particular channel.
///
/// It is legal to resume an unpaused or invalid channel; it causes no effect
/// and reports no error.
///
/// If the paused channel has an expiration, its expiration countdown resumes
/// now, as well.
///
/// Specifying a channel of -1 will resume _all_ paused channels. Any music is
/// unaffected.
///
/// \param channel the channel to resume, or -1 to resume all paused channels.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_Resume(channel: c_int) void;
pub const channelResume = Mix_Resume;

/// Resume playing of a group of channels by arbitrary tag.
///
/// It is legal to resume an unpaused or invalid channel; it causes no effect
/// and reports no error.
///
/// If the paused channel has an expiration, its expiration countdown resumes
/// now, as well.
///
/// A tag is an arbitrary number that can be assigned to several mixer
/// channels, to form groups of channels.
///
/// The default tag for a channel is -1.
///
/// \param tag an arbitrary value, assigned to channels, to search for.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_ResumeGroup(tag: c_int) void;
pub const channelGroupResume = Mix_ResumeGroup;

/// Query whether a particular channel is paused.
///
/// If an invalid channel is specified, this function returns zero.
///
/// \param channel the channel to query, or -1 to query all channels.
/// \return 1 if channel paused, 0 otherwise. If `channel` is -1, returns the
///         number of paused channels.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_Paused(channel: c_int) c_int;
pub const channelGetPaused = Mix_Paused;

/// Pause the music stream.
///
/// Pausing the music stream will prevent further playback of the assigned
/// music object, but will maintain the object's current mixing position. When
/// resumed, this channel will continue to mix the music where it left off.
///
/// Paused music can be resumed by calling Mix_ResumeMusic().
///
/// It is legal to halt paused music. Playing a new music object when music is
/// paused will replace the current music and unpause the music stream.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_PauseMusic() void;
pub const musicPause = Mix_PauseMusic;

/// Resume the music stream.
///
/// It is legal to resume an unpaused music stream; it causes no effect and
/// reports no error.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_ResumeMusic() void;
pub const musicResume = Mix_ResumeMusic;

/// Rewind the music stream.
///
/// This causes the currently-playing music to start mixing from the beginning
/// of the music, as if it were just started.
///
/// It's a legal no-op to rewind the music stream when not playing.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_RewindMusic() void;
pub const musicRewind = Mix_RewindMusic;

/// Query whether the music stream is paused.
///
/// \return true if music is paused, false otherwise.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
/// \sa Mix_PauseMusic
/// \sa Mix_ResumeMusic
///
extern fn Mix_PausedMusic() bool;
pub const musicPaused = Mix_PausedMusic;

/// Jump to a given order in mod music.
///
/// This only applies to MOD music formats.
///
/// \param order order.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
// TODO: extern SDL_DECLSPEC bool SDLCALL Mix_ModMusicJumpToOrder(int order);

/// Start a track in music object.
///
/// This only applies to GME music formats.
///
/// \param music the music object.
/// \param track the track number to play. 0 is the first track.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
// TODO: extern SDL_DECLSPEC bool SDLCALL Mix_StartTrack(Mix_Music *music, int track);

/// Get number of tracks in music object.
///
/// This only applies to GME music formats.
///
/// \param music the music object.
/// \returns number of tracks if successful, or -1 if failed or isn't
///          implemented.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
// TODO: extern SDL_DECLSPEC int SDLCALL Mix_GetNumTracks(Mix_Music *music);

/// Set the current position in the music stream, in seconds.
///
/// To convert from milliseconds, divide by 1000.0.
///
/// This function is only implemented for MOD music formats (set pattern order
/// number) and for WAV, OGG, FLAC, MP3, and MODPLUG music at the moment.
///
/// \param position the new position, in seconds (as a double).
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_SetMusicPosition(position: f64) bool;
pub const musicSetPosition = Mix_SetMusicPosition;

/// Get the time current position of music stream, in seconds.
///
/// To convert to milliseconds, multiply by 1000.0.
///
/// \param music the music object to query.
/// \returns -1.0 if this feature is not supported for some codec.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_GetMusicPosition(music: *Music) f64;
pub const musicPosition = Mix_GetMusicPosition;

/// Get a music object's duration, in seconds.
///
/// To convert to milliseconds, multiply by 1000.0.
///
/// If NULL is passed, returns duration of current playing music.
///
/// \param music the music object to query.
/// \returns music duration in seconds, or -1.0 on error.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_MusicDuration(music: *Music) f64;
pub const musicDuration = Mix_MusicDuration;

/// Get the loop start time position of music stream, in seconds.
///
/// To convert to milliseconds, multiply by 1000.0.
///
/// If NULL is passed, returns duration of current playing music.
///
/// \param music the music object to query.
/// \returns -1.0 if this feature is not used for this music or not supported
///          for some codec.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_GetMusicLoopStartTime(music: *Music) f64;
pub const musicLoopStartTime = Mix_GetMusicLoopStartTime;

/// Get the loop end time position of music stream, in seconds.
///
/// To convert to milliseconds, multiply by 1000.0.
///
/// If NULL is passed, returns duration of current playing music.
///
/// \param music the music object to query.
/// \returns -1.0 if this feature is not used for this music or not supported
///          for some codec.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_GetMusicLoopEndTime(music: Music) f64;
pub const musicLoopEndTime = Mix_GetMusicLoopEndTime;

/// Get the loop time length of music stream, in seconds.
///
/// To convert to milliseconds, multiply by 1000.0.
///
/// If NULL is passed, returns duration of current playing music.
///
/// \param music the music object to query.
/// \returns -1.0 if this feature is not used for this music or not supported
///          for some codec.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_GetMusicLoopLengthTime(music: *Music) f64;
pub const musicLoopLengthTime = Mix_GetMusicLoopLengthTime;

/// Check the playing status of a specific channel.
///
/// If the channel is currently playing, this function returns 1. Otherwise it
/// returns 0.
///
/// If the specified channel is -1, all channels are checked, and this function
/// returns the number of channels currently playing.
///
/// You may not specify MAX_CHANNEL_POST for a channel.
///
/// Paused channels are treated as playing, even though they are not currently
/// making forward progress in mixing.
///
/// \param channel channel.
/// \returns non-zero if channel is playing, zero otherwise. If `channel` is
///          -1, return the total number of channel playings.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_Playing(channel: c_int) c_int;
pub const channelPlaying = Mix_Playing;

/// Check the playing status of the music stream.
///
/// If music is currently playing, this function returns 1. Otherwise it
/// returns 0.
///
/// Paused music is treated as playing, even though it is not currently making
/// forward progress in mixing.
///
/// \returns true if music is playing, false otherwise.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_PlayingMusic() bool;
pub const musicPlaying = Mix_PlayingMusic;

/// Set SoundFonts paths to use by supported MIDI backends.
///
/// You may specify multiple paths in a single string by separating them with
/// semicolons; they will be searched in the order listed.
///
/// This function replaces any previously-specified paths.
///
/// Passing a NULL path will remove any previously-specified paths.
///
/// \param paths Paths on the filesystem where SoundFonts are available,
///              separated by semicolons.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_SetSoundFonts(paths: [*]const u8) bool;
pub const setSoundFonts = Mix_SetSoundFonts;

/// Get SoundFonts paths to use by supported MIDI backends.
///
/// There are several factors that determine what will be reported by this
/// function:
///
/// - If the boolean _SDL hint_ `"SDL_FORCE_SOUNDFONTS"` is set, AND the
///   `"SDL_SOUNDFONTS"` _environment variable_ is also set, this function will
///   return that environment variable regardless of whether
///   Mix_SetSoundFonts() was ever called.
/// - Otherwise, if Mix_SetSoundFonts() was successfully called with a non-NULL
///   path, this function will return the string passed to that function.
/// - Otherwise, if the `"SDL_SOUNDFONTS"` variable is set, this function will
///   return that environment variable.
/// - Otherwise, this function will search some common locations on the
///   filesystem, and if it finds a SoundFont there, it will return that.
/// - Failing everything else, this function returns NULL.
///
/// This returns a pointer to internal (possibly read-only) memory, and it
/// should not be modified or free'd by the caller.
///
/// \returns semicolon-separated list of sound font paths.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_GetSoundFonts() ?[*]const u8;
pub const getSoundFonts = Mix_GetSoundFonts;

pub const EachSoundFontCallback = *const fn ([*]const u8, ?*anyopaque) bool;

/// Iterate SoundFonts paths to use by supported MIDI backends.
///
/// This function will take the string reported by Mix_GetSoundFonts(), split
/// it up into separate paths, as delimited by semicolons in the string, and
/// call a callback function for each separate path.
///
/// If there are no paths available, this returns 0 without calling the
/// callback at all.
///
/// If the callback returns non-zero, this function stops iterating and returns
/// non-zero. If the callback returns 0, this function will continue iterating,
/// calling the callback again for further paths. If the callback never returns
/// 1, this function returns 0, so this can be used to decide if an available
/// soundfont is acceptable for use.
///
/// \param function the callback function to call once per path.
/// \param data a pointer to pass to the callback for its own personal use.
/// \returns true if callback ever returned true, false on error or if the
///          callback never returned true.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
/// \sa Mix_GetSoundFonts
///
extern fn Mix_EachSoundFont(function: EachSoundFontCallback, data: ?*anyopaque) bool;
pub const soundFontEach = Mix_EachSoundFont;

/// Set full path of the Timidity config file.
///
/// For example, "/etc/timidity.cfg"
///
/// This is obviously only useful if SDL_mixer is using Timidity internally to
/// play MIDI files.
///
/// \param path path to a Timidity config file.
/// \returns true on success or false on failure; call SDL_GetError() for more
///          information.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_SetTimidityCfg(path: [*]const u8) bool;
pub const timidityCfgSet = Mix_SetTimidityCfg;

/// Get full path of a previously-specified Timidity config file.
///
/// For example, "/etc/timidity.cfg"
///
/// If a path has never been specified, this returns NULL.
///
/// This returns a pointer to internal memory, and it should not be modified or
/// free'd by the caller.
///
/// \returns the previously-specified path, or NULL if not set.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
/// \sa Mix_SetTimidityCfg
///
extern fn Mix_GetTimidityCfg() [*]const u8;
pub const timidityCfg = Mix_GetTimidityCfg;

/// Get the Mix_Chunk currently associated with a mixer channel.
///
/// You may not specify MAX_CHANNEL_POST or -1 for a channel.
///
/// \param channel the channel to query.
/// \returns the associated chunk, if any, or NULL if it's an invalid channel.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
extern fn Mix_GetChunk(channel: c_int) *Chunk;
pub const channelChunk = Mix_GetChunk;

/// Close the mixer, halting all playing audio.
///
/// Any halted channels will have any currently-registered effects
/// deregistered, and will call any callback specified by Mix_ChannelFinished()
/// before this function returns.
///
/// Any halted music will call any callback specified by
/// Mix_HookMusicFinished() before this function returns.
///
/// Do not start any new audio playing during callbacks in this function.
///
/// This will close the audio device. Attempting to play new audio after this
/// function returns will fail, until another successful call to
/// Mix_OpenAudio().
///
/// Note that (unlike Mix_OpenAudio optionally calling SDL_Init(SDL_INIT_AUDIO)
/// on the app's behalf), this will _not_ deinitialize the SDL audio subsystem
/// in any case. At some point after calling this function and Mix_Quit(), some
/// part of the application should be responsible for calling SDL_Quit() to
/// deinitialize all of SDL, including its audio subsystem.
///
/// This function should be the last thing you call in SDL_mixer before
/// Mix_Quit(). However, the following notes apply if you don't follow this
/// advice:
///
/// Note that this will not free any loaded chunks or music; you should dispose
/// of those resources separately. It is probably poor form to dispose of them
/// _after_ this function, but it is safe to call Mix_FreeChunk() and
/// Mix_FreeMusic() after closing the device.
///
/// Note that any chunks or music you don't free may or may not work if you
/// call Mix_OpenAudio again, as the audio device may be in a new format and
/// the existing chunks will not be converted to match.
///
/// \since This function is available since SDL_mixer 3.0.0.
///
/// \sa Mix_Quit
///
extern fn Mix_CloseAudio() void;
pub const close = Mix_CloseAudio;
