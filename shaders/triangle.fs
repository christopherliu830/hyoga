#version 410 core

out vec4 fragColor;
in vec3 ourColor;

uniform vec4 color;

void main()
{
    fragColor = vec4(color, 1.0);
}