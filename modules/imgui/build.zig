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

    const imgui = b.addModule("imgui", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/imgui.zig"),
        .link_libc = true,
        .link_libcpp = true,
    });

    imgui.linkLibrary(dep_cimgui.artifact("cimgui_docking_clib"));
}
