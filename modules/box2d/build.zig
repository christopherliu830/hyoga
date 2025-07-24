const std = @import("std");
const Build = std.Build;

pub fn build(b: *Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const box2d_dep = b.dependency("box2d", .{});

    const module = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/box2d.zig"),
    });

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "box2d",
        .root_module = module,
    });

    lib.linkLibC();
    lib.addIncludePath(box2d_dep.path("include"));
    lib.installHeadersDirectory(box2d_dep.path("include"), "", .{});

    lib.addCSourceFiles(.{
        .root = box2d_dep.path("src"),
        .flags = &.{
            "-std=c17",
        },
        .files = &.{
            "aabb.c",
            "arena_allocator.c",
            "array.c",
            "bitset.c",
            "body.c",
            "broad_phase.c",
            "constraint_graph.c",
            "contact.c",
            "contact_solver.c",
            "core.c",
            "distance.c",
            "distance_joint.c",
            "dynamic_tree.c",
            "geometry.c",
            "hull.c",
            "id_pool.c",
            "island.c",
            "joint.c",
            "manifold.c",
            "math_functions.c",
            "motor_joint.c",
            "mouse_joint.c",
            "prismatic_joint.c",
            "revolute_joint.c",
            "sensor.c",
            "shape.c",
            "solver.c",
            "solver_set.c",
            "table.c",
            "timer.c",
            "types.c",
            "weld_joint.c",
            "wheel_joint.c",
            "world.c",
        },
    });
    b.installArtifact(lib);
}
