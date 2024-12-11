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

pub fn update(old_game: Game, gi: GameInterface) Game {
    var game = old_game;

    var time = std.time.Timer.start() catch unreachable;

    const zone = @import("ztracy").Zone(@src());
    defer zone.End();

    var event: sdl.events.Event = undefined;

    while (sdl.events.poll(&event)) {
        ui.processEvent(event) catch |err| 
            std.log.err("[UI] processEvent failure: {}", .{err});

        input.update(event);

        switch (event.type) {
            sdl.events.type.quit => {
                game.quit = true;
                return game;
            },
            else => {},
        }
    }

    game = gi.update(game);

    const q_cmd = blk: {
        if (gpu.begin()) |cmd| {
            break :blk cmd;
        } else |err| {
            std.log.err("[GPU] Failed to begin frame for render: {}", .{err});
            return game;
        }
    };

    if (q_cmd) |cmd| {
        ui.beginFrame() catch |err| std.log.err("[UI] Failed to begin frame for render: {}", .{err});

        gi.render(game);

        gpu.render(cmd, &game.scene) catch |err| std.log.err("[GPU] failed to finish render: {}", .{err});
        ui.render(cmd) catch |err| std.log.err("[UI] failed to finish render: {}", .{err});
        _ = gpu.submit(cmd);
    } else return game; // Too many frames in flight, skip rendering.
    game.frame_time = time.lap();

    @import("ztracy").FrameMark();
    return game;
}
