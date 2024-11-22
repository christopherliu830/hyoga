const std = @import("std");
const sdl = @import("sdl");
const prog = @import("shader_program.zig");
const tx = @import("texture.zig");

pub const Material = struct {
    pipeline: *sdl.gpu.GraphicsPipeline,
    vert_program_def: prog.ShaderDefinition,
    frag_program_def: prog.ShaderDefinition,
    textures: []const tx.TextureView = &.{},
};
