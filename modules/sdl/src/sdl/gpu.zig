const PixelFormat = @import("pixels.zig").PixelFormat;
const FColor = @import("pixels.zig").FColor;
pub const Rect = @import("rect.zig").Rect;
const PropertiesID = @import("properties.zig").PropertiesID;
const FlipMode = @import("surface.zig").FlipMode;
const Window = @import("video.zig").Window;

pub const SDLError = error {
    CreateTextureFailure,
    CreateBufferFailure,
};

pub const DeviceHdl = *Device;

pub const Device = opaque {
    pub const destroy = SDL_DestroyGPUDevice;
    pub const getDeviceDriver = SDL_GetGPUDeviceDriver;
    pub const getShaderFormats = SDL_GetGPUShaderFormats;
    pub const createComputePipeline = SDL_CreateGPUComputePipeline;
    pub const createGraphicsPipeline = SDL_CreateGPUGraphicsPipeline;
    pub const createSampler = SDL_CreateGPUSampler;
    pub const createShader = SDL_CreateGPUShader;

    pub fn createTexture(device: DeviceHdl, createinfo: *const TextureCreateInfo) SDLError!*Texture {
        return SDL_CreateGPUTexture(device, createinfo) orelse SDLError.CreateTextureFailure;
    }

    pub fn createBuffer(device: DeviceHdl, createinfo: *const BufferCreateInfo) SDLError!*Buffer {
        return SDL_CreateGPUBuffer(device, createinfo) orelse SDLError.CreateBufferFailure;
    }

    pub const createTransferBuffer = SDL_CreateGPUTransferBuffer;
    pub const setBufferName = SDL_SetGPUBufferName;
    pub const setTextureName = SDL_SetGPUTextureName;
    pub const releaseTexture = SDL_ReleaseGPUTexture;
    pub const releaseSampler = SDL_ReleaseGPUSampler;
    pub const releaseBuffer = SDL_ReleaseGPUBuffer;
    pub const releaseTransferBuffer = SDL_ReleaseGPUTransferBuffer;
    pub const releaseComputePipeline = SDL_ReleaseGPUComputePipeline;
    pub const releaseShader = SDL_ReleaseGPUShader;
    pub const releaseGraphicsPipeline = SDL_ReleaseGPUGraphicsPipeline;
    pub const acquireCommandBuffer = SDL_AcquireGPUCommandBuffer;
    pub const mapTransferBuffer = SDL_MapGPUTransferBuffer;
    pub const unmapTransferBuffer = SDL_UnmapGPUTransferBuffer;
    pub const windowSupportsSwapchainComposition = SDL_WindowSupportsGPUSwapchainComposition;
    pub const windowSupportsPresentMode = SDL_WindowSupportsGPUPresentMode;
    pub const claimWindow = SDL_ClaimWindowForGPUDevice;
    pub const releaseWindow = SDL_ReleaseWindowFromGPUDevice;
    pub const setSwapchainParameters = SDL_SetGPUSwapchainParameters;
    pub const setAllowedFramesInFlight = SDL_SetGPUAllowedFramesInFlight;
    pub const getSwapchainTextureFormat = SDL_GetGPUSwapchainTextureFormat;
    pub const waitForSwapchain = SDL_WaitForGPUSwapchain;
    pub const waitForIdle = SDL_WaitForGPUIdle;
    pub const waitForFences = SDL_WaitForGPUFences;
    pub const queryFence = SDL_QueryGPUFence;
    pub const releaseFence = SDL_ReleaseGPUFence;
    pub const textureSupportsFormat = SDL_GPUTextureSupportsFormat;
    pub const textureSupportsSampleCount = SDL_GPUTextureSupportsSampleCount;
    pub const gdkSuspend = SDL_GDKSuspendGPU;
    pub const gdkResume = SDL_GDKResumeGPU;
};

pub const Buffer = opaque {};

pub const TransferBuffer = opaque {};

pub const Texture = opaque {};

pub const Sampler = opaque {};

pub const Shader = opaque {};

pub const ComputePipeline = opaque {};

pub const GraphicsPipeline = opaque {};

pub const CommandBuffer = opaque {
    pub const insertDebugLabel = SDL_InsertGPUDebugLabel;
    pub const pushDebugGroup = SDL_PushGPUDebugGroup;
    pub const popDebugGroup = SDL_PopGPUDebugGroup;
    pub const pushVertexUniformData = SDL_PushGPUVertexUniformData;
    pub const pushFragmentUniformData = SDL_PushGPUFragmentUniformData;
    pub const pushComputeUniformData = SDL_PushGPUComputeUniformData;
    pub const beginRenderPass = SDL_BeginGPURenderPass;
    pub const beginComputePass = SDL_BeginGPUComputePass;
    pub const beginCopyPass = SDL_BeginGPUCopyPass;
    pub const generateMipmapsForTexture = SDL_GenerateMipmapsForGPUTexture;
    pub const blitTexture = SDL_BlitGPUTexture;
    pub const acquireSwapchainTexture = SDL_AcquireGPUSwapchainTexture;
    pub const waitAndAcquireSwapchainTexture = SDL_WaitAndAcquireGPUSwapchainTexture;
    pub const submit = SDL_SubmitGPUCommandBuffer;
    pub const submitAndAcquireFence = SDL_SubmitGPUCommandBufferAndAcquireFence;
    pub const cancel = SDL_CancelGPUCommandBuffer;
};

