#version 450 core

import _include.common;

struct VOut {
    float4 position: SV_Position;
    float3 vert_world_pos;
    float3 color;
    float3 normal;
    float2 uv;
}

[vk::binding(0, 2)] Sampler2D tex_diffuse;
[vk::binding(1, 2)] Sampler2D tex_specular;

[vk::binding(0, 3)]
ConstantBuffer<float3> hy_camera_world_position;
[vk::binding(1, 3)]
ConstantBuffer<float3> hy_light_direction;

[shader("fragment")]
float4 fragmentMain(VOut input): SV_Target {
    vec4 ambient = vec4(0.1, 0.1, 0.1, 1);
    vec3 ld = normalize(-hy_light_direction);
    vec3 n = normalize(input.normal);
    float diffuse = max(0, dot(n, ld));
    vec3 eye_direction = normalize(hy_camera_world_position - input.vert_world_pos);

    vec3 reflected = reflect(-ld, n);
    float spec = pow(max(dot(eye_direction, reflected), 0), 32);

    // return float4(hy_camera_world_position, 1);

    return tex_diffuse.Sample(input.uv) * (ambient + diffuse) * vec4(input.color, 1) +
        tex_specular.Sample(input.uv).x * spec;
}

