const std = @import("std");
const builtin = @import("builtin");

pub const GpuDriver = @import("hyoga_rt").GpuDriver;

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const dxc = b.option(bool, "dxc", "enable HLSL support") orelse false;
    const enable_tracy = b.option(bool, "enable_tracy", "enable profiling with tracy") orelse false;
    const backend = b.option(GpuDriver, "gpu_driver", "force backend graphics driver") orelse .none;
    const gen_shaders = b.option(bool, "compile_shaders", "force shader compile") orelse false;

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

    const imgui = b.dependency("imgui", .{
        .target = target,
        .optimize = optimize,
    });

    const ztracy = b.dependency("ztracy", .{
        .target = target,
        .optimize = optimize,
        .enable_ztracy = enable_tracy,
        .enable_fibers = true,
    });

    b.modules.put(b.dupe("lib"), lib.module("hyoga-lib")) catch @panic("OOM");
    b.modules.put(b.dupe("imgui"), imgui.module("imgui")) catch @panic("OOM");
    b.modules.put(b.dupe("implot"), imgui.module("implot")) catch @panic("OOM");
    b.modules.put(b.dupe("ztracy"), ztracy.module("root")) catch @panic("OOM");

    b.installArtifact(rt.artifact("rt"));

    const wf = b.addNamedWriteFiles("bin_files");
    _ = wf.addCopyDirectory(rt.namedWriteFiles("bin_files").getDirectory(), "", .{});

    try @import("src/build/InstallShadersStep.zig").init(b, wf, .{
        .install_dir = .bin,
        .always_generate = gen_shaders,
        .source_path = b.path("shaders"),
        .dest_path = "shaders",
        .target = "spirv",
        .profile = "spirv_1_3",
    });
    _ = wf.addCopyDirectory(b.path("shaders"), "shaders", .{ .include_extensions = &.{".json"} });

    // Language server

    const check = b.step("check", "check if run compiles");
    check.dependOn(&rt.artifact("rt").step);
}
