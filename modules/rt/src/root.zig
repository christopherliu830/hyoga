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
    procs: *const fn (ProcTable) callconv(.c) void,
    shutdown: *const fn (*Engine, World) callconv(.c) void,
    update: *const fn (*Engine, World) callconv(.c) World,
    render: *const fn (*Engine, World) callconv(.c) void,
    afterRender: ?*const fn (*Engine, World) callconv(.c) void = null,
    reload: *const fn (*Engine, World) callconv(.c) bool,
};

pub const ProcTable = extern struct {
    hy_init: *const fn () callconv(.c) *Engine,
    hy_engine_gameAllocator: *const fn (*Engine) callconv(.c) hy.ExternAllocator,
    hy_engine_gpu: *const fn (*Engine) callconv(.c) *gfx.Gpu,
    hy_engine_phys2: *const fn (*Engine) callconv(.c) *Phys2,
    hy_engine_input: *const fn (*Engine) callconv(.c) *Input,
    hy_engine_window: *const fn (*Engine) callconv(.c) *Window,
    hy_engine_ui: *const fn (*Engine) callconv(.c) *UI,
    hy_audio_soundRead: *const fn (path: hy.ExternSliceConst(u8)) callconv(.c) Audio.Sound,
    hy_audio_soundPlay: *const fn (sound: *Audio.Sound) callconv(.c) void,
    hy_audio_soundStop: *const fn (sound: *Audio.Sound) callconv(.c) void,
    hy_gfx_clearColorSet: *const fn (gpu: *gfx.Gpu, color: hym.Vec4) callconv(.c) void,
    hy_gfx_modelImport: *const fn (gpu: *gfx.Gpu, path: hy.ExternSliceConst(u8), settings: gfx.Models.ImportSettings) callconv(.c) gfx.Model,
    hy_gfx_modelCreate: *const fn (gpu: *gfx.Gpu, opts: hy.gfx.ModelCreateOptions) callconv(.c) gfx.Model,
    hy_gfx_modelDestroy: *const fn (gpu: *gfx.Gpu, model: gfx.Model) callconv(.c) void,
    hy_gfx_modelBounds: *const fn (gpu: *gfx.Gpu, model: gfx.Model) callconv(.c) hym.AxisAligned,
    hy_gfx_modelDupe: *const fn (gpu: *gfx.Gpu, model: gfx.Model, options: gfx.Models.DupeModelOptions) callconv(.c) gfx.Model,
    hy_gfx_modelPrimitive: *const fn (gpu: *gfx.Gpu, shape: gfx.Gpu.primitives.Shape) callconv(.c) gfx.Model,
    hy_gfx_modelWaitLoad: *const fn (gpu: *gfx.Gpu, model: gfx.Model, max: u64) callconv(.c) bool,
    hy_gfx_materialLoad: *const fn (gpu: *gfx.Gpu, path: hy.ExternSliceConst(u8)) callconv(.c) gfx.MaterialHandle,
    hy_gfx_materialReload: *const fn (gpu: *gfx.Gpu, hdl: gfx.MaterialHandle) callconv(.c) void,
    hy_gfx_materialCreate: *const fn (gpu: *gfx.Gpu, type: gfx.MaterialType, tx_set: *const gfx.TextureArray) callconv(.c) gfx.MaterialHandle,
    hy_gfx_materialDestroy: *const fn (gpu: *gfx.Gpu, hdl: gfx.MaterialHandle) callconv(.c) void,
    hy_gfx_renderableAdd: *const fn (gpu: *gfx.Gpu, opts: gfx.Gpu.AddRenderableOptions) callconv(.c) gfx.Renderable,
    hy_gfx_renderableRemove: *const fn (gpu: *gfx.Gpu, hdl: gfx.Renderable) callconv(.c) void,
    hy_gfx_renderableTransformSet: *const fn (gpu: *gfx.Gpu, hdl: gfx.Renderable, transform: hym.Mat4) callconv(.c) void,
    hy_gfx_spriteMakeRenderable: *const fn (gpu: *gfx.Gpu, hdl: gfx.SpriteHandle) callconv(.c) gfx.Renderable,
    hy_gfx_spriteCreate: *const fn (gpu: *gfx.Gpu, opts: gfx.Gpu.SpriteCreateOptions) callconv(.c) gfx.SpriteHandle,
    hy_gfx_spriteDestroy: *const fn (gpu: *gfx.Gpu, hdl: gfx.SpriteHandle) callconv(.c) void,
    hy_gfx_spriteWeakPtr: *const fn (gpu: *gfx.Gpu, hdl: gfx.SpriteHandle) callconv(.c) ?*gfx.Sprite,
    hy_gfx_spriteRenderableWeakPtr: *const fn (gpu: *gfx.Gpu, hdl: gfx.Renderable) callconv(.c) ?*gfx.Sprite,
    hy_gfx_spriteCurrentAnimationFrame: *const fn (gpu: *gfx.Gpu, hdl: *gfx.Sprite) callconv(.c) u32,
    hy_gfx_spriteDupe: *const fn (gpu: *gfx.Gpu, hdl: gfx.SpriteHandle) callconv(.c) gfx.SpriteHandle,
    hy_gfx_textureImport: *const fn (gpu: *gfx.Gpu, path: hy.ExternSliceConst(u8)) callconv(.c) gfx.TextureHandle,
    hy_gfx_passCreate: *const fn (gpu: *gfx.Gpu, opts: hy.gfx.PassCreateOptions) callconv(.c) gfx.PassHandle,
    hy_gfx_passDestroy: *const fn (gpu: *gfx.Gpu, hdl: gfx.PassHandle) callconv(.c) void,
    hy_gfx_passAdd: *const fn (gpu: *gfx.Gpu, opts: gfx.Gpu.PassAddOptions) callconv(.c) gfx.Renderable,
    hy_gfx_passClear: *const fn (gpu: *gfx.Gpu, hdl: gfx.PassHandle) callconv(.c) void,
    hy_gfx_immediateDraw: *const fn (gpu: *gfx.Gpu, verts: hy.ExternSliceConst(gfx.UIVertex), idxs: hy.ExternSliceConst(u32), transform: hym.Mat4, material_hdl: gfx.MaterialHandle) callconv(.c) void,
    hy_io_reset: *const fn (input: *Input) callconv(.c) void,
    hy_io_mouse: *const fn (input: *Input, button: hy.MouseButton) callconv(.c) bool,
    hy_io_mousePosition: *const fn (input: *Input) callconv(.c) hym.Vec2,
    hy_io_key: *const fn (input: *Input, button: hy.Keycode) callconv(.c) bool,
    hy_io_bindPoll: *const fn (input: *Input, id: u32, on: hy.input.OnFlags, button: hy.Keycode) callconv(.c) void,
    hy_io_bindPollMouse: *const fn (input: *Input, id: u32, on: hy.input.OnFlags, mouse: hy.MouseButton) callconv(.c) void,
    hy_io_eventPump: *const fn (input: *Input) callconv(.c) hy.ExternSliceConst(u32),
    hy_io_eventClear: *const fn (input: *Input, events: hy.ExternSliceConst(u32)) callconv(.c) void,
    hy_p2_bodyAdd: *const fn (world: *Phys2, opts: Phys2.BodyAddOptions) callconv(.c) Phys2.Body,
    hy_p2_bodyDestroy: *const fn (body: Phys2.Body) callconv(.c) void,
    hy_p2_bodyUserData: *const fn (body: Phys2.Body) callconv(.c) ?*anyopaque,
    hy_p2_bodyPosition: *const fn (world: *Phys2, body: Phys2.Body) callconv(.c) hym.Vec2,
    hy_p2_bodyPositionSet: *const fn (body: Phys2.Body, pos: hym.Vec2) callconv(.c) void,
    hy_p2_bodyPositionReal: *const fn (body: Phys2.Body) callconv(.c) hym.Vec2,
    hy_p2_bodyType: *const fn (body: Phys2.Body) callconv(.c) Phys2.Body.Type,
    hy_p2_bodyTypeSet: *const fn (body: Phys2.Body, type: Phys2.Body.Type) callconv(.c) void,
    hy_p2_bodyVelocity: *const fn (body: Phys2.Body) callconv(.c) hym.Vec2,
    hy_p2_bodyVelocitySet: *const fn (body: Phys2.Body, velocity: hym.Vec2) callconv(.c) void,
    hy_p2_shapeBody: *const fn (shape: Phys2.b2.Shape) callconv(.c) Phys2.Body,
    hy_p2_shapeExtra: *const fn (shape: Phys2.b2.Shape) callconv(.c) Phys2.ShapeExtra,
    hy_p2_eventReset: *const fn (world: *Phys2) callconv(.c) void,
    hy_p2_eventRegister: *const fn (world: *Phys2, body: Phys2.Body, cb: *hy.closure.Runnable(Phys2.HitEvent)) callconv(.c) void,
    hy_p2_eventDeregister: *const fn (world: *Phys2, body: Phys2.Body, cb: *hy.closure.Runnable(Phys2.HitEvent)) callconv(.c) void,
    hy_p2_eventDeregisterAll: *const fn (world: *Phys2, body: Phys2.Body) callconv(.c) void,
    hy_p2_overlapLeaky: *const fn (world: *Phys2, arena: hy.ExternAllocator, shape: Phys2.ShapeConfig, origin: hym.Vec2) callconv(.c) hy.ExternSlice(Phys2.b2.Shape),
    hy_p2_castRayLeaky: *const fn (world: *Phys2, arena: hy.ExternAllocator, opts: Phys2.RaycastOptions) callconv(.c) hy.ExternSlice(Phys2.RaycastHit),
    hy_p2_castCircleLeaky: *const fn (world: *Phys2, arena: hy.ExternAllocator, opts: Phys2.CastCircleOptions) callconv(.c) hy.ExternSlice(Phys2.RaycastHit),
    hy_ui_globalState: *const fn (ctx: *UI) callconv(.c) UI.GlobalState,
    hy_ui_inputState: *const fn (ctx: *UI) callconv(.c) UI.InputState,
    hy_win_relativeMouseMode: *const fn (window: *Window, toggle: bool) callconv(.c) void,
    hy_win_dimensions: *const fn (window: *Window) callconv(.c) hym.Vec2,
    hy_win_projectionMatrix: *const fn (window: *Window) callconv(.c) hym.Mat4,
};

