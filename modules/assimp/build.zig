const std = @import("std");

const os = @import("builtin").target.os.tag;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{ });

    const module = b.addModule("assimp", .{
        .root_source_file = b.path("assimp.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .link_libcpp = true,
    });

    if (os == .windows) {
        b.installBinFile("bin/assimp-vc143-mt.dll", "assimp-vc143-mt.dll");
        module.addLibraryPath(b.path("bin"));
        module.linkSystemLibrary("assimp-vc143-mt", .{});
    } 
}

