const std = @import("std");
const sdl = @import("sdl");
const hy = @import("hyoga");
const mt = @import("material.zig");
const mdl = @import("model.zig");
const tracy = @import("tracy");
const gfx = @import("root.zig");
const buf = @import("buffer.zig");
const SlotMap = @import("hyoga").SlotMap;
const Gpu = @import("gpu.zig");
const Mesh = mdl.Mesh;
const Model = mdl.Model;
const ModelHandle = mdl.Handle;
const Mat4 = hy.math.Mat4;
const passes = @import("passes.zig");

pub const RenderItemHandle = SlotMap(Renderable).Handle;

const Instance = struct {
    mesh: Mesh,
    transforms: hy.DoubleIndirectList(Mat4) = .empty,
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
            instances.transforms.deinit(gpu.gpa);
        }
    }

    pub fn deinit(self: *RenderList) void {
        const pass: *passes.Forward = @fieldParentPtr("render_list", self);
        const gpu = pass.gpu;

        var it = self.instances.iterator();
        while (it.nextPtr()) |instances| {
            instances.transforms.deinit(gpu.gpa);
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
                        .transforms = .empty,
                    });
                }
            };

            const instances = self.instances.getPtr(instances_hdl).?;
            const transform_hdl = try instances.transforms.insert(gpu.gpa, .identity);
            return .{
                .instances_hdl = instances_hdl,
                .transform_hdl = transform_hdl,
            };
        }

        return error.InvalidModel;
    }

    pub fn remove(self: *RenderList, hdls: RenderHandle) void {
        const instances = self.instances.getPtr(hdls.instances_hdl).?;
        instances.transforms.remove(hdls.transform_hdl);
    }

    pub fn transformPtr(self: *RenderList, hdl: RenderHandle) *Mat4 {
        const instances = self.instances.getPtr(hdl.instances_hdl).?;
        const transform_idx = instances.transforms.index_map.get(hdl.transform_hdl).?;
        return &instances.transforms.array.items[transform_idx];
    }
};
