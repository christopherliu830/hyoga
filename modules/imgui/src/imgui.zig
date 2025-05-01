pub const igVERSION = "1.91.6 WIP";
pub const igVERSION_NUM = 19152;
pub const igPAYLOAD_TYPE_COLOR_3F = "_COL3F";
pub const igPAYLOAD_TYPE_COLOR_4F = "_COL4F";
pub const IM_UNICODE_CODEPOINT_INVALID = 0xFFFD;
// pub const IM_UNICODE_CODEPOINT_MAX = 0x10FFFF;
pub const IM_UNICODE_CODEPOINT_MAX = 0xFFFF;
pub const IM_COL32_R_SHIFT = 16;
pub const IM_COL32_G_SHIFT = 8;
pub const IM_COL32_B_SHIFT = 0;
pub const IM_COL32_A_SHIFT = 24;
pub const IM_COL32_A_MASK = 0xFF000000;
// pub const IM_COL32_R_SHIFT = 0;
// pub const IM_COL32_G_SHIFT = 8;
// pub const IM_COL32_B_SHIFT = 16;
// pub const IM_COL32_A_SHIFT = 24;
// pub const IM_COL32_A_MASK = 0xFF000000;
pub const IM_DRAWLIST_TEX_LINES_WIDTH_MAX = 63;
pub const ID = c_uint;
pub const S8 = c_char;
pub const U8 = c_char;
pub const S16 = c_short;
pub const U16 = c_ushort;
pub const S32 = c_int;
pub const U32 = c_uint;
pub const S64 = c_longlong;
pub const U64 = c_ulonglong;
pub const DrawFlags = c_int;
pub const DrawListFlags = c_int;
pub const FontAtlasFlags = c_int;
pub const BackendFlags = c_int;
pub const ButtonFlags = c_int;
pub const ChildFlags = c_int;
pub const ColorEditFlags = c_int;
pub const ConfigFlags = c_int;
pub const ComboFlags = c_int;
pub const DockNodeFlags = c_int;
pub const DragDropFlags = c_int;
pub const FocusedFlags = c_int;
pub const HoveredFlags = c_int;
pub const InputFlags = c_int;
pub const InputTextFlags = c_int;
pub const ItemFlags = c_int;
pub const KeyChord = c_int;
pub const PopupFlags = c_int;
pub const MultiSelectFlags = c_int;
pub const SelectableFlags = c_int;
pub const SliderFlags = c_int;
pub const TabBarFlags = c_int;
pub const TabItemFlags = c_int;
pub const TableFlags = c_int;
pub const TableColumnFlags = c_int;
pub const TableRowFlags = c_int;

pub const TreeNodeFlags = packed struct(u32) {
    none: bool = false,
    selected: bool = false,
    framed: bool = false,
    allow_overlap: bool = false,
    no_tree_push_on_open: bool = false,
    no_auto_open_on_log: bool = false,
    default_open: bool = false,
    open_on_double_click: bool = false,
    open_on_arrow: bool = false,
    leaf: bool = false,
    bullet: bool = false,
    frame_padding: bool = false,
    span_avail_width: bool = false,
    span_full_width: bool = false,
    span_text_width: bool = false,
    span_all_columns: bool = false,
    nav_left_jumps_back_here: bool = false,
    allow_item_overlap: bool = false,
    _padding: u14 = 0,

    pub const collapsing_header: TreeNodeFlags = .{
        .framed = true,
        .no_tree_push_on_open = true,
        .no_auto_open_on_log = true,
    };
};
pub const ViewportFlags = c_int;

pub const WindowFlags = packed struct(u32) {
    pub const no_nav: WindowFlags = .{ .no_nav_inputs = true, .no_nav_focus = true, .no_docking = true };
    pub const no_decoration: WindowFlags = .{ .no_title_bar = true, .no_resize = true, .no_scrollbar = true, .no_collapse = true };
    pub const no_inputs: WindowFlags = .{ .no_mouse_inputs = true, .no_nav_inputs = true, .no_nav_focus = true };
    pub const none: WindowFlags = .{};

    no_title_bar: bool = false,
    no_resize: bool = false,
    no_move: bool = false,
    no_scrollbar: bool = false,
    no_scroll_with_mouse: bool = false,
    no_collapse: bool = false,
    always_auto_resize: bool = false,
    no_background: bool = false,
    no_saved_settings: bool = false,
    no_mouse_inputs: bool = false,
    menu_bar: bool = false,
    horizontal_scrollbar: bool = false,
    no_focus_on_appearing: bool = false,
    no_bring_to_front_on_focus: bool = false,
    always_vertical_scrollbar: bool = false,
    always_horizontal_scrollbar: bool = false,
    no_nav_inputs: bool = false,
    no_nav_focus: bool = false,
    unsaved_document: bool = false,
    no_docking: bool = false,
    _padding: u12 = 0,
};

pub const TextureID = u64;
pub const DrawIdx = c_ushort;
pub const Wchar32 = c_uint;
pub const Wchar16 = c_ushort;
// pub const Wchar = c_uint;
pub const Wchar = Wchar16;
pub const SelectionUserData = i64;
pub const InputTextCallback = *const fn (data: [*c]InputTextCallbackData) callconv(.C) c_int;
pub const SizeCallback = *const fn (data: [*c]SizeCallbackData) callconv(.C) void;
pub const MemAllocFunc = ?*const fn (sz: usize, user_data: *anyopaque) callconv(.C) *anyopaque;
pub const MemFreeFunc = ?*const fn (ptr: *anyopaque, user_data: *anyopaque) callconv(.C) void;
pub const DrawCallback = *const fn (parent_list: [*c]const DrawList, cmd: [*c]const DrawCmd) callconv(.C) void;

pub const ChildFlag = struct {
    pub const none = 0x0;
    pub const borders = 0x1;
    pub const always_use_window_padding = 0x2;
    pub const resize_x = 0x4;
    pub const resize_y = 0x8;
    pub const auto_resize_x = 0x10;
    pub const auto_resize_y = 0x20;
    pub const always_auto_resize = 0x40;
    pub const frame_style = 0x80;
    pub const nav_flattened = 0x100;
    pub const border = 0x1;
};

pub const ItemFlag = struct {
    pub const none = 0x0;
    pub const no_tab_stop = 0x1;
    pub const no_nav = 0x2;
    pub const no_nav_default_focus = 0x4;
    pub const button_repeat = 0x8;
    pub const auto_close_popups = 0x10;
    pub const allow_duplicate_id = 0x20;
};

pub const InputTextFlag = struct {
    pub const none = 0x0;
    pub const chars_decimal = 0x1;
    pub const chars_hexadecimal = 0x2;
    pub const chars_scientific = 0x4;
    pub const chars_uppercase = 0x8;
    pub const chars_no_blank = 0x10;
    pub const allow_tab_input = 0x20;
    pub const enter_returns_true = 0x40;
    pub const escape_clears_all = 0x80;
    pub const ctrl_enter_for_new_line = 0x100;
    pub const read_only = 0x200;
    pub const password = 0x400;
    pub const always_overwrite = 0x800;
    pub const auto_select_all = 0x1000;
    pub const parse_empty_ref_val = 0x2000;
    pub const display_empty_ref_val = 0x4000;
    pub const no_horizontal_scroll = 0x8000;
    pub const no_undo_redo = 0x10000;
    pub const callback_completion = 0x20000;
    pub const callback_history = 0x40000;
    pub const callback_always = 0x80000;
    pub const callback_char_filter = 0x100000;
    pub const callback_resize = 0x200000;
    pub const callback_edit = 0x400000;
};

pub const TreeNodeFlag = struct {
    pub const none = 0x0;
    pub const selected = 0x1;
    pub const framed = 0x2;
    pub const allow_overlap = 0x4;
    pub const no_tree_push_on_open = 0x8;
    pub const no_auto_open_on_log = 0x10;
    pub const default_open = 0x20;
    pub const open_on_double_click = 0x40;
    pub const open_on_arrow = 0x80;
    pub const leaf = 0x100;
    pub const bullet = 0x200;
    pub const frame_padding = 0x400;
    pub const span_avail_width = 0x800;
    pub const span_full_width = 0x1000;
    pub const span_text_width = 0x2000;
    pub const span_all_columns = 0x4000;
    pub const nav_left_jumps_back_here = 0x8000;
    pub const collapsing_header = 0x1a;
    pub const allow_item_overlap = 0x4;
};

pub const PopupFlag = struct {
    pub const none = 0x0;
    pub const mouse_button_left = 0x0;
    pub const mouse_button_right = 0x1;
    pub const mouse_button_middle = 0x2;
    pub const mouse_button_mask = 0x1f;
    pub const mouse_button_default = 0x1;
    pub const no_reopen = 0x20;
    pub const no_open_over_existing_popup = 0x80;
    pub const no_open_over_items = 0x100;
    pub const any_popup_id = 0x400;
    pub const any_popup_level = 0x800;
    pub const any_popup = 0xc00;
};

pub const SelectableFlag = struct {
    pub const none = 0x0;
    pub const no_auto_close_popups = 0x1;
    pub const span_all_columns = 0x2;
    pub const allow_double_click = 0x4;
    pub const disabled = 0x8;
    pub const allow_overlap = 0x10;
    pub const highlight = 0x20;
    pub const dont_close_popups = 0x1;
    pub const allow_item_overlap = 0x10;
};

pub const ComboFlag = struct {
    pub const none = 0x0;
    pub const popup_align_left = 0x1;
    pub const height_small = 0x2;
    pub const height_regular = 0x4;
    pub const height_large = 0x8;
    pub const height_largest = 0x10;
    pub const no_arrow_button = 0x20;
    pub const no_preview = 0x40;
    pub const width_fit_preview = 0x80;
    pub const height_mask = 0x1e;
};

pub const TabBarFlag = struct {
    pub const none = 0x0;
    pub const reorderable = 0x1;
    pub const auto_select_new_tabs = 0x2;
    pub const tab_list_popup_button = 0x4;
    pub const no_close_with_middle_mouse_button = 0x8;
    pub const no_tab_list_scrolling_buttons = 0x10;
    pub const no_tooltip = 0x20;
    pub const draw_selected_overline = 0x40;
    pub const fitting_policy_resize_down = 0x80;
    pub const fitting_policy_scroll = 0x100;
    pub const fitting_policy_mask = 0x180;
    pub const fitting_policy_default = 0x80;
};

pub const TabItemFlag = struct {
    pub const none = 0x0;
    pub const unsaved_document = 0x1;
    pub const set_selected = 0x2;
    pub const no_close_with_middle_mouse_button = 0x4;
    pub const no_push_id = 0x8;
    pub const no_tooltip = 0x10;
    pub const no_reorder = 0x20;
    pub const leading = 0x40;
    pub const trailing = 0x80;
    pub const no_assumed_closure = 0x100;
};

pub const FocusedFlag = struct {
    pub const none = 0x0;
    pub const child_windows = 0x1;
    pub const root_window = 0x2;
    pub const any_window = 0x4;
    pub const no_popup_hierarchy = 0x8;
    pub const dock_hierarchy = 0x10;
    pub const root_and_child_windows = 0x3;
};

pub const HoveredFlag = struct {
    pub const none = 0x0;
    pub const child_windows = 0x1;
    pub const root_window = 0x2;
    pub const any_window = 0x4;
    pub const no_popup_hierarchy = 0x8;
    pub const dock_hierarchy = 0x10;
    pub const allow_when_blocked_by_popup = 0x20;
    pub const allow_when_blocked_by_active_item = 0x80;
    pub const allow_when_overlapped_by_item = 0x100;
    pub const allow_when_overlapped_by_window = 0x200;
    pub const allow_when_disabled = 0x400;
    pub const no_nav_override = 0x800;
    pub const allow_when_overlapped = 0x300;
    pub const rect_only = 0x3a0;
    pub const root_and_child_windows = 0x3;
    pub const for_tooltip = 0x1000;
    pub const stationary = 0x2000;
    pub const delay_none = 0x4000;
    pub const delay_short = 0x8000;
    pub const delay_normal = 0x10000;
    pub const no_shared_delay = 0x20000;
};

pub const DockNodeFlag = struct {
    pub const none = 0x0;
    pub const keep_alive_only = 0x1;
    pub const no_docking_over_central_node = 0x4;
    pub const passthru_central_node = 0x8;
    pub const no_docking_split = 0x10;
    pub const no_resize = 0x20;
    pub const auto_hide_tab_bar = 0x40;
    pub const no_undocking = 0x80;
    pub const no_split = 0x10;
    pub const no_docking_in_central_node = 0x4;
};

pub const DragDropFlag = struct {
    pub const none = 0x0;
    pub const source_no_preview_tooltip = 0x1;
    pub const source_no_disable_hover = 0x2;
    pub const source_no_hold_to_open_others = 0x4;
    pub const source_allow_null_id = 0x8;
    pub const source_extern = 0x10;
    pub const payload_auto_expire = 0x20;
    pub const payload_no_cross_context = 0x40;
    pub const payload_no_cross_process = 0x80;
    pub const accept_before_delivery = 0x400;
    pub const accept_no_draw_default_rect = 0x800;
    pub const accept_no_preview_tooltip = 0x1000;
    pub const accept_peek_only = 0xc00;
    pub const source_auto_expire_payload = 0x20;
};

pub const DataType = enum(c_int) {
    s8 = 0x0,
    u8 = 0x1,
    s16 = 0x2,
    u16 = 0x3,
    s32 = 0x4,
    u32 = 0x5,
    s64 = 0x6,
    u64 = 0x7,
    float = 0x8,
    double = 0x9,
    bool = 0xa,
    count = 0xb,
};

pub const Dir = enum(c_int) {
    none = -0x1,
    left = 0x0,
    right = 0x1,
    up = 0x2,
    down = 0x3,
    count = 0x4,
};

pub const SortDirection = enum(u8) {
    none = 0x0,
    ascending = 0x1,
    descending = 0x2,
};

pub const Key = enum(c_int) {
    pub const namedkey_begin = 0x200;
    pub const mod_none = 0x0;
    pub const namedkey_end = 0x29a;
    none = 0x0,
    tab = 0x200,
    left_arrow = 0x201,
    right_arrow = 0x202,
    up_arrow = 0x203,
    down_arrow = 0x204,
    page_up = 0x205,
    page_down = 0x206,
    home = 0x207,
    end = 0x208,
    insert = 0x209,
    delete = 0x20a,
    backspace = 0x20b,
    space = 0x20c,
    enter = 0x20d,
    escape = 0x20e,
    left_ctrl = 0x20f,
    left_shift = 0x210,
    left_alt = 0x211,
    left_super = 0x212,
    right_ctrl = 0x213,
    right_shift = 0x214,
    right_alt = 0x215,
    right_super = 0x216,
    menu = 0x217,
    @"0" = 0x218,
    @"1" = 0x219,
    @"2" = 0x21a,
    @"3" = 0x21b,
    @"4" = 0x21c,
    @"5" = 0x21d,
    @"6" = 0x21e,
    @"7" = 0x21f,
    @"8" = 0x220,
    @"9" = 0x221,
    a = 0x222,
    b = 0x223,
    c = 0x224,
    d = 0x225,
    e = 0x226,
    f = 0x227,
    g = 0x228,
    h = 0x229,
    i = 0x22a,
    j = 0x22b,
    k = 0x22c,
    l = 0x22d,
    m = 0x22e,
    n = 0x22f,
    o = 0x230,
    p = 0x231,
    q = 0x232,
    r = 0x233,
    s = 0x234,
    t = 0x235,
    u = 0x236,
    v = 0x237,
    w = 0x238,
    x = 0x239,
    y = 0x23a,
    z = 0x23b,
    f1 = 0x23c,
    f2 = 0x23d,
    f3 = 0x23e,
    f4 = 0x23f,
    f5 = 0x240,
    f6 = 0x241,
    f7 = 0x242,
    f8 = 0x243,
    f9 = 0x244,
    f10 = 0x245,
    f11 = 0x246,
    f12 = 0x247,
    f13 = 0x248,
    f14 = 0x249,
    f15 = 0x24a,
    f16 = 0x24b,
    f17 = 0x24c,
    f18 = 0x24d,
    f19 = 0x24e,
    f20 = 0x24f,
    f21 = 0x250,
    f22 = 0x251,
    f23 = 0x252,
    f24 = 0x253,
    apostrophe = 0x254,
    comma = 0x255,
    minus = 0x256,
    period = 0x257,
    slash = 0x258,
    semicolon = 0x259,
    equal = 0x25a,
    left_bracket = 0x25b,
    backslash = 0x25c,
    right_bracket = 0x25d,
    grave_accent = 0x25e,
    caps_lock = 0x25f,
    scroll_lock = 0x260,
    num_lock = 0x261,
    print_screen = 0x262,
    pause = 0x263,
    keypad0 = 0x264,
    keypad1 = 0x265,
    keypad2 = 0x266,
    keypad3 = 0x267,
    keypad4 = 0x268,
    keypad5 = 0x269,
    keypad6 = 0x26a,
    keypad7 = 0x26b,
    keypad8 = 0x26c,
    keypad9 = 0x26d,
    keypad_decimal = 0x26e,
    keypad_divide = 0x26f,
    keypad_multiply = 0x270,
    keypad_subtract = 0x271,
    keypad_add = 0x272,
    keypad_enter = 0x273,
    keypad_equal = 0x274,
    app_back = 0x275,
    app_forward = 0x276,
    gamepad_start = 0x277,
    gamepad_back = 0x278,
    gamepad_face_left = 0x279,
    gamepad_face_right = 0x27a,
    gamepad_face_up = 0x27b,
    gamepad_face_down = 0x27c,
    gamepad_dpad_left = 0x27d,
    gamepad_dpad_right = 0x27e,
    gamepad_dpad_up = 0x27f,
    gamepad_dpad_down = 0x280,
    gamepadl1 = 0x281,
    gamepadr1 = 0x282,
    gamepadl2 = 0x283,
    gamepadr2 = 0x284,
    gamepadl3 = 0x285,
    gamepadr3 = 0x286,
    gamepad_l_stick_left = 0x287,
    gamepad_l_stick_right = 0x288,
    gamepad_l_stick_up = 0x289,
    gamepad_l_stick_down = 0x28a,
    gamepad_r_stick_left = 0x28b,
    gamepad_r_stick_right = 0x28c,
    gamepad_r_stick_up = 0x28d,
    gamepad_r_stick_down = 0x28e,
    mouse_left = 0x28f,
    mouse_right = 0x290,
    mouse_middle = 0x291,
    mousex1 = 0x292,
    mousex2 = 0x293,
    mouse_wheel_x = 0x294,
    mouse_wheel_y = 0x295,
    reserved_for_mod_ctrl = 0x296,
    reserved_for_mod_shift = 0x297,
    reserved_for_mod_alt = 0x298,
    reserved_for_mod_super = 0x299,
    namedkey_count = 0x9a,
    mod_ctrl = 0x1000,
    mod_shift = 0x2000,
    mod_alt = 0x4000,
    mod_super = 0x8000,
    mod_mask = 0xf000,
};

pub const InputFlag = struct {
    pub const none = 0x0;
    pub const repeat = 0x1;
    pub const route_active = 0x400;
    pub const route_focused = 0x800;
    pub const route_global = 0x1000;
    pub const route_always = 0x2000;
    pub const route_over_focused = 0x4000;
    pub const route_over_active = 0x8000;
    pub const route_unless_bg_focused = 0x10000;
    pub const route_from_root_window = 0x20000;
    pub const tooltip = 0x40000;
};

pub const ConfigFlag = struct {
    pub const none = 0x0;
    pub const nav_enable_keyboard = 0x1;
    pub const nav_enable_gamepad = 0x2;
    pub const no_mouse = 0x10;
    pub const no_mouse_cursor_change = 0x20;
    pub const no_keyboard = 0x40;
    pub const docking_enable = 0x80;
    pub const viewports_enable = 0x400;
    pub const dpi_enable_scale_viewports = 0x4000;
    pub const dpi_enable_scale_fonts = 0x8000;
    pub const is_srgb = 0x100000;
    pub const is_touch_screen = 0x200000;
    pub const nav_enable_set_mouse_pos = 0x4;
    pub const nav_no_capture_keyboard = 0x8;
};

pub const BackendFlag = struct {
    pub const none = 0x0;
    pub const has_gamepad = 0x1;
    pub const has_mouse_cursors = 0x2;
    pub const has_set_mouse_pos = 0x4;
    pub const renderer_has_vtx_offset = 0x8;
    pub const platform_has_viewports = 0x400;
    pub const has_mouse_hovered_viewport = 0x800;
    pub const renderer_has_viewports = 0x1000;
};

pub const Col = enum(c_int) {
    text = 0x0,
    text_disabled = 0x1,
    window_bg = 0x2,
    child_bg = 0x3,
    popup_bg = 0x4,
    border = 0x5,
    border_shadow = 0x6,
    frame_bg = 0x7,
    frame_bg_hovered = 0x8,
    frame_bg_active = 0x9,
    title_bg = 0xa,
    title_bg_active = 0xb,
    title_bg_collapsed = 0xc,
    menu_bar_bg = 0xd,
    scrollbar_bg = 0xe,
    scrollbar_grab = 0xf,
    scrollbar_grab_hovered = 0x10,
    scrollbar_grab_active = 0x11,
    check_mark = 0x12,
    slider_grab = 0x13,
    slider_grab_active = 0x14,
    button = 0x15,
    button_hovered = 0x16,
    button_active = 0x17,
    header = 0x18,
    header_hovered = 0x19,
    header_active = 0x1a,
    separator = 0x1b,
    separator_hovered = 0x1c,
    separator_active = 0x1d,
    resize_grip = 0x1e,
    resize_grip_hovered = 0x1f,
    resize_grip_active = 0x20,
    tab_hovered = 0x21,
    tab = 0x22,
    tab_selected = 0x23,
    tab_selected_overline = 0x24,
    tab_dimmed = 0x25,
    tab_dimmed_selected = 0x26,
    tab_dimmed_selected_overline = 0x27,
    docking_preview = 0x28,
    docking_empty_bg = 0x29,
    plot_lines = 0x2a,
    plot_lines_hovered = 0x2b,
    plot_histogram = 0x2c,
    plot_histogram_hovered = 0x2d,
    table_header_bg = 0x2e,
    table_border_strong = 0x2f,
    table_border_light = 0x30,
    table_row_bg = 0x31,
    table_row_bg_alt = 0x32,
    text_link = 0x33,
    text_selected_bg = 0x34,
    drag_drop_target = 0x35,
    nav_cursor = 0x36,
    nav_windowing_highlight = 0x37,
    nav_windowing_dim_bg = 0x38,
    modal_window_dim_bg = 0x39,
    count = 0x3a,
    pub const tab_active = .tab_selected;
    pub const tab_unfocused = .tab_dimmed;
    pub const tab_unfocused_active = .tab_dimmed_selected;
    pub const nav_highlight = .nav_cursor;
};

pub const StyleVar = enum(c_int) {
    alpha = 0x0,
    disabled_alpha = 0x1,
    window_padding = 0x2,
    window_rounding = 0x3,
    window_border_size = 0x4,
    window_min_size = 0x5,
    window_title_align = 0x6,
    child_rounding = 0x7,
    child_border_size = 0x8,
    popup_rounding = 0x9,
    popup_border_size = 0xa,
    frame_padding = 0xb,
    frame_rounding = 0xc,
    frame_border_size = 0xd,
    item_spacing = 0xe,
    item_inner_spacing = 0xf,
    indent_spacing = 0x10,
    cell_padding = 0x11,
    scrollbar_size = 0x12,
    scrollbar_rounding = 0x13,
    grab_min_size = 0x14,
    grab_rounding = 0x15,
    tab_rounding = 0x16,
    tab_border_size = 0x17,
    tab_bar_border_size = 0x18,
    tab_bar_overline_size = 0x19,
    table_angled_headers_angle = 0x1a,
    table_angled_headers_text_align = 0x1b,
    button_text_align = 0x1c,
    selectable_text_align = 0x1d,
    separator_text_border_size = 0x1e,
    separator_text_align = 0x1f,
    separator_text_padding = 0x20,
    docking_separator_size = 0x21,
    count = 0x22,
};

pub const ButtonFlag = struct {
    pub const none = 0x0;
    pub const mouse_button_left = 0x1;
    pub const mouse_button_right = 0x2;
    pub const mouse_button_middle = 0x4;
    pub const mouse_button_mask = 0x7;
    pub const enable_nav = 0x8;
};

pub const ColorEditFlag = struct {
    pub const none = 0x0;
    pub const no_alpha = 0x2;
    pub const no_picker = 0x4;
    pub const no_options = 0x8;
    pub const no_small_preview = 0x10;
    pub const no_inputs = 0x20;
    pub const no_tooltip = 0x40;
    pub const no_label = 0x80;
    pub const no_side_preview = 0x100;
    pub const no_drag_drop = 0x200;
    pub const no_border = 0x400;
    pub const alpha_bar = 0x10000;
    pub const alpha_preview = 0x20000;
    pub const alpha_preview_half = 0x40000;
    pub const hdr = 0x80000;
    pub const display_rgb = 0x100000;
    pub const display_hsv = 0x200000;
    pub const display_hex = 0x400000;
    pub const uint8 = 0x800000;
    pub const float = 0x1000000;
    pub const picker_hue_bar = 0x2000000;
    pub const picker_hue_wheel = 0x4000000;
    pub const input_rgb = 0x8000000;
    pub const input_hsv = 0x10000000;
    pub const default_options = 0xa900000;
    pub const display_mask = 0x700000;
    pub const data_type_mask = 0x1800000;
    pub const picker_mask = 0x6000000;
    pub const input_mask = 0x18000000;
};

