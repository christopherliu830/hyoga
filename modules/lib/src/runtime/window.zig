pub const hym = @import("../math/math.zig");

const proc_table = @import("proc_table.zig");
const proc = &proc_table.table;

pub const Window = opaque {
    pub fn relativeMouseMode(window: *Window, toggle: bool) void {
        return proc.hy_win_relativeMouseMode(window, toggle);
    }

    pub fn dimensions(window: *Window) hym.Vec2 {
        return proc.hy_win_dimensions(window);
    }

    pub fn projectionMatrix(window: *Window) hym.Mat4 {
        return proc.hy_win_projectionMatrix(window);
    }
};

