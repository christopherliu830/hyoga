const std = @import("std");
const hy = @import("hyoga");
// const hya = hy.arena;
// const math = hy.math;

// const ui = @import("ui.zig");

// const Object = struct {
//     transform: math.Mat4,
//     render: hy.gpu.RenderItemHandle,
// };

// const Context = struct {
//     ui_state: ui.State,
//     allocator: std.mem.Allocator,
//     backpack: hy.gpu.ModelHandle,
//     objects: hy.Hive(Object),
// };

var memory: *anyopaque = undefined;

fn init() callconv(.C) void {
    const ptr = std.heap.page_allocator.create(u32) catch @panic("out of memory");
    memory = ptr;
}

fn shutdown() callconv(.C) void {
    const ptr = @as(*u32, @ptrCast(@alignCast(memory)));
    std.heap.page_allocator.destroy(ptr);
}

// Called every loop iteration
fn update(game: hy.Game) callconv(.C) hy.Game {
    return game;
}

// Only called on new frames
fn render(game: hy.Game) callconv(.C) void {
    _ = game;
    std.debug.print("My counter: {}\n", .{@as(*u32, @alignCast(@ptrCast(memory))).*});
    // const imgui = hy.ui.imgui;
    // if (imgui.Begin("My Counter")) {
    // }
    // var ctx: *Context = @ptrCast(@alignCast(game.user_data.?));
    // ctx.ui_state.frame_time = game.frame_time;
    // ui.drawMainUI(&ctx.ui_state);

    // var mat = math.mat4.identity;
    // mat.translate(game.scene.camera.position);
    // mat.translate(math.vec3.mul(game.scene.camera.look_direction, 3));

    // const imgui = hy.ui.imgui;
    // if (imgui.Begin("Main Menu", null, 0)) {
    //     if (imgui.ButtonEx("Add Backpack", .{ .x = -std.math.floatMin(f32), .y = 0 })) {
    //         const hdl = ctx.objects.insert(.{ .transform = mat, .render = undefined }) catch unreachable;
    //         const obj = hdl.unpack();
    //         if (hy.gpu.addModel(ctx.backpack, &obj.transform)) |model| {
    //             obj.render = model;
    //         } else |err| switch(err) {
    //             error.NotFound => {
    //                 // The model is not done loading yet
    //                 ctx.objects.remove(hdl);
    //             },
    //             else => |other_err| std.debug.panic("Error: {}", .{other_err}),
    //         }
    //     }

    //     var it = ctx.objects.iterator();
    //     while (it.next()) |val| {
    //         const obj = val.unpack();

    //         imgui.PushIDPtr(obj);
    //         if (imgui.ButtonEx("Delete Item", .{ .x = -std.math.floatMin(f32), .y = 0 })) {
    //             hy.gpu.removeModel(obj.render);
    //             ctx.objects.remove(val);
    //         }
    //         imgui.PopID();
    //     }

    //     if (imgui.ButtonEx("Quit", .{ .x = -std.math.floatMin(f32), .y = 0 })) {
    //         game.quit = true;
    //     }
    // }
    // imgui.End();
}

fn data() callconv(.C) *anyopaque {
    return memory;
}

fn reload(mem: *anyopaque) callconv(.C) void {
    memory = mem;
}

export fn interface() hy.GameInterface {
    return .{
        .init = init,
        .shutdown = shutdown,
        .update = update,
        .render = render,
        .data = data,
        .reload = reload,
        // init: *const fn() void,
        // shutdown: *const fn() void,
        // update: *const fn (Game) Game,
        // render: *const fn (Game) void,
        // data: *const fn() *anyopaque,
        // reload: *const fn(*anyopaque) void,
    };
}
