//! Link to game and library dlls and run.

const std = @import("std");
const hy = @import("hyoga");

const HotLibrary = struct {
    lib: ?std.DynLib,
    interface: hy.GameInterface,
    last_write_time: i128,
    original_path: []const u8,
    copy_basepath: []const u8,
    version: u32 = 0,

    pub fn isStale(self: HotLibrary) !bool {
        const st_dll = std.fs.cwd().statFile(self.original_path) catch |err| switch(err) {
            error.FileNotFound => return true,
            else => return err,
        };
        return st_dll.mtime > self.last_write_time;
    }

    pub fn reload(self: *HotLibrary, arena: std.mem.Allocator) !void {
        const dest_path = try std.fmt.allocPrint(arena, ".hy/game{}.dll", .{self.version });
        self.version += 1;

        const file = try std.fs.cwd().openFile(self.original_path, .{});
        defer file.close();
        const src_stat = try file.stat();

        {
            var atomic_file = try std.fs.cwd().atomicFile(dest_path, .{ .mode = src_stat.mode });
            defer atomic_file.deinit();
            try atomic_file.file.writeFileAll(file, .{ .in_len = src_stat.size });
            try atomic_file.file.updateTimes(src_stat.atime, src_stat.mtime);
            try atomic_file.finish();

        }

        var new_lib = try std.DynLib.open(dest_path);
        if (new_lib.lookup(*const fn() callconv(.C) hy.GameInterface, "interface")) |interface| {
            std.log.debug("Hot reload triggered", .{});
            self.interface = interface();
            self.last_write_time = src_stat.mtime;
            self.close();
            self.lib = new_lib;
        } else {
            return error.LoadLibraryFailure;
        }
    }

    pub fn close(self: *HotLibrary) void {
        self.lib.?.close();
        self.lib = null;
    }

    pub fn shutdown() void {

    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = gpa.allocator();
    var arena_allocator = std.heap.ArenaAllocator.init(allocator);
    const arena = arena_allocator.allocator();

    hy.init(allocator);
    defer hy.shutdown();

    var src_lib = load(allocator) catch |err| { 
        std.log.err("could not load library {}", .{err});
        return err;
    };

    var gi = src_lib.interface;
    var game = gi.init();

    if (gi.reloadImgui) |reloadImgui| {
        reloadImgui(hy.ui.getState());
    }

    while (!game.quit) {

        game = hy.update(game, gi);

        if (try src_lib.isStale()) {
            src_lib.reload(arena) catch |err| std.debug.panic("Could not reload library: {}", .{err});
            gi = src_lib.interface;

            if (gi.reloadImgui) |reloadImgui| {
                reloadImgui(hy.ui.getState());
            }
        }

        _ = arena_allocator.reset(.retain_capacity);
    }
}



fn load(arena: std.mem.Allocator) !HotLibrary {
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
    return .{
        .lib = lib_copy,
        .interface = interface(),
        .last_write_time = src_stat.mtime,
        .original_path = path,
        .copy_basepath= std.fs.path.dirname(dest_path).?,
    };
}