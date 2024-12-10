pub const PowerState = enum (c_int) {
    @"error" = -1,
    unknown,
    on_battery,
    no_battery,
    charging,
    charged
};

pub extern fn SDL_GetPowerInfo(seconds: ?*i32, percent: ?*i32) PowerState;