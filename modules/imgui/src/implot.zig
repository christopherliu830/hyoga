const imgui = @import("imgui");

pub const Context=  opaque {};

pub const Point = extern struct {
    x: f64,
    y: f64,
};

pub const Axis = enum (c_int) {
    x1,
    x2,
    x3,
    y1,
    y2,
    y3,
    count,
};

pub const Getter = *const fn(data: ?*anyopaque, idx: i32, point: ?*Point) ?*anyopaque;

pub const Flags = packed struct (c_int) {

    pub const CanvasOnly = Flags { 
        .no_title = true, 
        .no_legend = true,
        .no_menus = true,
        .no_box_select = true,
        .no_mouse_text = true
    };

    no_title: bool = false,
    no_legend: bool = false,
    no_mouse_text: bool = false,
    no_inputs: bool = false,
    no_menus: bool = false,
    no_box_select: bool = false,
    no_frame: bool = false,
    equal: bool = false,
    crosshairs: bool = false,
    _: u23 = 0,
};

pub const AxisFlags = packed struct (c_int) {
    pub const lock = AxisFlags { .lock_min = true, .lock_max = true};
    pub const no_decoration = AxisFlags { .no_label = true, .no_grid_lines = true, .no_tick_marks = true, .no_tick_labels = true, };
    pub const aux_default = AxisFlags { .no_grid_lines = true, .opposite = true };
    no_label: bool = false,
    no_grid_lines: bool = false,
    no_tick_marks: bool = false,
    no_tick_labels: bool = false,
    no_initial_fit: bool = false,
    no_menus: bool = false,
    no_side_switch: bool = false,
    no_highlight: bool = false,
    opposite: bool = false,
    foreground: bool = false,
    invert: bool = false,
    auto_fit: bool = false,
    range_fit: bool = false,
    pan_stretch: bool = false,
    lock_min: bool = false,
    lock_max: bool = false,
};

pub const BarsFlags = enum (c_int) {
    none = 0,
    horizontal = 1 << 10,
};

pub const Cond = enum (c_int) {
    none = @intFromEnum(imgui.Cond.none),
    always = @intFromEnum(imgui.Cond.always),
    once = @intFromEnum(imgui.Cond.once),
};

pub extern fn ImPlot_CreateContext() *Context;
pub const createContext = ImPlot_CreateContext;
pub extern fn ImPlot_DestroyContext(ctx: ?*Context) void;
pub const destroyContext = ImPlot_DestroyContext;
pub extern fn ImPlot_GetCurrentContext() *Context;
pub const getCurrentContext = ImPlot_GetCurrentContext;
pub extern fn ImPlot_SetCurrentContext(ctx: ?*Context) void;
pub const setCurrentContext = ImPlot_SetCurrentContext;
pub extern fn ImPlot_SetImGuiContext(ctx: *imgui.Context) void;
pub const setImguiContext = ImPlot_SetImGuiContext;
pub extern fn ImPlot_BeginPlot(title_id: [*]const u8, size: imgui.Vec2, flags: Flags) bool;
pub const begin = ImPlot_BeginPlot;
pub extern fn ImPlot_EndPlot() void;
pub const end = ImPlot_EndPlot;
pub extern fn ImPlot_SetupAxis(axis: Axis, label: [*]const u8, flags: AxisFlags) void;
pub const setupAxis = ImPlot_SetupAxis;
pub extern fn ImPlot_SetupAxisLimits(axis: Axis, v_min: f64, v_max: f64, cond: Cond) void;
pub const setupAxisLimits = ImPlot_SetupAxisLimits;
pub extern fn ImPlot_SetupAxisLinks(axis: Axis, link_min: *f64, link_max: *f64, cond: Cond) void;
pub const setupAxisLinks = ImPlot_SetupAxisLinks;
// CIMGUI_API void ImPlot_SetupAxisFormat_Str(ImAxis axis,const char* fmt);
// CIMGUI_API void ImPlot_SetupAxisFormat_PlotFormatter(ImAxis axis,ImPlotFormatter formatter,void* data);
// CIMGUI_API void ImPlot_SetupAxisTicks_doublePtr(ImAxis axis,const double* values,int n_ticks,const char* const labels[],bool keep_default);
// CIMGUI_API void ImPlot_SetupAxisTicks_double(ImAxis axis,double v_min,double v_max,int n_ticks,const char* const labels[],bool keep_default);
// CIMGUI_API void ImPlot_SetupAxisScale_PlotScale(ImAxis axis,ImPlotScale scale);
// CIMGUI_API void ImPlot_SetupAxisScale_PlotTransform(ImAxis axis,ImPlotTransform forward,ImPlotTransform inverse,void* data);
// CIMGUI_API void ImPlot_SetupAxisLimitsConstraints(ImAxis axis,double v_min,double v_max);
// CIMGUI_API void ImPlot_SetupAxisZoomConstraints(ImAxis axis,double z_min,double z_max);
pub extern fn ImPlot_SetupAxes(x_label: [*]const u8, y_label: [*]const u8, x_flags: AxisFlags, y_flags: AxisFlags) void;
pub const setupAxes = ImPlot_SetupAxes;
pub extern fn ImPlot_SetupAxesLimits(x_min: f64, x_max: f64, y_min: f64, y_max: f64, cond: Cond) void;
pub const setupAxesLimits = ImPlot_SetupAxesLimits;

