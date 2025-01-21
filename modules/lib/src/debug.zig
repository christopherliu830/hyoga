const std = @import("std");

/// Handle OOM by crashing.
pub inline fn oom() noreturn {
    std.debug.panic("out of memory", .{});
}

pub fn singlePointerChild(T: type) type {
    const info = @typeInfo(T);
    std.debug.assert(info.pointer.size == .One);
    return info.pointer.child;
}

pub fn assertMatches(comptime A: type, comptime B: type) void {
    switch (@typeInfo(A)) {
        .@"struct" => assertStructMatches(A, B),
        .@"enum" => assertEnumMatches(A, B),
        else => @compileError("not implemented"),
    }
}

pub fn assertEnumMatches(comptime A: type, comptime B: type) void {
    for (
        std.meta.fields(A),
        std.meta.fields(B),
    ) |a_field, b_field| {
        if (!std.mem.eql(u8, a_field.name, b_field.name)) {
            @compileError(std.fmt.comptimePrint("{s} has tag {s}" ++
                "while {s} has tag {s}", .{
                @typeName(A),
                a_field.name,
                @typeName(B),
                b_field.name,
            }));
        }
    }

    return;
}

pub fn assertStructMatches(comptime A: type, comptime B: type) void {
    for (
        std.meta.fields(A),
    ) |a_field| {
        if (@offsetOf(A, a_field.name) != @offsetOf(B, a_field.name)) {
            @compileError(std.fmt.comptimePrint(
                "struct {s} has field {s} at {} " ++
                    "while struct {s} has field {s} at {}",
                .{
                    @typeName(A),
                    a_field.name,
                    @offsetOf(A, a_field.name),
                    @typeName(B),
                    a_field.name,
                    @offsetOf(B, a_field.name),
                },
            ));
        }
    }

    if (@sizeOf(A) != @sizeOf(B)) {
        @compileError(std.fmt.comptimePrint(
            "struct {s} has size of {} " ++
                "while struct {s} has size of {}",
            .{
                @typeName(A),
                @sizeOf(A),
                @typeName(B),
                @sizeOf(B),
            },
        ));
    }
}
