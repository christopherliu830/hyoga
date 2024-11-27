import subprocess as sp
import os
import json
import binascii
from textwrap import fill
from pathlib import Path

cwd = Path(os.getcwd()).resolve()
shaders_path = cwd.joinpath("shaders")

vert_files = shaders_path.glob("*.slang")
shaders = [x for x in shaders_path.glob("*.slang")]

# spirv
for shader in shaders:
    vert_spv_path = shader.with_suffix(".vert.spv")
    frag_spv_path = shader.with_suffix(".frag.spv")
    resources_path = shader.with_suffix(".json")
    vert_resources = {}
    frag_resources = {}

    with open(resources_path) as resources_file:
        resources = json.load(resources_file)
        vert_resources = resources["vert"]
        frag_resources = resources["frag"]

    if vert_spv_path.exists() and \
        shader.stat().st_mtime <= vert_spv_path.stat().st_mtime and \
        resources_path.exists() and resources_path.stat().st_mtime <= vert_spv_path.stat().st_mtime: continue

    sp.run(["slangc", shader, 
            "-profile", "glsl_450",
            "-target", "spirv",
            "-entry", "vertexMain",
            "-o", shader.with_suffix(".vert.spv")])

    sp.run(["slangc", shader.with_suffix(".frag"), 
        "-profile", "glsl_450",
        "-target", "spirv",
        "-entry", "fragmentMain",
        "-o", shader.with_suffix(".vert.spv")])
    