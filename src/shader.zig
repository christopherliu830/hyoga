const std = @import("std");
const gl = @import("gl");

const Shader = u32;
const Program = u32;

const ShaderType = enum(u32) {
    VERTEX = gl.VERTEX_SHADER,
    FRAGMENT = gl.FRAGMENT_SHADER,
};

const ShaderCreate = struct {
    path: [:0]const u8,
    shader_type: ShaderType,
};

pub fn logShaderModuleError(module: u32) void {
    var buffer = [_]u8{0} ** 512;
    gl.GetShaderInfoLog(module, 512, null, &buffer);
    std.log.err("OpenGL Shader Compile Error: {s}\n", .{buffer});
}

pub fn logShaderLinkError(program: u32) void {
    var buffer = [_]u8{0} ** 512;
    gl.GetProgramInfoLog(program, 512, null, &buffer);
    std.log.err("OpenGL Shader Link Error: {s}\n", .{buffer});
}

pub fn createShaderModule(info: ShaderCreate) !Shader {
    const file = try std.fs.cwd().openFile(info.path, .{});
    defer file.close();

    var reader = std.io.bufferedReader(file.reader());
    const in_stream = reader.reader();
    var buffer: [4096]u8 = undefined;
    const size = try in_stream.readAll(&buffer);
    buffer[size] = 0;
    const data = buffer[0..size :0];

    var s: Shader = undefined;
    const s_type: c_uint = @intFromEnum(info.shader_type);
    s = gl.CreateShader(s_type);
    gl.ShaderSource(s, 1, @ptrCast(&data), null);
    gl.CompileShader(s);

    var success: i32 = 0;
    gl.GetShaderiv(s, gl.COMPILE_STATUS, &success);

    if (success == 0) {
        logShaderModuleError(s);
        return error.ShaderCompileError;
    }

    return s;
}

pub fn createShaderProgram(vs: Shader, fs: Shader) !Program {
    const program = gl.CreateProgram();
    gl.AttachShader(program, vs);
    gl.AttachShader(program, fs);
    gl.LinkProgram(program);
    var success: i32 = undefined;
    gl.GetProgramiv(program, gl.LINK_STATUS, &success);
    if (success == 0) {
        logShaderLinkError(program);
        return error.ShaderLinkError;
    }
    return program;
}