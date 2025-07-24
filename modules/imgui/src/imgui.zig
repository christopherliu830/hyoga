pub const ID = u64;

pub const Vec2 = extern struct { x: f32, y: f32 };

pub fn Vector(T: type) type {
    return extern struct {
        size: c_int,
        capacity: c_int,
        data: [*]T,
    };
}

pub const Context = opaque {};

pub const Font = opaque {};

pub const FontAtlas = opaque {};

pub const KeyChord = packed struct(c_int) {
    mods: u8 = 0,
    key: Key,

    pub const Key = enum(u26) {
        Tab,
        LeftArrow,
        RightArrow,
        UpArrow,
        DownArrow,
        PageUp,
        PageDown,
        Home,
        End,
        Insert,
        Delete,
        Backspace,
        Space,
        Enter,
        Escape,
        LeftCtrl,
        LeftShift,
        LeftAlt,
        LeftSuper, // Also see ImGuiMod_Ctrl, ImGuiMod_Shift, ImGuiMod_Alt, ImGuiMod_Super below!
        RightCtrl,
        RightShift,
        RightAlt,
        RightSuper,
        Menu,
        @"0",
        @"1",
        @"2",
        @"3",
        @"4",
        @"5",
        @"6",
        @"7",
        @"8",
        @"9",
        A,
        B,
        C,
        D,
        E,
        F,
        G,
        H,
        I,
        J,
        K,
        L,
        M,
        N,
        O,
        P,
        Q,
        R,
        S,
        T,
        U,
        V,
        W,
        X,
        Y,
        Z,
        F1,
        F2,
        F3,
        F4,
        F5,
        F6,
        F7,
        F8,
        F9,
        F10,
        F11,
        F12,
        F13,
        F14,
        F15,
        F16,
        F17,
        F18,
        F19,
        F20,
        F21,
        F22,
        F23,
        F24,
        Apostrophe, // '
        Comma, // ,
        Minus, // -
        Period, // .
        Slash, // /
        Semicolon, // ;
        Equal, // =
        LeftBracket, // [
        Backslash, // \ (this text inhibit multiline comment caused by backslash)
        RightBracket, // ]
        GraveAccent, // `
        CapsLock,
        ScrollLock,
        NumLock,
        PrintScreen,
        Pause,
        Keypad0,
        Keypad1,
        Keypad2,
        Keypad3,
        Keypad4,
        Keypad5,
        Keypad6,
        Keypad7,
        Keypad8,
        Keypad9,
        KeypadDecimal,
        KeypadDivide,
        KeypadMultiply,
        KeypadSubtract,
        KeypadAdd,
        KeypadEnter,
        KeypadEqual,
        AppBack, // Available on some keyboard/mouses. Often referred as "Browser Back"
        AppForward,
        Oem102, // Non-US backslash.

        // Gamepad
        // (analog values are 0.0f to 1.0f)
        // (download controller mapping PNG/PSD at http://dearimgui.com/controls_sheets)
        //                              // XBOX        | SWITCH  | PLAYSTA. | -> ACTION
        GamepadStart, // Menu        | +       | Options  |
        GamepadBack, // View        | -       | Share    |
        GamepadFaceLeft, // X           | Y       | Square   | Tap: Toggle Menu. Hold: Windowing mode (Focus/Move/Resize windows)
        GamepadFaceRight, // B           | A       | Circle   | Cancel / Close / Exit
        GamepadFaceUp, // Y           | X       | Triangle | Text Input / On-screen Keyboard
        GamepadFaceDown, // A           | B       | Cross    | Activate / Open / Toggle / Tweak
        GamepadDpadLeft, // D-pad Left  | "       | "        | Move / Tweak / Resize Window (in Windowing mode)
        GamepadDpadRight, // D-pad Right | "       | "        | Move / Tweak / Resize Window (in Windowing mode)
        GamepadDpadUp, // D-pad Up    | "       | "        | Move / Tweak / Resize Window (in Windowing mode)
        GamepadDpadDown, // D-pad Down  | "       | "        | Move / Tweak / Resize Window (in Windowing mode)
        GamepadL1, // L Bumper    | L       | L1       | Tweak Slower / Focus Previous (in Windowing mode)
        GamepadR1, // R Bumper    | R       | R1       | Tweak Faster / Focus Next (in Windowing mode)
        GamepadL2, // L Trigger   | ZL      | L2       | [Analog]
        GamepadR2, // R Trigger   | ZR      | R2       | [Analog]
        GamepadL3, // L Stick     | L3      | L3       |
        GamepadR3, // R Stick     | R3      | R3       |
        GamepadLStickLeft, //             |         |          | [Analog] Move Window (in Windowing mode)
        GamepadLStickRight, //             |         |          | [Analog] Move Window (in Windowing mode)
        GamepadLStickUp, //             |         |          | [Analog] Move Window (in Windowing mode)
        GamepadLStickDown, //             |         |          | [Analog] Move Window (in Windowing mode)
        GamepadRStickLeft, //             |         |          | [Analog]
        GamepadRStickRight, //             |         |          | [Analog]
        GamepadRStickUp, //             |         |          | [Analog]
        GamepadRStickDown, //             |         |          | [Analog]

        // Aliases: Mouse Buttons (auto-submitted from AddMouseButtonEvent() calls)
        // - This is mirroring the data also written to io.MouseDown[], io.MouseWheel, in a format allowing them to be accessed via standard key API.
        MouseLeft,
        MouseRight,
        MouseMiddle,
        MouseX1,
        MouseX2,
        MouseWheelX,
        MouseWheelY,

        ReservedForModCtrl,
        ReservedForModShift,
        ReservedForModAlt,
        ReservedForModSuper,

        NamedKey_END,

        ImGuiMod_Ctrl = 1 << 12, // Ctrl (non-macOS), Cmd (macOS)
        ImGuiMod_Shift = 1 << 13, // Shift
        ImGuiMod_Alt = 1 << 14, // Option/Menu
        ImGuiMod_Super = 1 << 15, // Windows/Super (non-macOS), Ctrl (macOS)
        ImGuiMod_Mask_ = 0xF000, // 4-bits

        pub const named_key_count: comptime_int = @This().NamedKey_END - @This().Tab;
    };
};

