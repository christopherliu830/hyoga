const std = @import("std");

const os = @import("builtin").target.os.tag;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{ });

    const module = b.addModule("imgui", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/imgui.zig"),
        .link_libc = true,
        .link_libcpp = true,
    });

    module.addIncludePath(b.path("imgui"));

    module.addCSourceFiles(.{
        .files = &.{
            "cimgui.cpp",
            "imgui/imgui_demo.cpp",
            "imgui/imgui_draw.cpp",
            "imgui/imgui_tables.cpp",
            "imgui/imgui_widgets.cpp",
            "imgui/imgui.cpp",
            "implot/implot_demo.cpp",
            "implot/implot_items.cpp",
            "implot/implot.cpp",
        },
    });

}