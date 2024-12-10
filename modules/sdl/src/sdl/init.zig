
const InitFlags = u32;

pub const Flag = struct {
    pub const audio = 0x0000010;
    pub const video = 0x0000020;
    pub const joystick = 0x0000200;
    pub const haptic = 0x0001000;
    pub const gamepad = 0x0002000;
    pub const events = 0x0004000;
    pub const sensor = 0x0008000;
    pub const camera = 0x0010000;
};

extern fn SDL_Init(flags: InitFlags) bool;
pub const init = SDL_Init;

extern fn SDL_Quit() void;
pub const quit = SDL_Quit;