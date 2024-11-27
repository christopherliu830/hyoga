const std = @import("std");
const sdl = @import("sdl");

pub const math = @import("hyoga-math");
pub const arena = @import("hyoga-arena");

pub const window = @import("window.zig");
pub const input = @import("input.zig");
pub const material = @import("graphics/material.zig");
pub const ui = @import("graphics/ui.zig");

pub const gpu = @import("graphics/gpu.zig");


const vec3 = math.vec3;

pub const Game = struct {
    quit: bool = false,
    scene: gpu.Scene = .{
        .camera = .{
            .position = vec3.create(0, 0, 2.5),
            .look_direction = vec3.mul(vec3.z, -1),
        },
        .light_dir = vec3.create(0, -2, -1),
    },
    user_data: ?*anyopaque = null,
    fn_update: *const fn (*Game) void,
};

pub fn init(allocator: std.mem.Allocator) void {
    input.init(allocator);
    window.init() catch std.debug.panic("Init window failed", .{});
    gpu.init(window.instance, allocator) catch std.debug.panic("Init GPU failed", .{});
    ui.init(.{
        .device = gpu.device(),
        .window = window.instance,
        .allocator = allocator
    }) catch std.debug.panic("Init UI failed", .{});
}

pub fn shutdown() void {
    ui.shutdown();
    gpu.shutdown();
    window.destroy();
}

pub fn run(game: *Game) !void {
    var open: bool = false;
    _ = &open;
    var last_render_result: ?gpu.RenderSubmitResult = null;
    _ = &last_render_result;
    while (!game.quit) {
        var event: sdl.events.Event = undefined;
        while (sdl.events.poll(&event)) {
            try ui.processEvent(event);
            input.update(event);

            switch (event.type) {
                sdl.events.type.quit => game.quit = true,
                else => {},
            }
        }


        try ui.beginFrame();

        game.fn_update(game);

        // if (ui.imgui.begin("Debug Window", &open, 0)) {
        //     const pos = game.scene.camera.position;

        //     var light_dir: [3]f32 = game.scene.light_dir.v;
        //     _ = ui.imgui.inputFloat3("Light Direction", &light_dir, null, 0);
        //     game.scene.light_dir.v = light_dir;

        //     ui.imgui.text("Camera Position: %f %f %f", pos.x(), pos.y(), pos.z());
        //     ui.imgui.text("Num Keys Down: %d", input.num_keys_down);

        //     if (ui.imgui.collapsingHeader_TreeNodeFlags("Rendering", 0)) {
        //         if (last_render_result) |render_result| {
        //             ui.imgui.text("Draw Calls: %d", render_result.num_draw_calls);
        //             ui.imgui.text("Drawn Vert Count: %d", render_result.num_drawn_verts);
        //         }
        //     }

        //     if (ui.imgui.button("Quit", .{ .x = -std.math.floatMin(f32), .y = 0 })) {
        //         quit = true;
        //     }
        // }

        // ui.imgui.end();

        const cmd = try gpu.begin();
        gpu.render(cmd, &game.scene) catch {};
        ui.render(cmd) catch {};
        last_render_result = gpu.submit(cmd);
    }
}
