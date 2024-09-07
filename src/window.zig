const c = @import("c.zig");
const gl = @import("gl");
const cfg = @import("config.zig");

pub const Handle = *c.struct_SDL_Window;
pub var handle: Handle = undefined;

var gl_procs: gl.ProcTable = undefined;

pub const Key = enum(u32) {
    unknown = c.SDLK_UNKNOWN,
    enter = c.SDLK_RETURN,
    esc = c.SDLK_ESCAPE,
    backspace = c.SDLK_BACKSPACE,
    tab = c.SDLK_TAB,
    space = c.SDLK_SPACE,
    exclaim = c.SDLK_EXCLAIM,
    quote = c.SDLK_DBLAPOSTROPHE,
    hash = c.SDLK_HASH,
    dollar = c.SDLK_DOLLAR,
    percent = c.SDLK_PERCENT,
    ampersand = c.SDLK_AMPERSAND,
    apostrophe = c.SDLK_APOSTROPHE,
    leftparen = c.SDLK_LEFTPAREN,
    rightparen = c.SDLK_RIGHTPAREN,
    asterisk = c.SDLK_ASTERISK,
    plus = c.SDLK_PLUS,
    comma = c.SDLK_COMMA,
    minus = c.SDLK_MINUS,
    period = c.SDLK_PERIOD,
    slash = c.SDLK_SLASH,
    @"0" = c.SDLK_0,
    @"1" = c.SDLK_1,
    @"2" = c.SDLK_2,
    @"3" = c.SDLK_3,
    @"4" = c.SDLK_4,
    @"5" = c.SDLK_5,
    @"6" = c.SDLK_6,
    @"7" = c.SDLK_7,
    @"8" = c.SDLK_8,
    @"9" = c.SDLK_9,
    colon = c.SDLK_COLON,
    semicolon = c.SDLK_SEMICOLON,
    less = c.SDLK_LESS,
    equals = c.SDLK_EQUALS,
    greater = c.SDLK_GREATER,
    question = c.SDLK_QUESTION,
    at = c.SDLK_AT,
    left_bracket = c.SDLK_LEFTBRACKET,
    backslash = c.SDLK_BACKSLASH,
    right_bracket = c.SDLK_RIGHTBRACKET,
    caret = c.SDLK_CARET,
    underscore = c.SDLK_UNDERSCORE,
    tick = c.SDLK_GRAVE,
    a = c.SDLK_A,
    b = c.SDLK_B,
    c = c.SDLK_C,
    d = c.SDLK_D,
    e = c.SDLK_E,
    f = c.SDLK_F,
    g = c.SDLK_G,
    h = c.SDLK_H,
    i = c.SDLK_I,
    j = c.SDLK_J,
    k = c.SDLK_K,
    l = c.SDLK_L,
    m = c.SDLK_M,
    n = c.SDLK_N,
    o = c.SDLK_O,
    p = c.SDLK_P,
    q = c.SDLK_Q,
    r = c.SDLK_R,
    s = c.SDLK_S,
    t = c.SDLK_T,
    u = c.SDLK_U,
    v = c.SDLK_V,
    w = c.SDLK_W,
    x = c.SDLK_X,
    y = c.SDLK_Y,
    z = c.SDLK_Z,
    leftbrace = c.SDLK_LEFTBRACE,
    pipe = c.SDLK_PIPE,
    rightbrace = c.SDLK_RIGHTBRACE,
    tilde = c.SDLK_TILDE,
    delete = c.SDLK_DELETE,
    plusminus = c.SDLK_PLUSMINUS,
    capslock = c.SDLK_CAPSLOCK,
    f1 = c.SDLK_F1,
    f2 = c.SDLK_F2,
    f3 = c.SDLK_F3,
    f4 = c.SDLK_F4,
    f5 = c.SDLK_F5,
    f6 = c.SDLK_F6,
    f7 = c.SDLK_F7,
    f8 = c.SDLK_F8,
    f9 = c.SDLK_F9,
    f10 = c.SDLK_F10,
    f11 = c.SDLK_F11,
    f12 = c.SDLK_F12,
    print_screen = c.SDLK_PRINTSCREEN,
    scroll_lock = c.SDLK_SCROLLLOCK,
    pause = c.SDLK_PAUSE,
    insert = c.SDLK_INSERT,
    home = c.SDLK_HOME,
    page_up = c.SDLK_PAGEUP,
    end = c.SDLK_END,
    page_down = c.SDLK_PAGEDOWN,
    right = c.SDLK_RIGHT,
    left = c.SDLK_LEFT,
    down = c.SDLK_DOWN,
    up = c.SDLK_UP,
    num_lock_clear = c.SDLK_NUMLOCKCLEAR,
    keypad_divide = c.SDLK_KP_DIVIDE,
    keypad_multiply = c.SDLK_KP_MULTIPLY,
    keypad_minus = c.SDLK_KP_MINUS,
    keypad_plus = c.SDLK_KP_PLUS,
    keypad_enter = c.SDLK_KP_ENTER,
    keypad_1 = c.SDLK_KP_1,
    keypad_2 = c.SDLK_KP_2,
    keypad_3 = c.SDLK_KP_3,
    keypad_4 = c.SDLK_KP_4,
    keypad_5 = c.SDLK_KP_5,
    keypad_6 = c.SDLK_KP_6,
    keypad_7 = c.SDLK_KP_7,
    keypad_8 = c.SDLK_KP_8,
    keypad_9 = c.SDLK_KP_9,
    keypad_0 = c.SDLK_KP_0,
    keypad_period = c.SDLK_KP_PERIOD,
    _
};

pub const Mods = enum(u32) { ctrl, alt, shift };

pub const Action = enum(u8) { keyup, keydown, hold };

/// Sets gl variables and creates a glfw window.
/// Returns the glfw window object.
/// NOTE: Caller responsible for calling shutdownWindow() to
/// deinit the window module.
pub fn init() !void {
    if (!c.SDL_Init(c.SDL_INIT_VIDEO)) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }

    handle = c.SDL_CreateWindow("My Game Window", 640, 480, c.SDL_WINDOW_RESIZABLE) orelse {
        c.SDL_Log("Unable to create window: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
}

pub fn destroy() void {
    c.SDL_DestroyWindow(handle);
    c.SDL_Quit();
}

pub fn swapBuffers() void {
    if (!c.SDL_GL_SwapWindow(handle)) {
        c.SDL_Log("Unable to swap buffers: %s", c.SDL_GetError());
    }

}