pub extern fn ImPlot_PlotBars_FloatPtrInt(label_id: [*]const u8, values: [*]const f32, count: i32, bar_size: f64, shift: f64, flags: BarsFlags, offset: i32, stride: i32) void;
pub extern fn ImPlot_PlotBars_doublePtrInt(label_id: [*]const u8, values: [*]const f64, count: i32, bar_size: f64, shift: f64, flags: BarsFlags, offset: i32, stride: i32) void;
pub extern fn ImPlot_PlotBars_S8PtrInt(label_id: [*]const u8, values: [*]const imgui.S8, count: i32, bar_size: f64, shift: f64, flags: BarsFlags, offset: i32, stride: i32) void;
pub extern fn ImPlot_PlotBars_U8PtrInt(label_id: [*]const u8, values: [*]const imgui.U8, count: i32, bar_size: f64, shift: f64, flags: BarsFlags, offset: i32, stride: i32) void;
pub extern fn ImPlot_PlotBars_S16PtrInt(label_id: [*]const u8, values: [*]const imgui.S16, count: i32, bar_size: f64, shift: f64, flags: BarsFlags, offset: i32, stride: i32) void;
pub extern fn ImPlot_PlotBars_U16PtrInt(label_id: [*]const u8, values: [*]const imgui.U16, count: i32, bar_size: f64, shift: f64, flags: BarsFlags, offset: i32, stride: i32) void;
pub extern fn ImPlot_PlotBars_S32PtrInt(label_id: [*]const u8, values: [*]const imgui.S32, count: i32, bar_size: f64, shift: f64, flags: BarsFlags, offset: i32, stride: i32) void;
pub extern fn ImPlot_PlotBars_U32PtrInt(label_id: [*]const u8, values: [*]const imgui.U32, count: i32, bar_size: f64, shift: f64, flags: BarsFlags, offset: i32, stride: i32) void;
pub extern fn ImPlot_PlotBars_S64PtrInt(label_id: [*]const u8, values: [*]const imgui.S64, count: i32, bar_size: f64, shift: f64, flags: BarsFlags, offset: i32, stride: i32) void;
pub extern fn ImPlot_PlotBars_U64PtrInt(label_id: [*]const u8, values: [*]const imgui.U64, count: i32, bar_size: f64, shift: f64, flags: BarsFlags, offset: i32, stride: i32) void;

pub const PlotBarsOptions = struct {
    bar_size: f32 = 0.67, 
    shift: f32 = 0,
    flags: BarsFlags = .none,
    offset: i32 = 0,
    stride: ?i32 = null,
};