pub fn procs() ProcTable {
    return .{
        .hy_init = hy_init,
        .hy_engine_gameAllocator = hy_engine_gameAllocator,
        .hy_engine_gpu = hy_engine_gpu,
        .hy_engine_input = hy_engine_input,
        .hy_engine_phys2 = hy_engine_phys2,
        .hy_engine_ui = hy_engine_ui,
        .hy_engine_window = hy_engine_window,
        .hy_audio_soundPlay = hy_audio_soundPlay,
        .hy_audio_soundRead = hy_audio_soundRead,
        .hy_audio_soundStop = hy_audio_soundStop,
        .hy_gfx_clearColorSet = hy_gfx_clearColorSet,
        .hy_gfx_modelImport = hy_gfx_modelImport,
        .hy_gfx_modelCreate = hy_gfx_modelCreate,
        .hy_gfx_modelDestroy = hy_gfx_modelDestroy,
        .hy_gfx_modelBounds = hy_gfx_modelBounds,
        .hy_gfx_modelDupe = hy_gfx_modelDupe,
        .hy_gfx_modelPrimitive = hy_gfx_modelPrimitive,
        .hy_gfx_modelWaitLoad = hy_gfx_modelWaitLoad,
        .hy_gfx_materialLoad = hy_gfx_materialLoad,
        .hy_gfx_materialReload = hy_gfx_materialReload,
        .hy_gfx_materialCreate = hy_gfx_materialCreate,
        .hy_gfx_materialDestroy = hy_gfx_materialDestroy,
        .hy_gfx_renderableAdd = hy_gfx_renderableAdd,
        .hy_gfx_renderableRemove = hy_gfx_renderableDestroy,
        .hy_gfx_renderableTransformSet = hy_gfx_renderableTransformSet,
        .hy_gfx_spriteMakeRenderable = hy_gfx_spriteMakeRenderable,
        .hy_gfx_spriteCreate = hy_gfx_spriteCreate,
        .hy_gfx_spriteDestroy = hy_gfx_spriteDestroy,
        .hy_gfx_spriteWeakPtr = hy_gfx_spriteWeakPtr,
        .hy_gfx_spriteRenderableWeakPtr = hy_gfx_spriteRenderableWeakPtr,
        .hy_gfx_spriteCurrentAnimationFrame = hy_gfx_spriteCurrentAnimationFrame,
        .hy_gfx_spriteDupe = hy_gfx_spriteDupe,
        .hy_gfx_textureImport = hy_gfx_textureImport,
        .hy_gfx_passCreate = hy_gfx_passCreate,
        .hy_gfx_passDestroy = hy_gfx_passDestroy,
        .hy_gfx_passAdd = hy_gfx_passAdd,
        .hy_gfx_passClear = hy_gfx_passClear,
        .hy_gfx_immediateDraw = hy_gfx_immediateDraw,
        .hy_io_reset = hy_io_reset,
        .hy_io_mouse = hy_io_mouse,
        .hy_io_mousePosition = hy_io_mousePosition,
        .hy_io_key = hy_io_key,
        .hy_io_bindPoll = hy_io_bindPoll,
        .hy_io_bindPollMouse = hy_io_bindPollMouse,
        .hy_io_eventPump = hy_io_eventPump,
        .hy_io_eventClear = hy_io_eventClear,
        .hy_p2_bodyAdd = hyp2BodyAdd,
        .hy_p2_bodyDestroy = hyp2BodyDestroy,
        .hy_p2_bodyUserData = hyp2BodyUserData,
        .hy_p2_bodyPosition = hyp2BodyGetPosition,
        .hy_p2_bodyPositionSet = hyp2BodyPositionSet,
        .hy_p2_bodyPositionReal = hyp2BodyRealPosition,
        .hy_p2_bodyType = hyp2BodyGetType,
        .hy_p2_bodyTypeSet = hyp2BodySetType,
        .hy_p2_bodyVelocity = hyp2BodyGetVelocity,
        .hy_p2_bodyVelocitySet = hyp2BodyVelocitySet,
        .hy_p2_shapeBody = hyp2ShapeBody,
        .hy_p2_shapeExtra = hyp2ShapeExtra,
        .hy_p2_eventReset = hyp2EventsReset,
        .hy_p2_eventRegister = hyp2HitEventRegister,
        .hy_p2_eventDeregister = hyp2HitEventDeregister,
        .hy_p2_eventDeregisterAll = hyp2HitEventDeregisterAll,
        .hy_p2_overlapLeaky = hyp2OverlapLeaky,
        .hy_p2_castRayLeaky = hyp2RaycastLeaky,
        .hy_p2_castCircleLeaky = hyp2CastCircleLeaky,
        .hy_ui_globalState = hyuiGetGlobalState,
        .hy_ui_inputState = hyuiInputState,
        .hy_win_relativeMouseMode = hywSetRelativeMouseMode,
        .hy_win_dimensions = hywDimensions,
        .hy_win_projectionMatrix = hywProjectionMatrix,
    };
}

