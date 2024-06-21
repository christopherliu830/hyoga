const std = @import("std");
const glfw = @import("mach-glfw");
const gl = @import("./gl.zig");
const shaders = @import("./shader.zig");
const ww = @import("./window.zig");

const vertices = [_]f32{
     0.5,  0.5,  0.0,   1.0, 0.0, 0.0,  1.0, 1.0, // top right
     0.5, -0.5,  0.0,   0.0, 1.0, 0.0,  1.0, 1.0, // bottom right
    -0.5, -0.5,  0.0,   0.0, 0.0, 1.0,  0.0, 0.0, // bottom left
    -0.5,  0.5,  0.0,   1.0, 1.0, 0.0,  0.0, 1.0, // top left
};

const indices = [_]u32{ 0, 1, 3, 1, 2, 3 };

// void main() {
pub fn main() !void {
    const window = try ww.startupWindow();
    defer ww.shutdownWindow(window);

    const vs = try shaders.Module.create(.{
        .path = "shaders/triangle.vs",
        .shader_type = .VERTEX,
    });
    defer vs.destroy();

    const fs = try shaders.Module.create(.{
        .path ="shaders/triangle.fs",
        .shader_type = .FRAGMENT,
    });
    defer fs.destroy();

    const program = try shaders.Program.create(vs, fs);

    var vao = gl.VertexArray.create();
    defer vao.destroy();
    var vbo = gl.Buffer.create();
    defer vbo.destroy();
    var ebo = gl.Buffer.create();
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
        .normalized = false
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
        gl.DrawArrays(gl.TRIANGLES, 0, 3);

        const buffer = @embedFile("wall.jpg");
        var x: c_int = 0;
        var y: c_int = 0;
        var n_channels: c_int = 0;
        _ = c.stbi_load_from_memory(buffer, buffer.len, &x, &y, &n_channels, 0);

        window.swapBuffers();
    }
}
