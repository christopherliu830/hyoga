const std = @import("std");
const camera = @import("camera.zig");
const window = @import("window.zig");
const input = @import("input.zig");
const zlm = @import ("zlm/zlm.zig");
const math = @import("math.zig");
const sdl = @import("sdl");
const gpu = @import("graphics/gpu.zig");
const vec3 = @import("hym/vec3.zig");
const imgui = @import("graphics/imgui/imgui.zig");
const imgui_sdl = @import("graphics/imgui/imgui_impl_sdl.zig");
const imgui_impl_sdlgpu = @import("graphics/imgui/imgui_impl_sdlgpu.zig");

pub fn main() !void {
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
    const ctx = imgui.igCreateContext(null).?;
    defer imgui.igDestroyContext(ctx);
    try imgui_sdl.init(window.instance, allocator);
    defer imgui_sdl.shutdown();
    const init_info = imgui_impl_sdlgpu.InitInfo { .device = gpu.device, .window = gpu.window_state.hdl_window };
    try imgui_impl_sdlgpu.init(&init_info, allocator);
    defer imgui_impl_sdlgpu.shutdown();

    input.init(allocator);

    try scene.camera.registerInputs();

    var quit = false;
    var open: bool = false;
    var last_render_result: ?gpu.RenderSubmitResult = null;
    while (!quit) {
        var event: sdl.events.Event = undefined;
        while (sdl.events.pollEvent(&event)) {
            _ = try imgui_sdl.processEvent(&event);
            input.update(event);

            switch (event.type) {
                sdl.events.quit => quit = true,
                else => {},
            }
        }

        try imgui_impl_sdlgpu.newFrame();
        try imgui_sdl.newFrame();
        imgui.newFrame();

        if (imgui.begin("Debug Window", &open, 0)) {
            const pos = scene.camera.position;

            var light_dir: [3]f32 = scene.light_dir.v;
            _ = imgui.inputFloat3("Light Direction", &light_dir, null, 0);
            scene.light_dir.v = light_dir;

            imgui.text("Camera Position: %f %f %f", pos.x(), pos.y(), pos.z());
            imgui.text("Num Keys Down: %d", input.num_keys_down);

            if (imgui.collapsingHeader_TreeNodeFlags("Rendering", 0)) {
                if (last_render_result) |render_result| {
                    imgui.text("Draw Calls: %d", render_result.num_draw_calls);
                    imgui.text("Drawn Vert Count: %d", render_result.num_drawn_verts);
                }
            }

            if (imgui.button("Quit", .{ .x = -std.math.floatMin(f32), .y = 0 })) {
                quit = true;
            }
        }
        imgui.end();

        const render = try gpu.begin();
        imgui.render();
        try imgui_impl_sdlgpu.renderDrawData(imgui.getDrawData(), render.cmd, render.pass);
        last_render_result = gpu.submit(render);
    }
}

