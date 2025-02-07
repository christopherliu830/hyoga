//! All datatypes within this file are hand-written
//! and must be manually kept in sync with the runtime datatypes!
const std = @import("std");
const rt = @import("../runtime.zig");

const math = @import("../math/math.zig");
const mat4 = math.mat4;

pub const Gpu = opaque {
    pub const Model = enum(u64) {
        none = 0,
    };

    pub const TextureHandle = enum(u32) {
        none = std.math.maxInt(u32),
    };

    pub const Renderable = enum(u64) {
        none = 0,
    };

    pub const MaterialHandle = enum(u64) {
        none = 0,
    };

    pub const MaterialType = enum(u32) {
        standard,
        sprite,
        post_process,
        bw_mask,
        billboard,
    };

    pub const TextureType = enum(u32) {
        diffuse,
        specular,
        height,
        normal,
        mask,
    };

    pub const TextureArray = extern struct {
        const Map = std.EnumMap(TextureType, TextureHandle);
        const Initializer = std.enums.EnumFieldStruct(TextureType, TextureHandle, .none);
        data: [std.enums.directEnumArrayLen(TextureType, 0)]TextureHandle,

        pub fn make(txs: Initializer) TextureArray {
            return .{ .data = Map.initFullWithDefault(.none, txs).values };
        }
    };

    pub const PrimitiveShape = enum(u8) {
        cube,
        quad,
        sphere,
    };

    pub const PostProcessSteps = packed struct(u32) {
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
        optimize_meshes: bool = false,
        optimize_graph: bool = false,
        flip_uvs: bool = false,
        flip_winding_order: bool = false,
        split_by_bone_count: bool = false,
        debone: bool = false,
        global_scale: bool = false,
        embed_textures: bool = false,
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
            .gen_bounding_boxes = true,
        },
    };

    // Time to wait for model load in nanoseconds.
    pub const AddRenderableOptions = extern struct {
        model: Model,
        time: u64 = 0,
    };

    pub const ModelDupeOptions = extern struct {
        material: MaterialHandle = .none,
    };

    pub const SpriteCreateOptions = extern struct {
        atlas: [*:0]const u8,
        width: u16,
        height: u16,
        offset: u16 = 0,
        len: u16 = 0,
        speed: f32,
        color: [4]f32 = .{ 1, 1, 1, 1 },
    };

    pub const Sprite = extern struct {
        pub const Handle = enum(u64) {
            none = 0,
        };

        width: u32,
        height: u32,
        offset: u32,
        len: u32,
        speed: f32,
        time_offset: f32,
        color: [4]f32,
    };

    pub const materialCreate = hygpuMaterialCreate;
    pub const modelImport = hygpuImportModel;
    pub const modelDestroy = hygpuModelDestroy;
    pub const modelBounds = hygpuModelBounds;
    pub const modelDupe = hygpuModelDupe;
    pub const modelPrimitive = hygpuModelPrimitive;
    pub const modelWaitLoad = hygpuModelWaitLoad;
    pub const addRenderable = hygpuAddRenderable;
    pub const renderableDestroy = hygpuRenderableDestroy;
    pub const selectRenderable = hygpuSelectRenderable;
    pub const deselectRenderable = hygpuDeselectRenderable;
    pub const renderableSetTransform = hygpuRenderableSetTransform;
    pub const renderableOfSprite = hygpuRenderableOfSprite;
    pub const textureImport = hygpuTextureImport;
    pub const spriteCreate = hygpuSpriteCreate;
    pub const spriteDestroy = hygpuSpriteDestroy;
    pub const spriteWeakPointer = hygpuSpriteWeakPointer;
    pub const spriteCurrentIndex = hygpuSpriteCurrentIndex;
    pub const clearSelection = hygpuClearSelection;

    extern fn hygpuImportModel(*Gpu, [*:0]const u8, ImportSettings) Model;
    extern fn hygpuMaterialCreate(*Gpu, MaterialType, *const TextureArray) MaterialHandle;
    extern fn hygpuModelBounds(*Gpu, Model) math.AxisAligned;
    extern fn hygpuModelDupe(*Gpu, Model, ModelDupeOptions) Model;
    extern fn hygpuModelDestroy(*Gpu, Model) void;
    extern fn hygpuModelPrimitive(*Gpu, PrimitiveShape) Model;
    extern fn hygpuModelWaitLoad(*Gpu, Model, u64) bool;
    extern fn hygpuAddRenderable(*Gpu, AddRenderableOptions) Renderable;
    extern fn hygpuRenderableDestroy(*Gpu, Renderable) void;
    extern fn hygpuSelectRenderable(*Gpu, Renderable) void;
    extern fn hygpuDeselectRenderable(*Gpu, Renderable) void;
    extern fn hygpuRenderableSetTransform(*Gpu, Renderable, math.Mat4) void;
    extern fn hygpuRenderableOfSprite(*Gpu, Sprite.Handle) Renderable;
    extern fn hygpuSpriteCreate(*Gpu, SpriteCreateOptions) Sprite.Handle;
    extern fn hygpuSpriteDestroy(*Gpu, Sprite.Handle) void;
    extern fn hygpuSpriteWeakPointer(*Gpu, Renderable) ?*Sprite;
    extern fn hygpuSpriteCurrentIndex(*Gpu, *Sprite) u32;
    extern fn hygpuTextureImport(*Gpu, rt.ExternSlice(u8)) TextureHandle;
    extern fn hygpuClearSelection(*Gpu) void;
};
