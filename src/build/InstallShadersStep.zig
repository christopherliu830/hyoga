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

    try gatherDependencies(b, self, self.source_path, options.dest_path);

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

const InstallShaderStep = struct {
    src: Build.LazyPath,
    target: []const u8,
    dest_prefix: []const u8,
    step: Step,

    fn make(step: *Step, _: Step.MakeOptions) !void {
        const b = step.owner;
        const self: *InstallShaderStep = @fieldParentPtr("step", step);
        const src_path = self.src.getPath3(b, step);
        const sub = src_path.sub_path;
        const cwd = std.fs.cwd(); // default zig-out
        const dest_dir = b.getInstallPath(.bin, self.dest_prefix);


        var man = b.graph.cache.obtain();
        defer man.deinit();
        try step.addWatchInput(self.src);
        _ = try man.addFilePath(src_path, null);

        if (try step.cacheHit(&man)) {
            step.result_cached = true;
            return;
        }

        try cwd.makePath(dest_dir);

        const shader_args: []const ShaderArgs = blk: {
            if (std.mem.endsWith(u8, sub, ".vert.slang")) {
                break :blk &.{
                    .{
                        .stage = "",
                        .ext = ext_from_target.get(self.target).?,
                        .entry = "vertexMain"
                    },
                };
            } else if (std.mem.endsWith(u8, sub, ".frag.slang")) {
                break :blk &.{
                    .{
                        .stage = "",
                        .ext = ext_from_target.get(self.target).?,
                        .entry = "fragmentMain",
                    }
                };
            } else {
                break :blk &.{
                    .{
                        .stage = ".vert",
                        .ext = ext_from_target.get(self.target).?,
                        .entry = "vertexMain"
                    },
                    .{
                        .stage = ".frag",
                        .ext = ext_from_target.get(self.target).?,
                        .entry = "fragmentMain"
                    }
                };
            }
        };
                    
        for (shader_args) |opts| {
            // eg. standard.vert.spv, standard.frag.spv
            const out_basename = try std.mem.concat(b.allocator, u8, &.{std.fs.path.stem(src_path.sub_path), opts.stage, opts.ext});
            // eg. shaders/standard.vert.spv
            const out_path = b.pathJoin(&.{dest_dir, out_basename});
            var argv_list = std.ArrayList([]const u8).init(b.allocator);
            try argv_list.appendSlice(&.{
                "slangc",
                try src_path.toString(b.allocator),
                "-matrix-layout-row-major",
                "-entry", opts.entry,
                "-fvk-use-entrypoint-name",
                "-target", self.target,
                "-o", out_path,
            });

            _ = try step.evalChildProcess(argv_list.items);
        }

        try step.writeManifest(&man);
    }
};

fn make(_: *Build.Step, _: Step.MakeOptions) !void {

}

fn gatherDependencies(b: *Build, config: *InstallShadersStep, src: Build.LazyPath, dest_prefix: []const u8) !void {
    const step = &config.step;
    const src_dir_path = src.getPath3(b, step);

    var src_dir = src_dir_path.root_dir.handle.openDir(src_dir_path.subPathOrDot(), .{ .iterate = true }) catch |err| {
        return step.fail("unable to open source directory '{}': {s}", .{
            src_dir_path, @errorName(err),
        });
    };

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
                const install = try b.allocator.create(InstallShaderStep);
                install.* = .{
                    .src = try src.join(b.allocator, entry.path),
                    .dest_prefix = dest_prefix,
                    .target = config.target,
                    .step = Step.init(.{
                        .id = .custom,
                        .owner = b,
                        .name = try std.mem.concat(b.allocator, u8, &.{"compile ", entry.path}),
                        .makeFn = InstallShaderStep.make,
                    })
                };
                step.dependOn(&install.step);
            },
            else => {},
        }
    }
}