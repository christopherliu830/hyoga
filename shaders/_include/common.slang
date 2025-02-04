struct Vertex {
    float3 position;
    float3 normal;
    float2 uv;
}

struct ScreenVertex {
    float2 position;
    float2 uv;
}

struct Sprite {
    uint atlas_size_x;
    uint atlas_size_y;
    uint start_index;
    uint len;
    uint speed;
}


struct Lighting {
    float3 light_dir;
    float3 camera_pos;
}

float3x3 adjugate(float4x4 m) {
    return float3x3(cross(m[1].xyz, m[2].xyz),
                    cross(m[2].xyz, m[0].xyz),
                    cross(m[0].xyz, m[1].xyz));
}
