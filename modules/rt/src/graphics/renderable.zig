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
    transform: Mat4 = .identity,

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

    pub fn init(gpu: *Gpu) RenderList {
        return .{
            .gpu = gpu,
            .items = .empty,
        };
    }

    pub fn deinit(self: *RenderList) void {
        if (self.items.end > 0) {
            self.items.deinit(self.gpu.gpa);
        }
    }

    pub const AddOptions = extern struct {
        model: ModelHandle,
        /// Max sleep time for the model to load
        time: u64 = 0,
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
                    .transform = model.transform,
                    .next = head,
                };
                head = try self.items.insert(self.gpu.gpa, renderable);
            }
            if (head) |h| return h else return error.ModelEmpty;
        }

        return error.InvalidModel;
    }

    pub fn remove(self: *RenderList, hdl: RenderItemHandle) void {
        var maybe_head_hdl: ?RenderItemHandle = hdl;
        while (maybe_head_hdl) |head_hdl| {
            const head: ?Renderable = self.items.get(head_hdl);
            if (head) |h| {
                maybe_head_hdl = h.next;
                self.items.remove(head_hdl);
            } else {
                maybe_head_hdl = null;
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
                const lhs = &ctx.renderables[a];
                const rhs = &ctx.renderables[b];

                if (lhs.mesh.buffer.eql(rhs.mesh.buffer))
                    return lhs.mesh.material.index < rhs.mesh.material.index
                else
                    return @as(usize, @intFromPtr(lhs.mesh.buffer.hdl)) + lhs.mesh.buffer.offset <
                        @as(usize, @intFromPtr(rhs.mesh.buffer.hdl)) + rhs.mesh.buffer.offset;
            }

            pub fn swap(ctx: @This(), a: usize, b: usize) void {
                std.mem.swap(Renderable, &ctx.renderables[a], &ctx.renderables[b]);
                std.mem.swap(RenderItemHandle, &ctx.handles[a], &ctx.handles[b]);
            }
        };

        // Sort renderables (and associated handle) by material + mesh handle.

        const hdls = try allocator.dupe(RenderItemHandle, handles);
        errdefer allocator.free(hdls);
        const renderables = try allocator.alloc(Renderable, hdls.len);
        for (handles, 0..) |hdl, i| {
            renderables[i] = self.items.get(hdl) orelse unreachable;
        }
        defer allocator.free(renderables);

        const transforms = try allocator.alloc(Mat4, hdls.len);
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

        const meshes = try allocator.alloc(mdl.Mesh, num_distinct);
        errdefer allocator.free(meshes);
        const instance_counts = try allocator.alloc(u32, num_distinct);
        errdefer allocator.free(instance_counts);
        var instance_hdls = try allocator.alloc(RenderItemHandle, num_distinct);
        errdefer allocator.free(instance_hdls);

        var distinct_transform_idx: u32 = 0;
        for (0..renderables.len) |i| {
            const renderable = renderables[i];

            transforms[i] = renderable.transform;

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
        const handles = try allocator.alloc(RenderItemHandle, self.items.num_items);
        var it = self.items.iterator();
        var i: u32 = 0;
        while (it.next()) |_| {
            handles[i] = it.handle();
            i += 1;
        }
        return self.pack(handles, allocator) catch std.debug.panic("pack failure", .{});
    }
};
