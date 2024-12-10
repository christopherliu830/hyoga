const std = @import("std");

const os = @import("builtin").target.os.tag;

pub const GpuBackend = enum {
    none,
    direct3d12,
    vulkan,
    metal
};

pub const Options = struct {
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    backend: GpuBackend,
};

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const dxc_enabled = b.option(bool, "dxc", "compile with dxc enabled") orelse false;

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


    const dll_wf = b.addNamedWriteFiles("dlls");

    sdl.addIncludePath(b.path("include"));
    sdl.addLibraryPath(b.path("lib"));
    sdl.linkSystemLibrary("SDL3", .{});

    _ = dll_wf.addCopyFile(b.path("lib/SDL3.dll"), "SDL3.dll");

    sdl_shadercross.addImport("sdl", sdl);

    sdl_shadercross.addIncludePath(b.path("include"));
    sdl_shadercross.addCSourceFile(.{
        .file = b.path("src/sdl_shadercross/SDL_shadercross.c"),
        .flags = &.{ if (dxc_enabled) "-DSDL_SHADERCROSS_DXC" else "" },
    });

    sdl_shadercross.linkSystemLibrary("spirv-cross-c-shared", .{});
    _ = dll_wf.addCopyFile(b.path("lib/spirv-cross-c-shared.dll"), "spirv-cross-c-shared.dll");

    if (dxc_enabled) {
        sdl_shadercross.linkSystemLibrary("dxil", .{});
        sdl_shadercross.linkSystemLibrary("dxcompiler", .{});
        _ = dll_wf.addCopyFile(b.path("lib/dxil.dll"), "dxil.dll");
        _ = dll_wf.addCopyFile(b.path("lib/dxcompiler.dll"), "dxcompiler.dll");
    }
}
