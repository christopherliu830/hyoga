const std = @import("std");
const Build = std.Build;

pub const Vorbis = enum {
    none,
    stb,
    tremor,
    vorbisfile,
};

pub fn build(b: *Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // SDL option
    const dxc_enabled = b.option(bool, "dxc", "compile with dxc enabled") orelse false;

    const flac = b.option(bool, "flac", "enable flac") orelse true;
    const libflac = dependOption(b, bool, "libflac", "enable flac with libflac", flac, false) orelse false;
    const drflac = dependOption(b, bool, "drflac", "enable flac with drflac", flac, true) orelse false;

    const vorbis = b.option(Vorbis, "vorbis", "vorbis option") orelse .stb;

    const gme = b.option(bool, "gme", "enable gme") orelse false;

    const mod = b.option(bool, "mod", "enable mod") orelse false;
    const modplug = dependOption(b, bool, "modplug", "enable modplug", mod, false) orelse false;
    const xmp = dependOption(b, bool, "xmp", "enable xmp", mod, true) orelse false;

    const mp3 = b.option(bool, "mp3", "enable mp3") orelse true;
    const minimp3 = dependOption(b, bool, "minimp3", "enable minimp3", mp3, true) orelse false;
    const mpg123 = dependOption(b, bool, "mpg123", "enable mpg123", mp3, false) orelse false;

    // TODO
    // const sndfile = false;
    // const nativemidi = false;
    // const fluidsynth = false;
    // const timidity = false;

    const opus = b.option(bool, "opus", "enable opus") orelse false;
    const ogg = vorbis == .tremor or vorbis == .vorbisfile or libflac or opus;
    _ = ogg;

    const wav = b.option(bool, "wav", "enable wav") orelse true;
    const wavpack = b.option(bool, "wavpack", "enable wavpack") orelse false;

    const sdl_dep = b.dependency("sdl", .{
        .target = target,
        .optimize = optimize,
        .dxc = dxc_enabled,
    });

    const sdl_mixer_dep = b.dependency("sdl_mixer", .{
        .target = target,
        .optimize = optimize,
    });

    const sdl_mixer = b.addModule("sdl_mixer", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/root.zig"),
        .imports = &.{.{
            .name = "sdl",
            .module = sdl_dep.module("sdl"),
        }},
    });

    sdl_mixer.linkLibrary(sdl_dep.artifact("sdl"));
    sdl_mixer.addIncludePath(sdl_mixer_dep.path("src"));
    sdl_mixer.addIncludePath(sdl_mixer_dep.path("src/codecs"));
    sdl_mixer.addIncludePath(sdl_mixer_dep.path("include"));

    // TODO
    if (opus) sdl_mixer.addCMacro("MUSIC_OPUS", "1");
    if (flac) {
        if (libflac) sdl_mixer.addCMacro("MUSIC_FLAC_LIBFLAC", "1");
        if (drflac) sdl_mixer.addCMacro("MUSIC_FLAC_DRFLAC", "1");
    }
    if (gme) {
        sdl_mixer.addCMacro("MUSIC_GME", "1");
    }

    if (mod) {
        if (modplug) sdl_mixer.addCMacro("MUSIC_MOD_MODPLUG", "1");
        if (xmp) {
            sdl_mixer.linkSystemLibrary("xmp", .{});
            sdl_mixer.addCMacro("MUSIC_MOD_XMP", "1");
        }
    }

    if (mp3) {
        if (minimp3) sdl_mixer.addCMacro("MUSIC_MP3_MINIMP3", "1");
        if (mpg123) sdl_mixer.addCMacro("MUSIC_MP3_MPG123", "1");
    }

    if (vorbis == .stb) {
        sdl_mixer.addCMacro("MUSIC_OGG", "1");
        sdl_mixer.addCMacro("OGG_USE_STB", "1");
    }

    if (vorbis == .tremor) {
        sdl_mixer.addCMacro("MUSIC_OGG", "1");
        sdl_mixer.addCMacro("OGG_USE_TREMOR", "1");
    }

    if (vorbis == .tremor) {
        sdl_mixer.addCMacro("MUSIC_OGG", "1");
        sdl_mixer.addCMacro("OGG_USE_VORBISFILE", "1");
    }

    if (wav) {
        sdl_mixer.addCMacro("MUSIC_WAV", "1");
    }

    if (wavpack) {
        sdl_mixer.addCMacro("MUSIC_WAVPACK", "1");
    }

    sdl_mixer.addCSourceFiles(.{
        .root = sdl_mixer_dep.path("."),
        .files = &.{
            "src/codecs/load_aiff.c",
            "src/codecs/load_voc.c",
            "src/codecs/load_sndfile.c",
            "src/codecs/mp3utils.c",
            "src/codecs/music_drflac.c",
            "src/codecs/music_flac.c",
            "src/codecs/music_fluidsynth.c",
            "src/codecs/music_gme.c",
            "src/codecs/music_minimp3.c",
            "src/codecs/music_modplug.c",
            "src/codecs/music_mpg123.c",
            "src/codecs/music_nativemidi.c",
            "src/codecs/music_ogg.c",
            "src/codecs/music_ogg_stb.c",
            "src/codecs/music_opus.c",
            "src/codecs/music_timidity.c",
            "src/codecs/music_wav.c",
            "src/codecs/music_wavpack.c",
            "src/codecs/music_xmp.c",
            "src/effect_position.c",
            "src/effect_stereoreverse.c",
            "src/effects_internal.c",
            "src/mixer.c",
            "src/music.c",
            "src/utils.c",
        },
    });

    const lib_sdl_mixer = b.addLibrary(.{
        .name = "sdl_mixer",
        .root_module = sdl_mixer,
    });

    b.installArtifact(lib_sdl_mixer);
}

fn dependOption(b: *Build, T: type, name: []const u8, desc: []const u8, dep: bool, yes_dep: ?T) ?T {
    if (dep) {
        return b.option(T, name, desc) orelse yes_dep;
    } else {
        return null;
    }
}