pub const RenderPass = opaque {
    pub const bindGraphicsPipeline = SDL_BindGPUGraphicsPipeline;
    pub const setViewport = SDL_SetGPUViewport;
    pub const setScissor = SDL_SetGPUScissor;
    pub const setBlendConstants = SDL_SetGPUBlendConstants;
    pub const setStencilReference = SDL_SetGPUStencilReference;
    pub const bindVertexBuffers = SDL_BindGPUVertexBuffers;
    pub const bindIndexBuffer = SDL_BindGPUIndexBuffer;
    pub const bindVertexSamplers = SDL_BindGPUVertexSamplers;
    pub const bindVertexStorageTextures = SDL_BindGPUVertexStorageTextures;
    pub const bindVertexStorageBuffers = SDL_BindGPUVertexStorageBuffers;
    pub const bindFragmentSamplers = SDL_BindGPUFragmentSamplers;
    pub const bindFragmentStorageTextures = SDL_BindGPUFragmentStorageTextures;
    pub const bindFragmentStorageBuffers = SDL_BindGPUFragmentStorageBuffers;
    pub const drawIndexedPrimitives = SDL_DrawGPUIndexedPrimitives;
    pub const drawPrimitives = SDL_DrawGPUPrimitives;
    pub const drawPrimitivesIndirect = SDL_DrawGPUPrimitivesIndirect;
    pub const drawIndexedPrimitivesIndirect = SDL_DrawGPUIndexedPrimitivesIndirect;
    pub const end = SDL_EndGPURenderPass;
};

pub const ComputePass = opaque {
    pub const bindPipeline = SDL_BindGPUComputePipeline;
    pub const bindSamplers = SDL_BindGPUComputeSamplers;
    pub const bindStorageTextures = SDL_BindGPUComputeStorageTextures;
    pub const bindStorageBuffers = SDL_BindGPUComputeStorageBuffers;
    pub const dispatch = SDL_DispatchGPUCompute;
    pub const dispatchIndirect = SDL_DispatchGPUComputeIndirect;
    pub const end = SDL_EndGPUComputePass;
};

pub const CopyPass = opaque {
    pub const uploadToTexture = SDL_UploadToGPUTexture;
    pub const uploadToBuffer = SDL_UploadToGPUBuffer;
    pub const copyTextureToTexture = SDL_CopyGPUTextureToTexture;
    pub const copyBufferToBuffer = SDL_CopyGPUBufferToBuffer;
    pub const downloadFromTexture = SDL_DownloadFromGPUTexture;
    pub const downloadFromBuffer = SDL_DownloadFromGPUBuffer;
    pub const end = SDL_EndGPUCopyPass;
};

pub const Fence = opaque {};

pub const PrimitiveType = enum(c_uint) {
    trianglelist,
    trianglestrip,
    linelist,
    linestrip,
    pointlist,
};

pub const LoadOp = enum(c_uint) {
    load,
    clear,
    dont_care,
};

pub const StoreOp = enum(c_uint) {
    store,
    dont_care,
    resolve,
    resolve_and_store,
};

pub const IndexElementSize = enum(c_uint) {
    @"16bit",
    @"32bit",
};

pub const TextureFormat = enum(c_uint) {
    invalid,
    a8_unorm,
    r8_unorm,
    r8g8_unorm,
    r8g8b8a8_unorm,
    r16_unorm,
    r16g16_unorm,
    r16g16b16a16_unorm,
    r10g10b10a2_unorm,
    b5g6r5_unorm,
    b5g5r5a1_unorm,
    b4g4r4a4_unorm,
    b8g8r8a8_unorm,
    bc1_rgba_unorm,
    bc2_rgba_unorm,
    bc3_rgba_unorm,
    bc4_r_unorm,
    bc5_rg_unorm,
    bc7_rgba_unorm,
    bc6h_rgb_float,
    bc6h_rgb_ufloat,
    r8_snorm,
    r8g8_snorm,
    r8g8b8a8_snorm,
    r16_snorm,
    r16g16_snorm,
    r16g16b16a16_snorm,
    r16_float,
    r16g16_float,
    r16g16b16a16_float,
    r32_float,
    r32g32_float,
    r32g32b32a32_float,
    r11g11b10_ufloat,
    r8_uint,
    r8g8_uint,
    r8g8b8a8_uint,
    r16_uint,
    r16g16_uint,
    r16g16b16a16_uint,
    r32_uint,
    r32g32_uint,
    r32g32b32a32_uint,
    r8_int,
    r8g8_int,
    r8g8b8a8_int,
    r16_int,
    r16g16_int,
    r16g16b16a16_int,
    r32_int,
    r32g32_int,
    r32g32b32a32_int,
    r8g8b8a8_unorm_srgb,
    b8g8r8a8_unorm_srgb,
    bc1_rgba_unorm_srgb,
    bc2_rgba_unorm_srgb,
    bc3_rgba_unorm_srgb,
    bc7_rgba_unorm_srgb,
    d16_unorm,
    d24_unorm,
    d32_float,
    d24_unorm_s8_uint,
    d32_float_s8_uint,
    astc_4x4_unorm,
    astc_5x4_unorm,
    astc_5x5_unorm,
    astc_6x5_unorm,
    astc_6x6_unorm,
    astc_8x5_unorm,
    astc_8x6_unorm,
    astc_8x8_unorm,
    astc_10x5_unorm,
    astc_10x6_unorm,
    astc_10x8_unorm,
    astc_10x10_unorm,
    astc_12x10_unorm,
    astc_12x12_unorm,
    astc_4x4_unorm_srgb,
    astc_5x4_unorm_srgb,
    astc_5x5_unorm_srgb,
    astc_6x5_unorm_srgb,
    astc_6x6_unorm_srgb,
    astc_8x5_unorm_srgb,
    astc_8x6_unorm_srgb,
    astc_8x8_unorm_srgb,
    astc_10x5_unorm_srgb,
    astc_10x6_unorm_srgb,
    astc_10x8_unorm_srgb,
    astc_10x10_unorm_srgb,
    astc_12x10_unorm_srgb,
    astc_12x12_unorm_srgb,
    astc_4x4_float,
    astc_5x4_float,
    astc_5x5_float,
    astc_6x5_float,
    astc_6x6_float,
    astc_8x5_float,
    astc_8x6_float,
    astc_8x8_float,
    astc_10x5_float,
    astc_10x6_float,
    astc_10x8_float,
    astc_10x10_float,
    astc_12x10_float,
    astc_12x12_float,
};

pub const TextureType = enum(c_uint) {
    @"2d",
    @"2d_array",
    @"3d",
    cube,
    cube_array,
};

pub const SampleCount = enum(c_uint) {
    @"1",
    @"2",
    @"4",
    @"8",
};

