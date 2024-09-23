#!/bin/bash
## -V: create SPIR-V binary
## -x: save binary output as text-based 32-bit hexadecimal numbers
## -o: output file
glslangValidator -V -x -o imgui_shader.frag.u32 imgui_shader.frag
glslangValidator -V -x -o imgui_shader.vert.u32 imgui_shader.vert
