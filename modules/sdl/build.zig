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

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const root = b.addModule("root", .{
        .root_source_file = b.path("src/sdl.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    if (os == .windows) {
        root.addLibraryPath(b.path("lib"));
    } 

    root.linkSystemLibrary("SDL3", .{});
    root.addIncludePath(b.path("include"));
}

pub fn dependency(b: *std.Build, dep_name: []const u8, options: anytype) BuildTool {
    const dep = b.dependency(dep_name, options);
    return .{ .builder = b, .dep = dep.builder };
}

pub const BuildTool = struct {
    builder: *std.Build,
    dep: *std.Build,

    pub fn install(self: @This(), exe: *std.Build.Step.Compile) void {
        if (os == .windows) {
            const install_file = self.builder.addInstallBinFile(self.dep.path("lib/SDL3.dll"), "SDL3.dll");
            exe.step.dependOn(&install_file.step);
        } 
    }

    pub fn exportModule(self: @This(), module: *std.Build.Module) void {
        module.addImport("sdl", self.dep.modules.get("root").?);
    }

    pub fn linkLibrary(self: @This(), lib: *std.Build.Step.Compile) void {
        lib.addLibraryPath(self.dep.path("lib"));
        lib.addIncludePath(self.dep.path("include"));
        lib.linkSystemLibrary("SDL3");
    }
};

