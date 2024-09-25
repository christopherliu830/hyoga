const std = @import("std");
const gl = @import("gl.zig");
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
const camera = @import("camera.zig");

pub fn main() !void {
    var general_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = general_allocator.allocator();

    try window.init();
    defer window.destroy();

    try gpu.init(window.instance);

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

    try input.bind(sdl.keycode.up, .{ .name = "mixup", .handler =  mixUp });
    try input.bind(sdl.keycode.down, .{ .name = "mixdown", .handler = mixDown });
    try input.bind(sdl.keycode.left, .{ .name = "mixleft", .handler = mixLeft });
    try input.bind(sdl.keycode.right, .{ .name = "mixright", .handler = mixRight });

    var cam = camera.Camera {};
    try cam.registerInputs();

    var quit = false;
    var open: bool = false;
    while (!quit) {
        var event: sdl.events.Event = undefined;
        while (sdl.events.pollEvent(&event)) {
            input.update(event);
            _ = try imgui_sdl.processEvent(&event);

            switch (event.type) {
                sdl.events.quit => quit = true,

                sdl.events.mouse_motion => {
                    if (input.mouse.button_1) {
                        gpu.window_state.angle.add(vec3.mul(vec3.y, event.motion.xrel / 100));
                        gpu.window_state.angle.add(vec3.mul(vec3.x, event.motion.yrel / 100));
                    }
                },

                sdl.events.mouse_wheel => {
                    gpu.window_state.distance += event.wheel.y;
                },

                else => {},
            }
        }
        gpu.window_state.cam_position = cam.position;

        try imgui_impl_sdlgpu.newFrame();
        try imgui_sdl.newFrame();
        imgui.newFrame();
        imgui.showDemoWindow(&open);

        const render = try gpu.begin();
        imgui.render();
        imgui_impl_sdlgpu.renderDrawData(imgui.getDrawData(), render.cmd, render.pass);
        gpu.submit(render);
    }
}

pub fn mixUp(_: ?*anyopaque) void {
    gpu.window_state.angle.add(vec3.create(0.1, 0, 0));
    std.log.debug("{}", .{gpu.window_state.angle});
}

pub fn mixDown(_: ?*anyopaque) void {
    gpu.window_state.angle.sub(vec3.create(0.1, 0, 0));
    std.log.debug("{}", .{gpu.window_state.angle});
}

pub fn mixRight(_: ?*anyopaque) void {
    gpu.window_state.angle.add(vec3.create(0 , 0.1, 0));
    std.log.debug("{}", .{gpu.window_state.angle});
}

pub fn mixLeft(_: ?*anyopaque) void {
    gpu.window_state.angle.sub(vec3.create(0, 0.1, 0));
    std.log.debug("{}", .{gpu.window_state.angle});
}

