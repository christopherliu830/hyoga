//! This shader takes a scene and outputs a black and white texture.

#version 450 core

import _include.common;

struct VOut {
    float4 position: SV_Position;
}

[vk::binding(0, 0)]
StructuredBuffer<float4x4> objects;

[vk::binding(0, 1)]
ConstantBuffer<float4x4> hy_view_projection_matrix;

[shader("vertex")]
VOut vertexMain(Vertex in, int instance_id: SV_InstanceID)
{
    float4x4 model = objects[instance_id];
    VOut out;
    out.position = mul(float4(in.position, 1), mul(model, hy_view_projection_matrix));
    return out;
}

[shader("fragment")]
float4 fragmentMain(): SV_Target {
    return float4(1, 1, 1, 1);
}
