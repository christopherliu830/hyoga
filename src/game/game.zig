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
arena: std.heap.ArenaAllocator,
callback_arena: std.heap.ArenaAllocator,
cube_model: rt.gpu.ModelHandle = rt.gpu.ModelHandle.invalid,
cube: Object = undefined,
objects: SkipMap(Object),
ui_state: ui.State,
camera: cam.Camera,

pub fn init(engine: *hy.Engine) !hy.World {
    var self_gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const self = try self_gpa.allocator().create(Self);
    self.* = .{
        .gpa = self_gpa,
        .arena = std.heap.ArenaAllocator.init(self.gpa.allocator()),
        .callback_arena = std.heap.ArenaAllocator.init(self.gpa.allocator()),
        .objects = try SkipMap(Object).create(self.gpa.allocator(), .{}),
        .ui_state = .{ .second_timer = try std.time.Timer.start() },
        .camera = .{ .input = engine.input(), .window = engine.window() },
    };

    const gpu = engine.gpu();

    const cube = gpu.modelPrimitive(.cube);
    const quad = gpu.modelPrimitive(.quad);
    const bounds = gpu.modelBounds(quad);

    for (0..10) |y| {
        for (0..10) |x| {
            const fx: f32 = @floatFromInt(x);
            const fy: f32 = @floatFromInt(y);
            var object = (try self.objects.insert(undefined)).unwrap();
            object.* = .{
                .hdl = gpu.addRenderable(.{
                    .model = if ((y + x) % 2 == 0) quad else cube,
                    .owner = &object.transform,
                    .time = 10 * std.time.ns_per_s,
                }),
                .transform = hym.mat4.translation(hym.mat4.identity, hym.vec3.create(fx * 10, 90 - fy * 10, 0)),
                .bounds = bounds,
            };
        }
    }

    try self.camera.registerInputs(self.callback_arena.allocator());
    self.camera.position = hym.vec(.{ 50, 50, 50 });
    self.camera.look_direction = hym.vec(.{ 0, 0, -1 });

    const ui_state = engine.ui().getGlobalState();

    imgui.SetCurrentContext(@ptrCast(ui_state.imgui_ctx));
    implot.setCurrentContext(@ptrCast(ui_state.implot_ctx));

    return .{
        .scene = .{
            .light_dir = hym.vec(.{ 0, -1, -0.5 }),
            .view_proj = self.camera.viewProj(),
            .camera_world_pos = self.camera.position,
        },
        .memory = self,
    };
}

pub fn update(engine: *hy.Engine, pre: hy.World) callconv(.C) hy.World {
    var game = pre;
    const self: *Self = @ptrCast(@alignCast(pre.memory));

    game.scene.view_proj = self.camera.viewProj();

    const ray = self.camera.worldRay();
    const allocator = self.arena.allocator();

    // Check performance difference
    if (true) {
        var boxes = allocator.alloc(hym.AxisAligned, self.objects.len) catch std.debug.panic("oom", .{});
        var objects = allocator.alloc(*Object, self.objects.len) catch std.debug.panic("oom", .{});

        {
            var it = self.objects.iterator();
            var i: u32 = 0;
            while (it.next()) |cursor| : (i += 1) {
                const object = cursor.unwrap();
                const bounds = hym.AxisAligned{
                    .min = object.bounds.min.add(object.transform.position()),
                    .max = object.bounds.max.add(object.transform.position()),
                };
                boxes[i] = bounds;
                objects[i] = object;
            }
        }

        const packed_boxes = hym.Ray.pack(boxes, allocator) catch std.debug.panic("oom", .{});
        const intersections = ray.intersectPacked(packed_boxes, 1000, allocator) catch std.debug.panic("oom", .{});

        for (objects, 0..) |object, i| {
            const ixn = intersections[i];
            if (ixn < 1000) {
                std.debug.print("hit\n", .{});
                engine.gpu().selectRenderable(object.hdl);
            }
        }
    } else {
        var it = self.objects.iterator();
        var i: u32 = 0;
        while (it.next()) |cursor| : (i += 1) {
            const object = cursor.unwrap();
            const bounds = hym.AxisAligned{
                .min = object.bounds.min.add(object.transform.position()),
                .max = object.bounds.max.add(object.transform.position()),
            };
            var t: f32 = 1000;
            ray.intersect(&.{bounds}, (&t)[0..1]);
            if (t < 1000) {
                engine.gpu().selectRenderable(object.hdl);
            }
        }
    }

    if (self.ui_state.restart_requested) game.restart = true;

    return game;
}

// Only called on new frames
pub fn render(engine: *hy.Engine, state: hy.World) callconv(.C) void {
    _ = engine;
    const self: *Self = @ptrCast(@alignCast(state.memory));

    ui.drawMainUI(&self.ui_state);
    self.ui_state.frame_time = state.render_delta_time;
    if (self.ui_state.windows.camera) self.camera.editor();
}

pub fn afterRender(engine: *hy.Engine, world: hy.World) callconv(.C) void {
    engine.gpu().clearSelection();
    const self: *Self = @ptrCast(@alignCast(world.memory));
    _ = self.arena.reset(.retain_capacity);
}

pub fn reload(engine: *hy.Engine, game: hy.World) !void {
    const ptr = @as(*Self, @ptrCast(@alignCast(game.memory)));
    engine.input().reset();
    _ = ptr.callback_arena.reset(.retain_capacity);
    try ptr.camera.registerInputs(ptr.callback_arena.allocator());
}
