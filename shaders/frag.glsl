#version 450
layout(row_major) uniform;
layout(row_major) buffer;

#line 43 0
layout(binding = 0, set = 2)
uniform sampler2D tex_diffuse_0;


#line 44
layout(binding = 1, set = 2)
uniform sampler2D tex_specular_0;


#line 10
struct _MatrixStorage_float4x4_ColMajorstd140_0
{
    vec4  data_0[4];
};


#line 14
struct Scene_std140_0
{
    _MatrixStorage_float4x4_ColMajorstd140_0 view_proj_0;
    vec3 camera_world_pos_0;
    int viewport_size_x_0;
    vec3 light_dir_0;
    int viewport_size_y_0;
};


#line 3962 1
layout(binding = 1)
layout(std140) uniform block_Scene_std140_0
{
    _MatrixStorage_float4x4_ColMajorstd140_0 view_proj_0;
    vec3 camera_world_pos_0;
    int viewport_size_x_0;
    vec3 light_dir_0;
    int viewport_size_y_0;
}entryPointParams_gscene_0;

#line 4811
layout(location = 0)
out vec4 entryPointParam_fragmentMain_0;


#line 4811
layout(location = 0)
in vec3 input_vert_world_pos_0;


#line 4811
layout(location = 1)
in vec3 input_color_0;


#line 4811
layout(location = 2)
in vec3 input_normal_0;


#line 4811
layout(location = 3)
in vec2 input_uv_0;


#line 47 0
void main()
{



    vec3 ld_0 = - normalize(entryPointParams_gscene_0.light_dir_0);

#line 52
    entryPointParam_fragmentMain_0 = (texture((tex_diffuse_0), (input_uv_0))) * (vec4(0.10000000149011612, 0.10000000149011612, 0.10000000149011612, 1.0) + max(0.0, dot(normalize(input_normal_0), ld_0))) * vec4(input_color_0, 1.0) + (texture((tex_specular_0), (input_uv_0))).x * (pow(max(dot(normalize(entryPointParams_gscene_0.camera_world_pos_0 - input_vert_world_pos_0), reflect(- ld_0, input_normal_0)), 0.0), 32.0) * 0.5);

#line 52
    return;
}

