//! All datatypes within this file are hand-written
//! and must be manually kept in sync with the runtime datatypes!
const std = @import("std");
const hy = @import("../root.zig");
const rt = @import("../runtime.zig");

const hym = @import("../math/math.zig");
const mat4 = hym.mat4;

pub const Gpu = opaque {
    pub const Vertex = struct {
        pos: [3]f32 = .{ 0, 0, 0 },
        normal: [3]f32 = .{ 0, 0, 0 },
        uv: [2]f32 = .{ 0, 0 },
    };

    pub const UIVertex = struct {
        pos: [2]f32 = .{ 0, 0 },
        uv: [2]f32 = .{ 0, 0 },
        color: [4]f32 = .{ 0, 0, 0, 0 },
    };

    pub const Model = enum(u64) {
        none = 0,
    };

    pub const TextureHandle = enum(u32) {
        none = std.math.maxInt(u32),
    };

    pub const Renderable = extern struct {
        pass: PassType,
        index: enum(u64) {
            none = 0,
            _,
        },

        pub const none: Renderable = .{
            .pass = .default,
            .index = .none,
        };

        pub fn valid(self: Renderable) bool {
            return self.index != .none;
        }
    };

    pub const MaterialHandle = enum(u64) {
        none = 0,
    };

    pub const MaterialType = enum(u32) {
        standard,
        standard_unlit,
        sprite,
        post_process,
        screen_blit,
        billboard,
        ui,
        ui_sdf,
        xor_surf2,
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

    pub const PassType = enum(u32) {
        default,
        outlined,
        ui,
    };

    // Time to wait for model load in nanoseconds.
    pub const AddRenderableOptions = extern struct {
        model: Model,
        time: u64 = 0,
        pass: PassType,
    };

    pub const ModelDupeOptions = extern struct {
        material: MaterialHandle = .none,
    };

    pub const SpriteCreateOptions = extern struct {
        atlas: [*:0]const u8,
        width: u16 = 1,
        height: u16 = 1,
        offset: u16 = 0,
        len: u16 = 1,
        speed: f32 = 0,
        color: [4]f32 = .{ 1, 1, 1, 1 },
    };

    pub const Sprite = extern struct {
        pub const Handle = enum(u64) {
            none = 0,
            _,
        };

        width: u32,
        height: u32,
        offset: u32,
        len: u32,
        speed: f32,
        time_offset: f32,
        color: [4]f32,
    };

    pub const materialDefaultCreate = hygpuMaterialDefaultCreate;
    pub const materialCreate = hygpuMaterialCreate;
    pub const modelImport = hygpuImportModel;
    pub const modelDestroy = hygpuModelDestroy;
    pub const modelBounds = hygpuModelBounds;

    pub fn modelCreate(gpu: *Gpu, verts: []const Vertex, indices: []const u32, mat_hdl: MaterialHandle) Model {
        return hygpuModelCreate(gpu, .make(verts), .make(indices), mat_hdl);
    }

    pub const modelDupe = hygpuModelDupe;
    pub const modelPrimitive = hygpuModelPrimitive;
    pub const modelWaitLoad = hygpuModelWaitLoad;
    pub const renderableAdd = hygpuRenderableAdd;
    pub const renderableRemove = hygpuRenderableDestroy;
    pub const renderableSetTransform = hygpuRenderableSetTransform;
    pub const renderableOfSprite = hygpuRenderableOfSprite;
    pub const spriteCreate = hygpuSpriteCreate;
    pub const spriteDestroy = hygpuSpriteDestroy;
    pub const spriteWeakPtr = hygpuSpriteWeakPtr;
    pub const spriteRenderableWeakPtr = hygpuSpriteRenderableWeakPtr;
    pub const spriteCurrentAnimationFrame = hygpuSpriteCurrentAnimationFrame;
    pub const spriteDupe = hygpuSpriteDupe;

    pub fn textureImport(gpu: *Gpu, path: []const u8) TextureHandle {
        return hygpuTextureImport(gpu, .make(path));
    }

    pub const clearColorSet = hygpuClearColorSet;

    extern fn hygpuClearColorSet(*Gpu, hym.Vec4) void;
    extern fn hygpuImportModel(*Gpu, [*:0]const u8, ImportSettings) Model;
    extern fn hygpuMaterialDefaultCreate(*Gpu) MaterialHandle;
    extern fn hygpuMaterialCreate(*Gpu, MaterialType, *const TextureArray) MaterialHandle;
    extern fn hygpuModelBounds(*Gpu, Model) hym.AxisAligned;
    extern fn hygpuModelCreate(*Gpu, hy.ExternSliceConst(Vertex), hy.ExternSliceConst(u32), MaterialHandle) Model;
    extern fn hygpuModelDupe(*Gpu, Model, ModelDupeOptions) Model;
    extern fn hygpuModelDestroy(*Gpu, Model) void;
    extern fn hygpuModelPrimitive(*Gpu, PrimitiveShape) Model;
    extern fn hygpuModelWaitLoad(*Gpu, Model, u64) bool;
    extern fn hygpuRenderableAdd(*Gpu, AddRenderableOptions) Renderable;
    extern fn hygpuRenderableDestroy(*Gpu, Renderable) void;
    extern fn hygpuSelectRenderable(*Gpu, Renderable) void;
    extern fn hygpuDeselectRenderable(*Gpu, Renderable) void;
    extern fn hygpuRenderableSetTransform(*Gpu, Renderable, hym.Mat4) void;
    extern fn hygpuRenderableOfSprite(*Gpu, Sprite.Handle) Renderable;
    extern fn hygpuSpriteCreate(*Gpu, SpriteCreateOptions) Sprite.Handle;
    extern fn hygpuSpriteDestroy(*Gpu, Sprite.Handle) void;
    extern fn hygpuSpriteWeakPtr(*Gpu, Sprite.Handle) ?*Sprite;
    extern fn hygpuSpriteRenderableWeakPtr(*Gpu, Renderable) ?*Sprite;
    extern fn hygpuSpriteCurrentAnimationFrame(*Gpu, *Sprite) u32;
    extern fn hygpuSpriteDupe(*Gpu, Sprite.Handle) Sprite.Handle;
    extern fn hygpuTextureImport(*Gpu, hy.ExternSliceConst(u8)) TextureHandle;
    extern fn hygpuClearSelection(*Gpu) void;
};
