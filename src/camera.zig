const std = @import("std");
const input = @import("input.zig");
const vec3 = @import("hym/vec3.zig");

pub const Camera = struct {
    position: vec3.Vec3 = vec3.zero,

    pub fn registerInputs(self: *Camera) !void {
        try input.bind(input.keycode.d, .{ .name = "translateUp", .ctx = self, .handler = translateUp });
        try input.bind(input.keycode.f, .{ .name = "translateDown", .ctx = self, .handler = translateDown });
        try input.bind(input.keycode.s, .{ .name = "translateLeft", .ctx = self, .handler = translateLeft });
        try input.bind(input.keycode.g, .{ .name = "translateRight", .ctx = self, .handler = translateRight });
        try input.bind(input.keycode.t, .{ .name = "translateForward", .ctx = self, .handler = translateForward });
        try input.bind(input.keycode.b, .{ .name = "translateBack", .ctx = self, .handler = translateBack });        
    }
};

fn translateLeft(ctx: ?*anyopaque) void {
    const cam: *Camera = @ptrCast(@alignCast(ctx.?));
    cam.position.add(vec3.create(-1, 0, 0));
    std.log.debug("{}", .{cam.position.v});

}

fn translateUp(ctx: ?*anyopaque) void {
    const cam: *Camera = @ptrCast(@alignCast(ctx.?));
    std.log.debug("up", .{});
    cam.position.add(vec3.create(0, 1, 0));
    std.log.debug("{}", .{cam.position.v});

}

fn translateDown(ctx: ?*anyopaque) void {
    const cam: *Camera = @ptrCast(@alignCast(ctx.?));
    std.log.debug("down", .{});
    cam.position.add(vec3.create(0, -1, 0));
    std.log.debug("{}", .{cam.position.v});

}

fn translateRight(ctx: ?*anyopaque) void {
    const cam: *Camera = @ptrCast(@alignCast(ctx.?));
    std.log.debug("right", .{});
    cam.position.add(vec3.create(1, 0, 0));
    std.log.debug("{}", .{cam.position.v});

}

fn translateForward(ctx: ?*anyopaque) void {
    const cam: *Camera = @ptrCast(@alignCast(ctx.?));
    std.log.debug("fwd", .{});
    cam.position.add(vec3.create(0, 0, -1));
    std.log.debug("{}", .{cam.position.v});

}

fn translateBack(ctx: ?*anyopaque) void {
    const cam: *Camera = @ptrCast(@alignCast(ctx.?));
    std.log.debug("back", .{});
    cam.position.add(vec3.create(0, 0, 1));
    std.log.debug("{}", .{cam.position.v});

}
