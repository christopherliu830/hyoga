const std = @import("std");
const builtin = @import("builtin");

const GenerateBindings = @import("src/build/codegen.zig");

pub const GpuDriver = @import("hyoga_rt").GpuDriver;

pub const InstallShadersStep = @import("src/build/InstallShadersStep.zig");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const dxc = b.option(bool, "dxc", "enable HLSL support") orelse false;
    const options_step = b.addOptions();
    options_step.addOption(?[:0]const u8, "backend", if (dxc) "direct3d12" else null);
    const options_module = options_step.createModule();

    const runner = b.addExecutable(.{
        .name = "runner",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .root_source_file = b.path("src/rt/main.zig"),
        }),
    });

    const box2d = b.dependency("box2d", .{
        .optimize = optimize,
    });

    const stb_image = b.dependency("stb_image", .{
        .target = target,
        // stbi is too slow in debug mode.
    });

    const sdl = b.dependency("sdl", .{
        .target = target,
        .optimize = optimize,
        .dxc = dxc,
    });

    const sdl_mixer = b.dependency("sdl_mixer", .{
        .target = target,
        .optimize = optimize,
        .dxc = dxc,
    });

    const sdl_ttf = b.dependency("sdl_ttf", .{
        .target = target,
        .optimize = optimize,
        .dxc = dxc,
    });

    const assimp = b.dependency("assimp", .{
        .target = target,
        .optimize = optimize,
    });

    const tracy = b.dependency("tracy", .{
        .target = target,
        .optimize = optimize,
    });

    const zclay = b.dependency("zclay", .{
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addModule("lib", .{
        .root_source_file = b.path("src/lib/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    runner.root_module.addImport("box2d", box2d.artifact("box2d").root_module);
    runner.root_module.addImport("assimp", assimp.module("root"));
    runner.root_module.addImport("hyoga", lib);
    runner.root_module.addImport("sdl", sdl.module("sdl"));
    runner.root_module.addImport("sdl_shadercross", sdl.module("sdl_shadercross"));
    runner.root_module.addImport("sdl_mixer", sdl_mixer.module("sdl_mixer"));
    runner.root_module.addImport("sdl_ttf", sdl_ttf.module("sdl_ttf"));
    runner.root_module.addImport("stb_image", stb_image.module("stb_image"));
    runner.root_module.addImport("clay", zclay.module("clay"));
    runner.root_module.addImport("build_options", options_module);
    runner.root_module.addImport("tracy", tracy.module("tracy"));

    b.modules.put(b.dupe("clay"), zclay.module("clay")) catch @panic("OOM");

    b.installArtifact(runner);

    const wf = b.addNamedWriteFiles("bin_files");
    _ = wf.addCopyDirectory(assimp.namedWriteFiles("dlls").getDirectory(), ".", .{});
    _ = wf.addCopyDirectory(sdl.namedWriteFiles("dlls").getDirectory(), ".", .{});

    b.modules.put(b.dupe("clay"), zclay.module("clay")) catch @panic("OOM");

    try InstallShadersStep.init(b, wf, .{
        .install_dir = .bin,
        .source_path = b.path("shaders"),
        .dest_path = "shaders",
    });

    _ = wf.addCopyDirectory(b.path("shaders"), "shaders", .{ .include_extensions = &.{".json"} });
    _ = wf.addCopyDirectory(b.path("assets"), "assets", .{});

    const rt_bindings = GenerateBindings.create(b, .{
        .exports_file = b.path("src/rt/root.zig"),
        .mode = .rt,
    });

    const lib_bindings = GenerateBindings.create(b, .{
        .exports_file = b.path("src/rt/root.zig"),
        .mode = .lib,
    });

    const update_source = b.addUpdateSourceFiles();
    update_source.addCopyFileToSource(rt_bindings.getOutput(), "src/rt/generated/proc_table.zig");
    update_source.addCopyFileToSource(lib_bindings.getOutput(), "src/lib/generated/proc_table.zig");

    const codegen = b.step("codegen", "run code generation");
    codegen.dependOn(&update_source.step);

    runner.step.dependOn(&update_source.step);

    // Language server

    const check = b.step("check", "check if run compiles");
    check.dependOn(&runner.step);
}
