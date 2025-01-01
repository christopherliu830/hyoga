pub const std_options = std.Options {
    .fmt_max_depth = 4, // printing struct { [4]@Vector(4, f32) } breaks with default max depth
};

const std = @import("std");
const sdl = @import("sdl");
const imgui = @import("imgui");

const hy = @import("hyoga-lib");
const math = hy.math;

const Engine = @import("Engine.zig");
const Input = Engine.Input;
const Gpu = Engine.Gpu;


pub const Scene = extern struct {
    view_proj: math.Mat4,
    light_dir: math.Vec3,
    camera_world_pos: math.Vec3,
};

pub const World = extern struct {
    quit: bool = false,
    restart: bool = false,
    scene: Scene,
    frame_time: u64 = 0,
    memory: *anyopaque,
};

pub const GameInterface = extern struct {
    init: *const fn(*Engine) callconv(.C) World,
    shutdown: *const fn(*Engine, World) callconv(.C) void,
    update: *const fn (*Engine, World) callconv(.C) World,
    render: *const fn (*Engine, World) callconv(.C) void,
    reload: *const fn (*Engine, World) callconv (.C) bool,
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

export fn hyeStrint(engine: *Engine) *Engine.Strint {
    return &engine.strint;
}

export fn hyeUI(engine: *Engine) *Engine.UI {
    return &engine.ui;
}

export fn hyeWindow(engine: *Engine) *Engine.Window {
    return &engine.window;
}

export fn hygpuImportModel(gpu: *Gpu, path: [*:0]const u8, settings: Gpu.mdl.ImportSettings) Gpu.ModelHandle {
    return gpu.importModel(path, settings) catch |e| {
        std.log.err("import model failure: {}", .{e});
        return Gpu.ModelHandle.invalid;
    };
}

export fn hygpuModelBounds(gpu: *Gpu, model: Gpu.ModelHandle) hy.math.Bounds {
    if (gpu.models.get(model)) |m| {
        return m.bounds;
    } else |e| {
        std.log.err("get model failure: {}", .{e});
        return .{};
    }
}

export fn hygpuModelWaitLoad(gpu: *Gpu, model: Gpu.ModelHandle, max: u64) bool {
    return gpu.models.waitLoad(model, max);
}

export fn hygpuAddRenderable(gpu: *Gpu, options: Gpu.AddRenderableOptions) Gpu.RenderItemHandle {
    return gpu.renderables.add(options) catch |e| {
        std.log.err("add renderable failure: {}", .{e});
        return Gpu.RenderItemHandle.invalid;
    };
}

export fn hygpuRemoveRenderable(gpu: *Gpu, item: Gpu.RenderItemHandle) void {
    gpu.renderables.remove(item);
}

export fn hygpuSelectRenderable(gpu: *Gpu, item: Gpu.RenderItemHandle) void {
    gpu.outlined.put(gpu.gpa, item, {}) catch |e| {
        std.log.err("select renderable failure: {}", .{e});
    };
}

export fn hygpuDeselectRenderable(gpu: *Gpu, item: Gpu.RenderItemHandle) void {
    _ = gpu.outlined.swapRemove(item);
}

export fn hygpuClearSelection(gpu: *Gpu) void {
    gpu.outlined.clearRetainingCapacity();
}

export fn hyioReset(input: *Input) void {
    input.reset();
}

export fn hyioBindMouse(input: *Input, options: Input.BindMouseOptions, delegate: *hy.closure.Runnable) void {
    input.bindMouse(options, delegate) catch |e| {
        std.log.err("Could not bind delegate: {}", .{e});
    };
}

export fn hyioBindKey(input: *Input, options: Input.BindKeyOptions, delegate: *hy.closure.Runnable) void {
    input.bindKey(options, delegate) catch |e| {
        std.log.err("Could not bind delegate: {}", .{e});
    };
}

export fn hyioQueryMouse(input: *Input, button: hy.key.MouseButton) bool {
    return input.queryMouse(button);
}

export fn hyioQueryKey(input: *Input, button: hy.key.Keycode) bool {
    return input.queryKey(button);
}

export fn hysidFrom(strint: *Engine.Strint, str: [*]const u8, len: usize) Engine.Strint.ID {
    return strint.from(str[0..len]) catch |e| {
        std.log.err("strint failure: {}", .{e});
        return Engine.Strint.ID.invalid;
    };
}

export fn hysidAsString(strint: *Engine.Strint, str: Engine.Strint.ID, len: *usize) [*]const u8 {
    const slice = strint.asString(str);
    len.* = slice.len;
    return slice.ptr;
}

export fn hysidAsStringZ(strint: *Engine.Strint, str: Engine.Strint.ID, len: *usize) [*]const u8 {
    const slice = strint.asStringZ(str);
    len.* = slice.len;
    return slice.ptr;
}

export fn hyuiGetGlobalState(ui: *Engine.UI) Engine.UI.GlobalState {
    return ui.getGlobalState();
}

export fn hywSetRelativeMouseMode(window: *Engine.Window, on_off: bool) void {
    window.setRelativeMouseMode(on_off);
}

export fn hywAspect(window: *Engine.Window) f32 {
    return window.aspect;
}
