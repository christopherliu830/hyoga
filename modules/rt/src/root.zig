pub const proc_table = @import("generated/proc_table.zig");

const std = @import("std");
const hy = @import("hyoga");
const hym = hy.math;

const Engine = @import("Engine.zig");
const gfx = @import("graphics/root.zig");

const ProcTable = proc_table.ProcTable;

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

pub fn init() *Engine {
    return Engine.init() catch |err| {
        std.debug.panic("Engine init failure: {}", .{err});
    };
}

pub fn hy_init() callconv(.c) *hy.Engine {
    return @ptrCast(init());
}

pub fn hy_engine_gameAllocator(engine: *hy.Engine) callconv(.c) hy.ExternAllocator {
    const rt_engine: *Engine = @ptrCast(@alignCast(engine));
    return rt_engine.gameAllocator();
}

pub fn hy_engine_gpu(engine: *hy.Engine) callconv(.c) *hy.gfx.Gpu {
    const rt_engine: *Engine = @ptrCast(@alignCast(engine));
    return @ptrCast(rt_engine.gpu);
}

pub fn hy_engine_input(engine: *hy.Engine) callconv(.c) *hy.input.Context {
    const rt_engine: *Engine = @ptrCast(@alignCast(engine));
    return @ptrCast(&rt_engine.input);
}

pub fn hy_engine_phys2(engine: *hy.Engine) callconv(.c) *hy.p2.Context {
    const rt_engine: *Engine = @ptrCast(@alignCast(engine));
    return @ptrCast(&rt_engine.physics);
}

pub fn hy_engine_ui(engine: *hy.Engine) callconv(.c) *hy.UI {
    const rt_engine: *Engine = @ptrCast(@alignCast(engine));
    return @ptrCast(&rt_engine.ui);
}

pub fn hy_engine_window(engine: *hy.Engine) callconv(.c) *hy.Window {
    const rt_engine: *Engine = @ptrCast(@alignCast(engine));
    return @ptrCast(&rt_engine.window);
}

pub fn hy_audio_soundRead(path: hy.ExternSliceConst(u8)) callconv(.c) hy.Audio.Sound {
    const rt_sound = Engine.Audio.read(path.asSliceZ());
    return .{
        .chunk = rt_sound.chunk,
        .channel = @intFromEnum(rt_sound.current_channel),
    };
}

pub fn hy_audio_soundPlay(sound: *hy.Audio.Sound) callconv(.c) void {
    Audio.Sound.rtCast(sound).play();
}

pub fn hy_audio_soundStop(sound: *hy.Audio.Sound) callconv(.c) void {
    Audio.Sound.rtCast(sound).stop();
}

pub fn hy_gfx_clearColorSet(gpu: *hy.gfx.Gpu, color: hym.Vec4) callconv(.c) void {
    const rt_gpu: *gfx.Gpu = @ptrCast(@alignCast(gpu));
    rt_gpu.clearColorSet(color);
}

pub fn hy_gfx_modelImport(gpu: *hy.gfx.Gpu, path: hy.ExternSliceConst(u8), settings: hy.gfx.ImportSettings) callconv(.c) hy.gfx.Model {
    const rt_gpu: *gfx.Gpu = @ptrCast(@alignCast(gpu));
    const model = rt_gpu.importModel(path.asSliceZ(), settings) catch |e| {
        std.log.err("import model failure: {}", .{e});
        return .none;
    };
    return @enumFromInt(model.int());
}

pub fn hy_gfx_modelCreate(gpu: *hy.gfx.Gpu, opts: hy.gfx.ModelCreateOptions) callconv(.c) hy.gfx.Model {
    const rt_gpu: *gfx.Gpu = @ptrCast(@alignCast(gpu));
    const model = rt_gpu.models.create(.{
        .gpu = rt_gpu,
        .verts = @ptrCast(@alignCast(opts.verts.asSlice())),
        .indices = opts.indices.asSlice(),
        .material = @bitCast(@intFromEnum(opts.material)),
        .transform = opts.transform,
    }) catch unreachable;
    return @enumFromInt(model.int());
}

