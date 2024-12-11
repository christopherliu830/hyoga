//! Link to game and library dlls and run.

const std = @import("std");
const hy = @import("hyoga");
const game_api = @import("game");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};

    const allocator = gpa.allocator();

    hy.init(allocator);
    defer hy.shutdown();

    const gi = load(allocator) catch |err| { 
        std.log.err("could not load library {}", .{err});
    };

    var game = gi.init();
    defer gi.shutdown();

    game = gi.update(game);
    gi.render(game);
}

fn load(arena: std.mem.Allocator) !hy.GameInterface {
    const temp_dir = std.fs.cwd().makeOpenPath(".hy", .{}) catch {
        @panic("could not open temp directory");
    };

    var dll_pathw_buf: [512:0]u16 = undefined;
    var lib = try std.DynLib.open("game.dll");
    const dll_pathw = try std.os.windows.GetModuleFileNameW(lib.inner.dll, &dll_pathw_buf, 512);
    lib.close();

    const path = try std.unicode.utf16LeToUtf8Alloc(arena, dll_pathw);
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    const src_stat = try file.stat();

    {
        var atomic_file = try temp_dir.atomicFile("game.dll", .{ .mode = src_stat.mode });
        defer atomic_file.deinit();
        try atomic_file.file.writeFileAll(file, .{ .in_len = src_stat.size });
        try atomic_file.file.updateTimes(src_stat.atime, src_stat.mtime);
        try atomic_file.finish();
    }

    const dest_path = try temp_dir.realpathAlloc(arena, "game.dll");
    var lib_copy = try std.DynLib.open(dest_path);
    const interface = lib_copy.lookup(*const fn() callconv(.C) hy.GameInterface, "interface").?;
    return interface();
}