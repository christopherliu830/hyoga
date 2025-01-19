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
    current_dst: ?[]const u8 = null,
    version: u32 = 1,

    pub fn link(name: []const u8, allocator: std.mem.Allocator) !HotReloader {
        const src_format_string = switch (builtin.os.tag) {
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
        self.reload() catch |e| {
            if (e == error.FileNotFound) {
                std.log.err("Game at {?s} not found", .{self.current_dst});
            } else {
                std.log.err("Could not reload library: {}", .{e});
            }
            return null;
        };
        return self.interface;
    }

    pub fn isStale(self: *HotReloader) bool {
        const st_lib = std.fs.cwd().statFile(self.src) catch |err| switch (err) {
            error.FileNotFound => return true,
            else => {
                std.log.err("Error checking hot library: {}", .{err});
                return false;
            },
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

        if (new_lib.lookup(*const fn () callconv(.C) hy.GameInterface, "interface")) |interface| {
            std.log.info("hot reload triggered", .{});

            self.interface = interface();
            self.last_write_time = src_stat.mtime;

            if (self.lib) |*lib| {
                lib.close();
                if (self.current_dst) |dst| {
                    try std.fs.cwd().deleteFile(dst);
                }
                self.current_dst = dest_file;
            }

            self.lib = new_lib;
            self.version += 1;
        } else {
            return error.LoadLibraryFailure;
        }
    }

    pub fn createFilename(self: *HotReloader, version: u32) ![]const u8 {
        const lib_basename = std.fs.path.stem(self.name);
        return try std.fmt.allocPrint(self.allocator, format_string, .{ lib_basename, version });
    }

    pub fn shutdown(self: *HotReloader) void {
        self.allocator.free(self.src);
        self.allocator.free(self.current_dst.?);
    }

    const format_string = switch (builtin.os.tag) {
        .windows => "{s}{}.dll",
        .macos => "lib{s}{}.dylib",
        else => unreachable,
    };
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var game = try HotReloader.link("game", allocator);

    const engine = hy.runtime.init();
    defer engine.shutdown();

    var gi = game.interface;
    var world = gi.init(engine);

    while (!world.quit) {
        while (!world.restart and !world.quit) {
            world = engine.update(world, gi);

            if (game.isStale()) {
                if (game.update()) |new_interface| {
                    gi = new_interface;
                    _ = gi.reload(engine, world);
                }
            }
        }

        if (game.update()) |new_interface| {
            gi = new_interface;
            _ = gi.reload(engine, world);
        }

        world.restart = false;
    }
}
