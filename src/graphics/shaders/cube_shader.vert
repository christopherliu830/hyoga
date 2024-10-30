#version 450 core

layout (location = 0) in vec3 in_pos;
layout (location = 1) in vec3 in_normal;
layout (location = 2) in vec2 in_uv;

layout (location = 0) out vec3 out_color;
layout (location = 1) out vec3 out_normal;
layout (location = 2) out vec2 out_uv;
layout (location = 3) out vec3 out_light_dir;

layout(set = 1, binding = 0) uniform UBO
{
    mat4x4 m;
    mat4x4 v;
    mat4x4 p;
    mat4x4 normal;
} ubo;

void main() {
    gl_Position = ubo.p * ubo.v * ubo.m * vec4(in_pos, 1);
    // gl_Position = ubo.mvp * vec4(in_pos, 1);
    out_color = vec3(1, 1, 1);
    out_normal = normalize(mat3(ubo.normal) * in_normal);
    out_light_dir = vec3(-1, -1, -1);
    out_uv = in_uv;
}
