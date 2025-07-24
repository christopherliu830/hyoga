const std = @import("std");

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

    if (backend == .direct3d12 and !dxc) {
        std.log.err("{} requires -Ddxc", .{backend});
        return error.InvalidConfiguration;
    }

    const options_step = b.addOptions();
    options_step.addOption(?[:0]const u8, "backend", if (backend == .none) null else @tagName(backend));
    const options_module = options_step.createModule();

    const rt = b.addLibrary(.{
        .linkage = .dynamic,
        .name = "rt",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .root_source_file = b.path("src/root.zig"),
        }),
    });

    const hylib = b.dependency("hyoga_lib", .{
        .target = target,
        .optimize = optimize,
    });

    const box2d = b.dependency("box2d", .{
        .target = target,
        .optimize = optimize,
    });

    const imgui = b.dependency("imgui", .{
        .target = target,
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
    });

    const sdl_ttf = b.dependency("sdl_ttf", .{
        .target = target,
        .optimize = optimize,
    });

    const assimp = b.dependency("assimp", .{
        .target = target,
        .optimize = optimize,
    });

    const zclay = b.dependency("zclay", .{
        .target = target,
        .optimize = optimize,
    });

    rt.root_module.addImport("box2d", box2d.artifact("box2d").root_module);
    rt.root_module.addImport("assimp", assimp.module("root"));
    rt.root_module.addImport("hyoga-lib", hylib.module("hyoga-lib"));
    rt.root_module.addImport("sdl", sdl.module("sdl"));
    rt.root_module.addImport("sdl_shadercross", sdl.module("sdl_shadercross"));
    rt.root_module.addImport("sdl_mixer", sdl_mixer.module("sdl_mixer"));
    rt.root_module.addImport("sdl_ttf", sdl_ttf.module("sdl_ttf"));
    rt.root_module.addImport("imgui", imgui.module("imgui"));
    rt.root_module.addImport("stb_image", stb_image.module("stb_image"));
    rt.root_module.addImport("clay", zclay.module("clay"));
    rt.root_module.addImport("build_options", options_module);

    b.modules.put(b.dupe("imgui"), imgui.module("imgui")) catch @panic("OOM");
    b.modules.put(b.dupe("clay"), zclay.module("clay")) catch @panic("OOM");

    b.installArtifact(rt);

    const wf = b.addNamedWriteFiles("bin_files");
    _ = wf.addCopyDirectory(assimp.namedWriteFiles("dlls").getDirectory(), ".", .{});
    _ = wf.addCopyDirectory(sdl.namedWriteFiles("dlls").getDirectory(), ".", .{});
}
