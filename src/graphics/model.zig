const std = @import("std");
const ai = @import("assimp/assimp.zig");
const gpu = @import("gpu.zig");
const hyarena = @import("../genarray.zig");
const texture = @import("texture.zig");
const Vertex = @import("vertex.zig").Vertex;

pub const Arena = hyarena.GenArray(Model);
pub const Handle = Arena.Handle;

pub const Mesh = struct {
    vertices: std.ArrayList(Vertex),
    indices: std.ArrayList(u16),
    textures: std.ArrayList(texture.TextureView),

    pub fn create(allocator: std.mem.Allocator) Mesh {
        return .{
            .vertices = std.ArrayList(Vertex).init(allocator),
            .indices = std.ArrayList(u16).init(allocator),
            .textures = std.ArrayList(texture.TextureView).init(allocator),
        };
    }
};

pub const Model = struct {
    meshes: std.ArrayList(Mesh),

    pub fn load(path: [:0]const u8, allocator: std.mem.Allocator) !Model {
        var data = ai.importFile(path.ptr, .{ .triangulate = true, .flip_uvs = true });
        defer data.release();

        var model = Model {
            .meshes = std.ArrayList(Mesh).init(allocator),
        };

        const scene = ai.importFile(path, .{
            .triangulate = true
        });

        try model.processNode(scene.root_node, scene, allocator);

        return model;
    }

    pub fn release(self: Model) void {
        self.vertices.deinit();
        self.indices.deinit();
        self.textures.deinit();
    }

    fn processNode(model: *Model, node: *ai.Node, scene: *ai.Scene, allocator: std.mem.Allocator) !void {
        try model.meshes.ensureTotalCapacity(node.num_meshes);
        for (node.meshes[0..node.num_meshes]) |idx_mesh| {
            const mesh = scene.meshes[idx_mesh];
            try model.meshes.append(try processMesh(model, mesh, scene, allocator));
        }

        for (node.children[0..node.num_children]) |child| {
            try model.processNode(child, scene, allocator);
        }
    }

    fn processMesh(model: *Model, mesh: *ai.Mesh, scene: *const ai.Scene, allocator: std.mem.Allocator) !Mesh {
        _ = model;
        var m = Mesh.create(allocator);
        try m.vertices.ensureTotalCapacity(mesh.num_vertices);
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
                .{diffuse_count, "tex_diffuse"}, 
                .{specular_count, "tex_specular"},
            }) |x| {
                for (0..x[0]) |i| {

                    var str: ai.String = .{};
                    _ = material.getTexture(ai.Material.GetTextureInfo {
                        .tex_type = .diffuse,
                        .index = @intCast(i),
                        .path = &str,
                    });

                    const handle = try gpu.createTexture(str.data[0..str.len:0]);
                    try m.textures.append(texture.TextureView {
                        .hdl = handle,
                        .tex_type = x[1],
                        .path = str.data[0..str.data.len:0],
                    });
                }
            }

                // for (0..x[0]) |i| {

                //     var str: ai.String = undefined;
                //     _ = material.getTexture(ai.Material.GetTextureInfo {
                //         .tex_type = .specular,
                //         .index = @intCast(i),
                //         .path = &str,
                //     });

                //     const handle = try gpu.createTexture(str.data[0..str.data.len:0]);
                //     try m.textures.append(texture.TextureView {
                //         .id = handle,
                //         .tex_type = "tex_specular",
                //         .path = str.data[0..str.data.len:0],
                //     });

                // }
            // }

        }

        return m;
    }
};

