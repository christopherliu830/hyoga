const std = @import("std");
const sdl = @import("sdl");
const ai = @import("assimp");

const hy = @import("hyoga-lib");
const SlotMap = hy.SlotMap;
const mat4 = hy.math.mat4;

const Gpu = @import("gpu.zig");
const buf = @import("buffer.zig");
const mt = @import("material.zig");
const Loader = @import("loader.zig");
const tx = @import("texture.zig");
const Vertex = @import("vertex.zig").Vertex;
const Strint = @import("../strintern.zig");

pub const Arena = SlotMap(ImportModel);
pub const Handle = SlotMap(?Model).Handle;

const Buffer = buf.VertexIndexBuffer;

const ModelLoadJob = struct {
    allocator: std.mem.Allocator,
    dest_hdl: Handle,
    scene: *ai.Scene,
    mats: []mt.Handle,
    settings: ImportSettings,

    const Result = struct {
        job: ModelLoadJob,
        model: Model,
    };

    pub fn deinit(self: @This()) void {
        self.allocator.free(self.mats);
        self.scene.release();
    }
};

const Queue = Loader.Queue(ModelLoadJob.Result);

pub const Models = struct {
    allocator: std.mem.Allocator,
    queue: Queue,
    models: SlotMap(?Model),
    strint: *Strint,
    loader: *Loader,

    pub fn create(loader: *Loader, strint: *Strint, allocator: std.mem.Allocator) !Models {
        var m: Models = undefined;
        m.allocator = allocator;
        m.queue.init(allocator);
        m.strint = strint;
        m.loader = loader;
        m.models = try SlotMap(?Model).create(allocator, 1);
        return m;
    }

    pub fn deinit(self: *@This()) void {
        self.flushQueue() catch std.debug.panic("Could not flush queue", .{});
        const gpu: *Gpu = @alignCast(@fieldParentPtr("models", self));

        if (self.models.len > 0) {
            var it = self.models.iterator();
            while (it.next()) |q_entry| {
                if (q_entry) |entry| {
                    gpu.device.releaseBuffer(entry.root_buffer.hdl);
                    self.allocator.free(entry.children);
                }
            }
            self.models.deinit();
        }
    }

    pub fn get(self: *@This(), id: Handle) !*Model {
        try self.flushQueue();
        const ptr = try self.models.getPtr(id);
        if (ptr.* == null) return error.ModelNotLoaded;
        return &(ptr.*.?);
    }

    /// This function will return a handle to an initially null slot in the models array.
    /// Once the model is finished loading, the handle's value will be set to the model
    /// data. Trying to get the model before it's finished loading will return an error.
    pub fn read(self: *@This(), scene: *ai.Scene, mats: []mt.Handle, import: ImportSettings) !Handle {
        const hdl = try self.models.insert(null);

        const job = ModelLoadJob {
            .dest_hdl = hdl,
            .allocator = self.allocator,
            .scene = scene,
            .mats = try self.allocator.dupe(mt.Handle, mats),
            .settings = import,
        };

        try self.loader.run(&self.queue, doRead, .{self, job});

        return hdl;
    }

    pub fn waitLoad(self: *@This(), model: Handle, time: u64) bool {
        var timer = std.time.Timer.start() catch unreachable;
        while (time == 0 or timer.read() < time) {
            if (self.get(model)) |_| return true else |_| continue;
        }
        return false;
    }

    fn flushQueue(self: *@This()) !void {
        while (self.queue.pop()) |result| {
            const model = try self.models.getPtr(result.job.dest_hdl);
            model.* = result.model;
            result.job.deinit();
        }
    }

    fn doRead(queue: *Queue, self: *Models, job: ModelLoadJob) void {
        const gpu: *Gpu = @alignCast(@fieldParentPtr("models", self));
        const device = gpu.device;

        const allocator = self.queue.tsa.allocator();

        // Process scene node tree into a big array of meshes
        var bounds = hy.math.AxisAligned {
            .min = hy.math.vec3.zero,
            .max = hy.math.vec3.zero,
        };

        var in_model: ImportModel = .{
            .total_index_count = 0,
            .total_vertex_count = 0,
            .meshes = .{},
            .transform = job.settings.transform,
        };

        in_model.processNode(.{
            .allocator = allocator,
            .scene = job.scene,
            .node = job.scene.root_node,
            .materials = job.mats,
            .root_bounds = &bounds,
        }) catch |err| {
            std.log.err("[GPU] model load failure: {}", .{err});
        };

        defer in_model.deinit(allocator);

        const vtx_buf_size = in_model.total_vertex_count * @sizeOf(Vertex);
        const idx_buf_size = in_model.total_index_count * @sizeOf(u32);

        const hdl = device.createBuffer(&.{
            .usage = .{ .index = true, .vertex = true },
            .size = vtx_buf_size + idx_buf_size,
        }).?;

        const root_buffer = Buffer {
            .hdl = hdl,
            .size = vtx_buf_size + idx_buf_size,
            .idx_start = vtx_buf_size,
        };

        var buf_offset: usize = 0;

        const children = allocator.alloc(Mesh, in_model.meshes.items.len) catch {
            std.debug.panic("out of memory", .{});
        };

        for (in_model.meshes.items, 0..) |mesh, i| {
            const mesh_vbuf_size = mesh.vertices.items.len * @sizeOf(Vertex);
            const mesh_ibuf_size = mesh.indices.items.len * @sizeOf(u32);
            gpu.uploadToBuffer(root_buffer.hdl, @intCast(buf_offset), std.mem.sliceAsBytes(mesh.vertices.items))
                catch std.debug.panic("model load error");
            gpu.uploadToBuffer(root_buffer.hdl, @intCast(buf_offset + root_buffer.idx_start), std.mem.sliceAsBytes(mesh.indices.items))
                catch std.debug.panic("model load error");
            children[i] = .{
                .buffer = .{
                    .hdl = hdl,
                    .size = @intCast(mesh_vbuf_size + mesh_ibuf_size),
                    .offset = @intCast(buf_offset),
                    .idx_start = @intCast(buf_offset + mesh_vbuf_size),
                },
                .material = mesh.material,
            };
            buf_offset += mesh_vbuf_size;
        }

        queue.push(.{
            .job = job,
            .model = .{
                .root_buffer = root_buffer,
                .children = children,
                .bounds = bounds,
            },
        }) catch |err| std.log.err("[GPU] model load failure: {}", .{err});
    }
};

