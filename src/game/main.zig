const std = @import("std");
const hy = @import("hyoga");

inline fn castToData(ptr: *anyopaque) *u32 {
    return @ptrCast(@alignCast(ptr));
}

fn init() callconv(.C) hy.Game {
    const ptr = std.heap.page_allocator.create(u32) catch @panic("out of memory");
    ptr.* = 0;
    return .{
        .scene = .{
            .camera = .{
                .position = hy.math.vec3.create(0, 0, 2.5),
                .look_direction = hy.math.vec3.create(0, 0, -1),
            },
            .light_dir = hy.math.vec3.create(0, -1, 0),
        },
        .memory = ptr,
    };
}

fn shutdown(state: hy.Game) callconv(.C) void {
    const ptr = @as(*u32, @ptrCast(@alignCast(state.memory)));
    std.heap.page_allocator.destroy(ptr);
}

// Called every loop iteration
fn update(state: hy.Game) callconv(.C) hy.Game {
    return state;
}

// Only called on new frames
fn render(state: hy.Game) callconv(.C) void {
    _ = state;
    const imgui = hy.ui.imgui;
    if (imgui.Begin("Debug Window", null, 0)) {
        imgui.Text("Hello world!");
    }
    imgui.End();
}

fn reload(mem: *anyopaque) callconv(.C) void {
    _ = mem;
}

export fn loadImgui(state: hy.ui.ImguiState) callconv(.C) void {
    hy.ui.setState(state);
}

export fn interface() hy.GameInterface {
    return .{
        .init = init,
        .shutdown = shutdown,
        .update = update,
        .render = render,
        .reload = reload,
        .reloadImgui = loadImgui,
    };
}
