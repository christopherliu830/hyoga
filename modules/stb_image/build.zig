const std = @import("std");

const os = @import("builtin").target.os.tag;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const module = b.addModule("stb_image", .{
        .root_source_file = b.path("src/stb_image.zig"),
        .target = target,
        .optimize = optimize,
    });

    const translate_c = b.addTranslateC(.{
        .root_source_file = b.path("src/stb_image.h"),
        .target = target,
        .optimize = optimize,
    });

    translate_c.addIncludePath(b.path("src"));
    const c = translate_c.createModule();
    module.addImport("c", c);

    module.addCSourceFile(.{
        .file = b.path("src/stb_image.c"),
        .flags = &[_][]const u8{"-std=c99"},
    });
}