pub fn hy_gfx_modelDestroy(gpu: *hy.gfx.Gpu, model: hy.gfx.Model) callconv(.c) void {
    const rt_gpu: *gfx.Gpu = @ptrCast(@alignCast(gpu));
    rt_gpu.models.remove(&rt_gpu.buffer_allocator, @bitCast(@intFromEnum(model)));
}

pub fn hy_gfx_modelBounds(gpu: *hy.gfx.Gpu, model: hy.gfx.Model) callconv(.c) hym.AxisAligned {
    const rt_gpu: *gfx.Gpu = @ptrCast(@alignCast(gpu));
    if (rt_gpu.models.get(@bitCast(@intFromEnum(model)))) |m| {
        return m.bounds;
    } else |e| {
        std.log.err("get model failure: {}", .{e});
        return .{};
    }
}

pub fn hy_gfx_modelDupe(gpu: *hy.gfx.Gpu, original_model: hy.gfx.Model, options: hy.gfx.ModelDupeOptions) callconv(.c) hy.gfx.Model {
    const rt_gpu: *gfx.Gpu = @ptrCast(@alignCast(gpu));
    const model = rt_gpu.models.dupe(
        &rt_gpu.buffer_allocator,
        @bitCast(@intFromEnum(original_model)),
        @bitCast(options),
    ) catch |e| {
        std.log.err("dupe model failure: {}", .{e});
        return .none;
    };
    return @enumFromInt(model.int());
}

pub fn hy_gfx_modelPrimitive(gpu: *hy.gfx.Gpu, shape: hy.gfx.PrimitiveShape) callconv(.c) hy.gfx.Model {
    const rt_gpu: *gfx.Gpu = @ptrCast(@alignCast(gpu));
    return @enumFromInt(rt_gpu.modelPrimitive(@enumFromInt(@intFromEnum(shape))).int());
}

pub fn hy_gfx_modelWaitLoad(gpu: *hy.gfx.Gpu, model: hy.gfx.Model, max: u64) callconv(.c) bool {
    const rt_gpu: *gfx.Gpu = @ptrCast(@alignCast(gpu));
    return rt_gpu.models.waitLoad(@bitCast(@intFromEnum(model)), max);
}

pub fn hy_gfx_materialLoad(gpu: *hy.gfx.Gpu, path: hy.ExternSliceConst(u8)) callconv(.c) hy.gfx.MaterialHandle {
    const rt_gpu: *gfx.Gpu = @ptrCast(@alignCast(gpu));
    const hdl = rt_gpu.materialLoad(path.asSliceZ()) catch |e| {
        std.log.err("Error loading material: {}\n", .{e});
        return .none;
    };
    return @enumFromInt(hdl.int());
}

pub fn hy_gfx_materialReload(gpu: *hy.gfx.Gpu, hdl: hy.gfx.MaterialHandle) callconv(.c) void {
    const rt_gpu: *gfx.Gpu = @ptrCast(@alignCast(gpu));
    rt_gpu.materials.reload(@bitCast(@intFromEnum(hdl))) catch |e| {
        std.log.err("Error reloading material: {}\n", .{e});
    };
}

pub fn hy_gfx_materialCreate(gpu: *hy.gfx.Gpu, mt_type: hy.gfx.MaterialType, tx_set: *const hy.gfx.TextureArray) callconv(.c) hy.gfx.MaterialHandle {
    const rt_gpu: *gfx.Gpu = @ptrCast(@alignCast(gpu));
    const hdl = rt_gpu.materialCreate(@enumFromInt(@intFromEnum(mt_type)), @ptrCast(tx_set));
    return @enumFromInt(hdl.int());
}

pub fn hy_gfx_materialDestroy(gpu: *hy.gfx.Gpu, hdl: hy.gfx.MaterialHandle) callconv(.c) void {
    const rt_gpu: *gfx.Gpu = @ptrCast(@alignCast(gpu));
    rt_gpu.materialDestroy(@bitCast(@intFromEnum(hdl)));
}

pub fn hy_gfx_renderableAdd(gpu: *hy.gfx.Gpu, options: hy.gfx.AddRenderableOptions) callconv(.c) hy.gfx.Renderable {
    const rt_gpu: *gfx.Gpu = @ptrCast(@alignCast(gpu));
    const renderable = rt_gpu.renderableAdd(@bitCast(options)) catch |e| {
        std.log.err("add renderable failure: {}", .{e});
        return .none;
    };
    return @bitCast(renderable);
}

