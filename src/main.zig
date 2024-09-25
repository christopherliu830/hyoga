const std = @import("std");
const camera = @import("camera.zig");
const window = @import("window.zig");
const input = @import("input.zig");
const zlm = @import ("zlm/zlm.zig");
const math = @import("math.zig");
const sdl = @import("sdl/sdl.zig");
const gpu = @import("gpu.zig");
const vec3 = @import("hym/vec3.zig");
const imgui = @import("imgui/imgui.zig");
const imgui_sdl = @import("imgui/imgui_impl_sdl.zig");
const imgui_impl_sdlgpu = @import("imgui/imgui_impl_sdlgpu.zig");

pub fn main() !void {
    var general_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = general_allocator.allocator();

    try window.init();
    defer window.destroy();

    var scene = gpu.Scene {
        .camera = .{
            .position = vec3.create(0, 0, 2.5),
            .look_direction = vec3.mul(vec3.z, -1),
        }
    };

    try gpu.init(window.instance, &scene);

    // imgui
    const ctx = imgui.igCreateContext(null).?;
    defer imgui.igDestroyContext(ctx);
    try imgui_sdl.init(window.instance, allocator);
    defer imgui_sdl.shutdown();
    const init_info = imgui_impl_sdlgpu.InitInfo { .device = gpu.device, .window = gpu.window_state.hdl_window };
    try imgui_impl_sdlgpu.init(&init_info, allocator);
    defer imgui_impl_sdlgpu.shutdown();
    imgui_impl_sdlgpu.createFontsTexture();

    input.init(allocator);

    try scene.camera.registerInputs();

    var quit = false;
    var open: bool = false;
    _ = &open;
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

        // My windows
        if (imgui.begin("Debug Window", &open, 0)) {
            const pos = scene.camera.position;
            imgui.text("Camera Position: %f %f %f", pos.x(), pos.y(), pos.z());

            if (imgui.button("Quit", .{ .x = 120, .y = 20 })) {
                quit = true;
            }
        }
        imgui.end();

        const render = try gpu.begin();
        imgui.render();
        imgui_impl_sdlgpu.renderDrawData(imgui.getDrawData(), render.cmd, render.pass);
        gpu.submit(render);
    }
}

