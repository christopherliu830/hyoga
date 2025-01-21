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
const ent = @import("entity.zig");
const Entity = ent.Entity;

const Self = @This();

const Object = struct {
    transform: hym.Mat4 = .identity,
    bounds: hym.AxisAligned = .{},
    hdl: rt.gpu.RenderItemHandle = .invalid,
};

pub const ControlMode = enum {
    noclip,
    game,
};

const CachedWorld = struct {
    boxes: []hym.ray.Ray.PackedAxisAligned = &.{},
    objects: []*Entity = &.{},
};

allocator: std.mem.Allocator,
arena: std.heap.ArenaAllocator,
callback_arena: std.heap.ArenaAllocator,
input_group: hy.Input.Group,
cube_model: rt.gpu.ModelHandle = .invalid,
cube: Object = .{},
player: ent.Player,
objects: SkipMap(Entity),
selected_objects: std.ArrayListUnmanaged(*Entity),
ui_state: ui.State,
camera: cam.Camera,
timer: std.time.Timer,
world_cache: CachedWorld = .{},

pub fn init(engine: *hy.Engine) !hy.World {
    const extern_allocator = engine.gameAllocator();
    const allocator: std.mem.Allocator = .{
        .ptr = extern_allocator.ptr,
        .vtable = extern_allocator.vtable,
    };

    const gpu = engine.gpu();
    const cube = ent.createCube(engine.gpu());
    const self = allocator.create(Self) catch oom();
    self.* = .{
        .allocator = allocator,
        .arena = std.heap.ArenaAllocator.init(self.allocator),
        .callback_arena = std.heap.ArenaAllocator.init(self.allocator),
        .input_group = .none,
        .objects = SkipMap(Entity).create(self.allocator, .{}) catch oom(),
        .selected_objects = try .initCapacity(self.allocator, 8),
        .ui_state = .{ .second_timer = std.time.Timer.start() catch unreachable, .mode = .noclip },
        .camera = .default(engine.window()),
        .player = .default((self.objects.insert(cube) catch oom()).unwrap()),
        .timer = std.time.Timer.start() catch unreachable,
    };
    self.registerInputs(engine);
    const bounds = gpu.modelBounds(gpu.modelPrimitive(.cube));

    for (0..10) |y| {
        for (0..10) |x| {
            const fx: f32 = @floatFromInt(x);
            const fy: f32 = @floatFromInt(y);
            const cursor = self.objects.insert(ent.createCube(engine.gpu())) catch oom();
            const object = cursor.unwrap();

            object.position = hym.vec(.{ 2 * fx - 10, 10 - fy * 2, 0 });
            object.scale = hym.vec(.{ 1, 1, 1 });
            object.bounds = bounds;
        }
    }

    self.camera.position = hym.vec(.{ 0, 0, 15 });
    self.camera.look_direction = hym.vec(.{ 0, 0, -1 });

    const ui_state = engine.ui().getGlobalState();

    imgui.SetCurrentContext(@ptrCast(ui_state.imgui_ctx));
    implot.setCurrentContext(@ptrCast(ui_state.implot_ctx));

    self.switchControlMode(engine, .game, null);

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

    const allocator = self.arena.allocator();

    game.scene.view_proj = self.camera.viewProj();

    self.world_cache = cacheWorld(&self.objects, self.arena.allocator());
    self.selected_objects.clearRetainingCapacity();
    const ray = self.camera.worldRay(engine.input().queryMousePosition());
    const intersections = ray.intersectPacked(self.world_cache.boxes, 1000, allocator) catch oom();
    for (self.world_cache.objects, intersections[0..self.world_cache.objects.len]) |object, ixn| {
        if (ixn < 1000) {
            engine.gpu().selectRenderable(object.renderable);
            if (self.selected_objects.items.len < self.selected_objects.capacity) {
                self.selected_objects.appendAssumeCapacity(object);
            }
        }
    }

    const delta_time = blk: {
        const t: f32 = @floatFromInt(game.update_delta_time);
        break :blk t / std.time.ns_per_s;
    };

    for (self.world_cache.objects) |object| {
        if (object.scale.x() < 1) {
            object.scale = object.scale.add(hym.vec3.one.mul(delta_time));
        }
    }

    self.player.update(delta_time);
    self.camera.update(delta_time);

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

    var it = self.objects.iterator();
    while (it.next()) |cursor| {
        const object = cursor.unwrap();
        object.pushRender();
    }

    ui.drawMainUI(&self.ui_state);
    self.ui_state.update_time = state.update_delta_time;
    self.ui_state.render_time = state.render_delta_time;
    if (self.ui_state.windows.camera) self.camera.editor();
}

