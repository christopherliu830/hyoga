const std = @import("std");

const os = @import("builtin").target.os.tag;

const module_name = "assimp";

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{ });

    const module = b.addModule(module_name, .{
        .root_source_file = b.path("assimp.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .link_libcpp = true,
    });

    if (os == .windows) {
        module.addLibraryPath(b.path("lib"));
        module.linkSystemLibrary("assimp-vc143-mt", .{});
    } else {
        module.addLibraryPath(b.path("lib"));
        module.linkSystemLibrary("assimp", .{});
    }
}

pub fn dependency(b: *std.Build, dep_name: []const u8, options: anytype) BuildTool {
    const dep = b.dependency(dep_name, options);
    return .{ .builder = b, .dep = dep.builder };
}

pub const BuildTool = struct {
    builder: *std.Build,
    dep: *std.Build,

    pub fn install(self: BuildTool, target: *std.Build.Step.Compile) void {
        if (os == .windows) {
            const install_file = self.builder.addInstallBinFile(self.dep.path("lib/assimp-vc143-mt.dll"), "assimp-vc143-mt.dll");
            target.step.dependOn(&install_file.step);
        }
    }

    pub fn link(self: BuildTool, target: *std.Build.Step.Compile) void {
        if (os == .windows) {
            target.addLibraryPath(self.dep.path("lib"));
            target.linkSystemLibrary("assimp-vc143-mt", .{});
        } else {
            target.addLibraryPath(self.dep.path("lib"));
            target.linkSystemLibrary("assimp", .{});
        }

    }

    pub fn exportModule(self: BuildTool, target: *std.Build.Module) void {
        target.addImport(module_name, self.dep.modules.get(module_name).?);
    }

};
