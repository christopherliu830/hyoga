#version 450 core

struct Vertex {
    float3 position;
    float3 normal;
    float2 uv;
}

struct Lighting {
    float3 light_dir;
    float3 camera_pos;
}

struct Camera {
    float4x4 model;
    float4x4 trans_inverse_model;
    float4x4 vp;
}

[vk::binding(0, 1)]
ConstantBuffer<Camera> camera;

struct VOut {
    float4 position: SV_Position;
    float3 vert_world_pos;
    float3 color;
    float3 normal;
    float2 uv;
}

[shader("vertex")]
VOut vertexMain(Vertex input)
{
    VOut output;
    output.position = mul(float4(input.position, 1), mul(camera.model, camera.vp));
    output.vert_world_pos = vec3(camera.model * vec4(input.position, 1));
    output.color = vec3(1, 1, 1);
    output.normal = normalize(mat3x3(camera.trans_inverse_model) * input.normal);
    output.uv = input.uv;
    return output;
}

[vk::binding(0, 2)]
Texture2D tex_diffuse;
[vk::binding(1, 2)]
Texture2D tex_specular;

[vk::binding(0, 3)]
ConstantBuffer<Lighting> lighting;


SamplerState sampler_state;

[shader("fragment")]
float4 fragmentMain(VOut input): SV_Target {
    vec4 ambient = vec4(0.1, 0.1, 0.1, 0.1);
    vec3 ld = -normalize(lighting.light_dir);
    vec3 n = normalize(input.normal);
    float diffuse = max(0, dot(n, ld));
    vec3 eye_direction = normalize(lighting.camera_pos - input.vert_world_pos);

    vec3 reflected = reflect(-ld, input.normal);
    float spec = pow(max(dot(eye_direction, reflected), 0), 32) * 0.5;

    return tex_diffuse.Sample(sampler_state, input.uv) * (ambient + diffuse) * vec4(input.color, 1) +
        tex_specular.Sample(sampler_state, input.uv).x * spec;
}