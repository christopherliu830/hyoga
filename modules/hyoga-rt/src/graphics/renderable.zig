const std = @import("std");
const sdl = @import("sdl");
const hy = @import("hyoga-lib");
const mat4 = hy.math.mat4;

const SlotMap = @import("hyoga-lib").SlotMap;
const Gpu = @import("gpu.zig");
const mt = @import("material.zig");

const mdl = @import("model.zig");
const Model = mdl.Model;
const ModelHandle = mdl.Handle;

const RenderItems = SlotMap(Renderable);

pub const RenderItemHandle = RenderItems.Handle;

pub const PackedRenderables = struct {
    transforms: []mat4.Mat4,
    handles: std.AutoHashMapUnmanaged(RenderItemHandle, u32),
    meshes: []mdl.Mesh,
    instance_counts: []u32,
    len: u32,
};

pub const Renderable = struct {
    next: ?RenderItemHandle = null, // When models are imported as a group, support adds and removes via this link.
    mesh: mdl.Mesh,
    transform: mat4.Mat4 = mat4.identity, // Set on import and does not change.
    parent_transform: *const mat4.Mat4 = &mat4.identity,

    pub fn lessThan(_: void, lhs: Renderable, rhs: Renderable) bool {
        if (lhs.mesh.buffer.eql(rhs.mesh.buffer))
            return lhs.mesh.material.index < rhs.mesh.material.index
        else
            return @as(usize, @intFromPtr(lhs.mesh.buffer.hdl)) < 
                   @as(usize, @intFromPtr(rhs.mesh.buffer.hdl));
    }

    pub fn eql(lhs: Renderable, rhs: Renderable) bool {
        return lhs.mesh.buffer.eql(rhs.mesh.buffer) and
            lhs.mesh.material.index == rhs.mesh.material.index;
    }
};

/// A wrapper around a list of renderables, in order to support
/// group-based insertions and deletions.
pub const RenderList = struct {
    const RenderableWithHandle = struct {
        renderable: Renderable,
        handle: RenderItemHandle,

        fn lessThan(_: void, lhs: @This(), rhs: @This()) bool {
            return Renderable.lessThan({}, lhs.renderable, rhs.renderable);
        }
    };

    gpu: *Gpu,
    items: RenderItems,

    pub const Iterator = RenderItems.ValidItemsIterator;

    pub fn init(gpu: *Gpu, allocator: std.mem.Allocator) !RenderList {
        return .{
            .gpu = gpu,
            .items = try RenderItems.create(allocator, 8),
        };
    }

    pub const AddModelOptions = extern struct {
        owner: *mat4.Mat4,
        time: u64, 
        model: ModelHandle,
    };

    pub fn add(self: *RenderList, options: AddModelOptions) !RenderItemHandle {
        const q_model = blk: {
            var model = self.gpu.models.get(options.model)
                catch null;
                // catch |e| if (e != error.ModelEmpty) return e else null;

            if (options.time > 0) {
                var timer = try std.time.Timer.start();
                while (model == null and timer.read() < options.time) {
                    model = self.gpu.models.get(options.model) 
                        catch null;
                        //catch |e| if (e != error.ModelEmpty) return e else null;
                }
            }
            break :blk model;
        };

        if (q_model) |model| {
            var head: ?RenderItemHandle = null;
            for (model.children) |mesh| {
                const renderable = Renderable {
                    .mesh = mesh,
                    .transform = model.transform,
                    .parent_transform = options.owner,
                    .next = head,
                };
                head = try self.items.insert(renderable);
            }
            if (head) |h| return h else return error.ModelEmpty;
        }

        return error.InvalidModel;
    }

    pub fn remove(self: *RenderList, hdl: RenderItemHandle) void {
        var head_hdl: ?RenderItemHandle = hdl;
        while (head_hdl) |node_hdl| {
            const head: ?Renderable = self.items.get(node_hdl) catch null;
            if (head) |h| {
                head_hdl = h.next;
                self.items.remove(node_hdl);
            }
        }
    }

    pub inline fn iterator(self: *RenderList) Iterator {
        return self.items.iterator();
    } 

    /// Caller must free the returned slice.
    pub fn pack(self: *RenderList, handles: []RenderItemHandle, allocator: std.mem.Allocator) !PackedRenderables {
        const SwapContext = struct {
            handles: []RenderItemHandle,
            renderables: []Renderable,

            pub fn lessThan(ctx: @This(), a: usize, b: usize) bool {
                return Renderable.lessThan({}, ctx.renderables[a], ctx.renderables[b]);
            }

            pub fn swap(ctx: @This(), a: usize, b: usize) void {
                std.mem.swap(Renderable, &ctx.renderables[a], &ctx.renderables[b]);
                std.mem.swap(RenderItemHandle, &ctx.handles[a], &ctx.handles[b]);
            }
        };

        const renderables = try allocator.alloc(Renderable, handles.len);

        for (handles, 0..) |hdl, i| {
            renderables[i] = try self.items.get(hdl);
        }

        defer allocator.free(renderables);

        const transforms = try allocator.alloc(mat4.Mat4, handles.len);
        errdefer allocator.free(transforms);
        const material_ids = try allocator.alloc(mt.Handle, handles.len);
        errdefer allocator.free(material_ids);
        const meshes = try allocator.alloc(mdl.Mesh, handles.len);
        errdefer allocator.free(meshes);
        const instance_counts = try allocator.alloc(u32, handles.len);
        errdefer allocator.free(instance_counts);
        var handle_map: std.AutoHashMapUnmanaged(RenderItemHandle, u32) = .{};
        errdefer handle_map.deinit(allocator);

        std.sort.heapContext(0, handles.len, SwapContext { .renderables = renderables, .handles = handles });

        var dst: u32 = 0;
        for (0..handles.len) |i| {
            const handle = handles[i];
            const renderable = renderables[i];
            try handle_map.put(allocator, handle, @intCast(i));
            transforms[i] = renderable.parent_transform.*.mul(renderable.transform);

            if (dst != 0 and renderable.eql(renderables[i-1])) {
                instance_counts[dst-1] += 1;
            } else {
                meshes[dst] = renderable.mesh;
                instance_counts[dst] = 1;
                dst += 1;
            }
        }

        return .{
            .transforms = transforms,
            .meshes = meshes,
            .instance_counts = instance_counts,
            .len = dst,
            .handles = handle_map,
        };
    }

    pub fn packAll(self: *RenderList, allocator: std.mem.Allocator) !PackedRenderables {
        const handles = try allocator.alloc(RenderItemHandle, self.items.len); 
        for (0..self.items.len) |i| { handles[i] = self.items.handle_at(@intCast(i)) catch unreachable; }
        return try self.pack(handles, allocator);
    }
};

