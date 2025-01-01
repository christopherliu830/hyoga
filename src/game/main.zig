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
    bounds: hym.AxisAligned = .{},
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
fn update(engine: *hy.Engine, pre: hy.World) callconv(.C) hy.World {
    const self: *Self = @ptrCast(@alignCast(pre.memory));
    var game = pre;

    game.scene.view_proj = self.camera.viewProj();

    const ray = self.camera.worldRay();

    var it = self.objects.iterator();
    var i: u32 = 0;
    while (it.next()) |cursor| : (i += 1) {
        const object = cursor.unwrap();
        const bounds = hym.AxisAligned {
            .min = object.bounds.min.add(object.transform.position()),
            .max = object.bounds.max.add(object.transform.position()),
        };
        const collide = ray.intersect(bounds, 1000);
        if (collide) {
            engine.gpu().selectRenderable(object.hdl);
        }
    }

    it = self.objects.iterator();
    var first = it.next().?.unwrap();
    first.transform = hym.mat4.translation(hym.mat4.identity, ray.origin.add(ray.direction.mul(50)));

    if (self.ui_state.restart_requested) game.restart = true;

    return game;
}

// Only called on new frames
fn render(engine: *hy.Engine, state: hy.World) callconv(.C) void {
    _ = engine;
    const self: *Self = @ptrCast(@alignCast(state.memory));

    ui.drawMainUI(&self.ui_state);
    self.ui_state.frame_time = @floatFromInt(state.frame_time);
    if (self.ui_state.windows.camera) self.camera.editor();
}

fn afterRender(engine: *hy.Engine, _: hy.World) callconv(.C) void {
    engine.gpu().clearSelection();
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
        .afterRender = afterRender,
        .reload = reload,
    };
}
