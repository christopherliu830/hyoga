const std = @import("std");
const hy = @import("hyoga");

export fn hyInit() *hy.Engine {
    return hy.init();
}

export fn hyShutdown(hye: *hy.Engine) void {
    return hye.shutdown();
}

export fn hyUpdate(hye: *hy.Engine, game: hy.Game, gi: hy.GameInterface) hy.Game {
    return hye.update(game, gi);
}