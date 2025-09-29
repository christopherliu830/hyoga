pub const Strint = opaque {
    pub const ID = u32;

    pub fn from(self: *Strint, str: []const u8) ID {
        return hysidFrom(self, str.ptr, str.len);
    }

    pub fn asString(self: *Strint, id: ID) []const u8 {
        const len: usize = undefined;
        const ptr = hysidAsString(self, id, &len);
        return ptr[0..len];
    }

    pub fn asStringZ(self: *Strint, id: ID) [:0]const u8 {
        const len: usize = undefined;
        const ptr = hysidAsStringZ(self, id, &len);
        return ptr[0..len];
    }
};

extern fn hysidFrom(*Strint, str: [*]const u8, len: usize) Strint.ID;
extern fn hysidAsString(*Strint, Strint.ID, *usize) [*]const u8;
extern fn hysidAsStringZ(*Strint, Strint.ID, *usize) [*]const u8;
