const std = @import("std");
const PixelFormat = @import("pixels.zig").PixelFormat;
const FColor = @import("pixels.zig").FColor;
pub const Rect = @import("rect.zig").Rect;
const PropertiesID = @import("properties.zig").PropertiesID;
const FlipMode = @import("surface.zig").FlipMode;
const Window = @import("video.zig").Window;

const getError = @import("c.zig").SDL_GetError;
const root = @This();

pub const Device = opaque {
	pub fn acquireCommandBuffer(self: *Device) !*CommandBuffer {
		return root.acquireCommandBuffer(self) orelse {
			return error.AcquireCommandBufferError;
		};
	}

	pub fn claimWindow(self: *Device, window: *Window) !void {
		if (!root.claimWindowForDevice(self, window)) {
			std.log.debug("Could not claim window for GPU device: {s}", .{getError()});
			return error.ClaimWindowError;
		}
	}

    pub fn create(name: ?[:0]const u8, flags: ShaderFormat) !*Device {
		return createDevice(flags, true, if (name) |n| n.ptr else null) orelse {
			std.log.err("Could not create device: {s}", .{getError()});
			return error.DeviceCreateError;
		};
    }

    pub fn createBuffer(self: *Device, info: BufferCreateInfo) !*Buffer {
        return root.createBuffer(self, &info) orelse {
            std.log.err("Failed to create buffer: {s}", .{getError()});
            return error.CreateBufferError;
        };
    }

	pub fn createGraphicsPipeline(self: *Device, info: GraphicsPipelineCreateInfo) !*GraphicsPipeline {
		return root.createGraphicsPipeline(self, &info) orelse {
			std.log.err("Failed to create pipeline: {s}", .{getError()});
			return error.CreateGraphicsPipelineError;
		};
	}

	pub fn createTransferBuffer(self: *Device, info: TransferBufferCreateInfo) !*TransferBuffer {
		return root.createTransferBuffer(self, &info) orelse {
			std.log.err("failed to create transfer buffer: {s}", .{getError()});
            return error.CreateBufferError;
		};
	}

	pub fn createSampler(self: *Device, info: SamplerCreateInfo) !*Sampler {
		return root.createSampler(self, &info) orelse {
			std.log.err("Failed to create sampler: {s}", .{getError()});
			return error.CreateSamplerError;
		};
	}

    pub fn createShader(self: *Device, params: ShaderCreateInfo) !*Shader {
        return root.createShader(self, &params) orelse {
            std.log.err("Failed to load shader: {s}", .{getError()});
            return error.CreateShaderError;
        };
    }

    pub fn createTexture(self: *Device, params: TextureCreateInfo) !*Texture {
        return root.createTexture(self, &params) orelse {
            std.log.err("Failed to load texture: {s}", .{getError()});
            return error.LoadTextureFailed;
        };
    }

    pub fn destroy(self: *Device) void {
        root.destroyDevice(self);
    }

	pub fn destroyTransferBuffer(self: *Device, buffer: *TransferBuffer) void {
		root.releaseTransferBuffer(self, buffer);
	}

    pub fn releaseBuffer(self: *Device, buffer: *Buffer) void {
        root.releaseBuffer(self, buffer);
    }

	pub fn releaseComputePipeline(self: *Device, pipeline: *GraphicsPipeline) void {
		root.releaseComputePipeline(self, pipeline);
	}

	pub fn releaseGraphicsPipeline(self: *Device, pipeline: *GraphicsPipeline) void {
		root.releaseGraphicsPipeline(self, pipeline);
	}

	pub fn releaseSampler(self: *Device, sampler: *Sampler) void {
		root.releaseSampler(self, sampler);
	}

    pub fn releaseShader(self: *Device, shader: *Shader) void {
        root.releaseShader(self, shader);
    } 

	pub fn releaseTexture(self: *Device, texture: *Texture) void {
		root.releaseTexture(self, texture);
	}

	pub fn releaseTransferBuffer(self: *Device, buffer: *TransferBuffer) void {
		root.releaseTransferBuffer(self, buffer);
	}

	pub fn mapTransferBuffer(self: *Device, transfer_buffer: *TransferBuffer, cycle: bool) ![*]u8 {
		return @ptrCast(root.mapTransferBuffer(self, transfer_buffer, cycle) orelse {
			std.log.err("Failed to map transfer buffer: {s}", .{getError()});
			return error.MapTransferBufferError;
		});
	}

	pub fn unmapTransferBuffer(self: *Device, transfer_buffer: *TransferBuffer) void {
		root.unmapTransferBuffer(self, transfer_buffer);
	}

};

