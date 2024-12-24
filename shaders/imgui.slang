struct Mvp {
    float4x4 mvp;
}

[vk::binding(0, 1)]
ConstantBuffer<Mvp> mvp;

struct Vertex {
    float2 position;
    float2 uv;
    float4 color;
}

struct VOut {
    float4 position : SV_Position;
    float4 color;
    float2 uv;
}

[shader("vertex")]
VOut vertexMain(Vertex in)
{
    VOut output;
    output.position = mul(float4(in.position.xy, 0, 1), mvp.mvp);
    output.color = in.color;
    output.uv = in.uv;
    return output;
}

[vk::binding(0, 2)]
Sampler2D tex_diffuse;

[shader("fragment")]
float4 fragmentMain(VOut input): SV_Target {
    return input.color  * tex_diffuse.Sample(input.uv);
}
