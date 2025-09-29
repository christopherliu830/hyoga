const std = @import("std");
const Type = std.builtin.Type;

pub const ArrayGroupField = struct {
    name: []const u8,
    field: type,
};

/// ArrayList requires a .default value
pub fn ArrayGroup(
    ArrayList: fn (type) type,
    comptime initializer: anytype,
) type {
    const fields = @typeInfo(@TypeOf(initializer)).@"struct".fields;
    var array_types: [fields.len]Type.StructField = undefined;
    inline for (fields, 0..) |field, i| {
        const Elem = field.defaultValue().?;
        const default = ArrayList(Elem).default;
        array_types[i] = .{
            .name = field.name,
            .type = ArrayList(Elem),
            .default_value_ptr = &default,
            .is_comptime = false,
            .alignment = @alignOf(ArrayList(Elem)),
        };
    }

    var enum_tags: [fields.len]Type.EnumField = undefined;
    for (fields, 0..) |field, i| {
        enum_tags[i] = .{
            .name = field.name,
            .value = i,
        };
    }

    const Arrays = @Type(.{ .@"struct" = .{
        .layout = .auto,
        .decls = &.{},
        .is_tuple = false,
        .fields = &array_types,
    } });

    const TagType = @Type(.{ .@"enum" = .{
        .tag_type = u32,
        .decls = &.{},
        .is_exhaustive = true,
        .fields = &enum_tags,
    } });

    return struct {
        arrays: Arrays = .{},

        /// The field of the initializer
        /// ie initializer of { .a = f32, .b = f32 }
        /// will give Tag { a, b }
        pub const Tag = TagType;

        pub fn get(self: *@This(), comptime tag: Tag) *ArrayType(tag) {
            return &@field(self.arrays, @tagName(tag));
        }

        pub fn ArrayType(comptime tag: Tag) type {
            const array_fields = std.meta.fields(Arrays);
            return array_fields[@intFromEnum(tag)].type;
        }

        pub fn Field(comptime tag: Tag) type {
            return fields[@intFromEnum(tag)].defaultValue().?;
        }
    };
}