pub fn init() *Engine {
    return Engine.init() catch |err| {
        std.debug.panic("Engine init failure: {}", .{err});
    };
}

fn hy_init() callconv(.c) *Engine {
    return init();
}

fn hy_engine_gameAllocator(engine: *Engine) callconv(.c) hy.ExternAllocator {
    return engine.gameAllocator();
}

fn hy_engine_gpu(engine: *Engine) callconv(.c) *gfx.Gpu {
    return engine.gpu;
}

fn hy_engine_input(engine: *Engine) callconv(.c) *Input {
    return &engine.input;
}

fn hy_engine_phys2(engine: *Engine) callconv(.c) *Phys2 {
    return &engine.physics;
}

fn hy_engine_ui(engine: *Engine) callconv(.c) *UI {
    return &engine.ui;
}

fn hy_engine_window(engine: *Engine) callconv(.c) *Window {
    return &engine.window;
}

fn hy_audio_soundRead(path: hy.ExternSliceConst(u8)) callconv(.c) Audio.Sound {
    return Engine.Audio.read(path.asSliceZ());
}

fn hy_audio_soundPlay(sound: *Audio.Sound) callconv(.c) void {
    sound.play();
}

fn hy_audio_soundStop(sound: *Audio.Sound) callconv(.c) void {
    sound.stop();
}

