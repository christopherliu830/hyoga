#version 450 core

#include "_include/common.glsl"

layout(location = 0) in vec2 in_uv;

layout(location = 0) out vec4 frag_color;

layout(set = 2, binding = 0) uniform sampler2D tex_diffuse;

void main() {
    vec4 color = texture(tex_diffuse, in_uv);
    frag_color = color;
}