pub const CubeMapFace = enum(c_uint) {
    positivex,
    negativex,
    positivey,
    negativey,
    positivez,
    negativez,
};

pub const TransferBufferUsage = enum(c_uint) {
    upload,
    download,
};

pub const ShaderStage = enum(c_uint) {
    vertex,
    fragment,
};

pub const VertexElementFormat = enum(c_uint) {
    invalid,
    i32,
    int2,
    int3,
    int4,
    uint,
    uint2,
    uint3,
    uint4,
    f32,
    float2,
    float3,
    float4,
    byte2,
    byte4,
    ubyte2,
    ubyte4,
    byte2_norm,
    byte4_norm,
    ubyte2_norm,
    ubyte4_norm,
    short2,
    short4,
    ushort2,
    ushort4,
    short2_norm,
    short4_norm,
    ushort2_norm,
    ushort4_norm,
    half2,
    half4,
};

pub const VertexInputRate = enum(c_uint) {
    vertex,
    instance,
};

pub const FillMode = enum(c_uint) {
    fill,
    line,
};

pub const CullMode = enum(c_uint) {
    none,
    front,
    back,
};

pub const FrontFace = enum(c_uint) {
    counter_clockwise,
    clockwise,
};

pub const CompareOp = enum(c_uint) {
    invalid,
    never,
    less,
    equal,
    less_or_equal,
    greater,
    not_equal,
    greater_or_equal,
    always,
};

pub const StencilOp = enum(c_uint) {
    invalid,
    keep,
    zero,
    replace,
    increment_and_clamp,
    decrement_and_clamp,
    invert,
    increment_and_wrap,
    decrement_and_wrap,
};

pub const BlendOp = enum(c_uint) {
    invalid,
    add,
    subtract,
    reverse_subtract,
    min,
    max,
};

pub const BlendFactor = enum(c_uint) {
    invalid,
    zero,
    one,
    src_color,
    one_minus_src_color,
    dst_color,
    one_minus_dst_color,
    src_alpha,
    one_minus_src_alpha,
    dst_alpha,
    one_minus_dst_alpha,
    constant_color,
    one_minus_constant_color,
    src_alpha_saturate,
};

pub const Filter = enum(c_uint) {
    nearest,
    linear,
};

pub const SamplerMipmapMode = enum(c_uint) {
    nearest,
    linear,
};

pub const SamplerAddressMode = enum(c_uint) {
    repeat,
    mirrored_repeat,
    clamp_to_edge,
};

pub const PresentMode = enum(c_uint) {
    vsync,
    immediate,
    mailbox,
};

pub const SwapchainComposition = enum(c_uint) {
    sdr,
    sdr_linear,
    hdr_extended_linear,
    hdr10_st2084,
};

pub const TextureUsageFlags = packed struct(u32) {
    sampler: bool = false,
    color_target: bool = false,
    depth_stencil_target: bool = false,
    graphics_storage_read: bool = false,
    compute_storage_read: bool = false,
    compute_storage_write: bool = false,
    compute_storage_simultaneous_read_write: bool = false,
    _padding: u25 = 0,
};

pub const BufferUsageFlags = packed struct(u32) {
    vertex: bool = false,
    index: bool = false,
    indirect: bool = false,
    graphics_storage_read: bool = false,
    compute_storage_read: bool = false,
    compute_storage_write: bool = false,
    _padding: u26 = 0,
};

pub const ShaderFormat = packed struct(u32) {
    private: bool = false,
    spirv: bool = false,
    dxbc: bool = false,
    dxil: bool = false,
    msl: bool = false,
    metallib: bool = false,
    _padding: u26 = 0,
};

pub const ColorComponentFlags = packed struct(u8) {
    r: bool = false,
    g: bool = false,
    b: bool = false,
    a: bool = false,
    _padding: u4 = 0,
};

pub const Viewport = extern struct {
    x: f32 = @import("std").mem.zeroes(f32),
    y: f32 = @import("std").mem.zeroes(f32),
    w: f32 = @import("std").mem.zeroes(f32),
    h: f32 = @import("std").mem.zeroes(f32),
    min_depth: f32 = @import("std").mem.zeroes(f32),
    max_depth: f32 = @import("std").mem.zeroes(f32),
};

pub const TextureTransferInfo = extern struct {
    transfer_buffer: ?*TransferBuffer = @import("std").mem.zeroes(?*TransferBuffer),
    offset: u32 = @import("std").mem.zeroes(u32),
    pixels_per_row: u32 = @import("std").mem.zeroes(u32),
    rows_per_layer: u32 = @import("std").mem.zeroes(u32),
};

pub const TransferBufferLocation = extern struct {
    transfer_buffer: ?*TransferBuffer = @import("std").mem.zeroes(?*TransferBuffer),
    offset: u32 = @import("std").mem.zeroes(u32),
};

pub const TextureLocation = extern struct {
    texture: ?*Texture = @import("std").mem.zeroes(?*Texture),
    mip_level: u32 = @import("std").mem.zeroes(u32),
    layer: u32 = @import("std").mem.zeroes(u32),
    x: u32 = @import("std").mem.zeroes(u32),
    y: u32 = @import("std").mem.zeroes(u32),
    z: u32 = @import("std").mem.zeroes(u32),
};

pub const TextureRegion = extern struct {
    texture: ?*Texture = @import("std").mem.zeroes(?*Texture),
    mip_level: u32 = @import("std").mem.zeroes(u32),
    layer: u32 = @import("std").mem.zeroes(u32),
    x: u32 = @import("std").mem.zeroes(u32),
    y: u32 = @import("std").mem.zeroes(u32),
    z: u32 = @import("std").mem.zeroes(u32),
    w: u32 = @import("std").mem.zeroes(u32),
    h: u32 = @import("std").mem.zeroes(u32),
    d: u32 = @import("std").mem.zeroes(u32),
};

pub const BlitRegion = extern struct {
    texture: ?*Texture = @import("std").mem.zeroes(?*Texture),
    mip_level: u32 = @import("std").mem.zeroes(u32),
    layer_or_depth_plane: u32 = @import("std").mem.zeroes(u32),
    x: u32 = @import("std").mem.zeroes(u32),
    y: u32 = @import("std").mem.zeroes(u32),
    w: u32 = @import("std").mem.zeroes(u32),
    h: u32 = @import("std").mem.zeroes(u32),
};

