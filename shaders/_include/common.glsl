struct Sprite {
    uint atlas_size_x;
    uint atlas_size_y;
    uint start_index;
    uint len;
    uint speed;
    uint time_offset; // float. used in sprite animation index
    uint color_x;
    uint color_y;
    uint color_z;
    uint color_w;
};

mat3 adjugate(mat4 m) {
    return mat3(cross(m[1].xyz, m[2].xyz),
                cross(m[2].xyz, m[0].xyz),
                cross(m[0].xyz, m[1].xyz));
}

vec2 pixelToUv(vec2 window_dimensions, vec2 pixels) {
    return pixels / window_dimensions;
}
