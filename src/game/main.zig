const std = @import("std");
const hy = @import("hyoga");
const hym = hy.math;
const mat4 = hym.mat4;
const vec3 = hym.vec3;
const vec4 = hym.vec4;

const ui = @import("ui.zig");
const cam = @import("camera.zig");

const Self = @This();

const Object = struct {
    transform: hym.Mat4,
    hdl: hy.Gpu.RenderItemHandle,
};

gpa: std.heap.GeneralPurposeAllocator(.{}),
backpack_hdl: hy.Gpu.ModelHandle = undefined,
objects: hy.SkipMap(Object),
ui_state: ui.State,
camera: cam.Camera,

fn init(hye: *hy.Engine) callconv(.C) hy.World {
    return tryInit(hye) catch |e| std.debug.panic("init failure: {}", .{e});
}

fn tryInit(hye: *hy.Engine) !hy.World {
    hye.setGlobalState();

    var self_gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const self = try self_gpa.allocator().create(Self);
    self.* = .{
        .gpa = self_gpa,
        .objects = try hy.SkipMap(Object).create(self_gpa.allocator(), .{}),
        .ui_state = .{ .second_timer = try std.time.Timer.start() },
        .camera = .{ .input = &hye.input, .window = &hye.window },
    };

    self.backpack_hdl = try hye.gpu.importModel(try hye.strint.from("assets/backpack/backpack.obj"), .{
        .transform = mat4.identity,
        .post_process = .{
            .triangulate = true,
            .split_large_meshes = true,
            .pre_transform_vertices = true,
            .optimize_graph = true,
            .optimize_meshes = true,
        }
    });

    inline for (0..10) |y| {
        inline for (0..10) |x| {
            var object = (try self.objects.insert(undefined)).unwrap();
            object.hdl = hye.gpu.renderables.add(.{
                .model = self.backpack_hdl,
                .owner = &object.transform,
                .time = 1 * std.time.ns_per_s,
            }) catch { std.debug.panic("model add fail", .{}); };

            object.transform = hym.mat4.identity;
            object.transform = hym.mat4.translation(object.transform, hym.vec3.create(x * 10, 100 - y * 10,0));

        }
    }

    try self.camera.registerInputs();
    self.camera.position = hym.vec(.{50, 50, 50});
    self.camera.look_direction = hym.vec(.{0, 0, -1});

    return .{
        .scene = .{
            .light_dir = hym.vec3.create(0, 0, -1),
            .view_proj = self.camera.viewProj(),
            .camera_world_pos = self.camera.position,
        },
        .memory = self,
    };
}

fn shutdown(_: *hy.Engine, state: hy.World) callconv(.C) void {
    const ptr = @as(*u32, @ptrCast(@alignCast(state.memory)));
    std.heap.page_allocator.destroy(ptr);
}

// Called every loop iteration
fn update(_: *hy.Engine, pre: hy.World) callconv(.C) hy.World {
    const self: *Self = @ptrCast(@alignCast(pre.memory));
    var game = pre;

    game.scene.view_proj = self.camera.viewProj();

    if (self.ui_state.restart_requested) game.restart = true;

    return game;
}

// Only called on new frames
fn render(hye: *hy.Engine, state: hy.World) callconv(.C) void {
    const self: *Self = @ptrCast(@alignCast(state.memory));

    ui.drawMainUI(&self.ui_state);
    self.ui_state.frame_time = @floatFromInt(state.frame_time);
    if (self.ui_state.windows.camera) self.camera.editor();

    const imgui = hy.UI.imgui;
    if (imgui.Begin("Test", null, 0)) {
        var it = self.objects.iterator();
        var count: u32 = 0;
        while (it.next()) |cursor| {
            const object = cursor.unwrap();
            imgui.PushIDPtr(object);
            if (count % 10 > 0) imgui.SameLine();
            if (imgui.ButtonEx("", .{ .x = 20, .y = 20 })) {
                hye.gpu.outlined.clearRetainingCapacity();
                hye.gpu.outlined.append(hye.gpa.allocator(), object.hdl) catch { std.debug.panic("model add fail", .{}); };
            }
            imgui.PopID();
            count += 1;
        }
    }
    imgui.End();
}

fn reload(hye: *hy.Engine, game: hy.World) callconv(.C) bool {
    tryReload(hye, game) catch |err| {
        std.log.err("Failed reload: {}", .{err});
        return false;
    };
    return true;
}

fn tryReload(hye: *hy.Engine, game: hy.World) !void {
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