pub const SliderFlag = struct {
    pub const none = 0x0;
    pub const logarithmic = 0x20;
    pub const no_round_to_format = 0x40;
    pub const no_input = 0x80;
    pub const wrap_around = 0x100;
    pub const clamp_on_input = 0x200;
    pub const clamp_zero_range = 0x400;
    pub const always_clamp = 0x600;
    pub const invalid_mask = 0x7000000f;
};

pub const MouseButton = enum(c_int) {
    left = 0x0,
    right = 0x1,
    middle = 0x2,
    count = 0x5,
};

pub const MouseCursor = enum(c_int) {
    none = -0x1,
    arrow = 0x0,
    text_input = 0x1,
    resize_all = 0x2,
    resize_ns = 0x3,
    resize_ew = 0x4,
    resize_nesw = 0x5,
    resize_nwse = 0x6,
    hand = 0x7,
    not_allowed = 0x8,
    count = 0x9,
};

pub const MouseSource = enum(c_int) {
    mouse = 0x0,
    touch_screen = 0x1,
    pen = 0x2,
    count = 0x3,
};

pub const Cond = enum(c_int) {
    none = 0x0,
    always = 0x1,
    once = 0x2,
    first_use_ever = 0x4,
    appearing = 0x8,
};

pub const TableFlag = struct {
    pub const none = 0x0;
    pub const resizable = 0x1;
    pub const reorderable = 0x2;
    pub const hideable = 0x4;
    pub const sortable = 0x8;
    pub const no_saved_settings = 0x10;
    pub const context_menu_in_body = 0x20;
    pub const row_bg = 0x40;
    pub const borders_inner_h = 0x80;
    pub const borders_outer_h = 0x100;
    pub const borders_inner_v = 0x200;
    pub const borders_outer_v = 0x400;
    pub const borders_h = 0x180;
    pub const borders_v = 0x600;
    pub const borders_inner = 0x280;
    pub const borders_outer = 0x500;
    pub const borders = 0x780;
    pub const no_borders_in_body = 0x800;
    pub const no_borders_in_body_until_resize = 0x1000;
    pub const sizing_fixed_fit = 0x2000;
    pub const sizing_fixed_same = 0x4000;
    pub const sizing_stretch_prop = 0x6000;
    pub const sizing_stretch_same = 0x8000;
    pub const no_host_extend_x = 0x10000;
    pub const no_host_extend_y = 0x20000;
    pub const no_keep_columns_visible = 0x40000;
    pub const precise_widths = 0x80000;
    pub const no_clip = 0x100000;
    pub const pad_outer_x = 0x200000;
    pub const no_pad_outer_x = 0x400000;
    pub const no_pad_inner_x = 0x800000;
    pub const scroll_x = 0x1000000;
    pub const scroll_y = 0x2000000;
    pub const sort_multi = 0x4000000;
    pub const sort_tristate = 0x8000000;
    pub const highlight_hovered_column = 0x10000000;
    pub const sizing_mask = 0xe000;
};

pub const TableColumnFlag = struct {
    pub const none = 0x0;
    pub const disabled = 0x1;
    pub const default_hide = 0x2;
    pub const default_sort = 0x4;
    pub const width_stretch = 0x8;
    pub const width_fixed = 0x10;
    pub const no_resize = 0x20;
    pub const no_reorder = 0x40;
    pub const no_hide = 0x80;
    pub const no_clip = 0x100;
    pub const no_sort = 0x200;
    pub const no_sort_ascending = 0x400;
    pub const no_sort_descending = 0x800;
    pub const no_header_label = 0x1000;
    pub const no_header_width = 0x2000;
    pub const prefer_sort_ascending = 0x4000;
    pub const prefer_sort_descending = 0x8000;
    pub const indent_enable = 0x10000;
    pub const indent_disable = 0x20000;
    pub const angled_header = 0x40000;
    pub const is_enabled = 0x1000000;
    pub const is_visible = 0x2000000;
    pub const is_sorted = 0x4000000;
    pub const is_hovered = 0x8000000;
    pub const width_mask = 0x18;
    pub const indent_mask = 0x30000;
    pub const status_mask = 0xf000000;
    pub const no_direct_resize = 0x40000000;
};

pub const TableRowFlag = struct {
    pub const none = 0x0;
    pub const headers = 0x1;
};

pub const TableBgTarget = enum(c_int) {
    none = 0x0,
    rowbg0 = 0x1,
    rowbg1 = 0x2,
    cell_bg = 0x3,
};

pub const MultiSelectFlag = struct {
    pub const none = 0x0;
    pub const single_select = 0x1;
    pub const no_select_all = 0x2;
    pub const no_range_select = 0x4;
    pub const no_auto_select = 0x8;
    pub const no_auto_clear = 0x10;
    pub const no_auto_clear_on_reselect = 0x20;
    pub const boxselect1d = 0x40;
    pub const boxselect2d = 0x80;
    pub const box_select_no_scroll = 0x100;
    pub const clear_on_escape = 0x200;
    pub const clear_on_click_void = 0x400;
    pub const scope_window = 0x800;
    pub const scope_rect = 0x1000;
    pub const select_on_click = 0x2000;
    pub const select_on_click_release = 0x4000;
    pub const nav_wrap_x = 0x10000;
};

pub const SelectionRequestType = enum(c_int) {
    none = 0x0,
    set_all = 0x1,
    set_range = 0x2,
};

pub const DrawFlag = struct {
    pub const none = 0x0;
    pub const closed = 0x1;
    pub const round_corners_top_left = 0x10;
    pub const round_corners_top_right = 0x20;
    pub const round_corners_bottom_left = 0x40;
    pub const round_corners_bottom_right = 0x80;
    pub const round_corners_none = 0x100;
    pub const round_corners_top = 0x30;
    pub const round_corners_bottom = 0xc0;
    pub const round_corners_left = 0x50;
    pub const round_corners_right = 0xa0;
    pub const round_corners_all = 0xf0;
    pub const round_corners_default = 0xf0;
    pub const round_corners_mask = 0x1f0;
};

pub const DrawListFlag = struct {
    pub const none = 0x0;
    pub const anti_aliased_lines = 0x1;
    pub const anti_aliased_lines_use_tex = 0x2;
    pub const anti_aliased_fill = 0x4;
    pub const allow_vtx_offset = 0x8;
};

pub const FontAtlasFlag = struct {
    pub const none = 0x0;
    pub const no_power_of_two_height = 0x1;
    pub const no_mouse_cursors = 0x2;
    pub const no_baked_lines = 0x4;
};

pub const ViewportFlag = struct {
    pub const none = 0x0;
    pub const is_platform_window = 0x1;
    pub const is_platform_monitor = 0x2;
    pub const owned_by_app = 0x4;
    pub const no_decoration = 0x8;
    pub const no_task_bar_icon = 0x10;
    pub const no_focus_on_appearing = 0x20;
    pub const no_focus_on_click = 0x40;
    pub const no_inputs = 0x80;
    pub const no_renderer_clear = 0x100;
    pub const no_auto_merge = 0x200;
    pub const top_most = 0x400;
    pub const can_host_other_windows = 0x800;
    pub const is_minimized = 0x1000;
    pub const is_focused = 0x2000;
};

pub const DrawListSharedData = opaque {};
pub const FontBuilderIO = opaque {};
pub const Context = opaque {};

pub const Vec2 = extern struct {
    pub const auto: Vec2 = .{ .x = 0, .y = 0 };
    x: f32 = 0,
    y: f32 = 0,
};
pub const Vec4 = extern struct {
    x: f32 = 0,
    y: f32 = 0,
    z: f32 = 0,
    w: f32 = 0,
};
pub const TableSortSpecs = extern struct {
    Specs: [*c]const TableColumnSortSpecs = @import("std").mem.zeroes([*c]const TableColumnSortSpecs),
    SpecsCount: c_int = @import("std").mem.zeroes(c_int),
    SpecsDirty: bool = @import("std").mem.zeroes(bool),
};
pub const TableColumnSortSpecs = extern struct {
    ColumnUserID: u32 = @import("std").mem.zeroes(u32),
    ColumnIndex: i16 = @import("std").mem.zeroes(i16),
    SortOrder: i16 = @import("std").mem.zeroes(i16),
    SortDirection: SortDirection = @import("std").mem.zeroes(SortDirection),
};
pub const Vector_ImWchar = extern struct {
    Size: c_int = @import("std").mem.zeroes(c_int),
    Capacity: c_int = @import("std").mem.zeroes(c_int),
    Data: [*c]Wchar = @import("std").mem.zeroes([*c]Wchar),
};
pub const Vector_TextFilter_TextRange = extern struct {
    Size: c_int = @import("std").mem.zeroes(c_int),
    Capacity: c_int = @import("std").mem.zeroes(c_int),
    Data: [*c]TextFilter_TextRange = @import("std").mem.zeroes([*c]TextFilter_TextRange),
};
pub const Vector_char = extern struct {
    Size: c_int = @import("std").mem.zeroes(c_int),
    Capacity: c_int = @import("std").mem.zeroes(c_int),
    Data: [*c]u8 = @import("std").mem.zeroes([*c]u8),
};
pub const Vector_StoragePair = extern struct {
    Size: c_int = @import("std").mem.zeroes(c_int),
    Capacity: c_int = @import("std").mem.zeroes(c_int),
    Data: [*c]StoragePair = @import("std").mem.zeroes([*c]StoragePair),
};
pub const Vector_SelectionRequest = extern struct {
    Size: c_int = @import("std").mem.zeroes(c_int),
    Capacity: c_int = @import("std").mem.zeroes(c_int),
    Data: [*c]SelectionRequest = @import("std").mem.zeroes([*c]SelectionRequest),
};
pub const Vector_ImDrawCmd = extern struct {
    Size: c_int = @import("std").mem.zeroes(c_int),
    Capacity: c_int = @import("std").mem.zeroes(c_int),
    Data: [*c]DrawCmd = @import("std").mem.zeroes([*c]DrawCmd),
};
pub const Vector_ImDrawIdx = extern struct {
    Size: c_int = @import("std").mem.zeroes(c_int),
    Capacity: c_int = @import("std").mem.zeroes(c_int),
    Data: [*c]DrawIdx = @import("std").mem.zeroes([*c]DrawIdx),
};
pub const Vector_ImDrawChannel = extern struct {
    Size: c_int = @import("std").mem.zeroes(c_int),
    Capacity: c_int = @import("std").mem.zeroes(c_int),
    Data: [*c]DrawChannel = @import("std").mem.zeroes([*c]DrawChannel),
};
pub const Vector_ImDrawVert = extern struct {
    Size: c_int = @import("std").mem.zeroes(c_int),
    Capacity: c_int = @import("std").mem.zeroes(c_int),
    Data: [*c]DrawVert = @import("std").mem.zeroes([*c]DrawVert),
};
pub const Vector_ImVec2 = extern struct {
    Size: c_int = @import("std").mem.zeroes(c_int),
    Capacity: c_int = @import("std").mem.zeroes(c_int),
    Data: [*c]Vec2 = @import("std").mem.zeroes([*c]Vec2),
};
pub const Vector_ImVec4 = extern struct {
    Size: c_int = @import("std").mem.zeroes(c_int),
    Capacity: c_int = @import("std").mem.zeroes(c_int),
    Data: [*c]Vec4 = @import("std").mem.zeroes([*c]Vec4),
};
pub const Vector_ImTextureID = extern struct {
    Size: c_int = @import("std").mem.zeroes(c_int),
    Capacity: c_int = @import("std").mem.zeroes(c_int),
    Data: [*c]TextureID = @import("std").mem.zeroes([*c]TextureID),
};
pub const Vector_ImU8 = extern struct {
    Size: c_int = @import("std").mem.zeroes(c_int),
    Capacity: c_int = @import("std").mem.zeroes(c_int),
    Data: [*c]u8 = @import("std").mem.zeroes([*c]u8),
};
pub const Vector_ImDrawListPtr = extern struct {
    Size: c_int = @import("std").mem.zeroes(c_int),
    Capacity: c_int = @import("std").mem.zeroes(c_int),
    Data: [*c]*DrawList = @import("std").mem.zeroes([*c]*DrawList),
};
pub const Vector_ImU32 = extern struct {
    Size: c_int = @import("std").mem.zeroes(c_int),
    Capacity: c_int = @import("std").mem.zeroes(c_int),
    Data: [*c]u32 = @import("std").mem.zeroes([*c]u32),
};
pub const Vector_ImFontPtr = extern struct {
    Size: c_int = @import("std").mem.zeroes(c_int),
    Capacity: c_int = @import("std").mem.zeroes(c_int),
    Data: [*c][*c]Font = @import("std").mem.zeroes([*c][*c]Font),
};
pub const Vector_ImFontAtlasCustomRect = extern struct {
    Size: c_int = @import("std").mem.zeroes(c_int),
    Capacity: c_int = @import("std").mem.zeroes(c_int),
    Data: [*c]FontAtlasCustomRect = @import("std").mem.zeroes([*c]FontAtlasCustomRect),
};
pub const Vector_ImFontConfig = extern struct {
    Size: c_int = @import("std").mem.zeroes(c_int),
    Capacity: c_int = @import("std").mem.zeroes(c_int),
    Data: [*c]FontConfig = @import("std").mem.zeroes([*c]FontConfig),
};
pub const Vector_float = extern struct {
    Size: c_int = @import("std").mem.zeroes(c_int),
    Capacity: c_int = @import("std").mem.zeroes(c_int),
    Data: [*c]f32 = @import("std").mem.zeroes([*c]f32),
};
pub const Vector_ImFontGlyph = extern struct {
    Size: c_int = @import("std").mem.zeroes(c_int),
    Capacity: c_int = @import("std").mem.zeroes(c_int),
    Data: [*c]FontGlyph = @import("std").mem.zeroes([*c]FontGlyph),
};
pub const Vector_PlatformMonitor = extern struct {
    Size: c_int = @import("std").mem.zeroes(c_int),
    Capacity: c_int = @import("std").mem.zeroes(c_int),
    Data: [*c]PlatformMonitor = @import("std").mem.zeroes([*c]PlatformMonitor),
};
pub const Vector_ViewportPtr = extern struct {
    Size: c_int = @import("std").mem.zeroes(c_int),
    Capacity: c_int = @import("std").mem.zeroes(c_int),
    Data: [*c][*c]Viewport = @import("std").mem.zeroes([*c][*c]Viewport),
};
pub const Style = extern struct {
    Alpha: f32 = @import("std").mem.zeroes(f32),
    DisabledAlpha: f32 = @import("std").mem.zeroes(f32),
    WindowPadding: Vec2 = @import("std").mem.zeroes(Vec2),
    WindowRounding: f32 = @import("std").mem.zeroes(f32),
    WindowBorderSize: f32 = @import("std").mem.zeroes(f32),
    WindowMinSize: Vec2 = @import("std").mem.zeroes(Vec2),
    WindowTitleAlign: Vec2 = @import("std").mem.zeroes(Vec2),
    WindowMenuButtonPosition: Dir = @import("std").mem.zeroes(Dir),
    ChildRounding: f32 = @import("std").mem.zeroes(f32),
    ChildBorderSize: f32 = @import("std").mem.zeroes(f32),
    PopupRounding: f32 = @import("std").mem.zeroes(f32),
    PopupBorderSize: f32 = @import("std").mem.zeroes(f32),
    FramePadding: Vec2 = @import("std").mem.zeroes(Vec2),
    FrameRounding: f32 = @import("std").mem.zeroes(f32),
    FrameBorderSize: f32 = @import("std").mem.zeroes(f32),
    ItemSpacing: Vec2 = @import("std").mem.zeroes(Vec2),
    ItemInnerSpacing: Vec2 = @import("std").mem.zeroes(Vec2),
    CellPadding: Vec2 = @import("std").mem.zeroes(Vec2),
    TouchExtraPadding: Vec2 = @import("std").mem.zeroes(Vec2),
    IndentSpacing: f32 = @import("std").mem.zeroes(f32),
    ColumnsMinSpacing: f32 = @import("std").mem.zeroes(f32),
    ScrollbarSize: f32 = @import("std").mem.zeroes(f32),
    ScrollbarRounding: f32 = @import("std").mem.zeroes(f32),
    GrabMinSize: f32 = @import("std").mem.zeroes(f32),
    GrabRounding: f32 = @import("std").mem.zeroes(f32),
    LogSliderDeadzone: f32 = @import("std").mem.zeroes(f32),
    TabRounding: f32 = @import("std").mem.zeroes(f32),
    TabBorderSize: f32 = @import("std").mem.zeroes(f32),
    TabMinWidthForCloseButton: f32 = @import("std").mem.zeroes(f32),
    TabBarBorderSize: f32 = @import("std").mem.zeroes(f32),
    TabBarOverlineSize: f32 = @import("std").mem.zeroes(f32),
    TableAngledHeadersAngle: f32 = @import("std").mem.zeroes(f32),
    TableAngledHeadersTextAlign: Vec2 = @import("std").mem.zeroes(Vec2),
    ColorButtonPosition: Dir = @import("std").mem.zeroes(Dir),
    ButtonTextAlign: Vec2 = @import("std").mem.zeroes(Vec2),
    SelectableTextAlign: Vec2 = @import("std").mem.zeroes(Vec2),
    SeparatorTextBorderSize: f32 = @import("std").mem.zeroes(f32),
    SeparatorTextAlign: Vec2 = @import("std").mem.zeroes(Vec2),
    SeparatorTextPadding: Vec2 = @import("std").mem.zeroes(Vec2),
    DisplayWindowPadding: Vec2 = @import("std").mem.zeroes(Vec2),
    DisplaySafeAreaPadding: Vec2 = @import("std").mem.zeroes(Vec2),
    DockingSeparatorSize: f32 = @import("std").mem.zeroes(f32),
    MouseCursorScale: f32 = @import("std").mem.zeroes(f32),
    AntiAliasedLines: bool = @import("std").mem.zeroes(bool),
    AntiAliasedLinesUseTex: bool = @import("std").mem.zeroes(bool),
    AntiAliasedFill: bool = @import("std").mem.zeroes(bool),
    CurveTessellationTol: f32 = @import("std").mem.zeroes(f32),
    CircleTessellationMaxError: f32 = @import("std").mem.zeroes(f32),
    Colors: [Col.count]Vec4 = @import("std").mem.zeroes([Col.count]Vec4),
    HoverStationaryDelay: f32 = @import("std").mem.zeroes(f32),
    HoverDelayShort: f32 = @import("std").mem.zeroes(f32),
    HoverDelayNormal: f32 = @import("std").mem.zeroes(f32),
    HoverFlagsForTooltipMouse: HoveredFlags = @import("std").mem.zeroes(HoveredFlags),
    HoverFlagsForTooltipNav: HoveredFlags = @import("std").mem.zeroes(HoveredFlags),
    pub const ScaleAllSizes = ImGuiStyle_ScaleAllSizes;
};
pub const KeyData = extern struct {
    Down: bool = @import("std").mem.zeroes(bool),
    DownDuration: f32 = @import("std").mem.zeroes(f32),
    DownDurationPrev: f32 = @import("std").mem.zeroes(f32),
    AnalogValue: f32 = @import("std").mem.zeroes(f32),
};
pub const IO = extern struct {
    ConfigFlags: ConfigFlags = @import("std").mem.zeroes(ConfigFlags),
    BackendFlags: BackendFlags = @import("std").mem.zeroes(BackendFlags),
    DisplaySize: Vec2 = @import("std").mem.zeroes(Vec2),
    DeltaTime: f32 = @import("std").mem.zeroes(f32),
    IniSavingRate: f32 = @import("std").mem.zeroes(f32),
    IniFilename: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    LogFilename: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    UserData: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    Fonts: [*c]FontAtlas = @import("std").mem.zeroes([*c]FontAtlas),
    FontGlobalScale: f32 = @import("std").mem.zeroes(f32),
    FontAllowUserScaling: bool = @import("std").mem.zeroes(bool),
    FontDefault: [*c]Font = @import("std").mem.zeroes([*c]Font),
    DisplayFramebufferScale: Vec2 = @import("std").mem.zeroes(Vec2),
    ConfigNavSwapGamepadButtons: bool = @import("std").mem.zeroes(bool),
    ConfigNavMoveSetMousePos: bool = @import("std").mem.zeroes(bool),
    ConfigNavCaptureKeyboard: bool = @import("std").mem.zeroes(bool),
    ConfigNavEscapeClearFocusItem: bool = @import("std").mem.zeroes(bool),
    ConfigNavEscapeClearFocusWindow: bool = @import("std").mem.zeroes(bool),
    ConfigNavCursorVisibleAuto: bool = @import("std").mem.zeroes(bool),
    ConfigNavCursorVisibleAlways: bool = @import("std").mem.zeroes(bool),
    ConfigDockingNoSplit: bool = @import("std").mem.zeroes(bool),
    ConfigDockingWithShift: bool = @import("std").mem.zeroes(bool),
    ConfigDockingAlwaysTabBar: bool = @import("std").mem.zeroes(bool),
    ConfigDockingTransparentPayload: bool = @import("std").mem.zeroes(bool),
    ConfigViewportsNoAutoMerge: bool = @import("std").mem.zeroes(bool),
    ConfigViewportsNoTaskBarIcon: bool = @import("std").mem.zeroes(bool),
    ConfigViewportsNoDecoration: bool = @import("std").mem.zeroes(bool),
    ConfigViewportsNoDefaultParent: bool = @import("std").mem.zeroes(bool),
    MouseDrawCursor: bool = @import("std").mem.zeroes(bool),
    ConfigMacOSXBehaviors: bool = @import("std").mem.zeroes(bool),
    ConfigInputTrickleEventQueue: bool = @import("std").mem.zeroes(bool),
    ConfigInputTextCursorBlink: bool = @import("std").mem.zeroes(bool),
    ConfigInputTextEnterKeepActive: bool = @import("std").mem.zeroes(bool),
    ConfigDragClickToInputText: bool = @import("std").mem.zeroes(bool),
    ConfigWindowsResizeFromEdges: bool = @import("std").mem.zeroes(bool),
    ConfigWindowsMoveFromTitleBarOnly: bool = @import("std").mem.zeroes(bool),
    ConfigWindowsCopyContentsWithCtrlC: bool = @import("std").mem.zeroes(bool),
    ConfigScrollbarScrollByPage: bool = @import("std").mem.zeroes(bool),
    ConfigMemoryCompactTimer: f32 = @import("std").mem.zeroes(f32),
    MouseDoubleClickTime: f32 = @import("std").mem.zeroes(f32),
    MouseDoubleClickMaxDist: f32 = @import("std").mem.zeroes(f32),
    MouseDragThreshold: f32 = @import("std").mem.zeroes(f32),
    KeyRepeatDelay: f32 = @import("std").mem.zeroes(f32),
    KeyRepeatRate: f32 = @import("std").mem.zeroes(f32),
    ConfigErrorRecovery: bool = @import("std").mem.zeroes(bool),
    ConfigErrorRecoveryEnableAssert: bool = @import("std").mem.zeroes(bool),
    ConfigErrorRecoveryEnableDebugLog: bool = @import("std").mem.zeroes(bool),
    ConfigErrorRecoveryEnableTooltip: bool = @import("std").mem.zeroes(bool),
    ConfigDebugIsDebuggerPresent: bool = @import("std").mem.zeroes(bool),
    ConfigDebugHighlightIdConflicts: bool = @import("std").mem.zeroes(bool),
    ConfigDebugBeginReturnValueOnce: bool = @import("std").mem.zeroes(bool),
    ConfigDebugBeginReturnValueLoop: bool = @import("std").mem.zeroes(bool),
    ConfigDebugIgnoreFocusLoss: bool = @import("std").mem.zeroes(bool),
    ConfigDebugIniSettings: bool = @import("std").mem.zeroes(bool),
    BackendPlatformName: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    BackendRendererName: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    BackendPlatformUserData: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    BackendRendererUserData: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    BackendLanguageUserData: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    WantCaptureMouse: bool = @import("std").mem.zeroes(bool),
    WantCaptureKeyboard: bool = @import("std").mem.zeroes(bool),
    WantTextInput: bool = @import("std").mem.zeroes(bool),
    WantSetMousePos: bool = @import("std").mem.zeroes(bool),
    WantSaveIniSettings: bool = @import("std").mem.zeroes(bool),
    NavActive: bool = @import("std").mem.zeroes(bool),
    NavVisible: bool = @import("std").mem.zeroes(bool),
    Framerate: f32 = @import("std").mem.zeroes(f32),
    MetricsRenderVertices: c_int = @import("std").mem.zeroes(c_int),
    MetricsRenderIndices: c_int = @import("std").mem.zeroes(c_int),
    MetricsRenderWindows: c_int = @import("std").mem.zeroes(c_int),
    MetricsActiveWindows: c_int = @import("std").mem.zeroes(c_int),
    MouseDelta: Vec2 = @import("std").mem.zeroes(Vec2),
    Ctx: ?*Context = @import("std").mem.zeroes(?*Context),
    MousePos: Vec2 = @import("std").mem.zeroes(Vec2),
    MouseDown: [5]bool = @import("std").mem.zeroes([5]bool),
    MouseWheel: f32 = @import("std").mem.zeroes(f32),
    MouseWheelH: f32 = @import("std").mem.zeroes(f32),
    MouseSource: MouseSource = @import("std").mem.zeroes(MouseSource),
    MouseHoveredViewport: u32 = @import("std").mem.zeroes(u32),
    KeyCtrl: bool = @import("std").mem.zeroes(bool),
    KeyShift: bool = @import("std").mem.zeroes(bool),
    KeyAlt: bool = @import("std").mem.zeroes(bool),
    KeySuper: bool = @import("std").mem.zeroes(bool),
    KeyMods: KeyChord = @import("std").mem.zeroes(KeyChord),
    KeysData: [@intFromEnum(Key.namedkey_count)]KeyData = @import("std").mem.zeroes([@intFromEnum(Key.namedkey_count)]KeyData),
    WantCaptureMouseUnlessPopupClose: bool = @import("std").mem.zeroes(bool),
    MousePosPrev: Vec2 = @import("std").mem.zeroes(Vec2),
    MouseClickedPos: [5]Vec2 = @import("std").mem.zeroes([5]Vec2),
    MouseClickedTime: [5]f64 = @import("std").mem.zeroes([5]f64),
    MouseClicked: [5]bool = @import("std").mem.zeroes([5]bool),
    MouseDoubleClicked: [5]bool = @import("std").mem.zeroes([5]bool),
    MouseClickedCount: [5]u16 = @import("std").mem.zeroes([5]u16),
    MouseClickedLastCount: [5]u16 = @import("std").mem.zeroes([5]u16),
    MouseReleased: [5]bool = @import("std").mem.zeroes([5]bool),
    MouseDownOwned: [5]bool = @import("std").mem.zeroes([5]bool),
    MouseDownOwnedUnlessPopupClose: [5]bool = @import("std").mem.zeroes([5]bool),
    MouseWheelRequestAxisSwap: bool = @import("std").mem.zeroes(bool),
    MouseCtrlLeftAsRightClick: bool = @import("std").mem.zeroes(bool),
    MouseDownDuration: [5]f32 = @import("std").mem.zeroes([5]f32),
    MouseDownDurationPrev: [5]f32 = @import("std").mem.zeroes([5]f32),
    MouseDragMaxDistanceAbs: [5]Vec2 = @import("std").mem.zeroes([5]Vec2),
    MouseDragMaxDistanceSqr: [5]f32 = @import("std").mem.zeroes([5]f32),
    PenPressure: f32 = @import("std").mem.zeroes(f32),
    AppFocusLost: bool = @import("std").mem.zeroes(bool),
    AppAcceptingEvents: bool = @import("std").mem.zeroes(bool),
    InputQueueSurrogate: c_ushort = @import("std").mem.zeroes(c_ushort),
    InputQueueCharacters: Vector_ImWchar = @import("std").mem.zeroes(Vector_ImWchar),
    GetClipboardTextFn: ?*const fn (user_data: *anyopaque) callconv(.C) [*c]const u8 = @import("std").mem.zeroes(?*const fn (user_data: *anyopaque) callconv(.C) [*c]const u8),
    SetClipboardTextFn: ?*const fn (user_data: *anyopaque, text: [*c]const u8) callconv(.C) void = @import("std").mem.zeroes(?*const fn (user_data: *anyopaque, text: [*c]const u8) callconv(.C) void),
    ClipboardUserData: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    pub const AddKeyEvent = ImGuiIO_AddKeyEvent;
    pub const AddKeyAnalogEvent = ImGuiIO_AddKeyAnalogEvent;
    pub const AddMousePosEvent = ImGuiIO_AddMousePosEvent;
    pub const AddMouseButtonEvent = ImGuiIO_AddMouseButtonEvent;
    pub const AddMouseWheelEvent = ImGuiIO_AddMouseWheelEvent;
    pub const AddMouseSourceEvent = ImGuiIO_AddMouseSourceEvent;
    pub const AddMouseViewportEvent = ImGuiIO_AddMouseViewportEvent;
    pub const AddFocusEvent = ImGuiIO_AddFocusEvent;
    pub const AddInputCharacter = ImGuiIO_AddInputCharacter;
    pub const AddInputCharacterUTF16 = ImGuiIO_AddInputCharacterUTF16;
    pub const AddInputCharactersUTF8 = ImGuiIO_AddInputCharactersUTF8;
    pub const SetKeyEventNativeData = ImGuiIO_SetKeyEventNativeData;
    pub const SetKeyEventNativeDataEx = ImGuiIO_SetKeyEventNativeDataEx;
    pub const SetAppAcceptingEvents = ImGuiIO_SetAppAcceptingEvents;
    pub const ClearEventsQueue = ImGuiIO_ClearEventsQueue;
    pub const ClearInputKeys = ImGuiIO_ClearInputKeys;
    pub const ClearInputMouse = ImGuiIO_ClearInputMouse;
    pub const ClearInputCharacters = ImGuiIO_ClearInputCharacters;
};
pub const InputTextCallbackData = extern struct {
    Ctx: [*c]Context = @import("std").mem.zeroes([*c]Context),
    EventFlag: InputTextFlags = @import("std").mem.zeroes(InputTextFlags),
    Flags: InputTextFlags = @import("std").mem.zeroes(InputTextFlags),
    UserData: *anyopaque = @import("std").mem.zeroes(*anyopaque),
    EventChar: Wchar = @import("std").mem.zeroes(Wchar),
    EventKey: Key = @import("std").mem.zeroes(Key),
    Buf: [*c]u8 = @import("std").mem.zeroes([*c]u8),
    BufTextLen: c_int = @import("std").mem.zeroes(c_int),
    BufSize: c_int = @import("std").mem.zeroes(c_int),
    BufDirty: bool = @import("std").mem.zeroes(bool),
    CursorPos: c_int = @import("std").mem.zeroes(c_int),
    SelectionStart: c_int = @import("std").mem.zeroes(c_int),
    SelectionEnd: c_int = @import("std").mem.zeroes(c_int),
    pub const DeleteChars = ImGuiInputTextCallbackData_DeleteChars;
    pub const InsertChars = ImGuiInputTextCallbackData_InsertChars;
    pub const SelectAll = ImGuiInputTextCallbackData_SelectAll;
    pub const ClearSelection = ImGuiInputTextCallbackData_ClearSelection;
    pub const HasSelection = ImGuiInputTextCallbackData_HasSelection;
};
pub const SizeCallbackData = extern struct {
    UserData: *anyopaque = @import("std").mem.zeroes(*anyopaque),
    Pos: Vec2 = @import("std").mem.zeroes(Vec2),
    CurrentSize: Vec2 = @import("std").mem.zeroes(Vec2),
    DesiredSize: Vec2 = @import("std").mem.zeroes(Vec2),
};
pub const WindowClass = extern struct {
    ClassId: u32 = @import("std").mem.zeroes(u32),
    ParentViewportId: u32 = @import("std").mem.zeroes(u32),
    FocusRouteParentWindowId: u32 = @import("std").mem.zeroes(u32),
    ViewportFlagsOverrideSet: ViewportFlags = @import("std").mem.zeroes(ViewportFlags),
    ViewportFlagsOverrideClear: ViewportFlags = @import("std").mem.zeroes(ViewportFlags),
    TabItemFlagsOverrideSet: TabItemFlags = @import("std").mem.zeroes(TabItemFlags),
    DockNodeFlagsOverrideSet: DockNodeFlags = @import("std").mem.zeroes(DockNodeFlags),
    DockingAlwaysTabBar: bool = @import("std").mem.zeroes(bool),
    DockingAllowUnclassed: bool = @import("std").mem.zeroes(bool),
};

