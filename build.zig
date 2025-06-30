const std = @import("std");
const builtin = @import("builtin");

pub const GpuDriver = @import("hyoga_rt").GpuDriver;

pub const InstallShadersStep = @import("src/build/InstallShadersStep.zig");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const dxc = b.option(bool, "dxc", "enable HLSL support") orelse false;
    const enable_tracy = b.option(bool, "enable_tracy", "enable profiling with tracy") orelse false;
    const backend = b.option(GpuDriver, "gpu_driver", "force backend graphics driver") orelse .none;

    const lib = b.dependency("hyoga_lib", .{
        .target = target,
        .optimize = optimize,
    });

    const rt = b.dependency("hyoga_rt", .{
        .target = target,
        .optimize = optimize,
        .enable_tracy = enable_tracy,
        .gpu_driver = backend,
        .dxc = dxc,
    });

    b.modules.put(b.dupe("lib"), lib.module("hyoga-lib")) catch @panic("OOM");
    b.modules.put(b.dupe("imgui"), rt.module("imgui")) catch @panic("OOM");
    b.modules.put(b.dupe("implot"), rt.module("implot")) catch @panic("OOM");
    b.modules.put(b.dupe("ztracy"), rt.module("ztracy")) catch @panic("OOM");
    b.modules.put(b.dupe("clay"), rt.module("clay")) catch @panic("OOM");

    b.installArtifact(rt.artifact("rt"));

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
}