pub fn hy_gfx_renderableRemove(gpu: *hy.gfx.Gpu, item: hy.gfx.Renderable) callconv(.c) void {
    const rt_gpu: *gfx.Gpu = @ptrCast(@alignCast(gpu));
    rt_gpu.renderableDestroy(@bitCast(item));
}

pub fn hy_gfx_renderableTransformSet(gpu: *hy.gfx.Gpu, item: hy.gfx.Renderable, transform: hym.Mat4) callconv(.c) void {
    const rt_gpu: *gfx.Gpu = @ptrCast(@alignCast(gpu));
    rt_gpu.renderableSetTransform(@bitCast(item), transform);
}

pub fn hy_gfx_spriteMakeRenderable(gpu: *hy.gfx.Gpu, hdl: hy.gfx.Sprite.Handle) callconv(.c) hy.gfx.Renderable {
    const rt_gpu: *gfx.Gpu = @ptrCast(@alignCast(gpu));
    const renderable = rt_gpu.renderableOfSprite(@bitCast(@intFromEnum(hdl))) catch |e| {
        std.log.err("sprite dupe failure: {}", .{e});
        return .none;
    };
    return @bitCast(renderable);
}

pub fn hy_gfx_spriteCreate(gpu: *hy.gfx.Gpu, opts: hy.gfx.SpriteCreateOptions) callconv(.c) hy.gfx.Sprite.Handle {
    const rt_gpu: *gfx.Gpu = @ptrCast(@alignCast(gpu));
    const hdl = rt_gpu.spriteCreate(@bitCast(opts)) catch |e| {
        std.log.err("sprite create failure: {}", .{e});
        return .none;
    };

    return @enumFromInt(hdl.int());
}

pub fn hy_gfx_spriteDestroy(gpu: *hy.gfx.Gpu, hdl: hy.gfx.Sprite.Handle) callconv(.c) void {
    const rt_gpu: *gfx.Gpu = @ptrCast(@alignCast(gpu));
    rt_gpu.spriteDestroy(@bitCast(@intFromEnum(hdl)));
}

pub fn hy_gfx_spriteWeakPtr(gpu: *hy.gfx.Gpu, hdl: hy.gfx.Sprite.Handle) callconv(.c) ?*hy.gfx.Sprite {
    const rt_gpu: *gfx.Gpu = @ptrCast(@alignCast(gpu));
    return @ptrCast(rt_gpu.spriteWeakPtr(@bitCast(@intFromEnum(hdl))));
}

pub fn hy_gfx_spriteRenderableWeakPtr(gpu: *hy.gfx.Gpu, hdl: hy.gfx.Renderable) callconv(.c) ?*hy.gfx.Sprite {
    const rt_gpu: *gfx.Gpu = @ptrCast(@alignCast(gpu));
    return @ptrCast(rt_gpu.spriteRenderableWeakPtr(@bitCast(hdl)));
}

pub fn hy_gfx_spriteCurrentAnimationFrame(gpu: *hy.gfx.Gpu, sprite: *hy.gfx.Sprite) callconv(.c) u32 {
    const rt_gpu: *gfx.Gpu = @ptrCast(@alignCast(gpu));
    return rt_gpu.spriteCurrentAnimationFrame(@ptrCast(sprite));
}

pub fn hy_gfx_spriteDupe(gpu: *hy.gfx.Gpu, hdl: hy.gfx.Sprite.Handle) callconv(.c) hy.gfx.Sprite.Handle {
    const rt_gpu: *gfx.Gpu = @ptrCast(@alignCast(gpu));
    const dupe_hdl = rt_gpu.spriteDupe(@bitCast(@intFromEnum(hdl)));
    return @enumFromInt(dupe_hdl.int());
}

