const sdl = @import("sdl");
const Mat4 = @import("hyoga-math").Mat4;
const Vec3 = @import("hyoga-math").Vec3;
const TextureType = @import("texture.zig").TextureType;

pub const MvpUniformGroup = extern struct {
    model: Mat4,
    inverse_model: Mat4,
    view_proj: Mat4,
};

const LightingUBO = extern struct {
    light_dir: Vec3,
    camera_pos: Vec3
};

pub const ShaderDefinition = struct {
    uniform_location_mvp: ?u32 = null,
    uniform_location_lighting: ?u32 = null,
    textures: []const TextureType = &.{},
};