const hy = @import("hyoga");

pub fn main() !void {
    hy.init();
    defer hy.shutdown();

    // const hdl_backpack = try hy.gpu.importModel("assets/backpack/backpack.obj", .{
    //     .transform = hym.mat4.rotation(90, hym.vec3.create(1, 0, 0)),
    //     .post_process = .{
    //         .triangulate = true,
    //         .split_large_meshes = true,
    //         .embed_textures = true,
    //         .flip_uvs = true,
    //     }
    // }); 

    var game = hy.Game { };
    try game.scene.camera.registerInputs();
    try hy.run(&game);

}

