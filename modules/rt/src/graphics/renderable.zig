const std = @import("std");
const sdl = @import("sdl");
const hy = @import("hyoga-lib");
const mt = @import("material.zig");
const mdl = @import("model.zig");
const tracy = @import("tracy");

const gfx = @import("root.zig");
const SlotMap = @import("hyoga-lib").SlotMap;
const Gpu = @import("gpu.zig");
const Mesh = mdl.Mesh;
const Model = mdl.Model;
const ModelHandle = mdl.Handle;
const Mat4 = hy.math.Mat4;
const passes = @import("passes.zig");

pub const RenderItemHandle = SlotMap(Renderable).Handle;

const Instance = struct {
    mesh: Mesh,
    transform_hdls: SlotMap(usize),
    back_handles: std.ArrayList(u32) = .empty,
    transform_buf: std.ArrayList(Mat4) = .empty,
};

const InstanceMap = hy.SlotMapSized(u32, u32, Instance);

pub const RenderHandle = extern struct {
    instances_hdl: InstanceMap.Handle align(4),
    transform_hdl: hy.SlotMap(usize).Handle align(4),
};

pub const Renderable = struct {
    mesh: Mesh,
    transform: Mat4 = .identity,

    // Does not account for transform differences
    pub fn eql(lhs: Renderable, rhs: Renderable) bool {
        return lhs.mesh.buffer.eql(rhs.mesh.buffer) and
            lhs.mesh.material.index == rhs.mesh.material.index;
    }
};

