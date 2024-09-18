const PixelFormat = @import("pixels.zig").PixelFormat;
const FColor = @import("pixels.zig").FColor;
const Rect = @import("rect.zig").Rect;
const PropertiesID = @import("properties.zig").PropertiesID;
const FlipMode = @import("surface.zig").FlipMode;
const Window = @import("video.zig").Window;

//pub const struct_SDL_GPUDevice = opaque {};
pub const Device = opaque {};

//pub const SDL_GPUDevice = struct_SDL_GPUDevice;
//pub const struct_SDL_GPUBuffer = opaque {};
pub const Buffer = opaque {};

//pub const SDL_GPUBuffer = struct_SDL_GPUBuffer;
//pub const struct_SDL_GPUTransferBuffer = opaque {};
pub const TransferBuffer = opaque {};

//pub const SDL_GPUTransferBuffer = struct_SDL_GPUTransferBuffer;
//pub const struct_SDL_GPUTexture = opaque {};
pub const Texture = opaque {};

//pub const SDL_GPUTexture = struct_SDL_GPUTexture;
//pub const struct_SDL_GPUSampler = opaque {};
pub const Sampler = opaque {};

//pub const SDL_GPUSampler = struct_SDL_GPUSampler;
//pub const struct_SDL_GPUShader = opaque {};
pub const Shader = opaque {};

//pub const SDL_GPUShader = struct_SDL_GPUShader;
//pub const struct_SDL_GPUComputePipeline = opaque {};
pub const ComputePipeline = opaque {};

//pub const SDL_GPUComputePipeline = struct_SDL_GPUComputePipeline;
//pub const struct_SDL_GPUGraphicsPipeline = opaque {};
pub const GraphicsPipeline = opaque {};

//pub const SDL_GPUGraphicsPipeline = struct_SDL_GPUGraphicsPipeline;
//pub const struct_SDL_GPUCommandBuffer = opaque {};
pub const CommandBuffer = opaque {};

//pub const SDL_GPUCommandBuffer = struct_SDL_GPUCommandBuffer;
//pub const struct_SDL_GPURenderPass = opaque {};
pub const RenderPass = opaque {};

//pub const SDL_GPURenderPass = struct_SDL_GPURenderPass;
//pub const struct_SDL_GPUComputePass = opaque {};
pub const ComputePass = opaque {};

//pub const SDL_GPUComputePass = struct_SDL_GPUComputePass;
//pub const struct_SDL_GPUCopyPass = opaque {};
pub const CopyPass = opaque {};

//pub const SDL_GPUCopyPass = struct_SDL_GPUCopyPass;
//pub const struct_SDL_GPUFence = opaque {};
pub const Fence = opaque {};

//pub const SDL_GPUFence = struct_SDL_GPUFence;
//pub const SDL_GPU_PRIMITIVETYPE_TRIANGLELIST: c_int = 0;
//pub const SDL_GPU_PRIMITIVETYPE_TRIANGLESTRIP: c_int = 1;
//pub const SDL_GPU_PRIMITIVETYPE_LINELIST: c_int = 2;
//pub const SDL_GPU_PRIMITIVETYPE_LINESTRIP: c_int = 3;
//pub const SDL_GPU_PRIMITIVETYPE_POINTLIST: c_int = 4;
//pub const enum_SDL_GPUPrimitiveType = c_uint;
pub const PrimitiveType = enum (c_uint) {
	trianglelist,
	trianglestrip,
	linelist,
	linestrip,
	pointlist,
};

//pub const SDL_GPUPrimitiveType = enum_SDL_GPUPrimitiveType;
//pub const SDL_GPU_LOADOP_LOAD: c_int = 0;
//pub const SDL_GPU_LOADOP_CLEAR: c_int = 1;
//pub const SDL_GPU_LOADOP_DONT_CARE: c_int = 2;
//pub const enum_SDL_GPULoadOp = c_uint;
pub const LoadOp = enum (c_uint) {
	load,
	clear,
	dont_care,
};

//pub const SDL_GPULoadOp = enum_SDL_GPULoadOp;
//pub const SDL_GPU_STOREOP_STORE: c_int = 0;
//pub const SDL_GPU_STOREOP_DONT_CARE: c_int = 1;
//pub const enum_SDL_GPUStoreOp = c_uint;
pub const StoreOp = enum (c_uint) {
	store,
	dont_care,
};

//pub const SDL_GPUStoreOp = enum_SDL_GPUStoreOp;
//pub const SDL_GPU_INDEXELEMENTSIZE_16BIT: c_int = 0;
//pub const SDL_GPU_INDEXELEMENTSIZE_32BIT: c_int = 1;
//pub const enum_SDL_GPUIndexElementSize = c_uint;
pub const IndexElementSize = enum (c_uint) {
	@"16bit",
	@"32bit",
};

//pub const SDL_GPUIndexElementSize = enum_SDL_GPUIndexElementSize;
//pub const SDL_GPU_TEXTUREFORMAT_INVALID: c_int = 0;
//pub const SDL_GPU_TEXTUREFORMAT_A8_UNORM: c_int = 1;
//pub const SDL_GPU_TEXTUREFORMAT_R8_UNORM: c_int = 2;
//pub const SDL_GPU_TEXTUREFORMAT_R8G8_UNORM: c_int = 3;
//pub const SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM: c_int = 4;
//pub const SDL_GPU_TEXTUREFORMAT_R16_UNORM: c_int = 5;
//pub const SDL_GPU_TEXTUREFORMAT_R16G16_UNORM: c_int = 6;
//pub const SDL_GPU_TEXTUREFORMAT_R16G16B16A16_UNORM: c_int = 7;
//pub const SDL_GPU_TEXTUREFORMAT_R10G10B10A2_UNORM: c_int = 8;
//pub const SDL_GPU_TEXTUREFORMAT_B5G6R5_UNORM: c_int = 9;
//pub const SDL_GPU_TEXTUREFORMAT_B5G5R5A1_UNORM: c_int = 10;
//pub const SDL_GPU_TEXTUREFORMAT_B4G4R4A4_UNORM: c_int = 11;
//pub const SDL_GPU_TEXTUREFORMAT_B8G8R8A8_UNORM: c_int = 12;
//pub const SDL_GPU_TEXTUREFORMAT_BC1_RGBA_UNORM: c_int = 13;
//pub const SDL_GPU_TEXTUREFORMAT_BC2_RGBA_UNORM: c_int = 14;
//pub const SDL_GPU_TEXTUREFORMAT_BC3_RGBA_UNORM: c_int = 15;
//pub const SDL_GPU_TEXTUREFORMAT_BC4_R_UNORM: c_int = 16;
//pub const SDL_GPU_TEXTUREFORMAT_BC5_RG_UNORM: c_int = 17;
//pub const SDL_GPU_TEXTUREFORMAT_BC7_RGBA_UNORM: c_int = 18;
//pub const SDL_GPU_TEXTUREFORMAT_BC6H_RGB_FLOAT: c_int = 19;
//pub const SDL_GPU_TEXTUREFORMAT_BC6H_RGB_UFLOAT: c_int = 20;
//pub const SDL_GPU_TEXTUREFORMAT_R8_SNORM: c_int = 21;
//pub const SDL_GPU_TEXTUREFORMAT_R8G8_SNORM: c_int = 22;
//pub const SDL_GPU_TEXTUREFORMAT_R8G8B8A8_SNORM: c_int = 23;
//pub const SDL_GPU_TEXTUREFORMAT_R16_SNORM: c_int = 24;
//pub const SDL_GPU_TEXTUREFORMAT_R16G16_SNORM: c_int = 25;
//pub const SDL_GPU_TEXTUREFORMAT_R16G16B16A16_SNORM: c_int = 26;
//pub const SDL_GPU_TEXTUREFORMAT_R16_FLOAT: c_int = 27;
//pub const SDL_GPU_TEXTUREFORMAT_R16G16_FLOAT: c_int = 28;
//pub const SDL_GPU_TEXTUREFORMAT_R16G16B16A16_FLOAT: c_int = 29;
//pub const SDL_GPU_TEXTUREFORMAT_R32_FLOAT: c_int = 30;
//pub const SDL_GPU_TEXTUREFORMAT_R32G32_FLOAT: c_int = 31;
//pub const SDL_GPU_TEXTUREFORMAT_R32G32B32A32_FLOAT: c_int = 32;
//pub const SDL_GPU_TEXTUREFORMAT_R11G11B10_UFLOAT: c_int = 33;
//pub const SDL_GPU_TEXTUREFORMAT_R8_UINT: c_int = 34;
//pub const SDL_GPU_TEXTUREFORMAT_R8G8_UINT: c_int = 35;
//pub const SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UINT: c_int = 36;
//pub const SDL_GPU_TEXTUREFORMAT_R16_UINT: c_int = 37;
//pub const SDL_GPU_TEXTUREFORMAT_R16G16_UINT: c_int = 38;
//pub const SDL_GPU_TEXTUREFORMAT_R16G16B16A16_UINT: c_int = 39;
//pub const SDL_GPU_TEXTUREFORMAT_R8_INT: c_int = 40;
//pub const SDL_GPU_TEXTUREFORMAT_R8G8_INT: c_int = 41;
//pub const SDL_GPU_TEXTUREFORMAT_R8G8B8A8_INT: c_int = 42;
//pub const SDL_GPU_TEXTUREFORMAT_R16_INT: c_int = 43;
//pub const SDL_GPU_TEXTUREFORMAT_R16G16_INT: c_int = 44;
//pub const SDL_GPU_TEXTUREFORMAT_R16G16B16A16_INT: c_int = 45;
//pub const SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM_SRGB: c_int = 46;
//pub const SDL_GPU_TEXTUREFORMAT_B8G8R8A8_UNORM_SRGB: c_int = 47;
//pub const SDL_GPU_TEXTUREFORMAT_BC1_RGBA_UNORM_SRGB: c_int = 48;
//pub const SDL_GPU_TEXTUREFORMAT_BC2_RGBA_UNORM_SRGB: c_int = 49;
//pub const SDL_GPU_TEXTUREFORMAT_BC3_RGBA_UNORM_SRGB: c_int = 50;
//pub const SDL_GPU_TEXTUREFORMAT_BC7_RGBA_UNORM_SRGB: c_int = 51;
//pub const SDL_GPU_TEXTUREFORMAT_D16_UNORM: c_int = 52;
//pub const SDL_GPU_TEXTUREFORMAT_D24_UNORM: c_int = 53;
//pub const SDL_GPU_TEXTUREFORMAT_D32_FLOAT: c_int = 54;
//pub const SDL_GPU_TEXTUREFORMAT_D24_UNORM_S8_UINT: c_int = 55;
//pub const SDL_GPU_TEXTUREFORMAT_D32_FLOAT_S8_UINT: c_int = 56;
//pub const enum_SDL_GPUTextureFormat = c_uint;
pub const TextureFormat = enum (c_uint) {
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
	r8_int,
	r8g8_int,
	r8g8b8a8_int,
	r16_int,
	r16g16_int,
	r16g16b16a16_int,
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
};

//pub const SDL_GPUTextureFormat = enum_SDL_GPUTextureFormat;
//pub const SDL_GPUTextureUsageFlags = Uint32;
pub const TextureUsageFlags = u32;
pub const TextureUsageNames = packed struct (c_int) {
	pub const sampler = @as(c_uint, 1) << @as(c_int, 0);
	pub const color_target = @as(c_uint, 1) << @as(c_int, 1);
	pub const depth_stencil_target = @as(c_uint, 1) << @as(c_int, 2);
	pub const graphics_storage_read = @as(c_uint, 1) << @as(c_int, 3);
	pub const compute_storage_read = @as(c_uint, 1) << @as(c_int, 4);
	pub const compute_storage_write = @as(c_uint, 1) << @as(c_int, 5);
};

//pub const SDL_GPU_TEXTURETYPE_2D: c_int = 0;
//pub const SDL_GPU_TEXTURETYPE_2D_ARRAY: c_int = 1;
//pub const SDL_GPU_TEXTURETYPE_3D: c_int = 2;
//pub const SDL_GPU_TEXTURETYPE_CUBE: c_int = 3;
//pub const SDL_GPU_TEXTURETYPE_CUBE_ARRAY: c_int = 4;
//pub const enum_SDL_GPUTextureType = c_uint;
pub const TextureType = enum (c_uint) {
	@"2d",
	@"2d_array",
	@"3d",
	cube,
	cube_array,
};

//pub const SDL_GPUTextureType = enum_SDL_GPUTextureType;
//pub const SDL_GPU_SAMPLECOUNT_1: c_int = 0;
//pub const SDL_GPU_SAMPLECOUNT_2: c_int = 1;
//pub const SDL_GPU_SAMPLECOUNT_4: c_int = 2;
//pub const SDL_GPU_SAMPLECOUNT_8: c_int = 3;
//pub const enum_SDL_GPUSampleCount = c_uint;
pub const SampleCount = enum (c_uint) {
	@"1",
	@"2",
	@"4",
	@"8",
};

//pub const SDL_GPUSampleCount = enum_SDL_GPUSampleCount;
//pub const SDL_GPU_CUBEMAPFACE_POSITIVEX: c_int = 0;
//pub const SDL_GPU_CUBEMAPFACE_NEGATIVEX: c_int = 1;
//pub const SDL_GPU_CUBEMAPFACE_POSITIVEY: c_int = 2;
//pub const SDL_GPU_CUBEMAPFACE_NEGATIVEY: c_int = 3;
//pub const SDL_GPU_CUBEMAPFACE_POSITIVEZ: c_int = 4;
//pub const SDL_GPU_CUBEMAPFACE_NEGATIVEZ: c_int = 5;
//pub const enum_SDL_GPUCubeMapFace = c_uint;
pub const CubeMapFace = enum (c_uint) {
	positivex,
	negativex,
	positivey,
	negativey,
	positivez,
	negativez,
};

//pub const SDL_GPUCubeMapFace = enum_SDL_GPUCubeMapFace;
//pub const SDL_GPUBufferUsageFlags = Uint32;
pub const BufferUsageFlags = u32;
pub const BufferUsageNames = packed struct (c_int) {
	pub const vertex = @as(c_uint, 1) << @as(c_int, 0);
	pub const index = @as(c_uint, 1) << @as(c_int, 1);
	pub const indirect = @as(c_uint, 1) << @as(c_int, 2);
	pub const graphics_storage_read = @as(c_uint, 1) << @as(c_int, 3);
	pub const compute_storage_read = @as(c_uint, 1) << @as(c_int, 4);
	pub const compute_storage_write = @as(c_uint, 1) << @as(c_int, 5);
};

//pub const SDL_GPU_TRANSFERBUFFERUSAGE_UPLOAD: c_int = 0;
//pub const SDL_GPU_TRANSFERBUFFERUSAGE_DOWNLOAD: c_int = 1;
//pub const enum_SDL_GPUTransferBufferUsage = c_uint;
pub const TransferBufferUsage = enum (c_uint) {
	upload,
	download,
};

//pub const SDL_GPUTransferBufferUsage = enum_SDL_GPUTransferBufferUsage;
//pub const SDL_GPU_SHADERSTAGE_VERTEX: c_int = 0;
//pub const SDL_GPU_SHADERSTAGE_FRAGMENT: c_int = 1;
//pub const enum_SDL_GPUShaderStage = c_uint;
pub const ShaderStage = enum (c_uint) {
	vertex,
	fragment,
};

//pub const SDL_GPUShaderStage = enum_SDL_GPUShaderStage;
//pub const SDL_GPUShaderFormat = Uint32;
pub const ShaderFormat = u32;
pub const ShaderFormatNames = packed struct (c_int) {
	pub const private = @as(c_uint, 1) << @as(c_int, 0);
	pub const spirv = @as(c_uint, 1) << @as(c_int, 1);
	pub const dxbc = @as(c_uint, 1) << @as(c_int, 2);
	pub const dxil = @as(c_uint, 1) << @as(c_int, 3);
	pub const msl = @as(c_uint, 1) << @as(c_int, 4);
	pub const metallib = @as(c_uint, 1) << @as(c_int, 5);
};

