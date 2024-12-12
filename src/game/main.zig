const std = @import("std");
const ui = @import("ui.zig");
const Hy = @import("hyoga");
const hym = Hy.math;

const Self = @This();

const Object = struct {
    transform: hym.Mat4,
    hdl: Hy.Gpu.RenderItemHandle,
};

gpa: std.heap.GeneralPurposeAllocator(.{}), 
backpack_hdl: Hy.Gpu.ModelHandle = undefined,
objects: Hy.Hive(Object),

inline fn get(ptr: *anyopaque) *Self {
    return @ptrCast(@alignCast(ptr));
}

fn init(hy: *Hy) callconv(.C) Hy.Game {
    return tryInit(hy) catch |err| {
        std.debug.panic("init failure: {}", .{err});
    };
}

fn tryInit(hy: *Hy) !Hy.Game {
    _ = hy;
    var self_gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const self = try self_gpa.allocator().create(Self);
    // self.* = .{
    //     .gpa = self_gpa,
    //     .objects = try Hy.Hive(Object).create(self_gpa.allocator(), .{}),
    // };

    // self.backpack_hdl = try Hy.gpu.importModel(try hy.symbol.from("assets/backpack/backpack.obj"), .{
    //     .transform = hym.mat4.identity,
    //     .post_process = .{
    //         .triangulate = true,
    //         .split_large_meshes = true,
    //         .pre_transform_vertices = true,
    //         .optimize_graph = true,
    //         .optimize_meshes = true,
    //     }
    // });

    // var object = (try self.objects.insert(undefined)).unpack();
    // object.hdl = try Hy.gpu.addModel(self.backpack_hdl, &object.transform);

    return .{
        .scene = .{
            .camera = .{
                .position = Hy.math.vec3.create(0, 0, 2.5),
                .look_direction = Hy.math.vec3.create(0, 0, -1),
            },
            .light_dir = Hy.math.vec3.create(0, -1, 0),
        },
        .memory = self,
    };
}

fn shutdown(_: *Hy, state: Hy.Game) callconv(.C) void {
    const ptr = @as(*u32, @ptrCast(@alignCast(state.memory)));
    std.heap.page_allocator.destroy(ptr);
}

// Called every loop iteration
fn update(_: *Hy, pregame: Hy.Game) callconv(.C) Hy.Game {
    return pregame;
}

// Only called on new frames
fn render(hy: *Hy, state: Hy.Game) callconv(.C) void {
    _ = state;
    // const ptr: *u32 = @ptrCast(@alignCast(state.memory));
    hy.ui.useImgui();
    // const imgui = Hy.UI.imgui;
    // if (imgui.Begin("Debug Window", null, 0)) {
    // }
    // imgui.End();
}

export fn interface() Hy.GameInterface {
    return .{
        .init = init,
        .shutdown = shutdown,
        .update = update,
        .render = render,
    };
}
