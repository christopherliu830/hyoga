#version 450 core

layout(location = 0) out vec4 out_color;

layout(set = 2, binding = 0) uniform sampler2D tex_diffuse;
layout(set = 2, binding = 1) uniform sampler2D tex_specular;

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
    vec3 ld = -normalize(lighting.light_dir);
    vec3 n = normalize(normal);
    float diffuse = max(0, dot(n, ld));
    vec3 eye_direction = normalize(lighting.camera_pos - vtx_pos);

    vec3 reflected = reflect(-ld, normal);
    float spec = pow(max(dot(eye_direction, reflected), 0), 32) * 0.5;

    out_color = texture(tex_diffuse, uv) * (ambient + diffuse) * vec4(vtx_color, 1) +
                texture(tex_specular, uv).r * spec;
 }