const std = @import("std");
const builtin = @import("builtin");

pub const Options = struct {
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
};

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const dxc_enabled = b.option(bool, "dxc", "compile with dxc enabled") orelse false;

    const sdl_dep = b.dependency("sdl", .{
        .target = target,
        .optimize = optimize,
    });

    const sdl = b.addModule("sdl", .{
        .root_source_file = b.path("src/sdl/sdl.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const sdl_shadercross = b.addModule("sdl_shadercross", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/sdl_shadercross/sdl_shadercross.zig"),
        .link_libc = true,
    });

    sdl.linkLibrary(sdl_dep.artifact("SDL3"));

    const c = b.addTranslateC(.{
        .link_libc = true,
        .optimize = optimize,
        .target = target,
        .root_source_file = sdl_dep.path("include/SDL3/SDL.h"),
    });
    c.addIncludePath(sdl_dep.path("include"));

    sdl.addImport("c", c.createModule());

    const sdl_lib = b.addLibrary(.{
        .name = "sdl",
        .root_module = sdl,
    });

    sdl_lib.installHeadersDirectory(sdl_dep.path("include"), ".", .{});

    b.installArtifact(sdl_lib);

    const dll_wf = b.addNamedWriteFiles("dlls");

    switch (builtin.target.os.tag) {
        .windows => {
            sdl_shadercross.addIncludePath(sdl_dep.path("include"));
            sdl_shadercross.addIncludePath(b.path("include"));
            sdl_shadercross.addLibraryPath(b.path("lib/windows"));
            if (dxc_enabled) {
                sdl_shadercross.linkSystemLibrary("dxcompiler", .{});
                _ = dll_wf.addCopyFile(b.path("bin/dxil.dll"), "dxil.dll");
                _ = dll_wf.addCopyFile(b.path("bin/dxcompiler.dll"), "dxcompiler.dll");
            }
            sdl_shadercross.linkSystemLibrary("spirv-cross-c-shared", .{});
            _ = dll_wf.addCopyFile(b.path("lib/windows/spirv-cross-c-shared.dll"), "spirv-cross-c-shared.dll");
        },
        .macos => {
            sdl_shadercross.addIncludePath(sdl_dep.path("include"));
            sdl_shadercross.addIncludePath(b.path("include"));
            sdl_shadercross.addObjectFile(b.path("lib/macos/libspirv-cross-c.a"));
            sdl_shadercross.addObjectFile(b.path("lib/macos/libspirv-cross-core.a"));
            sdl_shadercross.addObjectFile(b.path("lib/macos/libspirv-cross-cpp.a"));
            sdl_shadercross.addObjectFile(b.path("lib/macos/libspirv-cross-glsl.a"));
            sdl_shadercross.addObjectFile(b.path("lib/macos/libspirv-cross-hlsl.a"));
            sdl_shadercross.addObjectFile(b.path("lib/macos/libspirv-cross-msl.a"));
            sdl_shadercross.addObjectFile(b.path("lib/macos/libspirv-cross-reflect.a"));
            sdl_shadercross.addObjectFile(b.path("lib/macos/libspirv-cross-util.a"));
        },
        else => unreachable,
    }

    sdl_shadercross.addImport("sdl", sdl);

    sdl_shadercross.addCSourceFile(.{
        .file = b.path("src/sdl_shadercross/SDL_shadercross.c"),
        .flags = &.{
            if (dxc_enabled) "-DSDL_SHADERCROSS_DXC" else "",
        },
    });
}