pub fn afterRender(engine: *hy.Engine, world: hy.World) callconv(.C) void {
    engine.gpu().clearSelection();
    const self: *Self = @ptrCast(@alignCast(world.memory));
    _ = self.arena.reset(.retain_capacity);
}

pub fn reload(engine: *hy.Engine, game: hy.World) !void {
    const ptr: *Self = @ptrCast(@alignCast(game.memory));

    // Patch up procedure pointers
    engine.input().reset();
    _ = ptr.callback_arena.reset(.retain_capacity);
    ptr.registerInputs(engine);

    ptr.switchControlMode(engine, .noclip, null);

    const ui_state = engine.ui().getGlobalState();
    imgui.SetCurrentContext(@ptrCast(ui_state.imgui_ctx));
    implot.setCurrentContext(@ptrCast(ui_state.implot_ctx));
}

fn cacheWorld(objects: *hy.SkipMap(Entity), arena: std.mem.Allocator) CachedWorld {
    var boxes = arena.alloc(hym.AxisAligned, objects.len) catch oom();
    var objects_slice = arena.alloc(*Entity, objects.len) catch oom();

    var it = objects.iterator();
    var i: u32 = 0;
    while (it.next()) |cursor| : (i += 1) {
        const object = cursor.unwrap();

        boxes[i] = object.calcBounds();
        objects_slice[i] = object;
    }

    const packed_boxes = hym.Ray.pack(boxes, arena) catch oom();

    return .{
        .boxes = packed_boxes,
        .objects = objects_slice,
    };
}

fn registerInputs(self: *Self, engine: *hy.Engine) void {
    const input = engine.input();
    const group = input.getGroup(self.input_group);

    if (group == self.input_group) return;
    self.input_group = group;

    const l: hy.closure.Builder = .{ .allocator = self.callback_arena.allocator() };
    input.bind(group, .key(.@"1"), l.make(switchControlMode, .{ self, engine, .game }));
    input.bind(group, .key(.@"2"), l.make(switchControlMode, .{ self, engine, .noclip }));
    input.bind(group, .mouse(.left), l.make(intersect, .{ self, engine }));
    input.bind(group, .mouse(.right), l.make(inspectUnderMouse, .{ self, engine.input() }));

    self.player.registerInputs(input, self.callback_arena.allocator());
    self.camera.registerInputs(engine.input(), self.callback_arena.allocator()) catch oom();
}

fn switchControlMode(self: *Self, engine: *hy.Engine, mode: ControlMode, _: ?*anyopaque) void {
    self.ui_state.mode = mode;
    switch (mode) {
        .noclip => {
            engine.window().setRelativeMouseMode(false);
            engine.input().setGroupEnabled(self.camera.input_group, true);
            engine.input().setGroupEnabled(self.player.input_group, false);
        },
        .game => {
            engine.window().setRelativeMouseMode(false);
            engine.input().setGroupEnabled(self.camera.input_group, false);
            engine.input().setGroupEnabled(self.player.input_group, true);
        },
    }
}

fn intersect(self: *Self, engine: *hy.Engine, _: ?*anyopaque) void {
    self.world_cache = cacheWorld(&self.objects, self.arena.allocator());
    const ray = self.camera.worldRay(engine.input().queryMousePosition());
    const intersections = ray.intersectPacked(self.world_cache.boxes, 1000, self.arena.allocator()) catch oom();

    for (self.world_cache.objects, intersections[0..self.world_cache.objects.len]) |object, ixn| {
        if (ixn < 1000) {
            object.scale = hym.vec(.{ 0.2, 0.2, 0.2 });
            engine.gpu().selectRenderable(object.renderable);
        }
    }
}

fn inspectUnderMouse(self: *Self, input: *hy.Input, _: ?*anyopaque) void {
    const bounds = self.player.entity.calcBounds();
    var out: f32 = 1000;
    const ray = self.camera.worldRay(input.queryMousePosition());
    ray.intersect(&.{bounds}, (&out)[0..1]);
    if (out < 1000) {
        self.ui_state.windows.inspector = true;
        self.ui_state.inspector = .{ .player = &self.player };
        return;
    }

    self.ui_state.inspector = .none;
}
