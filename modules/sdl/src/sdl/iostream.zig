const PropertiesID = @import("properties.zig").PropertiesID;

pub const Status = enum(c_int) {
    ready,
    @"error",
    eof,
    not_ready,
    readonly,
    writeonly,
};

pub const Whence = enum(c_int) {
    set,
    cur,
    end,
};

pub const Interface = extern struct {
    version: u32,
    size: ?*const fn (userdata: ?*anyopaque) callconv(.C) i64,
    seek: ?*const fn (userdata: ?*anyopaque, offset: i64, whence: Whence) callconv(.C) i64,

    /// Read up to `size` bytes from the data stream to the area pointed
    /// at by `ptr`.
    ///
    /// On an incomplete read, you should set `*status` to a value from the
    /// SDL_IOStatus enum. You do not have to explicitly set this on
    /// a complete, successful read.
    ///
    /// \return the number of bytes read
    ///
    read: ?*const fn (userdata: ?*anyopaque, ptr: ?*anyopaque, size: usize, status: *Status) callconv(.C) usize,

    /// Write exactly `size` bytes from the area pointed at by `ptr`
    /// to data stream.
    ///
    /// On an incomplete write, you should set `*status` to a value from the
    /// SDL_IOStatus enum. You do not have to explicitly set this on
    /// a complete, successful write.
    ///
    /// \return the number of bytes written
    ///
    write: ?*const fn (userdata: ?*anyopaque, ptr: ?*const anyopaque, size: usize, status: *Status) callconv(.C) usize,

    /// If the stream is buffering, make sure the data is written out.
    ///
    /// On failure, you should set `*status` to a value from the
    /// SDL_IOStatus enum. You do not have to explicitly set this on
    /// a successful flush.
    ///
    /// \return true if successful or false on write error when flushing data.
    ///
    flush: ?*const fn (userdata: ?*anyopaque, *Status) callconv(.C) bool,

    /// Close and free any allocated resources.
    ///
    /// This does not guarantee file writes will sync to physical media; they
    /// can be in the system's file cache, waiting to go to disk.
    ///
    /// The SDL_IOStream is still destroyed even if this fails, so clean up anything
    /// even if flushing buffers, etc, returns an error.
    ///
    /// \return true if successful or false on write error when flushing data.
    ///
    close: ?*const fn (userdata: ?*anyopaque) callconv(.C) bool,
};

pub const Stream = opaque {};

pub const fromFile = SDL_IOFromFile;
pub extern fn SDL_IOFromFile(file: [*c]const u8, mode: [*c]const u8) ?*Stream;

pub extern fn SDL_IOFromMem(mem: ?*anyopaque, size: usize) ?*Stream;
pub const fromMem = SDL_IOFromMem;

pub extern fn SDL_IOFromConstMem(mem: ?*const anyopaque, size: usize) ?*Stream;
pub const fromConstMem = SDL_IOFromConstMem;

pub extern fn SDL_IOFromDynamicMem() ?*Stream;
pub const fromDynamicMem = SDL_IOFromDynamicMem;

pub extern fn SDL_OpenIO(iface: [*c]const Interface, userdata: ?*anyopaque) ?*Stream;
pub const open = SDL_OpenIO;

pub extern fn SDL_CloseIO(context: ?*Stream) bool;
pub const close = SDL_CloseIO;

pub extern fn SDL_GetIOProperties(context: ?*Stream) PropertiesID;
pub const properties = SDL_GetIOProperties;

pub extern fn SDL_GetIOStatus(context: ?*Stream) Status;
pub const status = SDL_GetIOStatus;

pub extern fn SDL_GetIOSize(context: ?*Stream) i64;
pub const size = SDL_GetIOSize;

pub extern fn SDL_SeekIO(context: ?*Stream, offset: i64, whence: Whence) i64;
pub const seek = SDL_SeekIO;

pub extern fn SDL_TellIO(context: ?*Stream) i64;
pub const tell = SDL_TellIO;

pub extern fn SDL_ReadIO(context: ?*Stream, ptr: ?*anyopaque, size: usize) usize;
pub const read = SDL_ReadIO;

pub extern fn SDL_WriteIO(context: ?*Stream, ptr: ?*const anyopaque, size: usize) usize;
pub const write = SDL_WriteIO;

pub extern fn SDL_IOprintf(context: ?*Stream, fmt: [*c]const u8, ...) usize;
pub const printf = SDL_IOprintf;

pub extern fn SDL_IOvprintf(context: ?*Stream, fmt: [*c]const u8, ap: [*c]u8) usize;
pub const vprintf = SDL_IOvprintf;

pub extern fn SDL_FlushIO(context: ?*Stream) bool;
pub const flush = SDL_FlushIO;

