#version 450 core

layout(location = 0) in vec4 in_color;
layout(location = 1) in vec2 in_uv;

layout(location = 0) out vec4 frag_color;

layout(set = 2, binding = 0) uniform sampler2D tex_diffuse; 


void main() {
    frag_color = in_color  * texture(tex_diffuse, in_uv);
}