pub fn hy_gfx_textureImport(gpu: *hy.gfx.Gpu, path: hy.ExternSliceConst(u8)) callconv(.c) hy.gfx.TextureHandle {
    const rt_gpu: *gfx.Gpu = @ptrCast(@alignCast(gpu));
    const int = rt_gpu.textures.read(path.asSliceZ()) catch |e| {
        std.log.err("texture import failure: {}", .{e});
        return .none;
    };
    return @enumFromInt(int.value);
}

pub fn hy_gfx_passCreate(gpu: *hy.gfx.Gpu, opts: hy.gfx.PassCreateOptions) callconv(.c) hy.gfx.PassHandle {
    const rt_gpu: *gfx.Gpu = @ptrCast(@alignCast(gpu));
    const hdl = rt_gpu.passCreate(opts);
    return @enumFromInt(hdl.int());
}

pub fn hy_gfx_passDestroy(gpu: *hy.gfx.Gpu, hdl: hy.gfx.PassHandle) callconv(.c) void {
    const rt_gpu: *gfx.Gpu = @ptrCast(@alignCast(gpu));
    return rt_gpu.passDestroy(@bitCast(@intFromEnum(hdl)));
}

pub fn hy_gfx_passAdd(gpu: *hy.gfx.Gpu, opts: hy.gfx.PassAddOptions) callconv(.c) hy.gfx.Renderable {
    const rt_gpu: *gfx.Gpu = @ptrCast(@alignCast(gpu));
    const renderable = rt_gpu.passAdd(@bitCast(opts));
    return @bitCast(renderable);
}

pub fn hy_gfx_passClear(gpu: *hy.gfx.Gpu, hdl: hy.gfx.PassHandle) callconv(.c) void {
    const rt_gpu: *gfx.Gpu = @ptrCast(@alignCast(gpu));
    return rt_gpu.passClear(@bitCast(@intFromEnum(hdl)));
}

pub fn hy_gfx_immediateDraw(gpu: *hy.gfx.Gpu, verts: hy.ExternSliceConst(hy.gfx.UIVertex), indices: hy.ExternSliceConst(u32), transform: hym.Mat4, material_hdl: hy.gfx.MaterialHandle) callconv(.c) void {
    const rt_gpu: *gfx.Gpu = @ptrCast(@alignCast(gpu));
    rt_gpu.im.drawVerts(@ptrCast(verts.asSlice()), indices.asSlice(), .{
        .transform = transform,
        .material = if (material_hdl != .none) rt_gpu.materials.getPtr(@bitCast(@intFromEnum(material_hdl))) else null,
    });
}

pub fn hy_gfx_immediateText(
    gpu: *hy.gfx.Gpu,
    glyphs: hy.ExternSliceConst(u8),
    transform: hym.Mat4,
    color: u32,
) callconv(.c) void {
    const rt_gpu: *gfx.Gpu = @ptrCast(@alignCast(gpu));
    rt_gpu.im.drawText(glyphs.asSlice(), .{
        .transform = transform,
        .color = hy.Color.hexa(color).asf32x4Norm(),
    });
}

pub fn hy_io_reset(input: *hy.input.Context) callconv(.c) void {
    const rt_input: *Input = @ptrCast(@alignCast(input));
    rt_input.reset();
}

pub fn hy_io_mouse(input: *hy.input.Context, button: hy.key.MouseButton) callconv(.c) bool {
    const rt_input: *Input = @ptrCast(@alignCast(input));
    return rt_input.queryMouse(button);
}

pub fn hy_io_mousePosition(input: *hy.input.Context) callconv(.c) hym.Vec2 {
    const rt_input: *Input = @ptrCast(@alignCast(input));
    return rt_input.queryMousePosition();
}

pub fn hy_io_key(input: *hy.input.Context, button: hy.key.Keycode) callconv(.c) bool {
    const rt_input: *Input = @ptrCast(@alignCast(input));
    return rt_input.queryKey(button);
}

pub fn hy_io_bindPoll(input: *hy.input.Context, id: u32, on: hy.input.OnFlags, button: hy.key.Keycode) callconv(.c) void {
    const rt_input: *Input = @ptrCast(@alignCast(input));
    rt_input.bindPoll(id, on, button) catch |err| {
        std.log.err("input bind failure: {}", .{err});
    };
}

