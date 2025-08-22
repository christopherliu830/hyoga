//! [see](../SDL_shadercross/include/SDL3_shadercross/SDL_shadercross.h)

const sdl = @import("sdl");
const std = @import("std");

pub const Error = error{
    InitFailure,
    ShaderCompileFailure,
    ShaderTranspileFailure,
    ShaderReflectFailure,
};

pub const ShaderLanguage = enum {
    spirv,
    hlsl,
    msl,
    dxbc,
    dxil,
};

/// Initializes SDL_gpu_shadercross
///
/// \threadsafety This should only be called once, from a single thread.
///
pub fn init() Error!void {
    if (!SDL_ShaderCross_Init()) return Error.InitFailure;
}

/// De-initializes SDL_gpu_shadercross
///
/// \threadsafety This should only be called once, from a single thread.
///
pub const quit = SDL_ShaderCross_Quit;

/// Get the supported shader formats that SPIRV cross-compilation can output
///
/// \threadsafety It is safe to call this function from any thread.
///
pub const getSpirvShaderFormats = SDL_ShaderCross_GetSPIRVShaderFormats;

pub const Spirv = struct {
    bytecode: []const u8,
    entrypoint: [*:0]const u8,
    debug: bool = false,
    name: ?[*]const u8 = null,
    props: sdl.PropertiesID = 0,
};

pub const Hlsl = struct {
    source: [*:0]const u8,
    entrypoint: [*:0]const u8,
    include_dir: [*:0]const u8 = null,
    defines: []HlslDefine = &.{},
};

pub fn transpileFromSpirv(to: ShaderLanguage, stage: ShaderStage, spirv: Spirv) [:0]const u8 {
    var ptr: [*]const u8 = undefined;
    const info = SpirvInfo{
        .bytecode = spirv.bytecode.ptr,
        .size = spirv.bytecode.len,
        .entrypoint = spirv.entrypoint,
        .stage = stage,
        .enable_debug = spirv.debug,
        .name = spirv.name,
        .props = spirv.props,
    };
    switch (to) {
        .hlsl => ptr = SDL_ShaderCross_TranspileHLSLFromSPIRV(&info),
        .msl => ptr = SDL_ShaderCross_TranspileMSLFromSPIRV(&info),
        else => @compileError("Transpilation languages not supported"),
    }
    return std.mem.span(ptr);
}

/// Compile bytecode
///
/// You must SDL_free the returned buffer once you are done with it.
///
pub fn compileFromSpirv(to: ShaderLanguage, stage: ShaderStage, spirv: Spirv) []const u8 {
    var size: *usize = undefined;
    var ptr: [*]const u8 = undefined;

    const info = SpirvInfo{
        .bytecode = spirv.bytecode.ptr,
        .size = spirv.bytecode.len,
        .entrypoint = spirv.entrypoint,
        .stage = stage,
        .enable_debug = spirv.debug,
        .name = spirv.name,
        .props = spirv.props,
    };

    switch (to) {
        .dxbc => ptr = SDL_ShaderCross_CompileDXBCFromSPIRV(&info, &size),
        .msl => ptr = SDL_ShaderCross_CompileDXILFromSPIRV(&info, &size),
        else => @compileError("Compilation to language not supported"),
    }
    return ptr[0..size];
}

pub fn compileGraphicsShaderFromSpirv(device: *sdl.gpu.Device, stage: ShaderStage, spirv: Spirv, metadata: *GraphicsShaderMetadata) Error!*sdl.gpu.Shader {
    const info: SpirvInfo = .{
        .bytecode = spirv.bytecode.ptr,
        .size = spirv.bytecode.len,
        .entrypoint = spirv.entrypoint,
        .shader_stage = stage,
        .enable_debug = spirv.debug,
        .name = spirv.name,
        .props = spirv.props,
    };
    return SDL_ShaderCross_CompileGraphicsShaderFromSPIRV(device, &info, metadata, 0) orelse {
        std.log.err("Error compiling shader from spirv: {s}", .{sdl.getError()});
        return Error.ShaderCompileFailure;
    };
}

pub fn compileComputePipelineFromSpirv(device: *sdl.gpu.Device, stage: ShaderStage, spirv: Spirv, metadata: *GraphicsShaderMetadata) Error!*sdl.gpu.Shader {
    const info = SpirvInfo{
        .bytecode = spirv.bytecode.ptr,
        .size = spirv.bytecode.len,
        .entrypoint = spirv.entrypoint,
        .shader_stage = stage,
        .enable_debug = spirv.debug,
        .name = spirv.name,
        .props = spirv.props,
    };

    return SDL_ShaderCross_CompileComputePipelineFromSPIRV(device, &info, metadata) orelse {
        std.log.err("Error compiling shader from spirv: {s}", .{sdl.getError()});
        return Error.ShaderCompileFailure;
    };
}

pub fn reflectGraphicsSpirv(bytecode: []const u8) Error!*GraphicsShaderMetadata {
    if (SDL_ShaderCross_ReflectGraphicsSPIRV(bytecode.ptr, bytecode.len, 0)) |metadata| {
        return metadata;
    } else {
        std.log.err("Error reflect graphics spirv {s}", .{sdl.getError()});
        return Error.ShaderReflectFailure;
    }
}

