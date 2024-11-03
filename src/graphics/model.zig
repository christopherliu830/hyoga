const std = @import("std");
const ai = @import("assimp/assimp.zig");
const gpu = @import("gpu.zig");
const hyarena = @import("../genarray.zig");
const tx = @import("texture.zig");
const Vertex = @import("vertex.zig").Vertex;

pub const Arena = hyarena.Arena(Model);
pub const Handle = Arena.Handle;

pub const Mesh = struct {
    vertices: std.ArrayList(Vertex),
    indices: std.ArrayList(u32),

    textures: std.ArrayList(tx.TextureView),

    pub fn create(allocator: std.mem.Allocator) Mesh {
        return .{
            .vertices = std.ArrayList(Vertex).init(allocator),
            .indices = std.ArrayList(u32).init(allocator),
            .textures = std.ArrayList(tx.TextureView).init(allocator),
        };
    }
};

pub const Model = struct {
    total_vertex_count: u32,
    total_index_count: u32,
    meshes: std.ArrayList(Mesh),

    pub fn release(self: Model) void {
        self.vertices.deinit();
        self.indices.deinit();
        self.textures.deinit();
    }

    fn processNode(model: *Model, path: [:0]const u8, node: *ai.Node, scene: *ai.Scene, allocator: std.mem.Allocator) !void {
        try model.meshes.ensureTotalCapacity(node.num_meshes);
        for (node.meshes[0..node.num_meshes]) |idx_mesh| {
            const mesh = scene.meshes[idx_mesh];
            try model.meshes.append(try model.processMesh(path, mesh, scene, allocator));
        }

        for (node.children[0..node.num_children]) |child| {
            try model.processNode(path, child, scene, allocator);
        }
    }

    fn processMesh(model: *Model, path: [:0]const u8, mesh: *ai.Mesh, scene: *const ai.Scene, allocator: std.mem.Allocator) !Mesh {
        var m = Mesh.create(allocator);
        try m.vertices.ensureTotalCapacity(mesh.num_vertices);
        model.total_vertex_count += mesh.num_vertices;
        for (0..mesh.num_vertices) |i| {
            const x: f32 = @floatCast(mesh.vertices[i].x);
            const y: f32 = @floatCast(mesh.vertices[i].y);
            const z: f32 = @floatCast(mesh.vertices[i].z);
            const nx: f32 = @floatCast(mesh.normals[i].x);
            const ny: f32 = @floatCast(mesh.normals[i].y);
            const nz: f32 = @floatCast(mesh.normals[i].z);
            try m.vertices.append(.{
                .pos = .{ x, y, z },
                .normal = .{ nx, ny, nz },
                .uv = .{ 0, 0 },
            });
            if (mesh.texture_coords[0]) |tex_coords| {
                const u: f32 = @floatCast(tex_coords[i].x);
                const v: f32 = @floatCast(tex_coords[i].y);
                m.vertices.items[i].uv = .{ u, v };
            }
        }

        for (mesh.faces[0..mesh.num_faces]) |face| {
            const start = m.indices.items.len;
            try m.indices.ensureTotalCapacity(start + face.num_indices);
            model.total_index_count += face.num_indices;
            for (face.indices[0..face.num_indices]) |idx| {
                try m.indices.append(@intCast(idx));
            }
        }

        if (mesh.material_index >= 0) {
            const material = scene.materials[mesh.material_index];
            const diffuse_count = material.getTextureCount(.diffuse);
            const specular_count = material.getTextureCount(.specular);
            try m.textures.ensureTotalCapacity(m.textures.items.len + diffuse_count + specular_count);
            inline for (.{
                .{diffuse_count, tx.TextureType.diffuse, ai.TextureType.diffuse}, 
                .{specular_count, tx.TextureType.specular, ai.TextureType.specular},
            }) |x| {
                for (0..x[0]) |i| {

                    var str: ai.String = .{};
                    _ = material.getTexture(ai.Material.GetTextureInfo {
                        .tex_type = x[2],
                        .index = @intCast(i),
                        .path = &str,
                    });

                    const tex_identifier: [:0]u8 = str.data[0..str.len :0];
                    if (scene.getEmbeddedTexture(tex_identifier.ptr)) |tex| {
                        var handle: tx.Handle = undefined;
                        if (tex.height == 0) {
                            const data = std.mem.sliceAsBytes(tex.pc_data[0..tex.width]);
                            handle = try gpu.createTextureFromImageMemory(tex_identifier, data); 
                        }
                        else {
                            const data = std.mem.sliceAsBytes(tex.pc_data[0..tex.width * tex.height]);
                            handle = try gpu.createTextureFromMemory(tex_identifier, .{
                                .w = tex.width, .h = tex.height, .d = 4,
                                .data = data,
                                .format = .b8g8r8a8_unorm
                            });
                        }
                        try m.textures.append(tx.TextureView {
                            .hdl = handle,
                            .tex_type = x[1],
                        });
                        std.debug.assert(handle.is_valid());
                    } else { // Texture is a relative path
                        const tex_path: [:0]u8 = try std.fs.path.joinZ(allocator, &[_][]const u8 { std.fs.path.dirname(path).?, tex_identifier});
                        defer allocator.free(tex_path);
                        const handle = try gpu.createTextureFromFile(tex_path);
                        try m.textures.append(tx.TextureView {
                            .hdl = handle,
                            .tex_type = x[1],
                        });
                    }
                }
            }

        }

        return m;
    }
};

pub fn load(path: [:0]const u8, allocator: std.mem.Allocator) !Model {
    var scene = ai.importFile(path, .{ 
        .triangulate = true, 
        .split_large_meshes = true,
        .embed_textures = true,
        .flip_uvs = true,
    });
    defer scene.release();

    var model = Model {
        .total_index_count = 0,
        .total_vertex_count = 0,
        .meshes = std.ArrayList(Mesh).init(allocator),
    };

    try model.processNode(path, scene.root_node, scene, allocator);

    return model;
}