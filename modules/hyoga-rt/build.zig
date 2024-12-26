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
    const enable_tracy = b.option(bool, "enable_tracy", "enable profiling with tracy") orelse false;

    if (backend == .direct3d12 and !dxc) {
        std.log.err("{} requires -Ddxc", .{backend});
        return error.InvalidConfiguration;
    }

    const options_step = b.addOptions();
    options_step.addOption(?[:0]const u8, "backend", if (backend == .none) null else @tagName(backend));
    const options_module = options_step.createModule();

    const rt = b.addSharedLibrary(.{
        .name = "hyrt",
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/root.zig"),
    });

    const hylib = b.dependency("hyoga_lib", .{
        .target = target,
        .optimize = optimize
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

    if (enable_tracy) { rt.linkLibrary(ztracy.artifact("tracy")); }

    rt.root_module.addImport("assimp", assimp.module("root"));
    rt.root_module.addImport("hyoga-lib", hylib.module("hyoga-lib"));
    rt.root_module.addImport("sdl", sdl.module("sdl"));
    rt.root_module.addImport("sdl_shadercross", sdl.module("sdl_shadercross"));
    rt.root_module.addImport("imgui", imgui.module("imgui"));
    rt.root_module.addImport("implot", imgui.module("implot"));
    rt.root_module.addImport("stb_image", stb_image.module("stb_image"));
    rt.root_module.addImport("ztracy", ztracy.module("root"));
    rt.root_module.addImport("build_options", options_module);

    b.installArtifact(rt);

    const wf = b.addNamedWriteFiles("bin_files");
    _ = wf.addCopyDirectory(assimp.namedWriteFiles("dlls").getDirectory(), ".", .{});
    _ = wf.addCopyDirectory(sdl.namedWriteFiles("dlls").getDirectory(), ".", .{});
}

