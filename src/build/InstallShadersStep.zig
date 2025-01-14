const std = @import("std");
const InstallShadersStep = @This();
const Build = std.Build;
const Step = std.Build.Step;

const ext_from_target = std.StaticStringMap([]const u8).initComptime(.{
    .{ "spirv", ".spv" },
    .{ "metal", ".metal" },
});

const Options = struct {
    source_path: Build.LazyPath,
    install_dir: Build.InstallDir = .bin,
    dest_path: []const u8 = &.{},
    target: []const u8,
    profile: []const u8,
    always_generate: bool = false,
};

const ShaderArgs = struct {
    stage: []const u8,
    ext: []const u8,
    entry: []const u8,
};

pub fn init(b: *Build, step: *Step, options: Options) !void {
    const path = options.source_path.getPath3(b, step);
    var src_dir = try std.fs.cwd().openDir(try path.toString(b.allocator), .{ .iterate = true });
    defer src_dir.close();

    var it = try src_dir.walk(b.allocator);
    while (try it.next()) |entry| {
        switch (entry.kind) {
            .directory => {
                // Skip any directories beginning with "_"
                if (std.mem.startsWith(u8, entry.basename, "_")) {
                    var item = it.stack.pop();
                    if (it.stack.items.len != 0) {
                        item.iter.dir.close();
                    }
                    continue;
                }
            },
            .file => if (std.mem.endsWith(u8, entry.path, ".slang")) {
                const src_name = entry.path;
                const shader_args: []const ShaderArgs = blk: {
                    if (std.mem.endsWith(u8, src_name, ".vert.slang")) {
                        break :blk &.{
                            .{ .stage = "", .ext = ext_from_target.get(options.target).?, .entry = "vertexMain" },
                        };
                    } else if (std.mem.endsWith(u8, src_name, ".frag.slang")) {
                        break :blk &.{.{
                            .stage = "",
                            .ext = ext_from_target.get(options.target).?,
                            .entry = "fragmentMain",
                        }};
                    } else {
                        break :blk &.{ .{ .stage = ".vert", .ext = ext_from_target.get(options.target).?, .entry = "vertexMain" }, .{ .stage = ".frag", .ext = ext_from_target.get(options.target).?, .entry = "fragmentMain" } };
                    }
                };

                for (shader_args) |args| {
                    // eg. standard.vert.spv, standard.frag.spv
                    const out_basename = try std.mem.concat(b.allocator, u8, &.{ std.fs.path.stem(entry.path), args.stage, args.ext });
                    const name = try std.mem.concat(b.allocator, u8, &.{ "compile ", entry.path });
                    const run = Step.Run.create(b, name);
                    const input = try options.source_path.join(b.allocator, entry.path);
                    // ;b.pathJoin(&.{options.source_path, entry.path});
                    run.addArg("slangc");
                    run.addFileArg(input);
                    run.addArgs(&.{
                        "-matrix-layout-row-major",
                        "-entry",
                        args.entry,
                        "-fvk-use-entrypoint-name",
                        "-target",
                        options.target,
                    });
                    const out = run.captureStdOut();
                    const install_file_name = b.pathJoin(&.{ options.dest_path, out_basename });
                    const install = Step.InstallFile.create(b, out, .bin, install_file_name);
                    install.step.dependOn(&run.step);
                    step.dependOn(&install.step);
                }
            },
            else => {},
        }
    }
}
