const std = @import("std");
const imgui = @import("imgui");
const implot = @import("implot");
const hy = @import("hyoga-lib");
const rt = hy.runtime;
const hym = hy.math;
const SkipMap = hy.SkipMap;

const ui = @import("ui.zig");
const cam = @import("camera.zig");

const Self = @This();

const Object = struct {
    transform: hym.Mat4,
    bounds: hym.Bounds = .{},
    hdl: rt.gpu.RenderItemHandle = .invalid,
};

gpa: std.heap.GeneralPurposeAllocator(.{}),
callback_arena: std.heap.ArenaAllocator,
backpack_hdl: rt.gpu.ModelHandle = undefined,
objects: SkipMap(Object),
ui_state: ui.State,
camera: cam.Camera,

fn init(engine: *hy.Engine) callconv(.C) hy.World {
    return tryInit(engine) catch |e| std.debug.panic("init failure: {}", .{e});
}

fn tryInit(engine: *hy.Engine) !hy.World {
    var self_gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const self = try self_gpa.allocator().create(Self);
    self.* = .{
        .gpa = self_gpa,
        .callback_arena = std.heap.ArenaAllocator.init(self_gpa.allocator()),
        .objects = try SkipMap(Object).create(self_gpa.allocator(), .{}),
        .ui_state = .{ .second_timer = try std.time.Timer.start() },
        .camera = .{ .input = engine.input(), .window = engine.window() },
    };

    const gpu = engine.gpu();

    self.backpack_hdl = gpu.importModel("assets/backpack/backpack.obj", .{
        .transform = hym.mat4.identity,
        .post_process = .{
            .triangulate = true,
            .split_large_meshes = true,
            .pre_transform_vertices = true,
            .optimize_graph = true,
            .optimize_meshes = true,
            .gen_bounding_boxes = true,
        }
    });

    _ = gpu.modelWaitLoad(self.backpack_hdl, std.time.ns_per_s * 2);

    inline for (0..10) |y| {
        inline for (0..10) |x| {
            var object = (try self.objects.insert(undefined)).unwrap();
            object.* = .{
                .hdl = gpu.addRenderable(.{
                    .model = self.backpack_hdl,
                    .owner = &object.transform,
                    .time = 10 * std.time.ns_per_s,
                }),
                .transform = hym.mat4.translation(hym.mat4.identity, hym.vec3.create(x * 10, 100 - y * 10,0)),
                .bounds = gpu.modelBounds(self.backpack_hdl),
            };
        }
    }

    try self.camera.registerInputs(self.callback_arena.allocator());
    self.camera.position = hym.vec(.{50, 50, 50});
    self.camera.look_direction = hym.vec(.{0, 0, -1});

    const ui_state = engine.ui().getGlobalState();

    imgui.SetCurrentContext(@ptrCast(ui_state.imgui_ctx));
    implot.setCurrentContext(@ptrCast(ui_state.implot_ctx));

    return .{
        .scene = .{
            .light_dir = hym.vec(.{0, -1, -0.5}),
            .view_proj = self.camera.viewProj(),
            .camera_world_pos = self.camera.position,
        },
        .memory = self,
    };
}

fn shutdown(_: *hy.Engine, state: hy.World) callconv(.C) void {
    const ptr = @as(*u32, @ptrCast(@alignCast(state.memory)));
    std.heap.page_allocator.destroy(ptr);
}

// Called every loop iteration
fn update(_: *hy.Engine, pre: hy.World) callconv(.C) hy.World {
    const self: *Self = @ptrCast(@alignCast(pre.memory));
    var game = pre;

    game.scene.view_proj = self.camera.viewProj();

    if (self.ui_state.restart_requested) game.restart = true;

    return game;
}

// Only called on new frames
fn render(engine: *hy.Engine, state: hy.World) callconv(.C) void {
    const gpu = engine.gpu();
    const self: *Self = @ptrCast(@alignCast(state.memory));

    ui.drawMainUI(&self.ui_state);
    self.ui_state.frame_time = @floatFromInt(state.frame_time);
    if (self.ui_state.windows.camera) self.camera.editor();

    if (imgui.Begin("Test", null, 0)) {
        var it = self.objects.iterator();
        var count: u32 = 0;
        while (it.next()) |cursor| {
            const object = cursor.unwrap();
            imgui.PushIDPtr(object);
            if (count % 10 > 0) imgui.SameLine();
            if (imgui.ButtonEx("", .{ .x = 20, .y = 20 })) {
                gpu.clearSelection();
                gpu.selectRenderable(object.hdl);
            }
            imgui.PopID();
            count += 1;
        }
    }
    imgui.End();
}

fn reload(engine: *hy.Engine, game: hy.World) callconv(.C) bool {
    tryReload(engine, game) catch |err| {
        std.log.err("Failed reload: {}", .{err});
        return false;
    };
    return true;
}

fn tryReload(engine: *hy.Engine, game: hy.World) !void {
    const ptr = @as(*Self, @ptrCast(@alignCast(game.memory)));
    engine.input().reset();
    _ = ptr.callback_arena.reset(.retain_capacity);
    try ptr.camera.registerInputs(ptr.callback_arena.allocator());
}

export fn interface() hy.GameInterface {
    return .{
        .init = init,
        .shutdown = shutdown,
        .update = update,
        .render = render,
        .reload = reload,
    };
}
