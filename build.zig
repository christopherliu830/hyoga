const std = @import("std");
const builtin = @import("builtin");

const GenerateBindings = @import("src/build/codegen.zig");

pub const GpuDriver = @import("hyoga_rt").GpuDriver;

pub const InstallShadersStep = @import("src/build/InstallShadersStep.zig");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const dxc = b.option(bool, "dxc", "enable HLSL support") orelse false;

    const rt = b.dependency("hyoga_rt", .{
        .target = target,
        .optimize = optimize,
        .dxc = dxc,
    });

    const lib = b.dependency("lib", .{
        .target = target,
        .optimize = optimize,
    });

    b.modules.put(b.dupe("lib"), lib.module("hyoga-lib")) catch @panic("OOM");
    b.modules.put(b.dupe("clay"), rt.module("clay")) catch @panic("OOM");

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

    const rt_bindings = GenerateBindings.create(b, .{
        .exports_file = rt.path("src/root.zig"),
        .mode = .rt,
    });

    const lib_bindings = GenerateBindings.create(b, .{
        .exports_file = rt.path("src/root.zig"),
        .mode = .lib,
    });

    const update_source = b.addUpdateSourceFiles();
    update_source.addCopyFileToSource(rt_bindings.getOutput(), "modules/rt/src/generated/proc_table.zig");
    update_source.addCopyFileToSource(lib_bindings.getOutput(), "modules/lib/src/generated/proc_table.zig");

    rt.artifact("runner").step.dependOn(&update_source.step);

    const codegen = b.step("codegen", "generate code");
    codegen.dependOn(&update_source.step);

    // Language server

    const check = b.step("check", "check if run compiles");
    check.dependOn(&rt.artifact("runner").step);
}
