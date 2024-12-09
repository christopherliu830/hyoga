const std = @import("std");

const os = @import("builtin").target.os.tag;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{ });


    _ = b.addModule("sdl_shadercross", .{
        .root_source_file = b.path("src/sdl_shadercross.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const lib = b.addStaticLibrary(.{
        .name = "sdl_shadercross",
        .target = target,
        .optimize = optimize,
    });

    lib.addIncludePath(b.path("."));
    lib.addCSourceFile(.{ .file = b.path("SDL3_shadercross/SDL_shadercross.c"), });

    lib.addLibraryPath(b.dependency("sdl", .{}).path("lib"));
    lib.addIncludePath(b.dependency("sdl", .{}).path("include"));
    lib.linkSystemLibrary("SDL3");

    lib.addLibraryPath(b.path("SDL3_shadercross/external/DirectXShaderCompiler/lib"));
    lib.addLibraryPath(b.path("SDL3_shadercross/external/SPIRV-Cross/lib"));
    lib.addIncludePath(b.path("SDL3_shadercross/external/SPIRV-Cross"));
    lib.linkSystemLibrary("dxil");
    lib.linkSystemLibrary("spirv-cross-c-shared");

    lib.linkLibC();

    b.installArtifact(lib);
}

pub fn link(self: *std.Build, lib: *std.Build.Step.Compile) void {
    lib.addLibraryPath(self.path("SDL3_shadercross/external/DirectXShaderCompiler/lib"));
    lib.addLibraryPath(self.path("SDL3_shadercross/external/SPIRV-Cross/lib"));
    lib.linkSystemLibrary("dxil");
    lib.linkSystemLibrary("spirv-cross-c-shared");
}

pub fn installDX(self: *std.Build, b: *std.Build) ?*std.Build.Step.InstallFile {
    if (os == .windows) {
        const bin_path = self.path("SDL3_shadercross/external/DirectXShaderCompiler/lib/dxcompiler.dll");
        const dxcompiler = b.addInstallBinFile(bin_path, "dxcompiler.dll");
        const dxil_bin_path = self.path("SDL3_shadercross/external/DirectXShaderCompiler/lib/dxil.dll");
        const dxil = b.addInstallBinFile(dxil_bin_path, "dxil.dll");
        dxil.step.dependOn(&dxcompiler.step);
        return dxil;
    } 
    return null;
}

pub fn installSpirv(self: *std.Build, b: *std.Build) *std.Build.Step.InstallFile {
    const bin_path = self.path("SDL3_shadercross/external/SPIRV-Cross/lib/spirv-cross-c-shared.dll");
    return b.addInstallBinFile(bin_path, "spirv-cross-c-shared.dll");
}

