const std = @import("std");
const gl = @import("gl");

const Handle = u32;

pub usingnamespace gl;

const OpenGlError = error{
    ShaderCompileError,
    ShaderLinkError,
};

/// Create a handle.
/// caller owns handle upon return.
pub fn createBuffer() !Handle {
    var handle: [1]u32 = undefined;
    gl.GenBuffers(1, &handle);
    // gl.BindBuffer(gl.ARRAY_BUFFER, @as(*[1]u8, &handle));
    // gl.BufferData(gl.ARRAY_BUFFER, @sizeOf(vertices), &vertices, gl.STATIC_DRAW);
    return handle[0];
}

pub fn createVao() !Handle {
    var handle: [1]u32 = undefined;
    gl.GenVertexArrays(1, &handle);
    return handle[0];
}

pub fn createShaderModule(string: [:0]const u8, shader_type: gl.@"enum") !Handle {
    const module: Handle = gl.CreateShader(shader_type);
    const strings = [_][*]const u8{string.ptr};
    gl.ShaderSource(module, 1, &strings, null);
    gl.CompileShader(module);

    var success: i32 = 0;
    gl.GetShaderiv(module, gl.COMPILE_STATUS, &success);
    if (success == 0) return logShaderModuleError(module);

    return module;
}

pub fn createShaderModuleFromFile(path: []const u8, shader_type: gl.@"enum") !Handle {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    var reader = std.io.bufferedReader(file.reader());
    const in_stream = reader.reader();
    var buffer: [4096:0]u8 = undefined;
    const size = try in_stream.readAll(&buffer);
    buffer[size] = 0;
    return createShaderModule(&buffer, shader_type);
}

pub fn createShaderProgram(vs: Handle, fs: Handle) !Handle {
    const program: Handle = gl.CreateProgram();
    gl.AttachShader(program, vs);
    gl.AttachShader(program, fs);
    gl.LinkProgram(program);
    var success: i32 = undefined;
    gl.GetProgramiv(program, gl.LINK_STATUS, &success);
    if (success == 0) return logShaderLinkError(program);
    return program;
}

pub fn logShaderModuleError(module: Handle) OpenGlError {
    var buffer = [_]u8{0} ** 512;
    gl.GetShaderInfoLog(module, 512, null, &buffer);
    std.log.err("OpenGL Shader Compile Error: {s}\n", .{buffer});
    return OpenGlError.ShaderCompileError;
}

pub fn logShaderLinkError(program: Handle) OpenGlError {
    var buffer = [_]u8{0} ** 512;
    gl.GetProgramInfoLog(program, 512, null, &buffer);
    std.log.err("OpenGL Shader Link Error: {s}\n", .{buffer});
    return OpenGlError.ShaderLinkError;
}