pub const Payload = extern struct {
    Data: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    DataSize: c_int = @import("std").mem.zeroes(c_int),
    SourceId: u32 = @import("std").mem.zeroes(u32),
    SourceParentId: u32 = @import("std").mem.zeroes(u32),
    DataFrameCount: c_int = @import("std").mem.zeroes(c_int),
    DataType: [32 + 1]u8 = @import("std").mem.zeroes([32 + 1]u8),
    Preview: bool = @import("std").mem.zeroes(bool),
    Delivery: bool = @import("std").mem.zeroes(bool),
    pub const Clear = ImGuiPayload_Clear;
    pub const IsDataType = ImGuiPayload_IsDataType;
    pub const IsPreview = ImGuiPayload_IsPreview;
    pub const IsDelivery = ImGuiPayload_IsDelivery;
};

pub const TextFilter_TextRange = extern struct {
    b: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    e: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
    pub const empty = ImGuiTextFilter_ImGuiTextRange_empty;
    pub const split = ImGuiTextFilter_ImGuiTextRange_split;
};
pub const TextFilter = extern struct {
    InputBuf: [256]u8 = @import("std").mem.zeroes([256]u8),
    Filters: Vector_TextFilter_TextRange = @import("std").mem.zeroes(Vector_TextFilter_TextRange),
    CountGrep: c_int = @import("std").mem.zeroes(c_int),
    pub const Draw = ImGuiTextFilter_Draw;
    pub const PassFilter = ImGuiTextFilter_PassFilter;
    pub const Build = ImGuiTextFilter_Build;
    pub const Clear = ImGuiTextFilter_Clear;
    pub const IsActive = ImGuiTextFilter_IsActive;
};
pub const TextBuffer = extern struct {
    Buf: Vector_char = @import("std").mem.zeroes(Vector_char),
    pub const begin = ImGuiTextBuffer_begin;
    pub const end = ImGuiTextBuffer_end;
    pub const size = ImGuiTextBuffer_size;
    pub const empty = ImGuiTextBuffer_empty;
    pub const clear = ImGuiTextBuffer_clear;
    pub const reserve = ImGuiTextBuffer_reserve;
    pub const c_str = ImGuiTextBuffer_c_str;
    pub const append = ImGuiTextBuffer_append;
    pub const appendf = ImGuiTextBuffer_appendf;
    // pub const appendfv = ImGuiTextBuffer_appendfv;
};
pub const StoragePair = extern struct {
    key: u32 = @import("std").mem.zeroes(u32),
    anonymous_type0: anonymous_type0 = @import("std").mem.zeroes(anonymous_type0),
};
pub const anonymous_type0 = extern struct {
    val_i: c_int = @import("std").mem.zeroes(c_int),
    val_f: f32 = @import("std").mem.zeroes(f32),
    val_p: *anyopaque = @import("std").mem.zeroes(*anyopaque),
};
pub const Storage = extern struct {
    Data: Vector_StoragePair = @import("std").mem.zeroes(Vector_StoragePair),
    pub const Clear = ImGuiStorage_Clear;
    pub const GetInt = ImGuiStorage_GetInt;
    pub const SetInt = ImGuiStorage_SetInt;
    pub const GetBool = ImGuiStorage_GetBool;
    pub const SetBool = ImGuiStorage_SetBool;
    pub const GetFloat = ImGuiStorage_GetFloat;
    pub const SetFloat = ImGuiStorage_SetFloat;
    pub const GetVoidPtr = ImGuiStorage_GetVoidPtr;
    pub const SetVoidPtr = ImGuiStorage_SetVoidPtr;
    pub const GetIntRef = ImGuiStorage_GetIntRef;
    pub const GetBoolRef = ImGuiStorage_GetBoolRef;
    pub const GetFloatRef = ImGuiStorage_GetFloatRef;
    pub const GetVoidPtrRef = ImGuiStorage_GetVoidPtrRef;
    pub const BuildSortByKey = ImGuiStorage_BuildSortByKey;
    pub const SetAllInt = ImGuiStorage_SetAllInt;
};
pub const ListClipper = extern struct {
    Ctx: [*c]Context = @import("std").mem.zeroes([*c]Context),
    DisplayStart: c_int = @import("std").mem.zeroes(c_int),
    DisplayEnd: c_int = @import("std").mem.zeroes(c_int),
    ItemsCount: c_int = @import("std").mem.zeroes(c_int),
    ItemsHeight: f32 = @import("std").mem.zeroes(f32),
    StartPosY: f32 = @import("std").mem.zeroes(f32),
    StartSeekOffsetY: f64 = @import("std").mem.zeroes(f64),
    TempData: *anyopaque = @import("std").mem.zeroes(*anyopaque),
    pub const Begin = ImGuiListClipper_Begin;
    pub const End = ImGuiListClipper_End;
    pub const Step = ImGuiListClipper_Step;
    pub const IncludeItemByIndex = ImGuiListClipper_IncludeItemByIndex;
    pub const IncludeItemsByIndex = ImGuiListClipper_IncludeItemsByIndex;
    pub const SeekCursorForItem = ImGuiListClipper_SeekCursorForItem;
    pub const IncludeRangeByIndices = ImGuiListClipper_IncludeRangeByIndices;
    pub const ForceDisplayRangeByIndices = ImGuiListClipper_ForceDisplayRangeByIndices;
};
pub const Color = extern struct {
    Value: Vec4 = @import("std").mem.zeroes(Vec4),
    pub const SetHSV = ImColor_SetHSV;
};
pub const MultiSelectIO = extern struct {
    Requests: Vector_SelectionRequest = @import("std").mem.zeroes(Vector_SelectionRequest),
    RangeSrcItem: SelectionUserData = @import("std").mem.zeroes(SelectionUserData),
    NavIdItem: SelectionUserData = @import("std").mem.zeroes(SelectionUserData),
    NavIdSelected: bool = @import("std").mem.zeroes(bool),
    RangeSrcReset: bool = @import("std").mem.zeroes(bool),
    ItemsCount: c_int = @import("std").mem.zeroes(c_int),
};
pub const SelectionRequest = extern struct {
    Type: SelectionRequestType = @import("std").mem.zeroes(SelectionRequestType),
    Selected: bool = @import("std").mem.zeroes(bool),
    RangeDirection: i8 = @import("std").mem.zeroes(i8),
    RangeFirstItem: SelectionUserData = @import("std").mem.zeroes(SelectionUserData),
    RangeLastItem: SelectionUserData = @import("std").mem.zeroes(SelectionUserData),
};
pub const SelectionBasicStorage = extern struct {
    Size: c_int = @import("std").mem.zeroes(c_int),
    PreserveOrder: bool = @import("std").mem.zeroes(bool),
    UserData: *anyopaque = @import("std").mem.zeroes(*anyopaque),
    AdapterIndexToStorageId: ?*const fn (self: [*c]SelectionBasicStorage, idx: c_int) u32 = @import("std").mem.zeroes(?*const fn (self: [*c]SelectionBasicStorage, idx: c_int) u32),
    SelectionOrder: c_int = @import("std").mem.zeroes(c_int),
    Storage: Storage = @import("std").mem.zeroes(Storage),
    pub const ApplyRequests = ImGuiSelectionBasicStorage_ApplyRequests;
    pub const Contains = ImGuiSelectionBasicStorage_Contains;
    pub const Clear = ImGuiSelectionBasicStorage_Clear;
    pub const Swap = ImGuiSelectionBasicStorage_Swap;
    pub const SetItemSelected = ImGuiSelectionBasicStorage_SetItemSelected;
    pub const GetNextSelectedItem = ImGuiSelectionBasicStorage_GetNextSelectedItem;
    pub const GetStorageIdFromIndex = ImGuiSelectionBasicStorage_GetStorageIdFromIndex;
};
pub const SelectionExternalStorage = extern struct {
    UserData: *anyopaque = @import("std").mem.zeroes(*anyopaque),
    AdapterSetItemSelected: ?*const fn (self: [*c]SelectionExternalStorage, idx: c_int, selected: bool) void = @import("std").mem.zeroes(?*const fn (self: [*c]SelectionExternalStorage, idx: c_int, selected: bool) void),
    pub const ApplyRequests = ImGuiSelectionExternalStorage_ApplyRequests;
};
pub const DrawCmd = extern struct {
    clip_rect: Vec4 = .{},
    texture_id: TextureID = 0,
    vtx_offset: c_uint = 0,
    idx_offset: c_uint = 0,
    elem_count: c_uint = 0,
    user_callback: ?DrawCallback,
    user_callback_data: ?*anyopaque = null,
    user_callback_data_size: c_int = 0,
    user_callback_data_offset: c_int = 0,
    pub const GetTexID = ImDrawCmd_GetTexID;
};
pub const DrawVert = extern struct {
    pos: Vec2 = @import("std").mem.zeroes(Vec2),
    uv: Vec2 = @import("std").mem.zeroes(Vec2),
    col: u32 = @import("std").mem.zeroes(u32),
};
pub const DrawCmdHeader = extern struct {
    ClipRect: Vec4 = @import("std").mem.zeroes(Vec4),
    TextureId: TextureID = @import("std").mem.zeroes(TextureID),
    VtxOffset: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const DrawChannel = extern struct {
    CmdBuffer: Vector_ImDrawCmd = @import("std").mem.zeroes(Vector_ImDrawCmd),
    IdxBuffer: Vector_ImDrawIdx = @import("std").mem.zeroes(Vector_ImDrawIdx),
};
pub const DrawListSplitter = extern struct {
    Current: c_int = @import("std").mem.zeroes(c_int),
    Count: c_int = @import("std").mem.zeroes(c_int),
    Channels: Vector_ImDrawChannel = @import("std").mem.zeroes(Vector_ImDrawChannel),
    pub const Clear = ImDrawListSplitter_Clear;
    pub const ClearFreeMemory = ImDrawListSplitter_ClearFreeMemory;
    pub const Split = ImDrawListSplitter_Split;
    pub const Merge = ImDrawListSplitter_Merge;
    pub const SetCurrentChannel = ImDrawListSplitter_SetCurrentChannel;
};

pub const DrawList = extern struct {
    cmd_buffer: Vector_ImDrawCmd = @import("std").mem.zeroes(Vector_ImDrawCmd),
    idx_buffer: Vector_ImDrawIdx = @import("std").mem.zeroes(Vector_ImDrawIdx),
    vtx_buffer: Vector_ImDrawVert = @import("std").mem.zeroes(Vector_ImDrawVert),
    flags: DrawListFlags = @import("std").mem.zeroes(DrawListFlags),

    // Internal
    _VtxCurrentIdx: c_uint = @import("std").mem.zeroes(c_uint),
    _Data: ?*DrawListSharedData = @import("std").mem.zeroes(?*DrawListSharedData),
    _VtxWritePtr: [*c]DrawVert = @import("std").mem.zeroes([*c]DrawVert),
    _IdxWritePtr: [*c]DrawIdx = @import("std").mem.zeroes([*c]DrawIdx),
    _Path: Vector_ImVec2 = @import("std").mem.zeroes(Vector_ImVec2),
    _CmdHeader: DrawCmdHeader = @import("std").mem.zeroes(DrawCmdHeader),
    _Splitter: DrawListSplitter = @import("std").mem.zeroes(DrawListSplitter),
    _ClipRectStack: Vector_ImVec4 = @import("std").mem.zeroes(Vector_ImVec4),
    _TextureIdStack: Vector_ImTextureID = @import("std").mem.zeroes(Vector_ImTextureID),
    _CallbacksDataBuf: Vector_ImU8 = @import("std").mem.zeroes(Vector_ImU8),
    _FringeScale: f32 = @import("std").mem.zeroes(f32),
    _OwnerName: ?[*]const u8 = @import("std").mem.zeroes(?[*]const u8),

    pub const PushClipRect = ImDrawList_PushClipRect;
    pub const PushClipRectFullScreen = ImDrawList_PushClipRectFullScreen;
    pub const PopClipRect = ImDrawList_PopClipRect;
    pub const PushTextureID = ImDrawList_PushTextureID;
    pub const PopTextureID = ImDrawList_PopTextureID;
    pub const GetClipRectMin = ImDrawList_GetClipRectMin;
    pub const GetClipRectMax = ImDrawList_GetClipRectMax;
    pub const AddLine = ImDrawList_AddLine;
    pub const AddLineEx = ImDrawList_AddLineEx;
    pub const AddRect = ImDrawList_AddRect;
    pub const AddRectEx = ImDrawList_AddRectEx;
    pub const AddRectFilled = ImDrawList_AddRectFilled;
    pub const AddRectFilledEx = ImDrawList_AddRectFilledEx;
    pub const AddRectFilledMultiColor = ImDrawList_AddRectFilledMultiColor;
    pub const AddQuad = ImDrawList_AddQuad;
    pub const AddQuadEx = ImDrawList_AddQuadEx;
    pub const AddQuadFilled = ImDrawList_AddQuadFilled;
    pub const AddTriangle = ImDrawList_AddTriangle;
    pub const AddTriangleEx = ImDrawList_AddTriangleEx;
    pub const AddTriangleFilled = ImDrawList_AddTriangleFilled;
    pub const AddCircle = ImDrawList_AddCircle;
    pub const AddCircleEx = ImDrawList_AddCircleEx;
    pub const AddCircleFilled = ImDrawList_AddCircleFilled;
    pub const AddNgon = ImDrawList_AddNgon;
    pub const AddNgonEx = ImDrawList_AddNgonEx;
    pub const AddNgonFilled = ImDrawList_AddNgonFilled;
    pub const AddEllipse = ImDrawList_AddEllipse;
    pub const AddEllipseEx = ImDrawList_AddEllipseEx;
    pub const AddEllipseFilled = ImDrawList_AddEllipseFilled;
    pub const AddEllipseFilledEx = ImDrawList_AddEllipseFilledEx;
    pub const AddText = ImDrawList_AddText;
    pub const AddTextEx = ImDrawList_AddTextEx;
    pub const AddTextImFontPtr = ImDrawList_AddTextImFontPtr;
    pub const AddTextImFontPtrEx = ImDrawList_AddTextImFontPtrEx;
    pub const AddBezierCubic = ImDrawList_AddBezierCubic;
    pub const AddBezierQuadratic = ImDrawList_AddBezierQuadratic;
    pub const AddPolyline = ImDrawList_AddPolyline;
    pub const AddConvexPolyFilled = ImDrawList_AddConvexPolyFilled;
    pub const AddConcavePolyFilled = ImDrawList_AddConcavePolyFilled;
    pub const AddImage = ImDrawList_AddImage;
    pub const AddImageEx = ImDrawList_AddImageEx;
    pub const AddImageQuad = ImDrawList_AddImageQuad;
    pub const AddImageQuadEx = ImDrawList_AddImageQuadEx;
    pub const AddImageRounded = ImDrawList_AddImageRounded;
    pub const PathClear = ImDrawList_PathClear;
    pub const PathLineTo = ImDrawList_PathLineTo;
    pub const PathLineToMergeDuplicate = ImDrawList_PathLineToMergeDuplicate;
    pub const PathFillConvex = ImDrawList_PathFillConvex;
    pub const PathFillConcave = ImDrawList_PathFillConcave;
    pub const PathStroke = ImDrawList_PathStroke;
    pub const PathArcTo = ImDrawList_PathArcTo;
    pub const PathArcToFast = ImDrawList_PathArcToFast;
    pub const PathEllipticalArcTo = ImDrawList_PathEllipticalArcTo;
    pub const PathEllipticalArcToEx = ImDrawList_PathEllipticalArcToEx;
    pub const PathBezierCubicCurveTo = ImDrawList_PathBezierCubicCurveTo;
    pub const PathBezierQuadraticCurveTo = ImDrawList_PathBezierQuadraticCurveTo;
    pub const PathRect = ImDrawList_PathRect;
    pub const AddCallback = ImDrawList_AddCallback;
    pub const AddCallbackEx = ImDrawList_AddCallbackEx;
    pub const AddDrawCmd = ImDrawList_AddDrawCmd;
    pub const CloneOutput = ImDrawList_CloneOutput;
    pub const ChannelsSplit = ImDrawList_ChannelsSplit;
    pub const ChannelsMerge = ImDrawList_ChannelsMerge;
    pub const ChannelsSetCurrent = ImDrawList_ChannelsSetCurrent;
    pub const PrimReserve = ImDrawList_PrimReserve;
    pub const PrimUnreserve = ImDrawList_PrimUnreserve;
    pub const PrimRect = ImDrawList_PrimRect;
    pub const PrimRectUV = ImDrawList_PrimRectUV;
    pub const PrimQuadUV = ImDrawList_PrimQuadUV;
    pub const PrimWriteVtx = ImDrawList_PrimWriteVtx;
    pub const PrimWriteIdx = ImDrawList_PrimWriteIdx;
    pub const PrimVtx = ImDrawList_PrimVtx;
    pub const ResetForNewFrame = ImDrawList__ResetForNewFrame;
    pub const ClearFreeMemory = ImDrawList__ClearFreeMemory;
    pub const PopUnusedDrawCmd = ImDrawList__PopUnusedDrawCmd;
    pub const TryMergeDrawCmds = ImDrawList__TryMergeDrawCmds;
    pub const OnChangedClipRect = ImDrawList__OnChangedClipRect;
    pub const OnChangedTextureID = ImDrawList__OnChangedTextureID;
    pub const OnChangedVtxOffset = ImDrawList__OnChangedVtxOffset;
    pub const SetTextureID = ImDrawList__SetTextureID;
    pub const CalcCircleAutoSegmentCount = ImDrawList__CalcCircleAutoSegmentCount;
    pub const PathArcToFastEx = ImDrawList__PathArcToFastEx;
    pub const PathArcToN = ImDrawList__PathArcToN;
};
pub const DrawData = extern struct {
    Valid: bool = @import("std").mem.zeroes(bool),
    CmdListsCount: c_int = @import("std").mem.zeroes(c_int),
    TotalIdxCount: c_int = @import("std").mem.zeroes(c_int),
    TotalVtxCount: c_int = @import("std").mem.zeroes(c_int),
    CmdLists: Vector_ImDrawListPtr = @import("std").mem.zeroes(Vector_ImDrawListPtr),
    DisplayPos: Vec2 = @import("std").mem.zeroes(Vec2),
    DisplaySize: Vec2 = @import("std").mem.zeroes(Vec2),
    FramebufferScale: Vec2 = @import("std").mem.zeroes(Vec2),
    OwnerViewport: [*c]Viewport = @import("std").mem.zeroes([*c]Viewport),
    pub const Clear = ImDrawData_Clear;
    pub const AddDrawList = ImDrawData_AddDrawList;
    pub const DeIndexAllBuffers = ImDrawData_DeIndexAllBuffers;
    pub const ScaleClipRects = ImDrawData_ScaleClipRects;
};
pub const FontConfig = extern struct {
    FontData: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    FontDataSize: c_int = @import("std").mem.zeroes(c_int),
    FontDataOwnedByAtlas: bool = @import("std").mem.zeroes(bool),
    FontNo: c_int = @import("std").mem.zeroes(c_int),
    SizePixels: f32 = @import("std").mem.zeroes(f32),
    OversampleH: c_int = @import("std").mem.zeroes(c_int),
    OversampleV: c_int = @import("std").mem.zeroes(c_int),
    PixelSnapH: bool = @import("std").mem.zeroes(bool),
    GlyphExtraSpacing: Vec2 = @import("std").mem.zeroes(Vec2),
    GlyphOffset: Vec2 = @import("std").mem.zeroes(Vec2),
    GlyphRanges: [*c]const Wchar = @import("std").mem.zeroes([*c]const Wchar),
    GlyphMinAdvanceX: f32 = @import("std").mem.zeroes(f32),
    GlyphMaxAdvanceX: f32 = @import("std").mem.zeroes(f32),
    MergeMode: bool = @import("std").mem.zeroes(bool),
    FontBuilderFlags: c_uint = @import("std").mem.zeroes(c_uint),
    RasterizerMultiply: f32 = @import("std").mem.zeroes(f32),
    RasterizerDensity: f32 = @import("std").mem.zeroes(f32),
    EllipsisChar: Wchar = @import("std").mem.zeroes(Wchar),
    Name: [40]u8 = @import("std").mem.zeroes([40]u8),
    DstFont: [*c]Font = @import("std").mem.zeroes([*c]Font),
};
pub const FontGlyph = extern struct {
    Colored: c_uint = @import("std").mem.zeroes(c_uint),
    Visible: c_uint = @import("std").mem.zeroes(c_uint),
    Codepoint: c_uint = @import("std").mem.zeroes(c_uint),
    AdvanceX: f32 = @import("std").mem.zeroes(f32),
    X0: f32 = @import("std").mem.zeroes(f32),
    Y0: f32 = @import("std").mem.zeroes(f32),
    X1: f32 = @import("std").mem.zeroes(f32),
    Y1: f32 = @import("std").mem.zeroes(f32),
    U0: f32 = @import("std").mem.zeroes(f32),
    V0: f32 = @import("std").mem.zeroes(f32),
    U1: f32 = @import("std").mem.zeroes(f32),
    V1: f32 = @import("std").mem.zeroes(f32),
};
pub const FontGlyphRangesBuilder = extern struct {
    UsedChars: Vector_ImU32 = @import("std").mem.zeroes(Vector_ImU32),
    pub const Clear = ImFontGlyphRangesBuilder_Clear;
    pub const GetBit = ImFontGlyphRangesBuilder_GetBit;
    pub const SetBit = ImFontGlyphRangesBuilder_SetBit;
    pub const AddChar = ImFontGlyphRangesBuilder_AddChar;
    pub const AddText = ImFontGlyphRangesBuilder_AddText;
    pub const AddRanges = ImFontGlyphRangesBuilder_AddRanges;
    pub const BuildRanges = ImFontGlyphRangesBuilder_BuildRanges;
};
pub const FontAtlasCustomRect = extern struct {
    X: c_ushort = @import("std").mem.zeroes(c_ushort),
    Y: c_ushort = @import("std").mem.zeroes(c_ushort),
    Width: c_ushort = @import("std").mem.zeroes(c_ushort),
    Height: c_ushort = @import("std").mem.zeroes(c_ushort),
    GlyphID: c_uint = @import("std").mem.zeroes(c_uint),
    GlyphColored: c_uint = @import("std").mem.zeroes(c_uint),
    GlyphAdvanceX: f32 = @import("std").mem.zeroes(f32),
    GlyphOffset: Vec2 = @import("std").mem.zeroes(Vec2),
    Font: [*c]Font = @import("std").mem.zeroes([*c]Font),
    pub const IsPacked = ImFontAtlasCustomRect_IsPacked;
};
pub const FontAtlas = extern struct {
    flags: FontAtlasFlags = 0,
    tex_id: TextureID = 0,
    tex_desired_width: c_int,
    tex_pack_padding: c_int = 1,
    locked: bool = false,
    user_data: ?*anyopaque = null,
    tex_ready: bool = false,
    tex_pixels_use_colors: bool = false,
    tex_pixels_alpha_8: ?[*]c_char = null,
    tex_pixels_rgba32: ?[*]c_uint = null,
    tex_width: c_int = 0,
    tex_height: c_int = 0,
    tex_uv_scale: Vec2 = .{},
    tex_uv_white_pixel: Vec2 = .{},
    fonts: Vector_ImFontPtr = @import("std").mem.zeroes(Vector_ImFontPtr),
    custom_rects: Vector_ImFontAtlasCustomRect = @import("std").mem.zeroes(Vector_ImFontAtlasCustomRect),
    config_data: Vector_ImFontConfig = @import("std").mem.zeroes(Vector_ImFontConfig),
    tex_uv_lines: [IM_DRAWLIST_TEX_LINES_WIDTH_MAX + 1]Vec4 = @import("std").mem.zeroes([IM_DRAWLIST_TEX_LINES_WIDTH_MAX + 1]Vec4),
    FontBuilderIO: ?*const FontBuilderIO = @import("std").mem.zeroes(?*const FontBuilderIO),
    FontBuilderFlags: c_uint = @import("std").mem.zeroes(c_uint),
    PackIdMouseCursors: c_int = @import("std").mem.zeroes(c_int),
    PackIdLines: c_int = @import("std").mem.zeroes(c_int),
    pub const AddFont = ImFontAtlas_AddFont;
    pub const AddFontDefault = ImFontAtlas_AddFontDefault;
    pub const AddFontFromFileTTF = ImFontAtlas_AddFontFromFileTTF;
    pub const AddFontFromMemoryTTF = ImFontAtlas_AddFontFromMemoryTTF;
    pub const AddFontFromMemoryCompressedTTF = ImFontAtlas_AddFontFromMemoryCompressedTTF;
    pub const AddFontFromMemoryCompressedBase85TTF = ImFontAtlas_AddFontFromMemoryCompressedBase85TTF;
    pub const ClearInputData = ImFontAtlas_ClearInputData;
    pub const ClearTexData = ImFontAtlas_ClearTexData;
    pub const ClearFonts = ImFontAtlas_ClearFonts;
    pub const Clear = ImFontAtlas_Clear;
    pub const Build = ImFontAtlas_Build;
    pub const GetTexDataAsAlpha8 = ImFontAtlas_GetTexDataAsAlpha8;
    pub const GetTexDataAsRGBA32 = ImFontAtlas_GetTexDataAsRGBA32;
    pub const IsBuilt = ImFontAtlas_IsBuilt;
    pub const SetTexID = ImFontAtlas_SetTexID;
    pub const GetGlyphRangesDefault = ImFontAtlas_GetGlyphRangesDefault;
    pub const GetGlyphRangesGreek = ImFontAtlas_GetGlyphRangesGreek;
    pub const GetGlyphRangesKorean = ImFontAtlas_GetGlyphRangesKorean;
    pub const GetGlyphRangesJapanese = ImFontAtlas_GetGlyphRangesJapanese;
    pub const GetGlyphRangesChineseFull = ImFontAtlas_GetGlyphRangesChineseFull;
    pub const GetGlyphRangesChineseSimplifiedCommon = ImFontAtlas_GetGlyphRangesChineseSimplifiedCommon;
    pub const GetGlyphRangesCyrillic = ImFontAtlas_GetGlyphRangesCyrillic;
    pub const GetGlyphRangesThai = ImFontAtlas_GetGlyphRangesThai;
    pub const GetGlyphRangesVietnamese = ImFontAtlas_GetGlyphRangesVietnamese;
    pub const AddCustomRectRegular = ImFontAtlas_AddCustomRectRegular;
    pub const AddCustomRectFontGlyph = ImFontAtlas_AddCustomRectFontGlyph;
    pub const GetCustomRectByIndex = ImFontAtlas_GetCustomRectByIndex;
    pub const CalcCustomRectUV = ImFontAtlas_CalcCustomRectUV;
    pub const GetMouseCursorTexData = ImFontAtlas_GetMouseCursorTexData;
};
pub const Font = extern struct {
    IndexAdvanceX: Vector_float = @import("std").mem.zeroes(Vector_float),
    FallbackAdvanceX: f32 = @import("std").mem.zeroes(f32),
    FontSize: f32 = @import("std").mem.zeroes(f32),
    IndexLookup: Vector_ImWchar = @import("std").mem.zeroes(Vector_ImWchar),
    Glyphs: Vector_ImFontGlyph = @import("std").mem.zeroes(Vector_ImFontGlyph),
    FallbackGlyph: ?*const FontGlyph = @import("std").mem.zeroes(?*const FontGlyph),
    ContainerAtlas: ?*FontAtlas = @import("std").mem.zeroes(?*FontAtlas),
    ConfigData: ?*const FontConfig = @import("std").mem.zeroes(?*const FontConfig),
    ConfigDataCount: c_short = @import("std").mem.zeroes(c_short),
    FallbackChar: Wchar = @import("std").mem.zeroes(Wchar),
    EllipsisChar: Wchar = @import("std").mem.zeroes(Wchar),
    EllipsisCharCount: c_short = @import("std").mem.zeroes(c_short),
    EllipsisWidth: f32 = @import("std").mem.zeroes(f32),
    EllipsisCharStep: f32 = @import("std").mem.zeroes(f32),
    DirtyLookupTables: bool = @import("std").mem.zeroes(bool),
    Scale: f32 = @import("std").mem.zeroes(f32),
    Ascent: f32 = @import("std").mem.zeroes(f32),
    Descent: f32 = @import("std").mem.zeroes(f32),
    MetricsTotalSurface: c_int = @import("std").mem.zeroes(c_int),
    Used4kPagesMap: [(IM_UNICODE_CODEPOINT_MAX + 1) / 4096 / 8]u8 = @import("std").mem.zeroes([(IM_UNICODE_CODEPOINT_MAX + 1) / 4096 / 8]u8),
    pub const FindGlyph = ImFont_FindGlyph;
    pub const FindGlyphNoFallback = ImFont_FindGlyphNoFallback;
    pub const GetCharAdvance = ImFont_GetCharAdvance;
    pub const IsLoaded = ImFont_IsLoaded;
    pub const GetDebugName = ImFont_GetDebugName;
    pub const CalcTextSizeA = ImFont_CalcTextSizeA;
    pub const CalcTextSizeAEx = ImFont_CalcTextSizeAEx;
    pub const CalcWordWrapPositionA = ImFont_CalcWordWrapPositionA;
    pub const RenderChar = ImFont_RenderChar;
    pub const RenderText = ImFont_RenderText;
    pub const BuildLookupTable = ImFont_BuildLookupTable;
    pub const ClearOutputData = ImFont_ClearOutputData;
    pub const GrowIndex = ImFont_GrowIndex;
    pub const AddGlyph = ImFont_AddGlyph;
    pub const AddRemapChar = ImFont_AddRemapChar;
    pub const SetGlyphVisible = ImFont_SetGlyphVisible;
    pub const IsGlyphRangeUnused = ImFont_IsGlyphRangeUnused;
};
pub const Viewport = extern struct {
    ID: u32 = @import("std").mem.zeroes(u32),
    Flags: ViewportFlags = @import("std").mem.zeroes(ViewportFlags),
    Pos: Vec2 = @import("std").mem.zeroes(Vec2),
    Size: Vec2 = @import("std").mem.zeroes(Vec2),
    WorkPos: Vec2 = @import("std").mem.zeroes(Vec2),
    WorkSize: Vec2 = @import("std").mem.zeroes(Vec2),
    DpiScale: f32 = @import("std").mem.zeroes(f32),
    ParentViewportId: u32 = @import("std").mem.zeroes(u32),
    DrawData: ?*DrawData = @import("std").mem.zeroes(?*DrawData),
    RendererUserData: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    PlatformUserData: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    PlatformHandle: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    PlatformHandleRaw: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    PlatformWindowCreated: bool = @import("std").mem.zeroes(bool),
    PlatformRequestMove: bool = @import("std").mem.zeroes(bool),
    PlatformRequestResize: bool = @import("std").mem.zeroes(bool),
    PlatformRequestClose: bool = @import("std").mem.zeroes(bool),
    pub const GetCenter = ImGuiViewport_GetCenter;
    pub const GetWorkCenter = ImGuiViewport_GetWorkCenter;
};
pub const PlatformIO = extern struct {
    Platform_GetClipboardTextFn: ?*const fn (ctx: *Context) callconv(.C) [*c]const u8 = @import("std").mem.zeroes(?*const fn (ctx: ?*Context) callconv(.C) [*c]const u8),
    Platform_SetClipboardTextFn: ?*const fn (ctx: *Context, text: [*c]const u8) callconv(.C) void = @import("std").mem.zeroes(?*const fn (ctx: ?*Context, text: [*c]const u8) callconv(.C) void),
    Platform_ClipboardUserData: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    Platform_OpenInShellFn: ?*const fn (ctx: *Context, path: [*c]const u8) callconv(.C) bool = @import("std").mem.zeroes(?*const fn (ctx: ?*Context, path: [*c]const u8) callconv(.C) bool),
    Platform_OpenInShellUserData: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    Platform_SetImeDataFn: ?*const fn (ctx: *Context, viewport: ?*Viewport, data: ?*PlatformImeData) callconv(.C) void = @import("std").mem.zeroes(?*const fn (ctx: ?*Context, viewport: ?*Viewport, data: ?*PlatformImeData) callconv(.C) void),
    Platform_ImeUserData: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    Platform_LocaleDecimalPoint: Wchar = @import("std").mem.zeroes(Wchar),
    Renderer_RenderState: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    Platform_CreateWindow: ?*const fn (vp: *Viewport) callconv(.C) void = @import("std").mem.zeroes(?*const fn (vp: *Viewport) callconv(.C) void),
    Platform_DestroyWindow: ?*const fn (vp: *Viewport) callconv(.C) void = @import("std").mem.zeroes(?*const fn (vp: *Viewport) callconv(.C) void),
    Platform_ShowWindow: ?*const fn (vp: *Viewport) callconv(.C) void = @import("std").mem.zeroes(?*const fn (vp: *Viewport) callconv(.C) void),
    Platform_SetWindowPos: ?*const fn (vp: *Viewport, pos: Vec2) callconv(.C) void = @import("std").mem.zeroes(?*const fn (vp: *Viewport, pos: Vec2) callconv(.C) void),
    Platform_GetWindowPos: ?*const fn (vp: *Viewport) callconv(.C) Vec2 = @import("std").mem.zeroes(?*const fn (vp: *Viewport) callconv(.C) Vec2),
    Platform_SetWindowSize: ?*const fn (vp: *Viewport, size: Vec2) callconv(.C) void = @import("std").mem.zeroes(?*const fn (vp: *Viewport, size: Vec2) callconv(.C) void),
    Platform_GetWindowSize: ?*const fn (vp: *Viewport) callconv(.C) Vec2 = @import("std").mem.zeroes(?*const fn (vp: *Viewport) callconv(.C) Vec2),
    Platform_SetWindowFocus: ?*const fn (vp: *Viewport) callconv(.C) void = @import("std").mem.zeroes(?*const fn (vp: *Viewport) callconv(.C) void),
    Platform_GetWindowFocus: ?*const fn (vp: *Viewport) callconv(.C) bool = @import("std").mem.zeroes(?*const fn (vp: *Viewport) callconv(.C) bool),
    Platform_GetWindowMinimized: ?*const fn (vp: *Viewport) callconv(.C) bool = @import("std").mem.zeroes(?*const fn (vp: *Viewport) callconv(.C) bool),
    Platform_SetWindowTitle: ?*const fn (vp: *Viewport, str: [*c]const u8) callconv(.C) void = @import("std").mem.zeroes(?*const fn (vp: *Viewport, str: [*c]const u8) callconv(.C) void),
    Platform_SetWindowAlpha: ?*const fn (vp: *Viewport, alpha: f32) callconv(.C) void = @import("std").mem.zeroes(?*const fn (vp: *Viewport, alpha: f32) callconv(.C) void),
    Platform_UpdateWindow: ?*const fn (vp: *Viewport) callconv(.C) void = @import("std").mem.zeroes(?*const fn (vp: *Viewport) callconv(.C) void),
    Platform_RenderWindow: ?*const fn (vp: *Viewport, render_arg: *anyopaque) callconv(.C) void = @import("std").mem.zeroes(?*const fn (vp: *Viewport, render_arg: *anyopaque) callconv(.C) void),
    Platform_SwapBuffers: ?*const fn (vp: *Viewport, render_arg: *anyopaque) callconv(.C) void = @import("std").mem.zeroes(?*const fn (vp: *Viewport, render_arg: *anyopaque) callconv(.C) void),
    Platform_GetWindowDpiScale: ?*const fn (vp: *Viewport) callconv(.C) f32 = @import("std").mem.zeroes(?*const fn (vp: *Viewport) callconv(.C) f32),
    Platform_OnChangedViewport: ?*const fn (vp: *Viewport) callconv(.C) void = @import("std").mem.zeroes(?*const fn (vp: *Viewport) callconv(.C) void),
    Platform_GetWindowWorkAreaInsets: ?*const fn (vp: *Viewport) callconv(.C) Vec4 = @import("std").mem.zeroes(?*const fn (vp: *Viewport) callconv(.C) Vec4),
    Platform_CreateVkSurface: ?*const fn (vp: *Viewport, vk_inst: u64, vk_allocators: *anyopaque, out_vk_surface: [*c]u64) callconv(.C) c_int = @import("std").mem.zeroes(?*const fn (vp: *Viewport, vk_inst: u64, vk_allocators: *anyopaque, out_vk_surface: [*c]u64) callconv(.C) c_int),
    Renderer_CreateWindow: ?*const fn (vp: *Viewport) callconv(.C) void = @import("std").mem.zeroes(?*const fn (vp: *Viewport) callconv(.C) void),
    Renderer_DestroyWindow: ?*const fn (vp: *Viewport) callconv(.C) void = @import("std").mem.zeroes(?*const fn (vp: *Viewport) callconv(.C) void),
    Renderer_SetWindowSize: ?*const fn (vp: *Viewport, size: Vec2) callconv(.C) void = @import("std").mem.zeroes(?*const fn (vp: *Viewport, size: Vec2) callconv(.C) void),
    Renderer_RenderWindow: ?*const fn (vp: *Viewport, render_arg: *anyopaque) callconv(.C) void = @import("std").mem.zeroes(?*const fn (vp: *Viewport, render_arg: *anyopaque) callconv(.C) void),
    Renderer_SwapBuffers: ?*const fn (vp: *Viewport, render_arg: *anyopaque) callconv(.C) void = @import("std").mem.zeroes(?*const fn (vp: *Viewport, render_arg: *anyopaque) callconv(.C) void),
    Monitors: Vector_PlatformMonitor = @import("std").mem.zeroes(Vector_PlatformMonitor),
    Viewports: Vector_ViewportPtr = @import("std").mem.zeroes(Vector_ViewportPtr),
};
pub const PlatformMonitor = extern struct {
    MainPos: Vec2 = @import("std").mem.zeroes(Vec2),
    MainSize: Vec2 = @import("std").mem.zeroes(Vec2),
    WorkPos: Vec2 = @import("std").mem.zeroes(Vec2),
    WorkSize: Vec2 = @import("std").mem.zeroes(Vec2),
    DpiScale: f32 = @import("std").mem.zeroes(f32),
    PlatformHandle: ?*anyopaque = null,
};
pub const PlatformImeData = extern struct {
    WantVisible: bool = @import("std").mem.zeroes(bool),
    InputPos: Vec2 = @import("std").mem.zeroes(Vec2),
    InputLineHeight: f32 = @import("std").mem.zeroes(f32),
};

pub extern fn igCreateContext(shared_font_atlas: ?*FontAtlas) *Context;
pub extern fn igDestroyContext(ctx: ?*Context) void;
pub extern fn igGetCurrentContext() ?*Context;
pub extern fn igSetCurrentContext(ctx: ?*Context) void;
pub extern fn igGetIO() ?*IO;
pub extern fn igGetPlatformIO() ?*PlatformIO;
pub extern fn igGetStyle() ?*Style;
pub extern fn igNewFrame() void;
pub extern fn igEndFrame() void;
pub extern fn igRender() void;
pub extern fn igGetDrawData() ?*DrawData;
pub extern fn igShowDemoWindow(p_open: ?*bool) void;
pub extern fn igShowMetricsWindow(p_open: ?*bool) void;
pub extern fn igShowDebugLogWindow(p_open: ?*bool) void;
pub extern fn igShowIDStackToolWindow() void;
pub extern fn igShowIDStackToolWindowEx(p_open: ?*bool) void;
pub extern fn igShowAboutWindow(p_open: ?*bool) void;
pub extern fn igShowStyleEditor(ref: ?*Style) void;
pub extern fn igShowStyleSelector(label: ?*const u8) bool;
pub extern fn igShowFontSelector(label: ?*const u8) void;
pub extern fn igShowUserGuide() void;
pub extern fn igGetVersion() ?*const u8;
pub extern fn igStyleColorsDark(dst: ?*Style) void;
pub extern fn igStyleColorsLight(dst: ?*Style) void;
pub extern fn igStyleColorsClassic(dst: ?*Style) void;
pub extern fn igBegin(name: [*c]const u8, p_open: ?*bool, flags: WindowFlags) bool;
pub extern fn igEnd() void;
pub extern fn igBeginChild(str_id: [*c]const u8, size: Vec2, child_flags: ChildFlags, window_flags: WindowFlags) bool;
pub extern fn igBeginChildID(id: u32, size: Vec2, child_flags: ChildFlags, window_flags: WindowFlags) bool;
pub extern fn igEndChild() void;
pub extern fn igIsWindowAppearing() bool;
pub extern fn igIsWindowCollapsed() bool;
pub extern fn igIsWindowFocused(flags: FocusedFlags) bool;
pub extern fn igIsWindowHovered(flags: HoveredFlags) bool;
pub extern fn igGetWindowDrawList() ?*DrawList;
pub extern fn igGetWindowDpiScale() f32;
pub extern fn igGetWindowPos() Vec2;
pub extern fn igGetWindowSize() Vec2;
pub extern fn igGetWindowWidth() f32;
pub extern fn igGetWindowHeight() f32;
pub extern fn igGetWindowViewport() ?*Viewport;
pub extern fn igSetNextWindowPos(pos: Vec2, cond: Cond) void;
pub extern fn igSetNextWindowPosEx(pos: Vec2, cond: Cond, pivot: Vec2) void;
pub extern fn igSetNextWindowSize(size: Vec2, cond: Cond) void;
pub extern fn igSetNextWindowSizeConstraints(size_min: Vec2, size_max: Vec2, custom_callback: SizeCallback, custom_callback_data: *anyopaque) void;
pub extern fn igSetNextWindowContentSize(size: Vec2) void;
pub extern fn igSetNextWindowCollapsed(collapsed: bool, cond: Cond) void;
pub extern fn igSetNextWindowFocus() void;
pub extern fn igSetNextWindowScroll(scroll: Vec2) void;
pub extern fn igSetNextWindowBgAlpha(alpha: f32) void;
pub extern fn igSetNextWindowViewport(viewport_id: u32) void;
pub extern fn igSetWindowPos(pos: Vec2, cond: Cond) void;
pub extern fn igSetWindowSize(size: Vec2, cond: Cond) void;
pub extern fn igSetWindowCollapsed(collapsed: bool, cond: Cond) void;
pub extern fn igSetWindowFocus() void;
pub extern fn igSetWindowFontScale(scale: f32) void;
pub extern fn igSetWindowPosStr(name: [*c]const u8, pos: Vec2, cond: Cond) void;
pub extern fn igSetWindowSizeStr(name: [*c]const u8, size: Vec2, cond: Cond) void;
pub extern fn igSetWindowCollapsedStr(name: [*c]const u8, collapsed: bool, cond: Cond) void;
pub extern fn igSetWindowFocusStr(name: [*c]const u8) void;
pub extern fn igGetScrollX() f32;
pub extern fn igGetScrollY() f32;
pub extern fn igSetScrollX(scroll_x: f32) void;
pub extern fn igSetScrollY(scroll_y: f32) void;
pub extern fn igGetScrollMaxX() f32;
pub extern fn igGetScrollMaxY() f32;
pub extern fn igSetScrollHereX(center_x_ratio: f32) void;
pub extern fn igSetScrollHereY(center_y_ratio: f32) void;
pub extern fn igSetScrollFromPosX(local_x: f32, center_x_ratio: f32) void;
pub extern fn igSetScrollFromPosY(local_y: f32, center_y_ratio: f32) void;
pub extern fn igPushFont(font: ?*Font) void;
pub extern fn igPopFont() void;
pub extern fn igPushStyleColor(idx: Col, col: u32) void;
pub extern fn igPushStyleColorImVec4(idx: Col, col: Vec4) void;
pub extern fn igPopStyleColor() void;
pub extern fn igPopStyleColorEx(count: c_int) void;
pub extern fn igPushStyleVar(idx: StyleVar, val: f32) void;
pub extern fn igPushStyleVarImVec2(idx: StyleVar, val: Vec2) void;
pub extern fn igPushStyleVarX(idx: StyleVar, val_x: f32) void;
pub extern fn igPushStyleVarY(idx: StyleVar, val_y: f32) void;
pub extern fn igPopStyleVar() void;
pub extern fn igPopStyleVarEx(count: c_int) void;
pub extern fn igPushItemFlag(option: ItemFlags, enabled: bool) void;
pub extern fn igPopItemFlag() void;
pub extern fn igPushItemWidth(item_width: f32) void;
pub extern fn igPopItemWidth() void;
pub extern fn igSetNextItemWidth(item_width: f32) void;
pub extern fn igCalcItemWidth() f32;
pub extern fn igPushTextWrapPos(wrap_local_pos_x: f32) void;
pub extern fn igPopTextWrapPos() void;
pub extern fn igGetFont() ?*Font;
pub extern fn igGetFontSize() f32;
pub extern fn igGetFontTexUvWhitePixel() Vec2;
pub extern fn igGetColorU32(idx: Col) u32;
pub extern fn igGetColorU32Ex(idx: Col, alpha_mul: f32) u32;
pub extern fn igGetColorU32ImVec4(col: Vec4) u32;
pub extern fn igGetColorU32ImU32(col: u32) u32;
pub extern fn igGetColorU32ImU32Ex(col: u32, alpha_mul: f32) u32;
pub extern fn igGetStyleColorVec4(idx: Col) ?*const Vec4;
pub extern fn igGetCursorScreenPos() Vec2;
pub extern fn igSetCursorScreenPos(pos: Vec2) void;
pub extern fn igGetContentRegionAvail() Vec2;
pub extern fn igGetCursorPos() Vec2;
pub extern fn igGetCursorPosX() f32;
pub extern fn igGetCursorPosY() f32;
pub extern fn igSetCursorPos(local_pos: Vec2) void;
pub extern fn igSetCursorPosX(local_x: f32) void;
pub extern fn igSetCursorPosY(local_y: f32) void;
pub extern fn igGetCursorStartPos() Vec2;
pub extern fn igSeparator() void;
pub extern fn igSameLine() void;
pub extern fn igSameLineEx(offset_from_start_x: f32, spacing: f32) void;
pub extern fn igNewLine() void;
pub extern fn igSpacing() void;
pub extern fn igDummy(size: Vec2) void;
pub extern fn igIndent() void;
pub extern fn igIndentEx(indent_w: f32) void;
pub extern fn igUnindent() void;
pub extern fn igUnindentEx(indent_w: f32) void;
pub extern fn igBeginGroup() void;
pub extern fn igEndGroup() void;
pub extern fn igAlignTextToFramePadding() void;
pub extern fn igGetTextLineHeight() f32;
pub extern fn igGetTextLineHeightWithSpacing() f32;
pub extern fn igGetFrameHeight() f32;
pub extern fn igGetFrameHeightWithSpacing() f32;
pub extern fn igPushID(str_id: [*c]const u8) void;
pub extern fn igPushIDStr(str_id_begin: [*c]const u8, str_id_end: [*c]const u8) void;
pub extern fn igPushIDPtr(ptr_id: *anyopaque) void;
pub extern fn igPushIDInt(int_id: c_int) void;
pub extern fn igPopID() void;
pub extern fn igGetID(str_id: [*c]const u8) u32;
pub extern fn igGetIDStr(str_id_begin: [*c]const u8, str_id_end: [*c]const u8) u32;
pub extern fn igGetIDPtr(ptr_id: *anyopaque) u32;
pub extern fn igGetIDInt(int_id: c_int) u32;
pub extern fn igTextUnformatted(text: [*c]const u8) void;
pub extern fn igTextUnformattedEx(text: [*c]const u8, text_end: [*c]const u8) void;
pub extern fn igText(fmt: [*c]const u8, ...) void;
// pub extern fn igTextV(fmt: [*c]const u8, args: va_list) void;
pub extern fn igTextColored(col: Vec4, fmt: [*c]const u8, ...) void;
// pub extern fn igTextColoredV(col: Vec4, fmt: [*c]const u8, args: va_list) void;
pub extern fn igTextDisabled(fmt: [*c]const u8, ...) void;
// pub extern fn igTextDisabledV(fmt: [*c]const u8, args: va_list) void;
pub extern fn igTextWrapped(fmt: [*c]const u8, ...) void;
// pub extern fn igTextWrappedV(fmt: [*c]const u8, args: va_list) void;
pub extern fn igLabelText(label: [*c]const u8, fmt: [*c]const u8, ...) void;
// pub extern fn igLabelTextV(label: [*c]const u8, fmt: [*c]const u8, args: va_list) void;
pub extern fn igBulletText(fmt: [*c]const u8, ...) void;
// pub extern fn igBulletTextV(fmt: [*c]const u8, args: va_list) void;
pub extern fn igSeparatorText(label: [*c]const u8) void;
pub extern fn igButton(label: [*c]const u8) bool;
pub extern fn igButtonEx(label: [*c]const u8, size: Vec2) bool;
pub extern fn igSmallButton(label: [*c]const u8) bool;
pub extern fn igInvisibleButton(str_id: [*c]const u8, size: Vec2, flags: ButtonFlags) bool;
pub extern fn igArrowButton(str_id: [*c]const u8, dir: Dir) bool;
pub extern fn igCheckbox(label: [*c]const u8, v: [*c]bool) bool;
pub extern fn igCheckboxFlagsIntPtr(label: [*c]const u8, flags: [*c]c_int, flags_value: c_int) bool;
pub extern fn igCheckboxFlagsUintPtr(label: [*c]const u8, flags: [*c]c_uint, flags_value: c_uint) bool;
pub extern fn igRadioButton(label: [*c]const u8, active: bool) bool;
pub extern fn igRadioButtonIntPtr(label: [*c]const u8, v: [*c]c_int, v_button: c_int) bool;
pub extern fn igProgressBar(fraction: f32, size_arg: Vec2, overlay: [*c]const u8) void;
pub extern fn igBullet() void;
pub extern fn igTextLink(label: [*c]const u8) bool;
pub extern fn igTextLinkOpenURL(label: [*c]const u8) void;
pub extern fn igTextLinkOpenURLEx(label: [*c]const u8, url: [*c]const u8) void;
pub extern fn igImage(user_texture_id: TextureID, image_size: Vec2) void;
pub extern fn igImageEx(user_texture_id: TextureID, image_size: Vec2, uv0: Vec2, uv1: Vec2, tint_col: Vec4, border_col: Vec4) void;
pub extern fn igImageButton(str_id: [*c]const u8, user_texture_id: TextureID, image_size: Vec2) bool;
pub extern fn igImageButtonEx(str_id: [*c]const u8, user_texture_id: TextureID, image_size: Vec2, uv0: Vec2, uv1: Vec2, bg_col: Vec4, tint_col: Vec4) bool;
pub extern fn igBeginCombo(label: [*c]const u8, preview_value: [*c]const u8, flags: ComboFlags) bool;
pub extern fn igEndCombo() void;
pub extern fn igComboChar(label: [*c]const u8, current_item: [*c]c_int, items: [*][*c]const u8, items_count: c_int) bool;
pub extern fn igComboCharEx(label: [*c]const u8, current_item: [*c]c_int, items: [*][*c]const u8, items_count: c_int, popup_max_height_in_items: c_int) bool;
pub extern fn igCombo(label: [*c]const u8, current_item: [*c]c_int, items_separated_by_zeros: [*c]const u8) bool;
pub extern fn igComboEx(label: [*c]const u8, current_item: [*c]c_int, items_separated_by_zeros: [*c]const u8, popup_max_height_in_items: c_int) bool;
pub extern fn igComboCallback(label: [*c]const u8, current_item: [*c]c_int, getter: *const fn (user_data: *anyopaque, idx: c_int) [*c]const u8, user_data: *anyopaque, items_count: c_int) bool;
pub extern fn igComboCallbackEx(label: [*c]const u8, current_item: [*c]c_int, getter: *const fn (user_data: *anyopaque, idx: c_int) [*c]const u8, user_data: *anyopaque, items_count: c_int, popup_max_height_in_items: c_int) bool;
pub extern fn igDragFloat(label: [*c]const u8, v: [*c]f32) bool;
pub extern fn igDragFloatEx(label: [*c]const u8, v: [*c]f32, v_speed: f32, v_min: f32, v_max: f32, format: [*c]const u8, flags: SliderFlags) bool;
pub extern fn igDragFloat2(label: [*c]const u8, v: [*]f32) bool;
pub extern fn igDragFloat2Ex(label: [*c]const u8, v: [*]f32, v_speed: f32, v_min: f32, v_max: f32, format: [*c]const u8, flags: SliderFlags) bool;
pub extern fn igDragFloat3(label: [*c]const u8, v: [*]f32) bool;
pub extern fn igDragFloat3Ex(label: [*c]const u8, v: [*]f32, v_speed: f32, v_min: f32, v_max: f32, format: [*c]const u8, flags: SliderFlags) bool;
pub extern fn igDragFloat4(label: [*c]const u8, v: [*]f32) bool;
pub extern fn igDragFloat4Ex(label: [*c]const u8, v: [*]f32, v_speed: f32, v_min: f32, v_max: f32, format: [*c]const u8, flags: SliderFlags) bool;
pub extern fn igDragFloatRange2(label: [*c]const u8, v_current_min: [*c]f32, v_current_max: [*c]f32) bool;
pub extern fn igDragFloatRange2Ex(label: [*c]const u8, v_current_min: [*c]f32, v_current_max: [*c]f32, v_speed: f32, v_min: f32, v_max: f32, format: [*c]const u8, format_max: [*c]const u8, flags: SliderFlags) bool;
pub extern fn igDragInt(label: [*c]const u8, v: [*c]c_int) bool;
pub extern fn igDragIntEx(label: [*c]const u8, v: [*c]c_int, v_speed: f32, v_min: c_int, v_max: c_int, format: [*c]const u8, flags: SliderFlags) bool;
pub extern fn igDragInt2(label: [*c]const u8, v: [2]c_int) bool;
pub extern fn igDragInt2Ex(label: [*c]const u8, v: [2]c_int, v_speed: f32, v_min: c_int, v_max: c_int, format: [*c]const u8, flags: SliderFlags) bool;
pub extern fn igDragInt3(label: [*c]const u8, v: [3]c_int) bool;
pub extern fn igDragInt3Ex(label: [*c]const u8, v: [3]c_int, v_speed: f32, v_min: c_int, v_max: c_int, format: [*c]const u8, flags: SliderFlags) bool;
pub extern fn igDragInt4(label: [*c]const u8, v: [4]c_int) bool;
pub extern fn igDragInt4Ex(label: [*c]const u8, v: [4]c_int, v_speed: f32, v_min: c_int, v_max: c_int, format: [*c]const u8, flags: SliderFlags) bool;
pub extern fn igDragIntRange2(label: [*c]const u8, v_current_min: [*c]c_int, v_current_max: [*c]c_int) bool;
pub extern fn igDragIntRange2Ex(label: [*c]const u8, v_current_min: [*c]c_int, v_current_max: [*c]c_int, v_speed: f32, v_min: c_int, v_max: c_int, format: [*c]const u8, format_max: [*c]const u8, flags: SliderFlags) bool;
pub extern fn igDragScalar(label: [*c]const u8, data_type: DataType, p_data: *anyopaque) bool;
pub extern fn igDragScalarEx(label: [*c]const u8, data_type: DataType, p_data: *anyopaque, v_speed: f32, p_min: [*c]const void, p_max: [*c]const void, format: [*c]const u8, flags: SliderFlags) bool;
pub extern fn igDragScalarN(label: [*c]const u8, data_type: DataType, p_data: *anyopaque, components: c_int) bool;
pub extern fn igDragScalarNEx(label: [*c]const u8, data_type: DataType, p_data: *anyopaque, components: c_int, v_speed: f32, p_min: [*c]const void, p_max: [*c]const void, format: [*c]const u8, flags: SliderFlags) bool;
pub extern fn igSliderFloat(label: [*c]const u8, v: [*c]f32, v_min: f32, v_max: f32) bool;
pub extern fn igSliderFloatEx(label: [*c]const u8, v: [*c]f32, v_min: f32, v_max: f32, format: [*c]const u8, flags: SliderFlags) bool;
pub extern fn igSliderFloat2(label: [*c]const u8, v: [*]f32, v_min: f32, v_max: f32) bool;
pub extern fn igSliderFloat2Ex(label: [*c]const u8, v: [*]f32, v_min: f32, v_max: f32, format: [*c]const u8, flags: SliderFlags) bool;
pub extern fn igSliderFloat3(label: [*c]const u8, v: [*]f32, v_min: f32, v_max: f32) bool;
pub extern fn igSliderFloat3Ex(label: [*c]const u8, v: [*]f32, v_min: f32, v_max: f32, format: [*c]const u8, flags: SliderFlags) bool;
pub extern fn igSliderFloat4(label: [*c]const u8, v: [*]f32, v_min: f32, v_max: f32) bool;
pub extern fn igSliderFloat4Ex(label: [*c]const u8, v: [*]f32, v_min: f32, v_max: f32, format: [*c]const u8, flags: SliderFlags) bool;
pub extern fn igSliderAngle(label: [*c]const u8, v_rad: [*c]f32) bool;
pub extern fn igSliderAngleEx(label: [*c]const u8, v_rad: [*c]f32, v_degrees_min: f32, v_degrees_max: f32, format: [*c]const u8, flags: SliderFlags) bool;
pub extern fn igSliderInt(label: [*c]const u8, v: [*c]c_int, v_min: c_int, v_max: c_int) bool;
pub extern fn igSliderIntEx(label: [*c]const u8, v: [*c]c_int, v_min: c_int, v_max: c_int, format: [*c]const u8, flags: SliderFlags) bool;
pub extern fn igSliderInt2(label: [*c]const u8, v: [2]c_int, v_min: c_int, v_max: c_int) bool;
pub extern fn igSliderInt2Ex(label: [*c]const u8, v: [2]c_int, v_min: c_int, v_max: c_int, format: [*c]const u8, flags: SliderFlags) bool;
pub extern fn igSliderInt3(label: [*c]const u8, v: [3]c_int, v_min: c_int, v_max: c_int) bool;
pub extern fn igSliderInt3Ex(label: [*c]const u8, v: [3]c_int, v_min: c_int, v_max: c_int, format: [*c]const u8, flags: SliderFlags) bool;
pub extern fn igSliderInt4(label: [*c]const u8, v: [4]c_int, v_min: c_int, v_max: c_int) bool;
pub extern fn igSliderInt4Ex(label: [*c]const u8, v: [4]c_int, v_min: c_int, v_max: c_int, format: [*c]const u8, flags: SliderFlags) bool;
pub extern fn igSliderScalar(label: [*c]const u8, data_type: DataType, p_data: *anyopaque, p_min: [*c]const void, p_max: [*c]const void) bool;
pub extern fn igSliderScalarEx(label: [*c]const u8, data_type: DataType, p_data: *anyopaque, p_min: [*c]const void, p_max: [*c]const void, format: [*c]const u8, flags: SliderFlags) bool;
pub extern fn igSliderScalarN(label: [*c]const u8, data_type: DataType, p_data: *anyopaque, components: c_int, p_min: [*c]const void, p_max: [*c]const void) bool;
pub extern fn igSliderScalarNEx(label: [*c]const u8, data_type: DataType, p_data: *anyopaque, components: c_int, p_min: [*c]const void, p_max: [*c]const void, format: [*c]const u8, flags: SliderFlags) bool;
pub extern fn igVSliderFloat(label: [*c]const u8, size: Vec2, v: [*c]f32, v_min: f32, v_max: f32) bool;
pub extern fn igVSliderFloatEx(label: [*c]const u8, size: Vec2, v: [*c]f32, v_min: f32, v_max: f32, format: [*c]const u8, flags: SliderFlags) bool;
pub extern fn igVSliderInt(label: [*c]const u8, size: Vec2, v: [*c]c_int, v_min: c_int, v_max: c_int) bool;
pub extern fn igVSliderIntEx(label: [*c]const u8, size: Vec2, v: [*c]c_int, v_min: c_int, v_max: c_int, format: [*c]const u8, flags: SliderFlags) bool;
pub extern fn igVSliderScalar(label: [*c]const u8, size: Vec2, data_type: DataType, p_data: *anyopaque, p_min: [*c]const void, p_max: [*c]const void) bool;
pub extern fn igVSliderScalarEx(label: [*c]const u8, size: Vec2, data_type: DataType, p_data: *anyopaque, p_min: [*c]const void, p_max: [*c]const void, format: [*c]const u8, flags: SliderFlags) bool;
pub extern fn igInputText(label: [*c]const u8, buf: [*c]u8, buf_size: usize, flags: InputTextFlags) bool;
pub extern fn igInputTextEx(label: [*c]const u8, buf: [*c]u8, buf_size: usize, flags: InputTextFlags, callback: InputTextCallback, user_data: *anyopaque) bool;
pub extern fn igInputTextMultiline(label: [*c]const u8, buf: [*c]u8, buf_size: usize) bool;
pub extern fn igInputTextMultilineEx(label: [*c]const u8, buf: [*c]u8, buf_size: usize, size: Vec2, flags: InputTextFlags, callback: InputTextCallback, user_data: *anyopaque) bool;
pub extern fn igInputTextWithHint(label: [*c]const u8, hint: [*c]const u8, buf: [*c]u8, buf_size: usize, flags: InputTextFlags) bool;
pub extern fn igInputTextWithHintEx(label: [*c]const u8, hint: [*c]const u8, buf: [*c]u8, buf_size: usize, flags: InputTextFlags, callback: InputTextCallback, user_data: *anyopaque) bool;
pub extern fn igInputFloat(label: [*c]const u8, v: [*c]f32) bool;
pub extern fn igInputFloatEx(label: [*c]const u8, v: [*c]f32, step: f32, step_fast: f32, format: [*c]const u8, flags: InputTextFlags) bool;
pub extern fn igInputFloat2(label: [*c]const u8, v: [*]f32) bool;
pub extern fn igInputFloat2Ex(label: [*c]const u8, v: [*]f32, format: [*c]const u8, flags: InputTextFlags) bool;
pub extern fn igInputFloat3(label: [*c]const u8, v: [*]f32) bool;
pub extern fn igInputFloat3Ex(label: [*c]const u8, v: [*]f32, format: [*c]const u8, flags: InputTextFlags) bool;
pub extern fn igInputFloat4(label: [*c]const u8, v: [*]f32) bool;
pub extern fn igInputFloat4Ex(label: [*c]const u8, v: [*]f32, format: [*c]const u8, flags: InputTextFlags) bool;
pub extern fn igInputInt(label: [*c]const u8, v: [*c]c_int) bool;
pub extern fn igInputIntEx(label: [*c]const u8, v: [*c]c_int, step: c_int, step_fast: c_int, flags: InputTextFlags) bool;
pub extern fn igInputInt2(label: [*c]const u8, v: [2]c_int, flags: InputTextFlags) bool;
pub extern fn igInputInt3(label: [*c]const u8, v: [3]c_int, flags: InputTextFlags) bool;
pub extern fn igInputInt4(label: [*c]const u8, v: [4]c_int, flags: InputTextFlags) bool;
pub extern fn igInputDouble(label: [*c]const u8, v: [*c]f64) bool;
pub extern fn igInputDoubleEx(label: [*c]const u8, v: [*c]f64, step: f64, step_fast: f64, format: [*c]const u8, flags: InputTextFlags) bool;
pub extern fn igInputScalar(label: [*c]const u8, data_type: DataType, p_data: *anyopaque) bool;
pub extern fn igInputScalarEx(label: [*c]const u8, data_type: DataType, p_data: *anyopaque, p_step: [*c]const void, p_step_fast: [*c]const void, format: [*c]const u8, flags: InputTextFlags) bool;
pub extern fn igInputScalarN(label: [*c]const u8, data_type: DataType, p_data: *anyopaque, components: c_int) bool;
pub extern fn igInputScalarNEx(label: [*c]const u8, data_type: DataType, p_data: *anyopaque, components: c_int, p_step: [*c]const void, p_step_fast: [*c]const void, format: [*c]const u8, flags: InputTextFlags) bool;
pub extern fn igColorEdit3(label: [*c]const u8, col: [*]f32, flags: ColorEditFlags) bool;
pub extern fn igColorEdit4(label: [*c]const u8, col: [*]f32, flags: ColorEditFlags) bool;
pub extern fn igColorPicker3(label: [*c]const u8, col: [*]f32, flags: ColorEditFlags) bool;
pub extern fn igColorPicker4(label: [*c]const u8, col: [*]f32, flags: ColorEditFlags, ref_col: [*c]const f32) bool;
pub extern fn igColorButton(desc_id: [*c]const u8, col: Vec4, flags: ColorEditFlags) bool;
pub extern fn igColorButtonEx(desc_id: [*c]const u8, col: Vec4, flags: ColorEditFlags, size: Vec2) bool;
pub extern fn igSetColorEditOptions(flags: ColorEditFlags) void;
pub extern fn igTreeNode(label: [*c]const u8) bool;
pub extern fn igTreeNodeStr(str_id: [*c]const u8, fmt: [*c]const u8, ...) bool;
pub extern fn igTreeNodePtr(ptr_id: [*c]const void, fmt: [*c]const u8, ...) bool;
// pub extern fn igTreeNodeV(str_id: [*c]const u8, fmt: [*c]const u8, args: va_list) bool;
// pub extern fn igTreeNodeVPtr(ptr_id: [*c]const void, fmt: [*c]const u8, args: va_list) bool;
pub extern fn igTreeNodeEx(label: [*c]const u8, flags: TreeNodeFlags) bool;
pub extern fn igTreeNodeExStr(str_id: [*c]const u8, flags: TreeNodeFlags, fmt: [*c]const u8, ...) bool;
pub extern fn igTreeNodeExPtr(ptr_id: [*c]const void, flags: TreeNodeFlags, fmt: [*c]const u8, ...) bool;
// pub extern fn igTreeNodeExV(str_id: [*c]const u8, flags: TreeNodeFlags, fmt: [*c]const u8, args: va_list) bool;
// pub extern fn igTreeNodeExVPtr(ptr_id: [*c]const void, flags: TreeNodeFlags, fmt: [*c]const u8, args: va_list) bool;
pub extern fn igTreePush(str_id: [*c]const u8) void;
pub extern fn igTreePushPtr(ptr_id: [*c]const void) void;
pub extern fn igTreePop() void;
pub extern fn igGetTreeNodeToLabelSpacing() f32;
pub extern fn igCollapsingHeader(label: [*c]const u8, flags: TreeNodeFlags) bool;
pub extern fn igCollapsingHeaderBoolPtr(label: [*c]const u8, p_visible: [*c]bool, flags: TreeNodeFlags) bool;
pub extern fn igSetNextItemOpen(is_open: bool, cond: Cond) void;
pub extern fn igSetNextItemStorageID(storage_id: u32) void;
pub extern fn igSelectable(label: [*c]const u8) bool;
pub extern fn igSelectableEx(label: [*c]const u8, selected: bool, flags: SelectableFlags, size: Vec2) bool;
pub extern fn igSelectableBoolPtr(label: [*c]const u8, p_selected: [*c]bool, flags: SelectableFlags) bool;
pub extern fn igSelectableBoolPtrEx(label: [*c]const u8, p_selected: [*c]bool, flags: SelectableFlags, size: Vec2) bool;
pub extern fn igBeginMultiSelect(flags: MultiSelectFlags) [*c]MultiSelectIO;
pub extern fn igBeginMultiSelectEx(flags: MultiSelectFlags, selection_size: c_int, items_count: c_int) [*c]MultiSelectIO;
pub extern fn igEndMultiSelect() [*c]MultiSelectIO;
pub extern fn igSetNextItemSelectionUserData(selection_user_data: SelectionUserData) void;
pub extern fn igIsItemToggledSelection() bool;
pub extern fn igBeginListBox(label: [*c]const u8, size: Vec2) bool;
pub extern fn igEndListBox() void;
pub extern fn igListBox(label: [*c]const u8, current_item: [*c]c_int, items: [*][*c]const u8, items_count: c_int, height_in_items: c_int) bool;
pub extern fn igListBoxCallback(label: [*c]const u8, current_item: [*c]c_int, getter: *const fn (user_data: *anyopaque, idx: c_int) [*c]const u8, user_data: *anyopaque, items_count: c_int) bool;
pub extern fn igListBoxCallbackEx(label: [*c]const u8, current_item: [*c]c_int, getter: *const fn (user_data: *anyopaque, idx: c_int) [*c]const u8, user_data: *anyopaque, items_count: c_int, height_in_items: c_int) bool;
pub extern fn igPlotLines(label: [*c]const u8, values: [*c]const f32, values_count: c_int) void;
pub extern fn igPlotLinesEx(label: [*c]const u8, values: [*c]const f32, values_count: c_int, values_offset: c_int, overlay_text: [*c]const u8, scale_min: f32, scale_max: f32, graph_size: Vec2, stride: c_int) void;
pub extern fn igPlotLinesCallback(label: [*c]const u8, values_getter: *const fn (data: *anyopaque, idx: c_int) f32, data: *anyopaque, values_count: c_int) void;
pub extern fn igPlotLinesCallbackEx(label: [*c]const u8, values_getter: *const fn (data: *anyopaque, idx: c_int) f32, data: *anyopaque, values_count: c_int, values_offset: c_int, overlay_text: [*c]const u8, scale_min: f32, scale_max: f32, graph_size: Vec2) void;
pub extern fn igPlotHistogram(label: [*c]const u8, values: [*c]const f32, values_count: c_int) void;
pub extern fn igPlotHistogramEx(label: [*c]const u8, values: [*c]const f32, values_count: c_int, values_offset: c_int, overlay_text: [*c]const u8, scale_min: f32, scale_max: f32, graph_size: Vec2, stride: c_int) void;
pub extern fn igPlotHistogramCallback(label: [*c]const u8, values_getter: *const fn (data: *anyopaque, idx: c_int) f32, data: *anyopaque, values_count: c_int) void;
pub extern fn igPlotHistogramCallbackEx(label: [*c]const u8, values_getter: *const fn (data: *anyopaque, idx: c_int) f32, data: *anyopaque, values_count: c_int, values_offset: c_int, overlay_text: [*c]const u8, scale_min: f32, scale_max: f32, graph_size: Vec2) void;
pub extern fn igBeginMenuBar() bool;
pub extern fn igEndMenuBar() void;
pub extern fn igBeginMainMenuBar() bool;
pub extern fn igEndMainMenuBar() void;
pub extern fn igBeginMenu(label: [*c]const u8) bool;
pub extern fn igBeginMenuEx(label: [*c]const u8, enabled: bool) bool;
pub extern fn igEndMenu() void;
pub extern fn igMenuItem(label: [*c]const u8) bool;
pub extern fn igMenuItemEx(label: [*c]const u8, shortcut: [*c]const u8, selected: bool, enabled: bool) bool;
pub extern fn igMenuItemBoolPtr(label: [*c]const u8, shortcut: [*c]const u8, p_selected: [*c]bool, enabled: bool) bool;
pub extern fn igBeginTooltip() bool;
pub extern fn igEndTooltip() void;
pub extern fn igSetTooltip(fmt: [*c]const u8, ...) void;
// pub extern fn igSetTooltipV(fmt: [*c]const u8, args: va_list) void;
pub extern fn igBeginItemTooltip() bool;
pub extern fn igSetItemTooltip(fmt: [*c]const u8, ...) void;
// pub extern fn igSetItemTooltipV(fmt: [*c]const u8, args: va_list) void;
pub extern fn igBeginPopup(str_id: [*c]const u8, flags: WindowFlags) bool;
pub extern fn igBeginPopupModal(name: [*c]const u8, p_open: [*c]bool, flags: WindowFlags) bool;
pub extern fn igEndPopup() void;
pub extern fn igOpenPopup(str_id: [*c]const u8, popup_flags: PopupFlags) void;
pub extern fn igOpenPopupID(id: u32, popup_flags: PopupFlags) void;
pub extern fn igOpenPopupOnItemClick(str_id: [*c]const u8, popup_flags: PopupFlags) void;
pub extern fn igCloseCurrentPopup() void;
pub extern fn igBeginPopupContextItem() bool;
pub extern fn igBeginPopupContextItemEx(str_id: [*c]const u8, popup_flags: PopupFlags) bool;
pub extern fn igBeginPopupContextWindow() bool;
pub extern fn igBeginPopupContextWindowEx(str_id: [*c]const u8, popup_flags: PopupFlags) bool;
pub extern fn igBeginPopupContextVoid() bool;
pub extern fn igBeginPopupContextVoidEx(str_id: [*c]const u8, popup_flags: PopupFlags) bool;
pub extern fn igIsPopupOpen(str_id: [*c]const u8, flags: PopupFlags) bool;
pub extern fn igBeginTable(str_id: [*c]const u8, columns: c_int, flags: TableFlags) bool;
pub extern fn igBeginTableEx(str_id: [*c]const u8, columns: c_int, flags: TableFlags, outer_size: Vec2, inner_width: f32) bool;
pub extern fn igEndTable() void;
pub extern fn igTableNextRow() void;
pub extern fn igTableNextRowEx(row_flags: TableRowFlags, min_row_height: f32) void;
pub extern fn igTableNextColumn() bool;
pub extern fn igTableSetColumnIndex(column_n: c_int) bool;
pub extern fn igTableSetupColumn(label: [*c]const u8, flags: TableColumnFlags) void;
pub extern fn igTableSetupColumnEx(label: [*c]const u8, flags: TableColumnFlags, init_width_or_weight: f32, user_id: u32) void;
pub extern fn igTableSetupScrollFreeze(cols: c_int, rows: c_int) void;
pub extern fn igTableHeader(label: [*c]const u8) void;
pub extern fn igTableHeadersRow() void;
pub extern fn igTableAngledHeadersRow() void;
pub extern fn igTableGetSortSpecs() [*c]TableSortSpecs;
pub extern fn igTableGetColumnCount() c_int;
pub extern fn igTableGetColumnIndex() c_int;
pub extern fn igTableGetRowIndex() c_int;
pub extern fn igTableGetColumnName(column_n: c_int) [*c]const u8;
pub extern fn igTableGetColumnFlags(column_n: c_int) TableColumnFlags;
pub extern fn igTableSetColumnEnabled(column_n: c_int, v: bool) void;
pub extern fn igTableGetHoveredColumn() c_int;
pub extern fn igTableSetBgColor(target: TableBgTarget, color: u32, column_n: c_int) void;
pub extern fn igColumns() void;
pub extern fn igColumnsEx(count: c_int, id: [*c]const u8, borders: bool) void;
pub extern fn igNextColumn() void;
pub extern fn igGetColumnIndex() c_int;
pub extern fn igGetColumnWidth(column_index: c_int) f32;
pub extern fn igSetColumnWidth(column_index: c_int, width: f32) void;
pub extern fn igGetColumnOffset(column_index: c_int) f32;
pub extern fn igSetColumnOffset(column_index: c_int, offset_x: f32) void;
pub extern fn igGetColumnsCount() c_int;
pub extern fn igBeginTabBar(str_id: [*c]const u8, flags: TabBarFlags) bool;
pub extern fn igEndTabBar() void;
pub extern fn igBeginTabItem(label: [*c]const u8, p_open: [*c]bool, flags: TabItemFlags) bool;
pub extern fn igEndTabItem() void;
pub extern fn igTabItemButton(label: [*c]const u8, flags: TabItemFlags) bool;
pub extern fn igSetTabItemClosed(tab_or_docked_window_label: [*c]const u8) void;
pub extern fn igDockSpace(dockspace_id: u32) u32;
pub extern fn igDockSpaceEx(dockspace_id: u32, size: Vec2, flags: DockNodeFlags, window_class: [*c]const WindowClass) u32;
pub extern fn igDockSpaceOverViewport() u32;
pub extern fn igDockSpaceOverViewportEx(dockspace_id: u32, viewport: [*c]const Viewport, flags: DockNodeFlags, window_class: [*c]const WindowClass) u32;
pub extern fn igSetNextWindowDockID(dock_id: u32, cond: Cond) void;
pub extern fn igSetNextWindowClass(window_class: [*c]const WindowClass) void;
pub extern fn igGetWindowDockID() u32;
pub extern fn igIsWindowDocked() bool;
pub extern fn igLogToTTY(auto_open_depth: c_int) void;
pub extern fn igLogToFile(auto_open_depth: c_int, filename: [*c]const u8) void;
pub extern fn igLogToClipboard(auto_open_depth: c_int) void;
pub extern fn igLogFinish() void;
pub extern fn igLogButtons() void;
pub extern fn igLogText(fmt: [*c]const u8, ...) void;
// pub extern fn igLogTextV(fmt: [*c]const u8, args: va_list) void;
pub extern fn igBeginDragDropSource(flags: DragDropFlags) bool;
pub extern fn igSetDragDropPayload(type: [*c]const u8, data: *anyopaque, sz: usize, cond: Cond) bool;
pub extern fn igEndDragDropSource() void;
pub extern fn igBeginDragDropTarget() bool;
pub extern fn igAcceptDragDropPayload(type: [*c]const u8, flags: DragDropFlags) ?*const Payload;
pub extern fn igEndDragDropTarget() void;
pub extern fn igGetDragDropPayload() [*c]const Payload;
pub extern fn igBeginDisabled(disabled: bool) void;
pub extern fn igEndDisabled() void;
pub extern fn igPushClipRect(clip_rect_min: Vec2, clip_rect_max: Vec2, intersect_with_current_clip_rect: bool) void;
pub extern fn igPopClipRect() void;
pub extern fn igSetItemDefaultFocus() void;
pub extern fn igSetKeyboardFocusHere() void;
pub extern fn igSetKeyboardFocusHereEx(offset: c_int) void;
pub extern fn igSetNavCursorVisible(visible: bool) void;
pub extern fn igSetNextItemAllowOverlap() void;
pub extern fn igIsItemHovered(flags: HoveredFlags) bool;
pub extern fn igIsItemActive() bool;
pub extern fn igIsItemFocused() bool;
pub extern fn igIsItemClicked() bool;
pub extern fn igIsItemClickedEx(mouse_button: MouseButton) bool;
pub extern fn igIsItemVisible() bool;
pub extern fn igIsItemEdited() bool;
pub extern fn igIsItemActivated() bool;
pub extern fn igIsItemDeactivated() bool;
pub extern fn igIsItemDeactivatedAfterEdit() bool;
pub extern fn igIsItemToggledOpen() bool;
pub extern fn igIsAnyItemHovered() bool;
pub extern fn igIsAnyItemActive() bool;
pub extern fn igIsAnyItemFocused() bool;
pub extern fn igGetItemID() u32;
pub extern fn igGetItemRectMin() Vec2;
pub extern fn igGetItemRectMax() Vec2;
pub extern fn igGetItemRectSize() Vec2;
pub extern fn igGetMainViewport() ?*Viewport;
pub extern fn igGetBackgroundDrawList() [*c]DrawList;
pub extern fn igGetBackgroundDrawListEx(viewport: [*c]Viewport) [*c]DrawList;
pub extern fn igGetForegroundDrawList() [*c]DrawList;
pub extern fn igGetForegroundDrawListEx(viewport: [*c]Viewport) [*c]DrawList;
pub extern fn igIsRectVisibleBySize(size: Vec2) bool;
pub extern fn igIsRectVisible(rect_min: Vec2, rect_max: Vec2) bool;
pub extern fn igGetTime() f64;
pub extern fn igGetFrameCount() c_int;
pub extern fn igGetDrawListSharedData() [*c]DrawListSharedData;
pub extern fn igGetStyleColorName(idx: Col) [*c]const u8;
pub extern fn igSetStateStorage(storage: [*c]Storage) void;
pub extern fn igGetStateStorage() [*c]Storage;
pub extern fn igCalcTextSize(text: [*c]const u8) Vec2;
pub extern fn igCalcTextSizeEx(text: [*c]const u8, text_end: [*c]const u8, hide_text_after_double_hash: bool, wrap_width: f32) Vec2;
pub extern fn igColorConvertU32ToFloat4(in: u32) Vec4;
pub extern fn igColorConvertFloat4ToU32(in: Vec4) u32;
pub extern fn igColorConvertRGBtoHSV(r: f32, g: f32, b: f32, out_h: [*c]f32, out_s: [*c]f32, out_v: [*c]f32) void;
pub extern fn igColorConvertHSVtoRGB(h: f32, s: f32, v: f32, out_r: [*c]f32, out_g: [*c]f32, out_b: [*c]f32) void;
pub extern fn igIsKeyDown(key: Key) bool;
pub extern fn igIsKeyPressed(key: Key) bool;
pub extern fn igIsKeyPressedEx(key: Key, repeat: bool) bool;
pub extern fn igIsKeyReleased(key: Key) bool;
pub extern fn igIsKeyChordPressed(key_chord: KeyChord) bool;
pub extern fn igGetKeyPressedAmount(key: Key, repeat_delay: f32, rate: f32) c_int;
pub extern fn igGetKeyName(key: Key) [*c]const u8;
pub extern fn igSetNextFrameWantCaptureKeyboard(want_capture_keyboard: bool) void;
pub extern fn igShortcut(key_chord: KeyChord, flags: InputFlags) bool;
pub extern fn igSetNextItemShortcut(key_chord: KeyChord, flags: InputFlags) void;
pub extern fn igSetItemKeyOwner(key: Key) void;
pub extern fn igIsMouseDown(button: MouseButton) bool;
pub extern fn igIsMouseClicked(button: MouseButton) bool;
pub extern fn igIsMouseClickedEx(button: MouseButton, repeat: bool) bool;
pub extern fn igIsMouseReleased(button: MouseButton) bool;
pub extern fn igIsMouseDoubleClicked(button: MouseButton) bool;
pub extern fn igGetMouseClickedCount(button: MouseButton) c_int;
pub extern fn igIsMouseHoveringRect(r_min: Vec2, r_max: Vec2) bool;
pub extern fn igIsMouseHoveringRectEx(r_min: Vec2, r_max: Vec2, clip: bool) bool;
pub extern fn igIsMousePosValid(mouse_pos: [*c]const Vec2) bool;
pub extern fn igIsAnyMouseDown() bool;
pub extern fn igGetMousePos() Vec2;
pub extern fn igGetMousePosOnOpeningCurrentPopup() Vec2;
pub extern fn igIsMouseDragging(button: MouseButton, lock_threshold: f32) bool;
pub extern fn igGetMouseDragDelta(button: MouseButton, lock_threshold: f32) Vec2;
pub extern fn igResetMouseDragDelta() void;
pub extern fn igResetMouseDragDeltaEx(button: MouseButton) void;
pub extern fn igGetMouseCursor() MouseCursor;
pub extern fn igSetMouseCursor(cursor_type: MouseCursor) void;
pub extern fn igSetNextFrameWantCaptureMouse(want_capture_mouse: bool) void;
pub extern fn igGetClipboardText() [*c]const u8;
pub extern fn igSetClipboardText(text: [*c]const u8) void;
pub extern fn igLoadIniSettingsFromDisk(ini_filename: [*c]const u8) void;
pub extern fn igLoadIniSettingsFromMemory(ini_data: [*c]const u8, ini_size: usize) void;
pub extern fn igSaveIniSettingsToDisk(ini_filename: [*c]const u8) void;
pub extern fn igSaveIniSettingsToMemory(out_ini_size: [*c]usize) [*c]const u8;
pub extern fn igDebugTextEncoding(text: [*c]const u8) void;
pub extern fn igDebugFlashStyleColor(idx: Col) void;
pub extern fn igDebugStartItemPicker() void;
pub extern fn igDebugCheckVersionAndDataLayout(version_str: [*c]const u8, sz_io: usize, sz_style: usize, sz_vec2: usize, sz_vec4: usize, sz_drawvert: usize, sz_drawidx: usize) bool;
pub extern fn igDebugLog(fmt: [*c]const u8, ...) void;
// pub extern fn igDebugLogV(fmt: [*c]const u8, args: va_list) void;
pub extern fn igSetAllocatorFunctions(alloc_func: MemAllocFunc, free_func: MemFreeFunc, user_data: ?*anyopaque) void;
pub extern fn igGetAllocatorFunctions(p_alloc_func: *MemAllocFunc, p_free_func: *MemFreeFunc, p_user_data: **anyopaque) void;
pub extern fn igMemAlloc(size: usize) *anyopaque;
pub extern fn igMemFree(ptr: *anyopaque) void;
pub extern fn igUpdatePlatformWindows() void;
pub extern fn igRenderPlatformWindowsDefault() void;
pub extern fn igRenderPlatformWindowsDefaultEx(platform_render_arg: *anyopaque, renderer_render_arg: *anyopaque) void;
pub extern fn igDestroyPlatformWindows() void;
pub extern fn igFindViewportByID(id: u32) [*c]Viewport;
pub extern fn igFindViewportByPlatformHandle(platform_handle: *anyopaque) [*c]Viewport;
pub extern fn ImVector_Construct(vector: *anyopaque) void;
pub extern fn ImVector_Destruct(vector: *anyopaque) void;
// pub extern fn ImStr_FromCharStr(b: [*c]const u8) Str;
pub extern fn ImGuiStyle_ScaleAllSizes(self: *Style, scale_factor: f32) void;
pub extern fn ImGuiIO_AddKeyEvent(self: *IO, key: Key, down: bool) void;
pub extern fn ImGuiIO_AddKeyAnalogEvent(self: *IO, key: Key, down: bool, v: f32) void;
pub extern fn ImGuiIO_AddMousePosEvent(self: *IO, x: f32, y: f32) void;
pub extern fn ImGuiIO_AddMouseButtonEvent(self: *IO, button: c_int, down: bool) void;
pub extern fn ImGuiIO_AddMouseWheelEvent(self: *IO, wheel_x: f32, wheel_y: f32) void;
pub extern fn ImGuiIO_AddMouseSourceEvent(self: *IO, source: MouseSource) void;
pub extern fn ImGuiIO_AddMouseViewportEvent(self: *IO, id: u32) void;
pub extern fn ImGuiIO_AddFocusEvent(self: *IO, focused: bool) void;
pub extern fn ImGuiIO_AddInputCharacter(self: *IO, c: c_uint) void;
pub extern fn ImGuiIO_AddInputCharacterUTF16(self: *IO, c: c_ushort) void;
pub extern fn ImGuiIO_AddInputCharactersUTF8(self: *IO, str: [*c]const u8) void;
pub extern fn ImGuiIO_SetKeyEventNativeData(self: *IO, key: Key, native_keycode: c_int, native_scancode: c_int) void;
pub extern fn ImGuiIO_SetKeyEventNativeDataEx(self: *IO, key: Key, native_keycode: c_int, native_scancode: c_int, native_legacy_index: c_int) void;
pub extern fn ImGuiIO_SetAppAcceptingEvents(self: *IO, accepting_events: bool) void;
pub extern fn ImGuiIO_ClearEventsQueue(self: *IO) void;
pub extern fn ImGuiIO_ClearInputKeys(self: *IO) void;
pub extern fn ImGuiIO_ClearInputMouse(self: *IO) void;
pub extern fn ImGuiIO_ClearInputCharacters(self: *IO) void;
pub extern fn ImGuiInputTextCallbackData_DeleteChars(self: *InputTextCallbackData, pos: c_int, bytes_count: c_int) void;
pub extern fn ImGuiInputTextCallbackData_InsertChars(self: *InputTextCallbackData, pos: c_int, text: [*c]const u8, text_end: [*c]const u8) void;
pub extern fn ImGuiInputTextCallbackData_SelectAll(self: *InputTextCallbackData) void;
pub extern fn ImGuiInputTextCallbackData_ClearSelection(self: *InputTextCallbackData) void;
pub extern fn ImGuiInputTextCallbackData_HasSelection(self: *InputTextCallbackData) bool;
pub extern fn ImGuiPayload_Clear(self: *Payload) void;
pub extern fn ImGuiPayload_IsDataType(self: *Payload, type: [*c]const u8) bool;
pub extern fn ImGuiPayload_IsPreview(self: *Payload) bool;
pub extern fn ImGuiPayload_IsDelivery(self: *Payload) bool;
pub extern fn ImGuiTextFilter_ImGuiTextRange_empty(self: *TextFilter_TextRange) bool;
pub extern fn ImGuiTextFilter_ImGuiTextRange_split(self: *TextFilter_TextRange, separator: u8, out: [*c]Vector_TextFilter_TextRange) void;
pub extern fn ImGuiTextFilter_Draw(self: *TextFilter, label: [*c]const u8, width: f32) bool;
pub extern fn ImGuiTextFilter_PassFilter(self: *TextFilter, text: [*c]const u8, text_end: [*c]const u8) bool;
pub extern fn ImGuiTextFilter_Build(self: *TextFilter) void;
pub extern fn ImGuiTextFilter_Clear(self: *TextFilter) void;
pub extern fn ImGuiTextFilter_IsActive(self: *TextFilter) bool;
pub extern fn ImGuiTextBuffer_begin(self: *TextBuffer) [*c]const u8;
pub extern fn ImGuiTextBuffer_end(self: *TextBuffer) [*c]const u8;
pub extern fn ImGuiTextBuffer_size(self: *TextBuffer) c_int;
pub extern fn ImGuiTextBuffer_empty(self: *TextBuffer) bool;
pub extern fn ImGuiTextBuffer_clear(self: *TextBuffer) void;
pub extern fn ImGuiTextBuffer_reserve(self: *TextBuffer, capacity: c_int) void;
pub extern fn ImGuiTextBuffer_c_str(self: *TextBuffer) [*c]const u8;
pub extern fn ImGuiTextBuffer_append(self: *TextBuffer, str: [*c]const u8, str_end: [*c]const u8) void;
pub extern fn ImGuiTextBuffer_appendf(self: *TextBuffer, fmt: [*c]const u8, ...) void;
// pub extern fn ImGuiTextBuffer_appendfv(self: *TextBuffer, fmt: [*c]const u8, args: va_list) void;
pub extern fn ImGuiStorage_Clear(self: *Storage) void;
pub extern fn ImGuiStorage_GetInt(self: *Storage, key: u32, default_val: c_int) c_int;
pub extern fn ImGuiStorage_SetInt(self: *Storage, key: u32, val: c_int) void;
pub extern fn ImGuiStorage_GetBool(self: *Storage, key: u32, default_val: bool) bool;
pub extern fn ImGuiStorage_SetBool(self: *Storage, key: u32, val: bool) void;
pub extern fn ImGuiStorage_GetFloat(self: *Storage, key: u32, default_val: f32) f32;
pub extern fn ImGuiStorage_SetFloat(self: *Storage, key: u32, val: f32) void;
pub extern fn ImGuiStorage_GetVoidPtr(self: *Storage, key: u32) *anyopaque;
pub extern fn ImGuiStorage_SetVoidPtr(self: *Storage, key: u32, val: *anyopaque) void;
pub extern fn ImGuiStorage_GetIntRef(self: *Storage, key: u32, default_val: c_int) [*c]c_int;
pub extern fn ImGuiStorage_GetBoolRef(self: *Storage, key: u32, default_val: bool) [*c]bool;
pub extern fn ImGuiStorage_GetFloatRef(self: *Storage, key: u32, default_val: f32) [*c]f32;
pub extern fn ImGuiStorage_GetVoidPtrRef(self: *Storage, key: u32, default_val: *anyopaque) [*c]*anyopaque;
pub extern fn ImGuiStorage_BuildSortByKey(self: *Storage) void;
pub extern fn ImGuiStorage_SetAllInt(self: *Storage, val: c_int) void;
pub extern fn ImGuiListClipper_Begin(self: *ListClipper, items_count: c_int, items_height: f32) void;
pub extern fn ImGuiListClipper_End(self: *ListClipper) void;
pub extern fn ImGuiListClipper_Step(self: *ListClipper) bool;
pub extern fn ImGuiListClipper_IncludeItemByIndex(self: *ListClipper, item_index: c_int) void;
pub extern fn ImGuiListClipper_IncludeItemsByIndex(self: *ListClipper, item_begin: c_int, item_end: c_int) void;
pub extern fn ImGuiListClipper_SeekCursorForItem(self: *ListClipper, item_index: c_int) void;
pub extern fn ImGuiListClipper_IncludeRangeByIndices(self: *ListClipper, item_begin: c_int, item_end: c_int) void;
pub extern fn ImGuiListClipper_ForceDisplayRangeByIndices(self: *ListClipper, item_begin: c_int, item_end: c_int) void;
pub extern fn ImColor_SetHSV(self: *Color, h: f32, s: f32, v: f32, a: f32) void;
pub extern fn ImColor_HSV(h: f32, s: f32, v: f32, a: f32) Color;
pub extern fn ImGuiSelectionBasicStorage_ApplyRequests(self: *SelectionBasicStorage, ms_io: [*c]MultiSelectIO) void;
pub extern fn ImGuiSelectionBasicStorage_Contains(self: *SelectionBasicStorage, id: u32) bool;
pub extern fn ImGuiSelectionBasicStorage_Clear(self: *SelectionBasicStorage) void;
pub extern fn ImGuiSelectionBasicStorage_Swap(self: *SelectionBasicStorage, r: [*c]SelectionBasicStorage) void;
pub extern fn ImGuiSelectionBasicStorage_SetItemSelected(self: *SelectionBasicStorage, id: u32, selected: bool) void;
pub extern fn ImGuiSelectionBasicStorage_GetNextSelectedItem(self: *SelectionBasicStorage, opaque_it: [*c]*anyopaque, out_id: [*c]u32) bool;
pub extern fn ImGuiSelectionBasicStorage_GetStorageIdFromIndex(self: *SelectionBasicStorage, idx: c_int) u32;
pub extern fn ImGuiSelectionExternalStorage_ApplyRequests(self: *SelectionExternalStorage, ms_io: [*c]MultiSelectIO) void;
pub extern fn ImDrawCmd_GetTexID(self: *DrawCmd) TextureID;
pub extern fn ImDrawListSplitter_Clear(self: *DrawListSplitter) void;
pub extern fn ImDrawListSplitter_ClearFreeMemory(self: *DrawListSplitter) void;
pub extern fn ImDrawListSplitter_Split(self: *DrawListSplitter, draw_list: [*c]DrawList, count: c_int) void;
pub extern fn ImDrawListSplitter_Merge(self: *DrawListSplitter, draw_list: [*c]DrawList) void;
pub extern fn ImDrawListSplitter_SetCurrentChannel(self: *DrawListSplitter, draw_list: [*c]DrawList, channel_idx: c_int) void;
pub extern fn ImDrawList_PushClipRect(self: *DrawList, clip_rect_min: Vec2, clip_rect_max: Vec2, intersect_with_current_clip_rect: bool) void;
pub extern fn ImDrawList_PushClipRectFullScreen(self: *DrawList) void;
pub extern fn ImDrawList_PopClipRect(self: *DrawList) void;
pub extern fn ImDrawList_PushTextureID(self: *DrawList, texture_id: TextureID) void;
pub extern fn ImDrawList_PopTextureID(self: *DrawList) void;
pub extern fn ImDrawList_GetClipRectMin(self: *DrawList) Vec2;
pub extern fn ImDrawList_GetClipRectMax(self: *DrawList) Vec2;
pub extern fn ImDrawList_AddLine(self: *DrawList, p1: Vec2, p2: Vec2, col: u32) void;
pub extern fn ImDrawList_AddLineEx(self: *DrawList, p1: Vec2, p2: Vec2, col: u32, thickness: f32) void;
pub extern fn ImDrawList_AddRect(self: *DrawList, p_min: Vec2, p_max: Vec2, col: u32) void;
pub extern fn ImDrawList_AddRectEx(self: *DrawList, p_min: Vec2, p_max: Vec2, col: u32, rounding: f32, flags: DrawFlags, thickness: f32) void;
pub extern fn ImDrawList_AddRectFilled(self: *DrawList, p_min: Vec2, p_max: Vec2, col: u32) void;
pub extern fn ImDrawList_AddRectFilledEx(self: *DrawList, p_min: Vec2, p_max: Vec2, col: u32, rounding: f32, flags: DrawFlags) void;
pub extern fn ImDrawList_AddRectFilledMultiColor(self: *DrawList, p_min: Vec2, p_max: Vec2, col_upr_left: u32, col_upr_right: u32, col_bot_right: u32, col_bot_left: u32) void;
pub extern fn ImDrawList_AddQuad(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, p4: Vec2, col: u32) void;
pub extern fn ImDrawList_AddQuadEx(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, p4: Vec2, col: u32, thickness: f32) void;
pub extern fn ImDrawList_AddQuadFilled(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, p4: Vec2, col: u32) void;
pub extern fn ImDrawList_AddTriangle(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, col: u32) void;
pub extern fn ImDrawList_AddTriangleEx(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, col: u32, thickness: f32) void;
pub extern fn ImDrawList_AddTriangleFilled(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, col: u32) void;
pub extern fn ImDrawList_AddCircle(self: *DrawList, center: Vec2, radius: f32, col: u32) void;
pub extern fn ImDrawList_AddCircleEx(self: *DrawList, center: Vec2, radius: f32, col: u32, num_segments: c_int, thickness: f32) void;
pub extern fn ImDrawList_AddCircleFilled(self: *DrawList, center: Vec2, radius: f32, col: u32, num_segments: c_int) void;
pub extern fn ImDrawList_AddNgon(self: *DrawList, center: Vec2, radius: f32, col: u32, num_segments: c_int) void;
pub extern fn ImDrawList_AddNgonEx(self: *DrawList, center: Vec2, radius: f32, col: u32, num_segments: c_int, thickness: f32) void;
pub extern fn ImDrawList_AddNgonFilled(self: *DrawList, center: Vec2, radius: f32, col: u32, num_segments: c_int) void;
pub extern fn ImDrawList_AddEllipse(self: *DrawList, center: Vec2, radius: Vec2, col: u32) void;
pub extern fn ImDrawList_AddEllipseEx(self: *DrawList, center: Vec2, radius: Vec2, col: u32, rot: f32, num_segments: c_int, thickness: f32) void;
pub extern fn ImDrawList_AddEllipseFilled(self: *DrawList, center: Vec2, radius: Vec2, col: u32) void;
pub extern fn ImDrawList_AddEllipseFilledEx(self: *DrawList, center: Vec2, radius: Vec2, col: u32, rot: f32, num_segments: c_int) void;
pub extern fn ImDrawList_AddText(self: *DrawList, pos: Vec2, col: u32, text_begin: [*c]const u8) void;
pub extern fn ImDrawList_AddTextEx(self: *DrawList, pos: Vec2, col: u32, text_begin: [*c]const u8, text_end: [*c]const u8) void;
pub extern fn ImDrawList_AddTextImFontPtr(self: *DrawList, font: [*c]Font, font_size: f32, pos: Vec2, col: u32, text_begin: [*c]const u8) void;
pub extern fn ImDrawList_AddTextImFontPtrEx(self: *DrawList, font: [*c]Font, font_size: f32, pos: Vec2, col: u32, text_begin: [*c]const u8, text_end: [*c]const u8, wrap_width: f32, cpu_fine_clip_rect: [*c]const Vec4) void;
pub extern fn ImDrawList_AddBezierCubic(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, p4: Vec2, col: u32, thickness: f32, num_segments: c_int) void;
pub extern fn ImDrawList_AddBezierQuadratic(self: *DrawList, p1: Vec2, p2: Vec2, p3: Vec2, col: u32, thickness: f32, num_segments: c_int) void;
pub extern fn ImDrawList_AddPolyline(self: *DrawList, points: [*c]const Vec2, num_points: c_int, col: u32, flags: DrawFlags, thickness: f32) void;
pub extern fn ImDrawList_AddConvexPolyFilled(self: *DrawList, points: [*c]const Vec2, num_points: c_int, col: u32) void;
pub extern fn ImDrawList_AddConcavePolyFilled(self: *DrawList, points: [*c]const Vec2, num_points: c_int, col: u32) void;
pub extern fn ImDrawList_AddImage(self: *DrawList, user_texture_id: TextureID, p_min: Vec2, p_max: Vec2) void;
pub extern fn ImDrawList_AddImageEx(self: *DrawList, user_texture_id: TextureID, p_min: Vec2, p_max: Vec2, uv_min: Vec2, uv_max: Vec2, col: u32) void;
pub extern fn ImDrawList_AddImageQuad(self: *DrawList, user_texture_id: TextureID, p1: Vec2, p2: Vec2, p3: Vec2, p4: Vec2) void;
pub extern fn ImDrawList_AddImageQuadEx(self: *DrawList, user_texture_id: TextureID, p1: Vec2, p2: Vec2, p3: Vec2, p4: Vec2, uv1: Vec2, uv2: Vec2, uv3: Vec2, uv4: Vec2, col: u32) void;
pub extern fn ImDrawList_AddImageRounded(self: *DrawList, user_texture_id: TextureID, p_min: Vec2, p_max: Vec2, uv_min: Vec2, uv_max: Vec2, col: u32, rounding: f32, flags: DrawFlags) void;
pub extern fn ImDrawList_PathClear(self: *DrawList) void;
pub extern fn ImDrawList_PathLineTo(self: *DrawList, pos: Vec2) void;
pub extern fn ImDrawList_PathLineToMergeDuplicate(self: *DrawList, pos: Vec2) void;
pub extern fn ImDrawList_PathFillConvex(self: *DrawList, col: u32) void;
pub extern fn ImDrawList_PathFillConcave(self: *DrawList, col: u32) void;
pub extern fn ImDrawList_PathStroke(self: *DrawList, col: u32, flags: DrawFlags, thickness: f32) void;
pub extern fn ImDrawList_PathArcTo(self: *DrawList, center: Vec2, radius: f32, a_min: f32, a_max: f32, num_segments: c_int) void;
pub extern fn ImDrawList_PathArcToFast(self: *DrawList, center: Vec2, radius: f32, a_min_of_12: c_int, a_max_of_12: c_int) void;
pub extern fn ImDrawList_PathEllipticalArcTo(self: *DrawList, center: Vec2, radius: Vec2, rot: f32, a_min: f32, a_max: f32) void;
pub extern fn ImDrawList_PathEllipticalArcToEx(self: *DrawList, center: Vec2, radius: Vec2, rot: f32, a_min: f32, a_max: f32, num_segments: c_int) void;
pub extern fn ImDrawList_PathBezierCubicCurveTo(self: *DrawList, p2: Vec2, p3: Vec2, p4: Vec2, num_segments: c_int) void;
pub extern fn ImDrawList_PathBezierQuadraticCurveTo(self: *DrawList, p2: Vec2, p3: Vec2, num_segments: c_int) void;
pub extern fn ImDrawList_PathRect(self: *DrawList, rect_min: Vec2, rect_max: Vec2, rounding: f32, flags: DrawFlags) void;
pub extern fn ImDrawList_AddCallback(self: *DrawList, callback: DrawCallback, userdata: *anyopaque) void;
pub extern fn ImDrawList_AddCallbackEx(self: *DrawList, callback: DrawCallback, userdata: *anyopaque, userdata_size: usize) void;
pub extern fn ImDrawList_AddDrawCmd(self: *DrawList) void;
pub extern fn ImDrawList_CloneOutput(self: *DrawList) [*c]DrawList;
pub extern fn ImDrawList_ChannelsSplit(self: *DrawList, count: c_int) void;
pub extern fn ImDrawList_ChannelsMerge(self: *DrawList) void;
pub extern fn ImDrawList_ChannelsSetCurrent(self: *DrawList, n: c_int) void;
pub extern fn ImDrawList_PrimReserve(self: *DrawList, idx_count: c_int, vtx_count: c_int) void;
pub extern fn ImDrawList_PrimUnreserve(self: *DrawList, idx_count: c_int, vtx_count: c_int) void;
pub extern fn ImDrawList_PrimRect(self: *DrawList, a: Vec2, b: Vec2, col: u32) void;
pub extern fn ImDrawList_PrimRectUV(self: *DrawList, a: Vec2, b: Vec2, uv_a: Vec2, uv_b: Vec2, col: u32) void;
pub extern fn ImDrawList_PrimQuadUV(self: *DrawList, a: Vec2, b: Vec2, c: Vec2, d: Vec2, uv_a: Vec2, uv_b: Vec2, uv_c: Vec2, uv_d: Vec2, col: u32) void;
pub extern fn ImDrawList_PrimWriteVtx(self: *DrawList, pos: Vec2, uv: Vec2, col: u32) void;
pub extern fn ImDrawList_PrimWriteIdx(self: *DrawList, idx: DrawIdx) void;
pub extern fn ImDrawList_PrimVtx(self: *DrawList, pos: Vec2, uv: Vec2, col: u32) void;
pub extern fn ImDrawList__ResetForNewFrame(self: *DrawList) void;
pub extern fn ImDrawList__ClearFreeMemory(self: *DrawList) void;
pub extern fn ImDrawList__PopUnusedDrawCmd(self: *DrawList) void;
pub extern fn ImDrawList__TryMergeDrawCmds(self: *DrawList) void;
pub extern fn ImDrawList__OnChangedClipRect(self: *DrawList) void;
pub extern fn ImDrawList__OnChangedTextureID(self: *DrawList) void;
pub extern fn ImDrawList__OnChangedVtxOffset(self: *DrawList) void;
pub extern fn ImDrawList__SetTextureID(self: *DrawList, texture_id: TextureID) void;
pub extern fn ImDrawList__CalcCircleAutoSegmentCount(self: *DrawList, radius: f32) c_int;
pub extern fn ImDrawList__PathArcToFastEx(self: *DrawList, center: Vec2, radius: f32, a_min_sample: c_int, a_max_sample: c_int, a_step: c_int) void;
pub extern fn ImDrawList__PathArcToN(self: *DrawList, center: Vec2, radius: f32, a_min: f32, a_max: f32, num_segments: c_int) void;
pub extern fn ImDrawData_Clear(self: *DrawData) void;
pub extern fn ImDrawData_AddDrawList(self: *DrawData, draw_list: [*c]DrawList) void;
pub extern fn ImDrawData_DeIndexAllBuffers(self: *DrawData) void;
pub extern fn ImDrawData_ScaleClipRects(self: *DrawData, fb_scale: Vec2) void;
pub extern fn ImFontGlyphRangesBuilder_Clear(self: *FontGlyphRangesBuilder) void;
pub extern fn ImFontGlyphRangesBuilder_GetBit(self: *FontGlyphRangesBuilder, n: usize) bool;
pub extern fn ImFontGlyphRangesBuilder_SetBit(self: *FontGlyphRangesBuilder, n: usize) void;
pub extern fn ImFontGlyphRangesBuilder_AddChar(self: *FontGlyphRangesBuilder, c: Wchar) void;
pub extern fn ImFontGlyphRangesBuilder_AddText(self: *FontGlyphRangesBuilder, text: [*c]const u8, text_end: [*c]const u8) void;
pub extern fn ImFontGlyphRangesBuilder_AddRanges(self: *FontGlyphRangesBuilder, ranges: [*c]const Wchar) void;
pub extern fn ImFontGlyphRangesBuilder_BuildRanges(self: *FontGlyphRangesBuilder, out_ranges: [*c]Vector_ImWchar) void;
pub extern fn ImFontAtlasCustomRect_IsPacked(self: *FontAtlasCustomRect) bool;
pub extern fn ImFontAtlas_AddFont(self: *FontAtlas, font_cfg: [*c]const FontConfig) [*c]Font;
pub extern fn ImFontAtlas_AddFontDefault(self: *FontAtlas, font_cfg: [*c]const FontConfig) [*c]Font;
pub extern fn ImFontAtlas_AddFontFromFileTTF(self: *FontAtlas, filename: [*c]const u8, size_pixels: f32, font_cfg: [*c]const FontConfig, glyph_ranges: [*c]const Wchar) [*c]Font;
pub extern fn ImFontAtlas_AddFontFromMemoryTTF(self: *FontAtlas, font_data: *anyopaque, font_data_size: c_int, size_pixels: f32, font_cfg: [*c]const FontConfig, glyph_ranges: [*c]const Wchar) [*c]Font;
pub extern fn ImFontAtlas_AddFontFromMemoryCompressedTTF(self: *FontAtlas, compressed_font_data: [*c]const void, compressed_font_data_size: c_int, size_pixels: f32, font_cfg: [*c]const FontConfig, glyph_ranges: [*c]const Wchar) [*c]Font;
pub extern fn ImFontAtlas_AddFontFromMemoryCompressedBase85TTF(self: *FontAtlas, compressed_font_data_base85: [*c]const u8, size_pixels: f32, font_cfg: [*c]const FontConfig, glyph_ranges: [*c]const Wchar) [*c]Font;
pub extern fn ImFontAtlas_ClearInputData(self: *FontAtlas) void;
pub extern fn ImFontAtlas_ClearTexData(self: *FontAtlas) void;
pub extern fn ImFontAtlas_ClearFonts(self: *FontAtlas) void;
pub extern fn ImFontAtlas_Clear(self: *FontAtlas) void;
pub extern fn ImFontAtlas_Build(self: *FontAtlas) bool;
pub extern fn ImFontAtlas_GetTexDataAsAlpha8(self: *FontAtlas, out_pixels: [*c][*c]c_char, out_width: [*c]c_int, out_height: [*c]c_int, out_bytes_per_pixel: [*c]c_int) void;
pub extern fn ImFontAtlas_GetTexDataAsRGBA32(self: *FontAtlas, out_pixels: [*c][*c]c_char, out_width: [*c]c_int, out_height: [*c]c_int, out_bytes_per_pixel: [*c]c_int) void;
pub extern fn ImFontAtlas_IsBuilt(self: *FontAtlas) bool;
pub extern fn ImFontAtlas_SetTexID(self: *FontAtlas, id: TextureID) void;
pub extern fn ImFontAtlas_GetGlyphRangesDefault(self: *FontAtlas) [*c]const Wchar;
pub extern fn ImFontAtlas_GetGlyphRangesGreek(self: *FontAtlas) [*c]const Wchar;
pub extern fn ImFontAtlas_GetGlyphRangesKorean(self: *FontAtlas) [*c]const Wchar;
pub extern fn ImFontAtlas_GetGlyphRangesJapanese(self: *FontAtlas) [*c]const Wchar;
pub extern fn ImFontAtlas_GetGlyphRangesChineseFull(self: *FontAtlas) [*c]const Wchar;
pub extern fn ImFontAtlas_GetGlyphRangesChineseSimplifiedCommon(self: *FontAtlas) [*c]const Wchar;
pub extern fn ImFontAtlas_GetGlyphRangesCyrillic(self: *FontAtlas) [*c]const Wchar;
pub extern fn ImFontAtlas_GetGlyphRangesThai(self: *FontAtlas) [*c]const Wchar;
pub extern fn ImFontAtlas_GetGlyphRangesVietnamese(self: *FontAtlas) [*c]const Wchar;
pub extern fn ImFontAtlas_AddCustomRectRegular(self: *FontAtlas, width: c_int, height: c_int) c_int;
pub extern fn ImFontAtlas_AddCustomRectFontGlyph(self: *FontAtlas, font: [*c]Font, id: Wchar, width: c_int, height: c_int, advance_x: f32, offset: Vec2) c_int;
pub extern fn ImFontAtlas_GetCustomRectByIndex(self: *FontAtlas, index: c_int) [*c]FontAtlasCustomRect;
pub extern fn ImFontAtlas_CalcCustomRectUV(self: *FontAtlas, rect: [*c]const FontAtlasCustomRect, out_uv_min: [*c]Vec2, out_uv_max: [*c]Vec2) void;
pub extern fn ImFontAtlas_GetMouseCursorTexData(self: *FontAtlas, cursor: MouseCursor, out_offset: [*c]Vec2, out_size: [*c]Vec2, out_uv_border: [2]Vec2, out_uv_fill: [2]Vec2) bool;
pub extern fn ImFont_FindGlyph(self: *Font, c: Wchar) [*c]const FontGlyph;
pub extern fn ImFont_FindGlyphNoFallback(self: *Font, c: Wchar) [*c]const FontGlyph;
pub extern fn ImFont_GetCharAdvance(self: *Font, c: Wchar) f32;
pub extern fn ImFont_IsLoaded(self: *Font) bool;
pub extern fn ImFont_GetDebugName(self: *Font) [*c]const u8;
pub extern fn ImFont_CalcTextSizeA(self: *Font, size: f32, max_width: f32, wrap_width: f32, text_begin: [*c]const u8) Vec2;
pub extern fn ImFont_CalcTextSizeAEx(self: *Font, size: f32, max_width: f32, wrap_width: f32, text_begin: [*c]const u8, text_end: [*c]const u8, remaining: [*c][*c]const u8) Vec2;
pub extern fn ImFont_CalcWordWrapPositionA(self: *Font, scale: f32, text: [*c]const u8, text_end: [*c]const u8, wrap_width: f32) [*c]const u8;
pub extern fn ImFont_RenderChar(self: *Font, draw_list: [*c]DrawList, size: f32, pos: Vec2, col: u32, c: Wchar) void;
pub extern fn ImFont_RenderText(self: *Font, draw_list: [*c]DrawList, size: f32, pos: Vec2, col: u32, clip_rect: Vec4, text_begin: [*c]const u8, text_end: [*c]const u8, wrap_width: f32, cpu_fine_clip: bool) void;
pub extern fn ImFont_BuildLookupTable(self: *Font) void;
pub extern fn ImFont_ClearOutputData(self: *Font) void;
pub extern fn ImFont_GrowIndex(self: *Font, new_size: c_int) void;
pub extern fn ImFont_AddGlyph(self: *Font, src_cfg: [*c]const FontConfig, c: Wchar, x0: f32, y0: f32, x1: f32, y1: f32, u0: f32, v0: f32, u1: f32, v1: f32, advance_x: f32) void;
pub extern fn ImFont_AddRemapChar(self: *Font, dst: Wchar, src: Wchar, overwrite_dst: bool) void;
pub extern fn ImFont_SetGlyphVisible(self: *Font, c: Wchar, visible: bool) void;
pub extern fn ImFont_IsGlyphRangeUnused(self: *Font, c_begin: c_uint, c_last: c_uint) bool;
pub extern fn ImGuiViewport_GetCenter(self: *Viewport) Vec2;
pub extern fn ImGuiViewport_GetWorkCenter(self: *Viewport) Vec2;
pub extern fn igPushButtonRepeat(repeat: bool) void;
pub extern fn igPopButtonRepeat() void;
pub extern fn igPushTabStop(tab_stop: bool) void;
pub extern fn igPopTabStop() void;
pub extern fn igGetContentRegionMax() Vec2;
pub extern fn igGetWindowContentRegionMin() Vec2;
pub extern fn igGetWindowContentRegionMax() Vec2;
pub extern fn igBeginChildFrame(id: u32, size: Vec2) bool;
pub extern fn igBeginChildFrameEx(id: u32, size: Vec2, window_flags: WindowFlags) bool;
pub extern fn igEndChildFrame() void;
pub extern fn igShowStackToolWindow(p_open: [*c]bool) void;
pub extern fn igComboObsolete(label: [*c]const u8, current_item: [*c]c_int, old_callback: *const fn (user_data: *anyopaque, idx: c_int, out_text: [*c][*c]const u8) bool, user_data: *anyopaque, items_count: c_int) bool;
pub extern fn igComboObsoleteEx(label: [*c]const u8, current_item: [*c]c_int, old_callback: *const fn (user_data: *anyopaque, idx: c_int, out_text: [*c][*c]const u8) bool, user_data: *anyopaque, items_count: c_int, popup_max_height_in_items: c_int) bool;
pub extern fn igListBoxObsolete(label: [*c]const u8, current_item: [*c]c_int, old_callback: *const fn (user_data: *anyopaque, idx: c_int, out_text: [*c][*c]const u8) bool, user_data: *anyopaque, items_count: c_int) bool;
pub extern fn igListBoxObsoleteEx(label: [*c]const u8, current_item: [*c]c_int, old_callback: *const fn (user_data: *anyopaque, idx: c_int, out_text: [*c][*c]const u8) bool, user_data: *anyopaque, items_count: c_int, height_in_items: c_int) bool;
pub extern fn igSetItemAllowOverlap() void;
pub extern fn igPushAllowKeyboardFocus(tab_stop: bool) void;
pub extern fn igPopAllowKeyboardFocus() void;

pub const CreateContext = igCreateContext;
pub const DestroyContext = igDestroyContext;
pub const GetCurrentContext = igGetCurrentContext;
pub const SetCurrentContext = igSetCurrentContext;
pub const GetIO = igGetIO;
pub const GetPlatformIO = igGetPlatformIO;
pub const GetStyle = igGetStyle;
pub const NewFrame = igNewFrame;
pub const EndFrame = igEndFrame;
pub const Render = igRender;
pub const GetDrawData = igGetDrawData;
pub const ShowDemoWindow = igShowDemoWindow;
pub const ShowMetricsWindow = igShowMetricsWindow;
pub const ShowDebugLogWindow = igShowDebugLogWindow;
pub const ShowIDStackToolWindow = igShowIDStackToolWindow;
pub const ShowIDStackToolWindowEx = igShowIDStackToolWindowEx;
pub const ShowAboutWindow = igShowAboutWindow;
pub const ShowStyleEditor = igShowStyleEditor;
pub const ShowStyleSelector = igShowStyleSelector;
pub const ShowFontSelector = igShowFontSelector;
pub const ShowUserGuide = igShowUserGuide;
pub const GetVersion = igGetVersion;
pub const StyleColorsDark = igStyleColorsDark;
pub const StyleColorsLight = igStyleColorsLight;
pub const StyleColorsClassic = igStyleColorsClassic;
pub const Begin = igBegin;
pub const End = igEnd;
pub const BeginChild = igBeginChild;
pub const BeginChildID = igBeginChildID;
pub const EndChild = igEndChild;
pub const IsWindowAppearing = igIsWindowAppearing;
pub const IsWindowCollapsed = igIsWindowCollapsed;
pub const IsWindowFocused = igIsWindowFocused;
pub const IsWindowHovered = igIsWindowHovered;
pub const GetWindowDrawList = igGetWindowDrawList;
pub const GetWindowDpiScale = igGetWindowDpiScale;
pub const GetWindowPos = igGetWindowPos;
pub const GetWindowSize = igGetWindowSize;
pub const GetWindowWidth = igGetWindowWidth;
pub const GetWindowHeight = igGetWindowHeight;
pub const GetWindowViewport = igGetWindowViewport;
pub const SetNextWindowPos = igSetNextWindowPos;
pub const SetNextWindowPosEx = igSetNextWindowPosEx;
pub const SetNextWindowSize = igSetNextWindowSize;
pub const SetNextWindowSizeConstraints = igSetNextWindowSizeConstraints;
pub const SetNextWindowContentSize = igSetNextWindowContentSize;
pub const SetNextWindowCollapsed = igSetNextWindowCollapsed;
pub const SetNextWindowFocus = igSetNextWindowFocus;
pub const SetNextWindowScroll = igSetNextWindowScroll;
pub const SetNextWindowBgAlpha = igSetNextWindowBgAlpha;
pub const SetNextWindowViewport = igSetNextWindowViewport;
pub const SetWindowPos = igSetWindowPos;
pub const SetWindowSize = igSetWindowSize;
pub const SetWindowCollapsed = igSetWindowCollapsed;
pub const SetWindowFocus = igSetWindowFocus;
pub const SetWindowFontScale = igSetWindowFontScale;
pub const SetWindowPosStr = igSetWindowPosStr;
pub const SetWindowSizeStr = igSetWindowSizeStr;
pub const SetWindowCollapsedStr = igSetWindowCollapsedStr;
pub const SetWindowFocusStr = igSetWindowFocusStr;
pub const GetScrollX = igGetScrollX;
pub const GetScrollY = igGetScrollY;
pub const SetScrollX = igSetScrollX;
pub const SetScrollY = igSetScrollY;
pub const GetScrollMaxX = igGetScrollMaxX;
pub const GetScrollMaxY = igGetScrollMaxY;
pub const SetScrollHereX = igSetScrollHereX;
pub const SetScrollHereY = igSetScrollHereY;
pub const SetScrollFromPosX = igSetScrollFromPosX;
pub const SetScrollFromPosY = igSetScrollFromPosY;
pub const PushFont = igPushFont;
pub const PopFont = igPopFont;
pub const PushStyleColor = igPushStyleColor;

pub const PopStyleColor = igPopStyleColor;
pub const PopStyleColorEx = igPopStyleColorEx;
pub const PushStyleVar = igPushStyleVar;

pub const PushStyleVarX = igPushStyleVarX;
pub const PushStyleVarY = igPushStyleVarY;
pub const PopStyleVar = igPopStyleVar;
pub const PopStyleVarEx = igPopStyleVarEx;
pub const PushItemFlag = igPushItemFlag;
pub const PopItemFlag = igPopItemFlag;
pub const PushItemWidth = igPushItemWidth;
pub const PopItemWidth = igPopItemWidth;
pub const SetNextItemWidth = igSetNextItemWidth;
pub const CalcItemWidth = igCalcItemWidth;
pub const PushTextWrapPos = igPushTextWrapPos;
pub const PopTextWrapPos = igPopTextWrapPos;
pub const GetFont = igGetFont;
pub const GetFontSize = igGetFontSize;
pub const GetFontTexUvWhitePixel = igGetFontTexUvWhitePixel;

pub const GetCursorScreenPos = igGetCursorScreenPos;
pub const SetCursorScreenPos = igSetCursorScreenPos;
pub const GetContentRegionAvail = igGetContentRegionAvail;
pub const GetCursorPos = igGetCursorPos;
pub const GetCursorPosX = igGetCursorPosX;
pub const GetCursorPosY = igGetCursorPosY;
pub const SetCursorPos = igSetCursorPos;
pub const SetCursorPosX = igSetCursorPosX;
pub const SetCursorPosY = igSetCursorPosY;
pub const GetCursorStartPos = igGetCursorStartPos;
pub const Separator = igSeparator;
pub const SameLine = igSameLine;
pub const SameLineEx = igSameLineEx;
pub const NewLine = igNewLine;
pub const Spacing = igSpacing;
pub const Dummy = igDummy;
pub const Indent = igIndent;
pub const IndentEx = igIndentEx;
pub const Unindent = igUnindent;
pub const UnindentEx = igUnindentEx;
pub const BeginGroup = igBeginGroup;
pub const EndGroup = igEndGroup;
pub const AlignTextToFramePadding = igAlignTextToFramePadding;
pub const GetTextLineHeight = igGetTextLineHeight;
pub const GetTextLineHeightWithSpacing = igGetTextLineHeightWithSpacing;
pub const GetFrameHeight = igGetFrameHeight;
pub const GetFrameHeightWithSpacing = igGetFrameHeightWithSpacing;
pub const PushID = igPushID;
pub const PushIDStr = igPushIDStr;
pub const PushIDPtr = igPushIDPtr;
pub const PushIDInt = igPushIDInt;
pub const PopID = igPopID;
pub const GetID = igGetID;
pub const GetIDStr = igGetIDStr;
pub const GetIDPtr = igGetIDPtr;
pub const GetIDInt = igGetIDInt;
pub const TextUnformatted = igTextUnformatted;
pub const TextUnformattedEx = igTextUnformattedEx;
pub const Text = igText;
// pub const TextV = igTextV;
pub const TextColored = igTextColored;
// pub const TextColoredV = igTextColoredV;
pub const TextDisabled = igTextDisabled;
// pub const TextDisabledV = igTextDisabledV;
pub const TextWrapped = igTextWrapped;
// pub const TextWrappedV = igTextWrappedV;
pub const LabelText = igLabelText;
// pub const LabelTextV = igLabelTextV;
pub const BulletText = igBulletText;
// pub const BulletTextV = igBulletTextV;
pub const SeparatorText = igSeparatorText;
pub const Button = igButton;
pub const ButtonEx = igButtonEx;
pub const SmallButton = igSmallButton;
pub const InvisibleButton = igInvisibleButton;
pub const ArrowButton = igArrowButton;
pub const Checkbox = igCheckbox;
pub const CheckboxFlagsIntPtr = igCheckboxFlagsIntPtr;
pub const CheckboxFlagsUintPtr = igCheckboxFlagsUintPtr;
pub const RadioButton = igRadioButton;
pub const RadioButtonIntPtr = igRadioButtonIntPtr;
pub const ProgressBar = igProgressBar;
pub const Bullet = igBullet;
pub const TextLink = igTextLink;
pub const TextLinkOpenURL = igTextLinkOpenURL;
pub const TextLinkOpenURLEx = igTextLinkOpenURLEx;
pub const Image = igImage;
pub const ImageEx = igImageEx;
pub const ImageButton = igImageButton;
pub const ImageButtonEx = igImageButtonEx;
pub const BeginCombo = igBeginCombo;
pub const EndCombo = igEndCombo;
pub const ComboChar = igComboChar;
pub const ComboCharEx = igComboCharEx;
pub const Combo = igCombo;
pub const ComboEx = igComboEx;
pub const ComboCallback = igComboCallback;
pub const ComboCallbackEx = igComboCallbackEx;
//

pub const DragFloat = igDragFloat;
pub const DragFloatEx = igDragFloatEx;
pub const DragFloat2 = igDragFloat2;
pub const DragFloat2Ex = igDragFloat2Ex;
pub const DragFloat3 = igDragFloat3;
pub const DragFloat3Ex = igDragFloat3Ex;
pub const DragFloat4 = igDragFloat4;
pub const DragFloat4Ex = igDragFloat4Ex;
pub const DragFloatRange2 = igDragFloatRange2;
pub const DragFloatRange2Ex = igDragFloatRange2Ex;
pub const DragInt = igDragInt;
pub const DragIntEx = igDragIntEx;
pub const DragInt2 = igDragInt2;
pub const DragInt2Ex = igDragInt2Ex;
pub const DragInt3 = igDragInt3;
pub const DragInt3Ex = igDragInt3Ex;
pub const DragInt4 = igDragInt4;
pub const DragInt4Ex = igDragInt4Ex;
pub const DragIntRange2 = igDragIntRange2;
pub const DragIntRange2Ex = igDragIntRange2Ex;
pub const DragScalar = igDragScalar;
pub const DragScalarEx = igDragScalarEx;
pub const DragScalarN = igDragScalarN;
pub const DragScalarNEx = igDragScalarNEx;
pub const SliderFloat = igSliderFloat;
pub const SliderFloatEx = igSliderFloatEx;
pub const SliderFloat2 = igSliderFloat2;
pub const SliderFloat2Ex = igSliderFloat2Ex;
pub const SliderFloat3 = igSliderFloat3;
pub const SliderFloat3Ex = igSliderFloat3Ex;
pub const SliderFloat4 = igSliderFloat4;
pub const SliderFloat4Ex = igSliderFloat4Ex;
pub const SliderAngle = igSliderAngle;
pub const SliderAngleEx = igSliderAngleEx;
pub const SliderInt = igSliderInt;
pub const SliderIntEx = igSliderIntEx;
pub const SliderInt2 = igSliderInt2;
pub const SliderInt2Ex = igSliderInt2Ex;
pub const SliderInt3 = igSliderInt3;
pub const SliderInt3Ex = igSliderInt3Ex;
pub const SliderInt4 = igSliderInt4;
pub const SliderInt4Ex = igSliderInt4Ex;
pub const SliderScalar = igSliderScalar;
pub const SliderScalarEx = igSliderScalarEx;
pub const SliderScalarN = igSliderScalarN;
pub const SliderScalarNEx = igSliderScalarNEx;
pub const VSliderFloat = igVSliderFloat;
pub const VSliderFloatEx = igVSliderFloatEx;
pub const VSliderInt = igVSliderInt;
pub const VSliderIntEx = igVSliderIntEx;
pub const VSliderScalar = igVSliderScalar;
pub const VSliderScalarEx = igVSliderScalarEx;
pub const InputText = igInputText;
pub const InputTextEx = igInputTextEx;
pub const InputTextMultiline = igInputTextMultiline;
pub const InputTextMultilineEx = igInputTextMultilineEx;
pub const InputTextWithHint = igInputTextWithHint;
pub const InputTextWithHintEx = igInputTextWithHintEx;
pub const InputFloat = igInputFloat;
pub const InputFloatEx = igInputFloatEx;

pub const InputInt = igInputInt;
pub const InputIntEx = igInputIntEx;

pub const InputDouble = igInputDouble;
pub const InputDoubleEx = igInputDoubleEx;
pub const InputScalar = igInputScalar;
pub const InputScalarEx = igInputScalarEx;
pub const InputScalarN = igInputScalarN;
pub const InputScalarNEx = igInputScalarNEx;

pub const ColorButton = igColorButton;
pub const ColorButtonEx = igColorButtonEx;
pub const SetColorEditOptions = igSetColorEditOptions;
pub const TreeNode = igTreeNode;
pub const TreeNodeStr = igTreeNodeStr;
pub const TreeNodePtr = igTreeNodePtr;
// pub const TreeNodeV = igTreeNodeV;
// pub const TreeNodeVPtr = igTreeNodeVPtr;
pub const TreeNodeEx = igTreeNodeEx;
pub const TreeNodeExStr = igTreeNodeExStr;
pub const TreeNodeExPtr = igTreeNodeExPtr;
// pub const TreeNodeExV = igTreeNodeExV;
// pub const TreeNodeExVPtr = igTreeNodeExVPtr;
pub const TreePush = igTreePush;
pub const TreePushPtr = igTreePushPtr;
pub const TreePop = igTreePop;
pub const GetTreeNodeToLabelSpacing = igGetTreeNodeToLabelSpacing;
pub const CollapsingHeader = igCollapsingHeader;
pub const CollapsingHeaderBoolPtr = igCollapsingHeaderBoolPtr;
pub const SetNextItemOpen = igSetNextItemOpen;
pub const SetNextItemStorageID = igSetNextItemStorageID;
pub const Selectable = igSelectable;
pub const SelectableEx = igSelectableEx;
pub const SelectableBoolPtr = igSelectableBoolPtr;
pub const SelectableBoolPtrEx = igSelectableBoolPtrEx;
pub const BeginMultiSelect = igBeginMultiSelect;
pub const BeginMultiSelectEx = igBeginMultiSelectEx;
pub const EndMultiSelect = igEndMultiSelect;
pub const SetNextItemSelectionUserData = igSetNextItemSelectionUserData;
pub const IsItemToggledSelection = igIsItemToggledSelection;
pub const BeginListBox = igBeginListBox;
pub const EndListBox = igEndListBox;
pub const ListBox = igListBox;
pub const ListBoxCallback = igListBoxCallback;
pub const ListBoxCallbackEx = igListBoxCallbackEx;
pub const PlotLines = igPlotLines;
pub const PlotLinesEx = igPlotLinesEx;
pub const PlotLinesCallback = igPlotLinesCallback;
pub const PlotLinesCallbackEx = igPlotLinesCallbackEx;
pub const PlotHistogram = igPlotHistogram;
pub const PlotHistogramEx = igPlotHistogramEx;
pub const PlotHistogramCallback = igPlotHistogramCallback;
pub const PlotHistogramCallbackEx = igPlotHistogramCallbackEx;
pub const BeginMenuBar = igBeginMenuBar;
pub const EndMenuBar = igEndMenuBar;
pub const BeginMainMenuBar = igBeginMainMenuBar;
pub const EndMainMenuBar = igEndMainMenuBar;
pub const BeginMenu = igBeginMenu;
pub const BeginMenuEx = igBeginMenuEx;
pub const EndMenu = igEndMenu;
pub const MenuItem = igMenuItem;
pub const MenuItemEx = igMenuItemEx;
pub const MenuItemBoolPtr = igMenuItemBoolPtr;
pub const BeginTooltip = igBeginTooltip;
pub const EndTooltip = igEndTooltip;
pub const SetTooltip = igSetTooltip;
// pub const SetTooltipV = igSetTooltipV;
pub const BeginItemTooltip = igBeginItemTooltip;
pub const SetItemTooltip = igSetItemTooltip;
// pub const SetItemTooltipV = igSetItemTooltipV;
pub const BeginPopup = igBeginPopup;
pub const BeginPopupModal = igBeginPopupModal;
pub const EndPopup = igEndPopup;
pub const OpenPopup = igOpenPopup;
pub const OpenPopupID = igOpenPopupID;
pub const OpenPopupOnItemClick = igOpenPopupOnItemClick;
pub const CloseCurrentPopup = igCloseCurrentPopup;
pub const BeginPopupContextItem = igBeginPopupContextItem;
pub const BeginPopupContextItemEx = igBeginPopupContextItemEx;
pub const BeginPopupContextWindow = igBeginPopupContextWindow;
pub const BeginPopupContextWindowEx = igBeginPopupContextWindowEx;
pub const BeginPopupContextVoid = igBeginPopupContextVoid;
pub const BeginPopupContextVoidEx = igBeginPopupContextVoidEx;
pub const IsPopupOpen = igIsPopupOpen;
pub const BeginTable = igBeginTable;
pub const BeginTableEx = igBeginTableEx;
pub const EndTable = igEndTable;
pub const TableNextRow = igTableNextRow;
pub const TableNextRowEx = igTableNextRowEx;
pub const TableNextColumn = igTableNextColumn;
pub const TableSetColumnIndex = igTableSetColumnIndex;
pub const TableSetupColumn = igTableSetupColumn;
pub const TableSetupColumnEx = igTableSetupColumnEx;
pub const TableSetupScrollFreeze = igTableSetupScrollFreeze;
pub const TableHeader = igTableHeader;
pub const TableHeadersRow = igTableHeadersRow;
pub const TableAngledHeadersRow = igTableAngledHeadersRow;
pub const TableGetSortSpecs = igTableGetSortSpecs;
pub const TableGetColumnCount = igTableGetColumnCount;
pub const TableGetColumnIndex = igTableGetColumnIndex;
pub const TableGetRowIndex = igTableGetRowIndex;
pub const TableGetColumnName = igTableGetColumnName;
pub const TableGetColumnFlags = igTableGetColumnFlags;
pub const TableSetColumnEnabled = igTableSetColumnEnabled;
pub const TableGetHoveredColumn = igTableGetHoveredColumn;
pub const TableSetBgColor = igTableSetBgColor;
pub const Columns = igColumns;
pub const ColumnsEx = igColumnsEx;
pub const NextColumn = igNextColumn;
pub const GetColumnIndex = igGetColumnIndex;
pub const GetColumnWidth = igGetColumnWidth;
pub const SetColumnWidth = igSetColumnWidth;
pub const GetColumnOffset = igGetColumnOffset;
pub const SetColumnOffset = igSetColumnOffset;
pub const GetColumnsCount = igGetColumnsCount;
pub const BeginTabBar = igBeginTabBar;
pub const EndTabBar = igEndTabBar;
pub const BeginTabItem = igBeginTabItem;
pub const EndTabItem = igEndTabItem;
pub const TabItemButton = igTabItemButton;
pub const SetTabItemClosed = igSetTabItemClosed;
pub const DockSpace = igDockSpace;
pub const DockSpaceEx = igDockSpaceEx;
pub const DockSpaceOverViewport = igDockSpaceOverViewport;
pub const DockSpaceOverViewportEx = igDockSpaceOverViewportEx;
pub const SetNextWindowDockID = igSetNextWindowDockID;
pub const SetNextWindowClass = igSetNextWindowClass;
pub const GetWindowDockID = igGetWindowDockID;
pub const IsWindowDocked = igIsWindowDocked;
pub const LogToTTY = igLogToTTY;
pub const LogToFile = igLogToFile;
pub const LogToClipboard = igLogToClipboard;
pub const LogFinish = igLogFinish;
pub const LogButtons = igLogButtons;
pub const LogText = igLogText;
// pub const LogTextV = igLogTextV;
pub const BeginDragDropSource = igBeginDragDropSource;
pub const SetDragDropPayload = igSetDragDropPayload;
pub const EndDragDropSource = igEndDragDropSource;
pub const BeginDragDropTarget = igBeginDragDropTarget;
pub const AcceptDragDropPayload = igAcceptDragDropPayload;
pub const EndDragDropTarget = igEndDragDropTarget;
pub const GetDragDropPayload = igGetDragDropPayload;
pub const BeginDisabled = igBeginDisabled;
pub const EndDisabled = igEndDisabled;
pub const PushClipRect = igPushClipRect;
pub const PopClipRect = igPopClipRect;
pub const SetItemDefaultFocus = igSetItemDefaultFocus;
pub const SetKeyboardFocusHere = igSetKeyboardFocusHere;
pub const SetKeyboardFocusHereEx = igSetKeyboardFocusHereEx;
pub const SetNavCursorVisible = igSetNavCursorVisible;
pub const SetNextItemAllowOverlap = igSetNextItemAllowOverlap;
pub const IsItemHovered = igIsItemHovered;
pub const IsItemActive = igIsItemActive;
pub const IsItemFocused = igIsItemFocused;
pub const IsItemClicked = igIsItemClicked;
pub const IsItemClickedEx = igIsItemClickedEx;
pub const IsItemVisible = igIsItemVisible;
pub const IsItemEdited = igIsItemEdited;
pub const IsItemActivated = igIsItemActivated;
pub const IsItemDeactivated = igIsItemDeactivated;
pub const IsItemDeactivatedAfterEdit = igIsItemDeactivatedAfterEdit;
pub const IsItemToggledOpen = igIsItemToggledOpen;
pub const IsAnyItemHovered = igIsAnyItemHovered;
pub const IsAnyItemActive = igIsAnyItemActive;
pub const IsAnyItemFocused = igIsAnyItemFocused;
pub const GetItemID = igGetItemID;
pub const GetItemRectMin = igGetItemRectMin;
pub const GetItemRectMax = igGetItemRectMax;
pub const GetItemRectSize = igGetItemRectSize;
pub const GetMainViewport = igGetMainViewport;
pub const GetBackgroundDrawList = igGetBackgroundDrawList;
pub const GetBackgroundDrawListEx = igGetBackgroundDrawListEx;
pub const GetForegroundDrawList = igGetForegroundDrawList;
pub const GetForegroundDrawListEx = igGetForegroundDrawListEx;
pub const IsRectVisibleBySize = igIsRectVisibleBySize;
pub const IsRectVisible = igIsRectVisible;
pub const GetTime = igGetTime;
pub const GetFrameCount = igGetFrameCount;
pub const GetDrawListSharedData = igGetDrawListSharedData;
pub const GetStyleColorName = igGetStyleColorName;
pub const SetStateStorage = igSetStateStorage;
pub const GetStateStorage = igGetStateStorage;
pub const CalcTextSize = igCalcTextSize;
pub const CalcTextSizeEx = igCalcTextSizeEx;

pub const ColorConvertRGBtoHSV = igColorConvertRGBtoHSV;
pub const ColorConvertHSVtoRGB = igColorConvertHSVtoRGB;
pub const IsKeyDown = igIsKeyDown;
pub const IsKeyPressed = igIsKeyPressed;
pub const IsKeyPressedEx = igIsKeyPressedEx;
pub const IsKeyReleased = igIsKeyReleased;
pub const IsKeyChordPressed = igIsKeyChordPressed;
pub const GetKeyPressedAmount = igGetKeyPressedAmount;
pub const GetKeyName = igGetKeyName;
pub const SetNextFrameWantCaptureKeyboard = igSetNextFrameWantCaptureKeyboard;
pub const Shortcut = igShortcut;
pub const SetNextItemShortcut = igSetNextItemShortcut;
pub const SetItemKeyOwner = igSetItemKeyOwner;
pub const IsMouseDown = igIsMouseDown;
pub const IsMouseClicked = igIsMouseClicked;
pub const IsMouseClickedEx = igIsMouseClickedEx;
pub const IsMouseReleased = igIsMouseReleased;
pub const IsMouseDoubleClicked = igIsMouseDoubleClicked;
pub const GetMouseClickedCount = igGetMouseClickedCount;
pub const IsMouseHoveringRect = igIsMouseHoveringRect;
pub const IsMouseHoveringRectEx = igIsMouseHoveringRectEx;
pub const IsMousePosValid = igIsMousePosValid;
pub const IsAnyMouseDown = igIsAnyMouseDown;
pub const GetMousePos = igGetMousePos;
pub const GetMousePosOnOpeningCurrentPopup = igGetMousePosOnOpeningCurrentPopup;
pub const IsMouseDragging = igIsMouseDragging;
pub const GetMouseDragDelta = igGetMouseDragDelta;
pub const ResetMouseDragDelta = igResetMouseDragDelta;
pub const ResetMouseDragDeltaEx = igResetMouseDragDeltaEx;
pub const GetMouseCursor = igGetMouseCursor;
pub const SetMouseCursor = igSetMouseCursor;
pub const SetNextFrameWantCaptureMouse = igSetNextFrameWantCaptureMouse;
pub const GetClipboardText = igGetClipboardText;
pub const SetClipboardText = igSetClipboardText;
pub const LoadIniSettingsFromDisk = igLoadIniSettingsFromDisk;
pub const LoadIniSettingsFromMemory = igLoadIniSettingsFromMemory;
pub const SaveIniSettingsToDisk = igSaveIniSettingsToDisk;
pub const SaveIniSettingsToMemory = igSaveIniSettingsToMemory;
pub const DebugTextEncoding = igDebugTextEncoding;
pub const DebugFlashStyleColor = igDebugFlashStyleColor;
pub const DebugStartItemPicker = igDebugStartItemPicker;
pub const DebugCheckVersionAndDataLayout = igDebugCheckVersionAndDataLayout;
pub const DebugLog = igDebugLog;
// pub const DebugLogV = igDebugLogV;
pub const SetAllocatorFunctions = igSetAllocatorFunctions;
pub const GetAllocatorFunctions = igGetAllocatorFunctions;
pub const MemAlloc = igMemAlloc;
pub const MemFree = igMemFree;
pub const UpdatePlatformWindows = igUpdatePlatformWindows;
pub const RenderPlatformWindowsDefault = igRenderPlatformWindowsDefault;
pub const RenderPlatformWindowsDefaultEx = igRenderPlatformWindowsDefaultEx;
pub const DestroyPlatformWindows = igDestroyPlatformWindows;
pub const FindViewportByID = igFindViewportByID;
pub const FindViewportByPlatformHandle = igFindViewportByPlatformHandle;
pub const PushButtonRepeat = igPushButtonRepeat;
pub const PopButtonRepeat = igPopButtonRepeat;
pub const PushTabStop = igPushTabStop;
pub const PopTabStop = igPopTabStop;
pub const GetContentRegionMax = igGetContentRegionMax;
pub const GetWindowContentRegionMin = igGetWindowContentRegionMin;
pub const GetWindowContentRegionMax = igGetWindowContentRegionMax;
pub const BeginChildFrame = igBeginChildFrame;
pub const BeginChildFrameEx = igBeginChildFrameEx;
pub const EndChildFrame = igEndChildFrame;
pub const ShowStackToolWindow = igShowStackToolWindow;
pub const ComboObsolete = igComboObsolete;
pub const ComboObsoleteEx = igComboObsoleteEx;
pub const ListBoxObsolete = igListBoxObsolete;
pub const ListBoxObsoleteEx = igListBoxObsoleteEx;
pub const SetItemAllowOverlap = igSetItemAllowOverlap;
pub const PushAllowKeyboardFocus = igPushAllowKeyboardFocus;
pub const PopAllowKeyboardFocus = igPopAllowKeyboardFocus;