fn hy_gfx_clearColorSet(gpu: *gfx.Gpu, color: hym.Vec4) callconv(.c) void {
    gpu.clearColorSet(color);
}

fn hy_gfx_modelImport(gpu: *gfx.Gpu, path: hy.ExternSliceConst(u8), settings: gfx.Models.ImportSettings) callconv(.c) gfx.Model {
    return gpu.importModel(path.asSliceZ(), settings) catch |e| {
        std.log.err("import model failure: {}", .{e});
        return .none;
    };
}

fn hy_gfx_modelCreate(gpu: *gfx.Gpu, opts: hy.gfx.ModelCreateOptions) callconv(.c) gfx.Model {
    return gpu.models.create(.{
        .gpu = gpu,
        .verts = @ptrCast(@alignCast(opts.verts.asSlice())),
        .indices = opts.indices.asSlice(),
        .material = @bitCast(@intFromEnum(opts.material)),
        .transform = opts.transform,
    }) catch unreachable;
}

fn hy_gfx_modelDestroy(gpu: *gfx.Gpu, model: gfx.Model) callconv(.c) void {
    gpu.models.remove(&gpu.buffer_allocator, model);
}

fn hy_gfx_modelBounds(gpu: *gfx.Gpu, model: gfx.Model) callconv(.c) hym.AxisAligned {
    if (gpu.models.get(model)) |m| {
        return m.bounds;
    } else |e| {
        std.log.err("get model failure: {}", .{e});
        return .{};
    }
}

