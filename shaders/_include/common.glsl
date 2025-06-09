struct Sprite {
    uint atlas_size_x;
    uint atlas_size_y;
    uint start_index;
    uint len;
    float speed;
    float time_offset; // Used in sprite animation index.
    vec4 color; // Tint color
};

mat3 adjugate(mat4 m) {
    return mat3(cross(m[1].xyz, m[2].xyz),
                cross(m[2].xyz, m[0].xyz),
                cross(m[0].xyz, m[1].xyz));
}

vec2 pixelToUv(vec2 window_dimensions, vec2 pixels) {
    return pixels / window_dimensions;
}
