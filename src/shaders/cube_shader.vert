#version 450 core

layout (location = 0) in vec3 in_pos;
layout (location = 1) in vec3 aColor;
layout (location = 2) in vec2 aTexCoord;

layout (location = 0) out vec3 out_color;
layout (location = 1) out vec2 uv;

layout(set = 1, binding = 0) uniform UBO
{
    mat4x4 mvp;
};

void main() {
    gl_Position = mvp * vec4(in_pos, 1.0);
    out_color = aColor;
    uv = aTexCoord;
}