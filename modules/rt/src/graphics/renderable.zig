const std = @import("std");
const sdl = @import("sdl");
const hy = @import("hyoga-lib");
const mt = @import("material.zig");
const mdl = @import("model.zig");

const SlotMap = @import("hyoga-lib").SlotMap;
const Gpu = @import("gpu.zig");
const Mesh = mdl.Mesh;
const Model = mdl.Model;
const ModelHandle = mdl.Handle;
const Mat4 = hy.math.Mat4;

const RenderItems = SlotMap(Renderable);

pub const RenderItemHandle = RenderItems.Handle;

pub const PackedRenderables = struct {
    // Filled with every renderable
    transforms: []Mat4, // Sorted transforms

    // Only filled to number of instances
    meshes: []mdl.Mesh, // Mesh for each idx in transforms array.
    instance_counts: []u32, // Number of instances for same index in transforms
    hdls: []RenderItemHandle,
    len: u32,
};

pub const Renderable = struct {
    next: ?RenderItemHandle = null, // When models are imported as a group, support adds and removes via this link.
    mesh: Mesh,
    import_transform: Mat4 = .identity, // Set on import and does not change.

    pub fn lessThan(_: void, lhs: Renderable, rhs: Renderable) bool {
        if (lhs.mesh.buffer.eql(rhs.mesh.buffer))
            return lhs.mesh.material.index < rhs.mesh.material.index
        else
            return @as(usize, @intFromPtr(lhs.mesh.buffer.hdl)) <
                @as(usize, @intFromPtr(rhs.mesh.buffer.hdl));
    }

    // Does not account for transform differences
    pub fn eql(lhs: Renderable, rhs: Renderable) bool {
        return lhs.mesh.buffer.eql(rhs.mesh.buffer) and
            lhs.mesh.material.index == rhs.mesh.material.index;
    }
};

/// A wrapper around a list of renderables, in order to support
/// group-based insertions and deletions.
pub const RenderList = struct {
    gpu: *Gpu,
    items: RenderItems,

    pub const Iterator = RenderItems.ValidItemsIterator;

    pub fn init(gpu: *Gpu, allocator: std.mem.Allocator) RenderList {
        return .{
            .gpu = gpu,
            .items = RenderItems.create(allocator, 8) catch hy.err.oom(),
        };
    }

    pub const AddOptions = extern struct {
        model: ModelHandle,
        time: u64 = 0,

        comptime {
            hy.meta.assertMatches(AddOptions, hy.runtime.gpu.AddRenderableOptions);
        }
    };

    pub fn add(self: *RenderList, options: AddOptions) !RenderItemHandle {
        const q_model = blk: {
            var model = self.gpu.models.get(options.model) catch null;

            if (options.time > 0) {
                var timer = try std.time.Timer.start();
                while (model == null and timer.read() < options.time) {
                    model = self.gpu.models.get(options.model) catch null;
                }
            }
            break :blk model;
        };

        if (q_model) |model| {
            var head: ?RenderItemHandle = null;
            for (model.children) |mesh| {
                const renderable: Renderable = .{
                    .mesh = mesh,
                    .import_transform = model.transform,
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
    pub fn pack(self: *RenderList, handles: []const RenderItemHandle, allocator: std.mem.Allocator) !PackedRenderables {
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

        const hdls = try allocator.dupe(RenderItemHandle, handles);
        errdefer allocator.free(hdls);

        const renderables = try allocator.alloc(Renderable, handles.len);

        for (handles, 0..) |hdl, i| {
            renderables[i] = try self.items.get(hdl);
        }

        defer allocator.free(renderables);

        const transforms = try allocator.alloc(Mat4, handles.len);
        errdefer allocator.free(transforms);

        std.sort.heapContext(0, renderables.len, SwapContext{ .renderables = renderables, .handles = hdls });

        const num_distinct = blk: {
            var count: usize = 1;
            for (1..renderables.len) |i| {
                if (!renderables[i].eql(renderables[i - 1])) {
                    count += 1;
                }
            }
            break :blk count;
        };

        const material_ids = try allocator.alloc(mt.Handle, num_distinct);
        errdefer allocator.free(material_ids);
        const meshes = try allocator.alloc(mdl.Mesh, num_distinct);
        errdefer allocator.free(meshes);
        const instance_counts = try allocator.alloc(u32, num_distinct);
        errdefer allocator.free(instance_counts);
        var instance_hdls = try allocator.alloc(RenderItemHandle, num_distinct);
        errdefer allocator.free(instance_hdls);

        var distinct_transform_idx: u32 = 0;
        for (0..renderables.len) |i| {
            const renderable = renderables[i];
            std.debug.print("{}\n", .{renderable.mesh});

            transforms[i] = renderable.import_transform;

            if (distinct_transform_idx == 0 or !renderable.eql(renderables[i - 1])) {
                meshes[distinct_transform_idx] = renderable.mesh;
                instance_counts[distinct_transform_idx] = 1;
                instance_hdls[distinct_transform_idx] = hdls[i];
                distinct_transform_idx += 1;
            } else {
                instance_counts[distinct_transform_idx - 1] += 1;
            }
        }

        return .{
            .transforms = transforms,
            .meshes = meshes,
            .instance_counts = instance_counts,
            .len = distinct_transform_idx,
            .hdls = instance_hdls,
        };
    }

    pub fn packAll(self: *RenderList, allocator: std.mem.Allocator) !PackedRenderables {
        const handles = try allocator.alloc(RenderItemHandle, self.items.len);
        for (0..self.items.len) |i| {
            handles[i] = self.items.handle_at(@intCast(i)) catch unreachable;
        }
        return try self.pack(handles, allocator);
    }
};
