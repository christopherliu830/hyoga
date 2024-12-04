import subprocess as sp
import os
import sys
import json
import binascii
from textwrap import fill
from pathlib import Path

cwd = Path(os.getcwd()).resolve()
shaders_path = cwd.joinpath("shaders")

vert_files = shaders_path.glob("*.slang")
shaders = [x for x in shaders_path.glob("*.slang")]

sys.stderr.write(str(sys.argv))

# spirv
for shader in shaders:
    vert_spv_path = str(shader).split('.')[0] + (".vert.spv")
    frag_spv_path = str(shader).split('.')[0] + (".frag.spv")
    resources_path = str(shader).split('.')[0] + (".rsl.json")
    vert_resources = {}
    frag_resources = {}

    with open(resources_path) as resources_file:
        resources = json.load(resources_file)
        vert_resources = resources["vert"]
        frag_resources = resources["frag"]

    # if vert_spv_path.exists() and \
    #     shader.stat().st_mtime <= vert_spv_path.stat().st_mtime and \
    #     resources_path.exists() and resources_path.stat().st_mtime <= vert_spv_path.stat().st_mtime: continue


    sp.run(["slangc", shader, 
            "-target", "spirv",
            "-entry", "vertexMain",
            "-o", str(Path(sys.argv[1]).joinpath(shader.with_suffix(".vert.spv").name))])

    sp.run(["slangc", shader, 
        "-target", "spirv",
        "-entry", "fragmentMain",
        "-o", str(Path(sys.argv[1]).joinpath(shader.with_suffix(".frag.spv").name))])
    