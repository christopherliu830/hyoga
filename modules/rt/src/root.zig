const std = @import("std");
const sdl = @import("sdl");
const imgui = @import("imgui");

const hy = @import("hyoga-lib");
const hym = hy.math;

const Engine = @import("Engine.zig");
const gfx = @import("graphics/root.zig");

const Audio = Engine.Audio;
const Input = Engine.Input;
const Phys2 = Engine.Phys2;
const Strint = Engine.Strint;
const UI = Engine.UI;
const Window = Engine.Window;

pub const Scene = extern struct {
    view: hym.Mat4,
    proj: hym.Mat4,
    light_dir: hym.Vec3,
    camera_world_pos: hym.Vec3,

    comptime {
        hy.meta.assertMatches(Scene, hy.runtime.Scene);
    }
};

pub const World = extern struct {
    quit: bool = false,
    restart: bool = false,
    scene: Scene,
    current_time: u64 = 0,
    interp_alpha: f32 = 0,
    render_delta_time: u64 = 0,
    update_delta_time: u64 = 0,
    memory: *anyopaque,

    comptime {
        hy.meta.assertMatches(World, hy.runtime.World);
    }
};

pub const GameInterface = extern struct {
    init: *const fn (*Engine) callconv(.c) World,
    shutdown: *const fn (*Engine, World) callconv(.c) void,
    update: *const fn (*Engine, World) callconv(.c) World,
    render: *const fn (*Engine, World) callconv(.c) void,
    afterRender: ?*const fn (*Engine, World) callconv(.c) void = null,
    reload: *const fn (*Engine, World) callconv(.c) bool,
};

pub fn init() *Engine {
    return Engine.init() catch |err| {
        std.debug.panic("Engine init failure: {}", .{err});
    };
}

export fn hyInit() *Engine {
    return init();
}

export fn hyeShutdown(engine: *Engine) void {
    engine.shutdown();
}

export fn hyeUpdate(engine: *Engine, world: World, gi: GameInterface) World {
    return engine.update(world, gi);
}

export fn hyeGpu(engine: *Engine) *gfx.Gpu {
    return engine.gpu;
}

export fn hyeInput(engine: *Engine) *Input {
    return &engine.input;
}

export fn hyePhys2(engine: *Engine) *Phys2 {
    return &engine.physics;
}

export fn hyeStrint(engine: *Engine) *Strint {
    return &engine.strint;
}

export fn hyeUI(engine: *Engine) *UI {
    return &engine.ui;
}

export fn hyeWindow(engine: *Engine) *Window {
    return &engine.window;
}

export fn hyeGameAllocator(engine: *Engine) hy.ExternAllocator {
    return engine.gameAllocator();
}

export fn hyaudSoundRead(path: hy.ExternSliceConst(u8)) Audio.Sound {
    return Engine.Audio.read(path.asSliceZ());
}

export fn hyaudSoundPlay(sound: *Audio.Sound) void {
    sound.play();
}

export fn hyaudSoundStop(sound: *Audio.Sound) void {
    sound.stop();
}

export fn hy_gfx_clearColorSet(gpu: *gfx.Gpu, color: hym.Vec4) void {
    gpu.clearColorSet(color);
}

export fn hy_gfx_importModel(gpu: *gfx.Gpu, path: [*:0]const u8, settings: gfx.Models.ImportSettings) gfx.Model {
    return gpu.importModel(path, settings) catch |e| {
        std.log.err("import model failure: {}", .{e});
        return gfx.Model.invalid;
    };
}

export fn hy_gfx_modelCreate(gpu: *gfx.Gpu, opts: hy.gfx.ModelCreateOptions) gfx.Model {
    return gpu.models.create(.{
        .gpu = gpu,
        .verts = @ptrCast(@alignCast(opts.verts.asSlice())),
        .indices = opts.indices.asSlice(),
        .material = @bitCast(@intFromEnum(opts.material)),
        .transform = opts.transform,
    }) catch unreachable;
}

export fn hy_gfx_modelDestroy(gpu: *gfx.Gpu, model: gfx.Model) void {
    gpu.models.remove(&gpu.buffer_allocator, model);
}

export fn hy_gfx_modelBounds(gpu: *gfx.Gpu, model: gfx.Model) hym.AxisAligned {
    if (gpu.models.get(model)) |m| {
        return m.bounds;
    } else |e| {
        std.log.err("get model failure: {}", .{e});
        return .{};
    }
}

