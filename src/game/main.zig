const std = @import("std");
const hy = @import("hyoga");
const hya = hy.arena;
const math = hy.math;

// const Object = struct {
//     transform: math.Mat4,
//     render: hy.gpu.RenderItemHandle,
// };

// const Context = struct {
//     allocator: std.mem.Allocator,
//     backpack: hy.gpu.ModelHandle,
//     objects: hya.Arena(Object),
//     num_allocated: u32,
// };

// fn growIfNeeded(ctx: *Context) !void {
//     const len = if (ctx.objects.len > 0) ctx.objects.len * 2 else 8;
//     if (len > ctx.objects.capacity()) {
//         var it = ctx.objects.iterator();

//         try ctx.objects.resize(len); // Invalidate pointers

//         it.reset();
//         while (it.nextPtr()) |obj| {
//             hy.gpu.removeModel(obj.render);
//             obj.render = try hy.gpu.addModel(ctx.backpack, &obj.transform);
//         } 
//     }
// }

pub fn update(game: *hy.Game) void {
    // var ctx: *Context = @ptrCast(@alignCast(game.user_data.?));
    // if (ctx.objects.len == 0) {}

    // var mat = math.mat4.identity;
    // mat.translate(game.scene.camera.position);
    // mat.translate(math.vec3.mul(game.scene.camera.look_direction, 3));

    const ui = hy.ui.imgui;
    if (ui.begin("Main Menu", null, 0)) {
        // if (ui.button("Add Backpack", .{ .x = -std.math.floatMin(f32), .y = 0 })) {

        //     growIfNeeded(ctx) catch unreachable;

        //     const hdl = ctx.objects.insert(.{ .transform = mat, .render = undefined }) catch unreachable;
        //     const obj = ctx.objects.getPtr(hdl) catch unreachable;

        //     obj.render = hy.gpu.addModel(ctx.backpack, &obj.transform) catch std.debug.panic("Out of Memory", .{});
        //     std.debug.print("Added {}\n", .{obj.render});
        //     ctx.num_allocated += 1;
        // }

        // var it = ctx.objects.iterator();
        // while (it.next()) |obj| {
        //     ui.pushID_Ptr(obj);
        //     if (ui.button("Delete Item", .{ .x = -std.math.floatMin(f32), .y = 0 })) {
        //         hy.gpu.removeModel(obj.render);
        //     }
        //     ui.popID();
        // }
        // std.debug.print("\n", .{});

        if (ui.button("Quit", .{ .x = -std.math.floatMin(f32), .y = 0 })) {
            game.quit = true;
        }
    }
    ui.end();
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = gpa.allocator();

    hy.init(allocator);
    defer hy.shutdown();

    // const hdl_backpack = try hy.gpu.importModel("assets/backpack/backpack.obj", .{
    //     .transform = math.mat4.identity,
    //     .post_process = .{
    //         .triangulate = true,
    //         .split_large_meshes = true,
    //     }
    // }); 

    // var objects: Context = .{
    //     .allocator = gpa.allocator(),
    //     .backpack = hdl_backpack,
    //     .objects = try hya.Arena(Object).create(gpa.allocator(), 1),
    //     .num_allocated = 0,
    // };

    var game = hy.Game {
        .fn_update = update,
        .user_data = null,
    };

    try game.scene.camera.registerInputs();
    try hy.run(&game);
}
