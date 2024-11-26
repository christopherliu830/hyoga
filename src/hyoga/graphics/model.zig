const std = @import("std");
const hya = @import("hyoga-arena");
const ai = @import("assimp/assimp.zig");
const gpu = @import("gpu.zig");
const mt = @import("material.zig");
const tx = @import("texture.zig");
const Vertex = @import("vertex.zig").Vertex;
const mat4 = @import("hyoga-math").mat4;

pub const Arena = hya.Arena(Model);
pub const Handle = Arena.Handle;

pub const Mesh = struct {
    vertices: std.ArrayList(Vertex),
    indices: std.ArrayList(u32),
    material: mt.Handle,

    pub fn create(allocator: std.mem.Allocator, material: mt.Handle) Mesh {
        return .{
            .vertices = std.ArrayList(Vertex).init(allocator),
            .indices = std.ArrayList(u32).init(allocator),
            .material = material,
        };
    }
};

pub const Model = struct {
    total_vertex_count: u32,
    total_index_count: u32,
    meshes: std.ArrayList(Mesh),
    transform: mat4.Mat4,

    pub fn release(self: Model) void {
        self.vertices.deinit();
        self.indices.deinit();
        self.textures.deinit();
    }

    pub const ProcessModelParams = struct {
        path: [:0]const u8,
        scene: *ai.Scene,
        node: *ai.Node,
        mesh: ?*ai.Mesh = null,
        materials: []mt.Handle,
        allocator: std.mem.Allocator,
    };

    fn processNode(model: *Model, params: ProcessModelParams) !void {
        const node = params.node;
        try model.meshes.ensureTotalCapacity(node.num_meshes);
        for (node.meshes[0..node.num_meshes]) |idx_mesh| {
            const mesh = params.scene.meshes[idx_mesh];
            var sub = params;
            sub.mesh = mesh;
            try model.meshes.append(try model.processMesh(sub));
        }

        for (node.children[0..node.num_children]) |child| {
            var sub = params;
            sub.node = child;
            try model.processNode(sub);
        }
    }

    fn processMesh(model: *Model, params: ProcessModelParams) !Mesh {
        const in_mesh = params.mesh.?;
        var out_mesh = Mesh.create(params.allocator, params.materials[in_mesh.material_index]);
        try out_mesh.vertices.ensureTotalCapacity(in_mesh.num_vertices);
        model.total_vertex_count += in_mesh.num_vertices;

        for (0..in_mesh.num_vertices) |i| {
            const x: f32 = @floatCast(in_mesh.vertices[i].x);
            const y: f32 = @floatCast(in_mesh.vertices[i].y);
            const z: f32 = @floatCast(in_mesh.vertices[i].z);
            const nx: f32 = @floatCast(in_mesh.normals[i].x);
            const ny: f32 = @floatCast(in_mesh.normals[i].y);
            const nz: f32 = @floatCast(in_mesh.normals[i].z);
            try out_mesh.vertices.append(.{
                .pos = .{ x, y, z },
                .normal = .{ nx, ny, nz },
                .uv = .{ 0, 0 },
            });
            if (in_mesh.texture_coords[0]) |tex_coords| {
                const u: f32 = @floatCast(tex_coords[i].x);
                const v: f32 = @floatCast(tex_coords[i].y);
                out_mesh.vertices.items[i].uv = .{ u, v };
            }
        }

        for (in_mesh.faces[0..in_mesh.num_faces]) |face| {
            const start = out_mesh.indices.items.len;
            try out_mesh.indices.ensureTotalCapacity(start + face.num_indices);
            model.total_index_count += face.num_indices;
            for (face.indices[0..face.num_indices]) |idx| {
                try out_mesh.indices.append(@intCast(idx));
            }
        }

        return out_mesh;
    }
};

pub const ImportSettings = struct {
    transform: mat4.Mat4 = mat4.identity,
    post_process: ai.PostProcessSteps = .{
        .triangulate = true,
        .split_large_meshes = true,
    },
};

pub fn load(path: [:0]const u8, import: ImportSettings, mats: []mt.Handle, allocator: std.mem.Allocator) !Model {
    var scene = ai.importFile(path, import.post_process);
    defer scene.release();

    var model = Model {
        .total_index_count = 0,
        .total_vertex_count = 0,
        .meshes = std.ArrayList(Mesh).init(allocator),
        .transform = import.transform,
    };

    try model.processNode(.{
        .path = path,
        .scene = scene,
        .node = scene.root_node,
        .materials = mats,
        .allocator = allocator
    });

    return model;
}