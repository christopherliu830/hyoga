import subprocess as sp
import os
import json
import binascii
from textwrap import fill
from pathlib import Path

cwd = Path(os.getcwd()).resolve()
shaders_path = cwd.joinpath("shaders")

vert_files = shaders_path.glob("*.vert")
shaders = [x for x in shaders_path.glob("*.vert")]

# spirv
for shader in shaders:
    frag_path = shader.with_suffix(".frag")
    out_file_path = shader.with_suffix(".zig")
    vert_spv_path = shader.with_suffix(".vert.spv")
    frag_spv_path = shader.with_suffix(".frag.spv")
    resources_path = shader.with_suffix(".json")
    vert_resources = {}
    frag_resources = {}

    with open(resources_path) as resources_file:
        resources = json.load(resources_file)
        vert_resources = resources["vert"]
        frag_resources = resources["frag"]

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
    