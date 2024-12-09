const std = @import("std");
const os = @import("builtin").target.os.tag;
const Root = @This();

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{ });

    const sdl = b.dependency("sdl", .{ .target = target, .optimize = optimize });

    const lib = b.addStaticLibrary(.{
        .name = "sdl_shadercross",
        .target = target,
        .optimize = optimize,
    });

    lib.addIncludePath(b.path("SDL_shadercross/include/"));
    lib.addCSourceFile(.{ .file = b.path("SDL_shadercross/src/SDL_shadercross.c"), });

    // Link to sibling module SDL
    lib.addLibraryPath(sdl.path("lib"));
    lib.addIncludePath(sdl.path("include"));
    lib.linkSystemLibrary("SDL3");

    linkLibraries(b, lib);

    lib.linkLibC();

    const module = b.addModule("root", .{
        .root_source_file = b.path("src/sdl_shadercross.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    module.addImport("sdl", sdl.module("sdl"));
    module.linkLibrary(lib);
}

pub const BuildTool = struct {
    builder: *std.Build,

    pub fn init(self: *@This(), b: *std.Build) void {
        self.builder = b.dependency("sdl_shadercross").builder;
    }

    pub fn linkLibraries(self: *@This(), lib: *std.Build.Step.Compile) void {
        lib.addLibraryPath(self.builder.path("SDL_shadercross/lib"));
        if (os == .windows) { lib.linkSystemLibrary("dxil"); }
        lib.linkSystemLibrary("spirv-cross-c-shared");
    }

    pub fn install(self: *@This(), exe: *std.Build.Step.Compile) void {
        const dxcompiler = self.builder.addInstallBinFile(self.builder.path("SDL_shadercross/lib/dxcompiler.dll"), "dxcompiler.dll");
        const dxil = self.builder.addInstallBinFile(self.builder.path("SDL_shadercross/lib/dxil.dll"), "dxil.dll");
        const spirv = self.builder.addInstallBinFile(self.builder.path("SDL_shadercross/lib/spirv-cross-c-shared.dll"), "spirv-cross-c-shared.dll");
        exe.step.dependOn(&dxcompiler.step);
        exe.step.dependOn(&dxil.step);
        exe.step.dependOn(&spirv.step);
    }
};




// pub fn installDX(self: *std.Build, b: *std.Build) ?*std.Build.Step.InstallFile {
//     if (os == .windows) {
//         const bin_path = self.path("SDL_shadercross/lib/dxcompiler.dll");
//         const dxcompiler = b.addInstallBinFile(bin_path, "dxcompiler.dll");
//         const dxil_bin_path = self.path("SDL_shadercross/lib/dxil.dll");
//         const dxil = b.addInstallBinFile(dxil_bin_path, "dxil.dll");
//         dxil.step.dependOn(&dxcompiler.step);
//         return dxil;
//     } 
//     return null;
// }

// pub fn installSpirv(self: *std.Build, b: *std.Build) *std.Build.Step.InstallFile {
//     const bin_path = self.path("SDL_shadercross/lib/spirv-cross-c-shared.dll");
//     return b.addInstallBinFile(bin_path, "spirv-cross-c-shared.dll");
// }

