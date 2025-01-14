const Window = @import("video.zig").Window;
const Keycode = @import("keycode.zig").Keycode;
const Keymod = @import("keycode.zig").Keymod;
const Scancode = @import("scancode.zig").Scancode;
const PropertiesID = @import("properties.zig").PropertiesID;
pub const Rect = @import("rect.zig").Rect;

pub const ID = u32;
//pub extern fn SDL_HasKeyboard() bool;
pub extern fn SDL_HasKeyboard() bool;
pub const hasKeyboard = SDL_HasKeyboard;
//pub extern fn SDL_GetKeyboards(count: [*c]c_int) [*c]SDL_ID;
pub extern fn SDL_GetKeyboards(count: [*c]c_int) [*c]ID;
pub const getKeyboards = SDL_GetKeyboards;
//pub extern fn SDL_GetKeyboardNameForID(instance_id: SDL_ID) [*c]const u8;
pub extern fn SDL_GetKeyboardNameForID(instance_id: ID) [*c]const u8;
pub const getKeyboardNameForID = SDL_GetKeyboardNameForID;
//pub extern fn SDL_GetKeyboardFocus() ?*SDL_Window;
pub extern fn SDL_GetKeyboardFocus() ?*Window;
pub const getKeyboardFocus = SDL_GetKeyboardFocus;
//pub extern fn SDL_GetKeyboardState(numkeys: [*c]c_int) [*c]const bool;
pub extern fn SDL_GetKeyboardState(numkeys: [*c]c_int) [*c]const bool;
pub const getKeyboardState = SDL_GetKeyboardState;
//pub extern fn SDL_ResetKeyboard() void;
pub extern fn SDL_ResetKeyboard() void;
pub const resetKeyboard = SDL_ResetKeyboard;
//pub extern fn SDL_GetModState() SDL_Keymod;
pub extern fn SDL_GetModState() Keymod;
pub const getModState = SDL_GetModState;
//pub extern fn SDL_SetModState(modstate: SDL_Keymod) void;
pub extern fn SDL_SetModState(modstate: Keymod) void;
pub const setModState = SDL_SetModState;
//pub extern fn SDL_GetKeyFromScancode(scancode: SDL_Scancode, modstate: SDL_Keymod, key_event: bool) SDL_Keycode;
pub extern fn SDL_GetKeyFromScancode(scancode: Scancode, modstate: Keymod, key_event: bool) Keycode;
pub const getKeyFromScancode = SDL_GetKeyFromScancode;
//pub extern fn SDL_GetScancodeFromKey(key: SDL_Keycode, modstate: [*c]SDL_Keymod) SDL_Scancode;
pub extern fn SDL_GetScancodeFromKey(key: Keycode, modstate: [*c]Keymod) Scancode;
pub const getScancodeFromKey = SDL_GetScancodeFromKey;
//pub extern fn SDL_SetScancodeName(scancode: SDL_Scancode, name: [*c]const u8) bool;
pub extern fn SDL_SetScancodeName(scancode: Scancode, name: [*c]const u8) bool;
pub const setScancodeName = SDL_SetScancodeName;
//pub extern fn SDL_GetScancodeName(scancode: SDL_Scancode) [*c]const u8;
pub extern fn SDL_GetScancodeName(scancode: Scancode) [*c]const u8;
pub const getScancodeName = SDL_GetScancodeName;
//pub extern fn SDL_GetScancodeFromName(name: [*c]const u8) SDL_Scancode;
pub extern fn SDL_GetScancodeFromName(name: [*c]const u8) Scancode;
pub const getScancodeFromName = SDL_GetScancodeFromName;
//pub extern fn SDL_GetKeyName(key: SDL_Keycode) [*c]const u8;
pub extern fn SDL_GetKeyName(key: Keycode) [*c]const u8;
pub const getKeyName = SDL_GetKeyName;
//pub extern fn SDL_GetKeyFromName(name: [*c]const u8) SDL_Keycode;
pub extern fn SDL_GetKeyFromName(name: [*c]const u8) Keycode;
pub const getKeyFromName = SDL_GetKeyFromName;
//pub extern fn SDL_StartTextInput(window: ?*SDL_Window) bool;
pub extern fn SDL_StartTextInput(window: ?*Window) bool;
pub const startTextInput = SDL_StartTextInput;
//pub const SDL_TEXTINPUT_TYPE_TEXT: c_int = 0;
//pub const SDL_TEXTINPUT_TYPE_TEXT_NAME: c_int = 1;
//pub const SDL_TEXTINPUT_TYPE_TEXT_EMAIL: c_int = 2;
//pub const SDL_TEXTINPUT_TYPE_TEXT_USERNAME: c_int = 3;
//pub const SDL_TEXTINPUT_TYPE_TEXT_PASSWORD_HIDDEN: c_int = 4;
//pub const SDL_TEXTINPUT_TYPE_TEXT_PASSWORD_VISIBLE: c_int = 5;
//pub const SDL_TEXTINPUT_TYPE_NUMBER: c_int = 6;
//pub const SDL_TEXTINPUT_TYPE_NUMBER_PASSWORD_HIDDEN: c_int = 7;
//pub const SDL_TEXTINPUT_TYPE_NUMBER_PASSWORD_VISIBLE: c_int = 8;
//pub const enum_SDL_TextInputType = c_uint;
pub const TextInputType = enum(c_uint) {
    text,
    text_name,
    text_email,
    text_username,
    text_password_hidden,
    text_password_visible,
    number,
    number_password_hidden,
    number_password_visible,
};

