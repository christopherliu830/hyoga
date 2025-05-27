#version 450 core

#include "_include/common.glsl"

layout(location = 0) in vec3 in_position;
layout(location = 1) in vec3 in_normal;
layout(location = 2) in vec2 in_uv;

layout(location = 0) out vec3 out_color;
layout(location = 1) out vec3 out_normal;
layout(location = 2) out vec2 out_uv;

layout(std430, set = 0, binding = 0) readonly buffer hy_AllRenderables {
    mat4 hy_all_renderables[];
};

layout(std430, set = 0, binding = 1) buffer hy_Sprites {
    uint hy_sprites[];
};

layout(std140, set = 1, binding = 0) uniform hy_ViewProjectionMatrix {
    mat4 hy_view_projection_matrix;
};

layout(std140, set = 1, binding = 1) uniform hy_MaterialIndex {
    uint hy_material_index;
};

layout(std140, set = 1, binding = 2) uniform hy_Time {
    float hy_time;
};

Sprite hy_sprite_load(uint byte_offset) {
    uint index = byte_offset / 4;
    Sprite s;
    s.atlas_size_x = hy_sprites[index + 0];
    s.atlas_size_y = hy_sprites[index + 1];
    s.start_index  = hy_sprites[index + 2];
    s.len          = hy_sprites[index + 3];
    s.speed        = hy_sprites[index + 4];
    s.time_offset  = hy_sprites[index + 5];
    s.color_x      = hy_sprites[index + 6];
    s.color_y      = hy_sprites[index + 7];
    s.color_z      = hy_sprites[index + 8];
    s.color_w      = hy_sprites[index + 9];
    return s;
}

void main() {
    mat4 model = hy_all_renderables[gl_InstanceIndex];

    gl_Position =  vec4(in_position, 1) *  model * hy_view_projection_matrix;
    out_color = vec3(1, 1, 1);
    out_normal = in_normal * adjugate(model);

    // Sprite animation
    Sprite sprite = hy_sprite_load(hy_material_index);

    uvec2 num_tiles = uvec2(sprite.atlas_size_x, sprite.atlas_size_y);
    uint index = (uint(hy_time * sprite.speed) + sprite.start_index) % sprite.len;
    vec2 tile_uv_size = vec2(1, 1) / vec2(num_tiles);
    out_uv = in_uv / vec2(num_tiles) +
             tile_uv_size * vec2(index % num_tiles.x, index / num_tiles.x);
}

