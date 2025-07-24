const hy = @import("../root.zig");
const hym = hy.math;
const Engine = @import("../runtime.zig").Engine;
const gfx = @import("gpu.zig");
const p2 = @import("phys2.zig");
const ui = @import("ui.zig");
const input = @import("input.zig");
const Strint = @import("strint.zig").Strint;
const Window = @import("window.zig").Window;
const audio = @import("audio.zig");

pub var table: ProcTable = undefined;

pub fn load(t: ProcTable) void {
    table = t;
}

const String = hy.ExternSliceConst(u8);

pub const ProcTable = extern struct {
    hy_init: *const fn () callconv(.c) *Engine,
    hy_engine_gameAllocator: *const fn (*Engine) callconv(.c) hy.ExternAllocator,
    hy_engine_gpu: *const fn (*Engine) callconv(.c) *gfx.Gpu,
    hy_engine_phys2: *const fn (*Engine) callconv(.c) *p2.World,
    hy_engine_input: *const fn (*Engine) callconv(.c) *input.Context,
    hy_engine_window: *const fn (*Engine) callconv(.c) *Window,
    hy_engine_ui: *const fn (*Engine) callconv(.c) *ui.UI,
    hy_audio_soundRead: *const fn (path: hy.ExternSliceConst(u8)) callconv(.c) audio.Sound,
    hy_audio_soundPlay: *const fn (sound: *audio.Sound) callconv(.c) void,
    hy_audio_soundStop: *const fn (sound: *audio.Sound) callconv(.c) void,
    hy_gfx_clearColorSet: *const fn (gpu: *gfx.Gpu, color: hym.Vec4) callconv(.c) void,
    hy_gfx_modelImport: *const fn (gpu: *gfx.Gpu, path: String, settings: gfx.ImportSettings) callconv(.c) gfx.Model,
    hy_gfx_modelCreate: *const fn (gpu: *gfx.Gpu, opts: hy.gfx.ModelCreateOptions) callconv(.c) gfx.Model,
    hy_gfx_modelDestroy: *const fn (gpu: *gfx.Gpu, model: gfx.Model) callconv(.c) void,
    hy_gfx_modelBounds: *const fn (gpu: *gfx.Gpu, model: gfx.Model) callconv(.c) hym.AxisAligned,
    hy_gfx_modelDupe: *const fn (gpu: *gfx.Gpu, model: gfx.Model, options: gfx.ModelDupeOptions) callconv(.c) gfx.Model,
    hy_gfx_modelPrimitive: *const fn (gpu: *gfx.Gpu, shape: gfx.PrimitiveShape) callconv(.c) gfx.Model,
    hy_gfx_modelWaitLoad: *const fn (gpu: *gfx.Gpu, model: gfx.Model, max: u64) callconv(.c) bool,
    hy_gfx_materialLoad: *const fn (gpu: *gfx.Gpu, path: String) callconv(.c) gfx.MaterialHandle,
    hy_gfx_materialReload: *const fn (gpu: *gfx.Gpu, hdl: gfx.MaterialHandle) callconv(.c) void,
    hy_gfx_materialCreate: *const fn (gpu: *gfx.Gpu, type: gfx.MaterialType, tx_set: *const gfx.TextureArray) callconv(.c) gfx.MaterialHandle,
    hy_gfx_materialDestroy: *const fn (gpu: *gfx.Gpu, hdl: gfx.MaterialHandle) callconv(.c) void,
    hy_gfx_renderableAdd: *const fn (gpu: *gfx.Gpu, opts: gfx.AddRenderableOptions) callconv(.c) gfx.Renderable,
    hy_gfx_renderableRemove: *const fn (gpu: *gfx.Gpu, hdl: gfx.Renderable) callconv(.c) void,
    hy_gfx_renderableTransformSet: *const fn (gpu: *gfx.Gpu, hdl: gfx.Renderable, transform: hym.Mat4) callconv(.c) void,
    hy_gfx_spriteMakeRenderable: *const fn (gpu: *gfx.Gpu, hdl: gfx.Sprite.Handle) callconv(.c) gfx.Renderable,
    hy_gfx_spriteCreate: *const fn (gpu: *gfx.Gpu, opts: gfx.SpriteCreateOptions) callconv(.c) gfx.Sprite.Handle,
    hy_gfx_spriteDestroy: *const fn (gpu: *gfx.Gpu, hdl: gfx.Sprite.Handle) callconv(.c) void,
    hy_gfx_spriteWeakPtr: *const fn (gpu: *gfx.Gpu, hdl: gfx.Sprite.Handle) callconv(.c) ?*gfx.Sprite,
    hy_gfx_spriteRenderableWeakPtr: *const fn (gpu: *gfx.Gpu, hdl: gfx.Renderable) callconv(.c) ?*gfx.Sprite,
    hy_gfx_spriteCurrentAnimationFrame: *const fn (gpu: *gfx.Gpu, hdl: *gfx.Sprite) callconv(.c) u32,
    hy_gfx_spriteDupe: *const fn (gpu: *gfx.Gpu, hdl: gfx.Sprite.Handle) callconv(.c) gfx.Sprite.Handle,
    hy_gfx_textureImport: *const fn (gpu: *gfx.Gpu, path: String) callconv(.c) gfx.TextureHandle,
    hy_gfx_passCreate: *const fn (gpu: *gfx.Gpu, opts: hy.gfx.PassCreateOptions) callconv(.c) gfx.PassHandle,
    hy_gfx_passDestroy: *const fn (gpu: *gfx.Gpu, hdl: gfx.PassHandle) callconv(.c) void,
    hy_gfx_passAdd: *const fn (gpu: *gfx.Gpu, opts: gfx.PassAddOptions) callconv(.c) gfx.Renderable,
    hy_gfx_passClear: *const fn (gpu: *gfx.Gpu, hdl: gfx.PassHandle) callconv(.c) void,
    hy_gfx_immediateDraw: *const fn (gpu: *gfx.Gpu, verts: hy.ExternSliceConst(gfx.UIVertex), idxs: hy.ExternSliceConst(u32), transform: hym.Mat4, material_hdl: gfx.MaterialHandle) callconv(.c) void,
    hy_io_reset: *const fn (input: *input.Context) callconv(.c) void,
    hy_io_mouse: *const fn (input: *input.Context, button: hy.MouseButton) callconv(.c) bool,
    hy_io_mousePosition: *const fn (input: *input.Context) callconv(.c) hym.Vec2,
    hy_io_key: *const fn (input: *input.Context, button: hy.Keycode) callconv(.c) bool,
    hy_io_bindPoll: *const fn (input: *input.Context, id: u32, on: input.OnFlags, button: hy.Keycode) callconv(.c) void,
    hy_io_bindPollMouse: *const fn (input: *input.Context, id: u32, on: input.OnFlags, mouse: hy.MouseButton) callconv(.c) void,
    hy_io_eventPump: *const fn (input: *input.Context) callconv(.c) hy.ExternSliceConst(u32),
    hy_io_eventClear: *const fn (input: *input.Context, events: hy.ExternSliceConst(u32)) callconv(.c) void,
    hy_p2_bodyAdd: *const fn (world: *p2.World, opts: p2.Body.AddOptions) callconv(.c) p2.Body,
    hy_p2_bodyDestroy: *const fn (body: p2.Body) callconv(.c) void,
    hy_p2_bodyUserData: *const fn (body: p2.Body) callconv(.c) ?*anyopaque,
    hy_p2_bodyPosition: *const fn (world: *p2.World, body: p2.Body) callconv(.c) hym.Vec2,
    hy_p2_bodyPositionSet: *const fn (body: p2.Body, pos: hym.Vec2) callconv(.c) void,
    hy_p2_bodyPositionReal: *const fn (body: p2.Body) callconv(.c) hym.Vec2,
    hy_p2_bodyType: *const fn (body: p2.Body) callconv(.c) p2.Body.Type,
    hy_p2_bodyTypeSet: *const fn (body: p2.Body, type: p2.Body.Type) callconv(.c) void,
    hy_p2_bodyVelocity: *const fn (body: p2.Body) callconv(.c) hym.Vec2,
    hy_p2_bodyVelocitySet: *const fn (body: p2.Body, v: hym.Vec2) callconv(.c) void,
    hy_p2_shapeBody: *const fn (shape: p2.Shape) callconv(.c) p2.Body,
    hy_p2_shapeExtra: *const fn (shape: p2.Shape) callconv(.c) p2.ShapeExtra,
    hy_p2_eventReset: *const fn (world: *p2.World) callconv(.c) void,
    hy_p2_eventRegister: *const fn (world: *p2.World, body: p2.Body, cb: *hy.closure.Runnable(p2.HitEvent)) callconv(.c) void,
    hy_p2_eventDeregister: *const fn (world: *p2.World, body: p2.Body, cb: *hy.closure.Runnable(p2.HitEvent)) callconv(.c) void,
    hy_p2_eventDeregisterAll: *const fn (world: *p2.World, body: p2.Body) callconv(.c) void,
    hy_p2_overlapLeaky: *const fn (world: *p2.World, arena: hy.ExternAllocator, shape: p2.ShapeOptions, origin: hym.Vec2) callconv(.c) hy.ExternSlice(p2.Shape),
    hy_p2_castRayLeaky: *const fn (world: *p2.World, arena: hy.ExternAllocator, opts: p2.RaycastOptions) callconv(.c) hy.ExternSlice(p2.RaycastHit),
    hy_p2_castCircleLeaky: *const fn (world: *p2.World, arena: hy.ExternAllocator, opts: p2.CastCircleOptions) callconv(.c) hy.ExternSlice(p2.RaycastHit),
    hy_ui_globalState: *const fn (ctx: *ui.UI) callconv(.c) ui.State,
    hy_ui_inputState: *const fn (ctx: *ui.UI) callconv(.c) ui.InputState,
    hy_win_relativeMouseMode: *const fn (window: *Window, toggle: bool) callconv(.c) void,
    hy_win_dimensions: *const fn (window: *Window) callconv(.c) hym.Vec2,
    hy_win_projectionMatrix: *const fn (window: *Window) callconv(.c) hym.Mat4,
};