fn hy_gfx_modelDupe(gpu: *gfx.Gpu, model: gfx.Model, options: gfx.Models.DupeModelOptions) callconv(.c) gfx.Model {
    return gpu.models.dupe(&gpu.buffer_allocator, model, options) catch |e| {
        std.log.err("dupe model failure: {}", .{e});
        return .invalid;
    };
}

fn hy_gfx_modelPrimitive(gpu: *gfx.Gpu, shape: gfx.primitives.Shape) callconv(.c) gfx.Model {
    return gpu.modelPrimitive(shape);
}

fn hy_gfx_modelWaitLoad(gpu: *gfx.Gpu, model: gfx.Model, max: u64) callconv(.c) bool {
    return gpu.models.waitLoad(model, max);
}

fn hy_gfx_materialLoad(gpu: *gfx.Gpu, path: hy.ExternSliceConst(u8)) callconv(.c) gfx.MaterialHandle {
    return gpu.materialLoad(path.asSliceZ()) catch |e| {
        std.log.err("Error loading material: {}\n", .{e});
        return .invalid;
    };
}

fn hy_gfx_materialReload(gpu: *gfx.Gpu, hdl: gfx.MaterialHandle) callconv(.c) void {
    gpu.materials.reload(hdl) catch |e| {
        std.log.err("Error reloading material: {}\n", .{e});
    };
}