export fn hy_gfx_modelDupe(gpu: *gfx.Gpu, model: gfx.Model, options: gfx.Models.DupeModelOptions) gfx.Model {
    return gpu.models.dupe(&gpu.buffer_allocator, model, options) catch |e| {
        std.log.err("dupe model failure: {}", .{e});
        return .invalid;
    };
}

export fn hy_gfx_modelPrimitive(gpu: *gfx.Gpu, shape: gfx.primitives.Shape) gfx.Model {
    return gpu.modelPrimitive(shape);
}

export fn hy_gfx_modelWaitLoad(gpu: *gfx.Gpu, model: gfx.Model, max: u64) bool {
    return gpu.models.waitLoad(model, max);
}

export fn hy_gfx_materialDefaultCreate(gpu: *gfx.Gpu) gfx.MaterialHandle {
    return gpu.materialDefaultCreate();
}

export fn hy_gfx_materialLoad(gpu: *gfx.Gpu, path: hy.ExternSliceConst(u8)) gfx.MaterialHandle {
    return gpu.materialLoad(path.asSliceZ()) catch |e| {
        std.log.err("Error loading material: {}\n", .{e});
        return .invalid;
    };
}

export fn hy_gfx_materialReload(gpu: *gfx.Gpu, hdl: gfx.MaterialHandle) void {
    gpu.materials.reload(hdl) catch |e| {
        std.log.err("Error reloading material: {}\n", .{e});
    };
}

export fn hy_gfx_materialCreate(gpu: *gfx.Gpu, mt_type: gfx.MaterialType, tx_set: *const gfx.TextureArray) gfx.MaterialHandle {
    return gpu.materialCreate(mt_type, tx_set);
}

export fn hy_gfx_materialDestroy(gpu: *gfx.Gpu, hdl: gfx.MaterialHandle) void {
    gpu.materialDestroy(hdl);
}

export fn hy_gfx_renderableAdd(gpu: *gfx.Gpu, options: gfx.Gpu.AddRenderableOptions) gfx.Renderable {
    return gpu.renderableAdd(options) catch |e| {
        std.log.err("add renderable failure: {}", .{e});
        return .{
            .pass = .default,
            .index = .none,
        };
    };
}

export fn hy_gfx_renderableDestroy(gpu: *gfx.Gpu, item: gfx.Renderable) void {
    gpu.renderableDestroy(item);
}

export fn hy_gfx_renderableSetTransform(gpu: *gfx.Gpu, item: gfx.Renderable, transform: hym.Mat4) void {
    gpu.renderableSetTransform(item, transform);
}

export fn hy_gfx_renderableOfSprite(gpu: *gfx.Gpu, hdl: gfx.SpriteHandle) gfx.Renderable {
    return gpu.renderableOfSprite(hdl) catch |e| {
        std.log.err("sprite dupe failure: {}", .{e});
        return .{
            .pass = .default,
            .index = .none,
        };
    };
}

export fn hy_gfx_spriteCreate(gpu: *gfx.Gpu, opts: gfx.Gpu.SpriteCreateOptions) gfx.SpriteHandle {
    return gpu.spriteCreate(opts) catch |e| {
        std.log.err("sprite create failure: {}", .{e});
        return .invalid;
    };
}

export fn hy_gfx_spriteDestroy(gpu: *gfx.Gpu, hdl: gfx.SpriteHandle) void {
    gpu.spriteDestroy(hdl);
}

export fn hy_gfx_spriteWeakPtr(gpu: *gfx.Gpu, hdl: gfx.SpriteHandle) ?*gfx.Gpu.GpuSprite {
    return gpu.spriteWeakPtr(hdl);
}

export fn hy_gfx_spriteRenderableWeakPtr(gpu: *gfx.Gpu, hdl: gfx.Renderable) ?*gfx.Gpu.GpuSprite {
    return gpu.spriteRenderableWeakPtr(hdl);
}

export fn hy_gfx_spriteCurrentAnimationFrame(gpu: *gfx.Gpu, hdl: *gfx.Gpu.GpuSprite) u32 {
    return gpu.spriteCurrentAnimationFrame(hdl);
}

export fn hy_gfx_spriteDupe(gpu: *gfx.Gpu, hdl: gfx.SpriteHandle) gfx.SpriteHandle {
    return gpu.spriteDupe(hdl);
}

