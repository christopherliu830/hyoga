const sdl = @import("sdl");

// const TransformMatrices= extern struct {
//     model: mat4.Mat4,
//     mvp: mat4.Mat4,
//     normal_transform: mat4.Mat4
// };

// const LightingUBO = extern struct {
//     light_dir: vec3.Vec3,
//     camera_pos: vec3.Vec3
// };

// pub const UBOType = union {
//     transforms(TransformMatrices),
//     lighting(LightingUBO),
// };

// pub const Material = struct {
//     pipeline: *sdl.gpu.GraphicsPipeline,
//     vertex_uniforms: [4]ResourceType,
//     num_vertex_uniforms: u32,
//     fragment_uniforms: [4]ResourceType,
//     num_fragment_uniforms: u32,
//     vertex_bindings: []sdl.gpu.BufferBinding,
//     index_bindings: []sdl.gpu.BufferBinding,
//     fragment_samplers: []sdl.gpu.TextureSamplerBinding,
// };