//pub const SDL_TextInputType = enum_SDL_TextInputType;
//pub const SDL_CAPITALIZE_NONE: c_int = 0;
//pub const SDL_CAPITALIZE_SENTENCES: c_int = 1;
//pub const SDL_CAPITALIZE_WORDS: c_int = 2;
//pub const SDL_CAPITALIZE_LETTERS: c_int = 3;
//pub const enum_SDL_Capitalization = c_uint;
pub const Capitalization = enum(c_uint) {
    none,
    sentences,
    words,
    letters,
};

//pub const SDL_Capitalization = enum_SDL_Capitalization;
//pub extern fn SDL_StartTextInputWithProperties(window: ?*SDL_Window, props: SDL_PropertiesID) bool;
pub extern fn SDL_StartTextInputWithProperties(window: ?*Window, props: PropertiesID) bool;
pub const startTextInputWithProperties = SDL_StartTextInputWithProperties;
//pub extern fn SDL_TextInputActive(window: ?*SDL_Window) bool;
pub extern fn SDL_TextInputActive(window: ?*Window) bool;
pub const textInputActive = SDL_TextInputActive;
//pub extern fn SDL_StopTextInput(window: ?*SDL_Window) bool;
pub extern fn SDL_StopTextInput(window: ?*Window) bool;
pub const stopTextInput = SDL_StopTextInput;
//pub extern fn SDL_ClearComposition(window: ?*SDL_Window) bool;
pub extern fn SDL_ClearComposition(window: ?*Window) bool;
pub const clearComposition = SDL_ClearComposition;
//pub extern fn SDL_SetTextInputArea(window: ?*SDL_Window, rect: [*c]const SDL_Rect, cursor: c_int) bool;
pub extern fn SDL_SetTextInputArea(window: ?*Window, rect: [*c]const Rect, cursor: c_int) bool;
pub const setTextInputArea = SDL_SetTextInputArea;
//pub extern fn SDL_GetTextInputArea(window: ?*SDL_Window, rect: [*c]SDL_Rect, cursor: [*c]c_int) bool;
pub extern fn SDL_GetTextInputArea(window: ?*Window, rect: [*c]Rect, cursor: [*c]c_int) bool;
pub const getTextInputArea = SDL_GetTextInputArea;
//pub extern fn SDL_HasScreenKeyboardSupport() bool;
pub extern fn SDL_HasScreenKeyboardSupport() bool;
pub const hasScreenKeyboardSupport = SDL_HasScreenKeyboardSupport;
//pub extern fn SDL_ScreenKeyboardShown(window: ?*SDL_Window) bool;
pub extern fn SDL_ScreenKeyboardShown(window: ?*Window) bool;
pub const screenKeyboardShown = SDL_ScreenKeyboardShown;
