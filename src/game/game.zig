const std = @import("std");
const imgui = @import("imgui");
const implot = @import("implot");
const hy = @import("hyoga-lib");
const rt = hy.runtime;
const hym = hy.math;
const SkipMap = hy.SkipMap;

const oom = hy.err.oom;

const ui = @import("ui.zig");
const cam = @import("camera.zig");
const Entity = @import("entity.zig").Entity;

const Self = @This();

const Object = struct {
    transform: hym.Mat4 = .identity,
    bounds: hym.AxisAligned = .{},
    hdl: rt.gpu.RenderItemHandle = .invalid,
};

allocator: std.mem.Allocator,
arena: std.heap.ArenaAllocator,
callback_arena: std.heap.ArenaAllocator,
cube_model: rt.gpu.ModelHandle = .invalid,
cube: Object = .{},
entity: Entity,
objects: SkipMap(Entity),
selected_objects: std.ArrayListUnmanaged(struct { hym.Vec3, *Entity }),
ui_state: ui.State,
camera: cam.Camera,
timer: std.time.Timer,

pub fn init(engine: *hy.Engine) !hy.World {
    const extern_allocator = engine.gameAllocator();
    const allocator: std.mem.Allocator = .{
        .ptr = extern_allocator.ptr,
        .vtable = extern_allocator.vtable,
    };
    const self = allocator.create(Self) catch oom();

    self.* = .{
        .allocator = allocator,
        .arena = std.heap.ArenaAllocator.init(self.allocator),
        .callback_arena = std.heap.ArenaAllocator.init(self.allocator),
        .objects = SkipMap(Entity).create(self.allocator, .{}) catch oom(),
        .selected_objects = try .initCapacity(self.allocator, 8),
        .ui_state = .{ .second_timer = std.time.Timer.start() catch unreachable },
        .camera = .{ .window = engine.window() },
        .entity = .{
            .gpu = engine.gpu(),
            .position = hym.vec(.{ 0, 0, 5 }),
        },
        .timer = std.time.Timer.start() catch unreachable,
    };

    const gpu = engine.gpu();
    const cube = gpu.modelPrimitive(.cube);
    const bounds = gpu.modelBounds(cube);

    self.entity.renderable = gpu.addRenderable(.{ .model = cube });
    self.entity.bounds = bounds;

    self.entity.update();

    for (0..10) |y| {
        for (0..10) |x| {
            const fx: f32 = @floatFromInt(x);
            const fy: f32 = @floatFromInt(y);
            const cursor = self.objects.insert(.createCube(engine.gpu())) catch oom();
            const object = cursor.unwrap();

            object.position = hym.vec(.{ fx, 9 - fy, 0 });
            object.scale = hym.vec(.{ 1, 1, 1 });
            object.bounds = bounds;
        }
    }

    self.camera.registerInputs(engine.input(), self.callback_arena.allocator()) catch oom();
    self.camera.position = hym.vec(.{ 0, 0, 15 });
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

    // self.camera.position = hym.vec(.{ 0, 0, 15 });
    // self.camera.look_direction = hym.vec(.{ 0, 0, -1 });

    game.scene.view_proj = self.camera.viewProj();

    const ray = self.camera.worldRay(engine.input().queryMousePosition());
    const allocator = self.arena.allocator();

    var boxes = allocator.alloc(hym.AxisAligned, self.objects.len) catch oom();
    var objects = allocator.alloc(*Entity, self.objects.len) catch oom();

    const time = blk: {
        const t: f32 = @floatFromInt(self.timer.read());
        break :blk t / std.time.ns_per_s;
    };

    {
        var it = self.objects.iterator();
        var i: u32 = 0;
        while (it.next()) |cursor| : (i += 1) {
            const object = cursor.unwrap();

            boxes[i] = object.calcBounds();
            objects[i] = object;

            object.update();
        }
    }

    const packed_boxes = hym.Ray.pack(boxes, allocator) catch oom();
    const intersections = ray.intersectPacked(packed_boxes, 1000, allocator) catch oom();

    for (objects, intersections[0..objects.len]) |object, ixn| {
        if (ixn < 1000) {
            engine.gpu().selectRenderable(object.renderable);
            if (self.selected_objects.items.len < self.selected_objects.capacity) {
                self.selected_objects.appendAssumeCapacity(.{ object.position, object });
            }
        }
    }

    for (self.selected_objects.items) |item| {
        item[1].position = hym.vec(.{
            item[0].x(),
            item[0].y(),
            item[0].z() + std.math.sin(time),
        });
        item[1].update();
    }

    if (self.ui_state.restart_requested) {
        game.restart = true;
        self.ui_state.restart_requested = false;
    }

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
    for (self.selected_objects.items) |item| {
        item[1].position = item[0];
    }
    self.selected_objects.clearRetainingCapacity();
}

pub fn reload(engine: *hy.Engine, game: hy.World) !void {
    const ptr: *Self = @ptrCast(@alignCast(game.memory));

    // Patch up procedure pointers
    engine.input().reset();
    _ = ptr.callback_arena.reset(.retain_capacity);
    ptr.camera.registerInputs(engine.input(), ptr.callback_arena.allocator()) catch oom();

    const ui_state = engine.ui().getGlobalState();
    imgui.SetCurrentContext(@ptrCast(ui_state.imgui_ctx));
    implot.setCurrentContext(@ptrCast(ui_state.implot_ctx));
}
