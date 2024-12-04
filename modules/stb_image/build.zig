const std = @import("std");

const os = @import("builtin").target.os.tag;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    // const optimize = b.standardOptimizeOption(.{ });

    const module = b.addModule("stb_image", .{
        .root_source_file = b.path("src/stb_image.zig"),
        .target = target,
        .optimize = .ReleaseFast,
        .link_libc = true,
    });

    module.addIncludePath(b.path("src"));

    module.addCSourceFile(.{ 
        .file = b.path("src/stb_image.c"), 
        .flags = &[_][]const u8{"-std=c99"},
    });
}