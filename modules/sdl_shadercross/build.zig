const std = @import("std");
const os = @import("builtin").target.os.tag;
const Sdl = @import("sdl");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const dxc = b.option(bool, "dxc", "Enable HLSL compilation via DXC") orelse true;

    const sdl = Sdl.dependency(b, "sdl", .{
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addStaticLibrary(.{
        .name = "sdl_shadercross",
        .target = target,
        .optimize = optimize,
    });

    const root = b.addModule("root", .{
        .root_source_file = b.path("src/sdl_shadercross.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    lib.addIncludePath(b.path("SDL_shadercross/include/"));
    lib.addCSourceFile(.{
        .file = b.path("SDL_shadercross/src/SDL_shadercross.c"),
        .flags = &[_][]const u8 {
            if (dxc) "-DSDL_SHADERCROSS_DXC" else "",
        },
    });
    const bt = BuildTool { .builder = b, .dep = b };
    bt.link(lib);

    // Link to sibling module SDL
    sdl.linkLibrary(lib);
    sdl.exportModule(root);

    root.linkLibrary(lib);

}

pub fn dependency(b: *std.Build, dep_name: []const u8, options: anytype) BuildTool {
    const dep = b.dependency(dep_name, options);
    return .{ .builder = b, .dep = dep.builder };
}

pub const BuildTool = struct {
    builder: *std.Build,
    dep: *std.Build,

    pub fn link(self: @This(), target: *std.Build.Step.Compile) void {
        target.addLibraryPath(self.dep.path("SDL_shadercross/lib"));
        target.linkSystemLibrary("dxil");
        target.linkSystemLibrary("dxcompiler");
        target.linkSystemLibrary("spirv-cross-c-shared");
        target.linkLibC();
    }

    pub fn install(self: @This(), exe: *std.Build.Step.Compile) void {
        const dxcompiler = self.builder.addInstallBinFile(
            self.dep.path("SDL_shadercross/lib/dxcompiler.dll"),
            "dxcompiler.dll");

        const dxil = self.builder.addInstallBinFile(
            self.dep.path("SDL_shadercross/lib/dxil.dll"),
            "dxil.dll");

        const spirv = self.builder.addInstallBinFile(
            self.dep.path("SDL_shadercross/lib/spirv-cross-c-shared.dll"), 
            "spirv-cross-c-shared.dll");

        exe.step.dependOn(&dxcompiler.step);
        exe.step.dependOn(&dxil.step);
        exe.step.dependOn(&spirv.step);
    }

    pub fn exportModule(self: @This(), module: *std.Build.Module) void {
        module.addImport("sdl_shadercross", self.dep.modules.get("root").?);
    }
};