pub const Buffer = opaque {

};

pub const TransferBuffer = opaque {
};

pub const Texture = opaque {};

pub const Sampler = opaque {};

pub const Shader = opaque {};

pub const ComputePipeline = opaque {};

pub const GraphicsPipeline = opaque {};

pub const CommandBuffer = opaque {

	pub fn beginCopyPass(self: *CommandBuffer) !*CopyPass {
		return root.beginCopyPass(self) orelse {
			return error.BeginCopyPassError;
		};
	}

	pub fn submit(self: *CommandBuffer) void {
		return root.submitCommandBuffer(self);
	}

};

pub const RenderPass = opaque {

	pub const setStencilReference = SDL_SetGPUStencilReference;

	pub const bindGraphicsPipeline = SDL_BindGPUGraphicsPipeline;
};

pub const ComputePass = opaque {};

pub const CopyPass = opaque {

	pub fn uploadToBuffer(self: *CopyPass, source: TransferBufferLocation, dest: BufferRegion, cycle: bool) void {
		root.uploadToBuffer(self, &source, &dest, cycle);
	}

	pub fn uploadToTexture(self: *CopyPass, source: TextureTransferInfo, dest: TextureRegion, cycle: bool) void {
		root.uploadToTexture(self, &source, &dest, cycle);
	}

	pub fn end(self: *CopyPass) void {
		root.endCopyPass(self);
	}
};

pub const Fence = opaque {};

pub const PrimitiveType = enum (c_uint) {
	trianglelist,
	trianglestrip,
	linelist,
	linestrip,
	pointlist,
};

pub const LoadOp = enum (c_uint) {
	load,
	clear,
	dont_care,
};

pub const StoreOp = enum (c_uint) {
	store,
	dont_care,
	resolve,
	resolve_and_store,
};

pub const IndexElementSize = enum (c_uint) {
	@"16bit",
	@"32bit",
};

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

pub const TextureUsageFlags = packed struct (c_int) {
	sampler: bool = false,
	color_target: bool = false,
	depth_stencil_target: bool = false,
	graphics_storage_read: bool = false,
	compute_storage_read: bool = false,
	compute_storage_write: bool = false,
	_padding: u26 = 0,
};

pub const TextureType = enum (c_uint) {
	@"2d",
	@"2d_array",
	@"3d",
	cube,
	cube_array,
};

pub const SampleCount = enum (c_uint) {
	@"1",
	@"2",
	@"4",
	@"8",
};

pub const CubeMapFace = enum (c_uint) {
	positivex,
	negativex,
	positivey,
	negativey,
	positivez,
	negativez,
};

pub const BufferUsageFlags = packed struct (c_int) {
	vertex: bool = false,
	index: bool = false,
	indirect: bool = false,
	graphics_storage_read: bool = false,
	compute_storage_read: bool = false,
	compute_storage_write: bool = false,
	_padding: u26 = 0,
};

pub const TransferBufferUsage = enum (c_uint) {
	upload,
	download,
};

pub const ShaderStage = enum (c_uint) {
	vertex,
	fragment,
};

pub const ShaderFormat = packed struct (c_int) {
	private: bool = false,
	spirv: bool = false,
	dxbc: bool = false,
	dxil: bool = false,
	msl: bool = false,
	metallib: bool = false,
	_padding: u26 = 0,
};

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