pub const RenderList = struct {
    instances: InstanceMap = .empty,

    pub fn reset(self: *RenderList) void {
        const pass: *passes.Forward = @fieldParentPtr("render_list", self);
        const gpu = pass.gpu;

        var it = self.instances.iterator();
        while (it.nextPtr()) |instances| {
            instances.transform_hdls.deinit(gpu.gpa);
            instances.back_handles.clearAndFree(gpu.gpa);
            instances.transform_buf.clearAndFree(gpu.gpa);
        }
    }

    pub fn deinit(self: *RenderList) void {
        const pass: *passes.Forward = @fieldParentPtr("render_list", self);
        const gpu = pass.gpu;

        var it = self.instances.iterator();
        while (it.nextPtr()) |instances| {
            instances.transform_hdls.deinit(gpu.gpa);
            instances.back_handles.deinit(gpu.gpa);
            instances.transform_buf.deinit(gpu.gpa);
        }
        self.instances.deinit(gpu.gpa);
    }

    pub const AddOptions = extern struct {
        model: ModelHandle,
        /// Max sleep time for the model to load
        time: u64 = 0,
    };

    pub fn add(self: *RenderList, options: AddOptions) !RenderHandle {
        const pass: *passes.Forward = @fieldParentPtr("render_list", self);
        const gpu = pass.gpu;

        const q_model = blk: {
            var model = gpu.models.get(options.model) catch null;

            if (options.time > 0) {
                var timer = try std.time.Timer.start();
                while (model == null and timer.read() < options.time) {
                    model = gpu.models.get(options.model) catch null;
                }
            }
            break :blk model;
        };

        if (q_model) |model| {
            std.debug.assert(model.children.len == 1);
            const rhs = model.children[0];

            const instances_hdl: InstanceMap.Handle = blk: {
                var it = self.instances.iterator();
                while (it.nextPtr()) |lhs| {
                    if (lhs.mesh.buffer.eql(rhs.buffer) and
                        lhs.mesh.material.index == rhs.material.index and
                        lhs.mesh.material.generation == rhs.material.generation)
                    {
                        break :blk it.handle();
                    }
                } else {
                    break :blk try self.instances.insert(gpu.gpa, .{
                        .mesh = rhs,
                        .transform_hdls = .empty,
                        .transform_buf = .empty,
                    });
                }
            };

            const instances = self.instances.getPtr(instances_hdl).?;
            try instances.transform_buf.append(gpu.gpa, .identity);
            const transform_hdl = try instances.transform_hdls.insert(gpu.gpa, instances.transform_buf.items.len - 1);
            try instances.back_handles.append(gpu.gpa, transform_hdl.index);

            return .{
                .instances_hdl = instances_hdl,
                .transform_hdl = transform_hdl,
            };
        }

        return error.InvalidModel;
    }

    pub fn remove(self: *RenderList, hdls: RenderHandle) void {
        const instances = self.instances.getPtr(hdls.instances_hdl).?;
        const transform_index = instances.transform_hdls.get(hdls.transform_hdl).?;
        _ = instances.transform_hdls.remove(hdls.transform_hdl);

        _ = instances.transform_buf.swapRemove(transform_index);
        _ = instances.back_handles.swapRemove(transform_index);

        if (transform_index < instances.back_handles.items.len) {
            const back_hdl_idx = instances.back_handles.items[transform_index];
            const back_hdl = instances.transform_hdls.at(back_hdl_idx).?;
            back_hdl.* = transform_index;
        }
    }

    pub fn transformPtr(self: *RenderList, hdl: RenderHandle) *Mat4 {
        const instances = self.instances.getPtr(hdl.instances_hdl).?;
        const transform_idx = instances.transform_hdls.get(hdl.transform_hdl).?;
        return &instances.transform_buf.items[transform_idx];
    }

    // Caller must free the returned slice.
    // pub fn pack(self: *RenderList, handles: []const RenderItemHandle, allocator: std.mem.Allocator) !PackedRenderables {
    //     const SwapContext = struct {
    //         handles: []RenderItemHandle,
    //         renderables: []Renderable,

    //         pub fn lessThan(ctx: @This(), a: usize, b: usize) bool {
    //             const lhs = &ctx.renderables[a];
    //             const rhs = &ctx.renderables[b];

    //             if (lhs.mesh.buffer.eql(rhs.mesh.buffer))
    //                 return lhs.mesh.material.index < rhs.mesh.material.index
    //             else
    //                 return @as(usize, @intFromPtr(lhs.mesh.buffer.hdl)) + lhs.mesh.buffer.offset <
    //                     @as(usize, @intFromPtr(rhs.mesh.buffer.hdl)) + rhs.mesh.buffer.offset;
    //         }

    //         pub fn swap(ctx: @This(), a: usize, b: usize) void {
    //             std.mem.swap(Renderable, &ctx.renderables[a], &ctx.renderables[b]);
    //             std.mem.swap(RenderItemHandle, &ctx.handles[a], &ctx.handles[b]);
    //         }
    //     };

    //     // Sort renderables (and associated handle) by material + mesh handle.

    //     const hdls = try allocator.dupe(RenderItemHandle, handles);
    //     defer allocator.free(hdls);

    //     const renderables = try allocator.alloc(Renderable, hdls.len);
    //     for (handles, 0..) |hdl, i| {
    //         renderables[i] = self.items.get(hdl) orelse unreachable;
    //     }
    //     defer allocator.free(renderables);

    //     const transforms = try allocator.alloc(Mat4, hdls.len);
    //     errdefer allocator.free(transforms);

    //     std.sort.heapContext(0, renderables.len, SwapContext{ .renderables = renderables, .handles = hdls });

    //     const num_distinct = blk: {
    //         var count: usize = 1;
    //         for (1..renderables.len) |i| {
    //             if (!renderables[i].eql(renderables[i - 1])) {
    //                 count += 1;
    //             }
    //         }
    //         break :blk count;
    //     };

    //     const meshes = try allocator.alloc(mdl.Mesh, num_distinct);
    //     errdefer allocator.free(meshes);
    //     const instance_counts = try allocator.alloc(u32, num_distinct);
    //     errdefer allocator.free(instance_counts);
    //     var instance_hdls = try allocator.alloc(RenderItemHandle, num_distinct);
    //     errdefer allocator.free(instance_hdls);

    //     var distinct_transform_idx: u32 = 0;
    //     for (0..renderables.len) |i| {
    //         const renderable = renderables[i];

    //         transforms[i] = renderable.transform;

    //         if (distinct_transform_idx == 0 or !renderable.eql(renderables[i - 1])) {
    //             meshes[distinct_transform_idx] = renderable.mesh;
    //             instance_counts[distinct_transform_idx] = 1;
    //             instance_hdls[distinct_transform_idx] = hdls[i];
    //             distinct_transform_idx += 1;
    //         } else {
    //             instance_counts[distinct_transform_idx - 1] += 1;
    //         }
    //     }

    //     return .{
    //         .transforms = transforms,
    //         .meshes = meshes,
    //         .instance_counts = instance_counts,
    //         .len = distinct_transform_idx,
    //         .hdls = instance_hdls,
    //     };
    // }

    // pub fn packAll(self: *RenderList, allocator: std.mem.Allocator) !PackedRenderables {
    //     const zone_render_pack = tracy.initZone(@src(), .{ .name = "gfx.rbl.pack" });
    //     defer zone_render_pack.deinit();

    //     if (!self.render_pack_dirty) {
    //         return self.render_pack;
    //     } else {
    //         self.render_pack.deinit(allocator);

    //         const handles = try allocator.alloc(RenderItemHandle, self.items.num_items);
    //         defer allocator.free(handles);

    //         var it = self.items.iterator();
    //         var i: u32 = 0;
    //         while (it.next()) |_| {
    //             handles[i] = it.handle();
    //             i += 1;
    //         }

    //         self.render_pack = self.pack(handles, allocator) catch std.debug.panic("pack failure", .{});
    //         self.render_pack_dirty = false;
    //         return self.render_pack;
    //     }
    // }
};
