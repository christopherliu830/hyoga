//! Link to game and library dlls and run.

const std = @import("std");
const builtin = @import("builtin");
const hy = @import("hyoga-lib");

const HotReloader = struct {
    lib: ?std.DynLib = null,
    interface: hy.GameInterface,
    last_write_time: i128 = 0,
    allocator: std.mem.Allocator,
    name: []const u8,
    src: []const u8,
    current_dst: []const u8 = &.{},
    version: u32 = 1,

    pub fn link(name: []const u8, allocator: std.mem.Allocator) !HotReloader {
        const src_format_string = switch(builtin.os.tag) {
            .windows => "{s}.dll",
            .macos => "./lib{s}.dylib",
            else => unreachable,
        };

        var lib: HotReloader = .{
            .allocator = allocator,
            .name = name,
            .interface = undefined,
            .src = try std.fmt.allocPrint(allocator, src_format_string, .{name}),
        };
        try lib.reload();

        return lib;
    }

    /// Returns the fresh interface if the library was updated.
    /// On error or stale dll, returns null.
    pub fn update(self: *HotReloader) ?hy.GameInterface {
        if (!(self.isStale() catch return null)) {
            return null;
        } else {
            self.reload() catch |e| {
                std.log.err("Could not reload library: {}", .{e});
                return null;
            };
            return self.interface;
        }
    }

    pub fn isStale(self: *HotReloader) !bool {
        const st_lib = std.fs.cwd().statFile(self.src) catch |err| switch(err) {
            error.FileNotFound => return true,
            else => return err,
        };
        return st_lib.mtime > self.last_write_time;
    }

    pub fn reload(self: *HotReloader) !void {
        const dest_file = try self.createFilename(self.version);
        const file = try std.fs.cwd().openFile(self.src, .{});
        defer file.close();
        const src_stat = try file.stat();

        { // Copy file to destination atomically
            var atomic_file = try std.fs.cwd().atomicFile(dest_file, .{ .mode = src_stat.mode });
            defer atomic_file.deinit();
            try atomic_file.file.writeFileAll(file, .{ .in_len = src_stat.size });
            try atomic_file.file.updateTimes(src_stat.atime, src_stat.mtime);
            try atomic_file.finish();
        }

        var new_lib = try std.DynLib.open(dest_file);

        if (new_lib.lookup(*const fn() callconv(.C) hy.GameInterface, "interface")) |interface| {
            std.log.info("hot reload triggered", .{});

            self.interface = interface();
            self.last_write_time = src_stat.mtime;

            if (self.lib != null) {
                try self.unload(self.current_dst);
                self.current_dst = dest_file;
            }

            self.lib = new_lib;
            self.version += 1;
        } else {
            return error.LoadLibraryFailure;
        }
    }

    pub fn unload(self: *HotReloader, path: []const u8) !void {
        self.lib.?.close();
        try std.fs.cwd().deleteFile(path);
        self.lib = null;
    }

    pub fn createFilename(self: *HotReloader, version: u32) ![]const u8 {
        const lib_basename = std.fs.path.stem(self.name);
        return try std.fmt.allocPrint(self.allocator, format_string, .{lib_basename, version});
    }

    pub fn shutdown(self: *HotReloader) void {
        self.allocator.free(self.src);
        self.allocator.free(self.current_dst);
    }

    const format_string = switch(builtin.os.tag) {
        .windows => "{s}{}.dll",
        .macos => "lib{s}{}.dylib",
        else => unreachable,
    };
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}) {};
    const allocator = gpa.allocator();
    var arena = std.heap.ArenaAllocator.init(allocator);

    var game = try HotReloader.link("game", arena.allocator());

    var world: hy.World = undefined;

    const engine = hy.runtime.init();
    defer engine.shutdown();

    while (!world.quit) {

        var gi = game.interface;
        world = gi.init(engine);

        while (!world.restart and !world.quit) {
            world = engine.update(world, gi);

            if (game.update()) |new_interface| {
                gi = new_interface;
                _ = gi.reload(engine, world);
            }

            _ = arena.reset(.retain_capacity);
        }
    }
}
