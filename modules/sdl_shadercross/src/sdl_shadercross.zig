//! [see](../SDL_shadercross/include/SDL3_shadercross/SDL_shadercross.h)

const sdl = @import("sdl");
const std = @import("std");

pub const Error = error {
    CompileFailure,
    TranspileFailure,
    ReflectFailure,
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
pub const init = SDL_ShaderCross_Init;

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
};

pub const Hlsl = struct {
    source: [*:0]const u8,
    entrypoint: [*:0]const u8,
    include_dir: [*:0]const u8 = null,
    defines: [][*:0]u8 = null,
};

pub fn transpileFromSpirv(to: ShaderLanguage, stage: ShaderStage, spirv: Spirv) [*:0]const u8 {
    switch(to) {
        .hlsl => return SDL_ShaderCross_TranspileHLSLFromSPIRV(spirv.bytecode.ptr, spirv.bytecode.len, spirv.entrypoint, stage),
        .msl => return SDL_ShaderCross_TranspileMSLFromSPIRV(spirv.bytecode.ptr, spirv.bytecode.len, spirv.entrypoint, stage),
        else => @compileError("Transpilation languages not supported"),
    }
}

/// Compile bytecode 
///
/// You must SDL_free the returned buffer once you are done with it.
///
pub fn compileFromSpirv(to: ShaderLanguage, stage: ShaderStage, spirv: Spirv) []const u8 {
    var size: *usize = undefined;
    var ptr: [*]const u8 = undefined;
    switch(to) {
        .dxbc => ptr = SDL_ShaderCross_CompileDXBCFromSPIRV(spirv.bytecode.ptr, spirv.bytecode.len, spirv.entrypoint, stage, &size),
        .msl => ptr = SDL_ShaderCross_CompileDXILFromSPIRV(spirv.bytecode.ptr, spirv.bytecode.len, spirv.entrypoint, stage, &size),
        else => @compileError("Compilation to language not supported"),
    }
    return ptr[0..size];
}

pub fn compileGraphicsShaderFromSpirv(device: *sdl.gpu.Device, stage: sdl.gpu.ShaderStage, params: Spirv, info: *GraphicsShaderInfo) Error!*sdl.gpu.Shader {
    return SDL_ShaderCross_CompileGraphicsShaderFromSPIRV(device, params.bytecode.ptr, params.bytecode.len, params.entrypoint, stage, info)
        orelse Error.CompileFailure;
}

pub fn compileComputePipelineFromSpirv(device: *sdl.gpu.Device, params: Spirv, info: *ComputePipelineInfo) Error!*sdl.gpu.ComputePipeline {
    return SDL_ShaderCross_CompileComputePipelineFromSPIRV(device, params.bytecode.ptr, params.bytecode.len, params.entrypoint, info)
        orelse Error.CompileFailure;
}

pub fn reflectGraphicsSpirv(bytecode: []const u8) Error!GraphicsShaderInfo {
    var info: GraphicsShaderInfo = undefined;
    if (!SDL_ShaderCross_ReflectGraphicsSPIRV(bytecode.ptr, bytecode.len, &info)) return Error.ReflectFailure;
    return info;
}

pub fn reflectComputeSpirv(bytecode: []const u8) Error!ComputePipelineInfo {
    var info: ComputePipelineInfo = undefined;
    if (!SDL_ShaderCross_ReflectGraphicsSPIRV(bytecode.ptr, bytecode.len, &info)) return Error.ReflectFailure;
    return info;
}

pub const getHlslShaderFormats = SDL_ShaderCross_GetHLSLShaderFormats;

pub fn compileFromHlsl(to: ShaderLanguage, stage: ShaderStage, hlsl: Hlsl) []const u8 {
    var size: *usize = undefined;
    var ptr: [*]const u8 = undefined;
    switch(to) {
        .dxbc => ptr = SDL_ShaderCross_CompileDXBCFromHLSL(hlsl.source, hlsl.entrypoint, hlsl.include_dir, hlsl.defines.ptr, @intCast(hlsl.defines.len), stage, &size),
        .msl => ptr = SDL_ShaderCross_CompileDXILFromHLSL(hlsl.source, hlsl.entrypoint, hlsl.include_dir, hlsl.defines.ptr, @intCast(hlsl.defines.len), stage, &size),
        .spirv => ptr = SDL_ShaderCross_CompileSPIRVFromHLSL(hlsl.source, hlsl.entrypoint, hlsl.include_dir, hlsl.defines.ptr, @intCast(hlsl.defines.len), stage, &size),
        else => @compileError("Compilation to language not supported"),
    }
    return ptr[0..size];
}

pub fn compileGraphicsShaderFromHlsl(device: *sdl.gpu.Device, stage: sdl.gpu.ShaderStage, hlsl: Hlsl, info: *GraphicsShaderInfo) *sdl.gpu.Shader {
    return SDL_ShaderCross_CompileGraphicsShaderFromHLSL(device, hlsl.source, hlsl.entrypoint, hlsl.include_dir, hlsl.defines.ptr, @intCast(hlsl.defines.len), stage, info);
}

