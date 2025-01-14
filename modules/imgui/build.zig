const std = @import("std");
const builtin = @import("builtin");

const os = @import("builtin").target.os.tag;

const has_crc32 = std.Target.x86.featureSetHas(builtin.cpu.features, .crc32);

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const imgui = b.addModule("imgui", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/imgui.zig"),
        .link_libc = true,
        .link_libcpp = true,
    });

    imgui.addIncludePath(b.path("imgui"));

    imgui.addCSourceFiles(.{
        .files = &.{
            "dcimgui.cpp",
            "imgui/imgui_demo.cpp",
            "imgui/imgui_draw.cpp",
            "imgui/imgui_tables.cpp",
            "imgui/imgui_widgets.cpp",
            "imgui/imgui.cpp",
        },
    });

    const implot = b.addModule("implot", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/implot.zig"),
        .link_libc = true,
        .link_libcpp = true,
    });

    implot.addIncludePath(b.path("imgui"));
    implot.addCSourceFiles(.{
        .files = &.{
            "cimplot.cpp",
            "implot/implot_demo.cpp",
            "implot/implot_items.cpp",
            "implot/implot.cpp",
        },
    });

    implot.addImport("imgui", imgui);
}
