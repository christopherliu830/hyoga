const std = @import("std");
const gl = @import("gl.zig");
const window = @import("window.zig");
const input = @import("input.zig");
const zlm = @import ("zlm/zlm.zig");
const math = @import("math.zig");
const sdl = @import("sdl/sdl.zig");
const gpu = @import("gpu.zig");
const hym = @import("hym/hym.zig");

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

    try window.init();
    defer window.destroy();

    try gpu.init(window.instance);

    input.init(allocator);
    try input.bind(sdl.keycode.up, .{ .name = "mixup", .handler =  mixUp, });
    try input.bind(sdl.keycode.down, .{ .name = "mixdown", .handler = mixDown });

    var quit = false;
    while (!quit) {
        var event: sdl.events.Event = undefined;
        while (sdl.events.poll(&event)) {
            switch (event.type) {
                sdl.events.quit => quit = true,
                sdl.events.key_down => {
                    std.log.debug("key pressed: {}, {}, {}", .{ event.key, sdl.keycode.up, sdl.keycode.down });
                    const key = event.key.key;
                    input.post(key, undefined, .{ .down = true });
                },
                sdl.events.key_up => {
                    const key = event.key.key;
                    input.post(key, undefined, .{ .up = true });
                },
                else => {},
            }
        }

        i += 1;
        try gpu.render();
    }
}

pub fn mixUp(_: ?*anyopaque) void {
    gpu.window_state.angle.add(hym.vec(.{ 1, 0, 0 }));
}

pub fn mixDown(_: ?*anyopaque) void {
    gpu.window_state.angle.add(hym.vec(.{ 0, 1, 0 }));
}
