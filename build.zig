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

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const backend = b.option(GpuDriver, "GpuDriver", "force backend graphics driver") orelse .none;
    const options_step = b.addOptions();
    options_step.addOption(?[:0]const u8, "backend", if (backend == .none) null else @tagName(backend));
    const options_module = options_step.createModule();

    // Library
    const hyoga_lib = b.addStaticLibrary(.{
        .name = "hyoga",
        .root_source_file = b.path("src/hyoga/root.zig"),
        .target = target,
        .optimize = optimize
    });

    const exe = b.addExecutable(.{
        .name = "game",
        .root_source_file = b.path("src/game/main.zig"),
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
    // const assimp = b.dependency("assimp", opt);
    const stb_image = b.dependency("stb_image", .{ 
        .target = target
    });

    const ztracy = b.dependency("ztracy", .{
        .target = target,
        .optimize = optimize,
        .enable_ztracy = true,
        .enable_fibers = true,
    });

    const sdl = @import("sdl").dependency(b, "sdl", .{
        .target = target,
        .optimize = optimize,
    });

    const sdlsc = @import("sdl_shadercross").dependency(b, "sdl_shadercross", .{
        .target = target,
        .optimize = optimize,
    });

    const assimp = @import("assimp").dependency(b, "assimp", .{
        .target = target,
        .optimize = optimize,
    });

    // Modules

    hyoga_lib.root_module.addImport("hyoga-math", hym.module("hyoga-math"));
    hyoga_lib.root_module.addImport("hyoga-arena", hya.module("hyoga-arena"));
    hyoga_lib.root_module.addImport("imgui", imgui.module("imgui"));
    hyoga_lib.root_module.addImport("implot", imgui.module("implot"));
    hyoga_lib.root_module.addImport("stb_image", stb_image.module("stb_image"));
    hyoga_lib.root_module.addImport("ztracy", ztracy.module("root"));
    hyoga_lib.root_module.addImport("build_options", options_module);

    sdl.exportModule(&hyoga_lib.root_module);
    sdlsc.exportModule(&hyoga_lib.root_module);
    assimp.exportModule(&hyoga_lib.root_module);

    hyoga_lib.root_module.linkLibrary(ztracy.artifact("tracy"));
    hyoga_lib.linkLibC();
    hyoga_lib.linkLibCpp();
    sdlsc.link(hyoga_lib);

    exe.root_module.addImport("hyoga", &hyoga_lib.root_module);
    exe.root_module.addImport("ztracy", ztracy.module("root"));
    exe.linkLibC();
    exe.linkLibrary(ztracy.artifact("tracy"));
    sdl.install(exe);
    sdlsc.install(exe);
    assimp.install(exe);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/game/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    b.installArtifact(hyoga_lib);
    b.installArtifact(exe);

    b.installDirectory(.{
        .install_dir = .bin,
        .source_dir = b.path("assets"),
        .install_subdir = "assets",
    });

    // RUN

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_cmd.addArgs(args);

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
