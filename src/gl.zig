const std = @import("std");
const gl = @import("gl");

const Handle = u32;
const Buffer = u32;
const Vao = u32;

pub usingnamespace gl;

const OpenGlError = error{
    ShaderCompileError,
    ShaderLinkError,
};

/// Create a handle.
/// caller owns handle upon return.
pub fn createBuffer() Buffer {
    var handle: u32 = undefined;
    gl.GenBuffers(1, @ptrCast(&handle));
    return handle;
}

pub fn createVao() Vao {
    var handle: u32 = undefined;
    gl.GenVertexArrays(1, @ptrCast(&handle));
    return handle;
}
