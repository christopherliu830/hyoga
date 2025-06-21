const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const freetype_dep = b.dependency("freetype", .{
        .target = target,
        .optimize = optimize,
    });

    const freetype = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const freetype_lib = b.addLibrary(.{
        .name = "freetype",
        .linkage = .static,
        .root_module = freetype,
    });

    freetype.addIncludePath(freetype_dep.path("include"));

    var flags: std.ArrayListUnmanaged([]const u8) = .empty;
    defer flags.deinit(b.allocator);
    try flags.appendSlice(b.allocator, &.{
        "-DFT2_BUILD_LIBRARY",
        "-DHAVE_UNISTD_H",
        "-DHAVE_FCNTL_H",

        "-fno-sanitize=undefined",
    });

    freetype.addCSourceFiles(.{
        .root = freetype_dep.path("src"),
        .files = &.{
            "autofit/autofit.c",
            "base/ftbase.c",
            "base/ftbbox.c",
            "base/ftbdf.c",
            "base/ftbitmap.c",
            "base/ftcid.c",
            "base/ftfstype.c",
            "base/ftgasp.c",
            "base/ftglyph.c",
            "base/ftgxval.c",
            "base/ftinit.c",
            "base/ftmm.c",
            "base/ftotval.c",
            "base/ftpatent.c",
            "base/ftpfr.c",
            "base/ftstroke.c",
            "base/ftsynth.c",
            "base/fttype1.c",
            "base/ftwinfnt.c",
            "bdf/bdf.c",
            "bzip2/ftbzip2.c",
            "cache/ftcache.c",
            "cff/cff.c",
            "cid/type1cid.c",
            "gzip/ftgzip.c",
            "lzw/ftlzw.c",
            "pcf/pcf.c",
            "pfr/pfr.c",
            "psaux/psaux.c",
            "pshinter/pshinter.c",
            "psnames/psnames.c",
            "raster/raster.c",
            "sdf/sdf.c",
            "sfnt/sfnt.c",
            "smooth/smooth.c",
            "svg/svg.c",
            "truetype/truetype.c",
            "type1/type1.c",
            "type42/type42.c",
            "winfonts/winfnt.c",
        },
        .flags = flags.items,
    });

    switch (target.result.os.tag) {
        .linux => {
            freetype.addCSourceFiles(.{
                .root = freetype_dep.path(""),
                .files = &.{
                    "builds/unix/ftsystem.c",
                    "src/base/ftdebug.c",
                },
                .flags = flags.items,
            });
        },
        .windows => {
            freetype.addCSourceFiles(.{
                .root = freetype_dep.path(""),
                .files = &.{
                    "builds/windows/ftsystem.c",
                    "builds/windows/ftdebug.c",
                },
                .flags = flags.items,
            });
            freetype.addWin32ResourceFile(.{
                .file = freetype_dep.path("src/base/ftver.rc"),
            });
        },
        else => {
            freetype.addCSourceFiles(.{
                .root = freetype_dep.path(""),
                .files = &.{
                    "src/base/ftsystem.c",
                    "src/base/ftdebug.c",
                },
                .flags = flags.items,
            });
        }
    }

    b.installArtifact(freetype_lib);
    freetype_lib.installHeadersDirectory(freetype_dep.path("include/freetype"), "freetype", .{});
    freetype_lib.installHeader(freetype_dep.path("include/ft2build.h"), "ft2build.h");
}
