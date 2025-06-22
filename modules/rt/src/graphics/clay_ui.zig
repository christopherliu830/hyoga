const std = @import("std");
const hy = @import("hyoga-lib");
const hym = hy.math;
pub const clay = @import("clay");
const Gpu = @import("gpu.zig");
const Engine = @import("../engine.zig");
const Window = @import("../window.zig");
const Event = @import("sdl").Event;

pub const UI = struct {
    arena: clay.Arena,
    context: *clay.Context,
    dims: hym.Vec2 = .zero,
    gpu: *Gpu,
    window: *Window,
    capture_mouse: bool = false,
    hovered: bool = false,
    mouse_down: bool = false,
    mouse_clicked_outside: bool = false,
    mouse_position: hym.Vec2 = .zero,
    scroll_delta: hym.Vec2 = .zero,

    fn errorHandler(data: clay.ErrorData) callconv(.C) void {
        std.log.err("{}\n", .{data});
        @breakpoint();
    }

    pub fn create(allocator: std.mem.Allocator, gpu: *Gpu, window: *Window) !UI {
        const min_memory_size = clay.minMemorySize();
        const memory = try allocator.alloc(u8, min_memory_size);
        const arena = clay.createArenaWithCapacityAndMemory(memory);
        const context = clay.initialize(arena, .{ .w = 1920, .h = 1080 }, .{ .error_handler_function = errorHandler });
        clay.setMeasureTextFunction(*Gpu, gpu, measureText);

        return .{ .arena = arena, .context = context, .gpu = gpu, .window = window };
    }

    pub fn deinit(self: *UI, allocator: std.mem.Allocator) void {
        const memory = self.arena.memory[0..self.arena.capacity];
        allocator.free(memory);
    }

    pub fn processEvent(self: *UI, event: Event) !void {
        switch (event.type) {
            .mouse_motion => {
                const config = event.motion;
                self.mouse_position = .of(config.x, config.y);
            },
            .mouse_button_down => {
                const config = event.button;
                if (config.button == 1) {
                    self.mouse_down = true;
                    self.mouse_clicked_outside = !self.hovered;
                }
            },
            .mouse_button_up => {
                const config = event.button;
                if (config.button == 1) {
                    self.mouse_down = false;
                    self.mouse_clicked_outside = false;
                }
            },
            .mouse_wheel => {
                const config = event.wheel;
                self.scroll_delta = .of(config.x, config.y);
            },
            else => {},
        }
    }

    pub fn begin(self: *UI, delta_time: u64) void {
        clay.setCurrentContext(self.context);

        self.dims = self.window.dimensions();
        clay.setLayoutDimensions(.{ .w = self.dims.x(), .h = self.dims.y() });

        const mx = self.mouse_position.x();
        const my = self.mouse_position.y();
        clay.setPointerState(.{ .x = mx, .y = my }, self.mouse_down);
        clay.updateScrollContainers(true, @bitCast(self.scroll_delta), hym.nsTime(delta_time));
        const over = clay.getPointerOverIds();

        // Clay has a builtin root element, and
        // In most cases a second fullscreen element covers the whole screen.
        // So elements are hovered when there are > 2 hovered elements.
        self.hovered = over.len > 2;

        if (self.hovered and !self.mouse_clicked_outside) {
            self.capture_mouse = true;
        } else {
            self.capture_mouse = false;
        }

        clay.beginLayout(.center);
    }

    pub fn end(self: *UI) void {
        const gpu = self.gpu;

        // Setup viewport
        const l: f32 = 0;
        const r: f32 = self.dims.x();
        const t: f32 = self.dims.y();
        const b: f32 = 0;

        const transform: hym.Mat4 = .{ .m = .{
            .{ 2.0 / (r - l), 0, 0, 0 },
            .{ 0, 2.0 / (t - b), 0, 0 },
            .{ 0, 0, -1.0, 0 },
            .{ (r + l) / (l - r), (t + b) / (b - t), 0, 1.0 },
        } };

        const commands = clay.endLayout();

        for (commands) |command| {
            const box = command.bounding_box;

            const rect: hym.AxisAligned2D = .{
                .min = .of(box.x, self.dims.y() - (box.y + box.height)),
                .max = .of(box.x + box.width, self.dims.y() - box.y),
            };

            switch (command.command_type) {
                .rectangle => {
                    const config = &command.render_data.rectangle;
                    const color = @as(@Vector(4, f32), config.background_color) / [_]f32{ 256, 256, 256, 256 };
                    if (config.corner_radius.top_left > 0) {
                        drawRoundedRect(gpu, rect, config.corner_radius.top_left, config.background_color, transform);
                    } else {
                        drawRect(gpu, rect, color, transform);
                    }
                },
                .border => {
                    const config = &command.render_data.border;
                    const ex = rect.extents();

                    const min_radius = @min(ex.x(), ex.y()) / 2;
                    const color = @as(@Vector(4, f32), config.color) / [_]f32{ 256, 256, 256, 256 };

                    const clamped_radii: clay.CornerRadius = .{
                        .top_left = @min(config.corner_radius.top_left, min_radius),
                        .top_right = @min(config.corner_radius.top_right, min_radius),
                        .bottom_left = @min(config.corner_radius.bottom_left, min_radius),
                        .bottom_right = @min(config.corner_radius.bottom_right, min_radius),
                    };

                    if (config.width.left > 0) {
                        const top = rect.min.y() + clamped_radii.top_left;
                        const bot = rect.max.y() - clamped_radii.bottom_left;
                        const w: f32 = @floatFromInt(config.width.left);
                        drawRect(gpu, .{
                            .min = .of(rect.min.x(), top),
                            .max = .of(rect.min.x() + w, bot),
                        }, color, transform);
                    }

                    if (config.width.right > 0) {
                        const top = rect.min.y() + clamped_radii.top_right;
                        const bot = rect.max.y() - clamped_radii.bottom_right;
                        const w: f32 = @floatFromInt(config.width.right);
                        drawRect(gpu, .{
                            .min = .of(rect.max.x() - w, top),
                            .max = .of(rect.max.x(), bot),
                        }, color, transform);
                    }

                    if (config.width.bottom > 0) {
                        const left = rect.min.x() + clamped_radii.bottom_left;
                        const right = rect.max.x() - clamped_radii.bottom_right;
                        const h: f32 = @floatFromInt(config.width.bottom);
                        drawRect(gpu, .{
                            .min = .of(left, rect.min.y()),
                            .max = .of(right, rect.min.y() + h),
                        }, color, transform);
                    }

                    if (config.width.top > 0) {
                        const left = rect.min.x() + clamped_radii.top_left;
                        const right = rect.max.x() - clamped_radii.top_right;
                        const h: f32 = @floatFromInt(config.width.top);
                        drawRect(gpu, .{
                            .min = .of(left, rect.max.y() - h),
                            .max = .of(right, rect.max.y()),
                        }, color, transform);
                    }

                    if (config.corner_radius.top_left > 0) {
                        const center: hym.Vec2 = .of(rect.min.x() + clamped_radii.top_left, rect.max.y() - clamped_radii.top_left);
                        drawArc(gpu, center, clamped_radii.top_left, 90, 180, @floatFromInt(config.width.top), config.color, transform);
                    }

                    if (config.corner_radius.top_right > 0) {
                        const center: hym.Vec2 = .of(rect.max.x() - clamped_radii.top_right, rect.max.y() - clamped_radii.top_right);
                        drawArc(gpu, center, clamped_radii.top_right, 0, 90, @floatFromInt(config.width.top), config.color, transform);
                    }

                    if (config.corner_radius.bottom_left > 0) {
                        const center: hym.Vec2 = .of(rect.min.x() + clamped_radii.bottom_left, rect.min.y() + clamped_radii.bottom_left);
                        drawArc(gpu, center, clamped_radii.bottom_left, 180, 270, @floatFromInt(config.width.bottom), config.color, transform);
                    }

                    if (config.corner_radius.bottom_right > 0) {
                        const center: hym.Vec2 = .of(rect.max.x() - clamped_radii.bottom_right, rect.min.y() + clamped_radii.bottom_right);
                        drawArc(gpu, center, clamped_radii.bottom_right, 270, 360, @floatFromInt(config.width.bottom), config.color, transform);
                    }
                },
                .text => {
                    const config = &command.render_data.text;
                    const color = @as(@Vector(4, f32), config.text_color) / [_]f32{ 256, 256, 256, 256 };
                    const text_start: hym.Vec2 = .of(rect.min.x(), rect.max.y());
                    const scale_factor = @as(f32, @floatFromInt(config.font_size)) / gpu.textFontPtSize();
                    const scale: hym.Mat4 = hym.mat4.identity.scale(.of(scale_factor, scale_factor, scale_factor));
                    const text_transform = hym.mat4.identity
                        .mul(scale)
                        .mul(hym.mat4.identity.translate(text_start.append(0)))
                        .mul(transform);
                    gpu.im.drawText(config.string_contents.chars[0..@intCast(config.string_contents.length)], .{
                        .transform = text_transform,
                        .color = color,
                    });
                },
                .image => {
                    const config = &command.render_data.image;
                    const color = @as(@Vector(4, f32), config.background_color) / [_]f32{ 256, 256, 256, 256 };
                    drawRect(gpu, rect, color, transform);
                    const texture: Gpu.TextureHandle = .{ .value = @intCast(@intFromPtr(config.image_data)) };
                    const start = hym.vec2.create(rect.min.x(), rect.min.y());
                    const scale = hym.mat4.identity.scale(.of(rect.extents().x(), rect.extents().y(), 1));
                    const translate = hym.mat4.identity.translate(start.append(0));
                    const image_transform = hym.mat4.identity
                        .mul(scale)
                        .mul(translate)
                        .mul(transform);
                    gpu.im.drawImage(.{
                        .texture = texture,
                        .transform = image_transform,
                    });
                },
                .scissor_start => {
                    gpu.im.scissorBegin(.{
                        .x = @intFromFloat(box.x),
                        .y = @intFromFloat(box.y),
                        .w = @intFromFloat(box.width),
                        .h = @intFromFloat(box.height),
                    });
                },
                .scissor_end => {
                    gpu.im.scissorEnd();
                },
                else => {},
            }
        }
    }

    pub fn measureText(text: []const u8, config: *clay.TextElementConfig, gpu: *Gpu) clay.Dimensions {
        const scale_factor = @as(f32, @floatFromInt(config.font_size)) / gpu.textFontPtSize();
        const size = gpu.textSize(text).mul(scale_factor);
        return .{ .w = size.x(), .h = size.y() };
    }

    fn drawRect(gpu: *Gpu, box: hym.AxisAligned2D, color: [4]f32, transform: hym.Mat4) void {
        const ax = box.min.x();
        const ay = box.min.y();
        const bx = box.max.x();
        const by = box.max.y();

        const verts: []const Gpu.UIVertex = &.{
            .{ .pos = .{ ax, ay }, .color = color },
            .{ .pos = .{ bx, ay }, .color = color },
            .{ .pos = .{ bx, by }, .color = color },
            .{ .pos = .{ ax, by }, .color = color },
        };
        const indices: []const u32 = &.{ 0, 1, 2, 2, 3, 0 };
        gpu.im.drawVerts(verts, indices, .{ .transform = transform });
    }

    fn drawRoundedRect(gpu: *Gpu, box: hym.AxisAligned2D, corner_radius: f32, color: [4]f32, transform: hym.Mat4) void {
        const sin = std.math.sin;
        const cos = std.math.cos;
        var fixed_buffer: [8192]u8 = @splat(0);
        var fba: std.heap.FixedBufferAllocator = .init(&fixed_buffer);
        const allocator = fba.allocator();
        var verts: std.ArrayListUnmanaged(Gpu.UIVertex) = .empty;
        var indices: std.ArrayListUnmanaged(u32) = .empty;

        const min_radius = @min(box.extents().x(), box.extents().y()) / 2.0;
        const radius = @min(corner_radius, min_radius);

        // Outer == with border. Inner == without border
        // lrbt == left right bottom top
        const ol_x = box.min.x();
        const or_x = box.max.x();
        const ob_y = box.min.y();
        const ot_y = box.max.y();
        const il_x = ol_x + radius;
        const ir_x = or_x - radius;
        const ib_y = ob_y + radius;
        const it_y = ot_y - radius;

        // Main
        inline for (.{
            .{ il_x, ir_x, ib_y, it_y },
            .{ ol_x, il_x, ib_y, it_y },
            .{ ir_x, or_x, ib_y, it_y },
            .{ il_x, ir_x, ob_y, ib_y },
            .{ il_x, ir_x, it_y, ot_y },
        }) |iter| {
            const x1 = iter[0];
            const x2 = iter[1];
            const y1 = iter[2];
            const y2 = iter[3];
            const i: u32 = @intCast(verts.items.len);

            verts.appendSlice(allocator, &.{
                .{ .pos = .{ x1, y1 }, .color = color },
                .{ .pos = .{ x2, y1 }, .color = color },
                .{ .pos = .{ x2, y2 }, .color = color },
                .{ .pos = .{ x1, y2 }, .color = color },
            }) catch unreachable;
            indices.appendSlice(allocator, &.{ i + 0, i + 1, i + 2, i + 2, i + 3, i + 0 }) catch unreachable;
        }

        inline for (.{
            .{ box.min.x() + radius, box.max.y() - radius, 90, 180 },
            .{ box.max.x() - radius, box.max.y() - radius, 0, 90 },
            .{ box.min.x() + radius, box.min.y() + radius, 180, 270 },
            .{ box.max.x() - radius, box.min.y() + radius, 270, 360 },
        }) |iter| {
            const center_x = iter[0];
            const center_y = iter[1];
            const a = iter[2] * std.math.rad_per_deg;
            const b = iter[3] * std.math.rad_per_deg;

            const center_idx: u32 = @intCast(verts.items.len);
            verts.appendSlice(allocator, &.{
                .{ .pos = .{ center_x, center_y }, .color = color },
                .{ .pos = .{ center_x + cos(a) * radius, center_y + sin(a) * radius }, .color = color },
            }) catch unreachable;

            var t: f32 = 0.1;
            while (t <= 1) : (t += 0.1) {
                const i: u32 = @intCast(verts.items.len);
                const angle = (t + 0.1) * (b - a) + a;
                verts.appendSlice(allocator, &.{
                    .{
                        .pos = .{ center_x + cos(angle) * radius, center_y + sin(angle) * radius },
                        .color = color,
                    },
                }) catch unreachable;
                indices.appendSlice(allocator, &.{ center_idx, i - 1, i }) catch unreachable;
            }
        }

        gpu.im.drawVerts(verts.items, indices.items, .{ .transform = transform });
    }

    fn drawArc(
        gpu: *Gpu,
        center: hym.Vec2,
        radius: f32,
        angle_start: f32,
        angle_end: f32,
        thickness: f32,
        color: [4]f32,
        transform: hym.Mat4,
    ) void {
        const sin = std.math.sin;
        const cos = std.math.cos;
        var fixed_buffer: [4096]u8 = @splat(0);
        var fba: std.heap.FixedBufferAllocator = .init(&fixed_buffer);
        const allocator = fba.allocator();

        var verts: std.ArrayListUnmanaged(Gpu.UIVertex) = .empty;
        var indices: std.ArrayListUnmanaged(u32) = .empty;

        const a = angle_start * std.math.rad_per_deg;
        const b = angle_end * std.math.rad_per_deg;
        const in = radius - thickness;
        const out = radius;

        verts.appendSlice(allocator, &.{
            .{
                .pos = .{ center.x() + cos(a) * in, center.y() + sin(a) * in },
                .color = color,
            },
            .{
                .pos = .{ center.x() + cos(a) * out, center.y() + sin(a) * out },
                .color = color,
            },
        }) catch unreachable;

        var t: f32 = 0;
        while (t <= 1) : (t += 0.1) {
            const i: u32 = @intCast(verts.items.len);
            const next_angle = (t + 0.1) * (b - a) + a;
            verts.appendSlice(allocator, &.{
                .{
                    .pos = .{ center.x() + cos(next_angle) * in, center.y() + sin(next_angle) * in },
                    .color = color,
                },
                .{
                    .pos = .{ center.x() + cos(next_angle) * out, center.y() + sin(next_angle) * out },
                    .color = color,
                },
            }) catch unreachable;
            indices.appendSlice(allocator, &.{ i - 2, i, i - 1, i, i + 1, i - 1 }) catch unreachable;
        }

        gpu.im.drawVerts(verts.items, indices.items, .{ .transform = transform });
    }
};