fn hy_gfx_materialCreate(gpu: *gfx.Gpu, mt_type: gfx.MaterialType, tx_set: *const gfx.TextureArray) callconv(.c) gfx.MaterialHandle {
    return gpu.materialCreate(mt_type, tx_set);
}

fn hy_gfx_materialDestroy(gpu: *gfx.Gpu, hdl: gfx.MaterialHandle) callconv(.c) void {
    gpu.materialDestroy(hdl);
}

fn hy_gfx_renderableAdd(gpu: *gfx.Gpu, options: gfx.Gpu.AddRenderableOptions) callconv(.c) gfx.Renderable {
    return gpu.renderableAdd(options) catch |e| {
        std.log.err("add renderable failure: {}", .{e});
        return .{
            .pass = .default,
            .index = .none,
        };
    };
}

fn hy_gfx_renderableDestroy(gpu: *gfx.Gpu, item: gfx.Renderable) callconv(.c) void {
    gpu.renderableDestroy(item);
}

fn hy_gfx_renderableTransformSet(gpu: *gfx.Gpu, item: gfx.Renderable, transform: hym.Mat4) callconv(.c) void {
    gpu.renderableSetTransform(item, transform);
}

fn hy_gfx_spriteMakeRenderable(gpu: *gfx.Gpu, hdl: gfx.SpriteHandle) callconv(.c) gfx.Renderable {
    return gpu.renderableOfSprite(hdl) catch |e| {
        std.log.err("sprite dupe failure: {}", .{e});
        return .{
            .pass = .default,
            .index = .none,
        };
    };
}

fn hy_gfx_spriteCreate(gpu: *gfx.Gpu, opts: gfx.Gpu.SpriteCreateOptions) callconv(.c) gfx.SpriteHandle {
    return gpu.spriteCreate(opts) catch |e| {
        std.log.err("sprite create failure: {}", .{e});
        return .invalid;
    };
}

fn hy_gfx_spriteDestroy(gpu: *gfx.Gpu, hdl: gfx.SpriteHandle) callconv(.c) void {
    gpu.spriteDestroy(hdl);
}

fn hy_gfx_spriteWeakPtr(gpu: *gfx.Gpu, hdl: gfx.SpriteHandle) callconv(.c) ?*gfx.Gpu.GpuSprite {
    return gpu.spriteWeakPtr(hdl);
}

fn hy_gfx_spriteRenderableWeakPtr(gpu: *gfx.Gpu, hdl: gfx.Renderable) callconv(.c) ?*gfx.Gpu.GpuSprite {
    return gpu.spriteRenderableWeakPtr(hdl);
}

fn hy_gfx_spriteCurrentAnimationFrame(gpu: *gfx.Gpu, hdl: *gfx.Gpu.GpuSprite) callconv(.c) u32 {
    return gpu.spriteCurrentAnimationFrame(hdl);
}

fn hy_gfx_spriteDupe(gpu: *gfx.Gpu, hdl: gfx.SpriteHandle) callconv(.c) gfx.SpriteHandle {
    return gpu.spriteDupe(hdl);
}

fn hy_gfx_textureImport(gpu: *gfx.Gpu, path: hy.ExternSliceConst(u8)) callconv(.c) gfx.TextureHandle {
    return gpu.textures.read(path.asSliceZ()) catch |e| {
        std.log.err("texture import failure: {}", .{e});
        return .invalid;
    };
}

fn hy_gfx_passCreate(gpu: *gfx.Gpu, opts: hy.gfx.PassCreateOptions) callconv(.c) gfx.PassHandle {
    return gpu.passCreate(opts);
}

