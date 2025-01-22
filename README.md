# Hyoga

A work-in-progress game engine in Zig. Uses SDL3 for rendering. Check my twitter at @christopherliu_ for updates.

# Adding to your project

Add as a dependency through your `build.zig.zon`. Example:

```zig
pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const dxc = b.option(bool, "dxc", "enable HLSL support") orelse false;
    const enable_tracy = b.option(bool, "enable_tracy", "enable profiling with tracy") orelse false;
    const backend = b.option(GpuDriver, "gpu_driver", "force backend graphics driver") orelse .none;
    const gen_shaders = b.option(bool, "compile_shaders", "force shader compile") orelse false;

    const exe = b.addExecutable(.{
        .name = "run",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const hy = b.dependency("hyoga", .{
        .target = target,
        .optimize = optimize,
        .dxc = dxc,
        .enable_tracy = enable_tracy,
        .gpu_driver = backend,
        .compile_shaders = gen_shaders,
    });

    const rt = hy.artifact("rt");

    exe.root_module.addImport("hyoga-lib", hy.module("lib"));
    exe.root_module.addImport("imgui", hy.module("imgui"));
    exe.root_module.addImport("implot", hy.module("implot"));
    exe.root_module.addImport("ztracy", hy.module("ztracy"));
    exe.linkLibrary(hy.artifact("rt"));

    b.installArtifact(exe);

    b.installDirectory(.{
        .install_dir = .bin,
        .source_dir = hy.namedWriteFiles("bin_files").getDirectory(),
        .install_subdir = "",
    });

    b.installDirectory(.{
        .install_dir = .bin,
        .source_dir = b.path("assets"),
        .install_subdir = "assets",
    });
}
```

# Usage

```zig
const hy = @import("hyoga-lib");
const game = @import("my-game.zig");

pub fn main() void {
    // ... setup

    const engine = hy.runtime.init();
    defer engine.shutdown();

    var gi = game.interface; // see modules/lib/runtime.zig
    var world = gi.init(engine);

    while (!world.quit) {
        world = engine.update(world, gi);
        gi.reload(engine, world);
    }
}
```