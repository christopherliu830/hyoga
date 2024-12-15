//! This shader takes a scene and outputs a black and white texture.

#version 450 core

struct Vertex {
    float3 position;
    float3 normal;
    float2 uv;
}

struct Transforms {
    float4x4 model;
    float4x4 trans_inverse_model;
    float4x4 vp;
}

struct VOut {
    float4 position: SV_Position;
}

[vk::binding(0, 1)]
ConstantBuffer<Transforms> m;

[shader("vertex")]
VOut vertexMain(Vertex in)
{
    VOut output;
    output.position = mul(float4(in.position, 1), mul(m.model, m.vp));
    return output;
}

[shader("fragment")]
float4 fragmentMain(VOut input) : SV_Target {
    return float4(1, 1, 1, 1);
}