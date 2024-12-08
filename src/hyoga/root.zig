const std = @import("std");
const sdl = @import("sdl");

pub const math = @import("hyoga-math");
pub const arena = @import("hyoga-arena");
pub const Hive = @import("hive.zig").Hive;
pub const symbol = @import("symbol.zig");

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
    fn_render: *const fn (*Game) void,
    frame_time: u64 = 0,
};

pub fn init(allocator: std.mem.Allocator) void {
    symbol.init(allocator);
    input.init(allocator);
    window.init() catch std.debug.panic("Init window failed", .{});
    gpu.init(window.instance, allocator) catch |e| std.debug.panic("[GPU] Init failure: {}", .{e});
    ui.init(.{
        .device = gpu.device(),
        .window = window.instance,
        .allocator = allocator
    }) catch std.debug.panic("Init UI failed", .{});
}

pub fn shutdown() void {
    input.shutdown();
    ui.shutdown();
    gpu.shutdown();
    window.destroy();
    symbol.shutdown();
}

pub fn run(game: *Game) !void {

    var open: bool = false;
    _ = &open;
    var last_render_result: ?gpu.RenderSubmitResult = null;
    _ = &last_render_result;
    var time = try std.time.Timer.start();
    while (!game.quit) {
        const zone = @import("ztracy").Zone(@src());
        defer zone.End();

        var event: sdl.events.Event = undefined;

        while (sdl.events.poll(&event)) {
            try ui.processEvent(event);
            input.update(event);

            switch (event.type) {
                sdl.events.type.quit => game.quit = true,
                else => {},
            }
        }

        game.fn_update(game);

        if (try gpu.begin()) |cmd| {
            try ui.beginFrame();
            game.fn_render(game);

            try gpu.render(cmd, &game.scene);
            try ui.render(cmd);
            last_render_result = gpu.submit(cmd);
        } 

        game.frame_time = time.lap();
        @import("ztracy").FrameMark();
    }
}
