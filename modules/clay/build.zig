const std = @import("std");
const B = std.Build;

pub fn build(b: *B) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const clay = b.addModule("clay", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/root.zig"),
    });

    const clay_lib = b.addLibrary(.{
        .name = "clay",
        .linkage = .static,
        .root_module = clay,
    });

    const clay_dep = b.dependency("clay", .{});
    clay_lib.addIncludePath(clay_dep.path(""));

    clay.addCSourceFile(.{
        .file = b.addWriteFiles().add("clay.c",
            \\#define CLAY_IMPLEMENTATION
            \\#include<clay.h>
        ),
        .flags = &.{"-ffreestanding"},
    });
}
