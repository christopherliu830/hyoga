const std = @import("std");
const hy = @import("hyoga");
const hya = hy.arena;
const math = hy.math;

const ui = @import("ui.zig");

const Object = struct {
    transform: math.Mat4,
    render: hy.gpu.RenderItemHandle,
};

const Context = struct {
    ui_state: ui.State,
    allocator: std.mem.Allocator,
    backpack: hy.gpu.ModelHandle,
    objects: hy.Hive(Object),
};

// Called every loop iteration
pub fn update(game: *hy.Game) void {
    _ = game;
}

// Only called on new frames
pub fn render(game: *hy.Game) void {
    var ctx: *Context = @ptrCast(@alignCast(game.user_data.?));
    ctx.ui_state.frame_time = game.frame_time;
    ui.drawMainUI(&ctx.ui_state);

    var mat = math.mat4.identity;
    mat.translate(game.scene.camera.position);
    mat.translate(math.vec3.mul(game.scene.camera.look_direction, 3));

    const imgui = hy.ui.imgui;
    if (imgui.Begin("Main Menu", null, 0)) {
        if (imgui.ButtonEx("Add Backpack", .{ .x = -std.math.floatMin(f32), .y = 0 })) {
            const hdl = ctx.objects.insert(.{ .transform = mat, .render = undefined }) catch unreachable;
            const obj = hdl.unpack();
            if (hy.gpu.addModel(ctx.backpack, &obj.transform)) |model| {
                obj.render = model;
            } else |err| switch(err) {
                error.NotFound => {
                    // The model is not done loading yet
                    ctx.objects.remove(hdl);
                },
                else => |other_err| std.debug.panic("Error: {}", .{other_err}),
            }
        }

        var it = ctx.objects.iterator();
        while (it.next()) |val| {
            const obj = val.unpack();

            imgui.PushIDPtr(obj);
            if (imgui.ButtonEx("Delete Item", .{ .x = -std.math.floatMin(f32), .y = 0 })) {
                hy.gpu.removeModel(obj.render);
                ctx.objects.remove(val);
            }
            imgui.PopID();
        }

        if (imgui.ButtonEx("Quit", .{ .x = -std.math.floatMin(f32), .y = 0 })) {
            game.quit = true;
        }
    }
    imgui.End();

}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    defer _ = gpa.detectLeaks();
    const allocator = gpa.allocator();
    hy.init(allocator);
    defer hy.shutdown();

    const backpack = try hy.symbol.from("assets/backpack/backpack.obj");

    const hdl_backpack = try hy.gpu.importModel(backpack, .{
        .transform = math.mat4.identity,
        .post_process = .{
            .triangulate = true,
            .split_large_meshes = true,
            .pre_transform_vertices = true,
            .optimize_graph = true,
            .optimize_meshes = true,
        }
    }); 

    var objects: Context = .{
        .ui_state = try ui.State.create(),
        .allocator = gpa.allocator(),
        .backpack = hdl_backpack,
        .objects = try hy.Hive(Object).create(gpa.allocator(), .{}),
    };

    defer objects.objects.deinit();

    var game = hy.Game {
        .fn_update = update,
        .fn_render = render,
        .user_data = &objects,
    };

    try game.scene.camera.registerInputs();

    try hy.run(&game);
}