pub fn reflectComputeSpirv(bytecode: []const u8) Error!*ComputePipelineMetadata {
    if (!SDL_ShaderCross_ReflectComputeSPIRV(bytecode.ptr, bytecode.len, 0)) |metadata| {
        return metadata;
    } else {
        return Error.ShaderReflectFailure;
    }
}

pub const getHlslShaderFormats = SDL_ShaderCross_GetHLSLShaderFormats;

pub fn compileFromHlsl(to: ShaderLanguage, stage: ShaderStage, hlsl: Hlsl) []const u8 {
    var size: *usize = undefined;
    var ptr: [*]const u8 = undefined;

    const info = HlslInfo{
        .source = hlsl.source,
        .entrypoint = hlsl.entrypoint,
        .include_dir = hlsl.include_dir,
        .defines = if (hlsl.defines.len > 0) hlsl.defines.ptr else null,
        .shader_stage = stage,
        .name = hlsl.name,
        .props = hlsl.props,
    };

    switch (to) {
        .dxbc => ptr = SDL_ShaderCross_CompileDXBCFromHLSL(&info, &size),
        .msl => ptr = SDL_ShaderCross_CompileDXILFromHLSL(&info, &size),
        .spirv => ptr = SDL_ShaderCross_CompileSPIRVFromHLSL(&info, &size),
        else => @compileError("Compilation to language not supported"),
    }
    return ptr[0..size];
}

// Begin bindings

pub const ShaderStage = enum(c_int) { vertex, fragment, compute };

pub const IOVarType = enum(c_int) {
    unknown,
    int8,
    uint8,
    int16,
    uint16,
    int32,
    uint32,
    int64,
    uint64,
    float16,
    float32,
    float64,
};

pub const IOVarMetadata = extern struct {
    name: [*]const u8,
    location: u32,
    vector_type: IOVarType,
    vector_size: u32,
};

pub const GraphicsShaderMetadata = extern struct {
    num_samplers: u32,
    num_storage_textures: u32,
    num_storage_buffers: u32,
    num_uniform_buffers: u32,
    num_inputs: u32,
    inputs: [*]IOVarMetadata,
    num_outputs: u32,
    outputs: [*]IOVarMetadata,
};

pub const ComputePipelineMetadata = extern struct {
    num_samplers: u32,
    num_read_only_storage_textures: u32,
    num_read_only_storage_buffers: u32,
    num_read_write_storage_textures: u32,
    num_read_write_storage_buffers: u32,
    num_uniform_buffers: u32,
    thread_count_x: u32,
    thread_count_y: u32,
    thread_count_z: u32,
};

pub const SpirvInfo = extern struct {
    bytecode: [*]const u8,
    size: usize,
    entrypoint: [*]const u8,
    shader_stage: ShaderStage,
    enable_debug: bool,
    name: ?[*]const u8,
    props: sdl.PropertiesID,
};

pub const HlslDefine = extern struct {
    name: ?[*]u8 = null,
    value: ?[*]u8 = null,
};

pub const HlslInfo = extern struct {
    source: *const u8,
    entrypoint: *const u8,
    include_dir: *const u8,
    defines: ?[*]HlslDefine, // If not null, must be an array of defines that terminates with a fully NULL struct.
    shader_stage: ShaderStage,
    enable_debug: bool,
    name: ?*const u8,
    props: sdl.PropertiesID,
};

extern fn SDL_ShaderCross_Init() bool;

extern fn SDL_ShaderCross_Quit() void;

extern fn SDL_ShaderCross_GetSPIRVShaderFormats() sdl.gpu.ShaderFormat;

extern fn SDL_ShaderCross_TranspileMSLFromSPIRV(info: *const SpirvInfo) [*:0]u8;
extern fn SDL_ShaderCross_TranspileHLSLFromSPIRV(info: *const SpirvInfo) [*:0]u8;
extern fn SDL_ShaderCross_CompileDXBCFromSPIRV(info: *const SpirvInfo, size: *usize) [*:0]u8;
extern fn SDL_ShaderCross_CompileDXILFromSPIRV(info: *const SpirvInfo, size: *usize) [*:0]u8;
extern fn SDL_ShaderCross_CompileGraphicsShaderFromSPIRV(device: *sdl.gpu.Device, info: *const SpirvInfo, metadata: *const GraphicsShaderMetadata, props: sdl.PropertiesID) ?*sdl.gpu.Shader;
extern fn SDL_ShaderCross_CompileComputePipelineFromSPIRV(device: *sdl.gpu.Device, info: *SpirvInfo, metadata: *const ComputePipelineMetadata, props: sdl.PropertiesID) ?*sdl.gpu.ComputePipeline;
extern fn SDL_ShaderCross_ReflectGraphicsSPIRV(bytecode: [*]const u8, bytecode_size: usize, props: sdl.PropertiesID) ?*GraphicsShaderMetadata;
extern fn SDL_ShaderCross_ReflectComputeSPIRV(bytecode: [*]const u8, bytecode_size: usize, props: sdl.PropertiesID) ?*ComputePipelineMetadata;
extern fn SDL_ShaderCross_GetHLSLShaderFormats() sdl.gpu.ShaderFormat;
extern fn SDL_ShaderCross_CompileDXBCFromHLSL(info: *const HlslInfo, size: *usize) [*]u8;
extern fn SDL_ShaderCross_CompileDXILFromHLSL(info: *const HlslInfo, size: *usize) [*]u8;
extern fn SDL_ShaderCross_CompileSPIRVFromHLSL(info: *const HlslInfo, size: *usize) [*]u8;
