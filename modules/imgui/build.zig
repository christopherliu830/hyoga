const std = @import("std");
const builtin = @import("builtin");

const os = @import("builtin").target.os.tag;

const has_crc32 = std.Target.x86.featureSetHas(builtin.cpu.features, .crc32);

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const dep_cimgui = b.dependency("cimgui", .{
        .target = target,
        .optimize = optimize,
    });

    const dep_implot = b.dependency("implot", .{
        .target = target,
        .optimize = optimize,
    });

    const lib_cimgui_docking = b.addStaticLibrary(.{
        .name = "cimgui_clib_docking",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const implot_lib = b.addStaticLibrary(.{
        .name = "implot_lib",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const imgui = b.addModule("imgui", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/imgui.zig"),
        .link_libc = true,
        .link_libcpp = true,
    });

    const implot = b.addModule("implot", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/implot.zig"),
        .link_libc = true,
        .link_libcpp = true,
        .imports = &.{.{ .name = "imgui", .module = imgui }},
    });

    lib_cimgui_docking.linkLibCpp();
    lib_cimgui_docking.addCSourceFiles(.{
        .root = dep_cimgui.path("src-docking"),
        .files = &.{
            "cimgui.cpp",
            "imgui_demo.cpp",
            "imgui_draw.cpp",
            "imgui_tables.cpp",
            "imgui_widgets.cpp",
            "imgui.cpp",
        },
    });

    imgui.linkLibrary(lib_cimgui_docking);

    implot_lib.addIncludePath(dep_cimgui.path("src-docking"));
    implot_lib.addIncludePath(dep_implot.path("."));
    implot_lib.addCSourceFile(.{ .file = b.path("cimplot.cpp") });
    implot_lib.addCSourceFiles(.{
        .root = dep_implot.path("."),
        .files = &.{
            "implot_demo.cpp",
            "implot_items.cpp",
            "implot.cpp",
        },
    });
    implot.linkLibrary(implot_lib);
}
