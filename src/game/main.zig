const std = @import("std");
const hy = @import("hyoga");
const hya = hy.arena;
const math = hy.math;

const Object = struct {
    transform: math.Mat4,
    render: hy.gpu.RenderItemHandle,
};

const Objects = struct {
    allocator: std.mem.Allocator,
    backpack: hy.gpu.ModelHandle,
    array: []Object,
    num_allocated: u32,
};

fn growIfNeeded(objects: *Objects) !void {
    const len = objects.array.len;
    if (len == 0 or objects.num_allocated == len) {
        const new_array = try objects.allocator.alloc(Object, if (len == 0) 8 else len * 2);

        // Move all
        for (objects.array, 0..) |obj, i| {
            new_array[i] = obj;
            hy.gpu.removeModel(obj.render);
            new_array[i].render = try hy.gpu.addModel(objects.backpack, &new_array[i].transform);
        }
        objects.array = new_array;
    }
}

pub fn update(game: *hy.Game) void {
    var objects: *Objects = @ptrCast(@alignCast(game.user_data.?));
    if (objects.array.len == 0) {}
    const ui = hy.ui.imgui;
    if (ui.begin("Main Menu", null, 0)) {
        if (ui.button("Add Backpack", .{ .x = -std.math.floatMin(f32), .y = 0 })) {
            growIfNeeded(objects) catch unreachable;
            var object = &objects.array[objects.num_allocated];
            var second = math.mat4.identity;
            second.translate(game.scene.camera.position);
            second.translate(math.vec3.mul(game.scene.camera.look_direction, 3));
            object.transform = second;
            object.render = hy.gpu.addModel(objects.backpack, &object.transform) catch std.debug.panic("Out of Memory", .{});
            objects.num_allocated += 1;
        }

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

    const hdl_backpack = try hy.gpu.importModel("assets/backpack/backpack.obj", .{
        .transform = math.mat4.identity,
        .post_process = .{
            .triangulate = true,
            .split_large_meshes = true,
        }
    }); 

    var objects: Objects = .{
        .allocator = gpa.allocator(),
        .backpack = hdl_backpack,
        .array = &.{},
        .num_allocated = 0,
    };

    var game = hy.Game {
        .fn_update = update,
        .user_data = &objects,
    };

    try game.scene.camera.registerInputs();
    try hy.run(&game);
}
