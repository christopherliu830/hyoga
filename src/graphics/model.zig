const std = @import("std");
const ai = @import("assimp/assimp.zig");
const texture = @import("texture.zig");
const Vertex = @import("vertex.zig").Vertex;

pub const Mesh = struct {
    vertices: std.ArrayList(Vertex),
    indices: std.ArrayList(u16),
    textures: std.ArrayList(texture.Handle),

    pub fn create(allocator: std.mem.Allocator) Mesh {
        return .{
            .vertices = std.ArrayList(Vertex).init(allocator),
            .indices = std.ArrayList(u16).init(allocator),
            .textures = std.ArrayList(texture.Handle).init(allocator),
        };
    }
};

pub const Model = struct {
    meshes: std.ArrayList(Mesh),

    pub fn load(path: [:0]const u8, allocator: std.mem.Allocator) Model {
        const data = ai.importFile(path.ptr, .{ .triangulate = true, .flip_uvs = true });
        defer data.release();

        const model = Model {
            .meshes = std.ArrayList(Mesh).init(allocator),
        };

        const scene = ai.importFile(path, .{
            .triangulate = true
        });

        model.processNode(scene.root_node, scene);

        return model;
    }

    pub fn release(self: Model) void {
        self.vertices.deinit();
        self.indices.deinit();
        self.textures.deinit();
    }

    fn processNode(model: *Model, node: *ai.Node, scene: *ai.Scene, allocator: std.mem.Allocator) void {
        model.meshes.resize(node.num_meshes);
        for (node.meshes[0..node.num_meshes], 0..) |idx_mesh, i| {
            const mesh = scene.meshes[idx_mesh];
            model.meshes[i] = processMesh(model, mesh, scene, allocator);
        }

        for (node.children[0..node.num_children]) |child| {
            processNode(model, child, scene);
        }
    }

    fn processMesh(model: *Model, mesh: *ai.Mesh, scene: *ai.Scene, allocator: std.mem.Allocator) Mesh {
        const m = Mesh.create(allocator);
        m.vertices.resize(mesh.num_vertices);
        for (mesh.vertices[0..mesh.num_vertices], 0..) |vertex, i| {
            m.vertices[i] = .{
                .position = vertex.position
            };
        }
    }
    
};

