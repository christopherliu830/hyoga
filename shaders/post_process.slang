#version 450 core

import _include.common;

struct VOut {
    float4 position: SV_Position;
    float2 uv;
}

static const float4[3] vert_data = {
    -3,  -1,  -1,  1,
     1,   3,   1, -1,
     1,  -1,   1,  1,
};

[shader("vertex")]
VOut vertexMain(int id: SV_VertexID)
{
    VOut output;
    output.position = float4(vert_data[id].xy, 0, 1);
    output.uv = vert_data[id].zw;
    return output;
}

[vk::binding(0, 2)]
Sampler2D tex_diffuse;

[vk::binding(1, 2)]
Sampler2D tex_mask;

[vk::binding(0, 3)]
ConstantBuffer<float4> hy_viewport_size;

float neighborDepthDelta(float w, float h, float2 uv) {
    float2 uvCenter = uv;
    float2 uv_t = uv + float2(0, -1.0/h);
    float2 uv_r = uv + float2(1.0/w, 0);
    float2 uv_tr = uv + float2(1.0/w, -1.0/h);

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
    float delta = neighborDepthDelta(hy_viewport_size.x, hy_viewport_size.y, input.uv);
    float2 upper_left = pixelToUv(hy_viewport_size.xy, float2(-3, -3)) + input.uv;

    float q = step(0.001, tex_diffuse.Sample(upper_left).a);
    float4 shadow = float4(0, 0, 0, q);
    float4 color = tex_diffuse.Sample(input.uv);
    float use_color = step(0.001, max(max(color.r, color.g), max(color.b, color.a)));
    return lerp(shadow, color, use_color);

    // return max(shadow, tex_diffuse.Sample(input.uv));
}