export fn hy_gfx_textureImport(gpu: *gfx.Gpu, path: hy.ExternSlice(u8)) gfx.TextureHandle {
    return gpu.textures.read(path.asSliceZ()) catch |e| {
        std.log.err("texture import failure: {}", .{e});
        return .invalid;
    };
}

export fn hy_gfx_passCreate(gpu: *gfx.Gpu, opts: hy.gfx.PassCreateOptions) gfx.PassHandle {
    return gpu.passCreate(opts);
}

export fn hy_gfx_passDestroy(gpu: *gfx.Gpu, hdl: gfx.PassHandle) void {
    return gpu.passDestroy(hdl);
}

export fn hy_gfx_passAdd(gpu: *gfx.Gpu, opts: gfx.Gpu.PassAddOptions) gfx.Renderable {
    return gpu.passAdd(opts);
}

export fn hy_gfx_passClear(gpu: *gfx.Gpu, hdl: gfx.PassHandle) void {
    return gpu.passClear(hdl);
}

export fn hy_gfx_immediateDraw(
    gpu: *gfx.Gpu,
    verts: hy.ExternSliceConst(gfx.UIVertex),
    indices: hy.ExternSliceConst(u32),
    transform: hym.Mat4,
    material_hdl: gfx.MaterialHandle,
) void {
    const material = blk: {
        if (material_hdl.valid()) {
            break :blk gpu.materials.get(material_hdl);
        } else {
            break :blk gpu.materials.createWeak(.ui, .init(.{ .diffuse = .{ .target = gpu.default_assets.white_texture } }));
        }
    };
    gpu.im.drawVerts(verts.asSlice(), indices.asSlice(), .{
        .transform = transform,
        .material = if (material) |*m| m else null,
    });
}

export fn hyioReset(input: *Input) void {
    input.reset();
}

export fn hyioCreateGroup(input: *Input) Input.Group.Handle {
    return input.createGroup();
}

export fn hyioGetGroup(input: *Input, hdl: Input.Group.Handle) Input.Group.Handle {
    return input.getGroup(hdl);
}

export fn hyioGroupDestroy(input: *Input, hdl: Input.Group.Handle) void {
    return input.groupDestroy(hdl);
}

export fn hyioSetGroupEnabled(input: *Input, group: Input.Group.Handle, enabled: bool) void {
    input.setGroupEnabled(group, enabled);
}

export fn hyioBind(
    input: *Input,
    group: Input.Group.Handle,
    options: Input.BindOptions,
    delegate: *hy.closure.Runnable(anyopaque),
) void {
    input.bind(group, options, delegate) catch |e| {
        std.log.err("Could not bind delegate: {}", .{e});
    };
}

export fn hyioQueryMouse(input: *Input, button: hy.key.MouseButton) bool {
    return input.queryMouse(button);
}

export fn hyioQueryMousePosition(input: *Input) hym.Vec2 {
    return input.queryMousePosition();
}

export fn hyioQueryKey(input: *Input, button: hy.key.Keycode) bool {
    return input.queryKey(button);
}

export fn hy_io_bindPoll(input: *Input, id: u32, on: hy.Input.OnFlags, button: hy.key.Keycode) void {
    input.bindPoll(id, on, button) catch |err| {
        std.log.err("input bind failure: {}", .{err});
    };
}

export fn hy_io_bindPollMouse(input: *Input, id: u32, on: hy.Input.OnFlags, mouse: hy.MouseButton) void {
    input.bindPollMouse(id, on, mouse) catch |err| {
        std.log.err("input bind failure: {}", .{err});
    };
}

export fn hy_io_eventPump(input: *Input) hy.ExternSliceConst(u32) {
    const events = input.eventPump() catch |err| {
        std.log.err("input event pump failure: {}", .{err});
        return .from(&.{});
    };
    return .from(events);
}

export fn hy_io_eventClear(input: *Input, events: hy.ExternSliceConst(u32)) void {
    input.eventClear(events.asSlice());
}

export fn hysidFrom(strint: *Strint, str: [*]const u8, len: usize) Strint.ID {
    return strint.from(str[0..len]) catch |e| {
        std.log.err("strint failure: {}", .{e});
        return Strint.ID.invalid;
    };
}

