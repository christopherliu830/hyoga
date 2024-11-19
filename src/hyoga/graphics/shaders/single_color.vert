#version 450 core

layout (location = 0) in vec3 in_pos;
layout (location = 1) in vec3 in_normal;
layout (location = 2) in vec2 in_uv;

layout(set = 1, binding = 0) uniform TransformMatrices
{
    mat4x4 model;
    mat4x4 mvp;
    mat4x4 normal;
} ubo;


void main() {
    gl_Position = ubo.mvp * vec4(in_pos + in_normal * 0.02, 1);
}
