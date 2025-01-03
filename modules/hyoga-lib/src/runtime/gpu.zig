//! All datatypes within this file are hand-written
//! and must be manually kept in sync with the runtime datatypes!
const std = @import("std");

const math = @import("../math/math.zig");
const mat4 = math.mat4;

pub const Gpu = opaque {
    pub const modelImport = hygpuImportModel;
    pub const modelBounds = hygpuModelBounds;
    pub const modelDupe = hygpuModelDupe;
    pub const modelPrimitive = hygpuModelPrimitive;
    pub const modelWaitLoad = hygpuModelWaitLoad;
    pub const addRenderable = hygpuAddRenderable;
    pub const removeRenderable = hygpuRemoveRenderable;
    pub const selectRenderable = hygpuSelectRenderable;
    pub const deselectRenderable = hygpuDeselectRenderable;
    pub const clearSelection = hygpuClearSelection;
};

pub const RenderItemHandle = enum (u64) {
    invalid = 0,
    _
};

pub const ModelHandle = enum (u64) {
    invalid = 0,
};

pub const MaterialHandle = enum (u64) {
    invalid = 0,
};

pub const PrimitiveShape = enum (u8) {
    cube,
};

pub const PostProcessSteps = packed struct (u32) {
    calc_tangent_space: bool = false,
    join_identical_vertices: bool = false,
    make_left_handed: bool = false,
    triangulate: bool = false,
    remove_component: bool = false,
    gen_normals: bool = false,
    gen_smooth_normals: bool = false,
    split_large_meshes: bool = false,
    pre_transform_vertices: bool = false,
    limit_bone_weights: bool = false,
    validate_data_structure: bool = false,
    improve_cache_locality: bool = false,
    remove_redundant_materials: bool = false,
    fix_infacing_normals: bool = false,
    populate_armature_data: bool = false,
    sort_by_ptype: bool = false,
    find_degenerates: bool = false,
    find_invalid_data: bool = false,
    gen_uv_coords: bool = false,
    transform_uv_coords: bool = false,
    find_instances: bool = false,
    optimize_meshes : bool = false,
    optimize_graph : bool = false,
    flip_uvs: bool = false,
    flip_winding_order : bool = false,
    split_by_bone_count : bool = false,
    debone : bool = false,
    global_scale: bool = false,
    embed_textures : bool = false,
    force_gen_normals: bool = false,
    drop_normals: bool = false,
    gen_bounding_boxes: bool = false,
};

pub const ImportSettings = extern struct {
    transform: mat4.Mat4 = mat4.identity,
    post_process: PostProcessSteps = .{
        .triangulate = true,
        .split_large_meshes = true,
        .pre_transform_vertices = true,
        .optimize_graph = true,
        .optimize_meshes = true,
    },
};

// Time to wait for model load in nanoseconds.
pub const AddRenderableOptions = extern struct {
    owner: *const mat4.Mat4 = &mat4.identity,
    time: u64 = 0,
    model: ModelHandle,
};


pub const ModelDupeOptions = extern struct {
    override_material: MaterialHandle = .invalid,
};

extern fn hygpuImportModel(*Gpu, [*:0]const u8, ImportSettings) ModelHandle;
extern fn hygpuModelBounds(*Gpu, ModelHandle) math.AxisAligned;
extern fn hygpuModelDupe(*Gpu, ModelHandle, ModelDupeOptions) ModelHandle;
extern fn hygpuModelPrimitive(*Gpu, PrimitiveShape) ModelHandle;
extern fn hygpuModelWaitLoad(*Gpu, ModelHandle, u64) bool;
extern fn hygpuAddRenderable(*Gpu, AddRenderableOptions) RenderItemHandle;
extern fn hygpuRemoveRenderable(*Gpu, RenderItemHandle) void;
extern fn hygpuSelectRenderable(*Gpu, RenderItemHandle) void;
extern fn hygpuDeselectRenderable(*Gpu, RenderItemHandle) void;
extern fn hygpuClearSelection(*Gpu) void;

