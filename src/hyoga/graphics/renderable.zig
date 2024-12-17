const std = @import("std");
const sdl = @import("sdl");
const mat4 = @import("hyoga-math").mat4;

const SkipMap = @import("../skipmap.zig").SkipMapSized;
const Gpu = @import("gpu.zig");
const mt = @import("material.zig");

const mdl = @import("model.zig");
const Model = mdl.Model;
const ModelHandle = mdl.Handle;

const RenderItems = SkipMap(Renderable, u16);
pub const RenderItemHandle = RenderItems.Cursor;

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

    pub const Iterator = RenderItems.Iterator;

    pub fn init(gpu: *Gpu, allocator: std.mem.Allocator) !RenderList {
        return .{
            .gpu = gpu,
            .items = try RenderItems.create(allocator, .{}),
        };
    }

    pub const AddModelOptions = struct {
        model: ModelHandle,
        owner: *mat4.Mat4,
        time: u64 = 0, // Time to wait for model load in nanoseconds.
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
        var head = hdl;
        while (head != RenderItemHandle.invalid) |node| {
            const obj = self.render_state.renderables.get(node) catch {
                std.log.warn("[GPU]: Invalid handle for removeModel, returning...", .{});
                return;
            };
            head = obj.next;
            self.items.remove(obj);
        }
    }

    pub inline fn iterator(self: *RenderList) Iterator {
        return self.items.iterator();
    } 
};