pub const BufferLocation = extern struct {
    buffer: ?*Buffer = @import("std").mem.zeroes(?*Buffer),
    offset: u32 = @import("std").mem.zeroes(u32),
};

pub const BufferRegion = extern struct {
    buffer: ?*Buffer = @import("std").mem.zeroes(?*Buffer),
    offset: u32 = @import("std").mem.zeroes(u32),
    size: u32 = @import("std").mem.zeroes(u32),
};

pub const IndirectDrawCommand = extern struct {
    num_vertices: u32 = @import("std").mem.zeroes(u32),
    num_instances: u32 = @import("std").mem.zeroes(u32),
    first_vertex: u32 = @import("std").mem.zeroes(u32),
    first_instance: u32 = @import("std").mem.zeroes(u32),
};

pub const IndexedIndirectDrawCommand = extern struct {
    num_indices: u32 = @import("std").mem.zeroes(u32),
    num_instances: u32 = @import("std").mem.zeroes(u32),
    first_index: u32 = @import("std").mem.zeroes(u32),
    vertex_offset: i32 = @import("std").mem.zeroes(i32),
    first_instance: u32 = @import("std").mem.zeroes(u32),
};

pub const IndirectDispatchCommand = extern struct {
    groupcount_x: u32 = @import("std").mem.zeroes(u32),
    groupcount_y: u32 = @import("std").mem.zeroes(u32),
    groupcount_z: u32 = @import("std").mem.zeroes(u32),
};

pub const SamplerCreateInfo = extern struct {
    min_filter: Filter = @import("std").mem.zeroes(Filter),
    mag_filter: Filter = @import("std").mem.zeroes(Filter),
    mipmap_mode: SamplerMipmapMode = @import("std").mem.zeroes(SamplerMipmapMode),
    address_mode_u: SamplerAddressMode = @import("std").mem.zeroes(SamplerAddressMode),
    address_mode_v: SamplerAddressMode = @import("std").mem.zeroes(SamplerAddressMode),
    address_mode_w: SamplerAddressMode = @import("std").mem.zeroes(SamplerAddressMode),
    mip_lod_bias: f32 = @import("std").mem.zeroes(f32),
    max_anisotropy: f32 = @import("std").mem.zeroes(f32),
    compare_op: CompareOp = @import("std").mem.zeroes(CompareOp),
    min_lod: f32 = @import("std").mem.zeroes(f32),
    max_lod: f32 = @import("std").mem.zeroes(f32),
    enable_anisotropy: bool = @import("std").mem.zeroes(bool),
    enable_compare: bool = @import("std").mem.zeroes(bool),
    padding1: u8 = @import("std").mem.zeroes(u8),
    padding2: u8 = @import("std").mem.zeroes(u8),
    props: PropertiesID = @import("std").mem.zeroes(PropertiesID),
};

pub const VertexBufferDescription = extern struct {
    slot: u32 = @import("std").mem.zeroes(u32),
    pitch: u32 = @import("std").mem.zeroes(u32),
    input_rate: VertexInputRate = @import("std").mem.zeroes(VertexInputRate),
    instance_step_rate: u32 = @import("std").mem.zeroes(u32),
};

pub const VertexAttribute = extern struct {
    location: u32 = @import("std").mem.zeroes(u32),
    buffer_slot: u32 = @import("std").mem.zeroes(u32),
    format: VertexElementFormat = @import("std").mem.zeroes(VertexElementFormat),
    offset: u32 = @import("std").mem.zeroes(u32),
};

pub const VertexInputState = extern struct {
    vertex_buffer_descriptions: [*c]const VertexBufferDescription = @import("std").mem.zeroes([*c]const VertexBufferDescription),
    num_vertex_buffers: u32 = @import("std").mem.zeroes(u32),
    vertex_attributes: [*c]const VertexAttribute = @import("std").mem.zeroes([*c]const VertexAttribute),
    num_vertex_attributes: u32 = @import("std").mem.zeroes(u32),
};

pub const StencilOpState = extern struct {
    fail_op: StencilOp = @import("std").mem.zeroes(StencilOp),
    pass_op: StencilOp = @import("std").mem.zeroes(StencilOp),
    depth_fail_op: StencilOp = @import("std").mem.zeroes(StencilOp),
    compare_op: CompareOp = @import("std").mem.zeroes(CompareOp),
};

pub const ColorTargetBlendState = extern struct {
    src_color_blendfactor: BlendFactor = @import("std").mem.zeroes(BlendFactor),
    dst_color_blendfactor: BlendFactor = @import("std").mem.zeroes(BlendFactor),
    color_blend_op: BlendOp = @import("std").mem.zeroes(BlendOp),
    src_alpha_blendfactor: BlendFactor = @import("std").mem.zeroes(BlendFactor),
    dst_alpha_blendfactor: BlendFactor = @import("std").mem.zeroes(BlendFactor),
    alpha_blend_op: BlendOp = @import("std").mem.zeroes(BlendOp),
    color_write_mask: ColorComponentFlags = @import("std").mem.zeroes(ColorComponentFlags),
    enable_blend: bool = @import("std").mem.zeroes(bool),
    enable_color_write_mask: bool = @import("std").mem.zeroes(bool),
    padding1: u8 = @import("std").mem.zeroes(u8),
    padding2: u8 = @import("std").mem.zeroes(u8),
};

pub const ShaderCreateInfo = extern struct {
    code_size: usize = @import("std").mem.zeroes(usize),
    code: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    entrypoint: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    format: ShaderFormat = @import("std").mem.zeroes(ShaderFormat),
    stage: ShaderStage = @import("std").mem.zeroes(ShaderStage),
    num_samplers: u32 = @import("std").mem.zeroes(u32),
    num_storage_textures: u32 = @import("std").mem.zeroes(u32),
    num_storage_buffers: u32 = @import("std").mem.zeroes(u32),
    num_uniform_buffers: u32 = @import("std").mem.zeroes(u32),
    props: PropertiesID = @import("std").mem.zeroes(PropertiesID),
};