pub const VertexInputRate = enum (c_uint) {
	vertex,
	instance,
};

pub const FillMode = enum (c_uint) {
	fill,
	line,
};

pub const CullMode = enum (c_uint) {
	none,
	front,
	back,
};

pub const FrontFace = enum (c_uint) {
	counter_clockwise,
	clockwise,
};

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

pub const BlendOp = enum (c_uint) {
	invalid,
	add,
	subtract,
	reverse_subtract,
	min,
	max,
};

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

pub const ColorComponentFlags = packed struct (u8) {
	r: bool = false,
	g: bool = false,
	b: bool = false,
	a: bool = false,
	_padding: u4 = 0,
};

pub const Filter = enum (c_uint) {
	nearest,
	linear,
};

pub const SamplerMipmapMode = enum (c_uint) {
	nearest,
	linear,
};

pub const SamplerAddressMode = enum (c_uint) {
	repeat,
	mirrored_repeat,
	clamp_to_edge,
};

pub const PresentMode = enum (c_uint) {
	vsync,
	immediate,
	mailbox,
};

pub const SwapchainComposition = enum (c_uint) {
	sdr,
	sdr_linear,
	hdr_extended_linear,
	hdr10_st2048,
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
	enable_blend: bool,
	enable_color_write_mask: bool = @import("std").mem.zeroes(bool),
	padding2: u8 = @import("std").mem.zeroes(u8),
	padding3: u8 = @import("std").mem.zeroes(u8),
};

pub const ShaderCreateInfo = extern struct {
	code_size: usize = @import("std").mem.zeroes(usize),
	code: [*]const u8,
	entrypoint: [*]const u8,
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
	padding1: u8 = @import("std").mem.zeroes(u8),
	padding2: u8 = @import("std").mem.zeroes(u8),
	padding3: u8 = @import("std").mem.zeroes(u8),
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
	color_target_descriptions: [*]const ColorTargetDescription,
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
	num_writeonly_storage_textures: u32 = @import("std").mem.zeroes(u32),
	num_writeonly_storage_buffers: u32 = @import("std").mem.zeroes(u32),
	num_uniform_buffers: u32 = @import("std").mem.zeroes(u32),
	threadcount_x: u32 = @import("std").mem.zeroes(u32),
	threadcount_y: u32 = @import("std").mem.zeroes(u32),
	threadcount_z: u32 = @import("std").mem.zeroes(u32),
	props: PropertiesID = @import("std").mem.zeroes(PropertiesID),
};

