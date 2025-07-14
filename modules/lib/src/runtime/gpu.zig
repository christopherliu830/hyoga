//! All datatypes within this file are hand-written
//! and must be manually kept in sync with the runtime datatypes!
const std = @import("std");
const hy = @import("../root.zig");
const rt = @import("../runtime.zig");

const hym = @import("../math/math.zig");
const mat4 = hym.mat4;

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
    _,
};

pub const TextureHandle = enum(u32) {
    none = std.math.maxInt(u32),
    _,
};

pub const PassHandle = enum(u64) {
    none = 0,
    _,
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
    pub const Initializer = std.enums.EnumFieldStruct(TextureType, TextureHandle, .none);
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
    custom,
};

pub const PassCreateOptions = extern struct {
    name: hy.ExternSliceConst(u8) = .from(&.{}),
    type: PassType,
    clear_color: u32 = 0,
    width: u16 = 0,
    height: u16 = 0,
    blit_material: MaterialHandle = .none,
};

pub const PassAddOptions = extern struct {
    pass: PassHandle,
    model: Model,
    time: u64 = 0,
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

pub const ModelCreateOptions = extern struct {
    verts: hy.ExternSliceConst(u8),
    indices: hy.ExternSliceConst(u32),
    material: MaterialHandle,
    transform: hym.Mat4 = .identity,
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

pub const Gpu = opaque {
    pub const materialDefaultCreate = hy_gfx_materialDefaultCreate;
    pub const materialCreate = hy_gfx_materialCreate;

    pub fn materialLoad(gpu: *Gpu, path: [:0]const u8) MaterialHandle {
        return hy_gfx_materialLoad(gpu, .from(path));
    }

    pub const materialReload = hy_gfx_materialReload;
    pub const materialDestroy = hy_gfx_materialDestroy;

    pub const modelImport = hy_gfx_importModel;
    pub const modelDestroy = hy_gfx_modelDestroy;
    pub const modelBounds = hy_gfx_modelBounds;
    pub const modelCreate = hy_gfx_modelCreate;
    pub const modelDupe = hy_gfx_modelDupe;
    pub const modelPrimitive = hy_gfx_modelPrimitive;
    pub const modelWaitLoad = hy_gfx_modelWaitLoad;
    pub const renderableAdd = hy_gfx_renderableAdd;
    pub const renderableRemove = hy_gfx_renderableDestroy;
    pub const renderableSetTransform = hy_gfx_renderableSetTransform;
    pub const renderableOfSprite = hy_gfx_renderableOfSprite;
    pub const spriteCreate = hy_gfx_spriteCreate;
    pub const spriteDestroy = hy_gfx_spriteDestroy;
    pub const spriteWeakPtr = hy_gfx_spriteWeakPtr;
    pub const spriteRenderableWeakPtr = hy_gfx_spriteRenderableWeakPtr;
    pub const spriteCurrentAnimationFrame = hy_gfx_spriteCurrentAnimationFrame;
    pub const spriteDupe = hy_gfx_spriteDupe;

    pub fn textureImport(gpu: *Gpu, path: []const u8) TextureHandle {
        return hy_gfx_textureImport(gpu, .from(path));
    }

    pub const clearColorSet = hy_gfx_clearColorSet;

    pub const passCreate = hy_gfx_passCreate;
    pub const passDestroy = hy_gfx_passDestroy;
    pub const passAdd = hy_gfx_passAdd;
    pub const passClear = hy_gfx_passClear;

    pub fn immediateDraw(gpu: *Gpu, verts: []const UIVertex, indices: []const u32, transform: hym.Mat4, mat_hdl: MaterialHandle) void {
        hy_gfx_immediateDraw(gpu, .from(verts), .from(indices), transform, mat_hdl);
    }
};

extern fn hy_gfx_clearColorSet(*Gpu, hym.Vec4) void;
extern fn hy_gfx_importModel(*Gpu, [*:0]const u8, ImportSettings) Model;
extern fn hy_gfx_materialDefaultCreate(*Gpu) MaterialHandle;
extern fn hy_gfx_materialLoad(*Gpu, hy.ExternSliceConst(u8)) MaterialHandle;
extern fn hy_gfx_materialReload(*Gpu, MaterialHandle) void;
extern fn hy_gfx_materialCreate(*Gpu, MaterialType, *const TextureArray) MaterialHandle;
extern fn hy_gfx_materialDestroy(*Gpu, MaterialHandle) void;
extern fn hy_gfx_modelBounds(*Gpu, Model) hym.AxisAligned;
extern fn hy_gfx_modelCreate(*Gpu, ModelCreateOptions) Model;
extern fn hy_gfx_modelDupe(*Gpu, Model, ModelDupeOptions) Model;
extern fn hy_gfx_modelDestroy(*Gpu, Model) void;
extern fn hy_gfx_modelPrimitive(*Gpu, PrimitiveShape) Model;
extern fn hy_gfx_modelWaitLoad(*Gpu, Model, u64) bool;
extern fn hy_gfx_renderableAdd(*Gpu, AddRenderableOptions) Renderable;
extern fn hy_gfx_renderableDestroy(*Gpu, Renderable) void;
extern fn hy_gfx_selectRenderable(*Gpu, Renderable) void;
extern fn hy_gfx_deselectRenderable(*Gpu, Renderable) void;
extern fn hy_gfx_renderableSetTransform(*Gpu, Renderable, hym.Mat4) void;
extern fn hy_gfx_renderableOfSprite(*Gpu, Sprite.Handle) Renderable;
extern fn hy_gfx_spriteCreate(*Gpu, SpriteCreateOptions) Sprite.Handle;
extern fn hy_gfx_spriteDestroy(*Gpu, Sprite.Handle) void;
extern fn hy_gfx_spriteWeakPtr(*Gpu, Sprite.Handle) ?*Sprite;
extern fn hy_gfx_spriteRenderableWeakPtr(*Gpu, Renderable) ?*Sprite;
extern fn hy_gfx_spriteCurrentAnimationFrame(*Gpu, *Sprite) u32;
extern fn hy_gfx_spriteDupe(*Gpu, Sprite.Handle) Sprite.Handle;
extern fn hy_gfx_textureImport(*Gpu, hy.ExternSliceConst(u8)) TextureHandle;
extern fn hy_gfx_passCreate(*Gpu, PassCreateOptions) PassHandle;
extern fn hy_gfx_passDestroy(*Gpu, PassHandle) void;
extern fn hy_gfx_passAdd(*Gpu, PassAddOptions) Renderable;
extern fn hy_gfx_passClear(*Gpu, PassHandle) void;
extern fn hy_gfx_immediateDraw(gpu: *Gpu, verts: hy.ExternSliceConst(UIVertex), indices: hy.ExternSliceConst(u32), transform: hym.Mat4, hdl: MaterialHandle) void;
extern fn hy_gfx_clearSelection(*Gpu) void;
