const std = @import("std");
const hy = @import("hyoga");
const hym = hy.math;

const ui = @import("ui.zig");
const cam = @import("camera.zig");

const Self = @This();

const Object = struct {
    transform: hym.Mat4,
    hdl: hy.Gpu.RenderItemHandle,
};

gpa: std.heap.GeneralPurposeAllocator(.{}), 
backpack_hdl: hy.Gpu.ModelHandle = undefined,
objects: hy.Hive(Object),
ui_state: ui.State,
camera: cam.Camera,
selected: ?*Object = null,

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
        .ui_state = .{ .second_timer = try std.time.Timer.start() },
        .camera = .{ .input = &hye.input, .window = &hye.window },
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
    object.hdl = hye.gpu.addModel(.{
        .hdl = self.backpack_hdl,
        .owner = &object.transform,
        .time = 1 * std.time.ns_per_s,
    })  catch |err| blk: switch (err) {
        error.ModelNotFound => {
            std.debug.print("Model not done yet\n", .{});
            break :blk hy.Gpu.RenderItemHandle.invalid;
        },
        else => return err,
    };

    object.transform = hy.math.mat4.identity;

    try self.camera.registerInputs();

    return .{
        .scene = .{
            .view_proj = self.camera.viewProj(),
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
    const self: *Self = @ptrCast(@alignCast(pregame.memory));
    var game = pregame;

    game.scene.light_dir = hym.vec3.create(1, 0, 0);
    game.scene.view_proj = self.camera.viewProj();
    if (self.ui_state.restart_requested) game.restart = true;

    // game.scene.camera.position = self.camera.position;
    // game.scene.camera.look_direction = self.camera.look_direction;
    
    return game;
}

// Only called on new frames
fn render(hye: *hy.Engine, state: hy.Game) callconv(.C) void {
    _ = hye;
    const self: *Self = @ptrCast(@alignCast(state.memory));

    ui.drawMainUI(&self.ui_state);
    self.ui_state.frame_time = state.frame_time;
    if (self.ui_state.windows.camera) self.camera.editor();

    const imgui = hy.UI.imgui;
    if (imgui.Begin("Test", null, 0)) {
        var it = self.objects.iterator();
        while (it.next()) |cursor| {
            const object = cursor.unpack();
            imgui.PushIDPtr(object);
            if (imgui.Button("Select")) {
                self.selected = object;
            }
            imgui.PopID();
        }
    }
    imgui.End();
}

fn reload(hye: *hy.Engine, game: hy.Game) callconv(.C) bool {
    tryReload(hye, game) catch |err| {
        std.log.err("Failed reload: {}", .{err});
        return false;
    };
    return true;
}

fn tryReload(hye: *hy.Engine, game: hy.Game) !void {
    hye.setGlobalState();
    hye.input.reset();

    const ptr = @as(*Self, @ptrCast(@alignCast(game.memory)));
    try ptr.camera.registerInputs();

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