pub fn hy_io_bindPollMouse(input: *hy.input.Context, id: u32, on: hy.input.OnFlags, mouse: hy.MouseButton) callconv(.c) void {
    const rt_input: *Input = @ptrCast(@alignCast(input));
    rt_input.bindPollMouse(id, on, mouse) catch |err| {
        std.log.err("input bind failure: {}", .{err});
    };
}

pub fn hy_io_eventPump(input: *hy.input.Context) callconv(.c) hy.ExternSliceConst(u32) {
    const rt_input: *Input = @ptrCast(@alignCast(input));
    const events = rt_input.eventPump() catch |err| {
        std.log.err("input event pump failure: {}", .{err});
        return .from(&.{});
    };
    return .from(events);
}

pub fn hy_io_eventClear(input: *hy.input.Context, events: hy.ExternSliceConst(u32)) callconv(.c) void {
    const rt_input: *Input = @ptrCast(@alignCast(input));
    rt_input.eventClear(events.asSlice());
}

pub fn hy_p2_reset(p2_ctx: *hy.p2.Context) callconv(.c) void {
    const rt_p2_ctx: *Phys2 = @ptrCast(@alignCast(p2_ctx));
    return rt_p2_ctx.reset();
}

pub fn hy_p2_bodyAdd(p2_ctx: *hy.p2.Context, opts: *const hy.p2.BodyAddOptions) callconv(.c) hy.p2.Body {
    const rt_p2_ctx: *Phys2 = @ptrCast(@alignCast(p2_ctx));
    const rt_body = rt_p2_ctx.addBody(@ptrCast(opts));
    return @enumFromInt(@intFromEnum(rt_body));
}

pub fn hy_p2_bodyShapeAdd(body: hy.p2.Body, opts: *const hy.p2.BodyAddOptions.ShapeOptions) callconv(.c) void {
    Phys2.bodyShapeAdd(@enumFromInt(@intFromEnum(body)), @ptrCast(opts));
}

pub fn hy_p2_bodyDestroy(body: hy.p2.Body) callconv(.c) void {
    const rt_body: Phys2.Body = @enumFromInt(@intFromEnum(body));
    return rt_body.destroy();
}

pub fn hy_p2_bodyUserData(body: hy.p2.Body) callconv(.c) ?*anyopaque {
    const rt_body: Phys2.Body = @enumFromInt(@intFromEnum(body));
    return rt_body.getUserData();
}

pub fn hy_p2_bodyUserDataSet(body: hy.p2.Body, user_data: ?*anyopaque) callconv(.c) void {
    Phys2.bodyUserDataSet(body, user_data);
}

pub fn hy_p2_bodyPosition(p2_ctx: *hy.p2.Context, body: hy.p2.Body) callconv(.c) hym.Vec2 {
    const rt_p2_ctx: *Phys2 = @ptrCast(@alignCast(p2_ctx));
    const rt_body: Phys2.Body = @enumFromInt(@intFromEnum(body));
    return rt_p2_ctx.bodyPosition(rt_body);
}

pub fn hy_p2_bodyPositionSet(body: hy.p2.Body, pos: hym.Vec2) callconv(.c) void {
    const rt_body: Phys2.Body = @enumFromInt(@intFromEnum(body));
    Phys2.bodyPositionSet(rt_body, pos);
}

pub fn hy_p2_bodyPositionReal(body: hy.p2.Body) callconv(.c) hym.Vec2 {
    const rt_body: Phys2.Body = @enumFromInt(@intFromEnum(body));
    return @bitCast(rt_body.getPosition());
}

pub fn hy_p2_bodyType(body: hy.p2.Body) callconv(.c) hy.p2.Body.Type {
    const rt_body: Phys2.Body = @enumFromInt(@intFromEnum(body));
    return @enumFromInt(@intFromEnum(rt_body.getType()));
}

pub fn hy_p2_bodyTypeSet(body: hy.p2.Body, body_type: hy.p2.Body.Type) callconv(.c) void {
    const rt_body: Phys2.Body = @enumFromInt(@intFromEnum(body));
    rt_body.setType(@enumFromInt(@intFromEnum(body_type)));
}

