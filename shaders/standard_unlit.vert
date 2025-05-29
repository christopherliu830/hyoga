#version 450 core

#include "_include/common.glsl"

layout(location = 0) in vec3 in_position;
layout(location = 1) in vec3 in_normal;
layout(location = 2) in vec2 in_uv;

layout(location = 0) out vec3 out_vert_world_pos;
layout(location = 1) out vec3 out_color;
layout(location = 2) out vec2 out_uv;

layout(std430, row_major, set = 0, binding = 0) readonly buffer hy_AllRenderables { 
    mat4 hy_all_renderables[];
};

layout(std140, row_major, set = 1, binding = 0) uniform hy_ViewProjectionMatrix {
    mat4 hy_view_projection_matrix;
};

void main() {
    uint instance_id = gl_InstanceIndex;

    mat4 model = hy_all_renderables[instance_id];

    gl_Position = vec4(in_position, 1) * model * hy_view_projection_matrix;
    out_vert_world_pos = vec3(vec4(in_position, 1) * model);
    out_color = vec3(1, 1, 1);
    out_uv = in_uv;
}
