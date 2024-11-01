#version 450 core

layout(location = 0) out vec4 out_color;

layout(set = 2, binding = 0) uniform sampler2D tex_diffuse;

layout (location = 0) in vec3 vtx_pos;
layout (location = 1) in vec3 vtx_color;
layout (location = 2) in vec3 normal;
layout (location = 3) in vec2 uv;

layout(set = 3, binding = 0) uniform Lighting {
    vec3 light_dir;
    vec3 camera_pos;
} lighting;


void main() {
    vec4 ambient = vec4(0.1, 0.1, 0.1, 1);

    float diffuse_amt = max(0, dot(normalize(normal), -normalize(lighting.light_dir)));

    out_color = min(ambient + diffuse_amt, 1) * vec4(vtx_color, 1) * texture(tex_diffuse, uv);
}