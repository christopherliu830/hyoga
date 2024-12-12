const std = @import("std");
const sdl = @import("sdl");

pub const hym = @import("hyoga-math");
pub const hya = @import("hyoga-arena");
pub const Symbol = @import("Symbol.zig");
pub const window = @import("window.zig");
pub const Input = @import("Input.zig");
pub const material = @import("graphics/material.zig");
pub const ui = @import("graphics/ui.zig");
pub const gpu = @import("graphics/gpu.zig");

pub const Hive = @import("hive.zig").Hive;
pub const Game = @import("Game.zig").Game;
pub const GameInterface = @import("Game.zig").GameInterface;

const vec3 = hym.vec3;

const Self = @This();

gpa: std.heap.GeneralPurposeAllocator(.{}),
arena: std.heap.ArenaAllocator,
symbol: Symbol,
input: Input,

pub fn init() *Self {
    return tryInit() catch |err| std.debug.panic("error during init", .{err});
}

fn tryInit() !*Self {

    var self_gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    var self = self_gpa.allocator().create(Self)
        catch std.debug.panic("out of memory", .{});

    self.* = .{
        .gpa = self_gpa,
        .arena = std.heap.ArenaAllocator.init(self.gpa.allocator()),
        .symbol = Symbol.init(self.arena.allocator()),
        .input = Input.init(self.gpa.allocator()),
    };

    window.init() catch |e| std.debug.panic("|e| Window init failure: {}", .{e});

    gpu.init(window.instance, self.gpa.allocator(), &self.symbol) catch |e| std.debug.panic("[GPU] GPU init failure: {}", .{e});
    ui.init(.{
        .device = gpu.device(),
        .window = window.instance,
        .allocator = self.gpa.allocator(),
    }) catch std.debug.panic("UI Init failure", .{});

    return self;
}

pub fn shutdown(self: *Self) void {
    ui.shutdown();
    gpu.shutdown();
    window.destroy();
    self.input.shutdown();
    self.symbol.shutdown();
    self.arena.deinit();

    var gpa = self.gpa;
    gpa.allocator().destroy(self);
    _ = gpa.detectLeaks();
    _ = gpa.deinit();
}

pub fn update(self: *Self, old_game: Game, gi: GameInterface) Game {
    var game = old_game;

    if (game.imgui_state.context == null) {
        @branchHint(.cold);
        game.imgui_state = ui.getState();
    }

    var time = std.time.Timer.start() catch unreachable;

    const zone = @import("ztracy").Zone(@src());
    defer zone.End();

    var event: sdl.events.Event = undefined;

    while (sdl.events.poll(&event)) {
        ui.processEvent(event) catch |err| 
            std.log.err("[UI] processEvent failure: {}", .{err});

        self.input.update(event);

        switch (event.type) {
            sdl.events.type.quit => {
                game.quit = true;
                return game;
            },
            else => {},
        }
    }

    game = gi.update(self, game);

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

        gi.render(self, game);

        gpu.render(cmd, &game.scene) catch |err| std.log.err("[GPU] failed to finish render: {}", .{err});
        ui.render(cmd) catch |err| std.log.err("[UI] failed to finish render: {}", .{err});
        _ = gpu.submit(cmd);
    } else return game; // Too many frames in flight, skip rendering.
    game.frame_time = time.lap();

    @import("ztracy").FrameMark();
    return game;
}
