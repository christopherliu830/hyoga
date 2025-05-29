#version 450 core

#include "_include/common.glsl"

layout(set = 2, binding = 0) uniform sampler2D tex_diffuse;

layout(location = 0) in vec3 in_vert_world_pos;
layout(location = 1) in vec3 in_color;
layout(location = 2) in vec2 in_uv;

layout(location = 0) out vec4 frag_color;

void main() {
    frag_color = texture(tex_diffuse, in_uv) * vec4(in_color, 1);
}
