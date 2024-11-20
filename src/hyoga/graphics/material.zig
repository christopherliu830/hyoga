const sdl = @import("sdl");
const tx = @import("texture.zig");

pub const Material = struct {
    pipeline: *sdl.gpu.GraphicsPipeline,
    vertex_textures: [2]sdl.gpu.TextureSamplerBinding = .{ .{}, .{} },
    num_vertex_textures: u32 = 0,
    fragment_textures: [2]sdl.gpu.TextureSamplerBinding = .{ .{}, .{}, },
    num_fragment_textures: u32 = 0,
};
//     vertex_uniforms: [4]ResourceType,
//     num_vertex_uniforms: u32,
//     fragment_uniforms: [4]ResourceType,
//     num_fragment_uniforms: u32,
//     vertex_bindings: []sdl.gpu.BufferBinding,
//     index_bindings: []sdl.gpu.BufferBinding,
//     fragment_samplers: []sdl.gpu.TextureSamplerBinding,