//! This shader renders a mesh to always face the camera.
// NOTE: billboards must zero rotation or the scaling will not work.

#version 450 core

import _include.common;

struct VOut {
    float4 position : SV_Position;
    float4 color;
    float2 uv;
}

[vk::binding(0, 0)]
StructuredBuffer<float4x4> hy_all_renderables: register(b1);

[vk::binding(1, 0)]
ByteAddressBuffer hy_sprites: register(b2);

[vk::binding(0, 1)]
ConstantBuffer<float4x4> hy_view_matrix;

[vk::binding(1, 1)]
ConstantBuffer<float4x4> hy_projection_matrix;

[vk::binding(2, 1)]
ConstantBuffer<uint> hy_material_index;

[vk::binding(3, 1)]
ConstantBuffer<float> hy_time;

[vk::binding(0, 2)] Sampler2D tex_diffuse;

[shader("vertex")]
VOut vertexMain(Vertex in,
    int instance_id: SV_InstanceID,
    int vertex_id: SV_VertexID)
{
    float4x4 object = hy_all_renderables[instance_id];
    float3 world_position = object[3].xyz;

    float3 object_scale = float3(object[0][0], object[1][1], object[2][2]);


    float4x4 view = hy_view_matrix;
    float3 camera_right = float3(view[0][0], view[1][0], view[2][0]);
    float3 camera_up = float3(view[0][1], view[1][1], view[2][1]);

    float th = object_scale.z;
    float2x2 rot = (cos(th), -sin(th),
                    sin(th),  cos(th));

    // float2 position = mul(in.position.xy, rot);
    float2 position = in.position.xy;

    position = float2(position.x * cos(th) - position.y * sin(th),
                      position.y * cos(th) + position.x * sin(th));

    float3 position_world = world_position + 
                            camera_right * position.x * object_scale.x +
                            camera_up * position.y * object_scale.y;

    float4 final = mul(float4(position_world, 1), mul(view, hy_projection_matrix));

    // Sprite animation
    Sprite sprite = hy_sprites.Load<Sprite>(hy_material_index);

    uint2 num_tiles = uint2(sprite.atlas_size_x, sprite.atlas_size_y);

    uint counter = uint(hy_time * asfloat(sprite.speed) + asfloat(sprite.time_offset));
    uint index = (counter  % sprite.len) + sprite.start_index;

    float2 tile_uv_size = float2(1, 1) / (float2)num_tiles;
    float2 uv = in.uv / (float2)num_tiles +
                tile_uv_size * float2(index % num_tiles.x, index / num_tiles.x);

    VOut out;
    out.position = final;
    out.color = float4(
        asfloat(sprite.color[0]),
        asfloat(sprite.color[1]),
        asfloat(sprite.color[2]),
        asfloat(sprite.color[3]),
    );
    out.uv = uv;
    
    return out;
}

[shader("fragment")]
float4 fragmentMain(VOut in): SV_Target {
    float4 color = tex_diffuse.Sample(in.uv) * in.color;
    if (color.w < 0.1) discard;
    return color;
}

