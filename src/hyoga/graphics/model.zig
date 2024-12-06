const std = @import("std");
const sdl = @import("sdl");
const hya = @import("hyoga-arena");
const ai = @import("assimp");
const gpu = @import("gpu.zig");
const mt = @import("material.zig");
const ld = @import("loader.zig");
const tx = @import("texture.zig");
const Vertex = @import("vertex.zig").Vertex;
const mat4 = @import("hyoga-math").mat4;
const sym = @import("../symbol.zig");

pub const Arena = hya.Arena(Model);
pub const Handle = sym.Symbol;

const ModelLoadJob = struct {
    id: sym.Symbol,
    mats: []mt.Handle,
    settings: ImportSettings,
};

const ModelLoadResult = struct {
    model: Model,
    id: sym.Symbol,
    mats: []mt.Handle,
};

const Queue = ld.Queue(ModelLoadResult);

pub const Models = struct {
    allocator: std.mem.Allocator,
    device: *sdl.gpu.Device,
    queue: Queue = .{},
    models: std.AutoHashMapUnmanaged(sym.Symbol, Model) = .{},

    pub fn deinit(self: *@This()) void {
        self.flushQueue() catch std.debug.panic("Could not flush queue", .{});
        var it = self.models.valueIterator();
        while (it.next()) |entry| {
            entry.deinit();
        }
        self.models.deinit(self.allocator);
    }

    pub fn get(self: *@This(), id: sym.Symbol) !?*Model {
        try self.flushQueue();
        return self.models.getPtr(id);
    }

    pub fn read(self: *@This(), path: sym.Symbol, mats: []mt.Handle, import: ImportSettings) !sym.Symbol {
        const own_mats = try self.allocator.dupe(mt.Handle, mats);

        const job = ModelLoadJob {
            .mats = own_mats,
            .id = path,
            .settings = import,
        };

        try ld.run(&self.queue, readModel, .{job});
        return path;
    }

    fn flushQueue(self: *@This()) !void {
        while (self.queue.pop()) |val| {
            self.allocator.free(val.mats);
            try self.models.put(self.allocator, val.id, val.model);
        }
    }

    fn readModel(queue: *Queue, job: ModelLoadJob, allocator: std.mem.Allocator) void {
        const pathz = job.id.asStringZ();
        var scene = ai.importFile(pathz, job.settings.post_process);
        defer scene.release();

        var model = Model {
            .allocator = allocator,
            .total_index_count = 0,
            .total_vertex_count = 0,
            .meshes = .{},
            .transform = job.settings.transform,
        };

        model.processNode(.{
            .path = pathz,
            .scene = scene,
            .node = scene.root_node,
            .materials = job.mats,
        }) catch |err| {
            std.log.err("[GPU] model load failure: {}", .{err});
        };

        errdefer model.deinit();

        queue.push(ModelLoadResult {
            .model = model,
            .id = job.id,
            .mats = job.mats,
        }) catch |err| std.log.err("[GPU] model load failure: {}", .{err});
    }
};

pub const Mesh = struct {
    vertices: std.ArrayListUnmanaged(Vertex) = .{},
    indices: std.ArrayListUnmanaged(u32) = .{},
    material: mt.Handle,

    pub fn deinit(self: *Mesh, allocator: std.mem.Allocator) void {
        self.vertices.deinit(allocator);
        self.indices.deinit(allocator);
    }
};

pub const Model = struct {
    allocator: std.mem.Allocator,
    total_vertex_count: u32,
    total_index_count: u32,
    meshes: std.ArrayListUnmanaged(Mesh) = .{},
    transform: mat4.Mat4,

    pub fn deinit(self: *Model) void {
        for (self.meshes.items) |*mesh| { 
            mesh.deinit(self.allocator);
        }
        self.meshes.deinit(self.allocator);
    }

    pub const ProcessModelParams = struct {
        path: [:0]const u8,
        scene: *ai.Scene,
        node: *ai.Node,
        mesh: ?*ai.Mesh = null,
        materials: []mt.Handle,
    };

    fn processNode(self: *Model, params: ProcessModelParams) !void {
        const node = params.node;
        try self.meshes.ensureTotalCapacity(self.allocator, node.num_meshes);
        for (node.meshes[0..node.num_meshes]) |idx_mesh| {
            const mesh = params.scene.meshes[idx_mesh];
            var sub = params;
            sub.mesh = mesh;
            try self.meshes.append(self.allocator, try self.processMesh(sub));
            errdefer self.deinit();
        }


        for (node.children[0..node.num_children]) |child| {
            var sub = params;
            sub.node = child;
            try self.processNode(sub);
            errdefer self.deinit();
        }
    }

    fn processMesh(model: *Model, params: ProcessModelParams) !Mesh {
        const in_mesh = params.mesh.?;

        var out_mesh = Mesh { .material = params.materials[in_mesh.material_index], };
        try out_mesh.vertices.ensureTotalCapacity(model.allocator, in_mesh.num_vertices);
        model.total_vertex_count += in_mesh.num_vertices;

        for (0..in_mesh.num_vertices) |i| {
            const x: f32 = @floatCast(in_mesh.vertices[i].x);
            const y: f32 = @floatCast(in_mesh.vertices[i].y);
            const z: f32 = @floatCast(in_mesh.vertices[i].z);
            const nx: f32 = @floatCast(in_mesh.normals[i].x);
            const ny: f32 = @floatCast(in_mesh.normals[i].y);
            const nz: f32 = @floatCast(in_mesh.normals[i].z);

            out_mesh.vertices.append(model.allocator, .{
                .pos = .{ x, y, z },
                .normal = .{ nx, ny, nz },
                .uv = .{ 0, 0 },
            }) catch unreachable;

            if (in_mesh.texture_coords[0]) |tex_coords| {
                const u: f32 = @floatCast(tex_coords[i].x);
                const v: f32 = @floatCast(tex_coords[i].y);
                out_mesh.vertices.items[i].uv = .{ u, v };
            }
        }

        for (in_mesh.faces[0..in_mesh.num_faces]) |face| {
            const start = out_mesh.indices.items.len;
            try out_mesh.indices.ensureTotalCapacity(model.allocator, start + face.num_indices);
            model.total_index_count += face.num_indices;
            for (face.indices[0..face.num_indices]) |idx| {
                out_mesh.indices.append(model.allocator, @intCast(idx)) catch unreachable;
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
