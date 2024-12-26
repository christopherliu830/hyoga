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

const ShaderArgs = struct {
    stage: []const u8,
    ext: []const u8,
    entry: []const u8,
};

const ShaderInvocation = struct {
    process: std.process.Child,
    stderr: std.ArrayList(u8),
    stdout: std.ArrayList(u8),
    args: []const []const u8,
};

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

    var children = std.ArrayList(ShaderInvocation).init(b.allocator);
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

                const shader_args: []const ShaderArgs = blk: {
                    if (std.mem.endsWith(u8, entry.path, ".vert.slang")) {
                        break :blk &.{
                            .{ .stage = "", .ext = ext_from_target.get(self.target).?, .entry = "vertexMain", },
                        };
                    } else if (std.mem.endsWith(u8, entry.path, ".frag.slang")) {
                        break :blk &.{
                            .{ .stage = "", .ext = ext_from_target.get(self.target).?, .entry = "fragmentMain", }
                        };
                    } else {
                        break :blk &.{
                            .{ .stage = ".vert", .ext = ext_from_target.get(self.target).?, .entry = "vertexMain", },
                            .{ .stage = ".frag", .ext = ext_from_target.get(self.target).?, .entry = "fragmentMain", }
                        };
                    }
                };
                   
                for (shader_args) |opts| {
                    // eg. standard.vert.spv, standard.frag.spv
                    const out_basename = try std.mem.concat(b.allocator, u8, &.{std.fs.path.stem(entry.basename), opts.stage, opts.ext});
                    // eg. shaders/standard.vert.spv
                    const out_name = b.pathJoin(&.{dest_prefix, out_basename});

                    const src_stat = try src_dir.statFile(entry.path);
                    const dst_stat = cwd.statFile(out_name) catch null;

                    if (self.always_generate or dst_stat == null or dst_stat.?.mtime < src_stat.mtime) {
                        step_opts.progress_node.increaseEstimatedTotalItems(1);
                        var argv_list = std.ArrayList([]const u8).init(b.allocator);
                        try argv_list.appendSlice(&.{
                            "slangc",
                            "-matrix-layout-row-major",
                            "-entry", opts.entry,
                            "-fvk-use-entrypoint-name",
                            try src_sub_path.toString(b.allocator), // Input file
                            "-target", self.target,
                            "-o", out_name,
                        });

                        if (self.profile.len > 0) {
                            try argv_list.appendSlice(&.{"-profile", self.profile});
                        }

                        try step.handleChildProcUnsupported(null, argv_list.items);
                        try Step.handleVerbose(step.owner, null, argv_list.items);

                        const prog_node = step_opts.progress_node.start(out_basename, 1);
                        var child = std.process.Child.init(argv_list.items, b.allocator);
                        child.env_map = &b.graph.env_map;
                        child.stdin_behavior = .Ignore;
                        child.stdout_behavior = .Pipe;
                        child.stderr_behavior = .Pipe;
                        child.request_resource_usage_statistics = true;
                        child.progress_node = prog_node;

                        child.spawn() catch |err| return step.fail("failed to spawn slangc: {s}", .{ @errorName(err), });
                        const invoc = try children.addOne();
                        invoc.* = .{ 
                            .process = child,
                            .args = argv_list.items,
                            .stderr = std.ArrayList(u8).init(b.allocator),
                            .stdout = std.ArrayList(u8).init(b.allocator),
                        };
                    }
                }
            },
            else => {},
        }
    }

    for (children.items) |*child| {
        try child.process.collectOutput(&child.stdout, &child.stderr, 50 * 1024);
        const term = child.process.wait() catch |err| return step.fail("failed to wait process: {s}", .{ @errorName(err), });
        if (child.stderr.items.len > 0) {
            try step.result_error_msgs.append(b.allocator, child.stderr.items);
        }

        try step.handleChildProcessTerm(term, null, child.args);
    }
}

