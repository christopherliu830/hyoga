struct Vertex {
    float2 position;
    float2 uv;
}

struct VOut {
    float4 position: SV_Position;
    float2 uv;
}

[shader("vertex")]
VOut vertexMain(Vertex in)
{
    VOut output;
    output.position = float4(in.position.xy, 0, 1);
    output.uv = in.uv;
    return output;
}

[vk::binding(0, 2)]
Texture2D tex_diffuse;
SamplerState sampler_state;

[shader("fragment")]
float4 fragmentMain(VOut input): SV_Target {
    return tex_diffuse.Sample(sampler_state, input.uv);
}