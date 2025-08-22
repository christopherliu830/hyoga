pub fn version() u32 {
    return @intCast(SDL_GetVersion());
}

extern fn SDL_GetVersion() c_int;
