//
const std = @import("std");
const tx = @import("../texture.zig");

// Zig bindings for assimp library. For documentation
// refer to github.com/assimp/assimp
// NOTE: bindings are incomplete and added on an as-needed basis.

pub const AI_MAXLEN = 1024;
pub const AI_MAX_NUMBER_OF_COLOR_SETS = 0x8;
pub const AI_MAX_NUMBER_OF_TEXTURECOORDS = 0x8;
pub const HINT_MAX_TEXTURE_LEN = 9;

pub const Return = u32;

pub const Vector3 = extern struct { x: f32, y: f32, z: f32 };

pub const Color4 = extern struct {
    r: f32,
    g: f32,
    b: f32,
    a: f32,
};

pub const Matrix4x4 = extern struct {
    a1: f32,
    a2: f32,
    a3: f32,
    a4: f32,
    b1: f32,
    b2: f32,
    b3: f32,
    b4: f32,
    c1: f32,
    c2: f32,
    c3: f32,
    c4: f32,
    d1: f32,
    d2: f32,
    d3: f32,
    d4: f32,
};

pub const String = extern struct {
    len: u32 = 0,
    data: [AI_MAXLEN]u8 = undefined,
};

pub const AABB = extern struct {
    min: Vector3,
    max: Vector3,
};

// --------- MATERIAL ------------

pub const PropertyTypeInfo = enum(u32) { float, double, string, integer, buffer };

pub const MaterialProperty = extern struct {
    key: String,
    semantic: u32,
    index: u32,
    data_length: u32,
    type: PropertyTypeInfo,
    data: [*]const u8,
};

// ---- TEXTURE ----

pub const TextureType = enum(u32) { none, diffuse, specular, ambient, emissive, height, normals, shininess, opacity, displacement, lightmap, reflection, base_color, normal_camera, emission_color, metalness, diffuse_roughness, ambient_occlusion, unknown, sheen, clearcoat, transmission, maya_base, maya_specular, maya_specular_color, maya_specular_roughness };

pub const TextureMapping = opaque {};

pub const TextureOp = opaque {};

pub const MapMode = opaque {};

pub const Texel = extern struct {
    b: u8,
    g: u8,
    r: u8,
    a: u8,
};

pub const Texture = extern struct {
    width: u32,
    height: u32,
    ach_format_hint: [HINT_MAX_TEXTURE_LEN]u8,
    pc_data: [*]Texel, // format is always ARGB8888
    file_name: String,
};

pub const Material = extern struct {
    properties: *[*]MaterialProperty,
    num_properties: u32,
    num_allocated: u32,

    pub const GetTextureInfo = extern struct {
        tex_type: TextureType,
        index: u32,
        path: *String,
        mapping: ?*TextureMapping = null,
        uv_index: ?*u32 = null,
        blend: ?*f32 = null,
        op: ?*TextureOp = null,
        map_mode: ?*MapMode = null,
        flags: ?*u32 = null,
    };

    pub fn getTexture(self: *Material, info: GetTextureInfo) Return {
        return aiGetMaterialTexture(self, info.tex_type, info.index, info.path, info.mapping, info.uv_index, info.blend, info.op, info.map_mode, info.flags);
    }

    pub const getTextureCount = aiGetMaterialTextureCount;
};

extern fn aiGetMaterialTextureCount(mat: *Material, tex_type: TextureType) u32;

extern fn aiGetMaterialTexture(mat: *Material, tex_type: TextureType, index: u32, path: *String, mapping: ?*TextureMapping, uv_index: ?*u32, blend: ?*f32, op: ?*TextureOp, map_mode: ?*MapMode, flags: ?*u32) Return;

// ----------- MESH ------------

pub const Face = extern struct {
    num_indices: u32,
    indices: [*]u32,
};

pub const Bone = extern struct {};

pub const AnimMesh = extern struct {};

pub const MorphingMethod = enum(u32) {
    unknown,
    vertex_blend,
    morph_normalized,
    morph_relative,
};

pub const Mesh = extern struct {
    primitive_types: u32,
    num_vertices: u32,
    num_faces: u32,
    vertices: [*]Vector3,
    normals: [*]Vector3,
    tangents: [*]Vector3,
    bitangents: [*]Vector3,
    colors: [AI_MAX_NUMBER_OF_COLOR_SETS][*]Color4,
    texture_coords: [AI_MAX_NUMBER_OF_TEXTURECOORDS]?[*]Vector3,
    num_uv_components: [AI_MAX_NUMBER_OF_TEXTURECOORDS]u32,
    faces: [*]Face,
    num_bones: u32,
    bones: *[*]Bone,
    material_index: u32,
    name: String,
    num_anim_meshes: u32,
    anim_meshes: [*][*]AnimMesh,
    method: MorphingMethod,
    aabb: AABB,
    texture_coords_names: ?*[*]String,
};

pub const Animation = extern struct {};

pub const Light = opaque {};

pub const Camera = opaque {};

pub const Skeleton = opaque {};

pub const Node = extern struct {
    name: String,
    transformation: Matrix4x4,
    parent: *Node,
    num_children: u32,
    children: [*]*Node,
    num_meshes: u32,
    meshes: [*]u32,
    metadata: *anyopaque,
};

pub const Scene = extern struct {
    flags: u32,
    root_node: *Node,
    num_meshes: u32,
    meshes: [*]*Mesh,
    num_materials: u32,
    materials: [*]*Material,
    num_animations: u32,
    animations: [*]*Animation,
    num_textures: u32,
    textures: [*]*Texture,
    num_lights: u32,
    lights: [*]*Light,
    num_cameras: u32,
    cameras: [*]*Camera,
    metadata: *anyopaque,
    name: String,
    num_skeletons: u32,
    skeleton: [*]*Skeleton,

    // Internal, do not touch
    _private: *u8,

    pub fn release(self: *Scene) void {
        aiReleaseImport(self);
    }

    pub const getEmbeddedTexture = aiGetEmbeddedTexture;
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

extern fn aiImportFile(path: [*:0]const u8, flags: PostProcessSteps) *Scene;
pub const importFile = aiImportFile;

extern fn aiReleaseImport(scene: *Scene) void;

extern fn aiGetEmbeddedTexture(scene: *const Scene, filename: [*]const u8) ?*Texture;
