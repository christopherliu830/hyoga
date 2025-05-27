#version 450 core

#include "_include/common.glsl"

layout(location = 0) in vec3 in_color;
layout(location = 1) in vec3 in_normal;
layout(location = 2) in vec2 in_uv;

layout(location = 0) out vec4 frag_color;

layout(set = 2, binding = 0) uniform sampler2D tex_diffuse;

void main() {
    frag_color = texture(tex_diffuse, in_uv);
    if (frag_color.w < 0.1) discard;
}
