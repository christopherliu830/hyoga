const std = @import("std");
const gl = @import("gl.zig");
const ww = @import("window.zig");
const input = @import("input.zig");
const zlm = @import ("zlm/zlm.zig");
const c = @import("c.zig");

const Vec3 = zlm.Vec3;

const vertices = [_]f32{
    0.5, 0.5, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0, // top right
    0.5, -0.5, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0, // bottom right
    -0.5, -0.5, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, // bottom left
    -0.5, 0.5, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0, // top left
};

const indices = [_]u32{ 0, 1, 3, 1, 2, 3 };
var i: f32 = 0;

const tex_coords = [_]f32{
    0.0, 0.0,
    1.0, 0.0,
    0.5, 1.0,
};

const Context = struct {
    program: gl.Program,
    mix_amount: f32 = 0,
};

// void main() {
pub fn main() !void {
    var general_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = general_allocator.allocator();


    const window = try ww.startupWindow();
    defer ww.shutdownWindow(window);

    try gl.init(window);

    const vs = try gl.Module.create(.{
        .path = "shaders/triangle.vs",
        .shader_type = .VERTEX,
    });
    defer vs.destroy();

    const fs = try gl.Module.create(.{
        .path = "shaders/triangle.fs",
        .shader_type = .FRAGMENT,
    });
    defer fs.destroy();

    // Create program and assign texture units (used later in texture.bind)
    var program = try gl.Program.create(vs, fs);
    program.set("texture1", 0);
    program.set("texture2", 1);

    const tex = try gl.Texture.create("textures/wall.jpg");
    defer tex.destroy();
    const tex2 = try gl.Texture.create("textures/awesomeface.png");
    defer tex2.destroy();


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
        .normalized = false,
    }).add(.{
        .size = 2,
        .type = .FLOAT,
        .normalized = false,
    }).use();

    var context = Context { .program = program, .mix_amount = 0 };

    try input.init(allocator, window);
    try input.bind(.up, .{
        .name = "mix-up",
        .handler = mixUp,
        .fire_on = .{ .down = true },
        .ctx = &context,
    });
    try input.bind(.down, .{
        .name = "mix-down",
        .handler = mixDown,
        .fire_on = .{ .down = true },
        .ctx = &context,
    });

    var quit = false;
    while (!quit) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_EVENT_QUIT => {
                    quit = true;
                },
                else => {},
            }
        }

        gl.Clear(gl.COLOR_BUFFER_BIT);

        const time: f32 = @floatCast(std.math.sin(i));
        i += 1;
        program.set("color", @Vector(4, f32){ 0, time, 0, 0 });

        program.use();
        tex.bind(0);
        tex2.bind(1);
        _ = zlm.Mat4.createLookAt(Vec3.new(0, 10, 0), Vec3.zero, Vec3.unitY);
        vao.bind();
        gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, 0);

        ww.swapBuffers(window);
        c.SDL_Delay(17);
    }
}

pub fn mixUp(context: *anyopaque) void {
    const ctx: *Context = @ptrCast(@alignCast(context));
    ctx.*.mix_amount += 0.1;
    ctx.*.program.set("mix_amount", ctx.*.mix_amount);
}

pub fn mixDown(context: *anyopaque) void {
    const ctx: *Context = @ptrCast(@alignCast(context));
    ctx.*.mix_amount -= 0.1;
    ctx.*.program.set("mix_amount", ctx.*.mix_amount);
}
