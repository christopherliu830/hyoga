const std = @import("std");
const builtin = @import("builtin");

pub const GpuBackend = enum { none, direct3d12, vulkan, metal };

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

    switch (builtin.target.os.tag) {
        .windows => {
            sdl.addIncludePath(b.path("include"));
            sdl.addLibraryPath(b.path("lib/windows"));
            sdl.linkSystemLibrary("SDL3", .{});
            sdl_shadercross.addIncludePath(b.path("include"));
            sdl_shadercross.addLibraryPath(b.path("lib/windows"));
            _ = dll_wf.addCopyFile(b.path("lib/windows/SDL3.dll"), "SDL3.dll");
            if (optimize == .Debug) {
                _ = dll_wf.addCopyFile(b.path("lib/windows/SDL3.pdb"), "SDL3.pdb");
            }

            if (dxc_enabled) {
                sdl_shadercross.linkSystemLibrary("dxil", .{});
                sdl_shadercross.linkSystemLibrary("dxcompiler", .{});
                _ = dll_wf.addCopyFile(b.path("lib/dxil.dll"), "dxil.dll");
                _ = dll_wf.addCopyFile(b.path("lib/dxcompiler.dll"), "dxcompiler.dll");
            }
            sdl_shadercross.linkSystemLibrary("spirv-cross-c-shared", .{});
            _ = dll_wf.addCopyFile(b.path("lib/windows/spirv-cross-c-shared.dll"), "spirv-cross-c-shared.dll");
        },
        .macos => {
            sdl.addIncludePath(b.path("include"));
            sdl.addLibraryPath(b.path("lib/macos"));
            sdl.linkSystemLibrary("SDL3", .{});
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
        .flags = &.{if (dxc_enabled) "-DSDL_SHADERCROSS_DXC" else ""},
    });
}
