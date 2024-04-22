const std = @import("std");
const gl = @import("gl");
const zigimg = @import("zigimg");
const stb = @import("stb_image.zig");

pub usingnamespace gl;

const OpenGlError = error{
    ShaderCompileError,
    ShaderLinkError,
};

const ArrayTarget = enum(u32) {
    ARRAY_BUFFER = gl.ARRAY_BUFFER,
    ELEMENT_ARRAY_BUFFER = gl.ELEMENT_ARRAY_BUFFER,
};

const BufferUsage = enum(u32) {
    STREAM_DRAW = gl.STREAM_DRAW,
    STATIC_DRAW = gl.STATIC_DRAW,
    DYNAMIC_DRAW = gl.DYNAMIC_DRAW,
};

const AttributeType = enum(u32) {
    FLOAT = gl.FLOAT,

    pub fn size(self: AttributeType) u32 {
        switch (self) {
            .FLOAT => return @sizeOf(f32),
        }
    }
};

const ShaderType = enum(u32) {
    VERTEX = gl.VERTEX_SHADER,
    FRAGMENT = gl.FRAGMENT_SHADER,
};

pub const Buffer = struct {
    id: u32,

    pub fn create() Buffer {
        var handle: u32 = undefined;
        gl.GenBuffers(1, @ptrCast(&handle));
        return .{ .id = handle };
    }

    pub fn upload(self: Buffer, data: anytype, target: ArrayTarget, usage: BufferUsage) void {
        const size = data.len * @sizeOf(@TypeOf(data[0]));
        gl.BindBuffer(@intFromEnum(target), self.id);
        gl.BufferData(@intFromEnum(target), size, data.ptr, @intFromEnum(usage));
    }

    pub fn destroy(self: Buffer) void {
        var handle = self.id;
        gl.DeleteBuffers(1, @ptrCast(&handle));
    }
};

pub const VertexArray = struct {
    id: u32,

    pub fn create() VertexArray {
        var handle: u32 = undefined;
        gl.GenVertexArrays(1, @ptrCast(&handle));
        return .{ .id = handle };
    }

    pub fn bind(self: VertexArray) void {
        gl.BindVertexArray(self.id);
    }

    pub fn destroy(self: VertexArray) void {
        var handle = self.id;
        gl.DeleteVertexArrays(1, @ptrCast(&handle));
    }
};

pub const VertexAttributes = struct {
    pub const Attribute = struct {
        size: u32 = 0,
        type: AttributeType = .FLOAT,
        normalized: bool = false,
    };

    attrs: [8]Attribute,
    n_attrs: u32 = 0,

    pub fn start() VertexAttributes {
        return .{ .attrs = undefined, .n_attrs = 0 };
    }

    pub fn add(self: *VertexAttributes, attr: Attribute) *VertexAttributes {
        self.attrs[self.n_attrs] = attr;
        self.n_attrs += 1;
        return self;
    }

    pub fn use(self: VertexAttributes) void {
        var offset: u32 = 0;
        var stride: u32 = 0;

        for (self.attrs[0..self.n_attrs]) |attr| {
            stride += attr.size * attr.type.size();
        }

        for (self.attrs[0..self.n_attrs], 0..self.n_attrs) |attr, i| {
            const normalized: u8 = if (attr.normalized) gl.TRUE else gl.FALSE;
            std.debug.print("{}, {}, {}, {}, {}, {}\n", .{ i, attr.size, attr.type, normalized, stride, offset });
            gl.VertexAttribPointer(@intCast(i), @intCast(attr.size), @intFromEnum(attr.type), normalized, @intCast(stride), offset);
            gl.EnableVertexAttribArray(@intCast(i));
            offset += attr.size * attr.type.size();
        }
    }
};

pub const Module = struct {
    id: u32,

    pub const Builder = struct {
        data: [:0]const u8,
        shader_type: ShaderType,
    };

    pub fn create(builder: Builder) !Module {
        var s: u32 = undefined;
        const s_type: c_uint = @intFromEnum(builder.shader_type);
        s = gl.CreateShader(s_type);
        gl.ShaderSource(s, 1, @ptrCast(&builder.data), null);
        gl.CompileShader(s);

        var success: i32 = 0;
        gl.GetShaderiv(s, gl.COMPILE_STATUS, &success);

        if (success == 0) {
            logShaderModuleError(s);
            return error.ShaderCompileError;
        }
        return .{ .id = s };
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
        return .{ .id = id };
    }

    pub fn set(self: Program, name: [*:0]const u8, value: anytype) void {
        self.use();
        switch (@typeInfo(@TypeOf(value))) {
            .Float => gl.Uniform1f(gl.GetUniformLocation(self.id, name), value),
            .Bool => gl.Uniform1i(gl.GetUniformLocation(self.id, name), @intFromBool(value)),
            .Int => gl.Uniform1i(gl.GetUniformLocation(self.id, name), value),
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

pub const Texture = struct {
    id: u32,

    pub fn create(data: []const u8) !Texture {
        var h: c_int = undefined;
        var w: c_int = undefined;
        var n_channels: c_int = undefined;
        const stbi_uc = stb.stbi_load_from_memory(data.ptr,
                                                 @intCast(data.len),
                                                 &h,
                                                 &w,
                                                 &n_channels,
                                                 0);
        if (stbi_uc == 0) return error.ImageLoadError;
        defer stb.stbi_image_free(stbi_uc);
        var id: u32 = undefined;
        gl.GenTextures(1, @ptrCast(&id));
        gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, w, h,
                      0, gl.RGB, gl.UNSIGNED_BYTE, stbi_uc);
        gl.GenerateMipmap(gl.TEXTURE_2D);
        return .{ .id = id };

    }

    pub fn bind(self: Texture) void {
        gl.BindTexture(gl.TEXTURE_2D, self.id);
    }

    pub fn destroy(self: Texture) void {
        var handle = self.id;
        gl.DeleteTextures(1, @ptrCast(&handle));
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
