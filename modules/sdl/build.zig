const std = @import("std");

const os = @import("builtin").target.os.tag;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{ });

    const module = b.addModule("sdl", .{
        .root_source_file = b.path("src/sdl.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    if (os == .windows) {
        module.addLibraryPath(b.path("bin"));
        module.linkSystemLibrary("SDL3", .{});
        b.installBinFile("bin/SDL3.dll", "SDL3.dll");
    } 

    module.addIncludePath(b.path("include"));
}
