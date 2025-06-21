#version 450 core

layout(location = 0) in vec4 in_color;
layout(location = 1) in vec2 in_uv;

layout(location = 0) out vec4 frag_color;

layout(set = 2, binding = 0) uniform sampler2D tex_diffuse; 

void main() {
    const float smoothing = (1.0 / 16.0);
    float dist = texture(tex_diffuse, in_uv).a;
    float alpha = smoothstep(0.5 - smoothing, 0.5 + smoothing, dist);
    frag_color = vec4(in_color.rgb, in_color.a * alpha);
}


