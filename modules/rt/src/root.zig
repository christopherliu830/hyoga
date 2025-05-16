const std = @import("std");
const sdl = @import("sdl");
const imgui = @import("imgui");

const hy = @import("hyoga-lib");
const math = hy.math;

const Engine = @import("Engine.zig");
const Audio = Engine.Audio;
const Input = Engine.Input;
const Gpu = Engine.Gpu;
const Phys2 = Engine.Phys2;
const Strint = Engine.Strint;
const UI = Engine.UI;
const Window = Engine.Window;

pub const Scene = extern struct {
    view: math.Mat4,
    proj: math.Mat4,
    light_dir: math.Vec3,
    camera_world_pos: math.Vec3,

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
    init: *const fn (*Engine) callconv(.C) World,
    shutdown: *const fn (*Engine, World) callconv(.C) void,
    update: *const fn (*Engine, World) callconv(.C) World,
    render: *const fn (*Engine, World) callconv(.C) void,
    afterRender: ?*const fn (*Engine, World) callconv(.C) void = null,
    reload: *const fn (*Engine, World) callconv(.C) bool,
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

export fn hyeGpu(engine: *Engine) *Gpu {
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

export fn hyaudSoundPlay(sound: Audio.Sound) void {
    sound.play();
}

export fn hygpuClearColorSet(gpu: *Gpu, color: hy.math.Vec4) void {
    gpu.clearColorSet(color);
}

export fn hygpuImportModel(gpu: *Gpu, path: [*:0]const u8, settings: Gpu.Models.ImportSettings) Gpu.Model {
    return gpu.importModel(path, settings) catch |e| {
        std.log.err("import model failure: {}", .{e});
        return Gpu.Model.invalid;
    };
}

export fn hygpuModelCreate(gpu: *Gpu, verts: hy.ExternSliceConst(Gpu.Vertex), indices: hy.ExternSliceConst(u32), mat: Gpu.MaterialHandle) Gpu.Model {
    return gpu.models.create(.{
        .gpu = gpu,
        .verts = verts.asSlice(),
        .indices = indices.asSlice(),
        .material = mat,
    }) catch unreachable;
}

export fn hygpuModelDestroy(gpu: *Gpu, model: Gpu.Model) void {
    gpu.models.remove(&gpu.buffer_allocator, model);
}

export fn hygpuModelBounds(gpu: *Gpu, model: Gpu.Model) hy.math.AxisAligned {
    if (gpu.models.get(model)) |m| {
        return m.bounds;
    } else |e| {
        std.log.err("get model failure: {}", .{e});
        return .{};
    }
}

export fn hygpuModelDupe(gpu: *Gpu, model: Gpu.Model, options: Gpu.Models.DupeModelOptions) Gpu.Model {
    return gpu.models.dupe(model, options) catch |e| {
        std.log.err("dupe model failure: {}", .{e});
        return Gpu.Model.invalid;
    };
}

export fn hygpuModelPrimitive(gpu: *Gpu, shape: Gpu.primitives.Shape) Gpu.Model {
    return gpu.modelPrimitive(shape);
}

export fn hygpuModelWaitLoad(gpu: *Gpu, model: Gpu.Model, max: u64) bool {
    return gpu.models.waitLoad(model, max);
}

export fn hygpuMaterialCreate(gpu: *Gpu, mt_type: Gpu.MaterialType, tx_set: *const Gpu.TextureArray) Gpu.MaterialHandle {
    return gpu.materialCreate(mt_type, tx_set) catch |e| {
        std.log.err("material create failure: {}", .{e});
        return .invalid;
    };
}

export fn hygpuAddRenderable(gpu: *Gpu, options: Gpu.AddRenderableOptions) Gpu.RenderItemHandle {
    return gpu.renderables.add(options) catch |e| {
        std.log.err("add renderable failure: {}", .{e});
        return .invalid;
    };
}

export fn hygpuRenderableDestroy(gpu: *Gpu, item: Gpu.RenderItemHandle) void {
    gpu.renderableDestroy(item);
}

export fn hygpuSelectRenderable(gpu: *Gpu, item: Gpu.RenderItemHandle) void {
    gpu.selectRenderable(item);
}

export fn hygpuDeselectRenderable(gpu: *Gpu, item: Gpu.RenderItemHandle) void {
    _ = gpu.outlined.swapRemove(item);
}

export fn hygpuRenderableSetTransform(gpu: *Gpu, item: Gpu.RenderItemHandle, transform: hy.math.Mat4) void {
    gpu.renderableSetTransform(item, transform);
}

export fn hygpuClearSelection(gpu: *Gpu) void {
    gpu.outlined.clearRetainingCapacity();
}

export fn hygpuSpriteCreate(gpu: *Gpu, opts: Gpu.SpriteCreateOptions) Gpu.SpriteHandle {
    return gpu.spriteCreate(opts) catch |e| {
        std.log.err("sprite create failure: {}", .{e});
        return .invalid;
    };
}

export fn hygpuSpriteDestroy(gpu: *Gpu, hdl: Gpu.SpriteHandle) void {
    gpu.spriteDestroy(hdl);
}

export fn hygpuSpriteWeakPointer(gpu: *Gpu, hdl: Gpu.RenderItemHandle) ?*Gpu.GpuSprite {
    return gpu.spriteWeakPointer(hdl);
}

export fn hygpuSpriteCurrentIndex(gpu: *Gpu, hdl: *Gpu.GpuSprite) u32 {
    return gpu.spriteCurrentIndex(hdl);
}

export fn hygpuSpriteDupe(gpu: *Gpu, hdl: Gpu.SpriteHandle) Gpu.SpriteHandle {
    return gpu.spriteDupe(hdl);
}

export fn hygpuRenderableOfSprite(gpu: *Gpu, hdl: Gpu.SpriteHandle) Gpu.RenderItemHandle {
    return gpu.renderableOfSprite(hdl) catch |e| {
        std.log.err("sprite dupe failure: {}", .{e});
        return .invalid;
    };
}

export fn hygpuTextureImport(gpu: *Gpu, path: hy.ExternSlice(u8)) Gpu.TextureHandle {
    return gpu.textures.read(path.asSliceZ()) catch |e| {
        std.log.err("texture import failure: {}", .{e});
        return .invalid;
    };
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

export fn hyioQueryMousePosition(input: *Input) hy.math.Vec2 {
    return input.queryMousePosition();
}

export fn hyioQueryKey(input: *Input, button: hy.key.Keycode) bool {
    return input.queryKey(button);
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

export fn hyp2BodyGetPosition(p2d: *Phys2, body: Phys2.Body) hy.math.Vec2 {
    return p2d.bodyPosition(body);
}

export fn hyp2BodyRealPosition(body: Phys2.Body) hy.math.Vec2 {
    return @bitCast(body.getPosition());
}

export fn hyp2BodyGetType(body: Phys2.Body) Phys2.Body.Type {
    return @enumFromInt(@intFromEnum(body.getType()));
}

export fn hyp2BodySetType(body: Phys2.Body, body_type: Phys2.Body.Type) void {
    body.setType(@enumFromInt(@intFromEnum(body_type)));
}

export fn hyp2BodyGetVelocity(body: Phys2.Body) hy.math.Vec2 {
    return @bitCast(body.getLinearVelocity());
}

export fn hyp2BodySetVelocity(body: Phys2.Body, velocity: hy.math.Vec2) void {
    body.setLinearVelocity(@bitCast(velocity));
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

export fn hyp2OverlapLeaky(p2d: *Phys2, arena: hy.ExternAllocator, shape: Phys2.ShapeConfig, origin: hy.math.Vec2) hy.ExternSlice(Phys2.b2.Shape) {
    return .make(p2d.overlapLeaky(arena.allocator(), shape, origin));
}

export fn hyp2RaycastLeaky(
    p2d: *Phys2,
    arena: hy.ExternAllocator,
    opts: Phys2.RaycastOptions,
) hy.ExternSlice(Phys2.RaycastHit) {
    return .make(p2d.raycastLeaky(arena.allocator(), opts));
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

export fn hywSetRelativeMouseMode(window: *Window, on_off: bool) void {
    window.setRelativeMouseMode(on_off);
}

export fn hywDimensions(window: *Window) hy.math.Vec2 {
    return window.dimensions();
}
