#include <metal_stdlib>
#include <metal_math>
#include <metal_texture>
using namespace metal;

#line 6 "/Users/chrisliu/code/hyoga-zig/shaders/post_process.slang"
struct VOut_0
{
    float4 position_0 [[position]];
    float2 uv_0 [[user(_SLANG_ATTR)]];
};


#line 6
struct vertexInput_0
{
    float2 position_1 [[attribute(0)]];
    float2 uv_1 [[attribute(1)]];
};


#line 4692 "core.meta.slang"
struct KernelContext_0
{
    texture2d<float, access::sample> tex_diffuse_texture_0;
    sampler tex_diffuse_sampler_0;
};


#line 12 "/Users/chrisliu/code/hyoga-zig/shaders/post_process.slang"
[[vertex]] VOut_0 vertexMain(vertexInput_0 _S1 [[stage_in]], texture2d<float, access::sample> tex_diffuse_texture_1 [[texture(0)]], sampler tex_diffuse_sampler_1 [[sampler(0)]])
{

#line 12
    KernelContext_0 kernelContext_0;

#line 12
    (&kernelContext_0)->tex_diffuse_texture_0 = tex_diffuse_texture_1;

#line 12
    (&kernelContext_0)->tex_diffuse_sampler_0 = tex_diffuse_sampler_1;

    thread VOut_0 output_0;
    (&output_0)->position_0 = float4(_S1.position_1.xy, 0.0, 1.0);
    (&output_0)->uv_0 = _S1.uv_1;
    return output_0;
}


#line 5330 "core.meta.slang"
struct pixelOutput_0
{
    float4 output_1 [[color(0)]];
};


#line 5330
struct pixelInput_0
{
    float2 uv_2 [[user(_SLANG_ATTR)]];
};


#line 24 "/Users/chrisliu/code/hyoga-zig/shaders/post_process.slang"
[[fragment]] pixelOutput_0 fragmentMain(pixelInput_0 _S2 [[stage_in]], float4 position_2 [[position]], texture2d<float, access::sample> tex_diffuse_texture_2 [[texture(0)]], sampler tex_diffuse_sampler_2 [[sampler(0)]])
{

#line 24
    KernelContext_0 kernelContext_1;

#line 24
    (&kernelContext_1)->tex_diffuse_texture_0 = tex_diffuse_texture_2;

#line 24
    (&kernelContext_1)->tex_diffuse_sampler_0 = tex_diffuse_sampler_2;
    ;

#line 25
    pixelOutput_0 _S3 = { (((&kernelContext_1)->tex_diffuse_texture_0).sample(((&kernelContext_1)->tex_diffuse_sampler_0), (_S2.uv_2))) };

#line 25
    return _S3;
}
