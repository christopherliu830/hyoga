const std = @import("std");
const ui = @import("ui.zig");
const hy = @import("hyoga");
const hym = hy.math;

const Self = @This();

const Object = struct {
    transform: hym.Mat4,
    hdl: hy.Gpu.RenderItemHandle,
};

gpa: std.heap.GeneralPurposeAllocator(.{}), 
backpack_hdl: hy.Gpu.ModelHandle = undefined,
objects: hy.Hive(Object),
ui_state: ui.State,

inline fn get(ptr: *anyopaque) *Self {
    return @ptrCast(@alignCast(ptr));
}

fn init(hye: *hy.Engine) callconv(.C) hy.Game {
    return tryInit(hye) catch |err| {
        std.debug.panic("init failure: {}", .{err});
    };
}

fn tryInit(hye: *hy.Engine) !hy.Game {
    hye.setGlobalState();

    var self_gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const self = try self_gpa.allocator().create(Self);
    self.* = .{
        .gpa = self_gpa,
        .objects = try hy.Hive(Object).create(self_gpa.allocator(), .{}),
        .ui_state = .{ .second_timer = try std.time.Timer.start() }
    };

    self.backpack_hdl = try hye.gpu.importModel(try hye.symbol.from("assets/backpack/backpack.obj"), .{
        .transform = hym.mat4.identity,
        .post_process = .{
            .triangulate = true,
            .split_large_meshes = true,
            .pre_transform_vertices = true,
            .optimize_graph = true,
            .optimize_meshes = true,
        }
    });

    var object = (try self.objects.insert(undefined)).unpack();
    object.hdl = hye.gpu.addModel(self.backpack_hdl, &object.transform) catch |err| blk: switch (err) {
        error.ModelNotFound => {
            std.debug.print("Model not done yet\n", .{});
            break :blk hy.Gpu.RenderItemHandle.invalid;
        },
        else => return err,
    };
    object.transform = hy.math.mat4.identity;

    return .{
        .scene = .{
            .camera = .{
                .position = hy.math.vec3.create(0, 0, 2.5),
                .look_direction = hy.math.vec3.create(0, 0, -1),
            },
            .light_dir = hy.math.vec3.create(0, -1, 0),
        },
        .memory = self,
    };
}

fn shutdown(_: *hy.Engine, state: hy.Game) callconv(.C) void {
    const ptr = @as(*u32, @ptrCast(@alignCast(state.memory)));
    std.heap.page_allocator.destroy(ptr);
}

// Called every loop iteration
fn update(_: *hy.Engine, pregame: hy.Game) callconv(.C) hy.Game {
    return pregame;
}

// Only called on new frames
fn render(hye: *hy.Engine, state: hy.Game) callconv(.C) void {
    const ptr: *Self = @ptrCast(@alignCast(state.memory));

    ui.drawMainUI(&ptr.ui_state);
    ptr.ui_state.frame_time = state.frame_time;

    const imgui = hy.UI.imgui;
    if (imgui.Begin("Debug Window", null, 0)) {
        var it = ptr.objects.iterator();
        while (it.next()) |cursor| {
            var obj = cursor.unpack();
            if (!obj.hdl.is_valid()) {
                obj.hdl = hye.gpu.addModel(ptr.backpack_hdl, &obj.transform) catch |err| 
                    blk: switch (err) {
                        error.ModelNotFound => break :blk hy.Gpu.RenderItemHandle.invalid,
                        else => std.debug.panic("Unexpected error trying to add model: {}", .{err}),
                    };
                imgui.Text("Loading", );
            } else {
                imgui.Text("Done");
            }
        }
    }
    imgui.End();
}

fn reload(hye: *hy.Engine, _: hy.Game) callconv(.C) void {
    hye.setGlobalState();
}

export fn interface() hy.GameInterface {
    return .{
        .init = init,
        .shutdown = shutdown,
        .update = update,
        .render = render,
        .reload = reload,
    };
}
