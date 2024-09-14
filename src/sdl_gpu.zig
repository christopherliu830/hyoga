const c = @import("c.zig");

pub const PropertiesID = u32;

pub const FColor = extern struct { r: f32, g: f32, b: f32, a: f32 };

pub const Rect = extern struct {
    x: i32,
    y: i32,
    w: i32,
    h: i32,
};

pub const Device = c.SDL_GPUDevice;

pub const Buffer = c.SDL_GPUBuffer;

pub const TransferBuffer = c.SDL_GPUTransferBuffer;

pub const Texture = c.SDL_GPUTexture;

pub const Sampler = c.SDL_GPUSampler;

pub const Shader = c.SDL_GPUShader;

pub const ComputePipeline = c.SDL_GPUComputePipeline;

pub const GraphicsPipeline = c.SDL_GPUGraphicsPipeline;

pub const CommandBuffer = c.SDL_GPUCommandBuffer;

pub const RenderPass = c.SDL_GPURenderPass;

pub const ComputePass = c.SDL_GPUComputePass;

pub const CopyPass = c.SDL_GPUCopyPass;

pub const Fence = c.SDL_GPUFence;

pub const PrimitiveType = enum(c_int) {
    triangle_list,
    triangle_strip,
    line_list,
    line_strip,
    point_list,
};

pub const LoadOp = enum(c_int) {
    load,
    clear,
    dont_care,
};

pub const StoreOp = enum(c_int) {
    store,
    dont_care,
};

pub const IndexElementSize = enum(c_int) {
    @"16bit",
    @"32bit",
};

/// Texture format support varies depending on driver, hardware, and usage flags.
/// In general, you should use TextureSupportsFormat to query if a format
/// is supported before using it. However, there are a few guaranteed formats.
///
/// For SAMPLER usage, the following formats are universally supported:
///  - R8G8B8A8_UNORM
///  - B8G8R8A8_UNORM
///  - R8_UNORM
///  - R8_SNORM
///  - R8G8_UNORM
///  - R8G8_SNORM
///  - R8G8B8A8_SNORM
///  - R16_FLOAT
///  - R16G16_FLOAT
///  - R16G16B16A16_FLOAT
///  - R32_FLOAT
///  - R32G32_FLOAT
///  - R32G32B32A32_FLOAT
///  - R11G11B10_UFLOAT
///  - R8G8B8A8_UNORM_SRGB
///  - B8G8R8A8_UNORM_SRGB
///  - D16_UNORM
///
/// For COLOR_TARGET usage, the following formats are universally supported:
///  - R8G8B8A8_UNORM
///  - B8G8R8A8_UNORM
///  - R8_UNORM
///  - R16_FLOAT
///  - R16G16_FLOAT
///  - R16G16B16A16_FLOAT
///  - R32_FLOAT
///  - R32G32_FLOAT
///  - R32G32B32A32_FLOAT
///  - R8_UINT
///  - R8G8_UINT
///  - R8G8B8A8_UINT
///  - R16_UINT
///  - R16G16_UINT
///  - R16G16B16A16_UINT
///  - R8_INT
///  - R8G8_INT
///  - R8G8B8A8_INT
///  - R16_INT
///  - R16G16_INT
///  - R16G16B16A16_INT
///  - R8G8B8A8_UNORM_SRGB
///  - B8G8R8A8_UNORM_SRGB
///
/// For STORAGE usages, the following formats are universally supported:
///  - R8G8B8A8_UNORM
///  - R8G8B8A8_SNORM
///  - R16G16B16A16_FLOAT
///  - R32_FLOAT
///  - R32G32_FLOAT
///  - R32G32B32A32_FLOAT
///  - R8G8B8A8_UINT
///  - R16G16B16A16_UINT
///  - R8G8B8A8_INT
///  - R16G16B16A16_INT
///
/// For DEPTH_STENCIL_TARGET usage, the following formats are universally supported:
///  - D16_UNORM
///  - Either (but not necessarily both!) D24_UNORM or D32_SFLOAT
///  - Either (but not necessarily both!) D24_UNORM_S8_UINT or D32_SFLOAT_S8_UINT
///
/// Unless D16_UNORM is sufficient for your purposes, always check which
/// of D24/D32 is supported before creating a depth-stencil texture!
pub const TextureFormat = enum(c_int) {
    invalid = -1,

    // Unsigned Normalized Float Color Formats
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
    // Compressed Unsigned Normalized Float Color Formats
    bc1_rgba_unorm,
    bc2_rgba_unorm,
    bc3_rgba_unorm,
    bc4_r_unorm,
    bc5_rg_unorm,
    bc7_rgba_unorm,
    // Compressed Signed Float Color Formats
    bc6h_rgb_float,
    // Compressed Unsigned Float Color Formats
    bc6h_rgb_ufloat,
    // Signed Normalized Float Color Formats
    r8_snorm,
    r8g8_snorm,
    r8g8b8a8_snorm,
    r16_snorm,
    r16g16_snorm,
    r16g16b16a16_snorm,
    // Signed Float Color Formats
    r16_float,
    r16g16_float,
    r16g16b16a16_float,
    r32_float,
    r32g32_float,
    r32g32b32a32_float,
    // Unsigned Float Color Formats
    r11g11b10_ufloat,
    // Unsigned Integer Color Formats
    r8_uint,
    r8g8_uint,
    r8g8b8a8_uint,
    r16_uint,
    r16g16_uint,
    r16g16b16a16_uint,
    // Signed Integer Color Formats
    r8_int,
    r8g8_int,
    r8g8b8a8_int,
    r16_int,
    r16g16_int,
    r16g16b16a16_int,
    // SRGB Unsigned Normalized Color Formats
    r8g8b8a8_unorm_srgb,
    b8g8r8a8_unorm_srgb,
    // Compressed SRGB Unsigned Normalized Color Formats
    bc1_rgba_unorm_srgb,
    bc2_rgba_unorm_srgb,
    bc3_rgba_unorm_srgb,
    bc7_rgba_unorm_srgb,
    // Depth Formats
    d16_unorm,
    d24_unorm,
    d32_float,
    d24_unorm_s8_uint,
    d32_float_s8_uint,
};

