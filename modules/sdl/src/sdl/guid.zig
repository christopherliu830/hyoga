pub const Guid = struct {
    data: [16]u8,
};

extern fn SDL_GUIDToString(guid: Guid, psz_guid: [*]u8, cb_guid: i32) void;
pub const guidToString = SDL_GUIDToString;

extern fn SDL_StringToGUID(psz_guid: [*]const u8) Guid;
pub const stringToGuid = SDL_StringToGUID;
