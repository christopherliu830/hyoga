//! Link to game and library dlls and run.

const std = @import("std");
const hy = @import("hyoga");
const game_api = @import("game");

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    defer _ = gpa.detectLeaks();

    const allocator = gpa.allocator();

    load();

    hy.init(allocator);
    defer hy.shutdown();
}

fn load() hy.GameInterface {
    const lib = std.DynLib.open("game.dll") catch {
        @panic("no lib");
    };
    _ = lib;
}