pub fn compileComputePipelineFromHlsl(device: *sdl.gpu.Device, hlsl: Hlsl, info: *GraphicsShaderInfo) *sdl.gpu.ComputePipeline {
    return SDL_ShaderCross_CompileGraphicsShaderFromHLSL(device, hlsl.source, hlsl.entrypoint, hlsl.include_dir, hlsl.defines.ptr, @intCast(hlsl.defines.len), info);
}

// Begin bindings

pub const ShaderStage = enum (c_int) {
    vertex,
    fragment,
    compute
};

pub const GraphicsShaderInfo = extern struct {
    num_samplers: u32,
    num_storage_textures: u32,
    num_storage_buffers: u32,
    num_uniform_buffers: u32,
};

pub const ComputePipelineInfo = extern struct {
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


extern fn SDL_ShaderCross_Init() bool;

extern fn SDL_ShaderCross_Quit() void;

extern fn SDL_ShaderCross_GetSPIRVShaderFormats() sdl.gpu.ShaderFormat;

extern fn SDL_ShaderCross_TranspileHLSLFromSPIRV(
    bytecode: [*]const u8,
    bytecode_size: usize,
    entrypoint: [*]const u8,
    shader_stage: ShaderStage,
) [*:0]u8;

extern fn SDL_ShaderCross_TranspileMSLFromSPIRV(
    bytecode: [*]const u8,
    bytecode_size: usize,
    entrypoint: [*]const u8,
    shader_stage: ShaderStage) [*:0]u8;

extern fn SDL_ShaderCross_CompileDXBCFromSPIRV(
    bytecode: [*]const u8,
    bytecode_size: usize,
    entrypoint: [*]const u8,
    shader_stage: ShaderStage,
    size: *usize) [*:0]u8;

extern fn SDL_ShaderCross_CompileDXILFromSPIRV(
    bytecode: [*]const u8,
    bytecode_size: usize,
    entrypoint: [*]const u8,
    shader_stage: ShaderStage,
    size: *usize) [*:0]u8;

extern fn SDL_ShaderCross_CompileGraphicsShaderFromSPIRV(
    device: *sdl.gpu.Device,
    bytecode: [*]const u8,
    bytecode_size: usize,
    entrypoint: [*]const u8,
    shader_stage: sdl.gpu.ShaderStage,
    info: *GraphicsShaderInfo) ?*sdl.gpu.Shader;

extern fn SDL_ShaderCross_CompileComputePipelineFromSPIRV(
    device: *sdl.gpu.Device,
    bytecode: [*]const u8,
    bytecode_size: usize,
    entrypoint: [*]const u8,
    shader_stage: sdl.gpu.ShaderStage,
    info: *ComputePipelineInfo) ?*sdl.gpu.ComputePipeline;


extern fn SDL_ShaderCross_ReflectGraphicsSPIRV(
    bytecode: [*]const u8,
    bytecode_size: usize,
    info: *GraphicsShaderInfo) bool;

extern fn SDL_ShaderCross_ReflectComputeSPIRV(
    bytecode: [*]const u8,
    bytecode_size: usize,
    info: *ComputePipelineInfo) bool;

extern fn SDL_ShaderCross_GetHLSLShaderFormats() sdl.gpu.ShaderFormat;

extern fn SDL_ShaderCross_CompileDXBCFromHLSL(
    hlsl_source: [*]const u8,
    entrypoint: [*]const u8,
    include_dir: [*]const u8,
    defines: [*][*]const u8,
    num_defines: u32,
    stage: ShaderStage,
    size: *usize) [*]u8;

extern fn SDL_ShaderCross_CompileDXILFromHLSL(
    hlsl_source: [*]const u8,
    entrypoint: [*]const u8,
    include_dir: [*]const u8,
    defines: [*][*]const u8,
    num_defines: u32,
    stage: ShaderStage,
    size: *usize) [*]u8;

extern fn SDL_ShaderCross_CompileSPIRVFromHLSL(
    hlsl_source: [*]const u8,
    entrypoint: [*]const u8,
    include_dir: [*]const u8,
    defines: [*][*]const u8,
    num_defines: u32,
    stage: ShaderStage,
    size: *usize) [*]u8;

extern fn SDL_ShaderCross_CompileGraphicsShaderFromHLSL(
    device: *sdl.gpu.Device,
    hlsl_source: [*]const u8,
    entrypoint: [*]const u8,
    include_dir: [*]const u8,
    defines: [*][*]const u8,
    stage: ShaderStage,
    info: *GraphicsShaderInfo) ?*sdl.gpu.Shader;

extern fn SDL_ShaderCross_CompileComputePipelineFromHLSL(
    device: *sdl.gpu.Device,
    hlsl_source: [*]const u8,
    entrypoint: [*]const u8,
    include_dir: [*]const u8,
    defines: [*][*]const u8,
    stage: ShaderStage,
    info: *ComputePipelineInfo) ?*sdl.gpu.ComputePipeline;


