const std = @import("std");
const Sdl = @import("sdl");
const sdl_shadercross = @import("sdl_shadercross");
const Assimp = @import("assimp");

const os = @import("builtin").target.os.tag;

pub const GpuDriver = enum {
    none,
    vulkan,
    direct3d12,
    metal,
}; 

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const dxc = b.option(bool, "dxc", "enable HLSL support") orelse false;
    const backend = b.option(GpuDriver, "gpu_driver", "force backend graphics driver") orelse .none;
    const enable_tracy= b.option(bool, "enable_tracy", "enable profiling with tracy") orelse false;

    if (backend == .direct3d12 and !dxc) {
        std.log.err("{} requires -Ddxc", .{backend});
        return error.InvalidConfiguration;
    }

    const options_step = b.addOptions();
    options_step.addOption(?[:0]const u8, "backend", if (backend == .none) null else @tagName(backend));
    const options_module = options_step.createModule();

    const hyoga = b.addModule("hyoga", .{
        .root_source_file = b.path("src/hyoga/root.zig"),
        .target = target,
        .optimize = optimize
    });

    const hyoga_lib = b.addSharedLibrary(.{
        .name = "hyoga_lib",
        .root_source_file = b.path("src/hyogac/export.zig"),
        .target = target,
        .optimize = optimize
    });

    const hyoga_lib_import = b.addModule("hyoga_lib_import", .{
        .root_source_file = b.path("src/hyogac/include.zig"),
        .target = target,
        .optimize = optimize,
    });

    const game_lib = b.addSharedLibrary(.{
        .name = "game",
        .root_source_file = b.path("src/game/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const runner = b.addExecutable(.{
        .name = "run",
        .root_source_file = b.path("src/runner/runner.zig"),
        .target = target,
        .optimize = optimize,
    });

    const hym = b.dependency("hyoga_math", .{
        .target = target,
        .optimize = optimize,
    });

    const hya = b.dependency("hyoga_arena", .{
        .target = target,
        .optimize = optimize,
    });

    const imgui = b.dependency("imgui", .{
        .target = target,
        .optimize = optimize,
    });

    const stb_image = b.dependency("stb_image", .{ 
        .target = target
    });

    const sdl = b.dependency("sdl", .{
        .target = target,
        .optimize = optimize,
        .dxc = dxc,
    });

    const assimp = b.dependency("assimp", .{
        .target = target,
        .optimize = optimize
    });

    const ztracy = b.dependency("ztracy", .{
        .target = target,
        .optimize = optimize,
        .enable_ztracy = enable_tracy,
        .enable_fibers = true,
    });

    // Modules

    hyoga.addImport("assimp", assimp.module("root"));
    hyoga.addImport("hyoga-math", hym.module("hyoga-math"));
    hyoga.addImport("hyoga-arena", hya.module("hyoga-arena"));
    hyoga.addImport("sdl", sdl.module("sdl"));
    hyoga.addImport("sdl_shadercross", sdl.module("sdl_shadercross"));
    hyoga.addImport("imgui", imgui.module("imgui"));
    hyoga.addImport("implot", imgui.module("implot"));
    hyoga.addImport("stb_image", stb_image.module("stb_image"));
    hyoga.addImport("ztracy", ztracy.module("root"));
    hyoga.addImport("build_options", options_module);

    if (enable_tracy) { hyoga.linkLibrary(ztracy.artifact("tracy")); }

    hyoga_lib.root_module.addImport("hyoga", hyoga);

    hyoga_lib_import.addImport("hyoga-math", hym.module("hyoga-math"));
    hyoga_lib_import.addImport("hyoga-arena", hya.module("hyoga-arena"));
    hyoga_lib_import.linkLibrary(hyoga_lib);

    game_lib.root_module.addImport("hyoga", hyoga);
    game_lib.root_module.addImport("ztracy", ztracy.module("root"));

    runner.root_module.addImport("hyoga_lib", hyoga_lib_import);


    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/game/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const game_dll = b.addInstallArtifact(game_lib, .{});
    b.getInstallStep().dependOn(&game_dll.step);

    b.installArtifact(hyoga_lib);
    b.installArtifact(runner);

    b.installDirectory(.{
        .install_dir = .bin,
        .source_dir = b.path("assets"),
        .install_subdir = "assets",
    });

    b.installDirectory(.{
        .install_dir = .bin,
        .source_dir = assimp.namedWriteFiles("dlls").getDirectory(),
        .install_subdir = "",
    });

    b.installDirectory(.{
        .install_dir = .bin,
        .source_dir = sdl.namedWriteFiles("dlls").getDirectory(),
        .install_subdir = "",
    });

    const install_shaders = try @import("src/build/InstallShadersStep.zig").init(b, .{ 
        .install_dir = .bin,
        .source_path = b.path("shaders"),
        .dest_path = "shaders",
        .target = "spirv",
        .profile = "",
    });

    b.getInstallStep().dependOn(&install_shaders.step);

    b.installDirectory(.{
        .source_dir = b.path("shaders"),
        .install_dir = .bin,
        .include_extensions = &.{ ".rsl.json" },
        .install_subdir = "shaders"
    });

    const run_cmd = b.addRunArtifact(runner);
    run_cmd.setCwd(b.path("zig-out/bin/"));

    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_cmd.addArgs(args);

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);

    const hot_reload_step = b.step("reload", "build game.dll only");
    hot_reload_step.dependOn(&game_dll.step);
}

fn copyDlls(b: *std.Build, dlls: *std.Build.Step.WriteFile) !void {
    for (dlls.files.items) |dll| {
        const src = try dlls.getDirectory().join(b.allocator, dll.sub_path);
        const install_file = b.addInstallFileWithDir(src, .bin, dll.sub_path);
        b.getInstallStep().dependOn(&install_file.step);
    }
}