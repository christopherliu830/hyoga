pub const UI = opaque {
    pub const State = extern struct {
        imgui_ctx: ?*anyopaque,
        implot_ctx: ?*anyopaque,
        alloc_fn: ?*anyopaque,
        free_fn: ?*anyopaque,
        resize_fn: ?*anyopaque,
        userdata: ?*anyopaque,
    };

    pub const getGlobalState = hyuiGetGlobalState;
};

extern fn hyuiGetGlobalState(*UI) UI.State;
