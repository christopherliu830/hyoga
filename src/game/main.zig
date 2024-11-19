const hy = @import("hyoga");
const math = hy.math;

pub fn main() !void {
    hy.init();
    defer hy.shutdown();

    const backpack = try hy.gpu.importModel("assets/backpack/backpack.obj", .{
        .transform = math.mat4.identity,
        .post_process = .{
            .triangulate = true,
            .split_large_meshes = true,
            .embed_textures = true,
            .flip_uvs = true,
        }
    }); 

    var m = math.mat4.identity;
    m.translate(math.vec(.{1, 1, 1}));

    const backpack_2 = try hy.gpu.importModel("assets/backpack/backpack.obj", .{
        .transform = m,
        .post_process = .{
            .triangulate = true,
            .split_large_meshes = true,
            .embed_textures = true,
            .flip_uvs = true,
        }
    }); 

    try hy.gpu.addModel(backpack);
    try hy.gpu.addModel(backpack_2);

    var game = hy.Game { };
    try game.scene.camera.registerInputs();
    try hy.run(&game);
}
