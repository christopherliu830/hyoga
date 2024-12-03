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

    print(shader)


    # metal entry
    metal_vert_shader = str(shader).split(".")[0] + ".metal.vert.slang"
    is_metal = str(shader).split(".")[1] == "metal"
    if Path(metal_vert_shader).exists() and is_metal:
        sp.run(["slangc", metal_vert_shader, 
                "-target", "metal",
                "-entry", "vertexMain",
                "-o", str(shader).split(".")[0] + (".vert.metal")])

        metal_frag_shader = str(shader).split(".")[0] + ".metal.frag.slang"
        if Path(metal_frag_shader).exists() and is_metal:
            sp.run(["slangc", metal_frag_shader, 
                    "-target", "metal",
                    "-entry", "fragmentMain",
                    "-o", str(shader).split(".")[0] + (".frag.metal")])
    else:
        sp.run(["slangc", shader, 
                "-profile", "spirv_1_3",
                "-target", "spirv",
                "-entry", "vertexMain",
                "-o", shader.with_suffix(".vert.spv")])

        sp.run(["slangc", shader, 
            "-profile", "spirv_1_3",
            "-target", "spirv",
            "-entry", "fragmentMain",
            "-o", shader.with_suffix(".frag.spv")])
    