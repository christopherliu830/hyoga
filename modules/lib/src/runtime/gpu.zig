//! All datatypes within this file are hand-written
//! and must be manually kept in sync with the runtime datatypes!
const std = @import("std");
const hy = @import("../root.zig");
const rt = @import("../runtime.zig");

const proc_table = @import("proc_table.zig");
const proc = &proc_table.table;

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
    instance_hdl: [2]u32 = @splat(0),
    transform_hdl: [2]u32 = @splat(0),

    pub const none: Renderable = .{
        .pass = .default,
    };

    pub fn valid(self: Renderable) bool {
        return self.instance_hdl[1] != 0;
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
    pub fn clearColorSet(gpu: *Gpu, color: hym.Vec4) void {
        proc.hy_gfx_clearColorSet(gpu, color);
    }

    pub fn modelImport(gpu: *Gpu, path: []const u8, settings: ImportSettings) Model {
        return proc.hy_gfx_modelImport(gpu, .from(path), settings);
    }

    pub fn modelCreate(gpu: *Gpu, opts: ModelCreateOptions) Model {
        return proc.hy_gfx_modelCreate(gpu, opts);
    }

    pub fn modelDestroy(gpu: *Gpu, model: Model) void {
        proc.hy_gfx_modelDestroy(gpu, model);
    }

    pub fn modelBounds(gpu: *Gpu, model: Model) hym.AxisAligned {
        return proc.hy_gfx_modelBounds(gpu, model);
    }

    pub fn modelDupe(gpu: *Gpu, model: Model, opts: ModelDupeOptions) Model {
        return proc.hy_gfx_modelDupe(gpu, model, opts);
    }

    pub fn modelPrimitive(gpu: *Gpu, shape: PrimitiveShape) Model {
        return proc.hy_gfx_modelPrimitive(gpu, shape);
    }

    pub fn modelWaitLoad(gpu: *Gpu, model: Model, max: u64) bool {
        return proc.hy_gfx_modelWaitLoad(gpu, model, max);
    }

    pub fn materialLoad(gpu: *Gpu, path: []const u8) MaterialHandle {
        return proc.hy_gfx_materialLoad(gpu, .from(path));
    }

    pub fn materialReload(gpu: *Gpu, hdl: MaterialHandle) void {
        proc.hy_gfx_materialReload(gpu, hdl);
    }

    pub fn materialCreate(gpu: *Gpu, @"type": MaterialType, tx_set: *const TextureArray) MaterialHandle {
        return proc.hy_gfx_materialCreate(gpu, @"type", tx_set);
    }

    pub fn materialDestroy(gpu: *Gpu, hdl: MaterialHandle) void {
        proc.hy_gfx_materialDestroy(gpu, hdl);
    }

    pub fn renderableAdd(gpu: *Gpu, opts: AddRenderableOptions) Renderable {
        return proc.hy_gfx_renderableAdd(gpu, opts);
    }

    pub fn renderableRemove(gpu: *Gpu, hdl: Renderable) void {
        return proc.hy_gfx_renderableRemove(gpu, hdl);
    }

    pub fn renderableTransformSet(gpu: *Gpu, hdl: Renderable, transform: hym.Mat4) void {
        return proc.hy_gfx_renderableTransformSet(gpu, hdl, transform);
    }

    pub fn spriteMakeRenderable(gpu: *Gpu, hdl: Sprite.Handle) Renderable {
        return proc.hy_gfx_spriteMakeRenderable(gpu, hdl);
    }

    pub fn spriteCreate(gpu: *Gpu, opts: SpriteCreateOptions) Sprite.Handle {
        return proc.hy_gfx_spriteCreate(gpu, opts);
    }

    pub fn spriteDestroy(gpu: *Gpu, hdl: Sprite.Handle) void {
        proc.hy_gfx_spriteDestroy(gpu, hdl);
    }

    pub fn spriteWeakPtr(gpu: *Gpu, hdl: Sprite.Handle) ?*Sprite {
        return proc.hy_gfx_spriteWeakPtr(gpu, hdl);
    }

    pub fn spriteRenderableWeakPtr(gpu: *Gpu, hdl: Renderable) ?*Sprite {
        return proc.hy_gfx_spriteRenderableWeakPtr(gpu, hdl);
    }

    pub fn spriteCurrentAnimationFrame(gpu: *Gpu, hdl: *Sprite) u32 {
        return proc.hy_gfx_spriteCurrentAnimationFrame(gpu, hdl);
    }

    pub fn spriteDupe(gpu: *Gpu, hdl: Sprite.Handle) Sprite.Handle {
        return proc.hy_gfx_spriteDupe(gpu, hdl);
    }

    pub fn textureImport(gpu: *Gpu, path: []const u8) TextureHandle {
        return proc.hy_gfx_textureImport(gpu, .from(path));
    }

    pub fn passCreate(gpu: *Gpu, opts: PassCreateOptions) PassHandle {
        return proc.hy_gfx_passCreate(gpu, opts);
    }

    pub fn passDestroy(gpu: *Gpu, hdl: PassHandle) void {
        return proc.hy_gfx_passDestroy(gpu, hdl);
    }

    pub fn passAdd(gpu: *Gpu, opts: PassAddOptions) Renderable {
        return proc.hy_gfx_passAdd(gpu, opts);
    }

    pub fn passClear(gpu: *Gpu, hdl: PassHandle) void {
        proc.hy_gfx_passClear(gpu, hdl);
    }

    pub fn immediateDraw(gpu: *Gpu, verts: []const UIVertex, idxs: []const u32, transform: hym.Mat4, material_hdl: MaterialHandle) void {
        proc.hy_gfx_immediateDraw(gpu, .from(verts), .from(idxs), transform, material_hdl);
    }

    pub fn immediateText(gpu: *Gpu, glyphs: []const u8, transform: hym.Mat4, color: hy.Color) void {
        proc.hy_gfx_immediateText(gpu, .from(glyphs), transform, @bitCast(color.asu8x4()));
    }
};
