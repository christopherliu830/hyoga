#version 450 core

#include "_include/common.glsl"

layout(location = 0) in vec2 in_uv;

layout(location = 0) out vec4 frag_color;

layout(set = 2, binding = 0) uniform sampler2D tex_diffuse;

layout(set = 2, binding = 1) uniform sampler2D tex_mask;

layout(set = 3, binding = 0) uniform hy_ViewportSize {
    vec4 hy_viewport_size;
};

void main() {

    vec2 upper_left = pixelToUv(hy_viewport_size.xy, vec2(-3, -3)) + in_uv;

    // The color of the shadow at this pixel is determined
    // by the presence of a non-transparent pixel to its upper left.
    float q = step(0.001, texture(tex_diffuse, upper_left).a);
    vec4 shadow = vec4(0, 0, 0, q);

    vec4 color = texture(tex_diffuse, in_uv);

    // Use the color if it is non-zero in any component
    float use_color = step(0.001, max(max(color.r, color.g), max(color.b, color.a)));

    frag_color = mix(shadow, color, use_color);
}