pub const Model = struct {
    bounds: hy.math.AxisAligned,
    root_buffer: Buffer,
    children: []Mesh,
    transform: mat4.Mat4 = mat4.identity,
};

pub const Mesh = struct {
    buffer: Buffer,
    material: mt.Handle = mt.Handle.invalid,

};

const ImportMesh = struct {
    vertices: std.ArrayListUnmanaged(Vertex) = .{},
    indices: std.ArrayListUnmanaged(u32) = .{},
    material: mt.Handle,

    pub fn deinit(self: *ImportMesh, allocator: std.mem.Allocator) void {
        self.vertices.deinit(allocator);
        self.indices.deinit(allocator);
    }
};

const ImportModel = struct {
    total_vertex_count: u32 = 0,
    total_index_count: u32 = 0,
    buffer: ?Buffer = null,
    meshes: std.ArrayListUnmanaged(ImportMesh) = .{},
    transform: mat4.Mat4 = mat4.identity,

    pub fn deinit(self: ImportModel, allocator: std.mem.Allocator) void {
        for (self.meshes.items) |*mesh| { 
            mesh.deinit(allocator);
        }
        allocator.free(self.meshes.allocatedSlice());
    }

    pub const ProcessModelParams = struct {
        allocator: std.mem.Allocator,
        node: *ai.Node, // Current processing node
        mesh: ?*ai.Mesh = null, // Current processing mesh
        scene: *ai.Scene, // Root scene
        materials: []mt.Handle, // Root materials
        root_bounds: *hy.math.AxisAligned,
    };

    pub fn deepCopy(old: ImportModel, allocator: std.mem.Allocator) !ImportModel {
        var copy: ImportModel = .{
            .total_index_count = old.total_index_count,
            .total_vertex_count = old.total_vertex_count,
        };

        try copy.meshes.ensureTotalCapacity(allocator, old.meshes.items.len);
        errdefer allocator.destroy(copy);

        for (old.meshes.items) |mesh| {
            const v = try allocator.dupe(Vertex, mesh.vertices.items);
            var vertices = std.ArrayListUnmanaged(Vertex).fromOwnedSlice(v);
            errdefer vertices.deinit(allocator);
            const i = try allocator.dupe(u32, mesh.indices.items);
            var indices = std.ArrayListUnmanaged(u32).fromOwnedSlice(i);
            errdefer indices.deinit(allocator);

            copy.meshes.appendAssumeCapacity(.{
                .vertices = vertices,
                .indices = indices,
                .material = mesh.material,
            });
        }

        return copy;
    }

    fn processNode(self: *ImportModel, params: ProcessModelParams) !void {
        const node = params.node;
        try self.meshes.ensureTotalCapacity(params.allocator, node.num_meshes);
        for (node.meshes[0..node.num_meshes]) |idx_mesh| {
            const mesh = params.scene.meshes[idx_mesh];

            var sub = params;
            sub.mesh = mesh;
            try self.meshes.append(params.allocator, try self.processMesh(sub));

            const a = mesh.aabb.min;
            const b = mesh.aabb.max;
            const c = params.root_bounds.min;
            const d = params.root_bounds.max;
            const min_x = @min(@min(a.x, b.x), c.x());
            const min_y = @min(@min(a.y, b.y), c.y());
            const min_z = @min(@min(a.z, b.z), c.z());
            const max_x = @max(@max(a.x, b.x), d.x());
            const max_y = @max(@max(a.y, b.y), d.y());
            const max_z = @max(@max(a.z, b.z), d.z());
            params.root_bounds.min = hy.math.vec3.create(min_x, min_y, min_z);
            params.root_bounds.max = hy.math.vec3.create(max_x, max_y, max_z);

            errdefer self.deinit();
        }


        for (node.children[0..node.num_children]) |child| {
            var sub = params;
            sub.node = child;
            try self.processNode(sub);
            errdefer self.deinit();
        }
    }

    fn processMesh(model: *ImportModel, params: ProcessModelParams) !ImportMesh {
        const in_mesh = params.mesh.?;

        var out_mesh = ImportMesh { .material = params.materials[in_mesh.material_index] };
        try out_mesh.vertices.ensureTotalCapacity(params.allocator, in_mesh.num_vertices);
        model.total_vertex_count += in_mesh.num_vertices;

        for (0..in_mesh.num_vertices) |i| {
            const x: f32 = @floatCast(in_mesh.vertices[i].x);
            const y: f32 = @floatCast(in_mesh.vertices[i].y);
            const z: f32 = @floatCast(in_mesh.vertices[i].z);
            const nx: f32 = @floatCast(in_mesh.normals[i].x);
            const ny: f32 = @floatCast(in_mesh.normals[i].y);
            const nz: f32 = @floatCast(in_mesh.normals[i].z);

            out_mesh.vertices.append(params.allocator, .{
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
            try out_mesh.indices.ensureTotalCapacity(params.allocator, start + face.num_indices);
            model.total_index_count += face.num_indices;
            for (face.indices[0..face.num_indices]) |idx| {
                out_mesh.indices.append(params.allocator, @intCast(idx)) catch unreachable;
            }
        }

        return out_mesh;
    }
};

pub const ImportSettings = extern struct {
    transform: mat4.Mat4 = mat4.identity,
    post_process: ai.PostProcessSteps,
};
