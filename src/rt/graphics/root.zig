const std = @import("std");
const hy = @import("hyoga");

const material = @import("material.zig");
const model = @import("model.zig");
const texture = @import("texture.zig");
const passes = @import("passes.zig");
const rbl = @import("renderable.zig");
pub const primitives = @import("primitives.zig");

pub const Gpu = @import("gpu.zig");

pub const InstanceHandle = hy.SlotMap(rbl.Instance).Handle;
pub const Material = material.Material;
pub const MaterialHandle = material.Handle;
pub const MaterialTemplate = material.MaterialTemplate;
pub const MaterialType = material.Material.Type;
pub const Mesh = model.Mesh;
pub const Model = model.Handle;
pub const Models = model.Models;
pub const Renderable = Gpu.RenderItemHandle;
pub const Sprite = Gpu.GpuSprite;
pub const SpriteHandle = hy.SlotMap(Gpu.Sprite).Handle;
pub const TextureHandle = texture.Handle;
pub const Textures = texture.Textures;
pub const TextureSet = texture.TextureSet;
pub const TextureArray = texture.TextureArray;
pub const PassHandle = hy.SlotMap(passes.Forward).Handle;
pub const Vertex = @import("vertex.zig").Vertex;
pub const UIVertex = @import("vertex.zig").UIVertex;

pub const PipelineType = enum {
    default,
    post_process,
    ui,

    pub inline fn hasDepth(self: PipelineType) bool {
        return switch (self) {
            .default => true,
            .post_process => false,
            .ui => false,
        };
    }
};
