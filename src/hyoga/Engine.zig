const std = @import("std");
const sdl = @import("sdl");

pub const math = @import("hyoga-math");
pub const slotmap = @import("hyoga-arena");
pub const window = @import("window.zig");
pub const material = @import("graphics/material.zig");

pub const Input = @import("input/Input.zig");
pub const Symbol = @import("Symbol.zig");
pub const UI = @import("graphics/ui.zig");
pub const Gpu = @import("graphics/gpu.zig");
pub const Hive = @import("hive.zig").Hive;
pub const Game = @import("Game.zig").Game;
pub const GameInterface = @import("Game.zig").GameInterface;
pub const Loader = @import("graphics/loader.zig");

const Engine = @This();

gpa: std.heap.GeneralPurposeAllocator(.{}),
arena: std.heap.ArenaAllocator,
symbol: Symbol,
input: Input,
gpu: Gpu,
ui: UI,
loader: Loader,

pub fn init() !*Engine {

    var self_gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    var self = self_gpa.allocator().create(Engine)
        catch std.debug.panic("out of memory", .{});

    window.init() catch |e| std.debug.panic("|e| Window init failure: {}", .{e});

    self.* = .{
        .gpa = self_gpa,
        .arena = std.heap.ArenaAllocator.init(self.gpa.allocator()),
        .symbol = Symbol.init(self.arena.allocator()),
        .input = try Input.init(self.gpa.allocator()),
        .gpu = try Gpu.init(window.instance, &self.loader, &self.symbol, self.gpa.allocator()),
        .ui = try UI.init(.{.gpu = &self.gpu, .window = window.instance, .allocator = self.gpa.allocator()}),
        .loader = undefined,
    };

    try self.loader.init(self.gpa.allocator());

    self.setGlobalState();

    return self;
}

pub fn shutdown(self: *Engine) void {
    self.loader.deinit();
    self.ui.shutdown();
    self.gpu.shutdown();
    window.destroy();
    self.input.shutdown();
    self.symbol.shutdown();
    self.arena.deinit();

    var gpa = self.gpa;
    gpa.allocator().destroy(self);
    _ = gpa.detectLeaks();
    _ = gpa.deinit();
}

pub fn update(self: *Engine, old_game: Game, gi: GameInterface) Game {
    var game = old_game;

    var time = std.time.Timer.start() catch unreachable;

    const zone = @import("ztracy").Zone(@src());
    defer zone.End();

    var event: sdl.events.Event = undefined;

    while (sdl.events.poll(&event)) {
        self.ui.processEvent(event) catch |err| 
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
        if (self.gpu.begin()) |cmd| {
            break :blk cmd;
        } else |err| {
            std.log.err("[GPU] Failed to begin frame for render: {}", .{err});
            return game;
        }
    };

    if (q_cmd) |cmd| {
        self.ui.beginFrame() catch |err| std.log.err("[UI] Failed to begin frame for render: {}", .{err});

        gi.render(self, game);

        self.gpu.render(cmd, &game.scene) catch |err| std.log.err("[GPU] failed to finish render: {}", .{err});
        self.ui.render(cmd) catch |err| std.log.err("[UI] failed to finish render: {}", .{err});
        _ = self.gpu.submit(cmd);
    } else return game; // Too many frames in flight, skip rendering.
    game.frame_time = time.lap();

    @import("ztracy").FrameMark();
    return game;

}

/// Global variables don't get loaded across DLL boundaries, meaning
/// any libraries and modules that use global variables must be set here
/// on DLL load.
pub fn setGlobalState(self: *Engine) void {
    self.ui.useState(); // Uses IMGUI
    self.gpu.render_state.textures.image_loader.use(); // Uses STBI
}
