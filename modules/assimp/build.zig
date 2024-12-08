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
        module.addLibraryPath(b.path("bin"));
        module.linkSystemLibrary("assimp-vc143-mt", .{});
    } else {
        module.addLibraryPath(b.path("bin"));
        module.linkSystemLibrary("assimp", .{});
    }

}

pub fn install(self: *std.Build, b: *std.Build) ?*std.Build.Step.InstallFile {
    if (os == .windows) {
        return b.addInstallBinFile(self.path("bin/assimp-vc143-mt.dll"), "assimp-vc143-mt.dll");
    }
    return null;
}