pub const TextureCreateInfo = extern struct {
    type: TextureType = @import("std").mem.zeroes(TextureType),
    format: TextureFormat = @import("std").mem.zeroes(TextureFormat),
    usage: TextureUsageFlags = @import("std").mem.zeroes(TextureUsageFlags),
    width: u32 = @import("std").mem.zeroes(u32),
    height: u32 = @import("std").mem.zeroes(u32),
    layer_count_or_depth: u32 = @import("std").mem.zeroes(u32),
    num_levels: u32 = @import("std").mem.zeroes(u32),
    sample_count: SampleCount = @import("std").mem.zeroes(SampleCount),
    props: PropertiesID = @import("std").mem.zeroes(PropertiesID),
};

pub const BufferCreateInfo = extern struct {
    usage: BufferUsageFlags = @import("std").mem.zeroes(BufferUsageFlags),
    size: u32 = @import("std").mem.zeroes(u32),
    props: PropertiesID = @import("std").mem.zeroes(PropertiesID),
};

pub const TransferBufferCreateInfo = extern struct {
    usage: TransferBufferUsage = @import("std").mem.zeroes(TransferBufferUsage),
    size: u32 = @import("std").mem.zeroes(u32),
    props: PropertiesID = @import("std").mem.zeroes(PropertiesID),
};

pub const RasterizerState = extern struct {
    fill_mode: FillMode = @import("std").mem.zeroes(FillMode),
    cull_mode: CullMode = @import("std").mem.zeroes(CullMode),
    front_face: FrontFace = @import("std").mem.zeroes(FrontFace),
    depth_bias_constant_factor: f32 = @import("std").mem.zeroes(f32),
    depth_bias_clamp: f32 = @import("std").mem.zeroes(f32),
    depth_bias_slope_factor: f32 = @import("std").mem.zeroes(f32),
    enable_depth_bias: bool = @import("std").mem.zeroes(bool),
    enable_depth_clip: bool = @import("std").mem.zeroes(bool),
    padding1: u8 = @import("std").mem.zeroes(u8),
    padding2: u8 = @import("std").mem.zeroes(u8),
};

pub const MultisampleState = extern struct {
    sample_count: SampleCount = @import("std").mem.zeroes(SampleCount),
    sample_mask: u32 = @import("std").mem.zeroes(u32),
    enable_mask: bool = @import("std").mem.zeroes(bool),
    padding1: u8 = @import("std").mem.zeroes(u8),
    padding2: u8 = @import("std").mem.zeroes(u8),
    padding3: u8 = @import("std").mem.zeroes(u8),
};

pub const DepthStencilState = extern struct {
    compare_op: CompareOp = @import("std").mem.zeroes(CompareOp),
    back_stencil_state: StencilOpState = @import("std").mem.zeroes(StencilOpState),
    front_stencil_state: StencilOpState = @import("std").mem.zeroes(StencilOpState),
    compare_mask: u8 = @import("std").mem.zeroes(u8),
    write_mask: u8 = @import("std").mem.zeroes(u8),
    enable_depth_test: bool = @import("std").mem.zeroes(bool),
    enable_depth_write: bool = @import("std").mem.zeroes(bool),
    enable_stencil_test: bool = @import("std").mem.zeroes(bool),
    padding1: u8 = @import("std").mem.zeroes(u8),
    padding2: u8 = @import("std").mem.zeroes(u8),
    padding3: u8 = @import("std").mem.zeroes(u8),
};

pub const ColorTargetDescription = extern struct {
    format: TextureFormat = @import("std").mem.zeroes(TextureFormat),
    blend_state: ColorTargetBlendState = @import("std").mem.zeroes(ColorTargetBlendState),
};

pub const GraphicsPipelineTargetInfo = extern struct {
    color_target_descriptions: [*c]const ColorTargetDescription = @import("std").mem.zeroes([*c]const ColorTargetDescription),
    num_color_targets: u32 = @import("std").mem.zeroes(u32),
    depth_stencil_format: TextureFormat = @import("std").mem.zeroes(TextureFormat),
    has_depth_stencil_target: bool = @import("std").mem.zeroes(bool),
    padding1: u8 = @import("std").mem.zeroes(u8),
    padding2: u8 = @import("std").mem.zeroes(u8),
    padding3: u8 = @import("std").mem.zeroes(u8),
};

pub const GraphicsPipelineCreateInfo = extern struct {
    vertex_shader: ?*Shader = @import("std").mem.zeroes(?*Shader),
    fragment_shader: ?*Shader = @import("std").mem.zeroes(?*Shader),
    vertex_input_state: VertexInputState = @import("std").mem.zeroes(VertexInputState),
    primitive_type: PrimitiveType = @import("std").mem.zeroes(PrimitiveType),
    rasterizer_state: RasterizerState = @import("std").mem.zeroes(RasterizerState),
    multisample_state: MultisampleState = @import("std").mem.zeroes(MultisampleState),
    depth_stencil_state: DepthStencilState = @import("std").mem.zeroes(DepthStencilState),
    target_info: GraphicsPipelineTargetInfo = @import("std").mem.zeroes(GraphicsPipelineTargetInfo),
    props: PropertiesID = @import("std").mem.zeroes(PropertiesID),
};

pub const ComputePipelineCreateInfo = extern struct {
    code_size: usize = @import("std").mem.zeroes(usize),
    code: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    entrypoint: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    format: ShaderFormat = @import("std").mem.zeroes(ShaderFormat),
    num_samplers: u32 = @import("std").mem.zeroes(u32),
    num_readonly_storage_textures: u32 = @import("std").mem.zeroes(u32),
    num_readonly_storage_buffers: u32 = @import("std").mem.zeroes(u32),
    num_readwrite_storage_textures: u32 = @import("std").mem.zeroes(u32),
    num_readwrite_storage_buffers: u32 = @import("std").mem.zeroes(u32),
    num_uniform_buffers: u32 = @import("std").mem.zeroes(u32),
    threadcount_x: u32 = @import("std").mem.zeroes(u32),
    threadcount_y: u32 = @import("std").mem.zeroes(u32),
    threadcount_z: u32 = @import("std").mem.zeroes(u32),
    props: PropertiesID = @import("std").mem.zeroes(PropertiesID),
};

