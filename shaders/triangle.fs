#version 410 core

out vec4 fragColor;
in vec3 ourColor;
in vec2 TexCoord;

uniform vec4 color;
uniform float mix_amount;

uniform sampler2D texture1;
uniform sampler2D texture2;

void main()
{
    fragColor = mix(texture(texture1, TexCoord), texture(texture2, TexCoord), mix_amount); 
}