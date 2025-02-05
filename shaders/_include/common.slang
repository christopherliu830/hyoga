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
    uint time_offset; // float. used in sprite animation index
    uint [4]color;
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

float2 pixelToUv(float2 window_dimensions, float2 pixels) {
    return pixels / window_dimensions;
};