pub const TextureUsageFlags = packed struct (c_int) {
    sampler: bool = false,
    color_target: bool = false,
    depth_stencil_target: bool = false,
    graphics_storage_read: bool = false,
    compute_storage_read: bool = false,
    compute_storage_write: bool = false,

    _padding: u28 = 0,
};

pub const TextureType = enum(c_int) { 
    @"2d",
    @"2d_array",
    @"3d",
    cube,
    cube_array
 };

pub const SampleCount = enum(c_int) {
    @"1",
    @"2",
    @"4",
    @"8",
};

pub const CubeMapFace = enum(c_int) {
    positivex,
    negativex,
    positivey,
    negativey,
    positivez,
    negativez,
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

pub const TransferBufferUsage = enum(c_int) {
    upload,
    download,
};

pub const ShaderStage = enum(c_int) {
    vertex,
    fragment,
};

pub const ShaderFormat = packed struct(u32) {
    private: bool = false, // shaders for NDA'd platforms */
    spirv: bool = false, // SPIR-V shaders for Vulkan */
    dxbc: bool = false, // DXBC SM5_0 shaders for D3D11 */
    dxil: bool = false, // DXIL shaders for D3D12 */
    msl: bool = false, // MSL shaders for Metal */
    metallib: bool = false, // precompiled metallib shaders for Metal */
    _padding: u26 = 0,
};

pub const VertexElementFormat = enum(c_int) {
    // 32-bit Signed Integers */
    int,
    int2,
    int3,
    int4,

    // 32-bit unsigned integers */
    uint,
    uint2,
    uint3,
    uint4,

    // 32-bit floats */
    float,
    float2,
    float3,
    float4,

    // 8-bit signed integers */
    byte2,
    byte4,

    // 8-bit unsigned integers */
    ubyte2,
    ubyte4,

    // 8-bit signed normalized */
    byte2_norm,
    byte4_norm,

    // 8-bit unsigned normalized */
    ubyte2_norm,
    ubyte4_norm,

    // 16-bit signed integers */
    short2,
    short4,

    // 16-bit unsigned integers */
    ushort2,
    ushort4,

    // 16-bit signed normalized */
    short2_norm,
    short4_norm,

    // 16-bit unsigned normalized */
    ushort2_norm,
    ushort4_norm,

    // 16-bit floats */
    half2,
    half4,
};

pub const VertexInputRate = enum(c_int) {
    vertex,
    instance,
};

pub const FillMode = enum(c_int) {
    fill,
    line,
};

pub const CullMode = enum(c_int) {
    none,
    front,
    back,
};

pub const FrontFace = enum(c_int) {
    counter_clockwise,
    clockwise,
};

pub const CompareOp = enum(c_int) {
    invalid,
    never,
    less,
    equal,
    less_or_equal,
    greater,
    not_equal,
    greater_or_equal,
    always
};

pub const StencilOp = enum(c_int) {
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

pub const BlendOp = enum(c_int) {
    invalid,
    add,
    subtract,
    reverse_subtract,
    min,
    max,
};

pub const BlendFactor = enum(c_int) {
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

pub const ColorComponentFlags = packed struct(u32) {
    r: bool,
    g: bool,
    b: bool,
    a: bool,
};

pub const Filter = enum(c_int) {
    nearest,
    linear,
};

pub const SamplerMipmapMode = enum(c_int) {
    nearest,
    linear,
};

pub const SamplerAddressMode = enum(c_int) {
    repeat,
    mirrored_repeat,
    clamp_to_edge,
};

/// VSYNC:
///   Waits for vblank before presenting.
///   If there is a pending image to present, the new image is enqueued for presentation.
///   Disallows tearing at the cost of visual latency.
///   When using this present mode, AcquireSwapchainTexture will block if too many frames are in flight.
/// IMMEDIATE:
///   Immediately presents.
///   Lowest latency option, but tearing may occur.
///   When using this mode, AcquireSwapchainTexture will return NULL if too many frames are in flight.
/// MAILBOX:
///   Waits for vblank before presenting. No tearing is possible.
///   If there is a pending image to present, the pending image is replaced by the new image.
///   Similar to VSYNC, but with reduced visual latency.
///   When using this mode, AcquireSwapchainTexture will return NULL if too many frames are in flight.
pub const PresentMode = enum(c_int) {
    vsync,
    immediate,
    mailbox,
};

/// SDR:
///   B8G8R8A8 or R8G8B8A8 swapchain. Pixel values are in nonlinear sRGB encoding. Blends raw pixel values.
/// SDR_LINEAR:
///   B8G8R8A8_SRGB or R8G8B8A8_SRGB swapchain. Pixel values are in nonlinear sRGB encoding. Blends in linear space.
/// HDR_EXTENDED_LINEAR:
///   R16G16B16A16_SFLOAT swapchain. Pixel values are in extended linear encoding. Blends in linear space.
/// HDR10_ST2048:
///   A2R10G10B10 or A2B10G10R10 swapchain. Pixel values are in PQ ST2048 encoding. Blends raw pixel values. (TODO: verify this)
pub const SwapchainComposition = enum(c_int) {
    sdr,
    sdr_linear,
    hdr_extended_linear,
    hdr10_st2048,
};

pub const Viewport = extern struct {
    x: f32,
    y: f32,
    w: f32,
    h: f32,
    min_depth: f32,
    max_depth: f32,
};

pub const TextureTransferInfo = extern struct {
    transfer_buffer: *TransferBuffer,
    offset: u32, // starting location of the image data
    pixels_per_row: u32, // number of pixels from one row to the next
    rows_per_layer: u32, // number of rows from one layer/depth-slice to the next
};

pub const TransferBufferLocation = extern struct {
    transfer_buffer: *TransferBuffer,
    offset: u32,
};

pub const TextureLocation = extern struct {
    texture: *Texture,
    mip_level: u32,
    layer: u32,
    x: u32,
    y: u32,
    z: u32,
};

pub const TextureRegion = extern struct {
    texture: ?*Texture,
    mip_level: u32,
    layer: u32,
    x: u32,
    y: u32,
    z: u32,
    w: u32,
    h: u32,
    d: u32,
};

pub const BlitRegion = extern struct {
    texture: *Texture,
    mip_level: u32,
    layer_or_depth_plane: u32,
    x: u32,
    y: u32,
    w: u32,
    h: u32,
};

pub const BufferLocation = extern struct {
    buffer: *Buffer,
    offset: u32,
};

pub const BufferRegion = extern struct {
    buffer: *Buffer,
    offset: u32,
    size: u32,
};

/// Note that the `firstVertex` and `firstInstance` parameters are NOT compatible with
/// built-in vertex/instance ID variables in shaders (for example, SV_VertexID). If
/// your shader depends on these variables, the correlating draw call parameter MUST
/// be 0.
pub const IndirectDrawCommand = extern struct {
    num_vertices: u32,
    num_instances: u32,
    first_vertex: u32,
    first_instance: u32,
};

pub const IndexedIndirectDrawCommand = extern struct {
    num_indices: u32, // number of vertices to draw per instance
    num_instances: u32, // number of instances to draw
    first_index: u32, // base index within the index buffer
    vertex_offset: i32, // value added to the vertex index before indexing into the vertex buffer
    first_instance: u32, // id of the first instance to draw
};

pub const IndirectDispatchCommand = extern struct {
    groupcount_x: u32,
    groupcount_y: u32,
    groupcount_z: u32,
};

// State structures

pub const SamplerCreateInfo = extern struct {
    min_filter: Filter,
    mag_filter: Filter,
    mipmap_mode: SamplerMipmapMode,
    address_mode_u: SamplerAddressMode,
    address_mode_v: SamplerAddressMode,
    address_mode_w: SamplerAddressMode,
    mip_lod_bias: f32,
    max_anisotropy: f32,
    compare_enable: bool,
    compare_op: CompareOp,
    min_lod: f32,
    max_lod: f32,
    enable_anisotropy: bool,
    enable_compare: bool,
    padding1: u8,
    padding2: u8,

    props: PropertiesID,
};

/// A structure specifying the parameters of vertex buffers used in a graphics
/// pipeline.
/// 
/// When you call SDL_BindGPUVertexBuffers, you specify the binding slots of
/// the vertex buffers. For example if you called SDL_BindGPUVertexBuffers with
/// a first_slot of 2 and num_bindings of 3, the binding slots 2, 3, 4 would be
/// used by the vertex buffers you pass in.
/// 
/// Vertex attributes are linked to buffers via the buffer_slot field of
/// SDL_GPUVertexAttribute. For example, if an attribute has a buffer_slot of
/// 0, then that attribute belongs to the vertex buffer bound at slot 0.
/// 
/// \since This struct is available since SDL 3.0.0
/// 
/// \sa SDL_GPUVertexAttribute
/// \sa SDL_GPUVertexInputState
/// 
pub const VertexBufferDescription = extern struct {
    slot: u32,
    pitch: u32,
    input_rate: VertexInputRate,
    instance_step_rate: u32,
};

pub const VertexAttribute = extern struct {
    location: u32,
    buffer_slot: u32,
    format: VertexElementFormat,
    offset: u32,
};

pub const VertexInputState = extern struct {
    vertex_buffer_descriptions: [*]const VertexBufferDescription,
    num_vertex_buffers: u32,
    vertex_attributes: [*]const VertexAttribute,
    num_vertex_attributes: u32,
};

pub const StencilOpState = extern struct {
    fail_op: StencilOp,
    pass_op: StencilOp,
    depth_fail_op: StencilOp,
    compare_op: CompareOp,
};

pub const ColorTargetBlendState = extern struct {
    src_color_blend_factor: BlendFactor,
    dst_color_blend_factor: BlendFactor,
    color_blend_op: BlendOp,
    src_alpha_blend_factor: BlendFactor,
    dst_alpha_blend_factor: BlendFactor,
    alpha_blend_op: BlendOp,
    color_write_mask: ColorComponentFlags,
    enable_blend: bool,
    enable_color_write_mask: bool,
    padding2: u8,
    padding3: u8,
};

pub const ShaderCreateInfo = extern struct {
    codeSize: usize,
    code: [*]const u8,
    entryPointName: [*:0]const u8,
    format: ShaderFormat,
    stage: ShaderStage,
    num_samplers: u32,
    num_storage_textures: u32,
    num_storage_buffers: u32,
    num_uniform_buffers: u32,

    props: PropertiesID,
};

pub const TextureCreateInfo = extern struct {
    type: TextureType,
    format: TextureFormat,
    usage: TextureUsageFlags,
    width: u32,
    height: u32,
    layer_count_or_depth: u32,
    num_levels: u32,
    sample_count: SampleCount,

    props: PropertiesID,
};

pub const BufferCreateInfo = extern struct {
    usage: BufferUsageFlags,
    size: u32,
    props: PropertiesID,
};

pub const TransferBufferCreateInfo = extern struct {
    usage: TransferBufferUsage,
    size: u32,
    props: PropertiesID,
};

pub const RasterizerState = extern struct {
    fill_mode: FillMode,
    cull_mode: CullMode,
    front_face: FrontFace,
    depth_bias_clamp: f32,
    depth_bias_constant_factor: f32,
    depth_bias_slope_factor: f32,
    enable_depth_bias: bool,
    padding1: u8,
    padding2: u8,
    padding3: u8,
};

pub const MultisampleState = extern struct {
    sample_count: SampleCount,
    sample_mask: u32,
    enable_mask: bool,
    padding1: u8,
    padding2: u8,
    padding3: u8,
};

pub const DepthStencilState = extern struct {
    compare_op: CompareOp,
    back_stencil_state: StencilOpState,
    front_stencil_state: StencilOpState,
    compare_mask: u8,
    write_mask: u8,
    enable_depth_test: bool,
    enable_depth_write: bool,
    enable_stencil_test: bool,
    padding1: u8,
    padding2: u8,
    padding3: u8,
};

pub const ColorTargetDescription = extern struct {
    format: TextureFormat,
    blend_state: ColorTargetBlendState,
};

pub const GraphicsPipelineAttachmentInfo = extern struct {
    color_target_descriptions: [*]ColorTargetDescription,
    num_color_targets: u32,
    depth_stencil_format: TextureFormat,
    has_depth_stencil_attachment: bool,
    padding1: u8,
    padding2: u8,
    padding3: u8,
};

pub const GraphicsPipelineCreateInfo = extern struct {
    vertex_shader: *Shader,
    fragment_shader: *Shader,
    vertex_input_state: VertexInputState,
    primitive_type: PrimitiveType,
    rasterizer_state: RasterizerState,
    multisample_state: MultisampleState,
    depth_stencil_state: DepthStencilState,
    target_info: GraphicsPipelineAttachmentInfo,

    props: PropertiesID,
};

pub const ComputePipelineCreateInfo = extern struct {
    code_size: usize,
    code: [*]const u8,
    entrypoint: [*]const u8,
    format: ShaderFormat,
    num_readonly_storage_textures: u32,
    num_readonly_storage_buffers: u32,
    num_writeonly_storage_textures: u32,
    num_writeonly_storage_buffers: u32,
    num_uniform_buffers: u32,
    threadcount_x: u32,
    threadcount_y: u32,
    threadcount_z: u32,

    props: PropertiesID,
};

pub const ColorTargetInfo= extern struct {
    // The texture that will be used as a color attachment by a render pass.
    texture: *Texture,
    mip_level: u32,
    layer_or_depth_plane: u32, // for 3d textures, you can bind an individual depth plane as an attachment. */
    clear_color: FColor, // Can be ignored by RenderPass if CLEAR is not used
    load_op: LoadOp,
    store_op: StoreOp,
    cycle: bool, // if SDL_TRUE, cycles the texture if the texture is bound and loadOp is not LOAD */
    padding1: u8,
    padding2: u8,
    padding3: u8,
};

pub const DepthStencilTargetInfo = extern struct {
    texture: *Texture,
    clear_depth: f32,
    load_op: LoadOp,
    store_op: StoreOp,
    stencil_load_op: LoadOp,
    stencil_store_op: StoreOp,
    cycle: bool, // if SDL_TRUE, cycles the texture if the texture is bound and any load ops are not LOAD */
    clear_stencil: u8,
    padding1: u8,
    padding2: u8
};

pub const BlitInfo = extern struct {
    source: BlitRegion,
    destination: BlitRegion,
    load_op: LoadOp,
    clear_color: FColor,
    flip_mode: c.SDL_FlipMode,
    filter: Filter,
    cycle: bool,
    padding1: u8,
    padding2: u8,
    padding3: u8,
};

// Binding Structs

pub const BufferBinding = extern struct {
    buffer: ?*Buffer,
    offset: u32,
};

pub const TextureSamplerBinding = extern struct {
    texture: ?*Texture,
    sampler: ?*Sampler,
};

pub const StorageBufferWriteOnlyBinding = extern struct {
    buffer: ?*Buffer,
    cycle: bool,
    padding1: u8,
    padding2: u8,
    padding3: u8,
};

pub const StorageTextureWriteOnlyBinding = extern struct {
    texture: ?*Texture,
    mip_level: u32,
    layer: u32,
    cycle: bool,
    padding1: u8,
    padding2: u8,
    padding3: u8,
};

/// Checks for GPU runtime support.
/// 
/// \param format_flags a bitflag indicating which shader formats the app is
///                     able to provide.
/// \param name the preferred GPU driver, or NULL to let SDL pick the optimal
///             driver.
/// \returns SDL_TRUE if supported, SDL_FALSE otherwise.
/// 
/// \since This function is available since SDL 3.0.0.
/// 
/// \sa SDL_CreateGPUDevice
/// 
extern fn SDL_GPUSupportsShaderFormats(format_flags: ShaderFormat, [*]const u8) bool;
pub const supportsShaderFormats = SDL_GPUSupportsShaderFormats;


/// Checks for GPU runtime support.
/// 
/// \param props the properties to use.
/// \returns SDL_TRUE if supported, SDL_FALSE otherwise.
/// 
/// \since This function is available since SDL 3.0.0.
/// 
/// \sa SDL_CreateGPUDeviceWithProperties
/// 
extern fn SDL_GPUSupportsProperties(props: PropertiesID) bool;
pub const supportsProperties = SDL_GPUSupportsProperties;

/// Creates a GPU context.
/// 
/// \param format_flags a bitflag indicating which shader formats the app is
///                     able to provide.
/// \param debug_mode enable debug mode properties and validations.
/// \param name the preferred GPU driver, or NULL to let SDL pick the optimal
///             driver.
/// \returns a GPU context on success or NULL on failure.
/// 
/// \since This function is available since SDL 3.0.0.
/// 
/// \sa SDL_GetGPUShaderFormats
/// \sa SDL_GetGPUDeviceDriver
/// \sa SDL_DestroyGPUDevice
/// \sa SDL_GPUSupportsShaderFormats
/// 
extern fn SDL_CreateGPUDevice(formatFlags: ShaderFormat, debugMode: bool, name: ?[*]const u8) ?*Device;
pub const createDevice = SDL_CreateGPUDevice;

/// Creates a GPU context.
/// 
/// These are the supported properties:
/// 
/// - `SDL_PROP_GPU_DEVICE_CREATE_DEBUGMODE_BOOL`: enable debug mode properties
///   and validations, defaults to SDL_TRUE.
/// - `SDL_PROP_GPU_DEVICE_CREATE_PREFERLOWPOWER_BOOL`: enable to prefer energy
///   efficiency over maximum GPU performance, defaults to SDL_FALSE.
/// - `SDL_PROP_GPU_DEVICE_CREATE_NAME_STRING`: the name of the GPU driver to
///   use, if a specific one is desired.
/// 
/// These are the current shader format properties:
/// 
/// - `SDL_PROP_GPU_DEVICE_CREATE_SHADERS_PRIVATE_BOOL`: The app is able to
///   provide shaders for an NDA platform.
/// - `SDL_PROP_GPU_DEVICE_CREATE_SHADERS_SPIRV_BOOL`: The app is able to
///   provide SPIR-V shaders if applicable.
/// - SDL_PROP_GPU_DEVICE_CREATE_SHADERS_DXBC_BOOL`: The app is able to provide
///   DXBC shaders if applicable
///   `SDL_PROP_GPU_DEVICE_CREATE_SHADERS_DXIL_BOOL`: The app is able to
///   provide DXIL shaders if applicable.
/// - `SDL_PROP_GPU_DEVICE_CREATE_SHADERS_MSL_BOOL`: The app is able to provide
///   MSL shaders if applicable.
/// - `SDL_PROP_GPU_DEVICE_CREATE_SHADERS_METALLIB_BOOL`: The app is able to
///   provide Metal shader libraries if applicable.
/// 
/// With the D3D12 renderer:
/// 
/// - `SDL_PROP_GPU_DEVICE_CREATE_D3D12_SEMANTIC_NAME_STRING`: the prefix to
///   use for all vertex semantics, default is "TEXCOORD".
/// 
/// \param props the properties to use.
/// \returns a GPU context on success or NULL on failure.
/// 
/// \since This function is available since SDL 3.0.0.
/// 
/// \sa SDL_GetGPUShaderFormats
/// \sa SDL_GetGPUDeviceDriver
/// \sa SDL_DestroyGPUDevice
/// \sa SDL_GPUSupportsProperties
extern fn SDL_CreateGPUDeviceWithProperties(props: PropertiesID) ?*Device;
pub const createDeviceWithProperties = SDL_CreateGPUDeviceWithProperties;

/// Destroys a GPU context previously returned by SDL_CreateGPUDevice.
/// 
/// \param device a GPU Context to destroy.
/// 
/// \since This function is available since SDL 3.0.0.
/// 
/// \sa SDL_CreateGPUDevice
extern fn SDL_DestroyGPUDevice(device: *Device) void;
pub const destroyDevice = SDL_DestroyGPUDevice;

extern fn SDL_GetNumGPUDrivers() c_int;
pub const getNumDrivers = SDL_GetNumGPUDrivers;

extern fn SDL_GetGPUDriver(index: c_int) [*:0]const u8;
pub const getDriver = SDL_GetGPUDriver;

extern fn SDL_GetGPUDeviceDriver(device: *Device) [*:0]const u8;
pub const getDeviceDriver = SDL_GetGPUDriver;

extern fn SDL_GetGPUShaderFormats(device: *Device) ShaderFormat;
pub const getShaderFormats = SDL_GetGPUShaderFormats;

extern fn SDL_CreateGPUComputePipeline(device: *Device, createinfo: *const ComputePipelineCreateInfo) ?*ComputePipeline;
pub const createComputePipeline = SDL_CreateGPUComputePipeline;

extern fn SDL_CreateGPUGraphicsPipeline(device: *Device, createinfo: *const GraphicsPipelineCreateInfo) ?*GraphicsPipeline;
pub const createGraphicsPipeline = SDL_CreateGPUGraphicsPipeline;

extern fn SDL_CreateGPUSampler(device: *Device, createinfo: *const SamplerCreateInfo) ?*Sampler;
pub const createSampler = SDL_CreateGPUSampler;

extern fn SDL_CreateGPUShader(device: *Device, createinfo: *const ShaderCreateInfo) ?*Shader;
pub const createShader = SDL_CreateGPUShader;

extern fn SDL_CreateGPUTexture(device: *Device, createinfo: *const TextureCreateInfo) ?*Texture;
pub const createTexture = SDL_CreateGPUTexture;

extern fn SDL_CreateGPUBuffer(device: *Device, createinfo: *const BufferCreateInfo) ?*Buffer;
pub const createBuffer = SDL_CreateGPUBuffer;

extern fn SDL_CreateGPUTransferBuffer(device: *Device, transferBufferCreateInfo: *const TransferBufferCreateInfo) ?*TransferBuffer;
pub const createTransferBuffer = SDL_CreateGPUTransferBuffer;

extern fn SDL_SetGPUBufferName(device: *Device, buffer: *Buffer, text: [*:0]const u8) void;
pub const setBufferName = SDL_SetGPUBufferName;

extern fn SDL_SetGPUTextureName(device: *Device, texture: *Texture, text: [*:0]const u8) void;
pub const setTextureName = SDL_SetGPUTextureName;

extern fn SDL_InsertGPUDebugLabel(command_buffer: *CommandBuffer, text: [*:0]const u8) void;
pub const insertDebugLabel = SDL_InsertGPUDebugLabel;

extern fn SDL_PushGPUDebugGroup(command_buffer: *CommandBuffer, name: [*:0]const u8) void;
pub const pushDebugGroup = SDL_PushGPUDebugGroup;

extern fn SDL_PopGPUDebugGroup(command_buffer: *CommandBuffer) void;
pub const popDebugGroup = SDL_PopGPUDebugGroup;

extern fn SDL_ReleaseGPUTexture(device: *Device, texture: *Texture) void;
pub const releaseTexture = SDL_ReleaseGPUTexture;

extern fn SDL_ReleaseGPUSampler(device: *Device, sampler: *Sampler) void;
pub const releaseSampler = SDL_ReleaseGPUSampler;

extern fn SDL_ReleaseGPUBuffer(device: *Device, buffer: *Buffer) void;
pub const releaseBuffer = SDL_ReleaseGPUBuffer;

extern fn SDL_ReleaseGPUTransferBuffer(device: *Device, transfer_buffer: *TransferBuffer) void;
pub const releaseTransferBuffer = SDL_ReleaseGPUTransferBuffer;

extern fn SDL_ReleaseGPUComputePipeline(device: *Device, compute_pipeline: *ComputePipeline) void;
pub const releaseComputePipeline = SDL_ReleaseGPUComputePipeline;

extern fn SDL_ReleaseGPUShader(device: *Device, shader: *Shader) void;
pub const releaseShader = SDL_ReleaseGPUShader;

extern fn SDL_ReleaseGPUGraphicsPipeline(device: *Device, graphics_pipeline: *GraphicsPipeline) void;
pub const releaseGraphicsPipeline = SDL_ReleaseGPUGraphicsPipeline;

extern fn SDL_AcquireGPUCommandBuffer(device: *Device) ?*CommandBuffer;
pub const acquireCommandBuffer = SDL_AcquireGPUCommandBuffer;

extern fn SDL_PushGPUVertexUniformData(command_buffer: *CommandBuffer, slot_index: u32, data: [*]const u8, length: u32) void;
pub const pushVertexUniformData = SDL_PushGPUVertexUniformData;

extern fn SDL_PushGPUFragmentUniformData(command_buffer: *CommandBuffer, slot_index: u32, data: [*]const u8, length: u32) void;
pub const pushFragmentUniformData = SDL_PushGPUFragmentUniformData;

extern fn SDL_PushGPUComputeUniformData(command_buffer: *CommandBuffer, slot_index: u32, data: [*]const anyopaque, length: u32) void;
pub const pushComputeUniformData = SDL_PushGPUComputeUniformData;

extern fn SDL_BeginGPURenderPass(command_buffer: *CommandBuffer, color_target_infos: [*]ColorTargetInfo, num_color_targets: u32, depth_stencil_target_info: *const DepthStencilTargetInfo) ?*RenderPass;
pub const beginRenderPass = SDL_BeginGPURenderPass;

extern fn SDL_BindGPUGraphicsPipeline(render_pass: *RenderPass, graphics_pipeline: *GraphicsPipeline) void;
pub const bindGraphicsPipeline = SDL_BindGPUGraphicsPipeline;

extern fn SDL_SetGPUViewport(render_pass: *RenderPass, viewport: *const Viewport) void;
pub const setViewport = SDL_SetGPUViewport;

extern fn SDL_SetGPUScissor(render_pass: *RenderPass, scissor: *const Rect) void;
pub const setScissor = SDL_SetGPUScissor;

extern fn SDL_SetGPUBlendConstants(render_pass: *RenderPass, blend_constants: FColor) void;
pub const setBlendConstants = c.SDL_SetGPUBlendConstants;

extern fn SDL_SetGPUStencilReference(render_pass: *RenderPass, reference: u8) void;
pub const setStencilReference = SDL_SetGPUStencilReference;

extern fn SDL_BindGPUVertexBuffers(render_pass: *RenderPass, first_slot: u32, bindings: [*]const BufferBinding, num_bindings: u32) void;
pub const bindVertexBuffers = SDL_BindGPUVertexBuffers;

extern fn SDL_BindGPUIndexBuffer(render_pass: *RenderPass, binding: *const BufferBinding, index_element_size: IndexElementSize) void;
pub const bindIndexBuffer = SDL_BindGPUIndexBuffer;

extern fn SDL_BindGPUVertexSamplers(render_pass: *RenderPass, first_slot: u32, texture_sampler_bindings: *const TextureSamplerBinding, num_bindings: u32) void;
pub const bindVertexSamplers = SDL_BindGPUVertexSamplers;

extern fn SDL_BindGPUVertexStorageTextures(render_pass: *RenderPass, first_slot: u32, storage_textures: [*]const *Texture, num_bindings: u32) void;
pub const bindVertexStorageTextures = SDL_BindGPUVertexStorageTextures;

extern fn SDL_BindGPUVertexStorageBuffers(render_pass: *RenderPass, first_slot: u32, storage_buffers: [*]const *Buffer, num_bindings: u32) void;
pub const bindVertexStorageBuffers = SDL_BindGPUVertexStorageBuffers;

extern fn SDL_BindGPUFragmentSamplers(render_pass: *RenderPass, first_slot: u32, texture_sampler_bindings: [*]const *TextureSamplerBinding, num_bindings: u32) void;
pub const bindFragmentSamplers = SDL_BindGPUFragmentSamplers;

extern fn SDL_BindGPUFragmentStorageTextures(render_pass: *RenderPass, first_slot: u32, storage_textures: [*]const *Texture, num_bindings: u32) void;
pub const bindFragmentStorageTextures = SDL_BindGPUFragmentStorageTextures;

extern fn SDL_BindGPUFragmentStorageBuffers(render_pass: *RenderPass, first_slot: u32, storage_buffers: [*]const *Buffer, num_bindings: u32) void;
pub const bindFragmentStorageBuffers = SDL_BindGPUFragmentStorageBuffers;

extern fn SDL_DrawGPUIndexedPrimitives(render_pass: *RenderPass, num_indices: u32, num_instances: u32, first_index: u32, vertex_offset: i32, first_instance: u32) void;
pub const drawIndexedPrimitives = SDL_DrawGPUIndexedPrimitives;

extern fn SDL_DrawGPUPrimitives(render_pass: *RenderPass, num_vertices: u32, num_instances: u32, first_vertex: u32, first_instance: u32) void;
pub const drawPrimitives = SDL_DrawGPUPrimitives;

extern fn SDL_DrawGPUPrimitivesIndirect(render_pass: *RenderPass, buffer: *Buffer, offset: u32, draw_count: u32) void;
pub const drawPrimitivesIndirect = SDL_DrawGPUPrimitivesIndirect;

extern fn SDL_DrawGPUIndexedPrimitivesIndirect(render_pass: *RenderPass, buffer: *Buffer, offset: u32, drawCount: u32) void;
pub const drawIndexedPrimitivesIndirect = SDL_DrawGPUIndexedPrimitivesIndirect;

extern fn SDL_EndGPURenderPass(render_pass: *RenderPass) void;
pub const endRenderPass = SDL_EndGPURenderPass;

extern fn SDL_BeginGPUComputePass(command_buffer: *CommandBuffer, storage_texture_bindings: [*]const StorageTextureWriteOnlyBinding, num_storage_texture_bindings: u32, storage_buffer_bindings: [*]const StorageBufferWriteOnlyBinding, num_storage_buffer_bindings: u32) ?*ComputePass;
pub const beginComputePass = SDL_BeginGPUComputePass;

extern fn SDL_BindGPUComputePipeline(compute_pass: *ComputePass, compute_pipeline: *ComputePipeline) void;
pub const bindComputePipeline = SDL_BindGPUComputePipeline;

extern fn SDL_BindGPUComputeSamplers(compute_pass: *ComputePass, first_slot: u32, texture_sampler_bindings: [*]const *TextureSamplerBinding, num_bindings: u32) void;
pub const bindComputeSamplers = SDL_BindGPUComputeSamplers;

extern fn SDL_BindGPUComputeStorageTextures(compute_pass: *ComputePass, first_slot: u32, storage_textures: [*]const *Texture, num_bindings: u32) void;
pub const bindComputeStorageTextures = SDL_BindGPUComputeStorageTextures;

extern fn SDL_BindGPUComputeStorageBuffers(compute_pass: *ComputePass, first_slot: u32, storage_buffers: [*]const *Buffer, num_bindings: u32) void;
pub const bindComputeStorageBuffers = SDL_BindGPUComputeStorageBuffers;

extern fn SDL_DispatchGPUCompute(compute_pass: *ComputePass, groupcount_x: u32, groupcount_y: u32, groupcount_z: u32) void;
pub const dispatchCompute = SDL_DispatchGPUCompute;

extern fn SDL_DispatchGPUComputeIndirect(compute_pass: *ComputePass, buffer: *Buffer, offset: u32) void;
pub const dispatchComputeIndirect = SDL_DispatchGPUComputeIndirect;

extern fn SDL_EndGPUComputePass(compute_pass: *ComputePass) void;
pub const endComputePass = SDL_EndGPUComputePass;

extern fn SDL_MapGPUTransferBuffer(device: *Device, transfer_buffer: *TransferBuffer, cycle: bool) ?[*]u8;
pub const mapTransferBuffer = SDL_MapGPUTransferBuffer;

extern fn SDL_UnmapGPUTransferBuffer(device: *Device, transfer_buffer: ?*TransferBuffer) void;
pub const unmapTransferBuffer = SDL_UnmapGPUTransferBuffer;

extern fn SDL_BeginGPUCopyPass(command_buffer: *CommandBuffer) ?*CopyPass;
pub const beginCopyPass = SDL_BeginGPUCopyPass;

extern fn SDL_UploadToGPUTexture(copy_pass: *CopyPass, source: *const TextureTransferInfo, destination: *const TextureRegion, cycle: bool) void;
pub const uploadToTexture = SDL_UploadToGPUTexture;

extern fn SDL_UploadToGPUBuffer(copy_pass: *CopyPass, source: *const TransferBufferLocation, destination: *const BufferRegion, cycle: bool) void;
pub const uploadToBuffer = SDL_UploadToGPUBuffer;

extern fn SDL_CopyGPUTextureToTexture(copy_pass: *CopyPass, source: *const TextureLocation, destination: *const TextureLocation, w: u32, h: u32, d: u32, cycle: bool) void;
pub const copyTextureToTexture = SDL_CopyGPUTextureToTexture;

extern fn SDL_CopyGPUBufferToBuffer(copy_pass: *CopyPass, source: *const BufferLocation, destination: *const BufferLocation, size: u32, cycle: bool) void;
pub const copyBufferToBuffer = SDL_CopyGPUBufferToBuffer;

extern fn SDL_DownloadFromGPUTexture(copy_pass: *CopyPass, source: *const TextureRegion, destination: *const TextureTransferInfo) void;
pub const downloadFromTexture = SDL_DownloadFromGPUTexture;

extern fn SDL_DownloadFromGPUBuffer(copy_pass: *CopyPass, source: *const BufferRegion, destination: *const TransferBufferLocation) void;
pub const downloadFromBuffer = SDL_DownloadFromGPUBuffer;

extern fn SDL_EndGPUCopyPass(copy_pass: *CopyPass) void;
pub const endCopyPass = SDL_EndGPUCopyPass;

extern fn SDL_GenerateMipmapsForGPUTexture(command_buffer: *CommandBuffer, texture: *Texture) void;
pub const generateMipmapsForTexture = SDL_GenerateMipmapsForGPUTexture;

extern fn SDL_BlitGPUTexture(command_buffer: *CommandBuffer, info: *const BlitInfo) void;
pub const blitTexture = SDL_BlitGPUTexture;

extern fn SDL_WindowSupportsGPUSwapchainComposition(device: *Device, window: *c.SDL_Window, swapchain_composition: SwapchainComposition) bool;
pub const windowSupportsSwapchainComposition = SDL_WindowSupportsGPUSwapchainComposition;

extern fn SDL_WindowSupportsGPUPresentMode(device: *Device, window: *c.SDL_Window, present_mode: PresentMode) bool;
pub const windowSupportsPresentMode = SDL_WindowSupportsGPUPresentMode;

extern fn SDL_ClaimWindowForGPUDevice(device: *Device, window: *c.SDL_Window) bool;
pub const claimWindowForDevice = SDL_ClaimWindowForGPUDevice;

extern fn SDL_ReleaseWindowFromGPUDevice(device: *Device, window: *c.SDL_Window) void;
pub const releaseWindowFromDevice = SDL_ReleaseWindowFromGPUDevice;

extern fn SDL_SetGPUSwapchainParameters(device: *Device, window: *c.SDL_Window, swapchain_composition: SwapchainComposition, present_mode: PresentMode) bool;
pub const setSwapchainParameters = SDL_SetGPUSwapchainParameters;

extern fn SDL_GetGPUSwapchainTextureFormat(device: *Device, window: *c.SDL_Window) TextureFormat;
pub const getSwapchainTextureFormat = SDL_GetGPUSwapchainTextureFormat;

extern fn SDL_AcquireGPUSwapchainTexture(command_buffer: *CommandBuffer, window: *c.SDL_Window, w: [*c]u32, h: [*c]u32) ?*Texture;
pub const acquireSwapchainTexture = SDL_AcquireGPUSwapchainTexture;

extern fn SDL_SubmitGPUCommandBuffer(command_buffer: *CommandBuffer) void;
pub const submitCommandBuffer = SDL_SubmitGPUCommandBuffer;

extern fn SDL_SubmitGPUCommandBufferAndAcquireFence(command_buffer: *CommandBuffer) ?*Fence;
pub const submitCommandBufferAndAcquireFence = SDL_SubmitGPUCommandBufferAndAcquireFence;

extern fn SDL_WaitForGPUIdle(device: *Device) void;
pub const waitForIdle = SDL_WaitForGPUIdle;

extern fn SDL_WaitForGPUFences(device: *Device, wait_all: bool, fences: [*]const *Fence, num_fences: u32) void;
pub const waitForFences = SDL_WaitForGPUFences;

extern fn SDL_QueryGPUFence(device: *Device, fence: *Fence) bool;
pub const queryFence = SDL_QueryGPUFence;

extern fn SDL_ReleaseGPUFence(device: *Device, fence: *Fence) void;
pub const releaseFence = SDL_ReleaseGPUFence;

/// Determines whether a texture format is supported for a given type and
/// usage.
/// 
/// \param device a GPU context.
/// \param format the texture format to check.
/// \param type the type of texture (2D, 3D, Cube).
/// \param usage a bitmask of all usage scenarios to check.
/// \returns whether the texture format is supported for this type and usage.
/// 
/// \since This function is available since SDL 3.0.0.
/// 
extern fn SDL_GPUTextureSupportsFormat(device: *Device, format: TextureFormat, @"type": TextureType, usage: TextureUsageFlags) bool;
pub const textureSupportsFormat = SDL_GPUTextureSupportsFormat;

/// Determines if a sample count for a texture format is supported.
/// 
/// \param device a GPU context.
/// \param format the texture format to check.
/// \param sample_count the sample count to check.
/// \returns a hardware-specific version of min(preferred, possible).
/// 
/// \since This function is available since SDL 3.0.0.
/// 
extern fn SDL_GPUTextureSupportsSampleCount(device: *Device, format: TextureFormat, sample_count: SampleCount) bool;
pub const textureSupportsSampleCount = SDL_GPUTextureSupportsSampleCount;