pub const IO = extern struct {
    config_flags: ConfigFlags,
    backend_flags: BackendFlags,
    display_size: Vec2,
    display_framebuffer_scale: Vec2,
    delta_time: f32,
    ini_saving_rage: f32,
    ini_filename: [*:0]const u8,
    log_filename: [*:0]const u8,
    user_data: ?*anyopaque,

    fonts: *FontAtlas,
    font_default: *Font,
    font_allow_user_scaling: bool,

    config_nav_swap_gamepad_buttons: bool,
    config_nav_move_set_mouse_pos: bool,
    config_nav_capture_keyboard: bool,
    config_nav_escape_clear_focus_item: bool,
    config_nav_cursor_visible_auto: bool,
    config_nav_cursor_visible_always: bool,

    config_docking_no_split: bool,
    config_docking_with_shift: bool,
    config_docking_always_tab_bar: bool,
    config_docking_transparent_payload: bool,

    config_viewports_no_auto_merge: bool,
    config_viewports_no_task_bar_icon: bool,
    config_viewports_no_decoration: bool,
    config_viewports_no_default_parent: bool,

    config_dpi_scale_fonts: bool,
    config_dpi_scale_viewports: bool,

    mouse_draw_cursor: bool,
    config_mac_osx_behaviors: bool,
    config_input_trickle_event_queue: bool,
    config_input_text_cursor_blink: bool,
    config_input_text_enter_keep_active: bool,
    config_drag_click_to_input_text: bool,
    config_windows_resize_from_edges: bool,
    config_windows_move_from_title_bar_only: bool,
    config_windows_copy_contents_with_ctrl_c: bool,
    config_scrollbar_scroll_by_page: bool,
    config_memory_compact_timer: f32,

    mouse_double_click_time: f32,
    mouse_double_click_max_dist: f32,
    mouse_drag_threshold: f32,
    key_repeat_delay: f32,
    key_repeat_rate: f32,

    config_error_recovery: bool,
    config_error_recovery_enable_assert: bool,
    config_error_recovery_enable_debug_log: bool,
    config_error_recovery_enable_tooltip: bool,

    config_debug_is_debugger_present: bool,

    config_debug_highlight_id_conflicts: bool,
    config_debug_highlight_id_conflicts_show_item_picker: bool,

    config_debug_begin_return_value_once: bool,
    config_debug_begin_return_value_loop: bool,

    config_debug_ignore_focus_loss: bool,
    config_debug_ini_settings: bool,

    backend_platform_name: ?[*:0]const u8,
    backend_renderer_name: ?[*:0]const u8,
    backend_platform_user_data: ?*anyopaque,
    backend_renderer_user_data: ?*anyopaque,
    backend_language_user_data: ?*anyopaque,

    want_capture_mouse: bool,
    want_capture_keyboard: bool,
    want_text_input: bool,
    want_set_mouse_pos: bool,
    want_save_ini_settings: bool,
    nav_active: bool,
    nav_visible: bool,
    framerate: f32,
    metrics_render_vertices: bool,
    metrics_render_indices: bool,
    metrics_render_windows: bool,
    metrics_active_windows: bool,
    mouse_delta: Vec2,

    ctx: *Context,

    mouse_pos: Vec2,
    mouse_down: [5]bool,
    mouse_wheel: f32,
    mouse_wheel_h: f32,
    mouse_source: MouseSource,
    mouse_hovered_viewport: ID,
    key_ctrl: bool,
    key_shift: bool,
    key_alt: bool,
    key_super: bool,

    key_mods: KeyChord,
    key_data: [KeyChord.Key.named_key_count]KeyData,
    want_capture_mouse_unless_popup_close: bool,
    mouse_pos_prev: Vec2,
    mouse_clicked_pos: [5]Vec2,
    mouse_clicked_time: [5]Vec2,
    mouse_clicked: [5]bool,
    mouse_double_clicked: [5]bool,
    mouse_clicked_count: [5]u16,
    mouse_clicked_last_count: [5]u16,
    mouse_released: [5]bool,
    mouse_released_time: [5]f64,
    mouse_down_owned: [5]bool,
    mouse_down_owned_unless_popup_close: [5]bool,
    mouse_wheel_request_axis_swap: bool,
    mouse_ctrl_left_as_right_click: bool,
    mouse_down_duration: [5]f32,
    mouse_down_duration_prev: [5]f32,
    mouse_drag_max_distance_abs: [5]Vec2,
    mouse_drag_max_distance_sqr: [5]Vec2,
    pen_pressure: f32,
    app_focus_lost: bool,
    app_accepting_events: bool,
    input_queue_surrogate: u16,
    input_queue_characters: Vector(u16),

    pub const ConfigFlags = packed struct(c_int) {
        pub const none: ConfigFlags = .{};

        nav_enable_keyboard: bool = false,
        nav_enable_gamepad: bool = false,
        obsolete_nav_enable_set_mouse_pos: bool = false,
        obsolete_nav_no_capture_keyboard: bool = false,
        no_mouse: bool = false,
        no_mouse_cursor_change: bool = false,
        no_keyboard: bool = false,

        docking_enable: bool = false,

        _padding_0: u2 = 0,

        viewports_enable: bool = false,

        _padding_1: u9 = 0,

        is_srgb: bool = false,
        is_touch_screen: bool = false,

        _padding_2: u12 = 0,
    };

    pub const BackendFlags = packed struct(c_int) {
        has_gamepad: bool = false,
        has_mouse_cursors: bool = false,
        has_set_mouse_pos: bool = false,
        renderer_has_vtx_offset: bool = false,
        renderer_has_textures: bool = false,

        _padding: u3 = 0,

        platform_has_viewports: bool = false,
        has_mouse_hovered_viewport: bool = false,
        renderer_has_viewports: bool = false,
    };

    pub const KeyData = extern struct {
        down: bool,
        down_duration: f32,
        down_duration_prev: f32,
        analog_value: f32,
    };

    pub const MouseSource = enum(c_int) {
        mouse,
        touch_screen,
        pen,
    };
};

extern fn igGetIO() *IO;
pub const getIO = igGetIO;

extern fn igCreateContext(shared_font_atlas: ?*FontAtlas) *Context;
pub const createContext = igCreateContext;
