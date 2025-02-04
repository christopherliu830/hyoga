#version 450 core

import _include.common;

struct VOut {
    float4 position: SV_Position;
    float3 color;
    float3 normal;
    float2 uv;
}

[vk::binding(0, 0)]
StructuredBuffer<float4x4> hy_all_renderables: register(b1);

[vk::binding(1, 0)]
StructuredBuffer<Sprite> hy_sprites: register(b2);

[vk::binding(0, 1)]
ConstantBuffer<float4x4> hy_view_projection_matrix;

[vk::binding(1, 1)]
ConstantBuffer<uint> hy_material_index;

[vk::binding(2, 1)]
ConstantBuffer<float> hy_time;

[vk::binding(0, 2)] Sampler2D tex_diffuse;

[shader("vertex")]
VOut vertexMain(Vertex input, int instance_id: SV_InstanceID) {
    VOut output;
    float4x4 model = hy_all_renderables[instance_id];
    output.position = mul(float4(input.position, 1), mul(model, hy_view_projection_matrix));
    output.color = float3(1, 1, 1);
    output.normal = mul(input.normal, adjugate(model));

    Sprite sprite = hy_sprites[hy_material_index];

    uint2 num_tiles = uint2(sprite.atlas_size_x, sprite.atlas_size_y);
    uint index = (uint(hy_time * sprite.speed) + sprite.start_index) % sprite.len;
    float2 tile_uv_size = float2(1, 1) / (float2)num_tiles;
    output.uv = input.uv / (float2)num_tiles +
                tile_uv_size * float2(index % num_tiles.x, index / num_tiles.x);

    return output;
}

[shader("fragment")]
float4 fragmentMain(VOut input) : SV_Target {
    float4 color = tex_diffuse.Sample(input.uv);
    if (color.w < 0.1) discard;
    return color;
}
