#version 450 core

struct Vertex {
    float3 position;
    float3 normal;
    float2 uv;
}

struct Camera {
    float4x4 model;
    float4x4 trans_inverse_model;
    float4x4 vp;
}

struct VOut {
    float4 position: SV_Position;
    float3 vert_world_pos;
    float3 color;
    float3 normal;
    float2 uv;
}

[shader("vertex")]
VOut vertexMain(
    Vertex input,
    [vk::binding(0, 1)]ConstantBuffer<Camera> camera,
) {
    VOut output;
    output.position = mul(float4(input.position, 1), mul(camera.model, camera.vp));
    output.vert_world_pos = vec3(camera.model * vec4(input.position, 1));
    output.color = vec3(1, 1, 1);
    output.normal = mul(input.normal, mat3x3(camera.trans_inverse_model));
    output.uv = input.uv;
    return output;
}
