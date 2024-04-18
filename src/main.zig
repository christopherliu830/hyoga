const std = @import("std");
const glfw = @import("mach-glfw");
const gl = @import("./gl.zig");
const ww = @import("./window.zig");

const vertices = [_]f32 {
    -0.5, -0.5, 0.0,
     0.5, -0.5, 0.0,
     0.0,  0.5, 0.0
};

pub fn main() !void {
    std.debug.print("\n\n", .{});

    const window = try ww.startupWindow();
    defer ww.shutdownWindow(window);

    const vao = try gl.createVao();
    const vbo = try gl.createBuffer();
    gl.BindVertexArray(vao);
    gl.BindBuffer(gl.ARRAY_BUFFER, vbo);
    gl.BufferData(gl.ARRAY_BUFFER, @sizeOf(@TypeOf(vertices)), &vertices, gl.STATIC_DRAW);
    
    const vs = try gl.createShaderModuleFromFile("shaders/triangle.vs", gl.VERTEX_SHADER);
    defer gl.DeleteShader(vs);
    const fs = try gl.createShaderModuleFromFile("shaders/triangle.fs", gl.FRAGMENT_SHADER);
    defer gl.DeleteShader(fs);

    const program = try gl.createShaderProgram(vs, fs);

    const attrib_0 = 0;
    gl.VertexAttribPointer(attrib_0, 3, gl.FLOAT, gl.FALSE, 3 * @sizeOf(f32), 0);
    gl.EnableVertexAttribArray(attrib_0);

    while (!window.shouldClose()) {
        window.swapBuffers();
        glfw.pollEvents();

        if (window.getKey(.escape) == .press) {
            window.setShouldClose(true);
        }

        gl.Clear(gl.COLOR_BUFFER_BIT);
        gl.UseProgram(program);

        const color_location = gl.GetUniformLocation(program, "color");
        const time: f32 = @floatCast(std.math.sin(glfw.getTime()));
        gl.Uniform4f(color_location, 0, time, 0, 0);

        gl.BindVertexArray(vao);
        gl.DrawArrays(gl.TRIANGLES, 0, 3);
    }

}
