const std = @import("std");
const InstallShadersStep = @This();
const Build = std.Build;
const Step = std.Build.Step;

const Options = struct {
    source_path: Build.LazyPath,
    install_dir: Build.InstallDir = .bin,
    dest_path: []const u8 = &.{},
    target: []const u8,
    profile: []const u8,
    always_generate: bool = false,
};

builder: *Build,
source_path: Build.LazyPath,
install_dir: Build.InstallDir,
target: []const u8,
profile: []const u8,
dest_path: []const u8,
step: Step,
always_generate: bool,

pub fn init(b: *Build, options: Options) !*InstallShadersStep {
    const self = try b.allocator.create(InstallShadersStep);
    self.* = .{
        .builder = b,
        .source_path = options.source_path,
        .install_dir = options.install_dir,
        .dest_path = options.dest_path,
        .target = options.target,
        .profile = options.profile,
        .always_generate = options.always_generate,
        .step = Step.init(.{
            .id = .custom,
            .name = "compile shaders",
            .owner = b,
            .makeFn = make
        })
    };
    return self;
}

fn make(step: *Step, step_opts: Step.MakeOptions) !void {
    const self: *InstallShadersStep = @fieldParentPtr("step", step);
    const b = self.builder;

    const dest_prefix = b.getInstallPath(self.install_dir, self.dest_path);
    const src_dir_path = self.source_path.getPath3(b, step);

    var src_dir = src_dir_path.root_dir.handle.openDir(src_dir_path.subPathOrDot(), .{ .iterate = true }) catch |err| {
        return step.fail("unable to open source directory '{}': {s}", .{
            src_dir_path, @errorName(err),
        });
    };

    const needs_derived_path = try step.addDirectoryWatchInput(self.source_path);
    if (needs_derived_path) try step.addDirectoryWatchInputFromPath(src_dir_path);

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
                const src_sub_path = try src_dir_path.join(b.allocator, entry.path);
                const cwd = std.fs.cwd(); // default zig-out
                try cwd.makePath(dest_prefix);

                inline for (.{
                    .{ .ext = ".vert.spv", .entry = "vertexMain", .offset = 0},
                    .{ .ext = ".frag.spv", .entry = "fragmentMain", .offset = 1 }
                }) |opts| {

                    const out_basename = try std.mem.concat(b.allocator, u8, &.{std.fs.path.stem(entry.basename), opts.ext});
                    const out_name = b.pathJoin(&.{dest_prefix, out_basename});

                    const src_stat = try src_dir.statFile(entry.path);
                    const dst_stat = cwd.statFile(out_name) catch null;

                    if (self.always_generate or dst_stat == null or dst_stat.?.mtime < src_stat.mtime) {
                        step_opts.progress_node.increaseEstimatedTotalItems(1);
                        const argv_list: []const []const u8 = &.{
                            "slangc",
                            "-matrix-layout-row-major",
                            try src_sub_path.toString(b.allocator), // Input file
                            "-entry", opts.entry,
                            "-target", self.target,
                            "-profile", "spirv_1_3",
                            "-o", out_name,
                        };

                        const child = step_opts.progress_node.start(out_basename, 1);
                        const run_result = try step.captureChildProcess(child, argv_list);
                        try step.handleChildProcessTerm(run_result.term, null, argv_list);
                        child.end();
                    }
                }
            },
            else => {},
        }
    }
}
