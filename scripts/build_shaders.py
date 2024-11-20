import subprocess as sp
import os
import binascii
from textwrap import fill
from pathlib import Path

cwd = Path(os.getcwd()).resolve()
shaders_path = cwd.joinpath("src/hyoga/graphics/shaders")

vert_files = shaders_path.glob("*.vert")
shaders = [x for x in shaders_path.glob("*.vert")]

# spirv
for shader in shaders:
    frag_path = shader.with_suffix(".frag")
    out_file_path = shader.with_suffix(".zig")
    vert_spv_path = shader.with_suffix(".vert.spv")
    frag_spv_path = shader.with_suffix(".frag.spv")
    resources_path = shader.with_suffix(".rsl")
    vert_resources = {}
    frag_resources = {}

    if resources_path.exists():
        with open(resources_path, 'rt') as rs_file:
            mode = ''
            for line in rs_file:
                line = line.strip()
                if line == 'vert': mode = 'vert'
                elif line == 'frag': mode = 'frag'
                else:
                    key, val = line.split('=')
                    if mode == 'vert': vert_resources[key] = val
                    if mode == 'frag': frag_resources[key] = val

    if out_file_path.exists() and \
        shader.stat().st_mtime <= out_file_path.stat().st_mtime and \
        frag_path.exists() and frag_path.stat().st_mtime <= out_file_path.stat().st_mtime and \
        resources_path.exists() and resources_path.stat().st_mtime <= out_file_path.stat().st_mtime: continue

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
    .num_samplers = {vert_resources["samplers"]},
    .num_storage_buffers = {vert_resources["storage_buffers"]},
    .num_storage_textures = {vert_resources["storage_textures"]},
    .num_uniform_buffers = {vert_resources["uniform_buffers"]},
}};

pub const frag_info = sdl.gpu.ShaderCreateInfo {{
    .code = &frag_code,
    .code_size = frag_code.len,
    .stage = .fragment,
    .entrypoint = "main",
    .format = .{{ .spirv = true }},
    .num_samplers = {frag_resources["samplers"]},
    .num_storage_buffers = {frag_resources["storage_buffers"]},
    .num_storage_textures = {frag_resources["storage_textures"]},
    .num_uniform_buffers = {frag_resources["uniform_buffers"]},
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
