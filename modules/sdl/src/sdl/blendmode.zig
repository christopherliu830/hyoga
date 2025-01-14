pub const BlendMode = packed struct(c_uint) {
    none: bool = false,
    blend: bool = false,
    blend_premultiplied: bool = false,
    add: bool = false,
    add_premultiplied: bool = false,
    mod: bool = false,
    mul: bool = false,
    invalid: bool = false,
    _padding: u24 = 0,
};

pub const BlendOperation = enum(c_uint) {
    add = 1,
    subtract = 2,
    rev_subtract = 3,
    minimum = 4,
    maximum = 5,
};

pub const BlendFactor = enum(c_uint) {
    zero = 1,
    one = 2,
    src_color = 3,
    one_minus_src_color = 4,
    src_alpha = 5,
    one_minus_src_alpha = 6,
    dst_color = 7,
    one_minus_dst_color = 8,
    dst_alpha = 9,
    one_minus_dst_alpha = 10,
};

pub extern fn SDL_ComposeCustomBlendMode(srcColorFactor: BlendFactor, dstColorFactor: BlendFactor, colorOperation: BlendOperation, srcAlphaFactor: BlendFactor, dstAlphaFactor: BlendFactor, alphaOperation: BlendOperation) BlendMode;
pub const composeCustomBlendMode = SDL_ComposeCustomBlendMode;
