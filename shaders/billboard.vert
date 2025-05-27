#version 450 core

#include "_include/common.glsl"

layout(location = 0) in vec3 in_position;
layout(location = 1) in vec3 in_normal;
layout(location = 2) in vec2 in_uv;

layout(location = 0) out vec4 out_color;
layout(location = 1) out vec2 out_uv;

layout(std430, row_major, set = 0, binding = 0) readonly buffer hy_AllRenderables {
    mat4 hy_all_renderables[];
};

layout(std430, set = 0, binding = 1) buffer hy_Sprites {
    uint hy_sprites[];
};

layout(std140, row_major, set = 1, binding = 0) uniform hy_ViewMatrix {
    mat4 hy_view_matrix;
};

layout(std140, row_major, set = 1, binding = 1) uniform hy_ProjectionMatrix {
    mat4 hy_projection_matrix;
};

layout(std140, set = 1, binding = 2) uniform hy_MaterialIndex {
    uint hy_material_index;
};

layout(std140, set = 1, binding = 3) uniform hy_Time {
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
    mat4 object = hy_all_renderables[gl_InstanceIndex];
    vec3 world_position = vec3(object[0][3], object[1][3], object[2][3]);

    vec3 object_scale = vec3(object[0][0], object[1][1], object[2][2]);

    mat4 view = hy_view_matrix;
    vec3 camera_right = vec3(view[0][0], view[0][1], view[0][2]);
    vec3 camera_up = vec3(view[1][0], view[1][1], view[1][2]);

    float th = object_scale.z;

    vec2 position = in_position.xy;
    position = vec2(position.x * cos(th) - position.y * sin(th),
                    position.y * cos(th) + position.x * sin(th));

    vec3 position_world = world_position + 
                          camera_right * position.x * object_scale.x +
                          camera_up    * position.y * object_scale.y;

    vec4 final = vec4(position_world, 1) * view * hy_projection_matrix;

    // Sprite animation
    Sprite sprite = hy_sprite_load(hy_material_index);

    uvec2 num_tiles = uvec2(sprite.atlas_size_x, sprite.atlas_size_y);

    uint counter = uint(hy_time * uintBitsToFloat(sprite.speed) + uintBitsToFloat(sprite.time_offset));
    uint index = (counter  % sprite.len) + sprite.start_index;

    vec2 tile_uv_size = vec2(1, 1) / vec2(num_tiles);
    vec2 uv = in_uv / vec2(num_tiles) +
                tile_uv_size * vec2(index % num_tiles.x, index / num_tiles.x);

    gl_Position = final;
    out_color = vec4(
        uintBitsToFloat(sprite.color_x),
        uintBitsToFloat(sprite.color_y),
        uintBitsToFloat(sprite.color_z),
        uintBitsToFloat(sprite.color_w)
    );
    out_uv = uv;
}