//pub const SDL_GPU_VERTEXELEMENTFORMAT_INVALID: c_int = 0;
//pub const SDL_GPU_VERTEXELEMENTFORMAT_INT: c_int = 1;
//pub const SDL_GPU_VERTEXELEMENTFORMAT_INT2: c_int = 2;
//pub const SDL_GPU_VERTEXELEMENTFORMAT_INT3: c_int = 3;
//pub const SDL_GPU_VERTEXELEMENTFORMAT_INT4: c_int = 4;
//pub const SDL_GPU_VERTEXELEMENTFORMAT_UINT: c_int = 5;
//pub const SDL_GPU_VERTEXELEMENTFORMAT_UINT2: c_int = 6;
//pub const SDL_GPU_VERTEXELEMENTFORMAT_UINT3: c_int = 7;
//pub const SDL_GPU_VERTEXELEMENTFORMAT_UINT4: c_int = 8;
//pub const SDL_GPU_VERTEXELEMENTFORMAT_FLOAT: c_int = 9;
//pub const SDL_GPU_VERTEXELEMENTFORMAT_FLOAT2: c_int = 10;
//pub const SDL_GPU_VERTEXELEMENTFORMAT_FLOAT3: c_int = 11;
//pub const SDL_GPU_VERTEXELEMENTFORMAT_FLOAT4: c_int = 12;
//pub const SDL_GPU_VERTEXELEMENTFORMAT_BYTE2: c_int = 13;
//pub const SDL_GPU_VERTEXELEMENTFORMAT_BYTE4: c_int = 14;
//pub const SDL_GPU_VERTEXELEMENTFORMAT_UBYTE2: c_int = 15;
//pub const SDL_GPU_VERTEXELEMENTFORMAT_UBYTE4: c_int = 16;
//pub const SDL_GPU_VERTEXELEMENTFORMAT_BYTE2_NORM: c_int = 17;
//pub const SDL_GPU_VERTEXELEMENTFORMAT_BYTE4_NORM: c_int = 18;
//pub const SDL_GPU_VERTEXELEMENTFORMAT_UBYTE2_NORM: c_int = 19;
//pub const SDL_GPU_VERTEXELEMENTFORMAT_UBYTE4_NORM: c_int = 20;
//pub const SDL_GPU_VERTEXELEMENTFORMAT_SHORT2: c_int = 21;
//pub const SDL_GPU_VERTEXELEMENTFORMAT_SHORT4: c_int = 22;
//pub const SDL_GPU_VERTEXELEMENTFORMAT_USHORT2: c_int = 23;
//pub const SDL_GPU_VERTEXELEMENTFORMAT_USHORT4: c_int = 24;
//pub const SDL_GPU_VERTEXELEMENTFORMAT_SHORT2_NORM: c_int = 25;
//pub const SDL_GPU_VERTEXELEMENTFORMAT_SHORT4_NORM: c_int = 26;
//pub const SDL_GPU_VERTEXELEMENTFORMAT_USHORT2_NORM: c_int = 27;
//pub const SDL_GPU_VERTEXELEMENTFORMAT_USHORT4_NORM: c_int = 28;
//pub const SDL_GPU_VERTEXELEMENTFORMAT_HALF2: c_int = 29;
//pub const SDL_GPU_VERTEXELEMENTFORMAT_HALF4: c_int = 30;
//pub const enum_SDL_GPUVertexElementFormat = c_uint;
pub const VertexElementFormat = enum (c_uint) {
	invalid,
	int,
	int2,
	int3,
	int4,
	uint,
	uint2,
	uint3,
	uint4,
	float,
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

//pub const SDL_GPUVertexElementFormat = enum_SDL_GPUVertexElementFormat;
//pub const SDL_GPU_VERTEXINPUTRATE_VERTEX: c_int = 0;
//pub const SDL_GPU_VERTEXINPUTRATE_INSTANCE: c_int = 1;
//pub const enum_SDL_GPUVertexInputRate = c_uint;
pub const VertexInputRate = enum (c_uint) {
	vertex,
	instance,
};

//pub const SDL_GPUVertexInputRate = enum_SDL_GPUVertexInputRate;
//pub const SDL_GPU_FILLMODE_FILL: c_int = 0;
//pub const SDL_GPU_FILLMODE_LINE: c_int = 1;
//pub const enum_SDL_GPUFillMode = c_uint;
pub const FillMode = enum (c_uint) {
	fill,
	line,
};

//pub const SDL_GPUFillMode = enum_SDL_GPUFillMode;
//pub const SDL_GPU_CULLMODE_NONE: c_int = 0;
//pub const SDL_GPU_CULLMODE_FRONT: c_int = 1;
//pub const SDL_GPU_CULLMODE_BACK: c_int = 2;
//pub const enum_SDL_GPUCullMode = c_uint;
pub const CullMode = enum (c_uint) {
	none,
	front,
	back,
};

//pub const SDL_GPUCullMode = enum_SDL_GPUCullMode;
//pub const SDL_GPU_FRONTFACE_COUNTER_CLOCKWISE: c_int = 0;
//pub const SDL_GPU_FRONTFACE_CLOCKWISE: c_int = 1;
//pub const enum_SDL_GPUFrontFace = c_uint;
pub const FrontFace = enum (c_uint) {
	counter_clockwise,
	clockwise,
};

//pub const SDL_GPUFrontFace = enum_SDL_GPUFrontFace;
//pub const SDL_GPU_COMPAREOP_INVALID: c_int = 0;
//pub const SDL_GPU_COMPAREOP_NEVER: c_int = 1;
//pub const SDL_GPU_COMPAREOP_LESS: c_int = 2;
//pub const SDL_GPU_COMPAREOP_EQUAL: c_int = 3;
//pub const SDL_GPU_COMPAREOP_LESS_OR_EQUAL: c_int = 4;
//pub const SDL_GPU_COMPAREOP_GREATER: c_int = 5;
//pub const SDL_GPU_COMPAREOP_NOT_EQUAL: c_int = 6;
//pub const SDL_GPU_COMPAREOP_GREATER_OR_EQUAL: c_int = 7;
//pub const SDL_GPU_COMPAREOP_ALWAYS: c_int = 8;
//pub const enum_SDL_GPUCompareOp = c_uint;
pub const CompareOp = enum (c_uint) {
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

//pub const SDL_GPUCompareOp = enum_SDL_GPUCompareOp;
//pub const SDL_GPU_STENCILOP_INVALID: c_int = 0;
//pub const SDL_GPU_STENCILOP_KEEP: c_int = 1;
//pub const SDL_GPU_STENCILOP_ZERO: c_int = 2;
//pub const SDL_GPU_STENCILOP_REPLACE: c_int = 3;
//pub const SDL_GPU_STENCILOP_INCREMENT_AND_CLAMP: c_int = 4;
//pub const SDL_GPU_STENCILOP_DECREMENT_AND_CLAMP: c_int = 5;
//pub const SDL_GPU_STENCILOP_INVERT: c_int = 6;
//pub const SDL_GPU_STENCILOP_INCREMENT_AND_WRAP: c_int = 7;
//pub const SDL_GPU_STENCILOP_DECREMENT_AND_WRAP: c_int = 8;
//pub const enum_SDL_GPUStencilOp = c_uint;
pub const StencilOp = enum (c_uint) {
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

//pub const SDL_GPUStencilOp = enum_SDL_GPUStencilOp;
//pub const SDL_GPU_BLENDOP_INVALID: c_int = 0;
//pub const SDL_GPU_BLENDOP_ADD: c_int = 1;
//pub const SDL_GPU_BLENDOP_SUBTRACT: c_int = 2;
//pub const SDL_GPU_BLENDOP_REVERSE_SUBTRACT: c_int = 3;
//pub const SDL_GPU_BLENDOP_MIN: c_int = 4;
//pub const SDL_GPU_BLENDOP_MAX: c_int = 5;
//pub const enum_SDL_GPUBlendOp = c_uint;
pub const BlendOp = enum (c_uint) {
	invalid,
	add,
	subtract,
	reverse_subtract,
	min,
	max,
};

//pub const SDL_GPUBlendOp = enum_SDL_GPUBlendOp;
//pub const SDL_GPU_BLENDFACTOR_INVALID: c_int = 0;
//pub const SDL_GPU_BLENDFACTOR_ZERO: c_int = 1;
//pub const SDL_GPU_BLENDFACTOR_ONE: c_int = 2;
//pub const SDL_GPU_BLENDFACTOR_SRC_COLOR: c_int = 3;
//pub const SDL_GPU_BLENDFACTOR_ONE_MINUS_SRC_COLOR: c_int = 4;
//pub const SDL_GPU_BLENDFACTOR_DST_COLOR: c_int = 5;
//pub const SDL_GPU_BLENDFACTOR_ONE_MINUS_DST_COLOR: c_int = 6;
//pub const SDL_GPU_BLENDFACTOR_SRC_ALPHA: c_int = 7;
//pub const SDL_GPU_BLENDFACTOR_ONE_MINUS_SRC_ALPHA: c_int = 8;
//pub const SDL_GPU_BLENDFACTOR_DST_ALPHA: c_int = 9;
//pub const SDL_GPU_BLENDFACTOR_ONE_MINUS_DST_ALPHA: c_int = 10;
//pub const SDL_GPU_BLENDFACTOR_CONSTANT_COLOR: c_int = 11;
//pub const SDL_GPU_BLENDFACTOR_ONE_MINUS_CONSTANT_COLOR: c_int = 12;
//pub const SDL_GPU_BLENDFACTOR_SRC_ALPHA_SATURATE: c_int = 13;
//pub const enum_SDL_GPUBlendFactor = c_uint;
pub const BlendFactor = enum (c_uint) {
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

//pub const SDL_GPUBlendFactor = enum_SDL_GPUBlendFactor;
//pub const SDL_GPUColorComponentFlags = Uint8;
pub const ColorComponentFlags = u8;
pub const ColorComponentNames = packed struct (c_int) {
	pub const r = @as(c_uint, 1) << @as(c_int, 0);
	pub const g = @as(c_uint, 1) << @as(c_int, 1);
	pub const b = @as(c_uint, 1) << @as(c_int, 2);
	pub const a = @as(c_uint, 1) << @as(c_int, 3);
};

//pub const SDL_GPU_FILTER_NEAREST: c_int = 0;
//pub const SDL_GPU_FILTER_LINEAR: c_int = 1;
//pub const enum_SDL_GPUFilter = c_uint;
pub const Filter = enum (c_uint) {
	nearest,
	linear,
};

//pub const SDL_GPUFilter = enum_SDL_GPUFilter;
//pub const SDL_GPU_SAMPLERMIPMAPMODE_NEAREST: c_int = 0;
//pub const SDL_GPU_SAMPLERMIPMAPMODE_LINEAR: c_int = 1;
//pub const enum_SDL_GPUSamplerMipmapMode = c_uint;
pub const SamplerMipmapMode = enum (c_uint) {
	nearest,
	linear,
};

//pub const SDL_GPUSamplerMipmapMode = enum_SDL_GPUSamplerMipmapMode;
//pub const SDL_GPU_SAMPLERADDRESSMODE_REPEAT: c_int = 0;
//pub const SDL_GPU_SAMPLERADDRESSMODE_MIRRORED_REPEAT: c_int = 1;
//pub const SDL_GPU_SAMPLERADDRESSMODE_CLAMP_TO_EDGE: c_int = 2;
//pub const enum_SDL_GPUSamplerAddressMode = c_uint;
pub const SamplerAddressMode = enum (c_uint) {
	repeat,
	mirrored_repeat,
	clamp_to_edge,
};

//pub const SDL_GPUSamplerAddressMode = enum_SDL_GPUSamplerAddressMode;
//pub const SDL_GPU_PRESENTMODE_VSYNC: c_int = 0;
//pub const SDL_GPU_PRESENTMODE_IMMEDIATE: c_int = 1;
//pub const SDL_GPU_PRESENTMODE_MAILBOX: c_int = 2;
//pub const enum_SDL_GPUPresentMode = c_uint;
pub const PresentMode = enum (c_uint) {
	vsync,
	immediate,
	mailbox,
};

//pub const SDL_GPUPresentMode = enum_SDL_GPUPresentMode;
//pub const SDL_GPU_SWAPCHAINCOMPOSITION_SDR: c_int = 0;
//pub const SDL_GPU_SWAPCHAINCOMPOSITION_SDR_LINEAR: c_int = 1;
//pub const SDL_GPU_SWAPCHAINCOMPOSITION_HDR_EXTENDED_LINEAR: c_int = 2;
//pub const SDL_GPU_SWAPCHAINCOMPOSITION_HDR10_ST2048: c_int = 3;
//pub const enum_SDL_GPUSwapchainComposition = c_uint;
pub const SwapchainComposition = enum (c_uint) {
	sdr,
	sdr_linear,
	hdr_extended_linear,
	hdr10_st2048,
};

//pub const SDL_GPUSwapchainComposition = enum_SDL_GPUSwapchainComposition;
//pub const struct_SDL_GPUViewport = extern struct {
pub const Viewport = extern struct {
//    x: f32 = @import("std").mem.zeroes(f32),
	x: f32 = @import("std").mem.zeroes(f32),//    y: f32 = @import("std").mem.zeroes(f32),
	y: f32 = @import("std").mem.zeroes(f32),//    w: f32 = @import("std").mem.zeroes(f32),
	w: f32 = @import("std").mem.zeroes(f32),//    h: f32 = @import("std").mem.zeroes(f32),
	h: f32 = @import("std").mem.zeroes(f32),//    min_depth: f32 = @import("std").mem.zeroes(f32),
	min_depth: f32 = @import("std").mem.zeroes(f32),//    max_depth: f32 = @import("std").mem.zeroes(f32),
	max_depth: f32 = @import("std").mem.zeroes(f32),//};
};
//pub const SDL_GPUViewport = struct_SDL_GPUViewport;
//pub const struct_SDL_GPUTextureTransferInfo = extern struct {
pub const TextureTransferInfo = extern struct {
//    transfer_buffer: ?*SDL_GPUTransferBuffer = @import("std").mem.zeroes(?*SDL_GPUTransferBuffer),
	transfer_buffer: ?*TransferBuffer = @import("std").mem.zeroes(?*TransferBuffer),//    offset: Uint32 = @import("std").mem.zeroes(Uint32),
	offset: u32 = @import("std").mem.zeroes(u32),//    pixels_per_row: Uint32 = @import("std").mem.zeroes(Uint32),
	pixels_per_row: u32 = @import("std").mem.zeroes(u32),//    rows_per_layer: Uint32 = @import("std").mem.zeroes(Uint32),
	rows_per_layer: u32 = @import("std").mem.zeroes(u32),//};
};
//pub const SDL_GPUTextureTransferInfo = struct_SDL_GPUTextureTransferInfo;
//pub const struct_SDL_GPUTransferBufferLocation = extern struct {
pub const TransferBufferLocation = extern struct {
//    transfer_buffer: ?*SDL_GPUTransferBuffer = @import("std").mem.zeroes(?*SDL_GPUTransferBuffer),
	transfer_buffer: ?*TransferBuffer = @import("std").mem.zeroes(?*TransferBuffer),//    offset: Uint32 = @import("std").mem.zeroes(Uint32),
	offset: u32 = @import("std").mem.zeroes(u32),//};
};
//pub const SDL_GPUTransferBufferLocation = struct_SDL_GPUTransferBufferLocation;
//pub const struct_SDL_GPUTextureLocation = extern struct {
pub const TextureLocation = extern struct {
//    texture: ?*SDL_GPUTexture = @import("std").mem.zeroes(?*SDL_GPUTexture),
	texture: ?*Texture = @import("std").mem.zeroes(?*Texture),//    mip_level: Uint32 = @import("std").mem.zeroes(Uint32),
	mip_level: u32 = @import("std").mem.zeroes(u32),//    layer: Uint32 = @import("std").mem.zeroes(Uint32),
	layer: u32 = @import("std").mem.zeroes(u32),//    x: Uint32 = @import("std").mem.zeroes(Uint32),
	x: u32 = @import("std").mem.zeroes(u32),//    y: Uint32 = @import("std").mem.zeroes(Uint32),
	y: u32 = @import("std").mem.zeroes(u32),//    z: Uint32 = @import("std").mem.zeroes(Uint32),
	z: u32 = @import("std").mem.zeroes(u32),//};
};
//pub const SDL_GPUTextureLocation = struct_SDL_GPUTextureLocation;
//pub const struct_SDL_GPUTextureRegion = extern struct {
pub const TextureRegion = extern struct {
//    texture: ?*SDL_GPUTexture = @import("std").mem.zeroes(?*SDL_GPUTexture),
	texture: ?*Texture = @import("std").mem.zeroes(?*Texture),//    mip_level: Uint32 = @import("std").mem.zeroes(Uint32),
	mip_level: u32 = @import("std").mem.zeroes(u32),//    layer: Uint32 = @import("std").mem.zeroes(Uint32),
	layer: u32 = @import("std").mem.zeroes(u32),//    x: Uint32 = @import("std").mem.zeroes(Uint32),
	x: u32 = @import("std").mem.zeroes(u32),//    y: Uint32 = @import("std").mem.zeroes(Uint32),
	y: u32 = @import("std").mem.zeroes(u32),//    z: Uint32 = @import("std").mem.zeroes(Uint32),
	z: u32 = @import("std").mem.zeroes(u32),//    w: Uint32 = @import("std").mem.zeroes(Uint32),
	w: u32 = @import("std").mem.zeroes(u32),//    h: Uint32 = @import("std").mem.zeroes(Uint32),
	h: u32 = @import("std").mem.zeroes(u32),//    d: Uint32 = @import("std").mem.zeroes(Uint32),
	d: u32 = @import("std").mem.zeroes(u32),//};
};
//pub const SDL_GPUTextureRegion = struct_SDL_GPUTextureRegion;
//pub const struct_SDL_GPUBlitRegion = extern struct {
pub const BlitRegion = extern struct {
//    texture: ?*SDL_GPUTexture = @import("std").mem.zeroes(?*SDL_GPUTexture),
	texture: ?*Texture = @import("std").mem.zeroes(?*Texture),//    mip_level: Uint32 = @import("std").mem.zeroes(Uint32),
	mip_level: u32 = @import("std").mem.zeroes(u32),//    layer_or_depth_plane: Uint32 = @import("std").mem.zeroes(Uint32),
	layer_or_depth_plane: u32 = @import("std").mem.zeroes(u32),//    x: Uint32 = @import("std").mem.zeroes(Uint32),
	x: u32 = @import("std").mem.zeroes(u32),//    y: Uint32 = @import("std").mem.zeroes(Uint32),
	y: u32 = @import("std").mem.zeroes(u32),//    w: Uint32 = @import("std").mem.zeroes(Uint32),
	w: u32 = @import("std").mem.zeroes(u32),//    h: Uint32 = @import("std").mem.zeroes(Uint32),
	h: u32 = @import("std").mem.zeroes(u32),//};
};
//pub const SDL_GPUBlitRegion = struct_SDL_GPUBlitRegion;
//pub const struct_SDL_GPUBufferLocation = extern struct {
pub const BufferLocation = extern struct {
//    buffer: ?*SDL_GPUBuffer = @import("std").mem.zeroes(?*SDL_GPUBuffer),
	buffer: ?*Buffer = @import("std").mem.zeroes(?*Buffer),//    offset: Uint32 = @import("std").mem.zeroes(Uint32),
	offset: u32 = @import("std").mem.zeroes(u32),//};
};
//pub const SDL_GPUBufferLocation = struct_SDL_GPUBufferLocation;
//pub const struct_SDL_GPUBufferRegion = extern struct {
pub const BufferRegion = extern struct {
//    buffer: ?*SDL_GPUBuffer = @import("std").mem.zeroes(?*SDL_GPUBuffer),
	buffer: ?*Buffer = @import("std").mem.zeroes(?*Buffer),//    offset: Uint32 = @import("std").mem.zeroes(Uint32),
	offset: u32 = @import("std").mem.zeroes(u32),//    size: Uint32 = @import("std").mem.zeroes(Uint32),
	size: u32 = @import("std").mem.zeroes(u32),//};
};
//pub const SDL_GPUBufferRegion = struct_SDL_GPUBufferRegion;
//pub const struct_SDL_GPUIndirectDrawCommand = extern struct {
pub const IndirectDrawCommand = extern struct {
//    num_vertices: Uint32 = @import("std").mem.zeroes(Uint32),
	num_vertices: u32 = @import("std").mem.zeroes(u32),//    num_instances: Uint32 = @import("std").mem.zeroes(Uint32),
	num_instances: u32 = @import("std").mem.zeroes(u32),//    first_vertex: Uint32 = @import("std").mem.zeroes(Uint32),
	first_vertex: u32 = @import("std").mem.zeroes(u32),//    first_instance: Uint32 = @import("std").mem.zeroes(Uint32),
	first_instance: u32 = @import("std").mem.zeroes(u32),//};
};
//pub const SDL_GPUIndirectDrawCommand = struct_SDL_GPUIndirectDrawCommand;
//pub const struct_SDL_GPUIndexedIndirectDrawCommand = extern struct {
pub const IndexedIndirectDrawCommand = extern struct {
//    num_indices: Uint32 = @import("std").mem.zeroes(Uint32),
	num_indices: u32 = @import("std").mem.zeroes(u32),//    num_instances: Uint32 = @import("std").mem.zeroes(Uint32),
	num_instances: u32 = @import("std").mem.zeroes(u32),//    first_index: Uint32 = @import("std").mem.zeroes(Uint32),
	first_index: u32 = @import("std").mem.zeroes(u32),//    vertex_offset: Sint32 = @import("std").mem.zeroes(Sint32),
	vertex_offset: i32 = @import("std").mem.zeroes(i32),//    first_instance: Uint32 = @import("std").mem.zeroes(Uint32),
	first_instance: u32 = @import("std").mem.zeroes(u32),//};
};
//pub const SDL_GPUIndexedIndirectDrawCommand = struct_SDL_GPUIndexedIndirectDrawCommand;
//pub const struct_SDL_GPUIndirectDispatchCommand = extern struct {
pub const IndirectDispatchCommand = extern struct {
//    groupcount_x: Uint32 = @import("std").mem.zeroes(Uint32),
	groupcount_x: u32 = @import("std").mem.zeroes(u32),//    groupcount_y: Uint32 = @import("std").mem.zeroes(Uint32),
	groupcount_y: u32 = @import("std").mem.zeroes(u32),//    groupcount_z: Uint32 = @import("std").mem.zeroes(Uint32),
	groupcount_z: u32 = @import("std").mem.zeroes(u32),//};
};
//pub const SDL_GPUIndirectDispatchCommand = struct_SDL_GPUIndirectDispatchCommand;
//pub const struct_SDL_GPUSamplerCreateInfo = extern struct {
pub const SamplerCreateInfo = extern struct {
//    min_filter: SDL_GPUFilter = @import("std").mem.zeroes(SDL_GPUFilter),
	min_filter: Filter = @import("std").mem.zeroes(Filter),//    mag_filter: SDL_GPUFilter = @import("std").mem.zeroes(SDL_GPUFilter),
	mag_filter: Filter = @import("std").mem.zeroes(Filter),//    mipmap_mode: SDL_GPUSamplerMipmapMode = @import("std").mem.zeroes(SDL_GPUSamplerMipmapMode),
	mipmap_mode: SamplerMipmapMode = @import("std").mem.zeroes(SamplerMipmapMode),//    address_mode_u: SDL_GPUSamplerAddressMode = @import("std").mem.zeroes(SDL_GPUSamplerAddressMode),
	address_mode_u: SamplerAddressMode = @import("std").mem.zeroes(SamplerAddressMode),//    address_mode_v: SDL_GPUSamplerAddressMode = @import("std").mem.zeroes(SDL_GPUSamplerAddressMode),
	address_mode_v: SamplerAddressMode = @import("std").mem.zeroes(SamplerAddressMode),//    address_mode_w: SDL_GPUSamplerAddressMode = @import("std").mem.zeroes(SDL_GPUSamplerAddressMode),
	address_mode_w: SamplerAddressMode = @import("std").mem.zeroes(SamplerAddressMode),//    mip_lod_bias: f32 = @import("std").mem.zeroes(f32),
	mip_lod_bias: f32 = @import("std").mem.zeroes(f32),//    max_anisotropy: f32 = @import("std").mem.zeroes(f32),
	max_anisotropy: f32 = @import("std").mem.zeroes(f32),//    compare_op: SDL_GPUCompareOp = @import("std").mem.zeroes(SDL_GPUCompareOp),
	compare_op: CompareOp = @import("std").mem.zeroes(CompareOp),//    min_lod: f32 = @import("std").mem.zeroes(f32),
	min_lod: f32 = @import("std").mem.zeroes(f32),//    max_lod: f32 = @import("std").mem.zeroes(f32),
	max_lod: f32 = @import("std").mem.zeroes(f32),//    enable_anisotropy: SDL_bool = @import("std").mem.zeroes(SDL_bool),
	enable_anisotropy: bool = @import("std").mem.zeroes(bool),//    enable_compare: SDL_bool = @import("std").mem.zeroes(SDL_bool),
	enable_compare: bool = @import("std").mem.zeroes(bool),//    padding1: Uint8 = @import("std").mem.zeroes(Uint8),
	padding1: u8 = @import("std").mem.zeroes(u8),//    padding2: Uint8 = @import("std").mem.zeroes(Uint8),
	padding2: u8 = @import("std").mem.zeroes(u8),//    props: SDL_PropertiesID = @import("std").mem.zeroes(SDL_PropertiesID),
	props: PropertiesID = @import("std").mem.zeroes(PropertiesID),//};
};
//pub const SDL_GPUSamplerCreateInfo = struct_SDL_GPUSamplerCreateInfo;
//pub const struct_SDL_GPUVertexBufferDescription = extern struct {
pub const VertexBufferDescription = extern struct {
//    slot: Uint32 = @import("std").mem.zeroes(Uint32),
	slot: u32 = @import("std").mem.zeroes(u32),//    pitch: Uint32 = @import("std").mem.zeroes(Uint32),
	pitch: u32 = @import("std").mem.zeroes(u32),//    input_rate: SDL_GPUVertexInputRate = @import("std").mem.zeroes(SDL_GPUVertexInputRate),
	input_rate: VertexInputRate = @import("std").mem.zeroes(VertexInputRate),//    instance_step_rate: Uint32 = @import("std").mem.zeroes(Uint32),
	instance_step_rate: u32 = @import("std").mem.zeroes(u32),//};
};
//pub const SDL_GPUVertexBufferDescription = struct_SDL_GPUVertexBufferDescription;
//pub const struct_SDL_GPUVertexAttribute = extern struct {
pub const VertexAttribute = extern struct {
//    location: Uint32 = @import("std").mem.zeroes(Uint32),
	location: u32 = @import("std").mem.zeroes(u32),//    buffer_slot: Uint32 = @import("std").mem.zeroes(Uint32),
	buffer_slot: u32 = @import("std").mem.zeroes(u32),//    format: SDL_GPUVertexElementFormat = @import("std").mem.zeroes(SDL_GPUVertexElementFormat),
	format: VertexElementFormat = @import("std").mem.zeroes(VertexElementFormat),//    offset: Uint32 = @import("std").mem.zeroes(Uint32),
	offset: u32 = @import("std").mem.zeroes(u32),//};
};
//pub const SDL_GPUVertexAttribute = struct_SDL_GPUVertexAttribute;
//pub const struct_SDL_GPUVertexInputState = extern struct {
pub const VertexInputState = extern struct {
//    vertex_buffer_descriptions: [*c]const SDL_GPUVertexBufferDescription = @import("std").mem.zeroes([*c]const SDL_GPUVertexBufferDescription),
	vertex_buffer_descriptions: [*c]const VertexBufferDescription = @import("std").mem.zeroes([*c]const VertexBufferDescription),//    num_vertex_buffers: Uint32 = @import("std").mem.zeroes(Uint32),
	num_vertex_buffers: u32 = @import("std").mem.zeroes(u32),//    vertex_attributes: [*c]const SDL_GPUVertexAttribute = @import("std").mem.zeroes([*c]const SDL_GPUVertexAttribute),
	vertex_attributes: [*c]const VertexAttribute = @import("std").mem.zeroes([*c]const VertexAttribute),//    num_vertex_attributes: Uint32 = @import("std").mem.zeroes(Uint32),
	num_vertex_attributes: u32 = @import("std").mem.zeroes(u32),//};
};
//pub const SDL_GPUVertexInputState = struct_SDL_GPUVertexInputState;
//pub const struct_SDL_GPUStencilOpState = extern struct {
pub const StencilOpState = extern struct {
//    fail_op: SDL_GPUStencilOp = @import("std").mem.zeroes(SDL_GPUStencilOp),
	fail_op: StencilOp = @import("std").mem.zeroes(StencilOp),//    pass_op: SDL_GPUStencilOp = @import("std").mem.zeroes(SDL_GPUStencilOp),
	pass_op: StencilOp = @import("std").mem.zeroes(StencilOp),//    depth_fail_op: SDL_GPUStencilOp = @import("std").mem.zeroes(SDL_GPUStencilOp),
	depth_fail_op: StencilOp = @import("std").mem.zeroes(StencilOp),//    compare_op: SDL_GPUCompareOp = @import("std").mem.zeroes(SDL_GPUCompareOp),
	compare_op: CompareOp = @import("std").mem.zeroes(CompareOp),//};
};
//pub const SDL_GPUStencilOpState = struct_SDL_GPUStencilOpState;
//pub const struct_SDL_GPUColorTargetBlendState = extern struct {
pub const ColorTargetBlendState = extern struct {
//    src_color_blendfactor: SDL_GPUBlendFactor = @import("std").mem.zeroes(SDL_GPUBlendFactor),
	src_color_blendfactor: BlendFactor = @import("std").mem.zeroes(BlendFactor),//    dst_color_blendfactor: SDL_GPUBlendFactor = @import("std").mem.zeroes(SDL_GPUBlendFactor),
	dst_color_blendfactor: BlendFactor = @import("std").mem.zeroes(BlendFactor),//    color_blend_op: SDL_GPUBlendOp = @import("std").mem.zeroes(SDL_GPUBlendOp),
	color_blend_op: BlendOp = @import("std").mem.zeroes(BlendOp),//    src_alpha_blendfactor: SDL_GPUBlendFactor = @import("std").mem.zeroes(SDL_GPUBlendFactor),
	src_alpha_blendfactor: BlendFactor = @import("std").mem.zeroes(BlendFactor),//    dst_alpha_blendfactor: SDL_GPUBlendFactor = @import("std").mem.zeroes(SDL_GPUBlendFactor),
	dst_alpha_blendfactor: BlendFactor = @import("std").mem.zeroes(BlendFactor),//    alpha_blend_op: SDL_GPUBlendOp = @import("std").mem.zeroes(SDL_GPUBlendOp),
	alpha_blend_op: BlendOp = @import("std").mem.zeroes(BlendOp),//    color_write_mask: SDL_GPUColorComponentFlags = @import("std").mem.zeroes(SDL_GPUColorComponentFlags),
	color_write_mask: ColorComponentFlags = @import("std").mem.zeroes(ColorComponentFlags),//    enable_blend: SDL_bool = @import("std").mem.zeroes(SDL_bool),
	enable_blend: bool = @import("std").mem.zeroes(bool),//    enable_color_write_mask: SDL_bool = @import("std").mem.zeroes(SDL_bool),
	enable_color_write_mask: bool = @import("std").mem.zeroes(bool),//    padding2: Uint8 = @import("std").mem.zeroes(Uint8),
	padding2: u8 = @import("std").mem.zeroes(u8),//    padding3: Uint8 = @import("std").mem.zeroes(Uint8),
	padding3: u8 = @import("std").mem.zeroes(u8),//};
};
//pub const SDL_GPUColorTargetBlendState = struct_SDL_GPUColorTargetBlendState;
//pub const struct_SDL_GPUShaderCreateInfo = extern struct {
pub const ShaderCreateInfo = extern struct {
//    code_size: usize = @import("std").mem.zeroes(usize),
	code_size: usize = @import("std").mem.zeroes(usize),//    code: [*c]const Uint8 = @import("std").mem.zeroes([*c]const Uint8),
	code: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),//    entrypoint: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
	entrypoint: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),//    format: SDL_GPUShaderFormat = @import("std").mem.zeroes(SDL_GPUShaderFormat),
	format: ShaderFormat = @import("std").mem.zeroes(ShaderFormat),//    stage: SDL_GPUShaderStage = @import("std").mem.zeroes(SDL_GPUShaderStage),
	stage: ShaderStage = @import("std").mem.zeroes(ShaderStage),//    num_samplers: Uint32 = @import("std").mem.zeroes(Uint32),
	num_samplers: u32 = @import("std").mem.zeroes(u32),//    num_storage_textures: Uint32 = @import("std").mem.zeroes(Uint32),
	num_storage_textures: u32 = @import("std").mem.zeroes(u32),//    num_storage_buffers: Uint32 = @import("std").mem.zeroes(Uint32),
	num_storage_buffers: u32 = @import("std").mem.zeroes(u32),//    num_uniform_buffers: Uint32 = @import("std").mem.zeroes(Uint32),
	num_uniform_buffers: u32 = @import("std").mem.zeroes(u32),//    props: SDL_PropertiesID = @import("std").mem.zeroes(SDL_PropertiesID),
	props: PropertiesID = @import("std").mem.zeroes(PropertiesID),//};
};
//pub const SDL_GPUShaderCreateInfo = struct_SDL_GPUShaderCreateInfo;
//pub const struct_SDL_GPUTextureCreateInfo = extern struct {
pub const TextureCreateInfo = extern struct {
//    type: SDL_GPUTextureType = @import("std").mem.zeroes(SDL_GPUTextureType),
	type: TextureType = @import("std").mem.zeroes(TextureType),//    format: SDL_GPUTextureFormat = @import("std").mem.zeroes(SDL_GPUTextureFormat),
	format: TextureFormat = @import("std").mem.zeroes(TextureFormat),//    usage: SDL_GPUTextureUsageFlags = @import("std").mem.zeroes(SDL_GPUTextureUsageFlags),
	usage: TextureUsageFlags = @import("std").mem.zeroes(TextureUsageFlags),//    width: Uint32 = @import("std").mem.zeroes(Uint32),
	width: u32 = @import("std").mem.zeroes(u32),//    height: Uint32 = @import("std").mem.zeroes(Uint32),
	height: u32 = @import("std").mem.zeroes(u32),//    layer_count_or_depth: Uint32 = @import("std").mem.zeroes(Uint32),
	layer_count_or_depth: u32 = @import("std").mem.zeroes(u32),//    num_levels: Uint32 = @import("std").mem.zeroes(Uint32),
	num_levels: u32 = @import("std").mem.zeroes(u32),//    sample_count: SDL_GPUSampleCount = @import("std").mem.zeroes(SDL_GPUSampleCount),
	sample_count: SampleCount = @import("std").mem.zeroes(SampleCount),//    props: SDL_PropertiesID = @import("std").mem.zeroes(SDL_PropertiesID),
	props: PropertiesID = @import("std").mem.zeroes(PropertiesID),//};
};
//pub const SDL_GPUTextureCreateInfo = struct_SDL_GPUTextureCreateInfo;
//pub const struct_SDL_GPUBufferCreateInfo = extern struct {
pub const BufferCreateInfo = extern struct {
//    usage: SDL_GPUBufferUsageFlags = @import("std").mem.zeroes(SDL_GPUBufferUsageFlags),
	usage: BufferUsageFlags = @import("std").mem.zeroes(BufferUsageFlags),//    size: Uint32 = @import("std").mem.zeroes(Uint32),
	size: u32 = @import("std").mem.zeroes(u32),//    props: SDL_PropertiesID = @import("std").mem.zeroes(SDL_PropertiesID),
	props: PropertiesID = @import("std").mem.zeroes(PropertiesID),//};
};
//pub const SDL_GPUBufferCreateInfo = struct_SDL_GPUBufferCreateInfo;
//pub const struct_SDL_GPUTransferBufferCreateInfo = extern struct {
pub const TransferBufferCreateInfo = extern struct {
//    usage: SDL_GPUTransferBufferUsage = @import("std").mem.zeroes(SDL_GPUTransferBufferUsage),
	usage: TransferBufferUsage = @import("std").mem.zeroes(TransferBufferUsage),//    size: Uint32 = @import("std").mem.zeroes(Uint32),
	size: u32 = @import("std").mem.zeroes(u32),//    props: SDL_PropertiesID = @import("std").mem.zeroes(SDL_PropertiesID),
	props: PropertiesID = @import("std").mem.zeroes(PropertiesID),//};
};
//pub const SDL_GPUTransferBufferCreateInfo = struct_SDL_GPUTransferBufferCreateInfo;
//pub const struct_SDL_GPURasterizerState = extern struct {
pub const RasterizerState = extern struct {
//    fill_mode: SDL_GPUFillMode = @import("std").mem.zeroes(SDL_GPUFillMode),
	fill_mode: FillMode = @import("std").mem.zeroes(FillMode),//    cull_mode: SDL_GPUCullMode = @import("std").mem.zeroes(SDL_GPUCullMode),
	cull_mode: CullMode = @import("std").mem.zeroes(CullMode),//    front_face: SDL_GPUFrontFace = @import("std").mem.zeroes(SDL_GPUFrontFace),
	front_face: FrontFace = @import("std").mem.zeroes(FrontFace),//    depth_bias_constant_factor: f32 = @import("std").mem.zeroes(f32),
	depth_bias_constant_factor: f32 = @import("std").mem.zeroes(f32),//    depth_bias_clamp: f32 = @import("std").mem.zeroes(f32),
	depth_bias_clamp: f32 = @import("std").mem.zeroes(f32),//    depth_bias_slope_factor: f32 = @import("std").mem.zeroes(f32),
	depth_bias_slope_factor: f32 = @import("std").mem.zeroes(f32),//    enable_depth_bias: SDL_bool = @import("std").mem.zeroes(SDL_bool),
	enable_depth_bias: bool = @import("std").mem.zeroes(bool),//    padding1: Uint8 = @import("std").mem.zeroes(Uint8),
	padding1: u8 = @import("std").mem.zeroes(u8),//    padding2: Uint8 = @import("std").mem.zeroes(Uint8),
	padding2: u8 = @import("std").mem.zeroes(u8),//    padding3: Uint8 = @import("std").mem.zeroes(Uint8),
	padding3: u8 = @import("std").mem.zeroes(u8),//};
};
//pub const SDL_GPURasterizerState = struct_SDL_GPURasterizerState;
//pub const struct_SDL_GPUMultisampleState = extern struct {
pub const MultisampleState = extern struct {
//    sample_count: SDL_GPUSampleCount = @import("std").mem.zeroes(SDL_GPUSampleCount),
	sample_count: SampleCount = @import("std").mem.zeroes(SampleCount),//    sample_mask: Uint32 = @import("std").mem.zeroes(Uint32),
	sample_mask: u32 = @import("std").mem.zeroes(u32),//    enable_mask: SDL_bool = @import("std").mem.zeroes(SDL_bool),
	enable_mask: bool = @import("std").mem.zeroes(bool),//    padding1: Uint8 = @import("std").mem.zeroes(Uint8),
	padding1: u8 = @import("std").mem.zeroes(u8),//    padding2: Uint8 = @import("std").mem.zeroes(Uint8),
	padding2: u8 = @import("std").mem.zeroes(u8),//    padding3: Uint8 = @import("std").mem.zeroes(Uint8),
	padding3: u8 = @import("std").mem.zeroes(u8),//};
};
//pub const SDL_GPUMultisampleState = struct_SDL_GPUMultisampleState;
//pub const struct_SDL_GPUDepthStencilState = extern struct {
pub const DepthStencilState = extern struct {
//    compare_op: SDL_GPUCompareOp = @import("std").mem.zeroes(SDL_GPUCompareOp),
	compare_op: CompareOp = @import("std").mem.zeroes(CompareOp),//    back_stencil_state: SDL_GPUStencilOpState = @import("std").mem.zeroes(SDL_GPUStencilOpState),
	back_stencil_state: StencilOpState = @import("std").mem.zeroes(StencilOpState),//    front_stencil_state: SDL_GPUStencilOpState = @import("std").mem.zeroes(SDL_GPUStencilOpState),
	front_stencil_state: StencilOpState = @import("std").mem.zeroes(StencilOpState),//    compare_mask: Uint8 = @import("std").mem.zeroes(Uint8),
	compare_mask: u8 = @import("std").mem.zeroes(u8),//    write_mask: Uint8 = @import("std").mem.zeroes(Uint8),
	write_mask: u8 = @import("std").mem.zeroes(u8),//    enable_depth_test: SDL_bool = @import("std").mem.zeroes(SDL_bool),
	enable_depth_test: bool = @import("std").mem.zeroes(bool),//    enable_depth_write: SDL_bool = @import("std").mem.zeroes(SDL_bool),
	enable_depth_write: bool = @import("std").mem.zeroes(bool),//    enable_stencil_test: SDL_bool = @import("std").mem.zeroes(SDL_bool),
	enable_stencil_test: bool = @import("std").mem.zeroes(bool),//    padding1: Uint8 = @import("std").mem.zeroes(Uint8),
	padding1: u8 = @import("std").mem.zeroes(u8),//    padding2: Uint8 = @import("std").mem.zeroes(Uint8),
	padding2: u8 = @import("std").mem.zeroes(u8),//    padding3: Uint8 = @import("std").mem.zeroes(Uint8),
	padding3: u8 = @import("std").mem.zeroes(u8),//};
};
//pub const SDL_GPUDepthStencilState = struct_SDL_GPUDepthStencilState;
//pub const struct_SDL_GPUColorTargetDescription = extern struct {
pub const ColorTargetDescription = extern struct {
//    format: SDL_GPUTextureFormat = @import("std").mem.zeroes(SDL_GPUTextureFormat),
	format: TextureFormat = @import("std").mem.zeroes(TextureFormat),//    blend_state: SDL_GPUColorTargetBlendState = @import("std").mem.zeroes(SDL_GPUColorTargetBlendState),
	blend_state: ColorTargetBlendState = @import("std").mem.zeroes(ColorTargetBlendState),//};
};
//pub const SDL_GPUColorTargetDescription = struct_SDL_GPUColorTargetDescription;
//pub const struct_SDL_GpuGraphicsPipelineTargetInfo = extern struct {
pub const GpuGraphicsPipelineTargetInfo = extern struct {
//    color_target_descriptions: [*c]const SDL_GPUColorTargetDescription = @import("std").mem.zeroes([*c]const SDL_GPUColorTargetDescription),
	color_target_descriptions: [*c]const ColorTargetDescription = @import("std").mem.zeroes([*c]const ColorTargetDescription),//    num_color_targets: Uint32 = @import("std").mem.zeroes(Uint32),
	num_color_targets: u32 = @import("std").mem.zeroes(u32),//    depth_stencil_format: SDL_GPUTextureFormat = @import("std").mem.zeroes(SDL_GPUTextureFormat),
	depth_stencil_format: TextureFormat = @import("std").mem.zeroes(TextureFormat),//    has_depth_stencil_target: SDL_bool = @import("std").mem.zeroes(SDL_bool),
	has_depth_stencil_target: bool = @import("std").mem.zeroes(bool),//    padding1: Uint8 = @import("std").mem.zeroes(Uint8),
	padding1: u8 = @import("std").mem.zeroes(u8),//    padding2: Uint8 = @import("std").mem.zeroes(Uint8),
	padding2: u8 = @import("std").mem.zeroes(u8),//    padding3: Uint8 = @import("std").mem.zeroes(Uint8),
	padding3: u8 = @import("std").mem.zeroes(u8),//};
};
//pub const SDL_GpuGraphicsPipelineTargetInfo = struct_SDL_GpuGraphicsPipelineTargetInfo;
//pub const struct_SDL_GPUGraphicsPipelineCreateInfo = extern struct {
pub const GraphicsPipelineCreateInfo = extern struct {
//    vertex_shader: ?*SDL_GPUShader = @import("std").mem.zeroes(?*SDL_GPUShader),
	vertex_shader: ?*Shader = @import("std").mem.zeroes(?*Shader),//    fragment_shader: ?*SDL_GPUShader = @import("std").mem.zeroes(?*SDL_GPUShader),
	fragment_shader: ?*Shader = @import("std").mem.zeroes(?*Shader),//    vertex_input_state: SDL_GPUVertexInputState = @import("std").mem.zeroes(SDL_GPUVertexInputState),
	vertex_input_state: VertexInputState = @import("std").mem.zeroes(VertexInputState),//    primitive_type: SDL_GPUPrimitiveType = @import("std").mem.zeroes(SDL_GPUPrimitiveType),
	primitive_type: PrimitiveType = @import("std").mem.zeroes(PrimitiveType),//    rasterizer_state: SDL_GPURasterizerState = @import("std").mem.zeroes(SDL_GPURasterizerState),
	rasterizer_state: RasterizerState = @import("std").mem.zeroes(RasterizerState),//    multisample_state: SDL_GPUMultisampleState = @import("std").mem.zeroes(SDL_GPUMultisampleState),
	multisample_state: MultisampleState = @import("std").mem.zeroes(MultisampleState),//    depth_stencil_state: SDL_GPUDepthStencilState = @import("std").mem.zeroes(SDL_GPUDepthStencilState),
	depth_stencil_state: DepthStencilState = @import("std").mem.zeroes(DepthStencilState),//    target_info: SDL_GpuGraphicsPipelineTargetInfo = @import("std").mem.zeroes(SDL_GpuGraphicsPipelineTargetInfo),
	target_info: GpuGraphicsPipelineTargetInfo = @import("std").mem.zeroes(GpuGraphicsPipelineTargetInfo),//    props: SDL_PropertiesID = @import("std").mem.zeroes(SDL_PropertiesID),
	props: PropertiesID = @import("std").mem.zeroes(PropertiesID),//};
};
//pub const SDL_GPUGraphicsPipelineCreateInfo = struct_SDL_GPUGraphicsPipelineCreateInfo;
//pub const struct_SDL_GPUComputePipelineCreateInfo = extern struct {
pub const ComputePipelineCreateInfo = extern struct {
//    code_size: usize = @import("std").mem.zeroes(usize),
	code_size: usize = @import("std").mem.zeroes(usize),//    code: [*c]const Uint8 = @import("std").mem.zeroes([*c]const Uint8),
	code: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),//    entrypoint: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
	entrypoint: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),//    format: SDL_GPUShaderFormat = @import("std").mem.zeroes(SDL_GPUShaderFormat),
	format: ShaderFormat = @import("std").mem.zeroes(ShaderFormat),//    num_samplers: Uint32 = @import("std").mem.zeroes(Uint32),
	num_samplers: u32 = @import("std").mem.zeroes(u32),//    num_readonly_storage_textures: Uint32 = @import("std").mem.zeroes(Uint32),
	num_readonly_storage_textures: u32 = @import("std").mem.zeroes(u32),//    num_readonly_storage_buffers: Uint32 = @import("std").mem.zeroes(Uint32),
	num_readonly_storage_buffers: u32 = @import("std").mem.zeroes(u32),//    num_writeonly_storage_textures: Uint32 = @import("std").mem.zeroes(Uint32),
	num_writeonly_storage_textures: u32 = @import("std").mem.zeroes(u32),//    num_writeonly_storage_buffers: Uint32 = @import("std").mem.zeroes(Uint32),
	num_writeonly_storage_buffers: u32 = @import("std").mem.zeroes(u32),//    num_uniform_buffers: Uint32 = @import("std").mem.zeroes(Uint32),
	num_uniform_buffers: u32 = @import("std").mem.zeroes(u32),//    threadcount_x: Uint32 = @import("std").mem.zeroes(Uint32),
	threadcount_x: u32 = @import("std").mem.zeroes(u32),//    threadcount_y: Uint32 = @import("std").mem.zeroes(Uint32),
	threadcount_y: u32 = @import("std").mem.zeroes(u32),//    threadcount_z: Uint32 = @import("std").mem.zeroes(Uint32),
	threadcount_z: u32 = @import("std").mem.zeroes(u32),//    props: SDL_PropertiesID = @import("std").mem.zeroes(SDL_PropertiesID),
	props: PropertiesID = @import("std").mem.zeroes(PropertiesID),//};
};
//pub const SDL_GPUComputePipelineCreateInfo = struct_SDL_GPUComputePipelineCreateInfo;
//pub const struct_SDL_GPUColorTargetInfo = extern struct {
pub const ColorTargetInfo = extern struct {
//    texture: ?*SDL_GPUTexture = @import("std").mem.zeroes(?*SDL_GPUTexture),
	texture: ?*Texture = @import("std").mem.zeroes(?*Texture),//    mip_level: Uint32 = @import("std").mem.zeroes(Uint32),
	mip_level: u32 = @import("std").mem.zeroes(u32),//    layer_or_depth_plane: Uint32 = @import("std").mem.zeroes(Uint32),
	layer_or_depth_plane: u32 = @import("std").mem.zeroes(u32),//    clear_color: SDL_FColor = @import("std").mem.zeroes(SDL_FColor),
	clear_color: FColor = @import("std").mem.zeroes(FColor),//    load_op: SDL_GPULoadOp = @import("std").mem.zeroes(SDL_GPULoadOp),
	load_op: LoadOp = @import("std").mem.zeroes(LoadOp),//    store_op: SDL_GPUStoreOp = @import("std").mem.zeroes(SDL_GPUStoreOp),
	store_op: StoreOp = @import("std").mem.zeroes(StoreOp),//    cycle: SDL_bool = @import("std").mem.zeroes(SDL_bool),
	cycle: bool = @import("std").mem.zeroes(bool),//    padding1: Uint8 = @import("std").mem.zeroes(Uint8),
	padding1: u8 = @import("std").mem.zeroes(u8),//    padding2: Uint8 = @import("std").mem.zeroes(Uint8),
	padding2: u8 = @import("std").mem.zeroes(u8),//    padding3: Uint8 = @import("std").mem.zeroes(Uint8),
	padding3: u8 = @import("std").mem.zeroes(u8),//};
};
//pub const SDL_GPUColorTargetInfo = struct_SDL_GPUColorTargetInfo;
//pub const struct_SDL_GPUDepthStencilTargetInfo = extern struct {
pub const DepthStencilTargetInfo = extern struct {
//    texture: ?*SDL_GPUTexture = @import("std").mem.zeroes(?*SDL_GPUTexture),
	texture: ?*Texture = @import("std").mem.zeroes(?*Texture),//    clear_depth: f32 = @import("std").mem.zeroes(f32),
	clear_depth: f32 = @import("std").mem.zeroes(f32),//    load_op: SDL_GPULoadOp = @import("std").mem.zeroes(SDL_GPULoadOp),
	load_op: LoadOp = @import("std").mem.zeroes(LoadOp),//    store_op: SDL_GPUStoreOp = @import("std").mem.zeroes(SDL_GPUStoreOp),
	store_op: StoreOp = @import("std").mem.zeroes(StoreOp),//    stencil_load_op: SDL_GPULoadOp = @import("std").mem.zeroes(SDL_GPULoadOp),
	stencil_load_op: LoadOp = @import("std").mem.zeroes(LoadOp),//    stencil_store_op: SDL_GPUStoreOp = @import("std").mem.zeroes(SDL_GPUStoreOp),
	stencil_store_op: StoreOp = @import("std").mem.zeroes(StoreOp),//    cycle: SDL_bool = @import("std").mem.zeroes(SDL_bool),
	cycle: bool = @import("std").mem.zeroes(bool),//    clear_stencil: Uint8 = @import("std").mem.zeroes(Uint8),
	clear_stencil: u8 = @import("std").mem.zeroes(u8),//    padding1: Uint8 = @import("std").mem.zeroes(Uint8),
	padding1: u8 = @import("std").mem.zeroes(u8),//    padding2: Uint8 = @import("std").mem.zeroes(Uint8),
	padding2: u8 = @import("std").mem.zeroes(u8),//};
};
//pub const SDL_GPUDepthStencilTargetInfo = struct_SDL_GPUDepthStencilTargetInfo;
//pub const struct_SDL_GPUBlitInfo = extern struct {
pub const BlitInfo = extern struct {
//    source: SDL_GPUBlitRegion = @import("std").mem.zeroes(SDL_GPUBlitRegion),
	source: BlitRegion = @import("std").mem.zeroes(BlitRegion),//    destination: SDL_GPUBlitRegion = @import("std").mem.zeroes(SDL_GPUBlitRegion),
	destination: BlitRegion = @import("std").mem.zeroes(BlitRegion),//    load_op: SDL_GPULoadOp = @import("std").mem.zeroes(SDL_GPULoadOp),
	load_op: LoadOp = @import("std").mem.zeroes(LoadOp),//    clear_color: SDL_FColor = @import("std").mem.zeroes(SDL_FColor),
	clear_color: FColor = @import("std").mem.zeroes(FColor),//    flip_mode: SDL_FlipMode = @import("std").mem.zeroes(SDL_FlipMode),
	flip_mode: FlipMode = @import("std").mem.zeroes(FlipMode),//    filter: SDL_GPUFilter = @import("std").mem.zeroes(SDL_GPUFilter),
	filter: Filter = @import("std").mem.zeroes(Filter),//    cycle: SDL_bool = @import("std").mem.zeroes(SDL_bool),
	cycle: bool = @import("std").mem.zeroes(bool),//    padding1: Uint8 = @import("std").mem.zeroes(Uint8),
	padding1: u8 = @import("std").mem.zeroes(u8),//    padding2: Uint8 = @import("std").mem.zeroes(Uint8),
	padding2: u8 = @import("std").mem.zeroes(u8),//    padding3: Uint8 = @import("std").mem.zeroes(Uint8),
	padding3: u8 = @import("std").mem.zeroes(u8),//};
};
//pub const SDL_GPUBlitInfo = struct_SDL_GPUBlitInfo;
//pub const struct_SDL_GPUBufferBinding = extern struct {
pub const BufferBinding = extern struct {
//    buffer: ?*SDL_GPUBuffer = @import("std").mem.zeroes(?*SDL_GPUBuffer),
	buffer: ?*Buffer = @import("std").mem.zeroes(?*Buffer),//    offset: Uint32 = @import("std").mem.zeroes(Uint32),
	offset: u32 = @import("std").mem.zeroes(u32),//};
};
//pub const SDL_GPUBufferBinding = struct_SDL_GPUBufferBinding;
//pub const struct_SDL_GPUTextureSamplerBinding = extern struct {
pub const TextureSamplerBinding = extern struct {
//    texture: ?*SDL_GPUTexture = @import("std").mem.zeroes(?*SDL_GPUTexture),
	texture: ?*Texture = @import("std").mem.zeroes(?*Texture),//    sampler: ?*SDL_GPUSampler = @import("std").mem.zeroes(?*SDL_GPUSampler),
	sampler: ?*Sampler = @import("std").mem.zeroes(?*Sampler),//};
};
//pub const SDL_GPUTextureSamplerBinding = struct_SDL_GPUTextureSamplerBinding;
//pub const struct_SDL_GPUStorageBufferWriteOnlyBinding = extern struct {
pub const StorageBufferWriteOnlyBinding = extern struct {
//    buffer: ?*SDL_GPUBuffer = @import("std").mem.zeroes(?*SDL_GPUBuffer),
	buffer: ?*Buffer = @import("std").mem.zeroes(?*Buffer),//    cycle: SDL_bool = @import("std").mem.zeroes(SDL_bool),
	cycle: bool = @import("std").mem.zeroes(bool),//    padding1: Uint8 = @import("std").mem.zeroes(Uint8),
	padding1: u8 = @import("std").mem.zeroes(u8),//    padding2: Uint8 = @import("std").mem.zeroes(Uint8),
	padding2: u8 = @import("std").mem.zeroes(u8),//    padding3: Uint8 = @import("std").mem.zeroes(Uint8),
	padding3: u8 = @import("std").mem.zeroes(u8),//};
};
//pub const SDL_GPUStorageBufferWriteOnlyBinding = struct_SDL_GPUStorageBufferWriteOnlyBinding;
//pub const struct_SDL_GPUStorageTextureWriteOnlyBinding = extern struct {
pub const StorageTextureWriteOnlyBinding = extern struct {
//    texture: ?*SDL_GPUTexture = @import("std").mem.zeroes(?*SDL_GPUTexture),
	texture: ?*Texture = @import("std").mem.zeroes(?*Texture),//    mip_level: Uint32 = @import("std").mem.zeroes(Uint32),
	mip_level: u32 = @import("std").mem.zeroes(u32),//    layer: Uint32 = @import("std").mem.zeroes(Uint32),
	layer: u32 = @import("std").mem.zeroes(u32),//    cycle: SDL_bool = @import("std").mem.zeroes(SDL_bool),
	cycle: bool = @import("std").mem.zeroes(bool),//    padding1: Uint8 = @import("std").mem.zeroes(Uint8),
	padding1: u8 = @import("std").mem.zeroes(u8),//    padding2: Uint8 = @import("std").mem.zeroes(Uint8),
	padding2: u8 = @import("std").mem.zeroes(u8),//    padding3: Uint8 = @import("std").mem.zeroes(Uint8),
	padding3: u8 = @import("std").mem.zeroes(u8),//};
};
//pub const SDL_GPUStorageTextureWriteOnlyBinding = struct_SDL_GPUStorageTextureWriteOnlyBinding;
//pub extern fn SDL_GPUSupportsShaderFormats(format_flags: SDL_GPUShaderFormat, name: [*c]const u8) SDL_bool;
pub extern fn SDL_GPUSupportsShaderFormats(format_flags: ShaderFormat, name: [*c]const u8) bool;
pub const supportsShaderFormats = SDL_GPUSupportsShaderFormats;
//pub extern fn SDL_GPUSupportsProperties(props: SDL_PropertiesID) SDL_bool;
pub extern fn SDL_GPUSupportsProperties(props: PropertiesID) bool;
pub const supportsProperties = SDL_GPUSupportsProperties;
//pub extern fn SDL_CreateGPUDevice(format_flags: SDL_GPUShaderFormat, debug_mode: SDL_bool, name: [*c]const u8) ?*SDL_GPUDevice;
pub extern fn SDL_CreateGPUDevice(format_flags: ShaderFormat, debug_mode: bool, name: [*c]const u8) ?*Device;
pub const createDevice = SDL_CreateGPUDevice;
//pub extern fn SDL_CreateGPUDeviceWithProperties(props: SDL_PropertiesID) ?*SDL_GPUDevice;
pub extern fn SDL_CreateGPUDeviceWithProperties(props: PropertiesID) ?*Device;
pub const createDeviceWithProperties = SDL_CreateGPUDeviceWithProperties;
//pub extern fn SDL_DestroyGPUDevice(device: ?*SDL_GPUDevice) void;
pub extern fn SDL_DestroyGPUDevice(device: ?*Device) void;
pub const destroyDevice = SDL_DestroyGPUDevice;
//pub extern fn SDL_GetNumGPUDrivers() c_int;
pub extern fn SDL_GetNumGPUDrivers() c_int;
pub const getNumDrivers = SDL_GetNumGPUDrivers;
//pub extern fn SDL_GetGPUDriver(index: c_int) [*c]const u8;
pub extern fn SDL_GetGPUDriver(index: c_int) [*c]const u8;
pub const getDriver = SDL_GetGPUDriver;
//pub extern fn SDL_GetGPUDeviceDriver(device: ?*SDL_GPUDevice) [*c]const u8;
pub extern fn SDL_GetGPUDeviceDriver(device: ?*Device) [*c]const u8;
pub const getDeviceDriver = SDL_GetGPUDeviceDriver;
//pub extern fn SDL_GetGPUShaderFormats(device: ?*SDL_GPUDevice) SDL_GPUShaderFormat;
pub extern fn SDL_GetGPUShaderFormats(device: ?*Device) ShaderFormat;
pub const getShaderFormats = SDL_GetGPUShaderFormats;
//pub extern fn SDL_CreateGPUComputePipeline(device: ?*SDL_GPUDevice, createinfo: [*c]const SDL_GPUComputePipelineCreateInfo) ?*SDL_GPUComputePipeline;
pub extern fn SDL_CreateGPUComputePipeline(device: ?*Device, createinfo: [*c]const ComputePipelineCreateInfo) ?*ComputePipeline;
pub const createComputePipeline = SDL_CreateGPUComputePipeline;
//pub extern fn SDL_CreateGPUGraphicsPipeline(device: ?*SDL_GPUDevice, createinfo: [*c]const SDL_GPUGraphicsPipelineCreateInfo) ?*SDL_GPUGraphicsPipeline;
pub extern fn SDL_CreateGPUGraphicsPipeline(device: ?*Device, createinfo: [*c]const GraphicsPipelineCreateInfo) ?*GraphicsPipeline;
pub const createGraphicsPipeline = SDL_CreateGPUGraphicsPipeline;
//pub extern fn SDL_CreateGPUSampler(device: ?*SDL_GPUDevice, createinfo: [*c]const SDL_GPUSamplerCreateInfo) ?*SDL_GPUSampler;
pub extern fn SDL_CreateGPUSampler(device: ?*Device, createinfo: [*c]const SamplerCreateInfo) ?*Sampler;
pub const createSampler = SDL_CreateGPUSampler;
//pub extern fn SDL_CreateGPUShader(device: ?*SDL_GPUDevice, createinfo: [*c]const SDL_GPUShaderCreateInfo) ?*SDL_GPUShader;
pub extern fn SDL_CreateGPUShader(device: ?*Device, createinfo: [*c]const ShaderCreateInfo) ?*Shader;
pub const createShader = SDL_CreateGPUShader;
//pub extern fn SDL_CreateGPUTexture(device: ?*SDL_GPUDevice, createinfo: [*c]const SDL_GPUTextureCreateInfo) ?*SDL_GPUTexture;
pub extern fn SDL_CreateGPUTexture(device: ?*Device, createinfo: [*c]const TextureCreateInfo) ?*Texture;
pub const createTexture = SDL_CreateGPUTexture;
//pub extern fn SDL_CreateGPUBuffer(device: ?*SDL_GPUDevice, createinfo: [*c]const SDL_GPUBufferCreateInfo) ?*SDL_GPUBuffer;
pub extern fn SDL_CreateGPUBuffer(device: ?*Device, createinfo: [*c]const BufferCreateInfo) ?*Buffer;
pub const createBuffer = SDL_CreateGPUBuffer;
//pub extern fn SDL_CreateGPUTransferBuffer(device: ?*SDL_GPUDevice, createinfo: [*c]const SDL_GPUTransferBufferCreateInfo) ?*SDL_GPUTransferBuffer;
pub extern fn SDL_CreateGPUTransferBuffer(device: ?*Device, createinfo: [*c]const TransferBufferCreateInfo) ?*TransferBuffer;
pub const createTransferBuffer = SDL_CreateGPUTransferBuffer;
//pub extern fn SDL_SetGPUBufferName(device: ?*SDL_GPUDevice, buffer: ?*SDL_GPUBuffer, text: [*c]const u8) void;
pub extern fn SDL_SetGPUBufferName(device: ?*Device, buffer: ?*Buffer, text: [*c]const u8) void;
pub const setBufferName = SDL_SetGPUBufferName;
//pub extern fn SDL_SetGPUTextureName(device: ?*SDL_GPUDevice, texture: ?*SDL_GPUTexture, text: [*c]const u8) void;
pub extern fn SDL_SetGPUTextureName(device: ?*Device, texture: ?*Texture, text: [*c]const u8) void;
pub const setTextureName = SDL_SetGPUTextureName;
//pub extern fn SDL_InsertGPUDebugLabel(command_buffer: ?*SDL_GPUCommandBuffer, text: [*c]const u8) void;
pub extern fn SDL_InsertGPUDebugLabel(command_buffer: ?*CommandBuffer, text: [*c]const u8) void;
pub const insertDebugLabel = SDL_InsertGPUDebugLabel;
//pub extern fn SDL_PushGPUDebugGroup(command_buffer: ?*SDL_GPUCommandBuffer, name: [*c]const u8) void;
pub extern fn SDL_PushGPUDebugGroup(command_buffer: ?*CommandBuffer, name: [*c]const u8) void;
pub const pushDebugGroup = SDL_PushGPUDebugGroup;
//pub extern fn SDL_PopGPUDebugGroup(command_buffer: ?*SDL_GPUCommandBuffer) void;
pub extern fn SDL_PopGPUDebugGroup(command_buffer: ?*CommandBuffer) void;
pub const popDebugGroup = SDL_PopGPUDebugGroup;
//pub extern fn SDL_ReleaseGPUTexture(device: ?*SDL_GPUDevice, texture: ?*SDL_GPUTexture) void;
pub extern fn SDL_ReleaseGPUTexture(device: ?*Device, texture: ?*Texture) void;
pub const releaseTexture = SDL_ReleaseGPUTexture;
//pub extern fn SDL_ReleaseGPUSampler(device: ?*SDL_GPUDevice, sampler: ?*SDL_GPUSampler) void;
pub extern fn SDL_ReleaseGPUSampler(device: ?*Device, sampler: ?*Sampler) void;
pub const releaseSampler = SDL_ReleaseGPUSampler;
//pub extern fn SDL_ReleaseGPUBuffer(device: ?*SDL_GPUDevice, buffer: ?*SDL_GPUBuffer) void;
pub extern fn SDL_ReleaseGPUBuffer(device: ?*Device, buffer: ?*Buffer) void;
pub const releaseBuffer = SDL_ReleaseGPUBuffer;
//pub extern fn SDL_ReleaseGPUTransferBuffer(device: ?*SDL_GPUDevice, transfer_buffer: ?*SDL_GPUTransferBuffer) void;
pub extern fn SDL_ReleaseGPUTransferBuffer(device: ?*Device, transfer_buffer: ?*TransferBuffer) void;
pub const releaseTransferBuffer = SDL_ReleaseGPUTransferBuffer;
//pub extern fn SDL_ReleaseGPUComputePipeline(device: ?*SDL_GPUDevice, compute_pipeline: ?*SDL_GPUComputePipeline) void;
pub extern fn SDL_ReleaseGPUComputePipeline(device: ?*Device, compute_pipeline: ?*ComputePipeline) void;
pub const releaseComputePipeline = SDL_ReleaseGPUComputePipeline;
//pub extern fn SDL_ReleaseGPUShader(device: ?*SDL_GPUDevice, shader: ?*SDL_GPUShader) void;
pub extern fn SDL_ReleaseGPUShader(device: ?*Device, shader: ?*Shader) void;
pub const releaseShader = SDL_ReleaseGPUShader;
//pub extern fn SDL_ReleaseGPUGraphicsPipeline(device: ?*SDL_GPUDevice, graphics_pipeline: ?*SDL_GPUGraphicsPipeline) void;
pub extern fn SDL_ReleaseGPUGraphicsPipeline(device: ?*Device, graphics_pipeline: ?*GraphicsPipeline) void;
pub const releaseGraphicsPipeline = SDL_ReleaseGPUGraphicsPipeline;
//pub extern fn SDL_AcquireGPUCommandBuffer(device: ?*SDL_GPUDevice) ?*SDL_GPUCommandBuffer;
pub extern fn SDL_AcquireGPUCommandBuffer(device: ?*Device) ?*CommandBuffer;
pub const acquireCommandBuffer = SDL_AcquireGPUCommandBuffer;
//pub extern fn SDL_PushGPUVertexUniformData(command_buffer: ?*SDL_GPUCommandBuffer, slot_index: Uint32, data: ?*const anyopaque, length: Uint32) void;
pub extern fn SDL_PushGPUVertexUniformData(command_buffer: ?*CommandBuffer, slot_index: u32, data: ?*const anyopaque, length: u32) void;
pub const pushVertexUniformData = SDL_PushGPUVertexUniformData;
//pub extern fn SDL_PushGPUFragmentUniformData(command_buffer: ?*SDL_GPUCommandBuffer, slot_index: Uint32, data: ?*const anyopaque, length: Uint32) void;
pub extern fn SDL_PushGPUFragmentUniformData(command_buffer: ?*CommandBuffer, slot_index: u32, data: ?*const anyopaque, length: u32) void;
pub const pushFragmentUniformData = SDL_PushGPUFragmentUniformData;
//pub extern fn SDL_PushGPUComputeUniformData(command_buffer: ?*SDL_GPUCommandBuffer, slot_index: Uint32, data: ?*const anyopaque, length: Uint32) void;
pub extern fn SDL_PushGPUComputeUniformData(command_buffer: ?*CommandBuffer, slot_index: u32, data: ?*const anyopaque, length: u32) void;
pub const pushComputeUniformData = SDL_PushGPUComputeUniformData;
//pub extern fn SDL_BeginGPURenderPass(command_buffer: ?*SDL_GPUCommandBuffer, color_target_infos: [*c]const SDL_GPUColorTargetInfo, num_color_targets: Uint32, depth_stencil_target_info: [*c]const SDL_GPUDepthStencilTargetInfo) ?*SDL_GPURenderPass;
pub extern fn SDL_BeginGPURenderPass(command_buffer: ?*CommandBuffer, color_target_infos: [*c]const ColorTargetInfo, num_color_targets: u32, depth_stencil_target_info: [*c]const DepthStencilTargetInfo) ?*RenderPass;
pub const beginRenderPass = SDL_BeginGPURenderPass;
//pub extern fn SDL_BindGPUGraphicsPipeline(render_pass: ?*SDL_GPURenderPass, graphics_pipeline: ?*SDL_GPUGraphicsPipeline) void;
pub extern fn SDL_BindGPUGraphicsPipeline(render_pass: ?*RenderPass, graphics_pipeline: ?*GraphicsPipeline) void;
pub const bindGraphicsPipeline = SDL_BindGPUGraphicsPipeline;
//pub extern fn SDL_SetGPUViewport(render_pass: ?*SDL_GPURenderPass, viewport: [*c]const SDL_GPUViewport) void;
pub extern fn SDL_SetGPUViewport(render_pass: ?*RenderPass, viewport: [*c]const Viewport) void;
pub const setViewport = SDL_SetGPUViewport;
//pub extern fn SDL_SetGPUScissor(render_pass: ?*SDL_GPURenderPass, scissor: [*c]const SDL_Rect) void;
pub extern fn SDL_SetGPUScissor(render_pass: ?*RenderPass, scissor: [*c]const Rect) void;
pub const setScissor = SDL_SetGPUScissor;
//pub extern fn SDL_SetGPUBlendConstants(render_pass: ?*SDL_GPURenderPass, blend_constants: SDL_FColor) void;
pub extern fn SDL_SetGPUBlendConstants(render_pass: ?*RenderPass, blend_constants: FColor) void;
pub const setBlendConstants = SDL_SetGPUBlendConstants;
//pub extern fn SDL_SetGPUStencilReference(render_pass: ?*SDL_GPURenderPass, reference: Uint8) void;
pub extern fn SDL_SetGPUStencilReference(render_pass: ?*RenderPass, reference: u8) void;
pub const setStencilReference = SDL_SetGPUStencilReference;
//pub extern fn SDL_BindGPUVertexBuffers(render_pass: ?*SDL_GPURenderPass, first_slot: Uint32, bindings: [*c]const SDL_GPUBufferBinding, num_bindings: Uint32) void;
pub extern fn SDL_BindGPUVertexBuffers(render_pass: ?*RenderPass, first_slot: u32, bindings: [*c]const BufferBinding, num_bindings: u32) void;
pub const bindVertexBuffers = SDL_BindGPUVertexBuffers;
//pub extern fn SDL_BindGPUIndexBuffer(render_pass: ?*SDL_GPURenderPass, binding: [*c]const SDL_GPUBufferBinding, index_element_size: SDL_GPUIndexElementSize) void;
pub extern fn SDL_BindGPUIndexBuffer(render_pass: ?*RenderPass, binding: [*c]const BufferBinding, index_element_size: IndexElementSize) void;
pub const bindIndexBuffer = SDL_BindGPUIndexBuffer;
//pub extern fn SDL_BindGPUVertexSamplers(render_pass: ?*SDL_GPURenderPass, first_slot: Uint32, texture_sampler_bindings: [*c]const SDL_GPUTextureSamplerBinding, num_bindings: Uint32) void;
pub extern fn SDL_BindGPUVertexSamplers(render_pass: ?*RenderPass, first_slot: u32, texture_sampler_bindings: [*c]const TextureSamplerBinding, num_bindings: u32) void;
pub const bindVertexSamplers = SDL_BindGPUVertexSamplers;
//pub extern fn SDL_BindGPUVertexStorageTextures(render_pass: ?*SDL_GPURenderPass, first_slot: Uint32, storage_textures: [*c]const ?*SDL_GPUTexture, num_bindings: Uint32) void;
pub extern fn SDL_BindGPUVertexStorageTextures(render_pass: ?*RenderPass, first_slot: u32, storage_textures: [*c]const ?*Texture, num_bindings: u32) void;
pub const bindVertexStorageTextures = SDL_BindGPUVertexStorageTextures;
//pub extern fn SDL_BindGPUVertexStorageBuffers(render_pass: ?*SDL_GPURenderPass, first_slot: Uint32, storage_buffers: [*c]const ?*SDL_GPUBuffer, num_bindings: Uint32) void;
pub extern fn SDL_BindGPUVertexStorageBuffers(render_pass: ?*RenderPass, first_slot: u32, storage_buffers: [*c]const ?*Buffer, num_bindings: u32) void;
pub const bindVertexStorageBuffers = SDL_BindGPUVertexStorageBuffers;
//pub extern fn SDL_BindGPUFragmentSamplers(render_pass: ?*SDL_GPURenderPass, first_slot: Uint32, texture_sampler_bindings: [*c]const SDL_GPUTextureSamplerBinding, num_bindings: Uint32) void;
pub extern fn SDL_BindGPUFragmentSamplers(render_pass: ?*RenderPass, first_slot: u32, texture_sampler_bindings: [*c]const TextureSamplerBinding, num_bindings: u32) void;
pub const bindFragmentSamplers = SDL_BindGPUFragmentSamplers;
//pub extern fn SDL_BindGPUFragmentStorageTextures(render_pass: ?*SDL_GPURenderPass, first_slot: Uint32, storage_textures: [*c]const ?*SDL_GPUTexture, num_bindings: Uint32) void;
pub extern fn SDL_BindGPUFragmentStorageTextures(render_pass: ?*RenderPass, first_slot: u32, storage_textures: [*c]const ?*Texture, num_bindings: u32) void;
pub const bindFragmentStorageTextures = SDL_BindGPUFragmentStorageTextures;
//pub extern fn SDL_BindGPUFragmentStorageBuffers(render_pass: ?*SDL_GPURenderPass, first_slot: Uint32, storage_buffers: [*c]const ?*SDL_GPUBuffer, num_bindings: Uint32) void;
pub extern fn SDL_BindGPUFragmentStorageBuffers(render_pass: ?*RenderPass, first_slot: u32, storage_buffers: [*c]const ?*Buffer, num_bindings: u32) void;
pub const bindFragmentStorageBuffers = SDL_BindGPUFragmentStorageBuffers;
//pub extern fn SDL_DrawGPUIndexedPrimitives(render_pass: ?*SDL_GPURenderPass, num_indices: Uint32, num_instances: Uint32, first_index: Uint32, vertex_offset: Sint32, first_instance: Uint32) void;
pub extern fn SDL_DrawGPUIndexedPrimitives(render_pass: ?*RenderPass, num_indices: u32, num_instances: u32, first_index: u32, vertex_offset: i32, first_instance: u32) void;
pub const drawIndexedPrimitives = SDL_DrawGPUIndexedPrimitives;
//pub extern fn SDL_DrawGPUPrimitives(render_pass: ?*SDL_GPURenderPass, num_vertices: Uint32, num_instances: Uint32, first_vertex: Uint32, first_instance: Uint32) void;
pub extern fn SDL_DrawGPUPrimitives(render_pass: ?*RenderPass, num_vertices: u32, num_instances: u32, first_vertex: u32, first_instance: u32) void;
pub const drawPrimitives = SDL_DrawGPUPrimitives;
//pub extern fn SDL_DrawGPUPrimitivesIndirect(render_pass: ?*SDL_GPURenderPass, buffer: ?*SDL_GPUBuffer, offset: Uint32, draw_count: Uint32) void;
pub extern fn SDL_DrawGPUPrimitivesIndirect(render_pass: ?*RenderPass, buffer: ?*Buffer, offset: u32, draw_count: u32) void;
pub const drawPrimitivesIndirect = SDL_DrawGPUPrimitivesIndirect;
//pub extern fn SDL_DrawGPUIndexedPrimitivesIndirect(render_pass: ?*SDL_GPURenderPass, buffer: ?*SDL_GPUBuffer, offset: Uint32, draw_count: Uint32) void;
pub extern fn SDL_DrawGPUIndexedPrimitivesIndirect(render_pass: ?*RenderPass, buffer: ?*Buffer, offset: u32, draw_count: u32) void;
pub const drawIndexedPrimitivesIndirect = SDL_DrawGPUIndexedPrimitivesIndirect;
//pub extern fn SDL_EndGPURenderPass(render_pass: ?*SDL_GPURenderPass) void;
pub extern fn SDL_EndGPURenderPass(render_pass: ?*RenderPass) void;
pub const endRenderPass = SDL_EndGPURenderPass;
//pub extern fn SDL_BeginGPUComputePass(command_buffer: ?*SDL_GPUCommandBuffer, storage_texture_bindings: [*c]const SDL_GPUStorageTextureWriteOnlyBinding, num_storage_texture_bindings: Uint32, storage_buffer_bindings: [*c]const SDL_GPUStorageBufferWriteOnlyBinding, num_storage_buffer_bindings: Uint32) ?*SDL_GPUComputePass;
pub extern fn SDL_BeginGPUComputePass(command_buffer: ?*CommandBuffer, storage_texture_bindings: [*c]const StorageTextureWriteOnlyBinding, num_storage_texture_bindings: u32, storage_buffer_bindings: [*c]const StorageBufferWriteOnlyBinding, num_storage_buffer_bindings: u32) ?*ComputePass;
pub const beginComputePass = SDL_BeginGPUComputePass;
//pub extern fn SDL_BindGPUComputePipeline(compute_pass: ?*SDL_GPUComputePass, compute_pipeline: ?*SDL_GPUComputePipeline) void;
pub extern fn SDL_BindGPUComputePipeline(compute_pass: ?*ComputePass, compute_pipeline: ?*ComputePipeline) void;
pub const bindComputePipeline = SDL_BindGPUComputePipeline;
//pub extern fn SDL_BindGPUComputeSamplers(compute_pass: ?*SDL_GPUComputePass, first_slot: Uint32, texture_sampler_bindings: [*c]const SDL_GPUTextureSamplerBinding, num_bindings: Uint32) void;
pub extern fn SDL_BindGPUComputeSamplers(compute_pass: ?*ComputePass, first_slot: u32, texture_sampler_bindings: [*c]const TextureSamplerBinding, num_bindings: u32) void;
pub const bindComputeSamplers = SDL_BindGPUComputeSamplers;
//pub extern fn SDL_BindGPUComputeStorageTextures(compute_pass: ?*SDL_GPUComputePass, first_slot: Uint32, storage_textures: [*c]const ?*SDL_GPUTexture, num_bindings: Uint32) void;
pub extern fn SDL_BindGPUComputeStorageTextures(compute_pass: ?*ComputePass, first_slot: u32, storage_textures: [*c]const ?*Texture, num_bindings: u32) void;
pub const bindComputeStorageTextures = SDL_BindGPUComputeStorageTextures;
//pub extern fn SDL_BindGPUComputeStorageBuffers(compute_pass: ?*SDL_GPUComputePass, first_slot: Uint32, storage_buffers: [*c]const ?*SDL_GPUBuffer, num_bindings: Uint32) void;
pub extern fn SDL_BindGPUComputeStorageBuffers(compute_pass: ?*ComputePass, first_slot: u32, storage_buffers: [*c]const ?*Buffer, num_bindings: u32) void;
pub const bindComputeStorageBuffers = SDL_BindGPUComputeStorageBuffers;
//pub extern fn SDL_DispatchGPUCompute(compute_pass: ?*SDL_GPUComputePass, groupcount_x: Uint32, groupcount_y: Uint32, groupcount_z: Uint32) void;
pub extern fn SDL_DispatchGPUCompute(compute_pass: ?*ComputePass, groupcount_x: u32, groupcount_y: u32, groupcount_z: u32) void;
pub const dispatchCompute = SDL_DispatchGPUCompute;
//pub extern fn SDL_DispatchGPUComputeIndirect(compute_pass: ?*SDL_GPUComputePass, buffer: ?*SDL_GPUBuffer, offset: Uint32) void;
pub extern fn SDL_DispatchGPUComputeIndirect(compute_pass: ?*ComputePass, buffer: ?*Buffer, offset: u32) void;
pub const dispatchComputeIndirect = SDL_DispatchGPUComputeIndirect;
//pub extern fn SDL_EndGPUComputePass(compute_pass: ?*SDL_GPUComputePass) void;
pub extern fn SDL_EndGPUComputePass(compute_pass: ?*ComputePass) void;
pub const endComputePass = SDL_EndGPUComputePass;
//pub extern fn SDL_MapGPUTransferBuffer(device: ?*SDL_GPUDevice, transfer_buffer: ?*SDL_GPUTransferBuffer, cycle: SDL_bool) ?*anyopaque;
pub extern fn SDL_MapGPUTransferBuffer(device: ?*Device, transfer_buffer: ?*TransferBuffer, cycle: bool) ?*anyopaque;
pub const mapTransferBuffer = SDL_MapGPUTransferBuffer;
//pub extern fn SDL_UnmapGPUTransferBuffer(device: ?*SDL_GPUDevice, transfer_buffer: ?*SDL_GPUTransferBuffer) void;
pub extern fn SDL_UnmapGPUTransferBuffer(device: ?*Device, transfer_buffer: ?*TransferBuffer) void;
pub const unmapTransferBuffer = SDL_UnmapGPUTransferBuffer;
//pub extern fn SDL_BeginGPUCopyPass(command_buffer: ?*SDL_GPUCommandBuffer) ?*SDL_GPUCopyPass;
pub extern fn SDL_BeginGPUCopyPass(command_buffer: ?*CommandBuffer) ?*CopyPass;
pub const beginCopyPass = SDL_BeginGPUCopyPass;
//pub extern fn SDL_UploadToGPUTexture(copy_pass: ?*SDL_GPUCopyPass, source: [*c]const SDL_GPUTextureTransferInfo, destination: [*c]const SDL_GPUTextureRegion, cycle: SDL_bool) void;
pub extern fn SDL_UploadToGPUTexture(copy_pass: ?*CopyPass, source: [*c]const TextureTransferInfo, destination: [*c]const TextureRegion, cycle: bool) void;
pub const uploadToTexture = SDL_UploadToGPUTexture;
//pub extern fn SDL_UploadToGPUBuffer(copy_pass: ?*SDL_GPUCopyPass, source: [*c]const SDL_GPUTransferBufferLocation, destination: [*c]const SDL_GPUBufferRegion, cycle: SDL_bool) void;
pub extern fn SDL_UploadToGPUBuffer(copy_pass: ?*CopyPass, source: [*c]const TransferBufferLocation, destination: [*c]const BufferRegion, cycle: bool) void;
pub const uploadToBuffer = SDL_UploadToGPUBuffer;
//pub extern fn SDL_CopyGPUTextureToTexture(copy_pass: ?*SDL_GPUCopyPass, source: [*c]const SDL_GPUTextureLocation, destination: [*c]const SDL_GPUTextureLocation, w: Uint32, h: Uint32, d: Uint32, cycle: SDL_bool) void;
pub extern fn SDL_CopyGPUTextureToTexture(copy_pass: ?*CopyPass, source: [*c]const TextureLocation, destination: [*c]const TextureLocation, w: u32, h: u32, d: u32, cycle: bool) void;
pub const copyTextureToTexture = SDL_CopyGPUTextureToTexture;
//pub extern fn SDL_CopyGPUBufferToBuffer(copy_pass: ?*SDL_GPUCopyPass, source: [*c]const SDL_GPUBufferLocation, destination: [*c]const SDL_GPUBufferLocation, size: Uint32, cycle: SDL_bool) void;
pub extern fn SDL_CopyGPUBufferToBuffer(copy_pass: ?*CopyPass, source: [*c]const BufferLocation, destination: [*c]const BufferLocation, size: u32, cycle: bool) void;
pub const copyBufferToBuffer = SDL_CopyGPUBufferToBuffer;
//pub extern fn SDL_DownloadFromGPUTexture(copy_pass: ?*SDL_GPUCopyPass, source: [*c]const SDL_GPUTextureRegion, destination: [*c]const SDL_GPUTextureTransferInfo) void;
pub extern fn SDL_DownloadFromGPUTexture(copy_pass: ?*CopyPass, source: [*c]const TextureRegion, destination: [*c]const TextureTransferInfo) void;
pub const downloadFromTexture = SDL_DownloadFromGPUTexture;
//pub extern fn SDL_DownloadFromGPUBuffer(copy_pass: ?*SDL_GPUCopyPass, source: [*c]const SDL_GPUBufferRegion, destination: [*c]const SDL_GPUTransferBufferLocation) void;
pub extern fn SDL_DownloadFromGPUBuffer(copy_pass: ?*CopyPass, source: [*c]const BufferRegion, destination: [*c]const TransferBufferLocation) void;
pub const downloadFromBuffer = SDL_DownloadFromGPUBuffer;
//pub extern fn SDL_EndGPUCopyPass(copy_pass: ?*SDL_GPUCopyPass) void;
pub extern fn SDL_EndGPUCopyPass(copy_pass: ?*CopyPass) void;
pub const endCopyPass = SDL_EndGPUCopyPass;
//pub extern fn SDL_GenerateMipmapsForGPUTexture(command_buffer: ?*SDL_GPUCommandBuffer, texture: ?*SDL_GPUTexture) void;
pub extern fn SDL_GenerateMipmapsForGPUTexture(command_buffer: ?*CommandBuffer, texture: ?*Texture) void;
pub const generateMipmapsForTexture = SDL_GenerateMipmapsForGPUTexture;
//pub extern fn SDL_BlitGPUTexture(command_buffer: ?*SDL_GPUCommandBuffer, info: [*c]const SDL_GPUBlitInfo) void;
pub extern fn SDL_BlitGPUTexture(command_buffer: ?*CommandBuffer, info: [*c]const BlitInfo) void;
pub const blitTexture = SDL_BlitGPUTexture;
//pub extern fn SDL_WindowSupportsGPUSwapchainComposition(device: ?*SDL_GPUDevice, window: ?*SDL_Window, swapchain_composition: SDL_GPUSwapchainComposition) SDL_bool;
pub extern fn SDL_WindowSupportsGPUSwapchainComposition(device: ?*Device, window: ?*Window, swapchain_composition: SwapchainComposition) bool;
pub const windowSupportsSwapchainComposition = SDL_WindowSupportsGPUSwapchainComposition;
//pub extern fn SDL_WindowSupportsGPUPresentMode(device: ?*SDL_GPUDevice, window: ?*SDL_Window, present_mode: SDL_GPUPresentMode) SDL_bool;
pub extern fn SDL_WindowSupportsGPUPresentMode(device: ?*Device, window: ?*Window, present_mode: PresentMode) bool;
pub const windowSupportsPresentMode = SDL_WindowSupportsGPUPresentMode;
//pub extern fn SDL_ClaimWindowForGPUDevice(device: ?*SDL_GPUDevice, window: ?*SDL_Window) SDL_bool;
pub extern fn SDL_ClaimWindowForGPUDevice(device: ?*Device, window: ?*Window) bool;
pub const claimWindowForDevice = SDL_ClaimWindowForGPUDevice;
//pub extern fn SDL_ReleaseWindowFromGPUDevice(device: ?*SDL_GPUDevice, window: ?*SDL_Window) void;
pub extern fn SDL_ReleaseWindowFromGPUDevice(device: ?*Device, window: ?*Window) void;
pub const releaseWindowFromDevice = SDL_ReleaseWindowFromGPUDevice;
//pub extern fn SDL_SetGPUSwapchainParameters(device: ?*SDL_GPUDevice, window: ?*SDL_Window, swapchain_composition: SDL_GPUSwapchainComposition, present_mode: SDL_GPUPresentMode) SDL_bool;
pub extern fn SDL_SetGPUSwapchainParameters(device: ?*Device, window: ?*Window, swapchain_composition: SwapchainComposition, present_mode: PresentMode) bool;
pub const setSwapchainParameters = SDL_SetGPUSwapchainParameters;
//pub extern fn SDL_GetGPUSwapchainTextureFormat(device: ?*SDL_GPUDevice, window: ?*SDL_Window) SDL_GPUTextureFormat;
pub extern fn SDL_GetGPUSwapchainTextureFormat(device: ?*Device, window: ?*Window) TextureFormat;
pub const getSwapchainTextureFormat = SDL_GetGPUSwapchainTextureFormat;
//pub extern fn SDL_AcquireGPUSwapchainTexture(command_buffer: ?*SDL_GPUCommandBuffer, window: ?*SDL_Window, w: [*c]Uint32, h: [*c]Uint32) ?*SDL_GPUTexture;
pub extern fn SDL_AcquireGPUSwapchainTexture(command_buffer: ?*CommandBuffer, window: ?*Window, w: [*c]u32, h: [*c]u32) ?*Texture;
pub const acquireSwapchainTexture = SDL_AcquireGPUSwapchainTexture;
//pub extern fn SDL_SubmitGPUCommandBuffer(command_buffer: ?*SDL_GPUCommandBuffer) void;
pub extern fn SDL_SubmitGPUCommandBuffer(command_buffer: ?*CommandBuffer) void;
pub const submitCommandBuffer = SDL_SubmitGPUCommandBuffer;
//pub extern fn SDL_SubmitGPUCommandBufferAndAcquireFence(command_buffer: ?*SDL_GPUCommandBuffer) ?*SDL_GPUFence;
pub extern fn SDL_SubmitGPUCommandBufferAndAcquireFence(command_buffer: ?*CommandBuffer) ?*Fence;
pub const submitCommandBufferAndAcquireFence = SDL_SubmitGPUCommandBufferAndAcquireFence;
//pub extern fn SDL_WaitForGPUIdle(device: ?*SDL_GPUDevice) void;
pub extern fn SDL_WaitForGPUIdle(device: ?*Device) void;
pub const waitForIdle = SDL_WaitForGPUIdle;
//pub extern fn SDL_WaitForGPUFences(device: ?*SDL_GPUDevice, wait_all: SDL_bool, fences: [*c]const ?*SDL_GPUFence, num_fences: Uint32) void;
pub extern fn SDL_WaitForGPUFences(device: ?*Device, wait_all: bool, fences: [*c]const ?*Fence, num_fences: u32) void;
pub const waitForFences = SDL_WaitForGPUFences;
//pub extern fn SDL_QueryGPUFence(device: ?*SDL_GPUDevice, fence: ?*SDL_GPUFence) SDL_bool;
pub extern fn SDL_QueryGPUFence(device: ?*Device, fence: ?*Fence) bool;
pub const queryFence = SDL_QueryGPUFence;
//pub extern fn SDL_ReleaseGPUFence(device: ?*SDL_GPUDevice, fence: ?*SDL_GPUFence) void;
pub extern fn SDL_ReleaseGPUFence(device: ?*Device, fence: ?*Fence) void;
pub const releaseFence = SDL_ReleaseGPUFence;
//pub extern fn SDL_GPUTextureFormatTexelBlockSize(format: SDL_GPUTextureFormat) Uint32;
pub extern fn SDL_GPUTextureFormatTexelBlockSize(format: TextureFormat) u32;
pub const textureFormatTexelBlockSize = SDL_GPUTextureFormatTexelBlockSize;
//pub extern fn SDL_GPUTextureSupportsFormat(device: ?*SDL_GPUDevice, format: SDL_GPUTextureFormat, @"type": SDL_GPUTextureType, usage: SDL_GPUTextureUsageFlags) SDL_bool;
pub extern fn SDL_GPUTextureSupportsFormat(device: ?*Device, format: TextureFormat, @"type": TextureType, usage: TextureUsageFlags) bool;
pub const textureSupportsFormat = SDL_GPUTextureSupportsFormat;
//pub extern fn SDL_GPUTextureSupportsSampleCount(device: ?*SDL_GPUDevice, format: SDL_GPUTextureFormat, sample_count: SDL_GPUSampleCount) SDL_bool;
pub extern fn SDL_GPUTextureSupportsSampleCount(device: ?*Device, format: TextureFormat, sample_count: SampleCount) bool;
pub const textureSupportsSampleCount = SDL_GPUTextureSupportsSampleCount;
//pub const __llvm__ = @as(c_int, 1);
//pub const __clang__ = @as(c_int, 1);
//pub const __clang_major__ = @as(c_int, 18);
//pub const __clang_minor__ = @as(c_int, 1);
//pub const __clang_patchlevel__ = @as(c_int, 6);
//pub const __clang_version__ = "18.1.6 (https://github.com/ziglang/zig-bootstrap 98bc6bf4fc4009888d33941daf6b600d20a42a56)";
//pub const __GNUC__ = @as(c_int, 4);
//pub const __GNUC_MINOR__ = @as(c_int, 2);
//pub const __GNUC_PATCHLEVEL__ = @as(c_int, 1);
//pub const __GXX_ABI_VERSION = @as(c_int, 1002);
//pub const __ATOMIC_RELAXED = @as(c_int, 0);
//pub const __ATOMIC_CONSUME = @as(c_int, 1);
//pub const __ATOMIC_ACQUIRE = @as(c_int, 2);
//pub const __ATOMIC_RELEASE = @as(c_int, 3);
//pub const __ATOMIC_ACQ_REL = @as(c_int, 4);
//pub const __ATOMIC_SEQ_CST = @as(c_int, 5);
//pub const __MEMORY_SCOPE_SYSTEM = @as(c_int, 0);
//pub const __MEMORY_SCOPE_DEVICE = @as(c_int, 1);
//pub const __MEMORY_SCOPE_WRKGRP = @as(c_int, 2);
//pub const __MEMORY_SCOPE_WVFRNT = @as(c_int, 3);
//pub const __MEMORY_SCOPE_SINGLE = @as(c_int, 4);
//pub const __OPENCL_MEMORY_SCOPE_WORK_ITEM = @as(c_int, 0);
//pub const __OPENCL_MEMORY_SCOPE_WORK_GROUP = @as(c_int, 1);
//pub const __OPENCL_MEMORY_SCOPE_DEVICE = @as(c_int, 2);
//pub const __OPENCL_MEMORY_SCOPE_ALL_SVM_DEVICES = @as(c_int, 3);
//pub const __OPENCL_MEMORY_SCOPE_SUB_GROUP = @as(c_int, 4);
//pub const __FPCLASS_SNAN = @as(c_int, 0x0001);
//pub const __FPCLASS_QNAN = @as(c_int, 0x0002);
//pub const __FPCLASS_NEGINF = @as(c_int, 0x0004);
//pub const __FPCLASS_NEGNORMAL = @as(c_int, 0x0008);
//pub const __FPCLASS_NEGSUBNORMAL = @as(c_int, 0x0010);
//pub const __FPCLASS_NEGZERO = @as(c_int, 0x0020);
//pub const __FPCLASS_POSZERO = @as(c_int, 0x0040);
//pub const __FPCLASS_POSSUBNORMAL = @as(c_int, 0x0080);
//pub const __FPCLASS_POSNORMAL = @as(c_int, 0x0100);
//pub const __FPCLASS_POSINF = @as(c_int, 0x0200);
//pub const __PRAGMA_REDEFINE_EXTNAME = @as(c_int, 1);
//pub const __VERSION__ = "Clang 18.1.6 (https://github.com/ziglang/zig-bootstrap 98bc6bf4fc4009888d33941daf6b600d20a42a56)";
//pub const __OBJC_BOOL_IS_BOOL = @as(c_int, 0);
//pub const __CONSTANT_CFSTRINGS__ = @as(c_int, 1);
//pub const __SEH__ = @as(c_int, 1);
//pub const __clang_literal_encoding__ = "UTF-8";
//pub const __clang_wide_literal_encoding__ = "UTF-16";
//pub const __ORDER_LITTLE_ENDIAN__ = @as(c_int, 1234);
//pub const __ORDER_BIG_ENDIAN__ = @as(c_int, 4321);
//pub const __ORDER_PDP_ENDIAN__ = @as(c_int, 3412);
//pub const __BYTE_ORDER__ = __ORDER_LITTLE_ENDIAN__;
//pub const __LITTLE_ENDIAN__ = @as(c_int, 1);
//pub const __CHAR_BIT__ = @as(c_int, 8);
//pub const __BOOL_WIDTH__ = @as(c_int, 8);
//pub const __SHRT_WIDTH__ = @as(c_int, 16);
//pub const __INT_WIDTH__ = @as(c_int, 32);
//pub const __LONG_WIDTH__ = @as(c_int, 32);
//pub const __LLONG_WIDTH__ = @as(c_int, 64);
//pub const __BITINT_MAXWIDTH__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 8388608, .decimal);
//pub const __SCHAR_MAX__ = @as(c_int, 127);
//pub const __SHRT_MAX__ = @as(c_int, 32767);
//pub const __INT_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
//pub const __LONG_MAX__ = @as(c_long, 2147483647);
//pub const __LONG_LONG_MAX__ = @as(c_longlong, 9223372036854775807);
//pub const __WCHAR_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
//pub const __WCHAR_WIDTH__ = @as(c_int, 16);
//pub const __WINT_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
//pub const __WINT_WIDTH__ = @as(c_int, 16);
//pub const __INTMAX_MAX__ = @as(c_longlong, 9223372036854775807);
//pub const __INTMAX_WIDTH__ = @as(c_int, 64);
//pub const __SIZE_MAX__ = @as(c_ulonglong, 18446744073709551615);
//pub const __SIZE_WIDTH__ = @as(c_int, 64);
//pub const __UINTMAX_MAX__ = @as(c_ulonglong, 18446744073709551615);
//pub const __UINTMAX_WIDTH__ = @as(c_int, 64);
//pub const __PTRDIFF_MAX__ = @as(c_longlong, 9223372036854775807);
//pub const __PTRDIFF_WIDTH__ = @as(c_int, 64);
//pub const __INTPTR_MAX__ = @as(c_longlong, 9223372036854775807);
//pub const __INTPTR_WIDTH__ = @as(c_int, 64);
//pub const __UINTPTR_MAX__ = @as(c_ulonglong, 18446744073709551615);
//pub const __UINTPTR_WIDTH__ = @as(c_int, 64);
//pub const __SIZEOF_DOUBLE__ = @as(c_int, 8);
//pub const __SIZEOF_FLOAT__ = @as(c_int, 4);
//pub const __SIZEOF_INT__ = @as(c_int, 4);
//pub const __SIZEOF_LONG__ = @as(c_int, 4);
//pub const __SIZEOF_LONG_DOUBLE__ = @as(c_int, 16);
//pub const __SIZEOF_LONG_LONG__ = @as(c_int, 8);
//pub const __SIZEOF_POINTER__ = @as(c_int, 8);
//pub const __SIZEOF_SHORT__ = @as(c_int, 2);
//pub const __SIZEOF_PTRDIFF_T__ = @as(c_int, 8);
//pub const __SIZEOF_SIZE_T__ = @as(c_int, 8);
//pub const __SIZEOF_WCHAR_T__ = @as(c_int, 2);
//pub const __SIZEOF_WINT_T__ = @as(c_int, 2);
//pub const __SIZEOF_INT128__ = @as(c_int, 16);
//pub const __INTMAX_TYPE__ = c_longlong;
//pub const __INTMAX_FMTd__ = "lld";
//pub const __INTMAX_FMTi__ = "lli";
//pub const __INTMAX_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `LL`");
//// (no file):94:9
//pub const __UINTMAX_TYPE__ = c_ulonglong;
//pub const __UINTMAX_FMTo__ = "llo";
//pub const __UINTMAX_FMTu__ = "llu";
//pub const __UINTMAX_FMTx__ = "llx";
//pub const __UINTMAX_FMTX__ = "llX";
//pub const __UINTMAX_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `ULL`");
//// (no file):100:9
//pub const __PTRDIFF_TYPE__ = c_longlong;
//pub const __PTRDIFF_FMTd__ = "lld";
//pub const __PTRDIFF_FMTi__ = "lli";
//pub const __INTPTR_TYPE__ = c_longlong;
//pub const __INTPTR_FMTd__ = "lld";
//pub const __INTPTR_FMTi__ = "lli";
//pub const __SIZE_TYPE__ = c_ulonglong;
//pub const __SIZE_FMTo__ = "llo";
//pub const __SIZE_FMTu__ = "llu";
//pub const __SIZE_FMTx__ = "llx";
//pub const __SIZE_FMTX__ = "llX";
//pub const __WCHAR_TYPE__ = c_ushort;
//pub const __WINT_TYPE__ = c_ushort;
//pub const __SIG_ATOMIC_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
//pub const __SIG_ATOMIC_WIDTH__ = @as(c_int, 32);
//pub const __CHAR16_TYPE__ = c_ushort;
//pub const __CHAR32_TYPE__ = c_uint;
//pub const __UINTPTR_TYPE__ = c_ulonglong;
//pub const __UINTPTR_FMTo__ = "llo";
//pub const __UINTPTR_FMTu__ = "llu";
//pub const __UINTPTR_FMTx__ = "llx";
//pub const __UINTPTR_FMTX__ = "llX";
//pub const __FLT16_DENORM_MIN__ = @as(f16, 5.9604644775390625e-8);
//pub const __FLT16_HAS_DENORM__ = @as(c_int, 1);
//pub const __FLT16_DIG__ = @as(c_int, 3);
//pub const __FLT16_DECIMAL_DIG__ = @as(c_int, 5);
//pub const __FLT16_EPSILON__ = @as(f16, 9.765625e-4);
//pub const __FLT16_HAS_INFINITY__ = @as(c_int, 1);
//pub const __FLT16_HAS_QUIET_NAN__ = @as(c_int, 1);
//pub const __FLT16_MANT_DIG__ = @as(c_int, 11);
//pub const __FLT16_MAX_10_EXP__ = @as(c_int, 4);
//pub const __FLT16_MAX_EXP__ = @as(c_int, 16);
//pub const __FLT16_MAX__ = @as(f16, 6.5504e+4);
//pub const __FLT16_MIN_10_EXP__ = -@as(c_int, 4);
//pub const __FLT16_MIN_EXP__ = -@as(c_int, 13);
//pub const __FLT16_MIN__ = @as(f16, 6.103515625e-5);
//pub const __FLT_DENORM_MIN__ = @as(f32, 1.40129846e-45);
//pub const __FLT_HAS_DENORM__ = @as(c_int, 1);
//pub const __FLT_DIG__ = @as(c_int, 6);
//pub const __FLT_DECIMAL_DIG__ = @as(c_int, 9);
//pub const __FLT_EPSILON__ = @as(f32, 1.19209290e-7);
//pub const __FLT_HAS_INFINITY__ = @as(c_int, 1);
//pub const __FLT_HAS_QUIET_NAN__ = @as(c_int, 1);
//pub const __FLT_MANT_DIG__ = @as(c_int, 24);
//pub const __FLT_MAX_10_EXP__ = @as(c_int, 38);
//pub const __FLT_MAX_EXP__ = @as(c_int, 128);
//pub const __FLT_MAX__ = @as(f32, 3.40282347e+38);
//pub const __FLT_MIN_10_EXP__ = -@as(c_int, 37);
//pub const __FLT_MIN_EXP__ = -@as(c_int, 125);
//pub const __FLT_MIN__ = @as(f32, 1.17549435e-38);
//pub const __DBL_DENORM_MIN__ = @as(f64, 4.9406564584124654e-324);
//pub const __DBL_HAS_DENORM__ = @as(c_int, 1);
//pub const __DBL_DIG__ = @as(c_int, 15);
//pub const __DBL_DECIMAL_DIG__ = @as(c_int, 17);
//pub const __DBL_EPSILON__ = @as(f64, 2.2204460492503131e-16);
//pub const __DBL_HAS_INFINITY__ = @as(c_int, 1);
//pub const __DBL_HAS_QUIET_NAN__ = @as(c_int, 1);
//pub const __DBL_MANT_DIG__ = @as(c_int, 53);
//pub const __DBL_MAX_10_EXP__ = @as(c_int, 308);
//pub const __DBL_MAX_EXP__ = @as(c_int, 1024);
//pub const __DBL_MAX__ = @as(f64, 1.7976931348623157e+308);
//pub const __DBL_MIN_10_EXP__ = -@as(c_int, 307);
//pub const __DBL_MIN_EXP__ = -@as(c_int, 1021);
//pub const __DBL_MIN__ = @as(f64, 2.2250738585072014e-308);
//pub const __LDBL_DENORM_MIN__ = @as(c_longdouble, 3.64519953188247460253e-4951);
//pub const __LDBL_HAS_DENORM__ = @as(c_int, 1);
//pub const __LDBL_DIG__ = @as(c_int, 18);
//pub const __LDBL_DECIMAL_DIG__ = @as(c_int, 21);
//pub const __LDBL_EPSILON__ = @as(c_longdouble, 1.08420217248550443401e-19);
//pub const __LDBL_HAS_INFINITY__ = @as(c_int, 1);
//pub const __LDBL_HAS_QUIET_NAN__ = @as(c_int, 1);
//pub const __LDBL_MANT_DIG__ = @as(c_int, 64);
//pub const __LDBL_MAX_10_EXP__ = @as(c_int, 4932);
//pub const __LDBL_MAX_EXP__ = @as(c_int, 16384);
//pub const __LDBL_MAX__ = @as(c_longdouble, 1.18973149535723176502e+4932);
//pub const __LDBL_MIN_10_EXP__ = -@as(c_int, 4931);
//pub const __LDBL_MIN_EXP__ = -@as(c_int, 16381);
//pub const __LDBL_MIN__ = @as(c_longdouble, 3.36210314311209350626e-4932);
//pub const __POINTER_WIDTH__ = @as(c_int, 64);
//pub const __BIGGEST_ALIGNMENT__ = @as(c_int, 16);
//pub const __WCHAR_UNSIGNED__ = @as(c_int, 1);
//pub const __WINT_UNSIGNED__ = @as(c_int, 1);
//pub const __INT8_TYPE__ = i8;
//pub const __INT8_FMTd__ = "hhd";
//pub const __INT8_FMTi__ = "hhi";
//pub const __INT8_C_SUFFIX__ = "";
//pub const __INT16_TYPE__ = c_short;
//pub const __INT16_FMTd__ = "hd";
//pub const __INT16_FMTi__ = "hi";
//pub const __INT16_C_SUFFIX__ = "";
//pub const __INT32_TYPE__ = c_int;
//pub const __INT32_FMTd__ = "d";
//pub const __INT32_FMTi__ = "i";
//pub const __INT32_C_SUFFIX__ = "";
//pub const __INT64_TYPE__ = c_longlong;
//pub const __INT64_FMTd__ = "lld";
//pub const __INT64_FMTi__ = "lli";
//pub const __INT64_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `LL`");
//// (no file):198:9
//pub const __UINT8_TYPE__ = u8;
//pub const __UINT8_FMTo__ = "hho";
//pub const __UINT8_FMTu__ = "hhu";
//pub const __UINT8_FMTx__ = "hhx";
//pub const __UINT8_FMTX__ = "hhX";
//pub const __UINT8_C_SUFFIX__ = "";
//pub const __UINT8_MAX__ = @as(c_int, 255);
//pub const __INT8_MAX__ = @as(c_int, 127);
//pub const __UINT16_TYPE__ = c_ushort;
//pub const __UINT16_FMTo__ = "ho";
//pub const __UINT16_FMTu__ = "hu";
//pub const __UINT16_FMTx__ = "hx";
//pub const __UINT16_FMTX__ = "hX";
//pub const __UINT16_C_SUFFIX__ = "";
//pub const __UINT16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
//pub const __INT16_MAX__ = @as(c_int, 32767);
//pub const __UINT32_TYPE__ = c_uint;
//pub const __UINT32_FMTo__ = "o";
//pub const __UINT32_FMTu__ = "u";
//pub const __UINT32_FMTx__ = "x";
//pub const __UINT32_FMTX__ = "X";
//pub const __UINT32_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `U`");
//// (no file):220:9
//pub const __UINT32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
//pub const __INT32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
//pub const __UINT64_TYPE__ = c_ulonglong;
//pub const __UINT64_FMTo__ = "llo";
//pub const __UINT64_FMTu__ = "llu";
//pub const __UINT64_FMTx__ = "llx";
//pub const __UINT64_FMTX__ = "llX";
//pub const __UINT64_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `ULL`");
//// (no file):228:9
//pub const __UINT64_MAX__ = @as(c_ulonglong, 18446744073709551615);
//pub const __INT64_MAX__ = @as(c_longlong, 9223372036854775807);
//pub const __INT_LEAST8_TYPE__ = i8;
//pub const __INT_LEAST8_MAX__ = @as(c_int, 127);
//pub const __INT_LEAST8_WIDTH__ = @as(c_int, 8);
//pub const __INT_LEAST8_FMTd__ = "hhd";
//pub const __INT_LEAST8_FMTi__ = "hhi";
//pub const __UINT_LEAST8_TYPE__ = u8;
//pub const __UINT_LEAST8_MAX__ = @as(c_int, 255);
//pub const __UINT_LEAST8_FMTo__ = "hho";
//pub const __UINT_LEAST8_FMTu__ = "hhu";
//pub const __UINT_LEAST8_FMTx__ = "hhx";
//pub const __UINT_LEAST8_FMTX__ = "hhX";
//pub const __INT_LEAST16_TYPE__ = c_short;
//pub const __INT_LEAST16_MAX__ = @as(c_int, 32767);
//pub const __INT_LEAST16_WIDTH__ = @as(c_int, 16);
//pub const __INT_LEAST16_FMTd__ = "hd";
//pub const __INT_LEAST16_FMTi__ = "hi";
//pub const __UINT_LEAST16_TYPE__ = c_ushort;
//pub const __UINT_LEAST16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
//pub const __UINT_LEAST16_FMTo__ = "ho";
//pub const __UINT_LEAST16_FMTu__ = "hu";
//pub const __UINT_LEAST16_FMTx__ = "hx";
//pub const __UINT_LEAST16_FMTX__ = "hX";
//pub const __INT_LEAST32_TYPE__ = c_int;
//pub const __INT_LEAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
//pub const __INT_LEAST32_WIDTH__ = @as(c_int, 32);
//pub const __INT_LEAST32_FMTd__ = "d";
//pub const __INT_LEAST32_FMTi__ = "i";
//pub const __UINT_LEAST32_TYPE__ = c_uint;
//pub const __UINT_LEAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
//pub const __UINT_LEAST32_FMTo__ = "o";
//pub const __UINT_LEAST32_FMTu__ = "u";
//pub const __UINT_LEAST32_FMTx__ = "x";
//pub const __UINT_LEAST32_FMTX__ = "X";
//pub const __INT_LEAST64_TYPE__ = c_longlong;
//pub const __INT_LEAST64_MAX__ = @as(c_longlong, 9223372036854775807);
//pub const __INT_LEAST64_WIDTH__ = @as(c_int, 64);
//pub const __INT_LEAST64_FMTd__ = "lld";
//pub const __INT_LEAST64_FMTi__ = "lli";
//pub const __UINT_LEAST64_TYPE__ = c_ulonglong;
//pub const __UINT_LEAST64_MAX__ = @as(c_ulonglong, 18446744073709551615);
//pub const __UINT_LEAST64_FMTo__ = "llo";
//pub const __UINT_LEAST64_FMTu__ = "llu";
//pub const __UINT_LEAST64_FMTx__ = "llx";
//pub const __UINT_LEAST64_FMTX__ = "llX";
//pub const __INT_FAST8_TYPE__ = i8;
//pub const __INT_FAST8_MAX__ = @as(c_int, 127);
//pub const __INT_FAST8_WIDTH__ = @as(c_int, 8);
//pub const __INT_FAST8_FMTd__ = "hhd";
//pub const __INT_FAST8_FMTi__ = "hhi";
//pub const __UINT_FAST8_TYPE__ = u8;
//pub const __UINT_FAST8_MAX__ = @as(c_int, 255);
//pub const __UINT_FAST8_FMTo__ = "hho";
//pub const __UINT_FAST8_FMTu__ = "hhu";
//pub const __UINT_FAST8_FMTx__ = "hhx";
//pub const __UINT_FAST8_FMTX__ = "hhX";
//pub const __INT_FAST16_TYPE__ = c_short;
//pub const __INT_FAST16_MAX__ = @as(c_int, 32767);
//pub const __INT_FAST16_WIDTH__ = @as(c_int, 16);
//pub const __INT_FAST16_FMTd__ = "hd";
//pub const __INT_FAST16_FMTi__ = "hi";
//pub const __UINT_FAST16_TYPE__ = c_ushort;
//pub const __UINT_FAST16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
//pub const __UINT_FAST16_FMTo__ = "ho";
//pub const __UINT_FAST16_FMTu__ = "hu";
//pub const __UINT_FAST16_FMTx__ = "hx";
//pub const __UINT_FAST16_FMTX__ = "hX";
//pub const __INT_FAST32_TYPE__ = c_int;
//pub const __INT_FAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
//pub const __INT_FAST32_WIDTH__ = @as(c_int, 32);
//pub const __INT_FAST32_FMTd__ = "d";
//pub const __INT_FAST32_FMTi__ = "i";
//pub const __UINT_FAST32_TYPE__ = c_uint;
//pub const __UINT_FAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
//pub const __UINT_FAST32_FMTo__ = "o";
//pub const __UINT_FAST32_FMTu__ = "u";
//pub const __UINT_FAST32_FMTx__ = "x";
//pub const __UINT_FAST32_FMTX__ = "X";
//pub const __INT_FAST64_TYPE__ = c_longlong;
//pub const __INT_FAST64_MAX__ = @as(c_longlong, 9223372036854775807);
//pub const __INT_FAST64_WIDTH__ = @as(c_int, 64);
//pub const __INT_FAST64_FMTd__ = "lld";
//pub const __INT_FAST64_FMTi__ = "lli";
//pub const __UINT_FAST64_TYPE__ = c_ulonglong;
//pub const __UINT_FAST64_MAX__ = @as(c_ulonglong, 18446744073709551615);
//pub const __UINT_FAST64_FMTo__ = "llo";
//pub const __UINT_FAST64_FMTu__ = "llu";
//pub const __UINT_FAST64_FMTx__ = "llx";
//pub const __UINT_FAST64_FMTX__ = "llX";
//pub const __USER_LABEL_PREFIX__ = "";
//pub const __FINITE_MATH_ONLY__ = @as(c_int, 0);
//pub const __GNUC_STDC_INLINE__ = @as(c_int, 1);
//pub const __GCC_ATOMIC_TEST_AND_SET_TRUEVAL = @as(c_int, 1);
//pub const __CLANG_ATOMIC_BOOL_LOCK_FREE = @as(c_int, 2);
//pub const __CLANG_ATOMIC_CHAR_LOCK_FREE = @as(c_int, 2);
//pub const __CLANG_ATOMIC_CHAR16_T_LOCK_FREE = @as(c_int, 2);
//pub const __CLANG_ATOMIC_CHAR32_T_LOCK_FREE = @as(c_int, 2);
//pub const __CLANG_ATOMIC_WCHAR_T_LOCK_FREE = @as(c_int, 2);
//pub const __CLANG_ATOMIC_SHORT_LOCK_FREE = @as(c_int, 2);
//pub const __CLANG_ATOMIC_INT_LOCK_FREE = @as(c_int, 2);
//pub const __CLANG_ATOMIC_LONG_LOCK_FREE = @as(c_int, 2);
//pub const __CLANG_ATOMIC_LLONG_LOCK_FREE = @as(c_int, 2);
//pub const __CLANG_ATOMIC_POINTER_LOCK_FREE = @as(c_int, 2);
//pub const __GCC_ATOMIC_BOOL_LOCK_FREE = @as(c_int, 2);
//pub const __GCC_ATOMIC_CHAR_LOCK_FREE = @as(c_int, 2);
//pub const __GCC_ATOMIC_CHAR16_T_LOCK_FREE = @as(c_int, 2);
//pub const __GCC_ATOMIC_CHAR32_T_LOCK_FREE = @as(c_int, 2);
//pub const __GCC_ATOMIC_WCHAR_T_LOCK_FREE = @as(c_int, 2);
//pub const __GCC_ATOMIC_SHORT_LOCK_FREE = @as(c_int, 2);
//pub const __GCC_ATOMIC_INT_LOCK_FREE = @as(c_int, 2);
//pub const __GCC_ATOMIC_LONG_LOCK_FREE = @as(c_int, 2);
//pub const __GCC_ATOMIC_LLONG_LOCK_FREE = @as(c_int, 2);
//pub const __GCC_ATOMIC_POINTER_LOCK_FREE = @as(c_int, 2);
//pub const __NO_INLINE__ = @as(c_int, 1);
//pub const __PIC__ = @as(c_int, 2);
//pub const __pic__ = @as(c_int, 2);
//pub const __FLT_RADIX__ = @as(c_int, 2);
//pub const __DECIMAL_DIG__ = __LDBL_DECIMAL_DIG__;
//pub const __SSP_STRONG__ = @as(c_int, 2);
//pub const __GCC_ASM_FLAG_OUTPUTS__ = @as(c_int, 1);
//pub const __code_model_small__ = @as(c_int, 1);
//pub const __amd64__ = @as(c_int, 1);
//pub const __amd64 = @as(c_int, 1);
//pub const __x86_64 = @as(c_int, 1);
//pub const __x86_64__ = @as(c_int, 1);
//pub const __SEG_GS = @as(c_int, 1);
//pub const __SEG_FS = @as(c_int, 1);
//pub const __seg_gs = @compileError("unable to translate macro: undefined identifier `address_space`");
//// (no file):357:9
//pub const __seg_fs = @compileError("unable to translate macro: undefined identifier `address_space`");
//// (no file):358:9
//pub const __k8 = @as(c_int, 1);
//pub const __k8__ = @as(c_int, 1);
//pub const __tune_k8__ = @as(c_int, 1);
//pub const __REGISTER_PREFIX__ = "";
//pub const __NO_MATH_INLINES = @as(c_int, 1);
//pub const __AES__ = @as(c_int, 1);
//pub const __VAES__ = @as(c_int, 1);
//pub const __PCLMUL__ = @as(c_int, 1);
//pub const __VPCLMULQDQ__ = @as(c_int, 1);
//pub const __LAHF_SAHF__ = @as(c_int, 1);
//pub const __LZCNT__ = @as(c_int, 1);
//pub const __RDRND__ = @as(c_int, 1);
//pub const __FSGSBASE__ = @as(c_int, 1);
//pub const __BMI__ = @as(c_int, 1);
//pub const __BMI2__ = @as(c_int, 1);
//pub const __POPCNT__ = @as(c_int, 1);
//pub const __PRFCHW__ = @as(c_int, 1);
//pub const __RDSEED__ = @as(c_int, 1);
//pub const __ADX__ = @as(c_int, 1);
//pub const __MOVBE__ = @as(c_int, 1);
//pub const __FMA__ = @as(c_int, 1);
//pub const __F16C__ = @as(c_int, 1);
//pub const __GFNI__ = @as(c_int, 1);
//pub const __SHA__ = @as(c_int, 1);
//pub const __FXSR__ = @as(c_int, 1);
//pub const __XSAVE__ = @as(c_int, 1);
//pub const __XSAVEOPT__ = @as(c_int, 1);
//pub const __XSAVEC__ = @as(c_int, 1);
//pub const __XSAVES__ = @as(c_int, 1);
//pub const __CLFLUSHOPT__ = @as(c_int, 1);
//pub const __CLWB__ = @as(c_int, 1);
//pub const __SHSTK__ = @as(c_int, 1);
//pub const __RDPID__ = @as(c_int, 1);
//pub const __WAITPKG__ = @as(c_int, 1);
//pub const __MOVDIRI__ = @as(c_int, 1);
//pub const __MOVDIR64B__ = @as(c_int, 1);
//pub const __PTWRITE__ = @as(c_int, 1);
//pub const __INVPCID__ = @as(c_int, 1);
//pub const __AVX2__ = @as(c_int, 1);
//pub const __AVX__ = @as(c_int, 1);
//pub const __SSE4_2__ = @as(c_int, 1);
//pub const __SSE4_1__ = @as(c_int, 1);
//pub const __SSSE3__ = @as(c_int, 1);
//pub const __SSE3__ = @as(c_int, 1);
//pub const __SSE2__ = @as(c_int, 1);
//pub const __SSE2_MATH__ = @as(c_int, 1);
//pub const __SSE__ = @as(c_int, 1);
//pub const __SSE_MATH__ = @as(c_int, 1);
//pub const __MMX__ = @as(c_int, 1);
//pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_1 = @as(c_int, 1);
//pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_2 = @as(c_int, 1);
//pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_4 = @as(c_int, 1);
//pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_8 = @as(c_int, 1);
//pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_16 = @as(c_int, 1);
//pub const __SIZEOF_FLOAT128__ = @as(c_int, 16);
//pub const _WIN32 = @as(c_int, 1);
//pub const _WIN64 = @as(c_int, 1);
//pub const WIN32 = @as(c_int, 1);
//pub const __WIN32 = @as(c_int, 1);
//pub const __WIN32__ = @as(c_int, 1);
//pub const WINNT = @as(c_int, 1);
//pub const __WINNT = @as(c_int, 1);
//pub const __WINNT__ = @as(c_int, 1);
//pub const WIN64 = @as(c_int, 1);
//pub const __WIN64 = @as(c_int, 1);
//pub const __WIN64__ = @as(c_int, 1);
//pub const __MINGW64__ = @as(c_int, 1);
//pub const __MSVCRT__ = @as(c_int, 1);
//pub const __MINGW32__ = @as(c_int, 1);
//pub const __declspec = @compileError("unable to translate C expr: unexpected token '__attribute__'");
//// (no file):428:9
//pub const _cdecl = @compileError("unable to translate macro: undefined identifier `__cdecl__`");
//// (no file):429:9
//pub const __cdecl = @compileError("unable to translate macro: undefined identifier `__cdecl__`");
//// (no file):430:9
//pub const _stdcall = @compileError("unable to translate macro: undefined identifier `__stdcall__`");
//// (no file):431:9
//pub const __stdcall = @compileError("unable to translate macro: undefined identifier `__stdcall__`");
//// (no file):432:9
//pub const _fastcall = @compileError("unable to translate macro: undefined identifier `__fastcall__`");
//// (no file):433:9
//pub const __fastcall = @compileError("unable to translate macro: undefined identifier `__fastcall__`");
//// (no file):434:9
//pub const _thiscall = @compileError("unable to translate macro: undefined identifier `__thiscall__`");
//// (no file):435:9
//pub const __thiscall = @compileError("unable to translate macro: undefined identifier `__thiscall__`");
//// (no file):436:9
//pub const _pascal = @compileError("unable to translate macro: undefined identifier `__pascal__`");
//// (no file):437:9
//pub const __pascal = @compileError("unable to translate macro: undefined identifier `__pascal__`");
//// (no file):438:9
//pub const __STDC__ = @as(c_int, 1);
//pub const __STDC_HOSTED__ = @as(c_int, 1);
//pub const __STDC_VERSION__ = @as(c_long, 201710);
//pub const __STDC_UTF_16__ = @as(c_int, 1);
//pub const __STDC_UTF_32__ = @as(c_int, 1);
//pub const _LIBCPP_DISABLE_VISIBILITY_ANNOTATIONS = @as(c_int, 1);
//pub const _LIBCXXABI_DISABLE_VISIBILITY_ANNOTATIONS = @as(c_int, 1);
//pub const _LIBCPP_HAS_NO_VENDOR_AVAILABILITY_ANNOTATIONS = @as(c_int, 1);
//pub const _LIBCPP_PSTL_CPU_BACKEND_SERIAL = @as(c_int, 1);
//pub const _LIBCPP_ABI_VERSION = @as(c_int, 1);
//pub const _LIBCPP_ABI_NAMESPACE = @compileError("unable to translate macro: undefined identifier `__1`");
//// (no file):450:9
//pub const _LIBCPP_HARDENING_MODE = @compileError("unable to translate macro: undefined identifier `_LIBCPP_HARDENING_MODE_DEBUG`");
//// (no file):451:9
//pub const __MSVCRT_VERSION__ = @as(c_int, 0xE00);
//pub const _WIN32_WINNT = @as(c_int, 0x0a00);
//pub const _DEBUG = @as(c_int, 1);
//pub const SDL_gpu_h_ = "";
//pub const SDL_stdinc_h_ = "";
//pub const SDL_platform_defines_h_ = "";
//pub const SDL_PLATFORM_WINDOWS = @as(c_int, 1);
//pub const HAVE_WINAPIFAMILY_H = @as(c_int, 0);
//pub const WINAPI_FAMILY_WINRT = @as(c_int, 0);
//pub const SDL_WINAPI_FAMILY_PHONE = @as(c_int, 0);
//pub const SDL_PLATFORM_WIN32 = @as(c_int, 1);
//pub const _LIBCPP_INTTYPES_H = "";
//pub const _LIBCPP___CONFIG = "";
//pub const _LIBCPP_COMPILER_CLANG_BASED = "";
//pub const _LIBCPP_CLANG_VER = (__clang_major__ * @as(c_int, 100)) + __clang_minor__;
//pub const __CLANG_INTTYPES_H = "";
//pub const _INTTYPES_H_ = "";
//pub const _INC_CRTDEFS = "";
//pub const _INC_CORECRT = "";
//pub const _INC__MINGW_H = "";
//pub const _INC_CRTDEFS_MACRO = "";
//pub const __STRINGIFY = @compileError("unable to translate C expr: unexpected token '#'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:10:9
//pub inline fn __MINGW64_STRINGIFY(x: anytype) @TypeOf(__STRINGIFY(x)) {
//    _ = &x;
//    return __STRINGIFY(x);
//}
//pub const __MINGW64_VERSION_MAJOR = @as(c_int, 12);
//pub const __MINGW64_VERSION_MINOR = @as(c_int, 0);
//pub const __MINGW64_VERSION_BUGFIX = @as(c_int, 0);
//pub const __MINGW64_VERSION_RC = @as(c_int, 0);
//pub const __MINGW64_VERSION_STR = __MINGW64_STRINGIFY(__MINGW64_VERSION_MAJOR) ++ "." ++ __MINGW64_STRINGIFY(__MINGW64_VERSION_MINOR) ++ "." ++ __MINGW64_STRINGIFY(__MINGW64_VERSION_BUGFIX);
//pub const __MINGW64_VERSION_STATE = "alpha";
//pub const __MINGW32_MAJOR_VERSION = @as(c_int, 3);
//pub const __MINGW32_MINOR_VERSION = @as(c_int, 11);
//pub const _M_AMD64 = @as(c_int, 100);
//pub const _M_X64 = @as(c_int, 100);
//pub const @"_" = @as(c_int, 1);
//pub const __MINGW_USE_UNDERSCORE_PREFIX = @as(c_int, 0);
//pub const __MINGW_IMP_SYMBOL = @compileError("unable to translate macro: undefined identifier `__imp_`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:119:11
//pub const __MINGW_IMP_LSYMBOL = @compileError("unable to translate macro: undefined identifier `__imp_`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:120:11
//pub inline fn __MINGW_USYMBOL(sym: anytype) @TypeOf(sym) {
//    _ = &sym;
//    return sym;
//}
//pub const __MINGW_LSYMBOL = @compileError("unable to translate C expr: unexpected token '##'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:122:11
//pub const __MINGW_ASM_CALL = @compileError("unable to translate C expr: unexpected token '__asm__'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:130:9
//pub const __MINGW_ASM_CRT_CALL = @compileError("unable to translate C expr: unexpected token '__asm__'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:131:9
//pub const __MINGW_EXTENSION = @compileError("unable to translate C expr: unexpected token '__extension__'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:163:13
//pub const __C89_NAMELESS = __MINGW_EXTENSION;
//pub const __C89_NAMELESSSTRUCTNAME = "";
//pub const __C89_NAMELESSSTRUCTNAME1 = "";
//pub const __C89_NAMELESSSTRUCTNAME2 = "";
//pub const __C89_NAMELESSSTRUCTNAME3 = "";
//pub const __C89_NAMELESSSTRUCTNAME4 = "";
//pub const __C89_NAMELESSSTRUCTNAME5 = "";
//pub const __C89_NAMELESSUNIONNAME = "";
//pub const __C89_NAMELESSUNIONNAME1 = "";
//pub const __C89_NAMELESSUNIONNAME2 = "";
//pub const __C89_NAMELESSUNIONNAME3 = "";
//pub const __C89_NAMELESSUNIONNAME4 = "";
//pub const __C89_NAMELESSUNIONNAME5 = "";
//pub const __C89_NAMELESSUNIONNAME6 = "";
//pub const __C89_NAMELESSUNIONNAME7 = "";
//pub const __C89_NAMELESSUNIONNAME8 = "";
//pub const __GNU_EXTENSION = __MINGW_EXTENSION;
//pub const __MINGW_HAVE_ANSI_C99_PRINTF = @as(c_int, 1);
//pub const __MINGW_HAVE_WIDE_C99_PRINTF = @as(c_int, 1);
//pub const __MINGW_HAVE_ANSI_C99_SCANF = @as(c_int, 1);
//pub const __MINGW_HAVE_WIDE_C99_SCANF = @as(c_int, 1);
//pub const __MINGW_POISON_NAME = @compileError("unable to translate macro: undefined identifier `_layout_has_not_been_verified_and_its_declaration_is_most_likely_incorrect`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:203:11
//pub const __MSABI_LONG = @import("std").zig.c_translation.Macros.L_SUFFIX;
//pub const __MINGW_GCC_VERSION = ((__GNUC__ * @as(c_int, 10000)) + (__GNUC_MINOR__ * @as(c_int, 100))) + __GNUC_PATCHLEVEL__;
//pub inline fn __MINGW_GNUC_PREREQ(major: anytype, minor: anytype) @TypeOf((__GNUC__ > major) or ((__GNUC__ == major) and (__GNUC_MINOR__ >= minor))) {
//    _ = &major;
//    _ = &minor;
//    return (__GNUC__ > major) or ((__GNUC__ == major) and (__GNUC_MINOR__ >= minor));
//}
//pub inline fn __MINGW_MSC_PREREQ(major: anytype, minor: anytype) @TypeOf(@as(c_int, 0)) {
//    _ = &major;
//    _ = &minor;
//    return @as(c_int, 0);
//}
//pub const __MINGW_ATTRIB_DEPRECATED_STR = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:247:11
//pub const __MINGW_SEC_WARN_STR = "This function or variable may be unsafe, use _CRT_SECURE_NO_WARNINGS to disable deprecation";
//pub const __MINGW_MSVC2005_DEPREC_STR = "This POSIX function is deprecated beginning in Visual C++ 2005, use _CRT_NONSTDC_NO_DEPRECATE to disable deprecation";
//pub const __MINGW_ATTRIB_DEPRECATED_MSVC2005 = __MINGW_ATTRIB_DEPRECATED_STR(__MINGW_MSVC2005_DEPREC_STR);
//pub const __MINGW_ATTRIB_DEPRECATED_SEC_WARN = __MINGW_ATTRIB_DEPRECATED_STR(__MINGW_SEC_WARN_STR);
//pub const __MINGW_MS_PRINTF = @compileError("unable to translate macro: undefined identifier `__format__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:270:9
//pub const __MINGW_MS_SCANF = @compileError("unable to translate macro: undefined identifier `__format__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:273:9
//pub const __MINGW_GNU_PRINTF = @compileError("unable to translate macro: undefined identifier `__format__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:276:9
//pub const __MINGW_GNU_SCANF = @compileError("unable to translate macro: undefined identifier `__format__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:279:9
//pub const __mingw_ovr = @compileError("unable to translate macro: undefined identifier `__unused__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:289:11
//pub const __mingw_static_ovr = __mingw_ovr;
//pub const __mingw_attribute_artificial = @compileError("unable to translate macro: undefined identifier `__artificial__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:298:11
//pub const __MINGW_SELECTANY = @compileError("unable to translate macro: undefined identifier `__selectany__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_mac.h:304:9
//pub const __MINGW_FORTIFY_LEVEL = @as(c_int, 0);
//pub const __mingw_bos_ovr = __mingw_ovr;
//pub const __MINGW_FORTIFY_VA_ARG = @as(c_int, 0);
//pub const _INC_MINGW_SECAPI = "";
//pub const _CRT_SECURE_CPP_OVERLOAD_SECURE_NAMES = @as(c_int, 0);
//pub const _CRT_SECURE_CPP_OVERLOAD_SECURE_NAMES_MEMORY = @as(c_int, 0);
//pub const _CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES = @as(c_int, 0);
//pub const _CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES_COUNT = @as(c_int, 0);
//pub const _CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES_MEMORY = @as(c_int, 0);
//pub const __MINGW_CRT_NAME_CONCAT2 = @compileError("unable to translate macro: undefined identifier `_s`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_secapi.h:41:9
//pub const __CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES_MEMORY_0_3_ = @compileError("unable to translate C expr: unexpected token ';'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_secapi.h:69:9
//pub const __LONG32 = c_long;
//pub const __MINGW_IMPORT = @compileError("unable to translate macro: undefined identifier `__dllimport__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:44:12
//pub const __USE_CRTIMP = @as(c_int, 1);
//pub const _CRTIMP = @compileError("unable to translate macro: undefined identifier `__dllimport__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:52:15
//pub const __DECLSPEC_SUPPORTED = "";
//pub const USE___UUIDOF = @as(c_int, 0);
//pub const _inline = @compileError("unable to translate C expr: unexpected token '__inline'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:74:9
//pub const __CRT_INLINE = @compileError("unable to translate macro: undefined identifier `__gnu_inline__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:83:11
//pub const __MINGW_INTRIN_INLINE = @compileError("unable to translate macro: undefined identifier `__always_inline__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:90:9
//pub const __CRT__NO_INLINE = @as(c_int, 1);
//pub const __UNUSED_PARAM = @compileError("unable to translate macro: undefined identifier `__unused__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:104:11
//pub const __restrict_arr = @compileError("unable to translate C expr: unexpected token '__restrict'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:119:10
//pub const __MINGW_ATTRIB_NORETURN = @compileError("unable to translate macro: undefined identifier `__noreturn__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:135:9
//pub const __MINGW_ATTRIB_CONST = @compileError("unable to translate C expr: unexpected token '__attribute__'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:136:9
//pub const __MINGW_ATTRIB_MALLOC = @compileError("unable to translate macro: undefined identifier `__malloc__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:146:9
//pub const __MINGW_ATTRIB_PURE = @compileError("unable to translate macro: undefined identifier `__pure__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:147:9
//pub const __MINGW_ATTRIB_NONNULL = @compileError("unable to translate macro: undefined identifier `__nonnull__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:160:9
//pub const __MINGW_ATTRIB_UNUSED = @compileError("unable to translate macro: undefined identifier `__unused__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:166:9
//pub const __MINGW_ATTRIB_USED = @compileError("unable to translate macro: undefined identifier `__used__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:172:9
//pub const __MINGW_ATTRIB_DEPRECATED = @compileError("unable to translate macro: undefined identifier `__deprecated__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:173:9
//pub const __MINGW_ATTRIB_DEPRECATED_MSG = @compileError("unable to translate macro: undefined identifier `__deprecated__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:175:9
//pub const __MINGW_NOTHROW = @compileError("unable to translate macro: undefined identifier `__nothrow__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:190:9
//pub const __MINGW_ATTRIB_NO_OPTIMIZE = "";
//pub const __MINGW_PRAGMA_PARAM = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:208:9
//pub const __MINGW_BROKEN_INTERFACE = @compileError("unable to translate macro: undefined identifier `message`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:211:9
//pub const _UCRT = "";
//pub const _INT128_DEFINED = "";
//pub const __int8 = u8;
//pub const __int16 = c_short;
//pub const __int32 = c_int;
//pub const __int64 = c_longlong;
//pub const __ptr32 = "";
//pub const __ptr64 = "";
//pub const __unaligned = "";
//pub const __w64 = "";
//pub const __forceinline = @compileError("unable to translate macro: undefined identifier `__always_inline__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:266:9
//pub const __nothrow = "";
//pub const _INC_VADEFS = "";
//pub const MINGW_SDK_INIT = "";
//pub const MINGW_HAS_SECURE_API = @as(c_int, 1);
//pub const __STDC_SECURE_LIB__ = @as(c_long, 200411);
//pub const __GOT_SECURE_LIB__ = __STDC_SECURE_LIB__;
//pub const MINGW_DDK_H = "";
//pub const MINGW_HAS_DDK_H = @as(c_int, 1);
//pub const _CRT_PACKING = @as(c_int, 8);
//pub const __GNUC_VA_LIST = "";
//pub const _VA_LIST_DEFINED = "";
//pub inline fn _ADDRESSOF(v: anytype) @TypeOf(&v) {
//    _ = &v;
//    return &v;
//}
//pub const _crt_va_start = @compileError("unable to translate macro: undefined identifier `__builtin_va_start`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/vadefs.h:48:9
//pub const _crt_va_arg = @compileError("unable to translate C expr: unexpected token 'an identifier'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/vadefs.h:49:9
//pub const _crt_va_end = @compileError("unable to translate macro: undefined identifier `__builtin_va_end`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/vadefs.h:50:9
//pub const _crt_va_copy = @compileError("unable to translate macro: undefined identifier `__builtin_va_copy`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/vadefs.h:51:9
//pub const __CRT_STRINGIZE = @compileError("unable to translate C expr: unexpected token '#'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:285:9
//pub inline fn _CRT_STRINGIZE(_Value: anytype) @TypeOf(__CRT_STRINGIZE(_Value)) {
//    _ = &_Value;
//    return __CRT_STRINGIZE(_Value);
//}
//pub const __CRT_WIDE = @compileError("unable to translate macro: undefined identifier `L`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:290:9
//pub inline fn _CRT_WIDE(_String: anytype) @TypeOf(__CRT_WIDE(_String)) {
//    _ = &_String;
//    return __CRT_WIDE(_String);
//}
//pub const _W64 = "";
//pub const _CRTIMP_NOIA64 = _CRTIMP;
//pub const _CRTIMP2 = _CRTIMP;
//pub const _CRTIMP_ALTERNATIVE = _CRTIMP;
//pub const _CRT_ALTERNATIVE_IMPORTED = "";
//pub const _MRTIMP2 = _CRTIMP;
//pub const _DLL = "";
//pub const _MT = "";
//pub const _MCRTIMP = _CRTIMP;
//pub const _CRTIMP_PURE = _CRTIMP;
//pub const _PGLOBAL = "";
//pub const _AGLOBAL = "";
//pub const _SECURECRT_FILL_BUFFER_PATTERN = @as(c_int, 0xFD);
//pub const _CRT_DEPRECATE_TEXT = @compileError("unable to translate macro: undefined identifier `deprecated`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:349:9
//pub const _CRT_INSECURE_DEPRECATE_MEMORY = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:352:9
//pub const _CRT_INSECURE_DEPRECATE_GLOBALS = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:356:9
//pub const _CRT_MANAGED_HEAP_DEPRECATE = "";
//pub const _CRT_OBSOLETE = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:364:9
//pub const _CONST_RETURN = "";
//pub const UNALIGNED = "";
//pub const _CRT_ALIGN = @compileError("unable to translate macro: undefined identifier `__aligned__`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:391:9
//pub const __CRTDECL = __cdecl;
//pub const _ARGMAX = @as(c_int, 100);
//pub const _TRUNCATE = @import("std").zig.c_translation.cast(usize, -@as(c_int, 1));
//pub inline fn _CRT_UNUSED(x: anytype) anyopaque {
//    _ = &x;
//    return @import("std").zig.c_translation.cast(anyopaque, x);
//}
//pub const __USE_MINGW_ANSI_STDIO = @as(c_int, 0);
//pub const _CRT_glob = @compileError("unable to translate macro: undefined identifier `_dowildcard`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:455:9
//pub const __ANONYMOUS_DEFINED = "";
//pub const _ANONYMOUS_UNION = __MINGW_EXTENSION;
//pub const _ANONYMOUS_STRUCT = __MINGW_EXTENSION;
//pub const _UNION_NAME = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:475:9
//pub const _STRUCT_NAME = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:476:9
//pub const DUMMYUNIONNAME = "";
//pub const DUMMYUNIONNAME1 = "";
//pub const DUMMYUNIONNAME2 = "";
//pub const DUMMYUNIONNAME3 = "";
//pub const DUMMYUNIONNAME4 = "";
//pub const DUMMYUNIONNAME5 = "";
//pub const DUMMYUNIONNAME6 = "";
//pub const DUMMYUNIONNAME7 = "";
//pub const DUMMYUNIONNAME8 = "";
//pub const DUMMYUNIONNAME9 = "";
//pub const DUMMYSTRUCTNAME = "";
//pub const DUMMYSTRUCTNAME1 = "";
//pub const DUMMYSTRUCTNAME2 = "";
//pub const DUMMYSTRUCTNAME3 = "";
//pub const DUMMYSTRUCTNAME4 = "";
//pub const DUMMYSTRUCTNAME5 = "";
//pub const __CRT_UUID_DECL = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:563:9
//pub const __MINGW_DEBUGBREAK_IMPL = !(__has_builtin(__debugbreak) != 0);
//pub const __MINGW_FASTFAIL_IMPL = !(__has_builtin(__fastfail) != 0);
//pub const __MINGW_PREFETCH_IMPL = @compileError("unable to translate macro: undefined identifier `__prefetch`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw.h:620:9
//pub const _CRTNOALIAS = "";
//pub const _CRTRESTRICT = "";
//pub const _SIZE_T_DEFINED = "";
//pub const _SSIZE_T_DEFINED = "";
//pub const _RSIZE_T_DEFINED = "";
//pub const _INTPTR_T_DEFINED = "";
//pub const __intptr_t_defined = "";
//pub const _UINTPTR_T_DEFINED = "";
//pub const __uintptr_t_defined = "";
//pub const _PTRDIFF_T_DEFINED = "";
//pub const _PTRDIFF_T_ = "";
//pub const _WCHAR_T_DEFINED = "";
//pub const _WCTYPE_T_DEFINED = "";
//pub const _WINT_T = "";
//pub const _ERRCODE_DEFINED = "";
//pub const _TIME32_T_DEFINED = "";
//pub const _TIME64_T_DEFINED = "";
//pub const _TIME_T_DEFINED = "";
//pub const _CRT_SECURE_CPP_NOTHROW = @compileError("unable to translate macro: undefined identifier `throw`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:143:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_0 = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:262:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_1 = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:263:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_2 = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:264:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_3 = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:265:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_4 = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:266:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_1_1 = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:267:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_1_2 = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:268:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_1_3 = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:269:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_2_0 = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:270:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_1_ARGLIST = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:271:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_2_ARGLIST = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:272:9
//pub const __DEFINE_CPP_OVERLOAD_SECURE_FUNC_SPLITPATH = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:273:9
//pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_0 = @compileError("unable to translate macro: undefined identifier `__func_name`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:277:9
//pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_1 = @compileError("unable to translate macro: undefined identifier `__func_name`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:279:9
//pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_2 = @compileError("unable to translate macro: undefined identifier `__func_name`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:281:9
//pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_3 = @compileError("unable to translate macro: undefined identifier `__func_name`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:283:9
//pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_4 = @compileError("unable to translate macro: undefined identifier `__func_name`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:285:9
//pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_0_EX = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:422:9
//pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_1_EX = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:423:9
//pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_2_EX = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:424:9
//pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_3_EX = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:425:9
//pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_4_EX = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:426:9
//pub const _TAGLC_ID_DEFINED = "";
//pub const _THREADLOCALEINFO = "";
//pub const __crt_typefix = @compileError("unable to translate C expr: unexpected token ''");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/corecrt.h:486:9
//pub const _CRT_USE_WINAPI_FAMILY_DESKTOP_APP = "";
//pub const _LIBCPP_STDINT_H = "";
//pub const __CLANG_STDINT_H = "";
//pub const _STDINT_H = "";
//pub const __need_wint_t = "";
//pub const __need_wchar_t = "";
//pub const _WCHAR_T = "";
//pub const _LIBCPP_STDDEF_H = "";
//pub const INT8_MIN = -@as(c_int, 128);
//pub const INT16_MIN = -@import("std").zig.c_translation.promoteIntLiteral(c_int, 32768, .decimal);
//pub const INT32_MIN = -@import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal) - @as(c_int, 1);
//pub const INT64_MIN = -@as(c_longlong, 9223372036854775807) - @as(c_int, 1);
//pub const INT8_MAX = @as(c_int, 127);
//pub const INT16_MAX = @as(c_int, 32767);
//pub const INT32_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
//pub const INT64_MAX = @as(c_longlong, 9223372036854775807);
//pub const UINT8_MAX = @as(c_int, 255);
//pub const UINT16_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
//pub const UINT32_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 0xffffffff, .hex);
//pub const UINT64_MAX = @as(c_ulonglong, 0xffffffffffffffff);
//pub const INT_LEAST8_MIN = INT8_MIN;
//pub const INT_LEAST16_MIN = INT16_MIN;
//pub const INT_LEAST32_MIN = INT32_MIN;
//pub const INT_LEAST64_MIN = INT64_MIN;
//pub const INT_LEAST8_MAX = INT8_MAX;
//pub const INT_LEAST16_MAX = INT16_MAX;
//pub const INT_LEAST32_MAX = INT32_MAX;
//pub const INT_LEAST64_MAX = INT64_MAX;
//pub const UINT_LEAST8_MAX = UINT8_MAX;
//pub const UINT_LEAST16_MAX = UINT16_MAX;
//pub const UINT_LEAST32_MAX = UINT32_MAX;
//pub const UINT_LEAST64_MAX = UINT64_MAX;
//pub const INT_FAST8_MIN = INT8_MIN;
//pub const INT_FAST16_MIN = INT16_MIN;
//pub const INT_FAST32_MIN = INT32_MIN;
//pub const INT_FAST64_MIN = INT64_MIN;
//pub const INT_FAST8_MAX = INT8_MAX;
//pub const INT_FAST16_MAX = INT16_MAX;
//pub const INT_FAST32_MAX = INT32_MAX;
//pub const INT_FAST64_MAX = INT64_MAX;
//pub const UINT_FAST8_MAX = UINT8_MAX;
//pub const UINT_FAST16_MAX = UINT16_MAX;
//pub const UINT_FAST32_MAX = UINT32_MAX;
//pub const UINT_FAST64_MAX = UINT64_MAX;
//pub const INTPTR_MIN = INT64_MIN;
//pub const INTPTR_MAX = INT64_MAX;
//pub const UINTPTR_MAX = UINT64_MAX;
//pub const INTMAX_MIN = INT64_MIN;
//pub const INTMAX_MAX = INT64_MAX;
//pub const UINTMAX_MAX = UINT64_MAX;
//pub const PTRDIFF_MIN = INT64_MIN;
//pub const PTRDIFF_MAX = INT64_MAX;
//pub const SIG_ATOMIC_MIN = INT32_MIN;
//pub const SIG_ATOMIC_MAX = INT32_MAX;
//pub const SIZE_MAX = UINT64_MAX;
//pub const WCHAR_MIN = @as(c_uint, 0);
//pub const WCHAR_MAX = @as(c_uint, 0xffff);
//pub const WINT_MIN = @as(c_uint, 0);
//pub const WINT_MAX = @as(c_uint, 0xffff);
//pub inline fn INT8_C(val: anytype) @TypeOf((INT_LEAST8_MAX - INT_LEAST8_MAX) + val) {
//    _ = &val;
//    return (INT_LEAST8_MAX - INT_LEAST8_MAX) + val;
//}
//pub inline fn INT16_C(val: anytype) @TypeOf((INT_LEAST16_MAX - INT_LEAST16_MAX) + val) {
//    _ = &val;
//    return (INT_LEAST16_MAX - INT_LEAST16_MAX) + val;
//}
//pub inline fn INT32_C(val: anytype) @TypeOf((INT_LEAST32_MAX - INT_LEAST32_MAX) + val) {
//    _ = &val;
//    return (INT_LEAST32_MAX - INT_LEAST32_MAX) + val;
//}
//pub const INT64_C = @import("std").zig.c_translation.Macros.LL_SUFFIX;
//pub inline fn UINT8_C(val: anytype) @TypeOf(val) {
//    _ = &val;
//    return val;
//}
//pub inline fn UINT16_C(val: anytype) @TypeOf(val) {
//    _ = &val;
//    return val;
//}
//pub const UINT32_C = @import("std").zig.c_translation.Macros.U_SUFFIX;
//pub const UINT64_C = @import("std").zig.c_translation.Macros.ULL_SUFFIX;
//pub const INTMAX_C = @import("std").zig.c_translation.Macros.LL_SUFFIX;
//pub const UINTMAX_C = @import("std").zig.c_translation.Macros.ULL_SUFFIX;
//pub const PRId64 = "lld";
//pub const PRIi64 = "lli";
//pub const PRIo64 = "llo";
//pub const PRIu64 = "llu";
//pub const PRIx64 = "llx";
//pub const PRIX64 = "llX";
//pub const PRId8 = "d";
//pub const PRId16 = "d";
//pub const PRId32 = "d";
//pub const PRIdLEAST8 = "d";
//pub const PRIdLEAST16 = "d";
//pub const PRIdLEAST32 = "d";
//pub const PRIdLEAST64 = PRId64;
//pub const PRIdFAST8 = "d";
//pub const PRIdFAST16 = "d";
//pub const PRIdFAST32 = "d";
//pub const PRIdFAST64 = PRId64;
//pub const PRIdMAX = PRId64;
//pub const PRIi8 = "i";
//pub const PRIi16 = "i";
//pub const PRIi32 = "i";
//pub const PRIiLEAST8 = "i";
//pub const PRIiLEAST16 = "i";
//pub const PRIiLEAST32 = "i";
//pub const PRIiLEAST64 = PRIi64;
//pub const PRIiFAST8 = "i";
//pub const PRIiFAST16 = "i";
//pub const PRIiFAST32 = "i";
//pub const PRIiFAST64 = PRIi64;
//pub const PRIiMAX = PRIi64;
//pub const PRIo8 = "o";
//pub const PRIo16 = "o";
//pub const PRIo32 = "o";
//pub const PRIoLEAST8 = "o";
//pub const PRIoLEAST16 = "o";
//pub const PRIoLEAST32 = "o";
//pub const PRIoLEAST64 = PRIo64;
//pub const PRIoFAST8 = "o";
//pub const PRIoFAST16 = "o";
//pub const PRIoFAST32 = "o";
//pub const PRIoFAST64 = PRIo64;
//pub const PRIoMAX = PRIo64;
//pub const PRIu8 = "u";
//pub const PRIu16 = "u";
//pub const PRIu32 = "u";
//pub const PRIuLEAST8 = "u";
//pub const PRIuLEAST16 = "u";
//pub const PRIuLEAST32 = "u";
//pub const PRIuLEAST64 = PRIu64;
//pub const PRIuFAST8 = "u";
//pub const PRIuFAST16 = "u";
//pub const PRIuFAST32 = "u";
//pub const PRIuFAST64 = PRIu64;
//pub const PRIuMAX = PRIu64;
//pub const PRIx8 = "x";
//pub const PRIx16 = "x";
//pub const PRIx32 = "x";
//pub const PRIxLEAST8 = "x";
//pub const PRIxLEAST16 = "x";
//pub const PRIxLEAST32 = "x";
//pub const PRIxLEAST64 = PRIx64;
//pub const PRIxFAST8 = "x";
//pub const PRIxFAST16 = "x";
//pub const PRIxFAST32 = "x";
//pub const PRIxFAST64 = PRIx64;
//pub const PRIxMAX = PRIx64;
//pub const PRIX8 = "X";
//pub const PRIX16 = "X";
//pub const PRIX32 = "X";
//pub const PRIXLEAST8 = "X";
//pub const PRIXLEAST16 = "X";
//pub const PRIXLEAST32 = "X";
//pub const PRIXLEAST64 = PRIX64;
//pub const PRIXFAST8 = "X";
//pub const PRIXFAST16 = "X";
//pub const PRIXFAST32 = "X";
//pub const PRIXFAST64 = PRIX64;
//pub const PRIXMAX = PRIX64;
//pub const SCNd16 = "hd";
//pub const SCNd32 = "d";
//pub const SCNd64 = PRId64;
//pub const SCNdLEAST16 = "hd";
//pub const SCNdLEAST32 = "d";
//pub const SCNdLEAST64 = PRId64;
//pub const SCNdFAST16 = "hd";
//pub const SCNdFAST32 = "d";
//pub const SCNdFAST64 = PRId64;
//pub const SCNdMAX = PRId64;
//pub const SCNi16 = "hi";
//pub const SCNi32 = "i";
//pub const SCNi64 = PRIi64;
//pub const SCNiLEAST16 = "hi";
//pub const SCNiLEAST32 = "i";
//pub const SCNiLEAST64 = PRIi64;
//pub const SCNiFAST16 = "hi";
//pub const SCNiFAST32 = "i";
//pub const SCNiFAST64 = PRIi64;
//pub const SCNiMAX = PRIi64;
//pub const SCNo16 = "ho";
//pub const SCNo32 = "o";
//pub const SCNo64 = PRIo64;
//pub const SCNoLEAST16 = "ho";
//pub const SCNoLEAST32 = "o";
//pub const SCNoLEAST64 = PRIo64;
//pub const SCNoFAST16 = "ho";
//pub const SCNoFAST32 = "o";
//pub const SCNoFAST64 = PRIo64;
//pub const SCNoMAX = PRIo64;
//pub const SCNx16 = "hx";
//pub const SCNx32 = "x";
//pub const SCNx64 = PRIx64;
//pub const SCNxLEAST16 = "hx";
//pub const SCNxLEAST32 = "x";
//pub const SCNxLEAST64 = PRIx64;
//pub const SCNxFAST16 = "hx";
//pub const SCNxFAST32 = "x";
//pub const SCNxFAST64 = PRIx64;
//pub const SCNxMAX = PRIx64;
//pub const SCNu16 = "hu";
//pub const SCNu32 = "u";
//pub const SCNu64 = PRIu64;
//pub const SCNuLEAST16 = "hu";
//pub const SCNuLEAST32 = "u";
//pub const SCNuLEAST64 = PRIu64;
//pub const SCNuFAST16 = "hu";
//pub const SCNuFAST32 = "u";
//pub const SCNuFAST64 = PRIu64;
//pub const SCNuMAX = PRIu64;
//pub const PRIdPTR = PRId64;
//pub const PRIiPTR = PRIi64;
//pub const PRIoPTR = PRIo64;
//pub const PRIuPTR = PRIu64;
//pub const PRIxPTR = PRIx64;
//pub const PRIXPTR = PRIX64;
//pub const SCNdPTR = PRId64;
//pub const SCNiPTR = PRIi64;
//pub const SCNoPTR = PRIo64;
//pub const SCNxPTR = PRIx64;
//pub const SCNuPTR = PRIu64;
//pub const SCNd8 = "hhd";
//pub const SCNdLEAST8 = "hhd";
//pub const SCNdFAST8 = "hhd";
//pub const SCNi8 = "hhi";
//pub const SCNiLEAST8 = "hhi";
//pub const SCNiFAST8 = "hhi";
//pub const SCNo8 = "hho";
//pub const SCNoLEAST8 = "hho";
//pub const SCNoFAST8 = "hho";
//pub const SCNx8 = "hhx";
//pub const SCNxLEAST8 = "hhx";
//pub const SCNxFAST8 = "hhx";
//pub const SCNu8 = "hhu";
//pub const SCNuLEAST8 = "hhu";
//pub const SCNuFAST8 = "hhu";
//pub const __STDARG_H = "";
//pub const __need___va_list = "";
//pub const __need_va_list = "";
//pub const __need_va_arg = "";
//pub const __need___va_copy = "";
//pub const __need_va_copy = "";
//pub const _VA_LIST = "";
//pub const va_start = @compileError("unable to translate macro: undefined identifier `__builtin_va_start`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\include/__stdarg_va_arg.h:17:9
//pub const va_end = @compileError("unable to translate macro: undefined identifier `__builtin_va_end`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\include/__stdarg_va_arg.h:19:9
//pub const va_arg = @compileError("unable to translate C expr: unexpected token 'an identifier'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\include/__stdarg_va_arg.h:20:9
//pub const __va_copy = @compileError("unable to translate macro: undefined identifier `__builtin_va_copy`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\include/__stdarg___va_copy.h:11:9
//pub const va_copy = @compileError("unable to translate macro: undefined identifier `__builtin_va_copy`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\include/__stdarg_va_copy.h:11:9
//pub const _LIBCPP_STDBOOL_H = "";
//pub const __STDBOOL_H = "";
//pub const __bool_true_false_are_defined = @as(c_int, 1);
//pub const @"bool" = bool;
//pub const @"true" = @as(c_int, 1);
//pub const @"false" = @as(c_int, 0);
//pub const _LIBCPP_STRING_H = "";
//pub const _INC_STRING = "";
//pub const _SECIMP = @compileError("unable to translate macro: undefined identifier `dllimport`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/string.h:16:9
//pub const _NLSCMP_DEFINED = "";
//pub const _NLSCMPERROR = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
//pub const NULL = @import("std").zig.c_translation.cast(?*anyopaque, @as(c_int, 0));
//pub const _WConst_return = "";
//pub const _CRT_MEMORY_DEFINED = "";
//pub const _WSTRING_DEFINED = "";
//pub const wcswcs = wcsstr;
//pub const _INC_STRING_S = "";
//pub const _WSTRING_S_DEFINED = "";
//pub const _LIBCPP_WCHAR_H = "";
//pub const __STDDEF_H = "";
//pub const __need_ptrdiff_t = "";
//pub const __need_size_t = "";
//pub const __need_NULL = "";
//pub const __need_max_align_t = "";
//pub const __need_offsetof = "";
//pub const _PTRDIFF_T = "";
//pub const _SIZE_T = "";
//pub const __CLANG_MAX_ALIGN_T_DEFINED = "";
//pub const offsetof = @compileError("unable to translate C expr: unexpected token 'an identifier'");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\include/__stddef_offsetof.h:16:9
//pub const _INC_WCHAR = "";
//pub const _STDIO_CONFIG_DEFINED = "";
//pub const _CRT_INTERNAL_PRINTF_LEGACY_VSPRINTF_NULL_TERMINATION = @as(c_ulonglong, 0x0001);
//pub const _CRT_INTERNAL_PRINTF_STANDARD_SNPRINTF_BEHAVIOR = @as(c_ulonglong, 0x0002);
//pub const _CRT_INTERNAL_PRINTF_LEGACY_WIDE_SPECIFIERS = @as(c_ulonglong, 0x0004);
//pub const _CRT_INTERNAL_PRINTF_LEGACY_MSVCRT_COMPATIBILITY = @as(c_ulonglong, 0x0008);
//pub const _CRT_INTERNAL_PRINTF_LEGACY_THREE_DIGIT_EXPONENTS = @as(c_ulonglong, 0x0010);
//pub const _CRT_INTERNAL_SCANF_SECURECRT = @as(c_ulonglong, 0x0001);
//pub const _CRT_INTERNAL_SCANF_LEGACY_WIDE_SPECIFIERS = @as(c_ulonglong, 0x0002);
//pub const _CRT_INTERNAL_SCANF_LEGACY_MSVCRT_COMPATIBILITY = @as(c_ulonglong, 0x0004);
//pub const _CRT_INTERNAL_LOCAL_PRINTF_OPTIONS = _CRT_INTERNAL_PRINTF_LEGACY_WIDE_SPECIFIERS;
//pub const _CRT_INTERNAL_LOCAL_SCANF_OPTIONS = _CRT_INTERNAL_SCANF_LEGACY_WIDE_SPECIFIERS;
//pub const _INC_CORECRT_WSTDLIB = "";
//pub const WEOF = @import("std").zig.c_translation.cast(wint_t, @import("std").zig.c_translation.promoteIntLiteral(c_int, 0xFFFF, .hex));
//pub const _FILE_DEFINED = "";
//pub const _iob = __iob_func();
//pub const stdin = __acrt_iob_func(@as(c_int, 0));
//pub const stdout = __acrt_iob_func(@as(c_int, 1));
//pub const stderr = __acrt_iob_func(@as(c_int, 2));
//pub const _STDSTREAM_DEFINED = "";
//pub const _FSIZE_T_DEFINED = "";
//pub const _wfinddata_t = _wfinddata64i32_t;
//pub const _wfinddatai64_t = _wfinddata64_t;
//pub const _wfindfirst = _wfindfirst64i32;
//pub const _wfindnext = _wfindnext64i32;
//pub const _wfindfirsti64 = _wfindfirst64;
//pub const _wfindnexti64 = _wfindnext64;
//pub const _WFINDDATA_T_DEFINED = "";
//pub const _CRT_CTYPEDATA_DEFINED = "";
//pub const __PCTYPE_FUNC = __pctype_func();
//pub const _pctype = __pctype_func();
//pub const _CRT_WCTYPEDATA_DEFINED = "";
//pub const _wctype = __MINGW_IMP_SYMBOL(_wctype).*;
//pub inline fn __pwctype_func() @TypeOf(__MINGW_IMP_SYMBOL(_pwctype).*) {
//    return __MINGW_IMP_SYMBOL(_pwctype).*;
//}
//pub const _pwctype = __MINGW_IMP_SYMBOL(_pwctype).*;
//pub const _UPPER = @as(c_int, 0x1);
//pub const _LOWER = @as(c_int, 0x2);
//pub const _DIGIT = @as(c_int, 0x4);
//pub const _SPACE = @as(c_int, 0x8);
//pub const _PUNCT = @as(c_int, 0x10);
//pub const _CONTROL = @as(c_int, 0x20);
//pub const _BLANK = @as(c_int, 0x40);
//pub const _HEX = @as(c_int, 0x80);
//pub const _LEADBYTE = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x8000, .hex);
//pub const _ALPHA = (@as(c_int, 0x0100) | _UPPER) | _LOWER;
//pub const _WCTYPE_DEFINED = "";
//pub const _WDIRECT_DEFINED = "";
//pub const _WIO_DEFINED = "";
//pub const _WLOCALE_DEFINED = "";
//pub const _WEXEC_DEFINED = "";
//pub const _WSPAWN_DEFINED = "";
//pub const _CRT_WSYSTEM_DEFINED = "";
//pub const _WCTYPE_INLINE_DEFINED = "";
//pub const _INO_T_DEFINED = "";
//pub const _DEV_T_DEFINED = "";
//pub const _OFF_T_DEFINED = "";
//pub const _OFF_T_ = "";
//pub const _OFF64_T_DEFINED = "";
//pub const _FILE_OFFSET_BITS_SET_OFFT = "";
//pub const _fstat = @compileError("unable to translate macro: undefined identifier `_fstat64i32`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_stat64.h:17:9
//pub const _fstati64 = @compileError("unable to translate macro: undefined identifier `_fstat64`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_stat64.h:18:9
//pub const _stat = _stat64i32;
//pub const _stati64 = _stat64;
//pub const _wstat = _wstat64i32;
//pub const _wstati64 = _wstat64;
//pub const __stat64 = _stat64;
//pub const stat64 = _stat64;
//pub const fstat64 = @compileError("unable to translate macro: undefined identifier `_fstat64`");
//// C:\Users\tearb\bin\zig\0.13.0\files\lib\libc\include\any-windows-any/_mingw_stat64.h:99:9
//pub const _STAT_DEFINED = "";
//pub const _WSTAT_DEFINED = "";
//pub const _WCONIO_DEFINED = "";
//pub const _WSTDIO_DEFINED = "";
//pub const _INC_SWPRINTF_INL = "";
//pub const _CRT_WPERROR_DEFINED = "";
//pub const wpopen = _wpopen;
//pub inline fn _putwc_nolock(_c: anytype, _stm: anytype) @TypeOf(_fputwc_nolock(_c, _stm)) {
//    _ = &_c;
//    _ = &_stm;
//    return _fputwc_nolock(_c, _stm);
//}
//pub inline fn _getwc_nolock(_c: anytype) @TypeOf(_fgetwc_nolock(_c)) {
//    _ = &_c;
//    return _fgetwc_nolock(_c);
//}
//pub const _WSTDLIB_DEFINED = "";
//pub const _WSTDLIBP_DEFINED = "";
//pub const _TM_DEFINED = "";
//pub const _WTIME_DEFINED = "";
//pub const _INC_WTIME_INL = "";
//pub const _INC_WTIME_S_INL = "";
//pub const __MINGW_MBWC_CONVERT_DEFINED = "";
//pub const _INC_WCHAR_S = "";
//pub const _WIO_S_DEFINED = "";
//pub const _WCONIO_S_DEFINED = "";
//pub const _WSTDIO_S_DEFINED = "";
//pub const _WTIME_S_DEFINED = "";
//pub const alloca = @compileError("unable to translate macro: undefined identifier `__builtin_alloca`");
//// ./include/SDL3/SDL_stdinc.h:59:12
//pub const SDL_SIZE_MAX = SIZE_MAX;
//pub inline fn SDL_HAS_BUILTIN(x: anytype) @TypeOf(__has_builtin(x)) {
//    _ = &x;
//    return __has_builtin(x);
//}
//pub const SDL_arraysize = @compileError("unable to translate C expr: expected ')' instead got '['");
//// ./include/SDL3/SDL_stdinc.h:105:9
//pub const SDL_STRINGIFY_ARG = @compileError("unable to translate C expr: unexpected token '#'");
//// ./include/SDL3/SDL_stdinc.h:118:9
//pub const SDL_reinterpret_cast = @import("std").zig.c_translation.Macros.CAST_OR_CALL;
//pub const SDL_static_cast = @import("std").zig.c_translation.Macros.CAST_OR_CALL;
//pub const SDL_const_cast = @import("std").zig.c_translation.Macros.CAST_OR_CALL;
//pub inline fn SDL_FOURCC(A: anytype, B: anytype, C: anytype, D: anytype) @TypeOf((((SDL_static_cast(Uint32, SDL_static_cast(Uint8, A)) << @as(c_int, 0)) | (SDL_static_cast(Uint32, SDL_static_cast(Uint8, B)) << @as(c_int, 8))) | (SDL_static_cast(Uint32, SDL_static_cast(Uint8, C)) << @as(c_int, 16))) | (SDL_static_cast(Uint32, SDL_static_cast(Uint8, D)) << @as(c_int, 24))) {
//    _ = &A;
//    _ = &B;
//    _ = &C;
//    _ = &D;
//    return (((SDL_static_cast(Uint32, SDL_static_cast(Uint8, A)) << @as(c_int, 0)) | (SDL_static_cast(Uint32, SDL_static_cast(Uint8, B)) << @as(c_int, 8))) | (SDL_static_cast(Uint32, SDL_static_cast(Uint8, C)) << @as(c_int, 16))) | (SDL_static_cast(Uint32, SDL_static_cast(Uint8, D)) << @as(c_int, 24));
//}
//pub inline fn SDL_SINT64_C(c: anytype) @TypeOf(INT64_C(c)) {
//    _ = &c;
//    return INT64_C(c);
//}
//pub inline fn SDL_UINT64_C(c: anytype) @TypeOf(UINT64_C(c)) {
//    _ = &c;
//    return UINT64_C(c);
//}
//pub const SDL_FALSE = @"false";
//pub const SDL_TRUE = @"true";
//pub const SDL_MAX_SINT8 = @import("std").zig.c_translation.cast(Sint8, @as(c_int, 0x7F));
//pub const SDL_MIN_SINT8 = @import("std").zig.c_translation.cast(Sint8, ~@as(c_int, 0x7F));
//pub const SDL_MAX_UINT8 = @import("std").zig.c_translation.cast(Uint8, @as(c_int, 0xFF));
//pub const SDL_MIN_UINT8 = @import("std").zig.c_translation.cast(Uint8, @as(c_int, 0x00));
//pub const SDL_MAX_SINT16 = @import("std").zig.c_translation.cast(Sint16, @as(c_int, 0x7FFF));
//pub const SDL_MIN_SINT16 = @import("std").zig.c_translation.cast(Sint16, ~@as(c_int, 0x7FFF));
//pub const SDL_MAX_UINT16 = @import("std").zig.c_translation.cast(Uint16, @import("std").zig.c_translation.promoteIntLiteral(c_int, 0xFFFF, .hex));
//pub const SDL_MIN_UINT16 = @import("std").zig.c_translation.cast(Uint16, @as(c_int, 0x0000));
//pub const SDL_MAX_SINT32 = @import("std").zig.c_translation.cast(Sint32, @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x7FFFFFFF, .hex));
//pub const SDL_MIN_SINT32 = @import("std").zig.c_translation.cast(Sint32, ~@import("std").zig.c_translation.promoteIntLiteral(c_int, 0x7FFFFFFF, .hex));
//pub const SDL_MAX_UINT32 = @import("std").zig.c_translation.cast(Uint32, @import("std").zig.c_translation.promoteIntLiteral(c_uint, 0xFFFFFFFF, .hex));
//pub const SDL_MIN_UINT32 = @import("std").zig.c_translation.cast(Uint32, @as(c_int, 0x00000000));
//pub const SDL_MAX_SINT64 = SDL_SINT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 0x7FFFFFFFFFFFFFFF, .hex));
//pub const SDL_MIN_SINT64 = ~SDL_SINT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 0x7FFFFFFFFFFFFFFF, .hex));
//pub const SDL_MAX_UINT64 = SDL_UINT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 0xFFFFFFFFFFFFFFFF, .hex));
//pub const SDL_MIN_UINT64 = SDL_UINT64_C(@as(c_int, 0x0000000000000000));
//pub const SDL_MAX_TIME = SDL_MAX_SINT64;
//pub const SDL_MIN_TIME = SDL_MIN_SINT64;
//pub const SDL_FLT_EPSILON = @as(f32, 1.1920928955078125e-07);
//pub const SDL_PRIs64 = "I64d";
//pub const SDL_PRIu64 = "I64u";
//pub const SDL_PRIx64 = "I64x";
//pub const SDL_PRIX64 = "I64X";
//pub const SDL_PRIs32 = PRId32;
//pub const SDL_PRIu32 = PRIu32;
//pub const SDL_PRIx32 = PRIx32;
//pub const SDL_PRIX32 = PRIX32;
//pub const SDL_IN_BYTECAP = @compileError("unable to translate C expr: unexpected token ''");
//// ./include/SDL3/SDL_stdinc.h:526:9
//pub const SDL_INOUT_Z_CAP = @compileError("unable to translate C expr: unexpected token ''");
//// ./include/SDL3/SDL_stdinc.h:527:9
//pub const SDL_OUT_Z_CAP = @compileError("unable to translate C expr: unexpected token ''");
//// ./include/SDL3/SDL_stdinc.h:528:9
//pub const SDL_OUT_CAP = @compileError("unable to translate C expr: unexpected token ''");
//// ./include/SDL3/SDL_stdinc.h:529:9
//pub const SDL_OUT_BYTECAP = @compileError("unable to translate C expr: unexpected token ''");
//// ./include/SDL3/SDL_stdinc.h:530:9
//pub const SDL_OUT_Z_BYTECAP = @compileError("unable to translate C expr: unexpected token ''");
//// ./include/SDL3/SDL_stdinc.h:531:9
//pub const SDL_PRINTF_FORMAT_STRING = "";
//pub const SDL_SCANF_FORMAT_STRING = "";
//pub const SDL_PRINTF_VARARG_FUNC = @compileError("unable to translate macro: undefined identifier `format`");
//// ./include/SDL3/SDL_stdinc.h:536:9
//pub const SDL_PRINTF_VARARG_FUNCV = @compileError("unable to translate macro: undefined identifier `format`");
//// ./include/SDL3/SDL_stdinc.h:537:9
//pub const SDL_SCANF_VARARG_FUNC = @compileError("unable to translate macro: undefined identifier `format`");
//// ./include/SDL3/SDL_stdinc.h:538:9
//pub const SDL_SCANF_VARARG_FUNCV = @compileError("unable to translate macro: undefined identifier `format`");
//// ./include/SDL3/SDL_stdinc.h:539:9
//pub const SDL_WPRINTF_VARARG_FUNC = @compileError("unable to translate C expr: unexpected token ''");
//// ./include/SDL3/SDL_stdinc.h:540:9
//pub const SDL_WPRINTF_VARARG_FUNCV = @compileError("unable to translate C expr: unexpected token ''");
//// ./include/SDL3/SDL_stdinc.h:541:9
//pub const SDL_COMPILE_TIME_ASSERT = @compileError("unable to translate C expr: unexpected token '_Static_assert'");
//// ./include/SDL3/SDL_stdinc.h:561:9
//pub const SDL_begin_code_h = "";
//pub const SDL_DEPRECATED = @compileError("unable to translate macro: undefined identifier `deprecated`");
//// ./include/SDL3/SDL_begin_code.h:38:13
//pub const SDL_UNUSED = @compileError("unable to translate macro: undefined identifier `unused`");
//// ./include/SDL3/SDL_begin_code.h:48:13
//pub const SDL_DECLSPEC = "";
//pub const SDLCALL = "";
//pub const SDL_INLINE = @compileError("unable to translate C expr: unexpected token '__inline__'");
//// ./include/SDL3/SDL_begin_code.h:105:9
//pub const SDL_FORCE_INLINE = @compileError("unable to translate macro: undefined identifier `always_inline`");
//// ./include/SDL3/SDL_begin_code.h:126:9
//pub const SDL_NORETURN = @compileError("unable to translate macro: undefined identifier `noreturn`");
//// ./include/SDL3/SDL_begin_code.h:134:9
//pub const SDL_ANALYZER_NORETURN = @compileError("unable to translate macro: undefined identifier `analyzer_noreturn`");
//// ./include/SDL3/SDL_begin_code.h:144:9
//pub const SDL_HAS_FALLTHROUGH = @compileError("unable to translate macro: undefined identifier `__has_attribute`");
//// ./include/SDL3/SDL_begin_code.h:169:9
//pub const SDL_FALLTHROUGH = @compileError("unable to translate macro: undefined identifier `__fallthrough__`");
//// ./include/SDL3/SDL_begin_code.h:176:9
//pub const SDL_NODISCARD = @compileError("unable to translate macro: undefined identifier `warn_unused_result`");
//// ./include/SDL3/SDL_begin_code.h:189:9
//pub const SDL_MALLOC = @compileError("unable to translate macro: undefined identifier `malloc`");
//// ./include/SDL3/SDL_begin_code.h:199:9
//pub const SDL_ALLOC_SIZE = @compileError("unable to translate macro: undefined identifier `alloc_size`");
//// ./include/SDL3/SDL_begin_code.h:211:9
//pub const SDL_ALLOC_SIZE2 = @compileError("unable to translate macro: undefined identifier `alloc_size`");
//// ./include/SDL3/SDL_begin_code.h:221:9
//pub const SDL_INIT_INTERFACE = @compileError("unable to translate C expr: unexpected token 'do'");
//// ./include/SDL3/SDL_stdinc.h:658:9
//pub const SDL_stack_alloc = @compileError("unable to translate C expr: unexpected token ')'");
//// ./include/SDL3/SDL_stdinc.h:666:9
//pub const SDL_stack_free = @compileError("unable to translate C expr: unexpected token ''");
//// ./include/SDL3/SDL_stdinc.h:667:9
//pub inline fn SDL_min(x: anytype, y: anytype) @TypeOf(if (x < y) x else y) {
//    _ = &x;
//    _ = &y;
//    return if (x < y) x else y;
//}
//pub inline fn SDL_max(x: anytype, y: anytype) @TypeOf(if (x > y) x else y) {
//    _ = &x;
//    _ = &y;
//    return if (x > y) x else y;
//}
//pub inline fn SDL_clamp(x: anytype, a: anytype, b: anytype) @TypeOf(if (x < a) a else if (x > b) b else x) {
//    _ = &x;
//    _ = &a;
//    _ = &b;
//    return if (x < a) a else if (x > b) b else x;
//}
//pub const SDL_copyp = @compileError("unable to translate C expr: unexpected token '{'");
//// ./include/SDL3/SDL_stdinc.h:1471:9
//pub const SDL_zero = @compileError("unable to translate C expr: unexpected token '('");
//// ./include/SDL3/SDL_stdinc.h:1513:9
//pub const SDL_zerop = @compileError("unable to translate C expr: unexpected token '*'");
//// ./include/SDL3/SDL_stdinc.h:1514:9
//pub const SDL_zeroa = @compileError("unable to translate C expr: unexpected token '('");
//// ./include/SDL3/SDL_stdinc.h:1515:9
//pub const SDL_INVALID_UNICODE_CODEPOINT = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0xFFFD, .hex);
//pub const SDL_PI_D = @as(f64, 3.141592653589793238462643383279502884);
//pub const SDL_PI_F = @as(f32, 3.141592653589793238462643383279502884);
//pub const SDL_ICONV_ERROR = @import("std").zig.c_translation.cast(usize, -@as(c_int, 1));
//pub const SDL_ICONV_E2BIG = @import("std").zig.c_translation.cast(usize, -@as(c_int, 2));
//pub const SDL_ICONV_EILSEQ = @import("std").zig.c_translation.cast(usize, -@as(c_int, 3));
//pub const SDL_ICONV_EINVAL = @import("std").zig.c_translation.cast(usize, -@as(c_int, 4));
//pub inline fn SDL_iconv_utf8_locale(S: anytype) @TypeOf(SDL_iconv_string("", "UTF-8", S, SDL_strlen(S) + @as(c_int, 1))) {
//    _ = &S;
//    return SDL_iconv_string("", "UTF-8", S, SDL_strlen(S) + @as(c_int, 1));
//}
//pub inline fn SDL_iconv_utf8_ucs2(S: anytype) [*c]Uint16 {
//    _ = &S;
//    return @import("std").zig.c_translation.cast([*c]Uint16, SDL_iconv_string("UCS-2", "UTF-8", S, SDL_strlen(S) + @as(c_int, 1)));
//}
//pub inline fn SDL_iconv_utf8_ucs4(S: anytype) [*c]Uint32 {
//    _ = &S;
//    return @import("std").zig.c_translation.cast([*c]Uint32, SDL_iconv_string("UCS-4", "UTF-8", S, SDL_strlen(S) + @as(c_int, 1)));
//}
//pub inline fn SDL_iconv_wchar_utf8(S: anytype) @TypeOf(SDL_iconv_string("UTF-8", "WCHAR_T", @import("std").zig.c_translation.cast([*c]u8, S), (SDL_wcslen(S) + @as(c_int, 1)) * @import("std").zig.c_translation.sizeof(wchar_t))) {
//    _ = &S;
//    return SDL_iconv_string("UTF-8", "WCHAR_T", @import("std").zig.c_translation.cast([*c]u8, S), (SDL_wcslen(S) + @as(c_int, 1)) * @import("std").zig.c_translation.sizeof(wchar_t));
//}
//pub const SDL_pixels_h_ = "";
//pub const SDL_error_h_ = "";
//pub inline fn SDL_Unsupported() @TypeOf(SDL_SetError("That operation is not supported")) {
//    return SDL_SetError("That operation is not supported");
//}
//pub inline fn SDL_InvalidParamError(param: anytype) @TypeOf(SDL_SetError("Parameter '%s' is invalid", param)) {
//    _ = &param;
//    return SDL_SetError("Parameter '%s' is invalid", param);
//}
//pub const SDL_endian_h_ = "";
//pub const SDL_LIL_ENDIAN = @as(c_int, 1234);
//pub const SDL_BIG_ENDIAN = @as(c_int, 4321);
//pub const SDL_BYTEORDER = SDL_LIL_ENDIAN;
//pub const SDL_FLOATWORDORDER = SDL_BYTEORDER;
//pub const HAS_BUILTIN_BSWAP16 = (SDL_HAS_BUILTIN(__builtin_bswap16) != 0) or ((__GNUC__ > @as(c_int, 4)) or ((__GNUC__ == @as(c_int, 4)) and (__GNUC_MINOR__ >= @as(c_int, 8))));
//pub const HAS_BUILTIN_BSWAP32 = (SDL_HAS_BUILTIN(__builtin_bswap32) != 0) or ((__GNUC__ > @as(c_int, 4)) or ((__GNUC__ == @as(c_int, 4)) and (__GNUC_MINOR__ >= @as(c_int, 3))));
//pub const HAS_BUILTIN_BSWAP64 = (SDL_HAS_BUILTIN(__builtin_bswap64) != 0) or ((__GNUC__ > @as(c_int, 4)) or ((__GNUC__ == @as(c_int, 4)) and (__GNUC_MINOR__ >= @as(c_int, 3))));
//pub const HAS_BROKEN_BSWAP = (__GNUC__ == @as(c_int, 2)) and (__GNUC_MINOR__ <= @as(c_int, 95));
//pub inline fn SDL_Swap16(x: anytype) @TypeOf(__builtin_bswap16(x)) {
//    _ = &x;
//    return __builtin_bswap16(x);
//}
//pub inline fn SDL_Swap32(x: anytype) @TypeOf(__builtin_bswap32(x)) {
//    _ = &x;
//    return __builtin_bswap32(x);
//}
//pub inline fn SDL_Swap64(x: anytype) @TypeOf(__builtin_bswap64(x)) {
//    _ = &x;
//    return __builtin_bswap64(x);
//}
//pub inline fn SDL_Swap16LE(x: anytype) @TypeOf(x) {
//    _ = &x;
//    return x;
//}
//pub inline fn SDL_Swap32LE(x: anytype) @TypeOf(x) {
//    _ = &x;
//    return x;
//}
//pub inline fn SDL_Swap64LE(x: anytype) @TypeOf(x) {
//    _ = &x;
//    return x;
//}
//pub inline fn SDL_SwapFloatLE(x: anytype) @TypeOf(x) {
//    _ = &x;
//    return x;
//}
//pub inline fn SDL_Swap16BE(x: anytype) @TypeOf(SDL_Swap16(x)) {
//    _ = &x;
//    return SDL_Swap16(x);
//}
//pub inline fn SDL_Swap32BE(x: anytype) @TypeOf(SDL_Swap32(x)) {
//    _ = &x;
//    return SDL_Swap32(x);
//}
//pub inline fn SDL_Swap64BE(x: anytype) @TypeOf(SDL_Swap64(x)) {
//    _ = &x;
//    return SDL_Swap64(x);
//}
//pub inline fn SDL_SwapFloatBE(x: anytype) @TypeOf(SDL_SwapFloat(x)) {
//    _ = &x;
//    return SDL_SwapFloat(x);
//}
//pub const SDL_ALPHA_OPAQUE = @as(c_int, 255);
//pub const SDL_ALPHA_OPAQUE_FLOAT = @as(f32, 1.0);
//pub const SDL_ALPHA_TRANSPARENT = @as(c_int, 0);
//pub const SDL_ALPHA_TRANSPARENT_FLOAT = @as(f32, 0.0);
//pub inline fn SDL_DEFINE_PIXELFOURCC(A: anytype, B: anytype, C: anytype, D: anytype) @TypeOf(SDL_FOURCC(A, B, C, D)) {
//    _ = &A;
//    _ = &B;
//    _ = &C;
//    _ = &D;
//    return SDL_FOURCC(A, B, C, D);
//}
//pub inline fn SDL_DEFINE_PIXELFORMAT(@"type": anytype, order: anytype, layout: anytype, bits: anytype, bytes: anytype) @TypeOf((((((@as(c_int, 1) << @as(c_int, 28)) | (@"type" << @as(c_int, 24))) | (order << @as(c_int, 20))) | (layout << @as(c_int, 16))) | (bits << @as(c_int, 8))) | (bytes << @as(c_int, 0))) {
//    _ = &@"type";
//    _ = &order;
//    _ = &layout;
//    _ = &bits;
//    _ = &bytes;
//    return (((((@as(c_int, 1) << @as(c_int, 28)) | (@"type" << @as(c_int, 24))) | (order << @as(c_int, 20))) | (layout << @as(c_int, 16))) | (bits << @as(c_int, 8))) | (bytes << @as(c_int, 0));
//}
//pub inline fn SDL_PIXELFLAG(X: anytype) @TypeOf((X >> @as(c_int, 28)) & @as(c_int, 0x0F)) {
//    _ = &X;
//    return (X >> @as(c_int, 28)) & @as(c_int, 0x0F);
//}
//pub inline fn SDL_PIXELTYPE(X: anytype) @TypeOf((X >> @as(c_int, 24)) & @as(c_int, 0x0F)) {
//    _ = &X;
//    return (X >> @as(c_int, 24)) & @as(c_int, 0x0F);
//}
//pub inline fn SDL_PIXELORDER(X: anytype) @TypeOf((X >> @as(c_int, 20)) & @as(c_int, 0x0F)) {
//    _ = &X;
//    return (X >> @as(c_int, 20)) & @as(c_int, 0x0F);
//}
//pub inline fn SDL_PIXELLAYOUT(X: anytype) @TypeOf((X >> @as(c_int, 16)) & @as(c_int, 0x0F)) {
//    _ = &X;
//    return (X >> @as(c_int, 16)) & @as(c_int, 0x0F);
//}
//pub inline fn SDL_BITSPERPIXEL(X: anytype) @TypeOf(if (SDL_ISPIXELFORMAT_FOURCC(X)) @as(c_int, 0) else (X >> @as(c_int, 8)) & @as(c_int, 0xFF)) {
//    _ = &X;
//    return if (SDL_ISPIXELFORMAT_FOURCC(X)) @as(c_int, 0) else (X >> @as(c_int, 8)) & @as(c_int, 0xFF);
//}
//pub inline fn SDL_BYTESPERPIXEL(X: anytype) @TypeOf(if (SDL_ISPIXELFORMAT_FOURCC(X)) if ((((X == SDL_PIXELFORMAT_YUY2) or (X == SDL_PIXELFORMAT_UYVY)) or (X == SDL_PIXELFORMAT_YVYU)) or (X == SDL_PIXELFORMAT_P010)) @as(c_int, 2) else @as(c_int, 1) else (X >> @as(c_int, 0)) & @as(c_int, 0xFF)) {
//    _ = &X;
//    return if (SDL_ISPIXELFORMAT_FOURCC(X)) if ((((X == SDL_PIXELFORMAT_YUY2) or (X == SDL_PIXELFORMAT_UYVY)) or (X == SDL_PIXELFORMAT_YVYU)) or (X == SDL_PIXELFORMAT_P010)) @as(c_int, 2) else @as(c_int, 1) else (X >> @as(c_int, 0)) & @as(c_int, 0xFF);
//}
//pub inline fn SDL_ISPIXELFORMAT_INDEXED(format: anytype) @TypeOf(!(SDL_ISPIXELFORMAT_FOURCC(format) != 0) and ((((SDL_PIXELTYPE(format) == SDL_PIXELTYPE_INDEX1) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_INDEX2)) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_INDEX4)) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_INDEX8))) {
//    _ = &format;
//    return !(SDL_ISPIXELFORMAT_FOURCC(format) != 0) and ((((SDL_PIXELTYPE(format) == SDL_PIXELTYPE_INDEX1) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_INDEX2)) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_INDEX4)) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_INDEX8));
//}
//pub inline fn SDL_ISPIXELFORMAT_PACKED(format: anytype) @TypeOf(!(SDL_ISPIXELFORMAT_FOURCC(format) != 0) and (((SDL_PIXELTYPE(format) == SDL_PIXELTYPE_PACKED8) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_PACKED16)) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_PACKED32))) {
//    _ = &format;
//    return !(SDL_ISPIXELFORMAT_FOURCC(format) != 0) and (((SDL_PIXELTYPE(format) == SDL_PIXELTYPE_PACKED8) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_PACKED16)) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_PACKED32));
//}
//pub inline fn SDL_ISPIXELFORMAT_ARRAY(format: anytype) @TypeOf(!(SDL_ISPIXELFORMAT_FOURCC(format) != 0) and (((((SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYU8) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYU16)) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYU32)) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYF16)) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYF32))) {
//    _ = &format;
//    return !(SDL_ISPIXELFORMAT_FOURCC(format) != 0) and (((((SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYU8) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYU16)) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYU32)) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYF16)) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYF32));
//}
//pub inline fn SDL_ISPIXELFORMAT_ALPHA(format: anytype) @TypeOf((SDL_ISPIXELFORMAT_PACKED(format) != 0) and ((((SDL_PIXELORDER(format) == SDL_PACKEDORDER_ARGB) or (SDL_PIXELORDER(format) == SDL_PACKEDORDER_RGBA)) or (SDL_PIXELORDER(format) == SDL_PACKEDORDER_ABGR)) or (SDL_PIXELORDER(format) == SDL_PACKEDORDER_BGRA))) {
//    _ = &format;
//    return (SDL_ISPIXELFORMAT_PACKED(format) != 0) and ((((SDL_PIXELORDER(format) == SDL_PACKEDORDER_ARGB) or (SDL_PIXELORDER(format) == SDL_PACKEDORDER_RGBA)) or (SDL_PIXELORDER(format) == SDL_PACKEDORDER_ABGR)) or (SDL_PIXELORDER(format) == SDL_PACKEDORDER_BGRA));
//}
//pub inline fn SDL_ISPIXELFORMAT_10BIT(format: anytype) @TypeOf(!(SDL_ISPIXELFORMAT_FOURCC(format) != 0) and ((SDL_PIXELTYPE(format) == SDL_PIXELTYPE_PACKED32) and (SDL_PIXELLAYOUT(format) == SDL_PACKEDLAYOUT_2101010))) {
//    _ = &format;
//    return !(SDL_ISPIXELFORMAT_FOURCC(format) != 0) and ((SDL_PIXELTYPE(format) == SDL_PIXELTYPE_PACKED32) and (SDL_PIXELLAYOUT(format) == SDL_PACKEDLAYOUT_2101010));
//}
//pub inline fn SDL_ISPIXELFORMAT_FLOAT(format: anytype) @TypeOf(!(SDL_ISPIXELFORMAT_FOURCC(format) != 0) and ((SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYF16) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYF32))) {
//    _ = &format;
//    return !(SDL_ISPIXELFORMAT_FOURCC(format) != 0) and ((SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYF16) or (SDL_PIXELTYPE(format) == SDL_PIXELTYPE_ARRAYF32));
//}
//pub inline fn SDL_ISPIXELFORMAT_FOURCC(format: anytype) @TypeOf((format != 0) and (SDL_PIXELFLAG(format) != @as(c_int, 1))) {
//    _ = &format;
//    return (format != 0) and (SDL_PIXELFLAG(format) != @as(c_int, 1));
//}
//pub const SDL_PIXELFORMAT_RGBA32 = SDL_PIXELFORMAT_ABGR8888;
//pub const SDL_PIXELFORMAT_ARGB32 = SDL_PIXELFORMAT_BGRA8888;
//pub const SDL_PIXELFORMAT_BGRA32 = SDL_PIXELFORMAT_ARGB8888;
//pub const SDL_PIXELFORMAT_ABGR32 = SDL_PIXELFORMAT_RGBA8888;
//pub const SDL_PIXELFORMAT_RGBX32 = SDL_PIXELFORMAT_XBGR8888;
//pub const SDL_PIXELFORMAT_XRGB32 = SDL_PIXELFORMAT_BGRX8888;
//pub const SDL_PIXELFORMAT_BGRX32 = SDL_PIXELFORMAT_XRGB8888;
//pub const SDL_PIXELFORMAT_XBGR32 = SDL_PIXELFORMAT_RGBX8888;
//pub inline fn SDL_DEFINE_COLORSPACE(@"type": anytype, range: anytype, primaries: anytype, transfer: anytype, matrix: anytype, chroma: anytype) @TypeOf((((((@import("std").zig.c_translation.cast(Uint32, @"type") << @as(c_int, 28)) | (@import("std").zig.c_translation.cast(Uint32, range) << @as(c_int, 24))) | (@import("std").zig.c_translation.cast(Uint32, chroma) << @as(c_int, 20))) | (@import("std").zig.c_translation.cast(Uint32, primaries) << @as(c_int, 10))) | (@import("std").zig.c_translation.cast(Uint32, transfer) << @as(c_int, 5))) | (@import("std").zig.c_translation.cast(Uint32, matrix) << @as(c_int, 0))) {
//    _ = &@"type";
//    _ = &range;
//    _ = &primaries;
//    _ = &transfer;
//    _ = &matrix;
//    _ = &chroma;
//    return (((((@import("std").zig.c_translation.cast(Uint32, @"type") << @as(c_int, 28)) | (@import("std").zig.c_translation.cast(Uint32, range) << @as(c_int, 24))) | (@import("std").zig.c_translation.cast(Uint32, chroma) << @as(c_int, 20))) | (@import("std").zig.c_translation.cast(Uint32, primaries) << @as(c_int, 10))) | (@import("std").zig.c_translation.cast(Uint32, transfer) << @as(c_int, 5))) | (@import("std").zig.c_translation.cast(Uint32, matrix) << @as(c_int, 0));
//}
//pub inline fn SDL_COLORSPACETYPE(X: anytype) SDL_ColorType {
//    _ = &X;
//    return @import("std").zig.c_translation.cast(SDL_ColorType, (X >> @as(c_int, 28)) & @as(c_int, 0x0F));
//}
//pub inline fn SDL_COLORSPACERANGE(X: anytype) SDL_ColorRange {
//    _ = &X;
//    return @import("std").zig.c_translation.cast(SDL_ColorRange, (X >> @as(c_int, 24)) & @as(c_int, 0x0F));
//}
//pub inline fn SDL_COLORSPACECHROMA(X: anytype) SDL_ChromaLocation {
//    _ = &X;
//    return @import("std").zig.c_translation.cast(SDL_ChromaLocation, (X >> @as(c_int, 20)) & @as(c_int, 0x0F));
//}
//pub inline fn SDL_COLORSPACEPRIMARIES(X: anytype) SDL_ColorPrimaries {
//    _ = &X;
//    return @import("std").zig.c_translation.cast(SDL_ColorPrimaries, (X >> @as(c_int, 10)) & @as(c_int, 0x1F));
//}
//pub inline fn SDL_COLORSPACETRANSFER(X: anytype) SDL_TransferCharacteristics {
//    _ = &X;
//    return @import("std").zig.c_translation.cast(SDL_TransferCharacteristics, (X >> @as(c_int, 5)) & @as(c_int, 0x1F));
//}
//pub inline fn SDL_COLORSPACEMATRIX(X: anytype) SDL_MatrixCoefficients {
//    _ = &X;
//    return @import("std").zig.c_translation.cast(SDL_MatrixCoefficients, X & @as(c_int, 0x1F));
//}
//pub inline fn SDL_ISCOLORSPACE_MATRIX_BT601(X: anytype) @TypeOf((SDL_COLORSPACEMATRIX(X) == SDL_MATRIX_COEFFICIENTS_BT601) or (SDL_COLORSPACEMATRIX(X) == SDL_MATRIX_COEFFICIENTS_BT470BG)) {
//    _ = &X;
//    return (SDL_COLORSPACEMATRIX(X) == SDL_MATRIX_COEFFICIENTS_BT601) or (SDL_COLORSPACEMATRIX(X) == SDL_MATRIX_COEFFICIENTS_BT470BG);
//}
//pub inline fn SDL_ISCOLORSPACE_MATRIX_BT709(X: anytype) @TypeOf(SDL_COLORSPACEMATRIX(X) == SDL_MATRIX_COEFFICIENTS_BT709) {
//    _ = &X;
//    return SDL_COLORSPACEMATRIX(X) == SDL_MATRIX_COEFFICIENTS_BT709;
//}
//pub inline fn SDL_ISCOLORSPACE_MATRIX_BT2020_NCL(X: anytype) @TypeOf(SDL_COLORSPACEMATRIX(X) == SDL_MATRIX_COEFFICIENTS_BT2020_NCL) {
//    _ = &X;
//    return SDL_COLORSPACEMATRIX(X) == SDL_MATRIX_COEFFICIENTS_BT2020_NCL;
//}
//pub inline fn SDL_ISCOLORSPACE_LIMITED_RANGE(X: anytype) @TypeOf(SDL_COLORSPACERANGE(X) != SDL_COLOR_RANGE_FULL) {
//    _ = &X;
//    return SDL_COLORSPACERANGE(X) != SDL_COLOR_RANGE_FULL;
//}
//pub inline fn SDL_ISCOLORSPACE_FULL_RANGE(X: anytype) @TypeOf(SDL_COLORSPACERANGE(X) == SDL_COLOR_RANGE_FULL) {
//    _ = &X;
//    return SDL_COLORSPACERANGE(X) == SDL_COLOR_RANGE_FULL;
//}
//pub const SDL_COLORSPACE_RGB_DEFAULT = SDL_COLORSPACE_SRGB;
//pub const SDL_COLORSPACE_YUV_DEFAULT = SDL_COLORSPACE_JPEG;
//pub const SDL_properties_h_ = "";
//pub const SDL_rect_h_ = "";
//pub const SDL_surface_h_ = "";
//pub const SDL_blendmode_h_ = "";
//pub const SDL_BLENDMODE_NONE = @as(c_uint, 0x00000000);
//pub const SDL_BLENDMODE_BLEND = @as(c_uint, 0x00000001);
//pub const SDL_BLENDMODE_BLEND_PREMULTIPLIED = @as(c_uint, 0x00000010);
//pub const SDL_BLENDMODE_ADD = @as(c_uint, 0x00000002);
//pub const SDL_BLENDMODE_ADD_PREMULTIPLIED = @as(c_uint, 0x00000020);
//pub const SDL_BLENDMODE_MOD = @as(c_uint, 0x00000004);
//pub const SDL_BLENDMODE_MUL = @as(c_uint, 0x00000008);
//pub const SDL_BLENDMODE_INVALID = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 0x7FFFFFFF, .hex);
//pub const SDL_iostream_h_ = "";
//pub const SDL_PROP_IOSTREAM_WINDOWS_HANDLE_POINTER = "SDL.iostream.windows.handle";
//pub const SDL_PROP_IOSTREAM_STDIO_FILE_POINTER = "SDL.iostream.stdio.file";
//pub const SDL_PROP_IOSTREAM_FILE_DESCRIPTOR_NUMBER = "SDL.iostream.file_descriptor";
//pub const SDL_PROP_IOSTREAM_ANDROID_AASSET_POINTER = "SDL.iostream.android.aasset";
//pub const SDL_PROP_IOSTREAM_DYNAMIC_MEMORY_POINTER = "SDL.iostream.dynamic.memory";
//pub const SDL_PROP_IOSTREAM_DYNAMIC_CHUNKSIZE_NUMBER = "SDL.iostream.dynamic.chunksize";
//pub const SDL_SURFACE_PREALLOCATED = @as(c_uint, 0x00000001);
//pub const SDL_SURFACE_LOCK_NEEDED = @as(c_uint, 0x00000002);
//pub const SDL_SURFACE_LOCKED = @as(c_uint, 0x00000004);
//pub const SDL_SURFACE_SIMD_ALIGNED = @as(c_uint, 0x00000008);
//pub inline fn SDL_MUSTLOCK(S: anytype) @TypeOf((S.*.flags & SDL_SURFACE_LOCK_NEEDED) == SDL_SURFACE_LOCK_NEEDED) {
//    _ = &S;
//    return (S.*.flags & SDL_SURFACE_LOCK_NEEDED) == SDL_SURFACE_LOCK_NEEDED;
//}
//pub const SDL_PROP_SURFACE_SDR_WHITE_POINT_FLOAT = "SDL.surface.SDR_white_point";
//pub const SDL_PROP_SURFACE_HDR_HEADROOM_FLOAT = "SDL.surface.HDR_headroom";
//pub const SDL_PROP_SURFACE_TONEMAP_OPERATOR_STRING = "SDL.surface.tonemap";
//pub const SDL_video_h_ = "";
//pub const SDL_PROP_GLOBAL_VIDEO_WAYLAND_WL_DISPLAY_POINTER = "SDL.video.wayland.wl_display";
//pub const SDL_WINDOW_FULLSCREEN = SDL_UINT64_C(@as(c_int, 0x0000000000000001));
//pub const SDL_WINDOW_OPENGL = SDL_UINT64_C(@as(c_int, 0x0000000000000002));
//pub const SDL_WINDOW_OCCLUDED = SDL_UINT64_C(@as(c_int, 0x0000000000000004));
//pub const SDL_WINDOW_HIDDEN = SDL_UINT64_C(@as(c_int, 0x0000000000000008));
//pub const SDL_WINDOW_BORDERLESS = SDL_UINT64_C(@as(c_int, 0x0000000000000010));
//pub const SDL_WINDOW_RESIZABLE = SDL_UINT64_C(@as(c_int, 0x0000000000000020));
//pub const SDL_WINDOW_MINIMIZED = SDL_UINT64_C(@as(c_int, 0x0000000000000040));
//pub const SDL_WINDOW_MAXIMIZED = SDL_UINT64_C(@as(c_int, 0x0000000000000080));
//pub const SDL_WINDOW_MOUSE_GRABBED = SDL_UINT64_C(@as(c_int, 0x0000000000000100));
//pub const SDL_WINDOW_INPUT_FOCUS = SDL_UINT64_C(@as(c_int, 0x0000000000000200));
//pub const SDL_WINDOW_MOUSE_FOCUS = SDL_UINT64_C(@as(c_int, 0x0000000000000400));
//pub const SDL_WINDOW_EXTERNAL = SDL_UINT64_C(@as(c_int, 0x0000000000000800));
//pub const SDL_WINDOW_MODAL = SDL_UINT64_C(@as(c_int, 0x0000000000001000));
//pub const SDL_WINDOW_HIGH_PIXEL_DENSITY = SDL_UINT64_C(@as(c_int, 0x0000000000002000));
//pub const SDL_WINDOW_MOUSE_CAPTURE = SDL_UINT64_C(@as(c_int, 0x0000000000004000));
//pub const SDL_WINDOW_MOUSE_RELATIVE_MODE = SDL_UINT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 0x0000000000008000, .hex));
//pub const SDL_WINDOW_ALWAYS_ON_TOP = SDL_UINT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 0x0000000000010000, .hex));
//pub const SDL_WINDOW_UTILITY = SDL_UINT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 0x0000000000020000, .hex));
//pub const SDL_WINDOW_TOOLTIP = SDL_UINT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 0x0000000000040000, .hex));
//pub const SDL_WINDOW_POPUP_MENU = SDL_UINT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 0x0000000000080000, .hex));
//pub const SDL_WINDOW_KEYBOARD_GRABBED = SDL_UINT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 0x0000000000100000, .hex));
//pub const SDL_WINDOW_VULKAN = SDL_UINT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 0x0000000010000000, .hex));
//pub const SDL_WINDOW_METAL = SDL_UINT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 0x0000000020000000, .hex));
//pub const SDL_WINDOW_TRANSPARENT = SDL_UINT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 0x0000000040000000, .hex));
//pub const SDL_WINDOW_NOT_FOCUSABLE = SDL_UINT64_C(@import("std").zig.c_translation.promoteIntLiteral(c_int, 0x0000000080000000, .hex));
//pub const SDL_WINDOWPOS_UNDEFINED_MASK = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 0x1FFF0000, .hex);
//pub inline fn SDL_WINDOWPOS_UNDEFINED_DISPLAY(X: anytype) @TypeOf(SDL_WINDOWPOS_UNDEFINED_MASK | X) {
//    _ = &X;
//    return SDL_WINDOWPOS_UNDEFINED_MASK | X;
//}
//pub const SDL_WINDOWPOS_UNDEFINED = SDL_WINDOWPOS_UNDEFINED_DISPLAY(@as(c_int, 0));
//pub inline fn SDL_WINDOWPOS_ISUNDEFINED(X: anytype) @TypeOf((X & @import("std").zig.c_translation.promoteIntLiteral(c_int, 0xFFFF0000, .hex)) == SDL_WINDOWPOS_UNDEFINED_MASK) {
//    _ = &X;
//    return (X & @import("std").zig.c_translation.promoteIntLiteral(c_int, 0xFFFF0000, .hex)) == SDL_WINDOWPOS_UNDEFINED_MASK;
//}
//pub const SDL_WINDOWPOS_CENTERED_MASK = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 0x2FFF0000, .hex);
//pub inline fn SDL_WINDOWPOS_CENTERED_DISPLAY(X: anytype) @TypeOf(SDL_WINDOWPOS_CENTERED_MASK | X) {
//    _ = &X;
//    return SDL_WINDOWPOS_CENTERED_MASK | X;
//}
//pub const SDL_WINDOWPOS_CENTERED = SDL_WINDOWPOS_CENTERED_DISPLAY(@as(c_int, 0));
//pub inline fn SDL_WINDOWPOS_ISCENTERED(X: anytype) @TypeOf((X & @import("std").zig.c_translation.promoteIntLiteral(c_int, 0xFFFF0000, .hex)) == SDL_WINDOWPOS_CENTERED_MASK) {
//    _ = &X;
//    return (X & @import("std").zig.c_translation.promoteIntLiteral(c_int, 0xFFFF0000, .hex)) == SDL_WINDOWPOS_CENTERED_MASK;
//}
//pub const SDL_PROP_DISPLAY_HDR_ENABLED_BOOLEAN = "SDL.display.HDR_enabled";
//pub const SDL_PROP_DISPLAY_KMSDRM_PANEL_ORIENTATION_NUMBER = "SDL.display.KMSDRM.panel_orientation";
//pub const SDL_PROP_WINDOW_CREATE_ALWAYS_ON_TOP_BOOLEAN = "SDL.window.create.always_on_top";
//pub const SDL_PROP_WINDOW_CREATE_BORDERLESS_BOOLEAN = "SDL.window.create.borderless";
//pub const SDL_PROP_WINDOW_CREATE_FOCUSABLE_BOOLEAN = "SDL.window.create.focusable";
//pub const SDL_PROP_WINDOW_CREATE_EXTERNAL_GRAPHICS_CONTEXT_BOOLEAN = "SDL.window.create.external_graphics_context";
//pub const SDL_PROP_WINDOW_CREATE_FLAGS_NUMBER = "SDL.window.create.flags";
//pub const SDL_PROP_WINDOW_CREATE_FULLSCREEN_BOOLEAN = "SDL.window.create.fullscreen";
//pub const SDL_PROP_WINDOW_CREATE_HEIGHT_NUMBER = "SDL.window.create.height";
//pub const SDL_PROP_WINDOW_CREATE_HIDDEN_BOOLEAN = "SDL.window.create.hidden";
//pub const SDL_PROP_WINDOW_CREATE_HIGH_PIXEL_DENSITY_BOOLEAN = "SDL.window.create.high_pixel_density";
//pub const SDL_PROP_WINDOW_CREATE_MAXIMIZED_BOOLEAN = "SDL.window.create.maximized";
//pub const SDL_PROP_WINDOW_CREATE_MENU_BOOLEAN = "SDL.window.create.menu";
//pub const SDL_PROP_WINDOW_CREATE_METAL_BOOLEAN = "SDL.window.create.metal";
//pub const SDL_PROP_WINDOW_CREATE_MINIMIZED_BOOLEAN = "SDL.window.create.minimized";
//pub const SDL_PROP_WINDOW_CREATE_MODAL_BOOLEAN = "SDL.window.create.modal";
//pub const SDL_PROP_WINDOW_CREATE_MOUSE_GRABBED_BOOLEAN = "SDL.window.create.mouse_grabbed";
//pub const SDL_PROP_WINDOW_CREATE_OPENGL_BOOLEAN = "SDL.window.create.opengl";
//pub const SDL_PROP_WINDOW_CREATE_PARENT_POINTER = "SDL.window.create.parent";
//pub const SDL_PROP_WINDOW_CREATE_RESIZABLE_BOOLEAN = "SDL.window.create.resizable";
//pub const SDL_PROP_WINDOW_CREATE_TITLE_STRING = "SDL.window.create.title";
//pub const SDL_PROP_WINDOW_CREATE_TRANSPARENT_BOOLEAN = "SDL.window.create.transparent";
//pub const SDL_PROP_WINDOW_CREATE_TOOLTIP_BOOLEAN = "SDL.window.create.tooltip";
//pub const SDL_PROP_WINDOW_CREATE_UTILITY_BOOLEAN = "SDL.window.create.utility";
//pub const SDL_PROP_WINDOW_CREATE_VULKAN_BOOLEAN = "SDL.window.create.vulkan";
//pub const SDL_PROP_WINDOW_CREATE_WIDTH_NUMBER = "SDL.window.create.width";
//pub const SDL_PROP_WINDOW_CREATE_X_NUMBER = "SDL.window.create.x";
//pub const SDL_PROP_WINDOW_CREATE_Y_NUMBER = "SDL.window.create.y";
//pub const SDL_PROP_WINDOW_CREATE_COCOA_WINDOW_POINTER = "SDL.window.create.cocoa.window";
//pub const SDL_PROP_WINDOW_CREATE_COCOA_VIEW_POINTER = "SDL.window.create.cocoa.view";
//pub const SDL_PROP_WINDOW_CREATE_WAYLAND_SURFACE_ROLE_CUSTOM_BOOLEAN = "SDL.window.create.wayland.surface_role_custom";
//pub const SDL_PROP_WINDOW_CREATE_WAYLAND_CREATE_EGL_WINDOW_BOOLEAN = "SDL.window.create.wayland.create_egl_window";
//pub const SDL_PROP_WINDOW_CREATE_WAYLAND_WL_SURFACE_POINTER = "SDL.window.create.wayland.wl_surface";
//pub const SDL_PROP_WINDOW_CREATE_WIN32_HWND_POINTER = "SDL.window.create.win32.hwnd";
//pub const SDL_PROP_WINDOW_CREATE_WIN32_PIXEL_FORMAT_HWND_POINTER = "SDL.window.create.win32.pixel_format_hwnd";
//pub const SDL_PROP_WINDOW_CREATE_X11_WINDOW_NUMBER = "SDL.window.create.x11.window";
//pub const SDL_PROP_WINDOW_SHAPE_POINTER = "SDL.window.shape";
//pub const SDL_PROP_WINDOW_HDR_ENABLED_BOOLEAN = "SDL.window.HDR_enabled";
//pub const SDL_PROP_WINDOW_SDR_WHITE_LEVEL_FLOAT = "SDL.window.SDR_white_level";
//pub const SDL_PROP_WINDOW_HDR_HEADROOM_FLOAT = "SDL.window.HDR_headroom";
//pub const SDL_PROP_WINDOW_ANDROID_WINDOW_POINTER = "SDL.window.android.window";
//pub const SDL_PROP_WINDOW_ANDROID_SURFACE_POINTER = "SDL.window.android.surface";
//pub const SDL_PROP_WINDOW_UIKIT_WINDOW_POINTER = "SDL.window.uikit.window";
//pub const SDL_PROP_WINDOW_UIKIT_METAL_VIEW_TAG_NUMBER = "SDL.window.uikit.metal_view_tag";
//pub const SDL_PROP_WINDOW_UIKIT_OPENGL_FRAMEBUFFER_NUMBER = "SDL.window.uikit.opengl.framebuffer";
//pub const SDL_PROP_WINDOW_UIKIT_OPENGL_RENDERBUFFER_NUMBER = "SDL.window.uikit.opengl.renderbuffer";
//pub const SDL_PROP_WINDOW_UIKIT_OPENGL_RESOLVE_FRAMEBUFFER_NUMBER = "SDL.window.uikit.opengl.resolve_framebuffer";
//pub const SDL_PROP_WINDOW_KMSDRM_DEVICE_INDEX_NUMBER = "SDL.window.kmsdrm.dev_index";
//pub const SDL_PROP_WINDOW_KMSDRM_DRM_FD_NUMBER = "SDL.window.kmsdrm.drm_fd";
//pub const SDL_PROP_WINDOW_KMSDRM_GBM_DEVICE_POINTER = "SDL.window.kmsdrm.gbm_dev";
//pub const SDL_PROP_WINDOW_COCOA_WINDOW_POINTER = "SDL.window.cocoa.window";
//pub const SDL_PROP_WINDOW_COCOA_METAL_VIEW_TAG_NUMBER = "SDL.window.cocoa.metal_view_tag";
//pub const SDL_PROP_WINDOW_VIVANTE_DISPLAY_POINTER = "SDL.window.vivante.display";
//pub const SDL_PROP_WINDOW_VIVANTE_WINDOW_POINTER = "SDL.window.vivante.window";
//pub const SDL_PROP_WINDOW_VIVANTE_SURFACE_POINTER = "SDL.window.vivante.surface";
//pub const SDL_PROP_WINDOW_WIN32_HWND_POINTER = "SDL.window.win32.hwnd";
//pub const SDL_PROP_WINDOW_WIN32_HDC_POINTER = "SDL.window.win32.hdc";
//pub const SDL_PROP_WINDOW_WIN32_INSTANCE_POINTER = "SDL.window.win32.instance";
//pub const SDL_PROP_WINDOW_WAYLAND_DISPLAY_POINTER = "SDL.window.wayland.display";
//pub const SDL_PROP_WINDOW_WAYLAND_SURFACE_POINTER = "SDL.window.wayland.surface";
//pub const SDL_PROP_WINDOW_WAYLAND_EGL_WINDOW_POINTER = "SDL.window.wayland.egl_window";
//pub const SDL_PROP_WINDOW_WAYLAND_XDG_SURFACE_POINTER = "SDL.window.wayland.xdg_surface";
//pub const SDL_PROP_WINDOW_WAYLAND_XDG_TOPLEVEL_POINTER = "SDL.window.wayland.xdg_toplevel";
//pub const SDL_PROP_WINDOW_WAYLAND_XDG_TOPLEVEL_EXPORT_HANDLE_STRING = "SDL.window.wayland.xdg_toplevel_export_handle";
//pub const SDL_PROP_WINDOW_WAYLAND_XDG_POPUP_POINTER = "SDL.window.wayland.xdg_popup";
//pub const SDL_PROP_WINDOW_WAYLAND_XDG_POSITIONER_POINTER = "SDL.window.wayland.xdg_positioner";
//pub const SDL_PROP_WINDOW_X11_DISPLAY_POINTER = "SDL.window.x11.display";
//pub const SDL_PROP_WINDOW_X11_SCREEN_NUMBER = "SDL.window.x11.screen";
//pub const SDL_PROP_WINDOW_X11_WINDOW_NUMBER = "SDL.window.x11.window";
//pub const SDL_WINDOW_SURFACE_VSYNC_DISABLED = @as(c_int, 0);
//pub const SDL_WINDOW_SURFACE_VSYNC_ADAPTIVE = -@as(c_int, 1);
//pub const SDL_GPU_TEXTUREUSAGE_SAMPLER = @as(c_uint, 1) << @as(c_int, 0);
//pub const SDL_GPU_TEXTUREUSAGE_COLOR_TARGET = @as(c_uint, 1) << @as(c_int, 1);
//pub const SDL_GPU_TEXTUREUSAGE_DEPTH_STENCIL_TARGET = @as(c_uint, 1) << @as(c_int, 2);
//pub const SDL_GPU_TEXTUREUSAGE_GRAPHICS_STORAGE_READ = @as(c_uint, 1) << @as(c_int, 3);
//pub const SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_READ = @as(c_uint, 1) << @as(c_int, 4);
//pub const SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_WRITE = @as(c_uint, 1) << @as(c_int, 5);
//pub const SDL_GPU_BUFFERUSAGE_VERTEX = @as(c_uint, 1) << @as(c_int, 0);
//pub const SDL_GPU_BUFFERUSAGE_INDEX = @as(c_uint, 1) << @as(c_int, 1);
//pub const SDL_GPU_BUFFERUSAGE_INDIRECT = @as(c_uint, 1) << @as(c_int, 2);
//pub const SDL_GPU_BUFFERUSAGE_GRAPHICS_STORAGE_READ = @as(c_uint, 1) << @as(c_int, 3);
//pub const SDL_GPU_BUFFERUSAGE_COMPUTE_STORAGE_READ = @as(c_uint, 1) << @as(c_int, 4);
//pub const SDL_GPU_BUFFERUSAGE_COMPUTE_STORAGE_WRITE = @as(c_uint, 1) << @as(c_int, 5);
//pub const SDL_GPU_SHADERFORMAT_INVALID = @as(c_int, 0);
//pub const SDL_GPU_SHADERFORMAT_PRIVATE = @as(c_uint, 1) << @as(c_int, 0);
//pub const SDL_GPU_SHADERFORMAT_SPIRV = @as(c_uint, 1) << @as(c_int, 1);
//pub const SDL_GPU_SHADERFORMAT_DXBC = @as(c_uint, 1) << @as(c_int, 2);
//pub const SDL_GPU_SHADERFORMAT_DXIL = @as(c_uint, 1) << @as(c_int, 3);
//pub const SDL_GPU_SHADERFORMAT_MSL = @as(c_uint, 1) << @as(c_int, 4);
//pub const SDL_GPU_SHADERFORMAT_METALLIB = @as(c_uint, 1) << @as(c_int, 5);
//pub const SDL_GPU_COLORCOMPONENT_R = @as(c_uint, 1) << @as(c_int, 0);
//pub const SDL_GPU_COLORCOMPONENT_G = @as(c_uint, 1) << @as(c_int, 1);
//pub const SDL_GPU_COLORCOMPONENT_B = @as(c_uint, 1) << @as(c_int, 2);
//pub const SDL_GPU_COLORCOMPONENT_A = @as(c_uint, 1) << @as(c_int, 3);
//pub const SDL_PROP_GPU_CREATETEXTURE_D3D12_CLEAR_R_FLOAT = "SDL.gpu.createtexture.d3d12.clear.r";
//pub const SDL_PROP_GPU_CREATETEXTURE_D3D12_CLEAR_G_FLOAT = "SDL.gpu.createtexture.d3d12.clear.g";
//pub const SDL_PROP_GPU_CREATETEXTURE_D3D12_CLEAR_B_FLOAT = "SDL.gpu.createtexture.d3d12.clear.b";
//pub const SDL_PROP_GPU_CREATETEXTURE_D3D12_CLEAR_A_FLOAT = "SDL.gpu.createtexture.d3d12.clear.a";
//pub const SDL_PROP_GPU_CREATETEXTURE_D3D12_CLEAR_DEPTH_FLOAT = "SDL.gpu.createtexture.d3d12.clear.depth";
//pub const SDL_PROP_GPU_CREATETEXTURE_D3D12_CLEAR_STENCIL_UINT8 = "SDL.gpu.createtexture.d3d12.clear.stencil";
//pub const SDL_PROP_GPU_DEVICE_CREATE_DEBUGMODE_BOOL = "SDL.gpu.device.create.debugmode";
//pub const SDL_PROP_GPU_DEVICE_CREATE_PREFERLOWPOWER_BOOL = "SDL.gpu.device.create.preferlowpower";
//pub const SDL_PROP_GPU_DEVICE_CREATE_NAME_STRING = "SDL.gpu.device.create.name";
//pub const SDL_PROP_GPU_DEVICE_CREATE_SHADERS_PRIVATE_BOOL = "SDL.gpu.device.create.shaders.private";
//pub const SDL_PROP_GPU_DEVICE_CREATE_SHADERS_SPIRV_BOOL = "SDL.gpu.device.create.shaders.spirv";
//pub const SDL_PROP_GPU_DEVICE_CREATE_SHADERS_DXBC_BOOL = "SDL.gpu.device.create.shaders.dxbc";
//pub const SDL_PROP_GPU_DEVICE_CREATE_SHADERS_DXIL_BOOL = "SDL.gpu.device.create.shaders.dxil";
//pub const SDL_PROP_GPU_DEVICE_CREATE_SHADERS_MSL_BOOL = "SDL.gpu.device.create.shaders.msl";
//pub const SDL_PROP_GPU_DEVICE_CREATE_SHADERS_METALLIB_BOOL = "SDL.gpu.device.create.shaders.metallib";
//pub const SDL_PROP_GPU_DEVICE_CREATE_D3D12_SEMANTIC_NAME_STRING = "SDL.gpu.device.create.d3d12.semantic";
//pub const threadlocaleinfostruct = struct_threadlocaleinfostruct;
//pub const threadmbcinfostruct = struct_threadmbcinfostruct;
//pub const __lc_time_data = struct___lc_time_data;
//pub const localeinfo_struct = struct_localeinfo_struct;
//pub const tagLC_ID = struct_tagLC_ID;
//pub const _iobuf = struct__iobuf;
//pub const _wfinddata32_t = struct__wfinddata32_t;
//pub const _wfinddata32i64_t = struct__wfinddata32i64_t;
//pub const _wfinddata64i32_t = struct__wfinddata64i32_t;
//pub const _wfinddata64_t = struct__wfinddata64_t;
//pub const _stat32 = struct__stat32;
//pub const stat = struct_stat;
//pub const _stat32i64 = struct__stat32i64;
//pub const _stat64i32 = struct__stat64i32;
//pub const _stat64 = struct__stat64;
//pub const tm = struct_tm;
//pub const SDL_iconv_data_t = struct_SDL_iconv_data_t;
//pub const SDL_GLContextState = struct_SDL_GLContextState;
