#version 450 core

#include "_include/common.glsl"

layout(set = 2, binding = 0) uniform sampler2D tex_diffuse;
layout(set = 2, binding = 1) uniform sampler2D tex_specular;

layout(location = 0) in vec3 in_vert_world_pos;
layout(location = 1) in vec3 in_color;
layout(location = 2) in vec3 in_normal;
layout(location = 3) in vec2 in_uv;

layout(location = 0) out vec4 frag_color;

layout(set = 3, binding = 0) uniform CameraData {
    vec3 hy_camera_world_position;
};

layout(set = 3, binding = 1) uniform LightData {
    vec3 hy_light_direction;
};

void main() {
    vec4 ambient = vec4(0.1, 0.1, 0.1, 1);
    vec3 ld = normalize(-hy_light_direction);
    vec3 n = normalize(in_normal);
    float diffuse = max(0, dot(n, ld));
    vec3 eye_direction = normalize(hy_camera_world_position - in_vert_world_pos);

    vec3 reflected = reflect(-ld, n);
    float spec = pow(max(dot(eye_direction, reflected), 0), 32);

    frag_color = texture(tex_diffuse, in_uv) * (ambient + diffuse) * vec4(in_color, 1) +
           texture(tex_specular, in_uv).r * spec;
}
