const std = @import("std");
const gl = @import("gl.zig");
const window = @import("window.zig");
const input = @import("input.zig");
const zlm = @import ("zlm/zlm.zig");
const math = @import("math.zig");
const sdl = @import("sdl/sdl.zig");
const gpu = @import("gpu.zig");
const hym = @import("hym/vec3.zig");

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
    _ = allocator;

    try window.init();
    defer window.destroy();

    try gpu.init(window.instance);

    var quit = false;
    while (!quit) {
        var event: sdl.c.SDL_Event = undefined;
        while (sdl.c.SDL_PollEvent(&event)) {
            switch (event.type) {
                sdl.c.SDL_EVENT_QUIT => quit = true,
                // c.SDL_EVENT_KEY_DOWN,
                // c.SDL_EVENT_KEY_UP => {
                //     const key: window.Key = @enumFromInt(event.key.key);
                //     const action: window.Action = @enumFromInt(event.key.@"type");
                //     input.post(key, undefined, action);
                // },
                else => {},
            }
        }

        i += 1;
        try gpu.render();
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
