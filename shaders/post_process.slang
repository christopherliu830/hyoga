struct Vertex {
    float2 position;
    float2 uv;
}

struct VOut {
    float4 position: SV_Position;
    float2 uv;
}

struct Window {
    uint16_t size_x;
    uint16_t size_y;
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
Sampler2D tex_diffuse;

[vk::binding(1, 2)]
Sampler2D tex_mask;

[vk::binding(0, 3)]
ConstantBuffer<Window> window;

float neighborDepthDelta(float2 uv) {
    float2 uvCenter = uv;
    float2 uv_t = uv + float2(0, -1.0/window.size_y);
    float2 uv_r = uv + float2(1.0/window.size_x, 0);
    float2 uv_tr = uv + float2(1.0/window.size_x, -1.0/window.size_y);

    float m_center = tex_mask.Sample(uv).r;
    float m_top = tex_mask.Sample(uv_t).r;
    float m_right = tex_mask.Sample(uv_r).r;
    float m_topright = tex_mask.Sample(uv_tr).r;

    float d_t = abs(m_center - m_top);
    float d_r = abs(m_center - m_right);
    float d_tr = abs(m_center - m_topright);

    float delta = max(0, d_t);
    delta = max(delta, d_r);
    delta = max(delta, d_tr);
    return delta;
}

[shader("fragment")]
float4 fragmentMain(VOut input): SV_Target {

    // outline
    float delta = neighborDepthDelta(input.uv); 

    return tex_diffuse.Sample(input.uv) + float4(delta, delta, delta, 1);
}