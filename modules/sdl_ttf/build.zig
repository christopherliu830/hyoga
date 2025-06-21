const std = @import("std");
const Build = std.Build;

pub fn build(b: *Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // SDL option
    const dxc_enabled = b.option(bool, "dxc", "compile with dxc enabled") orelse false;

    const sdl_dep = b.dependency("sdl", .{
        .target = target,
        .optimize = optimize,
        .dxc = dxc_enabled,
    });

    const sdl_ttf_dep = b.dependency("sdl_ttf", .{
        .target = target,
        .optimize = optimize,
    });

    const freetype = b.dependency("freetype", .{
        .target = target,
        .optimize = optimize,
    });

    const harfbuzz_dep = b.dependency("harfbuzz", .{
        .target = target,
        .optimize = optimize,
    });

    const harfbuzz = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libcpp = true,
    });

    const lib_harfbuzz = b.addLibrary(.{
        .name = "harfbuzz",
        .linkage = .static,
        .root_module = harfbuzz,
    });

    harfbuzz.addCSourceFile(.{ .file = harfbuzz_dep.path("src/harfbuzz.cc") });
    harfbuzz.addCMacro("HAVE_FREETYPE", "1");
    harfbuzz.linkLibrary(freetype.artifact("freetype"));

    const sdl_ttf = b.addModule("sdl_ttf", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/root.zig"),
        .imports = &.{.{
            .name = "sdl",
            .module = sdl_dep.module("sdl"),
        }},
    });

    sdl_ttf.linkLibrary(sdl_dep.artifact("sdl"));
    sdl_ttf.linkLibrary(freetype.artifact("freetype"));
    sdl_ttf.linkLibrary(lib_harfbuzz);
    sdl_ttf.addIncludePath(sdl_ttf_dep.path("include"));
    sdl_ttf.addIncludePath(harfbuzz_dep.path("src"));

    sdl_ttf.addCSourceFiles(.{ .root = sdl_ttf_dep.path("src"), .files = &.{
        "SDL_hashtable.c",
        "SDL_hashtable_ttf.c",
        "SDL_gpu_textengine.c",
        "SDL_renderer_textengine.c",
        "SDL_surface_textengine.c",
        "SDL_ttf.c",
    }, .flags = &.{
        "-DTTF_USE_HARFBUZZ",
        "-DTTF_USE_SDF",
    } });

    const lib_sdl_ttf = b.addLibrary(.{
        .name = "sdl_ttf",
        .root_module = sdl_ttf,
    });

    b.installArtifact(lib_sdl_ttf);
}
