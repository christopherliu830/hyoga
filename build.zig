const std = @import("std");
const builtin = @import("builtin");

const GpuDriver = @import("hyoga_rt").GpuDriver;

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const dxc = b.option(bool, "dxc", "enable HLSL support") orelse false;
    const enable_tracy = b.option(bool, "enable_tracy", "enable profiling with tracy") orelse false;
    const backend = b.option(GpuDriver, "gpu_driver", "force backend graphics driver") orelse .none;
    const gen_shaders = b.option(bool, "compile_shaders", "force shader compile") orelse false;

    const game_lib = b.addSharedLibrary(.{
        .name = "game",
        .root_source_file = b.path("src/game/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "run",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

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

    // Modules
    game_lib.root_module.addImport("hyoga-lib", lib.module("hyoga-lib"));
    game_lib.root_module.addImport("imgui", imgui.module("imgui"));
    game_lib.root_module.addImport("implot", imgui.module("implot"));
    game_lib.root_module.addImport("ztracy", ztracy.module("root"));
    game_lib.linkLibrary(rt.artifact("hyrt"));

    exe.root_module.addImport("hyoga-lib", lib.module("hyoga-lib"));
    exe.linkLibrary(rt.artifact("hyrt"));

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/game/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const game_dll = b.addInstallArtifact(game_lib, .{ .dest_dir = .{ .override = .bin } });
    b.getInstallStep().dependOn(&game_dll.step);

    b.installArtifact(exe);

    b.installArtifact(rt.artifact("hyrt")); // Needed for ZLS to work

    b.installDirectory(.{
        .install_dir = .bin,
        .source_dir = rt.namedWriteFiles("bin_files").getDirectory(),
        .install_subdir = "",
    });

    b.installDirectory(.{
        .install_dir = .bin,
        .source_dir = b.path("assets"),
        .install_subdir = "assets",
    });

    try @import("src/build/InstallShadersStep.zig").init(b, b.getInstallStep(), .{
        .install_dir = .bin,
        .always_generate = gen_shaders,
        .source_path = b.path("shaders"),
        .dest_path = "shaders",
        .target = "spirv",
        .profile = "spirv_1_3",
    });

    b.installDirectory(.{ .source_dir = b.path("shaders"), .install_dir = .bin, .include_extensions = &.{".rsl.json"}, .install_subdir = "shaders" });

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.setCwd(std.Build.LazyPath{ .cwd_relative = b.getInstallPath(.bin, ".") });

    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_cmd.addArgs(args);

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);

    const hot_reload_step = b.step("reload", "build game.dll only");
    hot_reload_step.dependOn(&game_dll.step);

    // Language server

    const exe_check = b.addExecutable(.{
        .name = "run",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe_check.root_module.addImport("hyoga-lib", lib.module("hyoga-lib"));
    exe_check.linkLibrary(rt.artifact("hyrt"));

    const check = b.step("check", "check if run compiles");
    check.dependOn(&exe_check.step);
}
