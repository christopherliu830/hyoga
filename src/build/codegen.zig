const std = @import("std");
const Step = std.Build.Step;

const GenerateBindings = @This();

owner: *std.Build,
step: Step,
generated_file: std.Build.GeneratedFile,
exports_file: std.Build.LazyPath,
mode: Mode,

pub const Options = struct {
    exports_file: std.Build.LazyPath,
    mode: Mode,
};

pub const Mode = enum {
    rt,
    lib,
};

pub fn create(owner: *std.Build, options: Options) *GenerateBindings {
    const generate_bindings = owner.allocator.create(GenerateBindings) catch @panic("OOM");
    const exports_file = options.exports_file.dupe(owner);

    generate_bindings.* = .{
        .owner = owner,
        .step = Step.init(.{
            .id = .custom,
            .name = "generate_bindings",
            .owner = owner,
            .makeFn = make,
        }),
        .generated_file = .{ .step = &generate_bindings.step },
        .exports_file = exports_file,
        .mode = options.mode,
    };

    exports_file.addStepDependencies(&generate_bindings.step);
    return generate_bindings;
}

pub fn createModule(generate_bindings: *GenerateBindings) *std.Build.Module {
    return generate_bindings.owner.createModule(.{
        .root_source_file = generate_bindings.getOutput(),
    });
}

pub fn getOutput(generate_bindings: *GenerateBindings) std.Build.LazyPath {
    return .{ .generated = .{ .file = &generate_bindings.generated_file } };
}

fn make(step: *Step, options: Step.MakeOptions) !void {
    _ = options;

    const b = step.owner;
    const generate_bindings: *GenerateBindings = @fieldParentPtr("step", step);

    const src_path = generate_bindings.exports_file.getPath3(b, step);
    const fd = try src_path.root_dir.handle.openFile(src_path.subPathOrDot(), .{});
    defer fd.close();
    var reader_buffer: [48 * 1024]u8 = @splat(0);
    var reader = fd.reader(&reader_buffer);
    const size = try reader.getSize();
    const source = try b.allocator.allocSentinel(u8, size + 1, 0);
    try reader.interface.readSliceAll(source[0..size]);

    var ast = try std.zig.Ast.parse(b.allocator, source, .zig);
    defer ast.deinit(b.allocator);

    const out_source = try printFile(b.allocator, ast, generate_bindings.mode);

    // Create a generated file.
    // refer to std.Build.Step.Options for the implementation of this part.
    var out_ast = try std.zig.Ast.parse(b.allocator, out_source, .zig);
    const bytes = try out_ast.renderAlloc(b.allocator);

    // Hash contents to file name.
    var hash = b.graph.cache.hash;
    // Random bytes to make unique. Refresh this with new random bytes when
    // implementation is modified in a non-backwards-compatible way.
    hash.add(@as(u32, 0xadda3083));
    hash.addBytes(bytes);

    const basename = "proc_table.zig";

    const sub_path = "c" ++ std.fs.path.sep_str ++ hash.final() ++ std.fs.path.sep_str ++ basename;
    generate_bindings.generated_file.path = try b.cache_root.join(b.allocator, &.{sub_path});

    if (b.cache_root.handle.access(sub_path, .{})) |_| {
        step.result_cached = true;
        return;
    } else |outer_err| switch (outer_err) {
        error.FileNotFound => {
            const sub_dirname = std.fs.path.dirname(sub_path).?;
            b.cache_root.handle.makePath(sub_dirname) catch |e| {
                return step.fail("unable to make path '{f}{s}': {s}", .{
                    b.cache_root, sub_dirname, @errorName(e),
                });
            };

            const rand_int = std.crypto.random.int(u64);
            const tmp_sub_path = "tmp" ++ std.fs.path.sep_str ++
                std.fmt.hex(rand_int) ++ std.fs.path.sep_str ++
                basename;
            const tmp_sub_path_dirname = std.fs.path.dirname(tmp_sub_path).?;

            b.cache_root.handle.makePath(tmp_sub_path_dirname) catch |err| {
                return step.fail("unable to make temporary directory '{f}{s}': {s}", .{
                    b.cache_root, tmp_sub_path_dirname, @errorName(err),
                });
            };

            b.cache_root.handle.writeFile(.{ .sub_path = tmp_sub_path, .data = bytes }) catch |err| {
                return step.fail("unable to write proc_table to '{f}{s}': {s}", .{
                    b.cache_root, tmp_sub_path, @errorName(err),
                });
            };

            b.cache_root.handle.rename(tmp_sub_path, sub_path) catch |err| switch (err) {
                error.PathAlreadyExists => {
                    // Other process beat us to it. Clean up the temp file.
                    b.cache_root.handle.deleteFile(tmp_sub_path) catch |e| {
                        try step.addError("warning: unable to delete temp file '{f}{s}': {s}", .{
                            b.cache_root, tmp_sub_path, @errorName(e),
                        });
                    };
                    step.result_cached = true;
                    return;
                },
                else => {
                    return step.fail("unable to rename proc_table from '{f}{s}' to '{f}{s}': {s}", .{
                        b.cache_root,    tmp_sub_path,
                        b.cache_root,    sub_path,
                        @errorName(err),
                    });
                },
            };
        },
        else => |e| return step.fail("unable to access proc_table file '{f}{s}': {s}", .{
            b.cache_root, sub_path, @errorName(e),
        }),
    }
}

