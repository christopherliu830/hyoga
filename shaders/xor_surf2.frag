#version 450 core

layout(location = 0) in vec4 in_color;

layout(location = 0) out vec4 O;

layout(std140, set = 3, binding = 0) uniform hy_Time {
    float hy_time;
};

layout(set = 3, binding = 1) uniform hy_ViewportSize {
    vec4 hy_viewport_size;
};

void main()
{
    O = vec4(1, 1, 1, 1);

    vec4 FC = gl_FragCoord;

    //Raymarch depth
    float z = 0;

    //Step distance
    float d = 0;

    //Raymarch iterator
    float i = 0;

    //Animation time
    float t = hy_time;

    vec2 r = hy_viewport_size.xy;

    vec3 dir = normalize(vec3(floor(gl_FragCoord / 5) * 5 * 2.0) - r.xyx);

    for(i = 1; i < 1e2; i++) {
    
        //Sample point (from ray direction)
        vec3 p = z * dir;
        
        //Polar coordinates
        p = vec3(atan(p.y,p.x)*2.,
                 p.z / 1.0 - t * 4,
                 length(p.xy) - 6.);
        
        //Apply turbulence
        //https://mini.gmshaders.com/p/turbulence
        for(d = 1.; d < 4.; d++ )
            p += sin(p.yzx*d-t+.2*i) / d;
            
        //Distance to cylinder and waves
        z += d = .2 * length(vec4(p.z,.1*cos(p*3.)-.1));

        //Coloring and brightness
        O += 1. / d / i;
    }

    //Tanh tonemap
    O=tanh(O*O/24e2);
    O.w = 1;

    O *= in_color;
}
