import subprocess as sp
import os
import binascii
from textwrap import fill
from pathlib import Path

cwd = Path(os.getcwd()).resolve()
shaders_path = cwd.joinpath("src/graphics/shaders")

vert_files = shaders_path.glob("*.vert")
shaders = [x for x in shaders_path.glob("*.vert")]

# spirv
for shader in shaders:
    frag_path = shader.with_suffix(".frag")
    out_file_path = shader.with_suffix(".zig")
    vert_spv_path = shader.with_suffix(".vert.spv")
    frag_spv_path = shader.with_suffix(".frag.spv")

    if out_file_path.exists() and \
        shader.stat().st_mtime <= out_file_path.stat().st_mtime and \
        frag_path.exists() and frag_path.stat().st_mtime <= out_file_path.stat().st_mtime: continue

    sp.run(["glslangValidator", shader, 
            "-V",  # spirv binary
            "-o", vert_spv_path])

    if frag_path.exists(): sp.run(["glslangValidator", shader.with_suffix(".frag"), 
        "-V",  # spirv binary
        "-o", frag_spv_path])
    
    with open(out_file_path, "wt") as out_file:

        out_file.write(f"""\
const sdl = @import("sdl");

pub const vert_info = sdl.gpu.ShaderCreateInfo {{ 
    .code = &vert_code,
    .code_size = vert_code.len,
    .stage = .vertex,
    .entrypoint = "main",
    .format = .{{ .spirv = true }},
    .num_samplers = unreachable,
    .num_storage_buffers = unreachable,
    .num_storage_textures = unreachable,
    .num_uniform_buffers = unreachable,
}};

pub const frag_info = sdl.gpu.ShaderCreateInfo {{
    .code = &frag_code,
    .code_size = frag_code.len,
    .stage = .fragment,
    .entrypoint = "main",
    .format = .{{ .spirv = true }},
    .num_samplers = unreachable,
    .num_storage_buffers = unreachable,
    .num_storage_textures = unreachable,
    .num_uniform_buffers = unreachable,
}};
                    
""")

        byte_str = ""
        with open(vert_spv_path, "rb") as vert_spv: 
            byte_str = ", ".join([f"0x{chunk.hex()}" for chunk in iter(lambda: vert_spv.read(1), b"")])

        out_file.write(f"""\
pub const vert_code = [_]u8 {{
{fill(byte_str, initial_indent="    ", subsequent_indent="    ")}
}};

""")
        if frag_path.exists():
            with open(frag_spv_path, "rb") as frag_spv: 
                byte_str = ", ".join([f"0x{chunk.hex()}" for chunk in iter(lambda: frag_spv.read(1), b"")])

            out_file.write(f"""\
pub const frag_code = [_]u8 {{
{fill(byte_str, initial_indent="    ", subsequent_indent="    ")}
}};

""")

    os.remove(vert_spv_path)
    os.remove(frag_spv_path)
