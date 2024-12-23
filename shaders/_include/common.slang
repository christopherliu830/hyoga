struct Vertex {
    float3 position;
    float3 normal;
    float2 uv;
}

struct Scene {
    int16_t     viewport_size_x;
    int16_t     viewport_size_y;
    float4x4    view_proj;
    float4x4    adj;
    float3      light_dir;
};

struct Lighting {
    float3 light_dir;
    float3 camera_pos;
}

float3x3 adjugate(float4x4 m) {
    return float3x3(cross(m[1].xyz, m[2].xyz),
                    cross(m[2].xyz, m[0].xyz),
                    cross(m[0].xyz, m[1].xyz));
}
