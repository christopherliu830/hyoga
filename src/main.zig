const std = @import("std");
const glfw = @import("mach-glfw");
const gl = @import("./gl.zig");
const ww = @import("./window.zig");

const vertices = [_]f32{
    // positions          // colors           // texture coords
    0.5,  0.5, 0.0,   1.0, 0.0, 0.0,   1.0, 1.0,   // top right
    0.5, -0.5, 0.0,   0.0, 1.0, 0.0,   1.0, 0.0,   // bottom right
    -0.5, -0.5, 0.0,   0.0, 0.0, 1.0,   0.0, 0.0,   // bottom left
    -0.5,  0.5, 0.0,   1.0, 1.0, 0.0,   0.0, 1.0
};

const indices = [_]u32{ 0, 1, 3, 1, 2, 3 };

const tex_coords = [_]f32 {
    0.0, 0.0,
    1.0, 0.0,
    0.5, 1.0,
};

// void main() {
pub fn main() !void {
    const window = try ww.startupWindow();
    defer ww.shutdownWindow(window);

    const vs = try gl.Module.create(.{
        .data = @embedFile("shaders/triangle.vs"),
        .shader_type = .VERTEX,
    });
    defer vs.destroy();

    const fs = try gl.Module.create(.{
        .data = @embedFile("shaders/triangle.fs"),
        .shader_type = .FRAGMENT,
    });
    defer fs.destroy();

    const tex = try gl.Texture.create(@embedFile("assets/IMG_9546.jpg"));
    defer tex.destroy();

    const program = try gl.Program.create(vs, fs);

    const vao = gl.VertexArray.create();
    defer vao.destroy();
    const vbo = gl.Buffer.create();
    defer vbo.destroy();
    const ebo = gl.Buffer.create();
    defer ebo.destroy();

    vao.bind();

    vbo.upload(&vertices, .ARRAY_BUFFER, .STATIC_DRAW);
    ebo.upload(&indices, .ELEMENT_ARRAY_BUFFER, .STATIC_DRAW);

    var attr_builder = gl.VertexAttributes.start();
    attr_builder.add(.{
        // POS
        .size = 3,
        .type = .FLOAT,
        .normalized = false,
    }).add(.{
        // COLOR
        .size = 3,
        .type = .FLOAT,
        .normalized = false
    }).add(.{
        .size = 2,
        .type = .FLOAT,
        .normalized = false,
    }).use();

    while (!window.shouldClose()) {
        glfw.pollEvents();

        if (window.getKey(.escape) == .press) {
            window.setShouldClose(true);
        }

        gl.Clear(gl.COLOR_BUFFER_BIT);

        const time: f32 = @floatCast(std.math.sin(glfw.getTime()));
        program.set("color", @Vector(4, f32){ 0, time, 0, 0 });

        program.use();
        vao.bind();
        gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, 0);

        window.swapBuffers();
    }
}