fn hy_gfx_passDestroy(gpu: *gfx.Gpu, hdl: gfx.PassHandle) callconv(.c) void {
    return gpu.passDestroy(hdl);
}

fn hy_gfx_passAdd(gpu: *gfx.Gpu, opts: gfx.Gpu.PassAddOptions) callconv(.c) gfx.Renderable {
    return gpu.passAdd(opts);
}

fn hy_gfx_passClear(gpu: *gfx.Gpu, hdl: gfx.PassHandle) callconv(.c) void {
    return gpu.passClear(hdl);
}

fn hy_gfx_immediateDraw(
    gpu: *gfx.Gpu,
    verts: hy.ExternSliceConst(gfx.UIVertex),
    indices: hy.ExternSliceConst(u32),
    transform: hym.Mat4,
    material_hdl: gfx.MaterialHandle,
) callconv(.c) void {
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

fn hyioReset(input: *Input) callconv(.c) void {
    input.reset();
}

fn hyioCreateGroup(input: *Input) callconv(.c) Input.Group.Handle {
    return input.createGroup();
}

fn hyioGetGroup(input: *Input, hdl: Input.Group.Handle) callconv(.c) Input.Group.Handle {
    return input.getGroup(hdl);
}

fn hyioGroupDestroy(input: *Input, hdl: Input.Group.Handle) callconv(.c) void {
    return input.groupDestroy(hdl);
}

fn hyioSetGroupEnabled(input: *Input, group: Input.Group.Handle, enabled: bool) callconv(.c) void {
    input.setGroupEnabled(group, enabled);
}

fn hyioBind(
    input: *Input,
    group: Input.Group.Handle,
    options: Input.BindOptions,
    delegate: *hy.closure.Runnable(anyopaque),
) callconv(.c) void {
    input.bind(group, options, delegate) catch |e| {
        std.log.err("Could not bind delegate: {}", .{e});
    };
}

fn hy_io_reset(input: *Input) callconv(.c) void {
    input.reset();
}

fn hy_io_mouse(input: *Input, button: hy.key.MouseButton) callconv(.c) bool {
    return input.queryMouse(button);
}

fn hy_io_mousePosition(input: *Input) callconv(.c) hym.Vec2 {
    return input.queryMousePosition();
}

fn hy_io_key(input: *Input, button: hy.key.Keycode) callconv(.c) bool {
    return input.queryKey(button);
}

fn hy_io_bindPoll(input: *Input, id: u32, on: hy.input.OnFlags, button: hy.key.Keycode) callconv(.c) void {
    input.bindPoll(id, on, button) catch |err| {
        std.log.err("input bind failure: {}", .{err});
    };
}

fn hy_io_bindPollMouse(input: *Input, id: u32, on: hy.input.OnFlags, mouse: hy.MouseButton) callconv(.c) void {
    input.bindPollMouse(id, on, mouse) catch |err| {
        std.log.err("input bind failure: {}", .{err});
    };
}

fn hy_io_eventPump(input: *Input) callconv(.c) hy.ExternSliceConst(u32) {
    const events = input.eventPump() catch |err| {
        std.log.err("input event pump failure: {}", .{err});
        return .from(&.{});
    };
    return .from(events);
}

fn hy_io_eventClear(input: *Input, events: hy.ExternSliceConst(u32)) callconv(.c) void {
    input.eventClear(events.asSlice());
}

fn hyp2BodyAdd(p2d: *Phys2, opts: Phys2.BodyAddOptions) callconv(.c) Phys2.Body {
    return p2d.addBody(opts);
}

fn hyp2BodyDestroy(body: Phys2.Body) callconv(.c) void {
    return body.destroy();
}

fn hyp2BodyUserData(body: Phys2.Body) callconv(.c) ?*anyopaque {
    return body.getUserData();
}

fn hyp2BodyGetPosition(p2d: *Phys2, body: Phys2.Body) callconv(.c) hym.Vec2 {
    return p2d.bodyPosition(body);
}

fn hyp2BodyPositionSet(body: Phys2.Body, pos: hym.Vec2) callconv(.c) void {
    Phys2.bodyPositionSet(body, pos);
}

fn hyp2BodyRealPosition(body: Phys2.Body) callconv(.c) hym.Vec2 {
    return @bitCast(body.getPosition());
}

fn hyp2BodyGetType(body: Phys2.Body) callconv(.c) Phys2.Body.Type {
    return @enumFromInt(@intFromEnum(body.getType()));
}

fn hyp2BodySetType(body: Phys2.Body, body_type: Phys2.Body.Type) callconv(.c) void {
    body.setType(@enumFromInt(@intFromEnum(body_type)));
}

fn hyp2BodyGetVelocity(body: Phys2.Body) callconv(.c) hym.Vec2 {
    return @bitCast(body.getLinearVelocity());
}

fn hyp2BodyVelocitySet(body: Phys2.Body, velocity: hym.Vec2) callconv(.c) void {
    body.setLinearVelocity(@bitCast(velocity));
}

fn hyp2ShapeExtra(shape: Phys2.b2.Shape) callconv(.c) Phys2.ShapeExtra {
    return Phys2.shapeExtra(shape);
}

fn hyp2EventsReset(p2d: *Phys2) callconv(.c) void {
    p2d.eventsReset();
}

fn hyp2HitEventRegister(p2d: *Phys2, body: Phys2.Body, cb: *hy.closure.Runnable(Phys2.HitEvent)) callconv(.c) void {
    p2d.hitEventRegister(body, cb);
}

fn hyp2HitEventDeregister(
    p2d: *Phys2,
    body: Phys2.Body,
    cb: *hy.closure.Runnable(Phys2.HitEvent),
) callconv(.c) void {
    p2d.hitEventDeregister(body, cb);
}

fn hyp2HitEventDeregisterAll(
    p2d: *Phys2,
    body: Phys2.Body,
) callconv(.c) void {
    p2d.hitEventDeregisterAll(body);
}

fn hyp2OverlapLeaky(p2d: *Phys2, arena: hy.ExternAllocator, shape: Phys2.ShapeConfig, origin: hym.Vec2) callconv(.c) hy.ExternSlice(Phys2.b2.Shape) {
    return .from(p2d.overlapLeaky(arena.allocator(), shape, origin));
}

fn hyp2RaycastLeaky(
    p2d: *Phys2,
    arena: hy.ExternAllocator,
    opts: Phys2.RaycastOptions,
) callconv(.c) hy.ExternSlice(Phys2.RaycastHit) {
    return .from(p2d.raycastLeaky(arena.allocator(), opts));
}

fn hyp2CastCircleLeaky(p2d: *Phys2, arena: hy.ExternAllocator, opts: Phys2.CastCircleOptions) callconv(.c) hy.ExternSlice(Phys2.RaycastHit) {
    return .from(p2d.castCircleLeaky(arena.allocator(), opts));
}

fn hyp2ShapeBody(shape: Phys2.b2.Shape) callconv(.c) Phys2.Body {
    return shape.getBody();
}

fn hyuiGetGlobalState(ui: *UI) callconv(.c) UI.GlobalState {
    return ui.getGlobalState();
}

fn hyuiInputState(ui: *UI) callconv(.c) UI.InputState {
    return ui.inputState();
}

fn hywSetRelativeMouseMode(window: *Window, on_off: bool) callconv(.c) void {
    window.setRelativeMouseMode(on_off);
}

fn hywDimensions(window: *Window) callconv(.c) hym.Vec2 {
    return window.dimensions();
}

fn hywProjectionMatrix(window: *Window) callconv(.c) hym.Mat4 {
    return window.projectionMatrix();
}