pub fn plotBars(label_id: [*]const u8, values: anytype, options: PlotBarsOptions) void {
    switch(@typeInfo(@TypeOf(values))) {
        .pointer => |ptr| {
            if (ptr.size != .Slice) @panic("plot bars must take a slice type");
            switch(@typeInfo(ptr.child)) {
                .int => |int| {
                    if (int.signedness == .signed) {
                        switch(int.bits) {
                            8 => ImPlot_PlotBars_S8PtrInt(label_id, values.ptr, @intCast(values.len), options.bar_size, options.shift, options.flags, options.offset, options.stride orelse int.bits/8),
                            16 => ImPlot_PlotBars_S16PtrInt(label_id, values.ptr, @intCast(values.len), options.bar_size, options.shift, options.flags, options.offset, options.stride orelse int.bits/8),
                            32 => ImPlot_PlotBars_S32PtrInt(label_id, values.ptr, @intCast(values.len), options.bar_size, options.shift, options.flags, options.offset, options.stride orelse int.bits/8),
                            64 => ImPlot_PlotBars_S64PtrInt(label_id, values.ptr, @intCast(values.len), options.bar_size, options.shift, options.flags, options.offset, options.stride orelse int.bits/8),
                            else => unreachable,
                        }
                    } else {
                        switch(int.bits) {
                            8 => ImPlot_PlotBars_U8PtrInt(label_id, values.ptr, @intCast(values.len), options.bar_size, options.shift, options.flags, options.offset, options.stride orelse int.bits/8),
                            16 => ImPlot_PlotBars_U16PtrInt(label_id, values.ptr, @intCast(values.len), options.bar_size, options.shift, options.flags, options.offset, options.stride orelse int.bits/8),
                            32 => ImPlot_PlotBars_U32PtrInt(label_id, values.ptr, @intCast(values.len), options.bar_size, options.shift, options.flags, options.offset, options.stride orelse int.bits/8),
                            64 => ImPlot_PlotBars_U64PtrInt(label_id, values.ptr, @intCast(values.len), options.bar_size, options.shift, options.flags, options.offset, options.stride orelse int.bits/8),
                            else => unreachable,
                        }
                    }
                },

                .float => |float| {
                    switch(float.bits) {
                        32 => ImPlot_PlotBars_FloatPtrInt(label_id, values.ptr, @intCast(values.len), options.bar_size, options.shift, options.flags, options.offset, options.stride orelse float.bits/8),
                        64 => ImPlot_PlotBars_doublePtrInt(label_id, values.ptr, @intCast(values.len), options.bar_size, options.shift, options.flags, options.offset, options.stride orelse float.bits/8),
                        else => @panic("invalid float size")
                    }
                },

                else => @panic("plotBars must take a slice type"),
            } 
        },
        else => @panic("plotBars must take a slice type"),
    }
}
                
pub extern fn ImPlot_PlotBars_FloatPtrFloatPtr(label_id: [*]const u8, x: *const f32, y: *const f32, count: i32, flags: BarsFlags, offset: i32, stride: i32) void;

pub extern fn ImPlot_PlotBars_doublePtrdoublePtr(label_id: [*]const u8, x: *const f64, y: *const f64, count: i32, flags: BarsFlags, offset: i32, stride: i32) void;

pub extern fn ImPlot_PlotBars_S8PtrS8Ptr(label_id: [*]const u8, x: *const imgui.S8, y: *const imgui.S8, count: i32, flags: BarsFlags, offset: i32, stride: i32) void;

pub extern fn ImPlot_PlotBars_U8PtrU8Ptr(label_id: [*]const u8, x: *const imgui.U8, y: *const imgui.U8, count: i32, flags: BarsFlags, offset: i32, stride: i32) void;

pub extern fn ImPlot_PlotBars_S16PtrS16Ptr(label_id: [*]const u8, x: *const imgui.S16, y: *const imgui.S16, count: i32, flags: BarsFlags, offset: i32, stride: i32) void;

pub extern fn ImPlot_PlotBars_U16PtrU16Ptr(label_id: [*]const u8, x: *const imgui.U16, y: *const imgui.U16, count: i32, flags: BarsFlags, offset: i32, stride: i32) void;

pub extern fn ImPlot_PlotBars_S32PtrS32Ptr(label_id: [*]const u8, x: *const imgui.S32, y: *const imgui.S32, count: i32, flags: BarsFlags, offset: i32, stride: i32) void;

pub extern fn ImPlot_PlotBars_U32PtrU32Ptr(label_id: [*]const u8, x: *const imgui.U32, y: *const imgui.U32, count: i32, flags: BarsFlags, offset: i32, stride: i32) void;

pub extern fn ImPlot_PlotBars_S64PtrS64Ptr(label_id: [*]const u8, x: *const imgui.S64, y: *const imgui.S64, count: i32, flags: BarsFlags, offset: i32, stride: i32) void;

pub extern fn ImPlot_PlotBars_U64PtrU64Ptr(label_id: [*]const u8, x: *const imgui.U64, y: *const imgui.U64, count: i32, flags: BarsFlags, offset: i32, stride: i32) void;

pub extern fn ImPlot_PlotBarsG(label_id: [*]const u8, getter: Getter, data: ?*anyopaque, flags: BarsFlags, offset: i32, stride: i32) void;

pub extern fn ImPlot_SetAxis(axis: Axis) void;
pub extern fn ImPlot_SetAxes(x: Axis, y: Axis) void;
