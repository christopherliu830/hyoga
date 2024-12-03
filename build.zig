const std = @import("std");

const os = @import("builtin").target.os.tag;

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{ });

    const hym = b.dependency("hyoga_math", .{
        .target = target,
        .optimize = optimize,
    });

    const hya = b.dependency("hyoga_arena", .{
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addStaticLibrary(.{
        .name = "hyoga",
        .root_source_file = b.path("src/hyoga/root.zig"),
        .target = target,
        .optimize = optimize
    });

    lib.root_module.addImport("hyoga-math", hym.module("hyoga-math"));
    lib.root_module.addImport("hyoga-arena", hya.module("hyoga-arena"));

    // ---------- SDL -----------

    const sdl = b.addModule("sdl", .{
        .root_source_file = b.path("src/sdl/sdl.zig"),
        .target = target,
    });

    if (os == .windows) {
        sdl.addIncludePath(b.path("thirdparty/sdl3/include/"));
        sdl.addLibraryPath(b.path("thirdparty/sdl3/"));
        b.installBinFile("thirdparty/sdl3/SDL3.dll", "SDL3.dll");
    } 
    sdl.linkSystemLibrary("SDL3", .{});
    lib.linkLibC();
    lib.root_module.addImport("sdl", sdl);

    // ---------- stb_image -----------

    lib.addCSourceFile(.{
        .file = b.path("thirdparty/stb_image.c"),
        .flags = &[_][]const u8{"-std=c99"},
    });
    lib.addIncludePath(b.path("thirdparty"));

    // ---------- imgui -----------

    const imgui = b.createModule(.{
        .target = target,
        .optimize = optimize,
    });

    imgui.addIncludePath(b.path("thirdparty/cimgui/imgui"));

    imgui.addCSourceFiles(.{
        .root = b.path("thirdparty/cimgui"),
        .files = &.{
            "cimgui.cpp",
            "imgui/imgui_demo.cpp",
            "imgui/imgui_draw.cpp",
            "imgui/imgui_tables.cpp",
            "imgui/imgui_widgets.cpp",
            "imgui/imgui.cpp",
            "implot/implot_demo.cpp",
            "implot/implot_items.cpp",
            "implot/implot.cpp",
        },
    });

    lib.root_module.addImport("imgui", imgui);

    // ---------- assimp -----------
    if (os == .windows) {

        b.installBinFile("thirdparty/assimp/assimp-vc143-mt.dll", "assimp-vc143-mt.dll");
        lib.addLibraryPath(b.path("thirdparty/assimp"));
        lib.linkSystemLibrary("assimp-vc143-mt");
    } else {
        b.installLibFile("thirdparty/assimp/libassimp.a", "libassimp.a");
        lib.addLibraryPath(b.path("thirdparty/assimp"));
        lib.linkSystemLibrary("assimp");
    }

    lib.linkLibCpp();

    b.installArtifact(lib);

    const zbench = b.dependency("zbench", .{
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "game",
        .root_source_file = b.path("src/game/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.root_module.addImport("hyoga", &lib.root_module);
    b.installArtifact(exe);
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/game/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);

    const benchmark = b.addExecutable(.{
        .name = "benchmarks",
        .root_source_file = b.path("src/benchmark/benchmark.zig"),
        .target = target,
        .optimize = optimize,
    });

    benchmark.root_module.addImport("hyoga", &lib.root_module);
    benchmark.root_module.addImport("zbench", zbench.module("zbench"));
    b.installArtifact(benchmark);

    const run_benchmarks = b.addRunArtifact(benchmark);
    const benchmark_step = b.step("benchmark", "Run benchmarks");
    benchmark_step.dependOn(&run_benchmarks.step);
}
