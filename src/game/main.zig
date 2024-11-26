const std = @import("std");
const hy = @import("hyoga");
const math = hy.math;

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


    try hy.gpu.addModel(hdl_backpack);

    var game = hy.Game { };
    try game.scene.camera.registerInputs();
    try hy.run(&game);
}