export fn hyp2BodyAdd(p2d: *Phys2, opts: Phys2.BodyAddOptions) Phys2.Body {
    return p2d.addBody(opts);
}

export fn hyp2BodyDestroy(body: Phys2.Body) void {
    return body.destroy();
}

export fn hyp2BodyUserData(body: Phys2.Body) ?*anyopaque {
    return body.getUserData();
}

export fn hyp2BodyGetPosition(p2d: *Phys2, body: Phys2.Body) hym.Vec2 {
    return p2d.bodyPosition(body);
}

export fn hyp2BodyPositionSet(body: Phys2.Body, pos: hym.Vec2) void {
    Phys2.bodyPositionSet(body, pos);
}

export fn hyp2BodyRealPosition(body: Phys2.Body) hym.Vec2 {
    return @bitCast(body.getPosition());
}

export fn hyp2BodyGetType(body: Phys2.Body) Phys2.Body.Type {
    return @enumFromInt(@intFromEnum(body.getType()));
}

export fn hyp2BodySetType(body: Phys2.Body, body_type: Phys2.Body.Type) void {
    body.setType(@enumFromInt(@intFromEnum(body_type)));
}

export fn hyp2BodyGetVelocity(body: Phys2.Body) hym.Vec2 {
    return @bitCast(body.getLinearVelocity());
}

export fn hyp2BodySetVelocity(body: Phys2.Body, velocity: hym.Vec2) void {
    body.setLinearVelocity(@bitCast(velocity));
}

export fn hyp2ShapeExtra(shape: Phys2.b2.Shape) Phys2.ShapeExtra {
    return Phys2.shapeExtra(shape);
}

export fn hyp2EventsReset(p2d: *Phys2) void {
    p2d.eventsReset();
}

export fn hyp2HitEventRegister(
    p2d: *Phys2,
    body: Phys2.Body,
    cb: *hy.closure.Runnable(anyopaque),
) void {
    p2d.hitEventRegister(body, cb);
}

export fn hyp2HitEventDeregister(
    p2d: *Phys2,
    body: Phys2.Body,
    cb: *hy.closure.Runnable(anyopaque),
) void {
    p2d.hitEventDeregister(body, cb);
}

export fn hyp2HitEventDeregisterAll(
    p2d: *Phys2,
    body: Phys2.Body,
) void {
    p2d.hitEventDeregisterAll(body);
}

export fn hyp2OverlapLeaky(p2d: *Phys2, arena: hy.ExternAllocator, shape: Phys2.ShapeConfig, origin: hym.Vec2) hy.ExternSlice(Phys2.b2.Shape) {
    return .from(p2d.overlapLeaky(arena.allocator(), shape, origin));
}

export fn hyp2RaycastLeaky(
    p2d: *Phys2,
    arena: hy.ExternAllocator,
    opts: Phys2.RaycastOptions,
) hy.ExternSlice(Phys2.RaycastHit) {
    return .from(p2d.raycastLeaky(arena.allocator(), opts));
}

export fn hyp2CastCircleLeaky(p2d: *Phys2, arena: hy.ExternAllocator, opts: Phys2.CastCircleOptions) hy.ExternSlice(Phys2.RaycastHit) {
    return .from(p2d.castCircleLeaky(arena.allocator(), opts));
}

export fn hyp2ShapeBody(shape: Phys2.b2.Shape) Phys2.Body {
    return shape.getBody();
}

export fn hysidAsString(strint: *Strint, str: Strint.ID, len: *usize) [*]const u8 {
    const slice = strint.asString(str);
    len.* = slice.len;
    return slice.ptr;
}

export fn hysidAsStringZ(strint: *Strint, str: Strint.ID, len: *usize) [*]const u8 {
    const slice = strint.asStringZ(str);
    len.* = slice.len;
    return slice.ptr;
}

export fn hyuiGetGlobalState(ui: *UI) UI.GlobalState {
    return ui.getGlobalState();
}

export fn hyuiInputState(ui: *UI) UI.InputState {
    return ui.inputState();
}

export fn hywSetRelativeMouseMode(window: *Window, on_off: bool) void {
    window.setRelativeMouseMode(on_off);
}

export fn hywDimensions(window: *Window) hym.Vec2 {
    return window.dimensions();
}

export fn hywProjectionMatrix(window: *Window) hym.Mat4 {
    return window.projectionMatrix();
}
