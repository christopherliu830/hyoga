pub const PenID = u32;

pub const InputFlags = packed struct (c_int) {
    down: bool = false,
    button_1: bool = false,
    button_2: bool = false,
    button_3: bool = false,
    button_4: bool = false,
    button_5: bool = false,
    _padding1: u24 = 0,
    eraser_tip: bool = false,
    _padding2: u1 = 0,
};

pub const Axis = enum (c_uint) {
    pressure,
    xtilt,
    ytilt,
    distance,
    rotation,
    slider,
    tangential_pressure,
    count
};
