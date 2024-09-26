#version 450 core

layout(location = 0) out vec4 fColor;

layout(set=2, binding=0) uniform sampler2D sTexture;

layout(location = 0) in vec4 Color;
layout(location = 1) in vec2 UV;

void main()
{
    fColor = Color * texture(sTexture, UV.st);
    // if (fColor.w < 0.8) discard;
    // fColor = vec4(UV.st, 0, 1);
}