pub fn hy_p2_bodyVelocity(body: hy.p2.Body) callconv(.c) hym.Vec2 {
    const rt_body: Phys2.Body = @enumFromInt(@intFromEnum(body));
    return @bitCast(rt_body.getLinearVelocity());
}

pub fn hy_p2_bodyVelocitySet(body: hy.p2.Body, velocity: hym.Vec2) callconv(.c) void {
    const rt_body: Phys2.Body = @enumFromInt(@intFromEnum(body));
    rt_body.setLinearVelocity(@bitCast(velocity));
}

pub fn hy_p2_shapeExtra(shape: hy.p2.Shape) callconv(.c) hy.p2.ShapeExtra {
    const rt_shape: Phys2.b2.Shape = @enumFromInt(@intFromEnum(shape));
    return Phys2.shapeExtra(rt_shape);
}

pub fn hy_p2_eventPump(p2_ctx: *hy.p2.Context, buffer: hy.ExternSlice(u8)) callconv(.c) u32 {
    const rt_p2_ctx: *Phys2 = @ptrCast(@alignCast(p2_ctx));
    return rt_p2_ctx.hit_events.pump(buffer.asSlice());
}

pub fn hy_p2_overlapLeaky(p2_ctx: *hy.p2.Context, arena: hy.ExternAllocator, shape: *const hy.p2.ShapeConfig, origin: hym.Vec2) callconv(.c) hy.ExternSlice(hy.p2.Shape) {
    const rt_p2_ctx: *Phys2 = @ptrCast(@alignCast(p2_ctx));
    return .from(@ptrCast(rt_p2_ctx.overlapLeaky(arena.allocator(), shape, origin)));
}

pub fn hy_p2_castRayLeaky(p2_ctx: *hy.p2.Context, arena: hy.ExternAllocator, opts: hy.p2.RaycastOptions) callconv(.c) hy.ExternSlice(hy.p2.RaycastHit) {
    const rt_p2_ctx: *Phys2 = @ptrCast(@alignCast(p2_ctx));
    return .from(@ptrCast(rt_p2_ctx.raycastLeaky(arena.allocator(), @bitCast(opts))));
}

pub fn hy_p2_castCircleLeaky(p2_ctx: *hy.p2.Context, arena: hy.ExternAllocator, opts: hy.p2.CastCircleOptions) callconv(.c) hy.ExternSlice(hy.p2.RaycastHit) {
    const rt_p2_ctx: *Phys2 = @ptrCast(@alignCast(p2_ctx));
    return .from(@ptrCast(rt_p2_ctx.castCircleLeaky(arena.allocator(), @bitCast(opts))));
}

pub fn hy_p2_shapeBody(shape: hy.p2.Shape) callconv(.c) hy.p2.Body {
    const rt_shape: Phys2.b2.Shape = @enumFromInt(@intFromEnum(shape));
    return @enumFromInt(@intFromEnum(rt_shape.getBody()));
}

pub fn hy_p2_shapeValid(shape: hy.p2.Shape) callconv(.c) bool {
    const rt_shape: Phys2.b2.Shape = @enumFromInt(@intFromEnum(shape));
    return rt_shape.isValid();
}

pub fn hy_ui_globalState(ui: *hy.UI) callconv(.c) hy.ui.State {
    const rt_ui: *UI = @ptrCast(@alignCast(ui));
    return @bitCast(rt_ui.getGlobalState());
}

pub fn hy_ui_inputState(ui: *hy.UI) callconv(.c) hy.ui.InputState {
    const rt_ui: *UI = @ptrCast(@alignCast(ui));
    return @bitCast(rt_ui.inputState());
}

pub fn hy_win_relativeMouseMode(window: *hy.Window, on_off: bool) callconv(.c) void {
    const rt_window: *Window = @ptrCast(@alignCast(window));
    rt_window.setRelativeMouseMode(on_off);
}

pub fn hy_win_dimensions(window: *hy.Window) callconv(.c) hym.Vec2 {
    const rt_window: *Window = @ptrCast(@alignCast(window));
    return rt_window.dimensions();
}

pub fn hy_win_projectionMatrix(window: *hy.Window) callconv(.c) hym.Mat4 {
    return window.projectionMatrix();
}
