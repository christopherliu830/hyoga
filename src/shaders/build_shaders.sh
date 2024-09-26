# Rebuilds the shaders needed for the GPU $1 test.
# For SPIR-V: requires glslangValidator and spirv-cross, which can be obtained from the LunarG Vulkan SDK.
# For DXBC compilation: requires FXC, which is part of the Windows SDK.
# For DXIL compilation, requires DXC, which can be obtained via the Windows SDK or via here: https://github.com/microsoft/DirectXShaderCompiler/releases
# For Metal compilation: requires Xcode

# On Windows, run this via Git Bash.
# To add the Windows SDK (FXC/DXC) to your path, run the command:
#   `export PATH=$PATH:/c/Program\ Files\ \(x86\)/Windows\ Kits/10/bin/x.x.x.x/x64/`

export MSYS_NO_PATHCONV=1

# SPIR-V
glslangValidator $1.vert -V -S vert -o $1.vert.spv --quiet
glslangValidator $1.frag -V -S frag -o $1.frag.spv --quiet
xxd -i $1.vert.spv | perl -w -p -e 's/\Aunsigned char (\w+)\[\] = /pub const $1 = \[_\]u8 /;' > $1.vert.zig
xxd -i $1.frag.spv | perl -w -p -e 's/\Aunsigned char (\w+)\[\] = /pub const $1 = \[_\]u8 /;' > $1.frag.zig
cat $1.vert.zig $1.frag.zig > $1_spirv.zig
cat $1_spirv.zig | perl -w -n -e 'print unless /unsigned int/' > $1_spirv.zig
rm -f $1.vert.zig $1.frag.zig $1.vert.spv $1.frag.spv

# Platform-specific compilation
if [[ "$OSTYPE" == "darwin"* ]]; then

    # FIXME: Needs to be updated!

    # Xcode
    generate_shaders()
    {
        fileplatform=$1
        compileplatform=$2
        sdkplatform=$3
        minversion=$4

        xcrun -sdk $sdkplatform metal -c -std=$compileplatform-metal1.1 -m$sdkplatform-version-min=$minversion -Wall -O3 -DVERTEX=1 -o ./$1.vert.air ./$1.metal || exit $?
        xcrun -sdk $sdkplatform metal -c -std=$compileplatform-metal1.1 -m$sdkplatform-version-min=$minversion -Wall -O3 -o ./$1.frag.air ./$1.metal || exit $?

        xcrun -sdk $sdkplatform metallib -o $1.vert.metallib $1.vert.air || exit $?
        xcrun -sdk $sdkplatform metallib -o $1.frag.metallib $1.frag.air || exit $?

        xxd -i $1.vert.metallib | perl -w -p -e 's/\Aunsigned /const unsigned /;' >./$1.vert_$fileplatform.h
        xxd -i $1.frag.metallib | perl -w -p -e 's/\Aunsigned /const unsigned /;' >./$1.frag_$fileplatform.h

        rm -f $1.vert.air $1.vert.metallib
        rm -f $1.frag.air $1.frag.metallib
    }

    generate_shaders macos macos macosx 10.11
    generate_shaders ios ios iphoneos 8.0
    generate_shaders iphonesimulator ios iphonesimulator 8.0
    generate_shaders tvos ios appletvos 9.0
    generate_shaders tvsimulator ios appletvsimulator 9.0

    # Bundle together one mega-header
    rm -f testgpu_metallib.h
    echo "#if defined(SDL_PLATFORM_IOS)" >> testgpu_metallib.h
        echo "#if TARGET_OS_SIMULATOR" >> testgpu_metallib.h
            cat $1.vert_iphonesimulator.h >> testgpu_metallib.h
            cat $1.frag_iphonesimulator.h >> testgpu_metallib.h
        echo "#else" >> testgpu_metallib.h
            cat $1.vert_ios.h >> testgpu_metallib.h
            cat $1.frag_ios.h >> testgpu_metallib.h
        echo "#endif" >> testgpu_metallib.h
    echo "#elif defined(SDL_PLATFORM_TVOS)" >> testgpu_metallib.h
        echo "#if TARGET_OS_SIMULATOR" >> testgpu_metallib.h
            cat $1.vert_tvsimulator.h >> testgpu_metallib.h
            cat $1.frag_tvsimulator.h >> testgpu_metallib.h
        echo "#else" >> testgpu_metallib.h
            cat $1.vert_tvos.h >> testgpu_metallib.h
            cat $1.frag_tvos.h >> testgpu_metallib.h
        echo "#endif" >> testgpu_metallib.h
    echo "#else" >> testgpu_metallib.h
        cat $1.vert_macos.h >> testgpu_metallib.h
        cat $1.frag_macos.h >> testgpu_metallib.h
    echo "#endif" >> testgpu_metallib.h

    # Clean up
    rm -f $1.vert_macos.h $1.frag_macos.h
    rm -f $1.vert_iphonesimulator.h $1.frag_iphonesimulator.h
    rm -f $1.vert_tvsimulator.h $1.frag_tvsimulator.h
    rm -f $1.vert_ios.h $1.frag_ios.h
    rm -f $1.vert_tvos.h $1.frag_tvos.h

elif [[ "$OSTYPE" == "cygwin"* ]] || [[ "$OSTYPE" == "msys"* ]]; then

    # FXC
    fxc $1.hlsl /E VSMain /T vs_5_0 /Fh $1.vert.h
    fxc $1.hlsl /E PSMain /T ps_5_0 /Fh $1.frag.h

    cat $1.vert.h | perl -w -p -e 's/BYTE/unsigned char/;s/g_VSMain/D3D11_CubeVert/;' > $1.vert.temp.h
    cat $1.frag.h | perl -w -p -e 's/BYTE/unsigned char/;s/g_PSMain/D3D11_CubeFrag/;' > $1.frag.temp.h
    cat $1.vert.temp.h $1.frag.temp.h > testgpu_dxbc.h
    rm -f $1.vert.h $1.frag.h $1.vert.temp.h $1.frag.temp.h

    # DXC
    dxc $1.hlsl /E VSMain /T vs_6_0 /Fh $1.vert.h /D D3D12=1
    dxc $1.hlsl /E PSMain /T ps_6_0 /Fh $1.frag.h /D D3D12=1

    cat $1.vert.h | perl -w -p -e 's/BYTE/unsigned char/;s/g_VSMain/D3D12_CubeVert/;' > $1.vert.temp.h
    cat $1.frag.h | perl -w -p -e 's/BYTE/unsigned char/;s/g_PSMain/D3D12_CubeFrag/;' > $1.frag.temp.h
    cat $1.vert.temp.h $1.frag.temp.h > testgpu_dxil.h
    rm -f $1.vert.h $1.frag.h $1.vert.temp.h $1.frag.temp.h

fi
