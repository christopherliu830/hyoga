const std = @import("std");

const os = @import("builtin").target.os.tag;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{ });

    // Library
    const hyoga_lib = b.addStaticLibrary(.{
        .name = "hyoga",
        .root_source_file = b.path("src/hyoga/root.zig"),
        .target = target,
        .optimize = optimize
    });

    // Dependencies

    const opt = .{
        .target = target,
        .optimize = optimize
    };

    const hym = b.dependency("hyoga_math", opt);
    const hya = b.dependency("hyoga_arena", opt);
    const zbench = b.dependency("zbench", opt);
    const imgui = b.dependency("imgui", opt);
    const sdl = b.dependency("sdl", opt);
    const assimp = b.dependency("assimp", opt);
    const stb_image = b.dependency("stb_image", opt);

    // Modules

    hyoga_lib.root_module.addImport("hyoga-math", hym.module("hyoga-math"));
    hyoga_lib.root_module.addImport("hyoga-arena", hya.module("hyoga-arena"));
    hyoga_lib.root_module.addImport("sdl", sdl.module("sdl"));
    hyoga_lib.root_module.addImport("imgui", imgui.module("imgui"));
    hyoga_lib.root_module.addImport("assimp", assimp.module("assimp"));
    hyoga_lib.root_module.addImport("stb_image", stb_image.module("stb_image"));

    b.installArtifact(hyoga_lib);

    const exe = b.addExecutable(.{
        .name = "game",
        .root_source_file = b.path("src/game/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.root_module.addImport("hyoga", &hyoga_lib.root_module);
    b.installArtifact(exe);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/game/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    // BENCHMARKS ---------------------------

    const benchmark = b.addExecutable(.{
        .name = "benchmarks",
        .root_source_file = b.path("src/benchmark/benchmark.zig"),
        .target = target,
        .optimize = optimize,
    });

    benchmark.root_module.addImport("hyoga", &hyoga_lib.root_module);
    benchmark.root_module.addImport("zbench", zbench.module("zbench"));
    b.installArtifact(benchmark);



    // POST BUILD 
    const shader_compile= b.addSystemCommand(&.{"python"});
    shader_compile.addFileArg(b.path("scripts/build_shaders.py"));
    const shader_out = shader_compile.addOutputDirectoryArg("shaders");

    b.installDirectory(.{
        .source_dir = shader_out,
        .install_dir = .bin,
        .install_subdir = "shaders",
    });

    // RUN

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }


    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const run_benchmarks = b.addRunArtifact(benchmark);

    const benchmark_step = b.step("benchmark", "Run benchmarks");
    benchmark_step.dependOn(&run_benchmarks.step);
    
    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);


}
