
pub const AI_MAXLEN = 1024;
pub const AI_MAX_NUMBER_OF_COLOR_SETS = 0x8;
pub const AI_MAX_NUMBER_OF_TEXTURECOORDS = 0x8;

pub const Vector3 = struct {
    x: f64,
    y: f64,
    z: f64
};

pub const Color4 = struct {
    r: f32,
    g: f32,
    b: f32,
    a: f32,
};

pub const Matrix4x4 = struct {
    a1: f64, a2: f64, a3: f64, a4: f64,
    b1: f64, b2: f64, b3: f64, b4: f64,
    c1: f64, c2: f64, c3: f64, c4: f64,
    d1: f64, d2: f64, d3: f64, d4: f64,
};

pub const String = struct {
    len: u32,
    data: [AI_MAXLEN]u8,
};

pub const AABB = struct {
    min: Vector3,
    max: Vector3,
};

// ----------- MESH ------------

pub const Face = struct { };

pub const Bone = struct { };

pub const AnimMesh = struct { };

pub const MorphingMethod = enum (c_int) { };

pub const Mesh = struct {
    primitive_types: u32,
    num_vertices: u32,
    num_faces: u32,
    vertices: *Vector3,
    normals: *Vector3,
    tangents: *Vector3,
    bitangents: *Vector3,
    colors: [AI_MAX_NUMBER_OF_COLOR_SETS]*Color4,
    texture_coords: [AI_MAX_NUMBER_OF_TEXTURECOORDS]*Vector3,
    num_uv_components: [AI_MAX_NUMBER_OF_TEXTURECOORDS]u32,
    faces: *Face,
    num_bones: u32,
    bones: **Bone,
    material_index: u32,
    name: String,
    num_anim_meshes: u32,
    method: MorphingMethod,
    aabb: AABB,
    texture_coords_names: **String,
};

pub const Material = struct {

};

pub const Animation = struct { };

pub const Texture = struct { };

pub const Light = opaque { };

pub const Camera = opaque { };

pub const Skeleton = opaque { };

pub const Node = struct {
    name: String,
    transformation: Matrix4x4,
    parent: *Node,
    num_children: u32,
    children: **Node,
    num_meshes: u32,
    meshes: *u32,
    metadata: *anyopaque,
};

pub const Scene = struct {
    flags: u32,
    root_node: *Node,
    num_meshes: u32,
    meshes: **Mesh,
    num_materials: u32,
    materials: **Material,
    num_animations: u32,
    animations: **Animation,
    num_textures: u32,
    textures: **Texture,
    num_lights: u32,
    lights: **Light,
    num_cameras: u32,
    cameras: **Camera,
    metadata: *anyopaque,
    name: String,
    num_skeletons: u32,
    skeleton: **Skeleton,

    // Internal, do not touch
    _private: *u8,
    
    pub fn release(self: *Scene) void {
        aiReleaseImport(self);
    }
};

pub const PostProcessSteps = packed struct (c_int) {
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

extern fn aiImportFile(path: [*:0]const u8, flags: PostProcessSteps) Scene;
pub const importFile = aiImportFile;

extern fn aiReleaseImport(scene: *Scene) void;