pub extern fn SDL_LoadFile_IO(src: ?*Stream, datasize: [*c]usize, closeio: bool) ?*anyopaque;
pub const loadFileIO = SDL_LoadFile_IO;

pub extern fn SDL_LoadFile(file: [*c]const u8, datasize: [*c]usize) ?*anyopaque;
pub const loadFile = SDL_LoadFile;

pub extern fn SDL_ReadU8(src: ?*Stream, value: [*c]u8) bool;
pub const readU8 = SDL_ReadU8;

pub extern fn SDL_ReadS8(src: ?*Stream, value: [*c]i8) bool;
pub const readS8 = SDL_ReadS8;

pub extern fn SDL_ReadU16LE(src: ?*Stream, value: [*c]u16) bool;
pub const readU16LE = SDL_ReadU16LE;

pub extern fn SDL_ReadS16LE(src: ?*Stream, value: [*c]i16) bool;
pub const readS16LE = SDL_ReadS16LE;

pub extern fn SDL_ReadU16BE(src: ?*Stream, value: [*c]u16) bool;
pub const readU16BE = SDL_ReadU16BE;

pub extern fn SDL_ReadS16BE(src: ?*Stream, value: [*c]i16) bool;
pub const readS16BE = SDL_ReadS16BE;

pub extern fn SDL_ReadU32LE(src: ?*Stream, value: [*c]u32) bool;
pub const readU32LE = SDL_ReadU32LE;

pub extern fn SDL_ReadS32LE(src: ?*Stream, value: [*c]i32) bool;
pub const readS32LE = SDL_ReadS32LE;

pub extern fn SDL_ReadU32BE(src: ?*Stream, value: [*c]u32) bool;
pub const readU32BE = SDL_ReadU32BE;

pub extern fn SDL_ReadS32BE(src: ?*Stream, value: [*c]i32) bool;
pub const readS32BE = SDL_ReadS32BE;

pub extern fn SDL_ReadU64LE(src: ?*Stream, value: [*c]u64) bool;
pub const readU64LE = SDL_ReadU64LE;

pub extern fn SDL_ReadS64LE(src: ?*Stream, value: [*c]i64) bool;
pub const readS64LE = SDL_ReadS64LE;

pub extern fn SDL_ReadU64BE(src: ?*Stream, value: [*c]u64) bool;
pub const readU64BE = SDL_ReadU64BE;

pub extern fn SDL_ReadS64BE(src: ?*Stream, value: [*c]i64) bool;
pub const readS64BE = SDL_ReadS64BE;

pub extern fn SDL_WriteU8(dst: ?*Stream, value: u8) bool;
pub const writeU8 = SDL_WriteU8;

pub extern fn SDL_WriteS8(dst: ?*Stream, value: i8) bool;
pub const writeS8 = SDL_WriteS8;

pub extern fn SDL_WriteU16LE(dst: ?*Stream, value: u16) bool;
pub const writeU16LE = SDL_WriteU16LE;

pub extern fn SDL_WriteS16LE(dst: ?*Stream, value: i16) bool;
pub const writeS16LE = SDL_WriteS16LE;

pub extern fn SDL_WriteU16BE(dst: ?*Stream, value: u16) bool;
pub const writeU16BE = SDL_WriteU16BE;

pub extern fn SDL_WriteS16BE(dst: ?*Stream, value: i16) bool;
pub const writeS16BE = SDL_WriteS16BE;

pub extern fn SDL_WriteU32LE(dst: ?*Stream, value: u32) bool;
pub const writeU32LE = SDL_WriteU32LE;

pub extern fn SDL_WriteS32LE(dst: ?*Stream, value: i32) bool;
pub const writeS32LE = SDL_WriteS32LE;

pub extern fn SDL_WriteU32BE(dst: ?*Stream, value: u32) bool;
pub const writeU32BE = SDL_WriteU32BE;

pub extern fn SDL_WriteS32BE(dst: ?*Stream, value: i32) bool;
pub const writeS32BE = SDL_WriteS32BE;

pub extern fn SDL_WriteU64LE(dst: ?*Stream, value: u64) bool;
pub const writeU64LE = SDL_WriteU64LE;

pub extern fn SDL_WriteS64LE(dst: ?*Stream, value: i64) bool;
pub const writeS64LE = SDL_WriteS64LE;

pub extern fn SDL_WriteU64BE(dst: ?*Stream, value: u64) bool;
pub const writeU64BE = SDL_WriteU64BE;

pub extern fn SDL_WriteS64BE(dst: ?*Stream, value: i64) bool;
pub const writeS64BE = SDL_WriteS64BE;
