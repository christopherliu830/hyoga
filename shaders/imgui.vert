#version 450 core

layout(location = 0) in vec2 in_position;
layout(location = 1) in vec2 in_uv;
layout(location = 2) in vec4 in_color;

layout(location = 0) out vec4 out_color;
layout(location = 1) out vec2 out_uv;

layout(set = 1, binding = 0) uniform Mvp {
    mat4 mvp;
};

void main() {
    gl_Position = mvp * vec4(in_position.xy, 0, 1);
    out_color = in_color;
    out_uv = in_uv;
}

