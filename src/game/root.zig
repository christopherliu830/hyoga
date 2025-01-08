const std = @import("std");
const hy = @import("hyoga-lib");
const game = @import("game.zig");

const log = std.log.scoped(.game);

fn init(engine: *hy.Engine) callconv(.C) hy.World {
    return game.init(engine) catch |e| std.debug.panic("init failure: {}", .{e});
}

fn shutdown(_: *hy.Engine, state: hy.World) callconv(.C) void {
    const ptr = @as(*u32, @ptrCast(@alignCast(state.memory)));
    std.heap.page_allocator.destroy(ptr);
}

fn reload(engine: *hy.Engine, world: hy.World) callconv(.C) bool {
    game.reload(engine, world)
        catch |e| {
            log.err("Reload failure: {}", .{e});
            return false;
        };
    return true;
}


export fn interface() hy.GameInterface {
    return .{
        .init = init,
        .shutdown = shutdown,
        .update = game.update,
        .render = game.render,
        .afterRender = game.afterRender,
        .reload = reload,
    };
}
