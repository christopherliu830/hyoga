const std = @import("std");
const builtin = @import("builtin");
const hy = @import("hyoga-lib");
const root = @import("root.zig");

pub const HotReloader = struct {
    allocator: std.mem.Allocator,
    lib: ?std.DynLib = null,
    interface: root.GameInterface,
    last_write_time: i128 = 0,
    name: []const u8,
    src: []const u8,
    version: u32 = 1,

    pub fn link(name: []const u8, allocator: std.mem.Allocator) !HotReloader {
        const src_format_string = switch (builtin.os.tag) {
            .windows => "{s}.dll",
            .macos => "./lib{s}.dylib",
            else => unreachable,
        };

        const src = try std.fmt.allocPrint(allocator, src_format_string, .{name});

        var lib: HotReloader = .{
            .allocator = allocator,
            .name = name,
            .interface = undefined,
            .src = src,
        };

        try lib.reload();

        return lib;
    }

    /// Returns the fresh interface if the library was updated.
    /// On error or stale dll, returns null.
    pub fn update(self: *HotReloader) ?root.GameInterface {
        self.reload() catch |e| {
            if (e == error.FileNotFound) {
                std.log.err("library at {s}{} not found", .{ self.name, self.version });
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
        var ara: std.heap.ArenaAllocator = .init(self.allocator);
        defer ara.deinit();
        const arena = ara.allocator();

        const lib_basename = std.fs.path.stem(self.name);

        const format_string = switch (builtin.os.tag) {
            .windows => "{s}{}.dll",
            .macos => "lib{s}{}.dylib",
            else => unreachable,
        };

        const src_pdb = try std.fmt.allocPrint(arena, "{s}.pdb", .{lib_basename});
        const dest_pdb = try std.fmt.allocPrint(arena, "{s}{}.pdb", .{ lib_basename, self.version });
        const dest_file = try std.fmt.allocPrint(arena, format_string, .{ lib_basename, self.version });

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

        std.fs.cwd().copyFile(src_pdb, std.fs.cwd(), dest_pdb, .{}) catch |err| {
            if (err == error.FileNotFound) std.log.warn("source file pdb '{s}' not found", .{src_pdb});
        };

        var new_lib = std.DynLib.open(dest_file) catch |err| {
            if (err == error.FileNotFound) std.log.err("lib '{s}' not found", .{dest_file});
            return err;
        };

        if (new_lib.lookup(*const fn () callconv(.c) root.GameInterface, "interface")) |interface| {
            std.log.info("hot reload triggered", .{});

            self.interface = interface();
            self.last_write_time = src_stat.mtime;

            if (self.lib) |*lib| {
                lib.close();
                const prev_dest = try std.fmt.allocPrint(arena, format_string, .{ lib_basename, self.version - 1 });
                const prev_pdb = try std.fmt.allocPrint(arena, "{s}{}.pdb", .{ lib_basename, self.version - 1 });
                try std.fs.cwd().deleteFile(prev_dest);
                try std.fs.cwd().deleteFile(prev_pdb);
            }

            self.lib = new_lib;
            self.version += 1;
        } else {
            return error.LoadLibraryFailure;
        }
    }

    pub fn shutdown(self: *HotReloader) void {
        self.allocator.free(self.src);
    }
};

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    const allocator = gpa.allocator();

    var game = try HotReloader.link("game", allocator);

    var engine = root.init();
    defer engine.shutdown();

    var gi = game.interface;
    gi.procs(root.procs());
    var world = gi.init(engine);

    while (!world.quit) {
        world = engine.update(world, gi);

        if (game.isStale() or world.restart) {
            gi = game.update() orelse gi;
            gi.procs(root.procs());
            _ = gi.reload(engine, world);
            world.restart = false;
        }
    }

    gi.shutdown(engine, world);
}
