const std = @import("std");
const InstallShadersStep = @This();
const Build = std.Build;
const Step = std.Build.Step;

const Options = struct {
    source_path: Build.LazyPath,
    install_dir: Build.InstallDir = .bin,
    dest_path: []const u8 = &.{},
};

const ShaderArgs = struct {
    stage: []const u8,
    ext: []const u8,
};

pub fn init(b: *Build, wf: *Step.WriteFile, options: Options) !void {
    const path = options.source_path.getPath3(b, &wf.step);
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
                        item.?.iter.dir.close();
                    }
                    continue;
                }
            },
            .file => if (std.mem.endsWith(u8, entry.path, ".vert") or
                std.mem.endsWith(u8, entry.path, ".frag"))
            {
                const src_name = entry.path;
                const shader_args: []const ShaderArgs = blk: {
                    if (std.mem.endsWith(u8, src_name, ".vert")) {
                        break :blk &.{
                            .{
                                .stage = "",
                                .ext = ".vert.spv",
                            },
                        };
                    } else if (std.mem.endsWith(u8, src_name, ".frag")) {
                        break :blk &.{.{
                            .stage = "",
                            .ext = ".frag.spv",
                        }};
                    } else {
                        continue;
                    }
                };

                for (shader_args) |args| {
                    // eg. standard.vert.spv, standard.frag.spv
                    const out_basename = try std.mem.concat(b.allocator, u8, &.{ std.fs.path.stem(entry.path), args.stage, args.ext });
                    const name = try std.mem.concat(b.allocator, u8, &.{ "compile ", entry.path });
                    const run = Step.Run.create(b, name);
                    const input = try options.source_path.join(b.allocator, entry.path);
                    run.addArg("glslc");
                    run.addFileArg(input);
                    run.addArgs(&.{ "-o", "-" });
                    const out = run.captureStdOut();
                    const install_file_name = b.pathJoin(&.{ options.dest_path, out_basename });
                    _ = wf.addCopyFile(out, install_file_name);
                }
            },
            else => {},
        }
    }
}