fn printFile(alloc: std.mem.Allocator, ast: std.zig.Ast, mode: Mode) ![:0]u8 {
    var aw: std.Io.Writer.Allocating = .init(alloc);
    const w = &aw.writer;

    try w.print("/// Hyoga generated file.\n", .{});
    try w.print("const std = @import(\"std\");\n", .{});

    switch (mode) {
        .rt => try w.print("const hy = @import(\"hyoga\");", .{}),
        .lib => try w.print("const hy = @import(\"../root.zig\");", .{}),
    }

    try w.print("const hym = hy.math;", .{});
    try w.print("pub const ProcTable = extern struct {{", .{});

    for (ast.rootDecls()) |node_idx| {
        switch (ast.nodeTag(node_idx)) {
            .fn_decl => {
                var buffer: [1]std.zig.Ast.Node.Index = .{.root};
                const fn_proto = ast.fullFnProto(&buffer, node_idx).?;

                const name = ast.tokenSlice(fn_proto.name_token.?);
                const last_token = ast.lastToken(fn_proto.ast.return_type.unwrap().?);
                const start = ast.tokenStart(fn_proto.lparen);
                const end = ast.tokenStart(last_token) + ast.tokenSlice(last_token).len;

                if (std.mem.startsWith(u8, name, "hy")) {
                    try w.print("{s}: *const fn {s},", .{ name, ast.source[start..end] });
                }
            },
            else => {},
        }
    }

    try w.print("}};\n\n", .{});

    if (mode == .rt) {
        try w.print("const root = @import(\"../root.zig\");", .{});
        try w.print("pub const table: ProcTable = .{{", .{});

        for (ast.rootDecls()) |node_idx| {
            switch (ast.nodeTag(node_idx)) {
                .fn_decl => {
                    var buffer: [1]std.zig.Ast.Node.Index = .{.root};
                    const fn_proto = ast.fullFnProto(&buffer, node_idx).?;

                    const name = ast.tokenSlice(fn_proto.name_token.?);
                    if (std.mem.startsWith(u8, name, "hy")) {
                        try w.print(".{s} = root.{s},", .{ name, name });
                    }
                },
                else => {},
            }
        }
        try w.print("}};", .{});
    } else {
        try w.print("pub var table: ProcTable = undefined;", .{});
    }

    return try aw.toOwnedSliceSentinel(0);
}
