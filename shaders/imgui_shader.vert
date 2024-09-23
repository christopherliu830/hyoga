#version 450 core
layout(location = 0) in vec2 aPos;
layout(location = 1) in vec2 aUV;
layout(location = 2) in vec4 aColor;
layout(set = 1, binding = 0) uniform UBO
{
    mat4 projMatrix;
} ubo;

out gl_PerVertex { vec4 gl_Position; };

layout(location = 0) out vec4 Color; 
layout(location = 1) out vec2 UV;

void main()
{
    Color = aColor;
    UV = aUV;
    gl_Position = ubo.projMatrix * vec4(aPos.xy, 0, 1);
}