pub const ColorTargetInfo = extern struct {
    texture: *Texture,
    mip_level: u32 = @import("std").mem.zeroes(u32),
    layer_or_depth_plane: u32 = @import("std").mem.zeroes(u32),
    clear_color: FColor = @import("std").mem.zeroes(FColor),
    load_op: LoadOp = @import("std").mem.zeroes(LoadOp),
    store_op: StoreOp = @import("std").mem.zeroes(StoreOp),
    resolve_texture: ?*Texture = @import("std").mem.zeroes(?*Texture),
    resolve_mip_level: u32 = @import("std").mem.zeroes(u32),
    resolve_layer: u32 = @import("std").mem.zeroes(u32),
    cycle: bool = @import("std").mem.zeroes(bool),
    cycle_resolve_texture: bool = @import("std").mem.zeroes(bool),
    padding1: u8 = @import("std").mem.zeroes(u8),
    padding2: u8 = @import("std").mem.zeroes(u8),
};

pub const DepthStencilTargetInfo = extern struct {
    texture: ?*Texture = @import("std").mem.zeroes(?*Texture),
    clear_depth: f32 = @import("std").mem.zeroes(f32),
    load_op: LoadOp = @import("std").mem.zeroes(LoadOp),
    store_op: StoreOp = @import("std").mem.zeroes(StoreOp),
    stencil_load_op: LoadOp = @import("std").mem.zeroes(LoadOp),
    stencil_store_op: StoreOp = @import("std").mem.zeroes(StoreOp),
    cycle: bool = @import("std").mem.zeroes(bool),
    clear_stencil: u8 = @import("std").mem.zeroes(u8),
    padding1: u8 = @import("std").mem.zeroes(u8),
    padding2: u8 = @import("std").mem.zeroes(u8),
};

pub const BlitInfo = extern struct {
    source: BlitRegion = @import("std").mem.zeroes(BlitRegion),
    destination: BlitRegion = @import("std").mem.zeroes(BlitRegion),
    load_op: LoadOp = @import("std").mem.zeroes(LoadOp),
    clear_color: FColor = @import("std").mem.zeroes(FColor),
    flip_mode: FlipMode = @import("std").mem.zeroes(FlipMode),
    filter: Filter = @import("std").mem.zeroes(Filter),
    cycle: bool = @import("std").mem.zeroes(bool),
    padding1: u8 = @import("std").mem.zeroes(u8),
    padding2: u8 = @import("std").mem.zeroes(u8),
    padding3: u8 = @import("std").mem.zeroes(u8),
};

pub const BufferBinding = extern struct {
    buffer: ?*Buffer = @import("std").mem.zeroes(?*Buffer),
    offset: u32 = @import("std").mem.zeroes(u32),
};

pub const TextureSamplerBinding = extern struct {
    texture: ?*Texture = @import("std").mem.zeroes(?*Texture),
    sampler: ?*Sampler = @import("std").mem.zeroes(?*Sampler),
};

pub const StorageBufferReadWriteBinding = extern struct {
    buffer: ?*Buffer = @import("std").mem.zeroes(?*Buffer),
    cycle: bool = @import("std").mem.zeroes(bool),
    padding1: u8 = @import("std").mem.zeroes(u8),
    padding2: u8 = @import("std").mem.zeroes(u8),
    padding3: u8 = @import("std").mem.zeroes(u8),
};

pub const StorageTextureReadWriteBinding = extern struct {
    texture: ?*Texture = @import("std").mem.zeroes(?*Texture),
    mip_level: u32 = @import("std").mem.zeroes(u32),
    layer: u32 = @import("std").mem.zeroes(u32),
    cycle: bool = @import("std").mem.zeroes(bool),
    padding1: u8 = @import("std").mem.zeroes(u8),
    padding2: u8 = @import("std").mem.zeroes(u8),
    padding3: u8 = @import("std").mem.zeroes(u8),
};

