#version 450 core

const vec4 vert_data[3] = {
    vec4(-3,  -1,  -1,  1),
    vec4(1,   3,   1, -1),
    vec4(1,  -1,   1,  1)
};

layout(location = 0) out vec2 out_uv;

void main() {
    gl_Position = vec4(vert_data[gl_VertexIndex].xy, 0, 1);
    out_uv = vert_data[gl_VertexIndex].zw;
}
