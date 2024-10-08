#version 450 core

layout(location = 0) out vec4 out_color;

layout(set = 2, binding = 0) uniform sampler2D tex;

layout(location = 0) in vec3 vtx_color;
layout (location = 1) in vec3 normal;
layout(location = 2) in vec2 uv;

void main() {
    vec3 light_dir = vec3(0, -1, 0);
    float light_amt = max(0, dot(normalize(normal), -light_dir));
    out_color = vec4(1, 1, 1, 1) * texture(tex, uv) * light_amt;
}