pub const ColorTargetInfo = extern struct {
	texture: ?*Texture = @import("std").mem.zeroes(?*Texture),
	mip_level: u32 = @import("std").mem.zeroes(u32),
	layer_or_depth_plane: u32 = @import("std").mem.zeroes(u32),
	clear_color: FColor = @import("std").mem.zeroes(FColor),
	load_op: LoadOp = @import("std").mem.zeroes(LoadOp),
	store_op: StoreOp = @import("std").mem.zeroes(StoreOp),
	cycle: bool = @import("std").mem.zeroes(bool),
	padding1: u8 = @import("std").mem.zeroes(u8),
	padding2: u8 = @import("std").mem.zeroes(u8),
	padding3: u8 = @import("std").mem.zeroes(u8),
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

pub const StorageBufferWriteOnlyBinding = extern struct {
	buffer: ?*Buffer = @import("std").mem.zeroes(?*Buffer),
	cycle: bool = @import("std").mem.zeroes(bool),
	padding1: u8 = @import("std").mem.zeroes(u8),
	padding2: u8 = @import("std").mem.zeroes(u8),
	padding3: u8 = @import("std").mem.zeroes(u8),
};

pub const StorageTextureWriteOnlyBinding = extern struct {
	texture: ?*Texture = @import("std").mem.zeroes(?*Texture),
	mip_level: u32 = @import("std").mem.zeroes(u32),
	layer: u32 = @import("std").mem.zeroes(u32),
	cycle: bool = @import("std").mem.zeroes(bool),
	padding1: u8 = @import("std").mem.zeroes(u8),
	padding2: u8 = @import("std").mem.zeroes(u8),
	padding3: u8 = @import("std").mem.zeroes(u8),
};

pub extern fn SDL_GPUSupportsShaderFormats(format_flags: ShaderFormat, name: [*c]const u8) bool;
pub const supportsShaderFormats = SDL_GPUSupportsShaderFormats;

pub extern fn SDL_GPUSupportsProperties(props: PropertiesID) bool;
pub const supportsProperties = SDL_GPUSupportsProperties;

pub extern fn SDL_CreateGPUDevice(format_flags: ShaderFormat, debug_mode: bool, name: [*c]const u8) ?*Device;
pub const createDevice = SDL_CreateGPUDevice;

pub extern fn SDL_CreateGPUDeviceWithProperties(props: PropertiesID) ?*Device;
pub const createDeviceWithProperties = SDL_CreateGPUDeviceWithProperties;

pub extern fn SDL_DestroyGPUDevice(device: ?*Device) void;
pub const destroyDevice = SDL_DestroyGPUDevice;

pub extern fn SDL_GetNumGPUDrivers() c_int;
pub const getNumDrivers = SDL_GetNumGPUDrivers;

pub extern fn SDL_GetGPUDriver(index: c_int) [*c]const u8;
pub const getDriver = SDL_GetGPUDriver;

pub extern fn SDL_GetGPUDeviceDriver(device: ?*Device) [*c]const u8;
pub const getDeviceDriver = SDL_GetGPUDeviceDriver;

pub extern fn SDL_GetGPUShaderFormats(device: ?*Device) ShaderFormat;
pub const getShaderFormats = SDL_GetGPUShaderFormats;

pub extern fn SDL_CreateGPUComputePipeline(device: ?*Device, createinfo: [*c]const ComputePipelineCreateInfo) ?*ComputePipeline;
pub const createComputePipeline = SDL_CreateGPUComputePipeline;

pub extern fn SDL_CreateGPUGraphicsPipeline(device: ?*Device, createinfo: *const GraphicsPipelineCreateInfo) ?*GraphicsPipeline;
pub const createGraphicsPipeline = SDL_CreateGPUGraphicsPipeline;

pub extern fn SDL_CreateGPUSampler(device: ?*Device, createinfo: *const SamplerCreateInfo) ?*Sampler;
pub const createSampler = SDL_CreateGPUSampler;

pub extern fn SDL_CreateGPUShader(device: ?*Device, createinfo: [*c]const ShaderCreateInfo) ?*Shader;
pub const createShader = SDL_CreateGPUShader;

pub extern fn SDL_CreateGPUTexture(device: *Device, createinfo: *const TextureCreateInfo) ?*Texture;
pub const createTexture = SDL_CreateGPUTexture;

pub extern fn SDL_CreateGPUBuffer(device: *Device, createinfo: *const BufferCreateInfo) ?*Buffer;
pub const createBuffer = SDL_CreateGPUBuffer;

pub extern fn SDL_CreateGPUTransferBuffer(device: ?*Device, createinfo: *const TransferBufferCreateInfo) ?*TransferBuffer;
pub const createTransferBuffer = SDL_CreateGPUTransferBuffer;

pub extern fn SDL_SetGPUBufferName(device: ?*Device, buffer: ?*Buffer, text: [*c]const u8) void;
pub const setBufferName = SDL_SetGPUBufferName;

pub extern fn SDL_SetGPUTextureName(device: ?*Device, texture: ?*Texture, text: [*c]const u8) void;
pub const setTextureName = SDL_SetGPUTextureName;

pub extern fn SDL_InsertGPUDebugLabel(command_buffer: ?*CommandBuffer, text: [*c]const u8) void;
pub const insertDebugLabel = SDL_InsertGPUDebugLabel;

pub extern fn SDL_PushGPUDebugGroup(command_buffer: ?*CommandBuffer, name: [*c]const u8) void;
pub const pushDebugGroup = SDL_PushGPUDebugGroup;

pub extern fn SDL_PopGPUDebugGroup(command_buffer: ?*CommandBuffer) void;
pub const popDebugGroup = SDL_PopGPUDebugGroup;

pub extern fn SDL_ReleaseGPUTexture(device: ?*Device, texture: ?*Texture) void;
pub const releaseTexture = SDL_ReleaseGPUTexture;

pub extern fn SDL_ReleaseGPUSampler(device: ?*Device, sampler: ?*Sampler) void;
pub const releaseSampler = SDL_ReleaseGPUSampler;

pub extern fn SDL_ReleaseGPUBuffer(device: ?*Device, buffer: ?*Buffer) void;
pub const releaseBuffer = SDL_ReleaseGPUBuffer;

pub extern fn SDL_ReleaseGPUTransferBuffer(device: ?*Device, transfer_buffer: ?*TransferBuffer) void;
pub const releaseTransferBuffer = SDL_ReleaseGPUTransferBuffer;

pub extern fn SDL_ReleaseGPUComputePipeline(device: ?*Device, compute_pipeline: ?*ComputePipeline) void;
pub const releaseComputePipeline = SDL_ReleaseGPUComputePipeline;

pub extern fn SDL_ReleaseGPUShader(device: ?*Device, shader: ?*Shader) void;
pub const releaseShader = SDL_ReleaseGPUShader;

pub extern fn SDL_ReleaseGPUGraphicsPipeline(device: ?*Device, graphics_pipeline: ?*GraphicsPipeline) void;
pub const releaseGraphicsPipeline = SDL_ReleaseGPUGraphicsPipeline;

pub extern fn SDL_AcquireGPUCommandBuffer(device: ?*Device) ?*CommandBuffer;
pub const acquireCommandBuffer = SDL_AcquireGPUCommandBuffer;

pub extern fn SDL_PushGPUVertexUniformData(command_buffer: ?*CommandBuffer, slot_index: u32, data: ?*const anyopaque, length: u32) void;
pub const pushVertexUniformData = SDL_PushGPUVertexUniformData;

pub extern fn SDL_PushGPUFragmentUniformData(command_buffer: ?*CommandBuffer, slot_index: u32, data: ?*const anyopaque, length: u32) void;
pub const pushFragmentUniformData = SDL_PushGPUFragmentUniformData;

pub extern fn SDL_PushGPUComputeUniformData(command_buffer: ?*CommandBuffer, slot_index: u32, data: ?*const anyopaque, length: u32) void;
pub const pushComputeUniformData = SDL_PushGPUComputeUniformData;

pub extern fn SDL_BeginGPURenderPass(command_buffer: ?*CommandBuffer, color_target_infos: [*c]const ColorTargetInfo, num_color_targets: u32, depth_stencil_target_info: [*c]const DepthStencilTargetInfo) ?*RenderPass;
pub const beginRenderPass = SDL_BeginGPURenderPass;

pub extern fn SDL_BindGPUGraphicsPipeline(render_pass: *RenderPass, graphics_pipeline: ?*GraphicsPipeline) void;
pub const bindGraphicsPipeline = SDL_BindGPUGraphicsPipeline;

pub extern fn SDL_SetGPUViewport(render_pass: *RenderPass, viewport: [*c]const Viewport) void;
pub const setViewport = SDL_SetGPUViewport;

pub extern fn SDL_SetGPUScissor(render_pass: *RenderPass, scissor: [*c]const Rect) void;
pub const setScissor = SDL_SetGPUScissor;

pub extern fn SDL_SetGPUBlendConstants(render_pass: *RenderPass, blend_constants: FColor) void;
pub const setBlendConstants = SDL_SetGPUBlendConstants;

pub extern fn SDL_SetGPUStencilReference(render_pass: *RenderPass, reference: u8) void;
pub const setStencilReference = SDL_SetGPUStencilReference;

pub extern fn SDL_BindGPUVertexBuffers(render_pass: *RenderPass, first_slot: u32, bindings: [*c]const BufferBinding, num_bindings: u32) void;
pub const bindVertexBuffers = SDL_BindGPUVertexBuffers;

pub extern fn SDL_BindGPUIndexBuffer(render_pass: *RenderPass, binding: [*c]const BufferBinding, index_element_size: IndexElementSize) void;
pub const bindIndexBuffer = SDL_BindGPUIndexBuffer;

pub extern fn SDL_BindGPUVertexSamplers(render_pass: *RenderPass, first_slot: u32, texture_sampler_bindings: [*c]const TextureSamplerBinding, num_bindings: u32) void;
pub const bindVertexSamplers = SDL_BindGPUVertexSamplers;

pub extern fn SDL_BindGPUVertexStorageTextures(render_pass: *RenderPass, first_slot: u32, storage_textures: [*c]const ?*Texture, num_bindings: u32) void;
pub const bindVertexStorageTextures = SDL_BindGPUVertexStorageTextures;

pub extern fn SDL_BindGPUVertexStorageBuffers(render_pass: *RenderPass, first_slot: u32, storage_buffers: [*c]const ?*Buffer, num_bindings: u32) void;
pub const bindVertexStorageBuffers = SDL_BindGPUVertexStorageBuffers;

pub extern fn SDL_BindGPUFragmentSamplers(render_pass: *RenderPass, first_slot: u32, texture_sampler_bindings: [*]const TextureSamplerBinding, num_bindings: u32) void;
pub const bindFragmentSamplers = SDL_BindGPUFragmentSamplers;

pub extern fn SDL_BindGPUFragmentStorageTextures(render_pass: *RenderPass, first_slot: u32, storage_textures: [*c]const ?*Texture, num_bindings: u32) void;
pub const bindFragmentStorageTextures = SDL_BindGPUFragmentStorageTextures;

pub extern fn SDL_BindGPUFragmentStorageBuffers(render_pass: *RenderPass, first_slot: u32, storage_buffers: [*c]const ?*Buffer, num_bindings: u32) void;
pub const bindFragmentStorageBuffers = SDL_BindGPUFragmentStorageBuffers;

pub extern fn SDL_DrawGPUIndexedPrimitives(render_pass: *RenderPass, num_indices: u32, num_instances: u32, first_index: u32, vertex_offset: i32, first_instance: u32) void;
pub const drawIndexedPrimitives = SDL_DrawGPUIndexedPrimitives;

pub extern fn SDL_DrawGPUPrimitives(render_pass: *RenderPass, num_vertices: u32, num_instances: u32, first_vertex: u32, first_instance: u32) void;
pub const drawPrimitives = SDL_DrawGPUPrimitives;

pub extern fn SDL_DrawGPUPrimitivesIndirect(render_pass: *RenderPass, buffer: ?*Buffer, offset: u32, draw_count: u32) void;
pub const drawPrimitivesIndirect = SDL_DrawGPUPrimitivesIndirect;

pub extern fn SDL_DrawGPUIndexedPrimitivesIndirect(render_pass: *RenderPass, buffer: ?*Buffer, offset: u32, draw_count: u32) void;
pub const drawIndexedPrimitivesIndirect = SDL_DrawGPUIndexedPrimitivesIndirect;

pub extern fn SDL_EndGPURenderPass(render_pass: *RenderPass) void;
pub const endRenderPass = SDL_EndGPURenderPass;

pub extern fn SDL_BeginGPUComputePass(command_buffer: *CommandBuffer, storage_texture_bindings: [*c]const StorageTextureWriteOnlyBinding, num_storage_texture_bindings: u32, storage_buffer_bindings: [*c]const StorageBufferWriteOnlyBinding, num_storage_buffer_bindings: u32) ?*ComputePass;
pub const beginComputePass = SDL_BeginGPUComputePass;

pub extern fn SDL_BindGPUComputePipeline(compute_pass: *ComputePass, compute_pipeline: ?*ComputePipeline) void;
pub const bindComputePipeline = SDL_BindGPUComputePipeline;

pub extern fn SDL_BindGPUComputeSamplers(compute_pass: *ComputePass, first_slot: u32, texture_sampler_bindings: [*c]const TextureSamplerBinding, num_bindings: u32) void;
pub const bindComputeSamplers = SDL_BindGPUComputeSamplers;

pub extern fn SDL_BindGPUComputeStorageTextures(compute_pass: *ComputePass, first_slot: u32, storage_textures: [*c]const ?*Texture, num_bindings: u32) void;
pub const bindComputeStorageTextures = SDL_BindGPUComputeStorageTextures;

pub extern fn SDL_BindGPUComputeStorageBuffers(compute_pass: *ComputePass, first_slot: u32, storage_buffers: [*c]const ?*Buffer, num_bindings: u32) void;
pub const bindComputeStorageBuffers = SDL_BindGPUComputeStorageBuffers;

pub extern fn SDL_DispatchGPUCompute(compute_pass: *ComputePass, groupcount_x: u32, groupcount_y: u32, groupcount_z: u32) void;
pub const dispatchCompute = SDL_DispatchGPUCompute;

pub extern fn SDL_DispatchGPUComputeIndirect(compute_pass: *ComputePass, buffer: ?*Buffer, offset: u32) void;
pub const dispatchComputeIndirect = SDL_DispatchGPUComputeIndirect;

pub extern fn SDL_EndGPUComputePass(compute_pass: *ComputePass) void;
pub const endComputePass = SDL_EndGPUComputePass;

pub extern fn SDL_MapGPUTransferBuffer(device: *Device, transfer_buffer: ?*TransferBuffer, cycle: bool) ?*anyopaque;
pub const mapTransferBuffer = SDL_MapGPUTransferBuffer;

pub extern fn SDL_UnmapGPUTransferBuffer(device: *Device, transfer_buffer: ?*TransferBuffer) void;
pub const unmapTransferBuffer = SDL_UnmapGPUTransferBuffer;

pub extern fn SDL_BeginGPUCopyPass(command_buffer: *CommandBuffer) ?*CopyPass;
pub const beginCopyPass = SDL_BeginGPUCopyPass;

pub extern fn SDL_UploadToGPUTexture(copy_pass: *CopyPass, source: [*c]const TextureTransferInfo, destination: [*c]const TextureRegion, cycle: bool) void;
pub const uploadToTexture = SDL_UploadToGPUTexture;

pub extern fn SDL_UploadToGPUBuffer(copy_pass: *CopyPass, source: [*c]const TransferBufferLocation, destination: [*c]const BufferRegion, cycle: bool) void;
pub const uploadToBuffer = SDL_UploadToGPUBuffer;

pub extern fn SDL_CopyGPUTextureToTexture(copy_pass: *CopyPass, source: [*c]const TextureLocation, destination: [*c]const TextureLocation, w: u32, h: u32, d: u32, cycle: bool) void;
pub const copyTextureToTexture = SDL_CopyGPUTextureToTexture;

pub extern fn SDL_CopyGPUBufferToBuffer(copy_pass: *CopyPass, source: [*c]const BufferLocation, destination: [*c]const BufferLocation, size: u32, cycle: bool) void;
pub const copyBufferToBuffer = SDL_CopyGPUBufferToBuffer;

pub extern fn SDL_DownloadFromGPUTexture(copy_pass: *CopyPass, source: [*c]const TextureRegion, destination: [*c]const TextureTransferInfo) void;
pub const downloadFromTexture = SDL_DownloadFromGPUTexture;

pub extern fn SDL_DownloadFromGPUBuffer(copy_pass: *CopyPass, source: [*c]const BufferRegion, destination: [*c]const TransferBufferLocation) void;
pub const downloadFromBuffer = SDL_DownloadFromGPUBuffer;

pub extern fn SDL_EndGPUCopyPass(copy_pass: *CopyPass) void;
pub const endCopyPass = SDL_EndGPUCopyPass;

pub extern fn SDL_GenerateMipmapsForGPUTexture(command_buffer: ?*CommandBuffer, texture: ?*Texture) void;
pub const generateMipmapsForTexture = SDL_GenerateMipmapsForGPUTexture;

pub extern fn SDL_BlitGPUTexture(command_buffer: ?*CommandBuffer, info: [*c]const BlitInfo) void;
pub const blitTexture = SDL_BlitGPUTexture;

pub extern fn SDL_WindowSupportsGPUSwapchainComposition(device: ?*Device, window: ?*Window, swapchain_composition: SwapchainComposition) bool;
pub const windowSupportsSwapchainComposition = SDL_WindowSupportsGPUSwapchainComposition;

pub extern fn SDL_WindowSupportsGPUPresentMode(device: ?*Device, window: ?*Window, present_mode: PresentMode) bool;
pub const windowSupportsPresentMode = SDL_WindowSupportsGPUPresentMode;

pub extern fn SDL_ClaimWindowForGPUDevice(device: ?*Device, window: ?*Window) bool;
pub const claimWindowForDevice = SDL_ClaimWindowForGPUDevice;

pub extern fn SDL_ReleaseWindowFromGPUDevice(device: ?*Device, window: ?*Window) void;
pub const releaseWindowFromDevice = SDL_ReleaseWindowFromGPUDevice;

pub extern fn SDL_SetGPUSwapchainParameters(device: ?*Device, window: ?*Window, swapchain_composition: SwapchainComposition, present_mode: PresentMode) bool;
pub const setSwapchainParameters = SDL_SetGPUSwapchainParameters;

pub extern fn SDL_GetGPUSwapchainTextureFormat(device: ?*Device, window: ?*Window) TextureFormat;
pub const getSwapchainTextureFormat = SDL_GetGPUSwapchainTextureFormat;

pub extern fn SDL_AcquireGPUSwapchainTexture(command_buffer: ?*CommandBuffer, window: ?*Window, w: [*c]u32, h: [*c]u32) ?*Texture;
pub const acquireSwapchainTexture = SDL_AcquireGPUSwapchainTexture;

pub extern fn SDL_SubmitGPUCommandBuffer(command_buffer: ?*CommandBuffer) void;
pub const submitCommandBuffer = SDL_SubmitGPUCommandBuffer;

pub extern fn SDL_SubmitGPUCommandBufferAndAcquireFence(command_buffer: ?*CommandBuffer) ?*Fence;
pub const submitCommandBufferAndAcquireFence = SDL_SubmitGPUCommandBufferAndAcquireFence;

pub extern fn SDL_WaitForGPUIdle(device: ?*Device) void;
pub const waitForIdle = SDL_WaitForGPUIdle;

pub extern fn SDL_WaitForGPUFences(device: ?*Device, wait_all: bool, fences: [*c]const ?*Fence, num_fences: u32) void;
pub const waitForFences = SDL_WaitForGPUFences;

pub extern fn SDL_QueryGPUFence(device: ?*Device, fence: ?*Fence) bool;
pub const queryFence = SDL_QueryGPUFence;

pub extern fn SDL_ReleaseGPUFence(device: ?*Device, fence: ?*Fence) void;
pub const releaseFence = SDL_ReleaseGPUFence;

pub extern fn SDL_GPUTextureFormatTexelBlockSize(format: TextureFormat) u32;
pub const textureFormatTexelBlockSize = SDL_GPUTextureFormatTexelBlockSize;

pub extern fn SDL_GPUTextureSupportsFormat(device: ?*Device, format: TextureFormat, @"type": TextureType, usage: TextureUsageFlags) bool;
pub const textureSupportsFormat = SDL_GPUTextureSupportsFormat;

pub extern fn SDL_GPUTextureSupportsSampleCount(device: ?*Device, format: TextureFormat, sample_count: SampleCount) bool;
pub const textureSupportsSampleCount = SDL_GPUTextureSupportsSampleCount;
