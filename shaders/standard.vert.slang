#version 450 core

import _include.common;

struct VOut {
    float4 position: SV_Position;
    float3 vert_world_pos;
    float3 color;
    float3 normal;
    float2 uv;
}

[vk::binding(0, 0)]
StructuredBuffer<float4x4> hy_all_renderables: register(b1);

[vk::binding(0, 1)]
ConstantBuffer<float4x4> hy_view_projection_matrix;

[shader("vertex")]
VOut vertexMain(Vertex input, int instance_id: SV_InstanceID) {
    VOut output;
    float4x4 model = hy_all_renderables[instance_id];
    output.position = mul(float4(input.position, 1), mul(model, hy_view_projection_matrix));
    output.vert_world_pos = vec3(model * vec4(input.position, 1));
    output.color = float3(1, 1, 1);
    output.normal = mul(input.normal, adjugate(model));
    output.uv = input.uv;
    return output;
}

