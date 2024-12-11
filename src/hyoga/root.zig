const std = @import("std");
const sdl = @import("sdl");

pub const math = @import("hyoga-math");
pub const arena = @import("hyoga-arena");
pub const symbol = @import("symbol.zig");
pub const window = @import("window.zig");
pub const input = @import("input.zig");
pub const material = @import("graphics/material.zig");
pub const ui = @import("graphics/ui.zig");
pub const gpu = @import("graphics/gpu.zig");

pub const Hive = @import("hive.zig").Hive;
pub const Game = @import("Game.zig").Game;
pub const GameInterface = @import("Game.zig").GameInterface;

const vec3 = math.vec3;

pub fn init(allocator: std.mem.Allocator) void {
    symbol.init(allocator);
    input.init(allocator);
    window.init() catch |e| std.debug.panic("|e| Window init failure: {}", .{e});
    gpu.init(window.instance, allocator) catch |e| std.debug.panic("[GPU] GPU init failure: {}", .{e});
    ui.init(.{
        .device = gpu.device(),
        .window = window.instance,
        .allocator = allocator
    }) catch std.debug.panic("UI Init failure", .{});
}

pub fn shutdown() void {
    ui.shutdown();
    gpu.shutdown();
    window.destroy();
    input.shutdown();
    symbol.shutdown();
}

pub fn run(options: Game.CreateOptions) !void {
    var time = try std.time.Timer.start();

    var game = Game.create(options);

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

        game = game.fn_update(game);

        if (try gpu.begin()) |cmd| {
            try ui.beginFrame();
            game.fn_render(game);

            try gpu.render(cmd, &game.scene);
            try ui.render(cmd);
            game.frame_time = time.lap();
        } 

        @import("ztracy").FrameMark();
    }
}
