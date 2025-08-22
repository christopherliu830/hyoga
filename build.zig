const std = @import("std");
const builtin = @import("builtin");

pub const GpuDriver = @import("hyoga_rt").GpuDriver;

pub const InstallShadersStep = @import("src/build/InstallShadersStep.zig");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const dxc = b.option(bool, "dxc", "enable HLSL support") orelse false;

    const lib = b.dependency("hyoga_lib", .{
        .target = target,
        .optimize = optimize,
    });

    const rt = b.dependency("hyoga_rt", .{
        .target = target,
        .optimize = optimize,
        .dxc = dxc,
    });

    b.modules.put(b.dupe("lib"), lib.module("hyoga-lib")) catch @panic("OOM");
    b.modules.put(b.dupe("clay"), rt.module("clay")) catch @panic("OOM");

    b.installArtifact(rt.artifact("rt"));
    b.installArtifact(rt.artifact("runner"));

    const wf = b.addNamedWriteFiles("bin_files");
    _ = wf.addCopyDirectory(rt.namedWriteFiles("bin_files").getDirectory(), "", .{});

    try InstallShadersStep.init(b, wf, .{
        .install_dir = .bin,
        .source_path = b.path("shaders"),
        .dest_path = "shaders",
    });

    _ = wf.addCopyDirectory(b.path("shaders"), "shaders", .{ .include_extensions = &.{".json"} });
    _ = wf.addCopyDirectory(b.path("assets"), "assets", .{});

    // Language server

    const check = b.step("check", "check if run compiles");
    check.dependOn(&rt.artifact("rt").step);

    const test_step = b.step("test", "Run unit tests");
    const hy_unit_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = lib.path("src/root.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const run_unit_tests = b.addRunArtifact(hy_unit_tests);
    test_step.dependOn(&run_unit_tests.step);

    const tri = b.addExecutable(.{
        .name = "triangle",
        .root_module = b.createModule(.{
            .root_source_file = b.path("test/triangle.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{.{
                .name = "hyoga",
                .module = lib.module("hyoga-lib"),
            }},
        }),
    });

    b.installArtifact(tri);
}
