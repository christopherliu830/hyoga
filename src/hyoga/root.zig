const std = @import("std");
const vec3 = @import("hym/vec3.zig");
const sdl = @import("sdl");

pub const window = @import("window.zig");
pub const input = @import("input.zig");
pub const gpu = @import("graphics/gpu.zig");
pub const ui = @import("graphics/ui.zig");

pub fn run() !void {
    var general_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = general_allocator.allocator();

    try window.init();
    defer window.destroy();

    var scene = gpu.Scene {
        .camera = .{
            .position = vec3.create(0, 0, 2.5),
            .look_direction = vec3.mul(vec3.z, -1),
        },
        .light_dir = vec3.create(0, -2, -1),
    };

    try gpu.init(window.instance, &scene, allocator);
    defer gpu.shutdown();

    // imgui
    try ui.init(.{
        .device = gpu.device,
        .window = window.instance,
        .allocator = allocator,
    });
    defer ui.shutdown();

    input.init(allocator);
    try scene.camera.registerInputs();

    var quit = false;
    var open: bool = false;
    var last_render_result: ?gpu.RenderSubmitResult = null;
    while (!quit) {
        var event: sdl.events.Event = undefined;
        while (sdl.events.pollEvent(&event)) {
            try ui.processEvent(event);
            input.update(event);

            switch (event.type) {
                sdl.events.quit => quit = true,
                else => {},
            }
        }

        try ui.beginFrame();

        if (ui.imgui.begin("Debug Window", &open, 0)) {
            const pos = scene.camera.position;

            var light_dir: [3]f32 = scene.light_dir.v;
            _ = ui.imgui.inputFloat3("Light Direction", &light_dir, null, 0);
            scene.light_dir.v = light_dir;

            ui.imgui.text("Camera Position: %f %f %f", pos.x(), pos.y(), pos.z());
            ui.imgui.text("Num Keys Down: %d", input.num_keys_down);

            if (ui.imgui.collapsingHeader_TreeNodeFlags("Rendering", 0)) {
                if (last_render_result) |render_result| {
                    ui.imgui.text("Draw Calls: %d", render_result.num_draw_calls);
                    ui.imgui.text("Drawn Vert Count: %d", render_result.num_drawn_verts);
                }
            }

            if (ui.imgui.button("Quit", .{ .x = -std.math.floatMin(f32), .y = 0 })) {
                quit = true;
            }
        }

        ui.imgui.end();

        const render_cmd = try gpu.begin();
        ui.render(render_cmd.cmd, render_cmd.pass) catch {};
        last_render_result = gpu.submit(render_cmd);
    }
}