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
    const optimize = b.standardOptimizeOption(.{ .preferred_optimize_mode = .Debug });

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

    lib.addCSourceFile(.{ .file = b.path("thirdparty/cimgui/cimgui.cpp") });
    lib.addCSourceFiles(.{
        .root = b.path("thirdparty/cimgui/imgui"),
        .files = &.{
            "imgui_demo.cpp",
            "imgui_draw.cpp",
            "imgui_tables.cpp",
            "imgui_widgets.cpp",
            "imgui.cpp",
        },
    });

    // ---------- assimp -----------
    b.installBinFile("thirdparty/assimp/assimp-vc143-mt.dll", "assimp-vc143-mt.dll");
    lib.addLibraryPath(b.path("thirdparty/assimp"));
    lib.linkSystemLibrary("assimp-vc143-mt");

    lib.linkLibCpp();

    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "hyoga-zig",
        .root_source_file = b.path("src/game/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.root_module.addImport("hyoga", &lib.root_module);

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(exe);

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
