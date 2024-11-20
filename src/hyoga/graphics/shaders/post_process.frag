#version 450 core

layout(location = 0) out vec4 out_color;

layout(set = 2, binding = 0) uniform sampler2D render_tex;

layout(location = 0) in vec2 uvs;

void main() {
    vec4 color = texture(render_tex, uvs);
    out_color = color;
}