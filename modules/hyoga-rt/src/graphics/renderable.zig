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

pub const Renderable = struct {
    next: ?RenderItemHandle = null, // When models are imported as a group, support adds and removes via this link.
    mesh: mdl.Mesh,
    transform: mat4.Mat4 = mat4.identity, // Set on import and does not change.
    parent_transform: ?*mat4.Mat4 = null,
};

/// A wrapper around a list of renderables, in order to support
/// group-based insertions and deletions.
pub const RenderList = struct {
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
            var model = try self.gpu.models.get(options.model);
            if (options.time > 0) {
                var timer = try std.time.Timer.start();
                while (model == null and timer.read() < options.time) model = try self.gpu.models.get(options.model);
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
    pub fn prepare(self: *RenderList, allocator: std.mem.Allocator) ![]mat4.Mat4 {
        const slice = try allocator.alloc(mat4.Mat4, self.items.capacity());
        for (self.items.entries.items, 0..) |entry, i| {
            switch(entry) {
                .occupied => |val| slice[i] = mat4.mul((val.value.parent_transform orelse &mat4.identity).*, val.value.transform),
                .empty => continue,
            }
        }
        return slice;
    }
};

