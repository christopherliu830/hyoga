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

pub fn update(game: *hy.Game) void {
    var ctx: *Context = @ptrCast(@alignCast(game.user_data.?));

    var mat = math.mat4.identity;
    mat.translate(game.scene.camera.position);
    mat.translate(math.vec3.mul(game.scene.camera.look_direction, 3));

    ui.drawMainUI(&ctx.ui_state);

    const imgui = hy.ui.imgui;
    if (imgui.begin("Main Menu", null, 0)) {
        if (imgui.button("Add Backpack", .{ .x = -std.math.floatMin(f32), .y = 0 })) {
            const hdl = ctx.objects.insert(.{ .transform = mat, .render = undefined }) catch unreachable;
            const obj = hdl.unpack();
            obj.render = hy.gpu.addModel(ctx.backpack, &obj.transform) catch std.debug.panic("Out of Memory", .{});
            std.debug.print("Added {}\n", .{obj.render});
        }

        var it = ctx.objects.iterator();
        while (it.next()) |val| {
            const obj = val.unpack();

            imgui.pushID_Ptr(obj);
            if (imgui.button("Delete Item", .{ .x = -std.math.floatMin(f32), .y = 0 })) {
                hy.gpu.removeModel(obj.render);
                ctx.objects.remove(val);
            }
            imgui.popID();
        }

        if (imgui.button("Quit", .{ .x = -std.math.floatMin(f32), .y = 0 })) {
            game.quit = true;
        }
    }
    imgui.end();
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = gpa.allocator();
    hy.init(allocator);
    defer hy.shutdown();

    const hdl_backpack = try hy.gpu.importModel("assets/backpack/backpack.obj", .{
        .transform = math.mat4.identity,
        .post_process = .{
            .triangulate = true,
            .split_large_meshes = true,
        }
    }); 

    var objects: Context = .{
        .ui_state = .{},
        .allocator = gpa.allocator(),
        .backpack = hdl_backpack,
        .objects = try hy.Hive(Object).create(gpa.allocator(), .{}),
    };

    var game = hy.Game {
        .fn_update = update,
        .user_data = &objects,
    };

    try game.scene.camera.registerInputs();
    try hy.run(&game);
}
