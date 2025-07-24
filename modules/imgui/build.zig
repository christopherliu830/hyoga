const std = @import("std");
const builtin = @import("builtin");

const os = @import("builtin").target.os.tag;

const has_crc32 = std.Target.x86.featureSetHas(builtin.cpu.features, .crc32);

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const dep_cimgui = b.dependency("cimgui", .{
        .target = target,
        .optimize = optimize,
    });

    const dep_sdl = b.dependency("sdl", .{
        .target = target,
        .optimize = optimize,
    });

    const imgui = b.addModule("imgui", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/imgui.zig"),
        .link_libc = true,
        .link_libcpp = true,
    });

    imgui.addCMacro("IMGUI_DISABLE_OBSOLETE_FUNCTIONS", "1");
    imgui.linkLibrary(dep_cimgui.artifact("cimgui_docking_clib"));

    const exe_module = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/main.zig"),
    });

    const exe = b.addExecutable(.{
        .name = "demo",
        .root_module = exe_module,
    });

    exe_module.addImport("imgui", imgui);
    exe_module.addImport("sdl", dep_sdl.module("sdl"));

    b.installArtifact(exe);
}
