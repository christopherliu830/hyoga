const std = @import("std");
const builtin = @import("builtin");

const module_name = "root";

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const module = b.addModule(module_name, .{
        .root_source_file = b.path("assimp.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .link_libcpp = true,
    });

    module.addLibraryPath(b.path("lib"));

    switch (builtin.target.os.tag) {
        .windows => module.linkSystemLibrary("assimp-vc143-mt", .{}),
        .macos => {
            module.addObjectFile(b.path("lib/libassimp.a"));
            module.linkSystemLibrary("z", .{});
        },
        else => {},
    }

    const wf_dlls = b.addNamedWriteFiles("dlls");
    switch (builtin.target.os.tag) {
        .windows => _ = wf_dlls.addCopyFile(b.path("lib/assimp-vc143-mt.dll"), "assimp-vc143-mt.dll"),
        else => {},
    }
}