extern fn SDL_GPUSupportsShaderFormats(format_flags: ShaderFormat, name: [*c]const u8) bool;
extern fn SDL_GPUSupportsProperties(props: PropertiesID) bool;
extern fn SDL_CreateGPUDevice(format_flags: ShaderFormat, debug_mode: bool, name: [*c]const u8) ?DeviceHdl;
extern fn SDL_CreateGPUDeviceWithProperties(props: PropertiesID) ?DeviceHdl;
extern fn SDL_DestroyGPUDevice(device: DeviceHdl) void;
extern fn SDL_GetNumGPUDrivers() i32;
extern fn SDL_GetGPUDriver(index: i32) [*c]const u8;
extern fn SDL_GetGPUDeviceDriver(device: DeviceHdl) [*:0]const u8;
extern fn SDL_GetGPUShaderFormats(device: DeviceHdl) ShaderFormat;
extern fn SDL_CreateGPUComputePipeline(device: DeviceHdl, createinfo: [*c]const ComputePipelineCreateInfo) ?*ComputePipeline;
extern fn SDL_CreateGPUGraphicsPipeline(device: DeviceHdl, createinfo: [*c]const GraphicsPipelineCreateInfo) ?*GraphicsPipeline;
extern fn SDL_CreateGPUSampler(device: DeviceHdl, createinfo: [*c]const SamplerCreateInfo) ?*Sampler;
extern fn SDL_CreateGPUShader(device: DeviceHdl, createinfo: [*c]const ShaderCreateInfo) ?*Shader;
extern fn SDL_CreateGPUTexture(device: DeviceHdl, createinfo: [*c]const TextureCreateInfo) ?*Texture;
extern fn SDL_CreateGPUBuffer(device: DeviceHdl, createinfo: [*c]const BufferCreateInfo) ?*Buffer;
extern fn SDL_CreateGPUTransferBuffer(device: DeviceHdl, createinfo: [*c]const TransferBufferCreateInfo) ?*TransferBuffer;
extern fn SDL_SetGPUBufferName(device: DeviceHdl, buffer: ?*Buffer, text: [*c]const u8) void;
extern fn SDL_SetGPUTextureName(device: DeviceHdl, texture: ?*Texture, text: [*c]const u8) void;
extern fn SDL_InsertGPUDebugLabel(command_buffer: *CommandBuffer, text: [*c]const u8) void;
extern fn SDL_PushGPUDebugGroup(command_buffer: *CommandBuffer, name: [*c]const u8) void;
extern fn SDL_PopGPUDebugGroup(command_buffer: *CommandBuffer) void;
extern fn SDL_ReleaseGPUTexture(device: DeviceHdl, texture: ?*Texture) void;
extern fn SDL_ReleaseGPUSampler(device: DeviceHdl, sampler: ?*Sampler) void;
extern fn SDL_ReleaseGPUBuffer(device: DeviceHdl, buffer: ?*Buffer) void;
extern fn SDL_ReleaseGPUTransferBuffer(device: DeviceHdl, transfer_buffer: ?*TransferBuffer) void;
extern fn SDL_ReleaseGPUComputePipeline(device: DeviceHdl, compute_pipeline: ?*ComputePipeline) void;
extern fn SDL_ReleaseGPUShader(device: DeviceHdl, shader: ?*Shader) void;
extern fn SDL_ReleaseGPUGraphicsPipeline(device: DeviceHdl, graphics_pipeline: ?*GraphicsPipeline) void;
extern fn SDL_AcquireGPUCommandBuffer(device: DeviceHdl) ?*CommandBuffer;
extern fn SDL_PushGPUVertexUniformData(command_buffer: *CommandBuffer, slot_index: u32, data: ?*const anyopaque, length: u32) void;
extern fn SDL_PushGPUFragmentUniformData(command_buffer: *CommandBuffer, slot_index: u32, data: ?*const anyopaque, length: u32) void;
extern fn SDL_PushGPUComputeUniformData(command_buffer: *CommandBuffer, slot_index: u32, data: ?*const anyopaque, length: u32) void;
extern fn SDL_BeginGPURenderPass(command_buffer: *CommandBuffer, color_target_infos: [*c]const ColorTargetInfo, num_color_targets: u32, depth_stencil_target_info: [*c]const DepthStencilTargetInfo) ?*RenderPass;
extern fn SDL_BindGPUGraphicsPipeline(render_pass: *RenderPass, graphics_pipeline: ?*GraphicsPipeline) void;
extern fn SDL_SetGPUViewport(render_pass: *RenderPass, viewport: [*c]const Viewport) void;
extern fn SDL_SetGPUScissor(render_pass: *RenderPass, scissor: [*c]const Rect) void;
extern fn SDL_SetGPUBlendConstants(render_pass: *RenderPass, blend_constants: FColor) void;
extern fn SDL_SetGPUStencilReference(render_pass: *RenderPass, reference: u8) void;
extern fn SDL_BindGPUVertexBuffers(render_pass: *RenderPass, first_slot: u32, bindings: [*c]const BufferBinding, num_bindings: u32) void;
extern fn SDL_BindGPUIndexBuffer(render_pass: *RenderPass, binding: [*c]const BufferBinding, index_element_size: IndexElementSize) void;
extern fn SDL_BindGPUVertexSamplers(render_pass: *RenderPass, first_slot: u32, texture_sampler_bindings: [*c]const TextureSamplerBinding, num_bindings: u32) void;
extern fn SDL_BindGPUVertexStorageTextures(render_pass: *RenderPass, first_slot: u32, storage_textures: [*c]const ?*Texture, num_bindings: u32) void;
extern fn SDL_BindGPUVertexStorageBuffers(render_pass: *RenderPass, first_slot: u32, storage_buffers: [*c]const ?*Buffer, num_bindings: u32) void;
extern fn SDL_BindGPUFragmentSamplers(render_pass: *RenderPass, first_slot: u32, texture_sampler_bindings: [*c]const TextureSamplerBinding, num_bindings: u32) void;
extern fn SDL_BindGPUFragmentStorageTextures(render_pass: *RenderPass, first_slot: u32, storage_textures: [*c]const ?*Texture, num_bindings: u32) void;
extern fn SDL_BindGPUFragmentStorageBuffers(render_pass: *RenderPass, first_slot: u32, storage_buffers: [*c]const ?*Buffer, num_bindings: u32) void;
extern fn SDL_DrawGPUIndexedPrimitives(render_pass: *RenderPass, num_indices: u32, num_instances: u32, first_index: u32, vertex_offset: i32, first_instance: u32) void;
extern fn SDL_DrawGPUPrimitives(render_pass: *RenderPass, num_vertices: u32, num_instances: u32, first_vertex: u32, first_instance: u32) void;
extern fn SDL_DrawGPUPrimitivesIndirect(render_pass: *RenderPass, buffer: ?*Buffer, offset: u32, draw_count: u32) void;
extern fn SDL_DrawGPUIndexedPrimitivesIndirect(render_pass: *RenderPass, buffer: ?*Buffer, offset: u32, draw_count: u32) void;
extern fn SDL_EndGPURenderPass(render_pass: *RenderPass) void;
extern fn SDL_BeginGPUComputePass(command_buffer: *CommandBuffer, storage_texture_bindings: [*c]const StorageTextureReadWriteBinding, num_storage_texture_bindings: u32, storage_buffer_bindings: [*c]const StorageBufferReadWriteBinding, num_storage_buffer_bindings: u32) ?*ComputePass;
extern fn SDL_BindGPUComputePipeline(compute_pass: *ComputePass, compute_pipeline: ?*ComputePipeline) void;
extern fn SDL_BindGPUComputeSamplers(compute_pass: *ComputePass, first_slot: u32, texture_sampler_bindings: [*c]const TextureSamplerBinding, num_bindings: u32) void;
extern fn SDL_BindGPUComputeStorageTextures(compute_pass: *ComputePass, first_slot: u32, storage_textures: [*c]const ?*Texture, num_bindings: u32) void;
extern fn SDL_BindGPUComputeStorageBuffers(compute_pass: *ComputePass, first_slot: u32, storage_buffers: [*c]const ?*Buffer, num_bindings: u32) void;
extern fn SDL_DispatchGPUCompute(compute_pass: *ComputePass, groupcount_x: u32, groupcount_y: u32, groupcount_z: u32) void;
extern fn SDL_DispatchGPUComputeIndirect(compute_pass: *ComputePass, buffer: ?*Buffer, offset: u32) void;
extern fn SDL_EndGPUComputePass(compute_pass: *ComputePass) void;
extern fn SDL_MapGPUTransferBuffer(device: DeviceHdl, transfer_buffer: ?*TransferBuffer, cycle: bool) ?*anyopaque;
extern fn SDL_UnmapGPUTransferBuffer(device: DeviceHdl, transfer_buffer: ?*TransferBuffer) void;
extern fn SDL_BeginGPUCopyPass(command_buffer: *CommandBuffer) ?*CopyPass;
extern fn SDL_UploadToGPUTexture(copy_pass: *CopyPass, source: [*c]const TextureTransferInfo, destination: [*c]const TextureRegion, cycle: bool) void;
extern fn SDL_UploadToGPUBuffer(copy_pass: *CopyPass, source: [*c]const TransferBufferLocation, destination: [*c]const BufferRegion, cycle: bool) void;
extern fn SDL_CopyGPUTextureToTexture(copy_pass: *CopyPass, source: [*c]const TextureLocation, destination: [*c]const TextureLocation, w: u32, h: u32, d: u32, cycle: bool) void;
extern fn SDL_CopyGPUBufferToBuffer(copy_pass: *CopyPass, source: [*c]const BufferLocation, destination: [*c]const BufferLocation, size: u32, cycle: bool) void;
extern fn SDL_DownloadFromGPUTexture(copy_pass: *CopyPass, source: [*c]const TextureRegion, destination: [*c]const TextureTransferInfo) void;
extern fn SDL_DownloadFromGPUBuffer(copy_pass: *CopyPass, source: [*c]const BufferRegion, destination: [*c]const TransferBufferLocation) void;
extern fn SDL_EndGPUCopyPass(copy_pass: *CopyPass) void;
extern fn SDL_GenerateMipmapsForGPUTexture(command_buffer: *CommandBuffer, texture: ?*Texture) void;
extern fn SDL_BlitGPUTexture(command_buffer: *CommandBuffer, info: [*c]const BlitInfo) void;
extern fn SDL_WindowSupportsGPUSwapchainComposition(device: DeviceHdl, window: ?*Window, swapchain_composition: SwapchainComposition) bool;
extern fn SDL_WindowSupportsGPUPresentMode(device: DeviceHdl, window: ?*Window, present_mode: PresentMode) bool;
extern fn SDL_ClaimWindowForGPUDevice(device: DeviceHdl, window: ?*Window) bool;
extern fn SDL_ReleaseWindowFromGPUDevice(device: DeviceHdl, window: ?*Window) void;
extern fn SDL_SetGPUSwapchainParameters(device: DeviceHdl, window: ?*Window, swapchain_composition: SwapchainComposition, present_mode: PresentMode) bool;
extern fn SDL_SetGPUAllowedFramesInFlight(device: DeviceHdl, allowed_frames_in_flight: u32) bool;
extern fn SDL_GetGPUSwapchainTextureFormat(device: DeviceHdl, window: ?*Window) TextureFormat;
extern fn SDL_AcquireGPUSwapchainTexture(command_buffer: *CommandBuffer, window: ?*Window, swapchain_texture: ?*?*Texture, swapchain_texture_width: ?*u32, swapchain_texture_height: ?*u32) bool;
extern fn SDL_WaitForGPUSwapchain(device: DeviceHdl, window: ?*Window) bool;
extern fn SDL_WaitAndAcquireGPUSwapchainTexture(command_buffer: *CommandBuffer, window: ?*Window, swapchain_texture: ?*?*Texture, swapchain_texture_width: ?*u32, swapchain_texture_height: ?*u32) bool;
extern fn SDL_SubmitGPUCommandBuffer(command_buffer: *CommandBuffer) bool;
extern fn SDL_SubmitGPUCommandBufferAndAcquireFence(command_buffer: *CommandBuffer) ?*Fence;
extern fn SDL_CancelGPUCommandBuffer(command_buffer: *CommandBuffer) bool;
extern fn SDL_WaitForGPUIdle(device: DeviceHdl) bool;
extern fn SDL_WaitForGPUFences(device: DeviceHdl, wait_all: bool, fences: [*c]const ?*Fence, num_fences: u32) bool;
extern fn SDL_QueryGPUFence(device: DeviceHdl, fence: ?*Fence) bool;
extern fn SDL_ReleaseGPUFence(device: DeviceHdl, fence: ?*Fence) void;
extern fn SDL_GPUTextureFormatTexelBlockSize(format: TextureFormat) u32;
extern fn SDL_GPUTextureSupportsFormat(device: DeviceHdl, format: TextureFormat, type: TextureType, usage: TextureUsageFlags) bool;
extern fn SDL_GPUTextureSupportsSampleCount(device: DeviceHdl, format: TextureFormat, sample_count: SampleCount) bool;
extern fn SDL_CalculateGPUTextureFormatSize(format: TextureFormat, width: u32, height: u32, depth_or_layer_count: u32) u32;
extern fn SDL_GDKSuspendGPU(device: DeviceHdl) void;
extern fn SDL_GDKResumeGPU(device: DeviceHdl) void;
pub const supportsShaderFormats = SDL_GPUSupportsShaderFormats;
pub const supportsProperties = SDL_GPUSupportsProperties;
pub const createDevice = SDL_CreateGPUDevice;
pub const createWithProperties = SDL_CreateGPUDeviceWithProperties;
pub const getNumDrivers = SDL_GetNumGPUDrivers;
pub const getDriver = SDL_GetGPUDriver;
pub const textureFormatTexelBlockSize = SDL_GPUTextureFormatTexelBlockSize;
pub const calculateTextureFormatSize = SDL_CalculateGPUTextureFormatSize;
