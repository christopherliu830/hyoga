const std = @import("std");
const gl = @import("gl");
const c = @import("./c.zig");

pub usingnamespace gl;

const OpenGlError = error {
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
        switch(self) {
            .FLOAT => return @sizeOf(f32),
        }
    }
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

    pub fn destroy(self: *Buffer) void {
        gl.DeleteBuffers(1, @ptrCast(&self.id));
    }
};

pub const VertexArray = struct {
    id: u32,

    pub fn create() VertexArray {
        var handle: u32 = undefined;
        gl.GenVertexArrays(1, @ptrCast(&handle));
        return .{ .id = handle };
    }

    pub fn bind(self: *VertexArray) void {
        gl.BindVertexArray(self.id);
    }

    pub fn destroy(self: *VertexArray) void {
        gl.DeleteVertexArrays(1, @ptrCast(&self.id));
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

        for(self.attrs[0..self.n_attrs]) |attr| {
            stride += attr.size * attr.type.size();
        }

        for(self.attrs[0..self.n_attrs], 0..self.n_attrs) |attr, i| {
            const normalized: u8 = if (attr.normalized) gl.TRUE else gl.FALSE;
            std.debug.print("{}, {}, {}, {}, {}, {}\n", .{i, attr.size, attr.type, normalized, stride, offset});
            gl.VertexAttribPointer(@intCast(i),
                                   @intCast(attr.size),
                                   @intFromEnum(attr.type),
                                   normalized,
                                   @intCast(stride),
                                   offset);
            gl.EnableVertexAttribArray(@intCast(i));
            offset += attr.size * attr.type.size();
        }
    }

};

const Texture = struct {
    id: u32,

    pub fn create(path: []const u8) !Texture {
        var handle: u32 = undefined;
        gl.GenTextures(1, @ptrCast(&handle));
        gl.BindTexture(gl.TEXTURE_2D, handle);

        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);

        var w: c_int = 0;
        var h: c_int = 0;
        var n_channels: c_int = 0;
        const data: *u8 = c.stbi_load(path, &w, &h, &n_channels, 0);
        defer c.stbi_image_free(data);

        gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, w, h, 0, gl.RGB, gl.UNSIGNED_BYTE, data);
        gl.GenerateMipmap(gl.TEXTURE_2D);

        return .{ .id = handle };
    }

};