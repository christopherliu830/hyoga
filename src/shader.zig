const std = @import("std");
const gl = @import("gl");

const ShaderType = enum(u32) {
    VERTEX = gl.VERTEX_SHADER,
    FRAGMENT = gl.FRAGMENT_SHADER,
};

pub const Module = struct {
    id: u32,

    pub const Builder = struct {
        path: [:0]const u8,
        shader_type: ShaderType,
    };

    pub fn create(builder: Builder) !Module {
        const file = try std.fs.cwd().openFile(builder.path, .{});
        defer file.close();

        var reader = std.io.bufferedReader(file.reader());
        const in_stream = reader.reader();
        var buffer: [4096]u8 = undefined;
        const size = try in_stream.readAll(&buffer);
        buffer[size] = 0;
        const data = buffer[0..size :0];

        var s: u32 = undefined;
        const s_type: c_uint = @intFromEnum(builder.shader_type);
        s = gl.CreateShader(s_type);
        gl.ShaderSource(s, 1, @ptrCast(&data), null);
        gl.CompileShader(s);

        var success: i32 = 0;
        gl.GetShaderiv(s, gl.COMPILE_STATUS, &success);

        if (success == 0) {
            logShaderModuleError(s);
            return error.ShaderCompileError;
        }
        return .{.id = s};
    }

    pub fn destroy(self: Module) void {
        gl.DeleteShader(self.id);
    }
};

pub const Program = struct {
    id: u32,

    pub fn use(self: Program) void {
        gl.UseProgram(self.id);
    }

    pub fn create(vs: Module, fs: Module) !Program {
        const id = gl.CreateProgram();
        gl.AttachShader(id, vs.id);
        gl.AttachShader(id, fs.id);
        gl.LinkProgram(id);
        var success: i32 = undefined;
        gl.GetProgramiv(id, gl.LINK_STATUS, &success);
        if (success == 0) {
            logShaderLinkError(id);
            return error.ShaderLinkError;
        }
        return .{.id = id};
    }

    pub fn set(self: Program, name: [*:0]const u8, value: anytype) void {
        self.use();
        switch(@typeInfo(@TypeOf(value))) {
            .Float => gl.Uniform1f(gl.GetUniformLocation(self.id, name), value),
            .Bool => gl.Uniform1i(gl.GetUniformLocation(self.id, name), @intFromBool(value)),
            .Int => gl.Uniform1i(gl.GetUniformLocation(self.id, name), value),
            .ComptimeInt => gl.Uniform1i(gl.GetUniformLocation(self.id, name), @as(i32, value)),
            .Vector => |vec| {
                switch (vec.len) {
                    4 => gl.Uniform4f(gl.GetUniformLocation(self.id, name), value[0], value[1], value[2], value[3]),
                    else => unreachable,
                }
            },
            else => unreachable,
        }
    }
};

pub fn logShaderModuleError(module: u32) void {
    var buffer = [_]u8{0} ** 512;
    var length: c_int = undefined;
    gl.GetShaderInfoLog(module, 512, &length, &buffer);
    buffer[@intCast(length)] = 0;
    std.log.err("OpenGL Shader Compile Error: {s}\n", .{buffer});
}

pub fn logShaderLinkError(program: u32) void {
    var buffer = [_]u8{0} ** 512;
    var length: c_int = undefined;
    gl.GetProgramInfoLog(program, 512, &length, &buffer);
    buffer[@intCast(length)] = 0;
    std.log.err("OpenGL Shader Link Error: {s}\n", .{buffer});
}

