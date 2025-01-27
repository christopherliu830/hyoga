pub const material = @import("graphics/material.zig");
pub const Input = @import("input/Input.zig");
pub const UI = @import("graphics/ui.zig");
pub const Gpu = @import("graphics/gpu.zig");
pub const Loader = @import("graphics/loader.zig");
pub const Window = @import("window.zig");
pub const Strint = @import("strintern.zig");
pub const Phys2 = @import("phys2d/phys2d.zig");

const std = @import("std");
const sdl = @import("sdl");
const hy = @import("hyoga-lib");

const Engine = @This();

const World = @import("root.zig").World;
const GameInterface = @import("root.zig").GameInterface;

pub const Config = struct {
    max_fps: u32 = 256,
};

gpa: std.heap.GeneralPurposeAllocator(.{}),
arena: std.heap.ArenaAllocator,
game_arena: std.heap.ArenaAllocator,
window: Window,
strint: Strint,
input: Input,
gpu: *Gpu,
physics: Phys2,
ui: UI,
loader: Loader,
timer: std.time.Timer, // time since engine init in nanoseconds.
frame_timer: std.time.Timer, // time duration of last game state update.
render_timer: std.time.Timer, // time duration since last render.
physics_time: u64 = 0, // Time of most recent physics update
config: Config = .{},

pub fn init() !*Engine {
    var self_gpa: std.heap.GeneralPurposeAllocator(.{}) = .{};
    var self = self_gpa.allocator().create(Engine) catch hy.err.oom();

    self.* = .{
        .gpa = self_gpa,
        .arena = std.heap.ArenaAllocator.init(self.gpa.allocator()),
        .game_arena = std.heap.ArenaAllocator.init(self.gpa.allocator()),
        .strint = Strint.init(self.arena.allocator()),
        .input = Input.init(self.gpa.allocator()),
        .window = try Window.init(),
        .gpu = try Gpu.init(&self.window, &self.loader, &self.strint, self.gpa.allocator()),
        .physics = .init(),
        .ui = try UI.init(.{ .gpu = self.gpu, .window = &self.window, .allocator = self.gpa.allocator() }),
        .loader = undefined, // Init after in place, I don't know why but it crashes otherwise.
        .timer = std.time.Timer.start() catch unreachable,
        .frame_timer = std.time.Timer.start() catch unreachable,
        .render_timer = std.time.Timer.start() catch unreachable,
        .physics_time = 0,
    };

    try self.loader.init(self.gpa.allocator());
    return self;
}

pub fn shutdown(self: *Engine) void {
    self.loader.deinit();
    self.ui.shutdown();
    self.gpu.shutdown();
    self.input.shutdown();
    self.strint.shutdown();
    self.window.deinit();
    self.game_arena.deinit();
    self.arena.deinit();

    var gpa = self.gpa;
    gpa.allocator().destroy(self);
}

pub fn update(self: *Engine, old_game: World, gi: GameInterface) World {
    var game = old_game;

    const start_time = self.frame_timer.read();

    const zone = @import("ztracy").Zone(@src());
    defer zone.End();

    var event: sdl.events.Event = undefined;

    while (sdl.events.poll(&event)) {
        self.ui.processEvent(event) catch |err|
            std.log.err("[UI] processEvent failure: {}", .{err});

        if (!self.ui.wantsKeyboard()) self.input.updateKeyboard(event);
        if (!self.ui.wantsMouse()) self.input.updateMouse(event);

        switch (event.type) {
            sdl.events.type.quit => {
                game.quit = true;
                return game;
            },
            else => {},
        }
    }

    game.current_time = self.timer.read();

    // Physics

    while (self.physics.current_time < game.current_time) {
        self.physics.step();
    }

    // Game state

    game = gi.update(self, game);

    // Rendering

    const maybe_cmd = blk: {
        if (self.gpu.begin()) |cmd| {
            break :blk cmd;
        } else |err| {
            std.log.err("[GPU] Failed to begin frame for render: {}", .{err});
            return game;
        }
    };

    // If no command buffer, too many frames are in flight - skip rendering.
    if (maybe_cmd) |cmd| {
        self.ui.beginFrame() catch |err|
            std.log.err("[UI] Failed to begin frame for render: {}", .{err});

        gi.render(self, game);

        self.gpu.render(cmd, &game.scene, game.current_time) catch |err|
            std.log.err("[GPU] failed to finish render: {}", .{err});
        self.ui.render(cmd) catch |err|
            std.log.err("[UI] failed to finish render: {}", .{err});

        _ = self.gpu.submit(cmd);

        if (gi.afterRender != null) gi.afterRender.?(self, game);

        game.render_delta_time = self.render_timer.lap();
    }

    game.update_delta_time = self.frame_timer.lap();
    const update_duration = game.update_delta_time - start_time;
    const min_update_time: u64 = @intFromFloat(1 / @as(f64, @floatFromInt(self.config.max_fps)) * std.time.ns_per_s);
    if (min_update_time > update_duration) {
        std.time.sleep(min_update_time - update_duration);
    }

    @import("ztracy").FrameMark();
    return game;
}

pub fn gameAllocator(self: *Engine) hy.runtime.ExternAllocator {
    const allocator = self.game_arena.allocator();
    return .{
        .ptr = allocator.ptr,
        .vtable = allocator.vtable,
    };
}
