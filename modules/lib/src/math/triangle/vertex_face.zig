const std = @import("std");
const hym = @import("../math.zig");

const root = @import("root.zig");
const funcs = @import("funcs.zig");
const VertexHandle = root.VertexHandle;
const determinant = funcs.determinant;

const log = std.log.scoped(.math);

pub const Triangle = struct {
    neighbor: [3]Ref,
    vertices: [3]VertexHandle = @splat(.none),
    constraints: [3]bool = @splat(false),
    visited: bool = false,

    pub const Ref = packed struct(usize) {
        rot: u2 = 0,
        triangle: u62,

        pub const none: Ref = .{ .rot = 0, .triangle = 0 };

        pub fn valid(self: Ref) bool {
            return self.triangle != 0;
        }

        pub fn format(value: Ref, writer: *std.io.Writer) !void {
            if (!value.valid()) {
                try writer.writeAll("(*)");
                return;
            }
            try writer.writeAll("(");
            if (value.org() != .none) try writer.printInt(@intFromEnum(value.org()), 10, .lower, .{}) else try writer.writeAll("*");
            try writer.writeAll(" ");
            if (value.dest() != .none) try writer.printInt(@intFromEnum(value.dest()), 10, .lower, .{}) else try writer.writeAll("*");
            try writer.writeAll(" ");
            if (value.apex() != .none) try writer.printInt(@intFromEnum(value.apex()), 10, .lower, .{}) else try writer.writeAll("*");
            try writer.writeAll(")");
            if (value.constrained()) {
                try writer.writeAll(" C");
            }
        }

        fn init(ptr: *Triangle) Triangle.Ref {
            var ref: Triangle.Ref = @bitCast(@intFromPtr(ptr));
            ref.rot = 0;
            return ref;
        }

        fn deref(self: Ref) *Triangle {
            return @ptrFromInt(@as(usize, @bitCast(@as(u64, self.triangle << 2))));
        }

        pub fn sym(self: Ref) Ref {
            return self.deref().neighbor[self.rot];
        }

        pub fn lnext(self: Ref) Ref {
            return .{ .triangle = self.triangle, .rot = switch (self.rot) {
                0 => 1,
                1 => 2,
                2 => 0,
                3 => unreachable,
            } };
        }

        pub fn lprev(self: Ref) Ref {
            return .{ .triangle = self.triangle, .rot = switch (self.rot) {
                0 => 2,
                1 => 0,
                2 => 1,
                3 => unreachable,
            } };
        }

        fn onext(self: Ref) Ref {
            return self.lprev().sym();
        }

        fn oprev(self: Ref) Ref {
            return self.sym().lnext();
        }

        fn dnext(self: Ref) Ref {
            return self.sym().lprev();
        }

        fn dprev(self: Ref) Ref {
            return self.lnext().sym();
        }

        fn rnext(self: Ref) Ref {
            return self.sym().lnext().sym();
        }

        fn rprev(self: Ref) Ref {
            return self.sym().lprev().sym();
        }

        pub fn apex(self: Ref) VertexHandle {
            return self.deref().vertices[self.rot];
        }

        fn apexSet(self: Ref, a: VertexHandle) void {
            self.deref().vertices[self.rot] = a;
        }

        pub fn org(self: Ref) VertexHandle {
            return self.deref().vertices[
                switch (self.rot) {
                    0 => 1,
                    1 => 2,
                    2 => 0,
                    3 => unreachable,
                }
            ];
        }

        fn orgSet(self: Ref, a: VertexHandle) void {
            self.deref().vertices[
                switch (self.rot) {
                    0 => 1,
                    1 => 2,
                    2 => 0,
                    3 => unreachable,
                }
            ] = a;
        }

        pub fn dest(self: Ref) VertexHandle {
            return self.deref().vertices[
                switch (self.rot) {
                    0 => 2,
                    1 => 0,
                    2 => 1,
                    3 => unreachable,
                }
            ];
        }

        fn destSet(self: Ref, a: VertexHandle) void {
            self.deref().vertices[
                switch (self.rot) {
                    0 => 2,
                    1 => 0,
                    2 => 1,
                    3 => unreachable,
                }
            ] = a;
        }

        fn neighborSet(self: Ref, t: Ref) void {
            self.deref().neighbor[self.rot] = t;
        }

        fn connect(self: Ref, other: Ref) void {
            self.neighborSet(other);
            other.neighborSet(self);

            if (other.constrained() or self.constrained()) {
                self.constrainedSet(true);
                other.constrainedSet(true);
            }
        }

        fn connectWithoutConstraint(self: Ref, other: Ref) void {
            self.neighborSet(other);
            other.neighborSet(self);
        }

        pub fn constrained(self: Ref) bool {
            return self.deref().constraints[self.rot];
        }

        fn constrainedSet(self: Ref, toggle: bool) void {
            self.deref().constraints[self.rot] = toggle;
        }
    };

    const Pool = std.heap.MemoryPool(Triangle);
};

pub fn CDT(T: type, Context: type) type {
    return struct {
        const Self = @This();

        allocator: std.mem.Allocator,
        scratch: std.heap.ArenaAllocator,
        pool: std.heap.MemoryPool(Triangle),
        left_edge: Triangle.Ref,
        right_edge: Triangle.Ref,
        vertices: std.ArrayListUnmanaged(Slot) = .empty,
        free_list: ?usize = null,

        const Slot = union {
            data: T,
            next: usize,
        };

        pub const f32_tolerance = 64 * std.math.floatEps(f32);

        pub fn init(allocator: std.mem.Allocator, initial_vertices: []const T) !Self {
            var sd: Self = .{
                .allocator = allocator,
                .scratch = .init(allocator),
                .pool = .init(allocator),
                .left_edge = .none,
                .right_edge = .none,
            };

            _ = try sd.triangulate(initial_vertices);

            return sd;
        }

        pub fn deinit(self: *Self) void {
            self.scratch.deinit();
            self.vertices.deinit(self.allocator);
            self.pool.deinit();
        }

        pub fn position(self: *const Self, h: VertexHandle) hym.Vec2 {
            return Context.position(self.unwrap(h));
        }

        pub fn unwrap(self: *const Self, h: VertexHandle) T {
            return self.vertices.items[h.unwrap()].data;
        }

        pub fn triangulate(self: *Self, initial_vertices: []const T) ![2]Triangle.Ref {
            const gpa = self.allocator;

            const dupe = try gpa.dupe(T, initial_vertices);
            defer gpa.free(dupe);

            std.sort.heap(T, dupe, {}, Context.lessThan);

            // Remove duplicate points
            for (dupe) |vertex| {
                if (self.vertices.items.len == 0 or
                    !Context.eql(vertex, self.vertices.getLast().data))
                {
                    try self.vertices.append(gpa, .{ .data = vertex });
                } else continue;
            }

            std.debug.assert(self.vertices.items.len > 2);

            const l, const r = try self.triangulateRecursive(0, self.vertices.items.len);
            self.left_edge = l;
            self.right_edge = r;

            return .{ l, r };
        }

        /// Returns two edges, left (0) and right (1). Left is an edge
        /// with org of the leftmost (or bottommost, in case of ties) vertex and
        /// a null dest. Right is an outside edge with dest of the rightmost (or topmost)
        /// vertex and a null org.
        fn triangulateRecursive(self: *Self, l: usize, r: usize) ![2]Triangle.Ref {
            const len = r - l;
            if (len == 2) {
                const left = try self.triangleMake(.{
                    .org = .make(l),
                    .dest = .make(l + 1),
                    .apex = .none,
                });

                const right = try self.triangleMake(.{
                    .org = .make(l + 1),
                    .dest = .make(l),
                    .apex = .none,
                });

                left.connect(right);
                left.lprev().connect(right.lnext());
                left.lnext().connect(right.lprev());

                return .{ right.lnext(), right.lprev() };
            } else if (len == 3) {
                const s1: VertexHandle = .make(l);
                const s2: VertexHandle = .make(l + 1);
                const s3: VertexHandle = .make(l + 2);
                const det = self.determinant(s1, s2, s3);

                if (det == 0.0) {
                    const a = try self.triangleMake(.{ .org = s1, .dest = s2, .apex = .none });
                    const b = try self.triangleMake(.{ .org = s2, .dest = s1, .apex = .none });
                    const c = try self.triangleMake(.{ .org = s2, .dest = s3, .apex = .none });
                    const d = try self.triangleMake(.{ .org = s3, .dest = s2, .apex = .none });

                    a.connect(b);
                    c.connect(d);

                    a.lnext().connect(c.lprev());
                    b.lprev().connect(d.lnext());
                    a.lprev().connect(b.lnext());
                    c.lnext().connect(d.lprev());
                    return .{ b.lnext(), d.lprev() };
                } else {
                    const a, const b, const c, const x = blk: {
                        if (det > 0.0) {
                            // Counter-clockwise
                            break :blk .{
                                try self.triangleMake(.{ .org = s2, .dest = s1, .apex = .none }),
                                try self.triangleMake(.{ .org = s3, .dest = s2, .apex = .none }),
                                try self.triangleMake(.{ .org = s1, .dest = s3, .apex = .none }),
                                try self.triangleMake(.{ .org = s1, .dest = s2, .apex = s3 }),
                            };
                        } else {
                            // Clockwise
                            break :blk .{
                                try self.triangleMake(.{ .org = s1, .dest = s2, .apex = .none }),
                                try self.triangleMake(.{ .org = s3, .dest = s1, .apex = .none }),
                                try self.triangleMake(.{ .org = s2, .dest = s3, .apex = .none }),
                                try self.triangleMake(.{ .org = s2, .dest = s1, .apex = s3 }),
                            };
                        }
                    };

                    x.connect(a);
                    x.lnext().connect(b);
                    x.lprev().connect(c);

                    a.lprev().connect(b.lnext());
                    b.lprev().connect(c.lnext());
                    c.lprev().connect(a.lnext());

                    if (det > 0.0) {
                        return .{ a.lnext(), b.lprev() };
                    } else {
                        return .{ b.lnext(), b.lprev() };
                    }
                }
            } else {
                const mid = (r + l) / 2;
                // ldi has dest @ to rightmost, (then topmost) point on left side
                // rdi has org @ to leftmost (then bottommost) point on right side
                var ldo, var ldi = try self.triangulateRecursive(l, mid);
                var rdi, var rdo = try self.triangulateRecursive(mid, r);

                while (true) {
                    const ldi_dest = self.position(ldi.dest());
                    const ldi_apex = self.position(ldi.apex());
                    const rdi_org = self.position(rdi.org());
                    const rdi_apex = self.position(rdi.apex());
                    if (funcs.rightOf(rdi_org, ldi_apex, ldi_dest)) {
                        ldi = ldi.lprev().sym();
                    } else if (funcs.leftOf(ldi_dest, rdi_apex, rdi_org)) {
                        rdi = rdi.lnext().sym();
                    } else {
                        break;
                    }
                }

                var lcand = ldi.sym();
                var rcand = rdi.sym();

                var basel = try self.triangleMake(.{
                    .org = rdi.org(),
                    .dest = ldi.dest(),
                    .apex = .none,
                });

                basel.lnext().connect(ldi);
                basel.lprev().connect(rdi);

                if (ldi.dest() == ldo.org()) {
                    ldo = basel.lnext();
                }
                if (rdi.org() == rdo.dest()) {
                    rdo = basel.lprev();
                }

                var lower_left = ldi.dest();
                var lower_right = rdi.org();
                var upper_left = lcand.apex();
                var upper_right = rcand.apex();

                while (true) {
                    const l_valid = funcs.leftOf(self.position(upper_left), self.position(lower_left), self.position(lower_right));
                    const r_valid = funcs.leftOf(self.position(upper_right), self.position(lower_left), self.position(lower_right));

                    if (!l_valid and !r_valid) {
                        const top = try self.triangleMake(.{
                            .org = lower_left,
                            .dest = lower_right,
                            .apex = .none,
                        });
                        top.connect(basel);
                        top.lnext().connect(rcand);
                        top.lprev().connect(lcand);

                        return .{ ldo, rdo };
                    }

                    if (l_valid) {
                        // Flip lower_left->upper_left edge if it needs to be deleted.
                        var next_edge = lcand.lprev().sym();
                        var next_apex = next_edge.apex();

                        if (next_apex != .none) {
                            var edge_needs_flip = self.incircle(
                                lower_left,
                                lower_right,
                                upper_left,
                                next_apex,
                            );

                            while (edge_needs_flip) {
                                next_edge = next_edge.lnext();
                                const top_casing = next_edge.sym();
                                const side_casing = next_edge.lnext().sym();
                                const outer_casing = lcand.lnext().sym();

                                // Delete the edge by re-stitching the two triangles

                                //  Previously connected here to side_casing
                                next_edge.lnext().connect(top_casing);

                                // Previously connected here to ldi
                                lcand.connect(side_casing);

                                lcand = lcand.lnext();

                                // Previously connected here to top_casing
                                next_edge.connect(outer_casing);

                                lcand.orgSet(lower_left);
                                lcand.apexSet(next_apex);
                                lcand.destSet(.none);
                                next_edge.orgSet(.none);
                                next_edge.destSet(upper_left);
                                next_edge.apexSet(next_apex);

                                upper_left = next_apex;
                                next_edge = side_casing;
                                next_apex = next_edge.apex();

                                if (next_apex != .none) {
                                    edge_needs_flip = self.incircle(
                                        lower_left,
                                        lower_right,
                                        upper_left,
                                        next_apex,
                                    );
                                } else {
                                    edge_needs_flip = false;
                                }
                            }
                        }
                    }

                    if (r_valid) {
                        // Flip lower_right->upper_right edge if it needs to be deleted.
                        var next_edge = rcand.lnext().sym();
                        var next_apex = next_edge.apex();

                        if (next_apex != .none) {
                            var edge_needs_flip = self.incircle(
                                lower_left,
                                lower_right,
                                upper_right,
                                next_apex,
                            );

                            while (edge_needs_flip) {
                                next_edge = next_edge.lprev();
                                const top_casing = next_edge.sym();
                                const side_casing = next_edge.lprev().sym();
                                const outer_casing = rcand.lprev().sym();

                                // Delete the edge by re-stitching the two triangles

                                //  Previously connected here to side_casing
                                next_edge.lprev().connect(top_casing);

                                // Previously connected here to rdi or basel
                                rcand.connect(side_casing);

                                rcand = rcand.lprev();
                                // 0: outer_casing
                                // 1: side
                                // 2: next_edge

                                // Previously connected here to top_casing
                                next_edge.connect(outer_casing);

                                rcand.orgSet(.none);
                                rcand.destSet(lower_right);
                                rcand.apexSet(next_apex);
                                next_edge.orgSet(upper_right);
                                next_edge.destSet(.none);
                                next_edge.apexSet(next_apex);

                                upper_right = next_apex;
                                next_edge = side_casing;
                                next_apex = next_edge.apex();

                                if (next_apex != .none) {
                                    edge_needs_flip = self.incircle(
                                        lower_left,
                                        lower_right,
                                        upper_right,
                                        next_apex,
                                    );
                                } else {
                                    edge_needs_flip = false;
                                }
                            }
                        }
                    }

                    if (!l_valid or (r_valid and self.incircle(upper_left, lower_left, lower_right, upper_right))) {
                        basel.connect(rcand); // Bottom triangle is connected to right ghost triangle
                        basel = rcand.lprev(); // Base is moved up
                        basel.destSet(lower_left); // Right ghost triangle is extended down to lower_left
                        lower_right = upper_right;
                        rcand = basel.sym();
                        upper_right = rcand.apex();
                    } else {
                        basel.connect(lcand);
                        basel = lcand.lnext();
                        basel.orgSet(lower_right);
                        lower_left = upper_left;
                        lcand = basel.sym();
                        upper_left = lcand.apex();
                    }
                }
            }
            return .{ undefined, undefined };
        }

        pub fn insert(self: *Self, point: T) !void {
            defer _ = self.scratch.reset(.retain_capacity);
            const arena = self.scratch.allocator();

            log.debug("insert {}", .{point});

            if (self.locateVertex(point)) |start_triangle| {
                const vertex = try self.vertexMake(point);
                errdefer _ = self.vertexDelete(vertex);
                log.debug("\tvertex @ {}", .{vertex});

                const org_vertex = self.unwrap(start_triangle.org());
                const dest_vertex = self.unwrap(start_triangle.dest());
                const org_pos = Context.position(org_vertex);
                const dest_pos = Context.position(dest_vertex);

                if (Context.eql(point, org_vertex)) {
                    log.debug("\tearly out", .{});
                    self.vertexDelete(vertex);
                    return;
                }

                var stack: std.ArrayListUnmanaged(Triangle.Ref) = .empty;

                if (funcs.determinant(org_pos, dest_pos, Context.position(point)) == 0.0) {
                    // The point is collinear on the line between org and dest.
                    // Split the triangle and its neighbor into four.
                    // `left` and `right` are from the perspective of org_pos
                    // looking at dest_pos.

                    const left = start_triangle;
                    const right = start_triangle.sym();
                    const left_far_sym = left.lnext().sym();
                    const right_far_sym = right.lprev().sym();

                    const left_far = try self.triangleMake(.{
                        .org = vertex,
                        .dest = left.dest(),
                        .apex = left.apex(),
                    });
                    left.destSet(vertex);

                    if (left.constrained()) {
                        left_far.constrainedSet(true);
                    }

                    const right_far = try self.triangleMake(.{
                        .org = right.org(),
                        .dest = vertex,
                        .apex = right.apex(),
                    });

                    right.orgSet(vertex);
                    left_far.connect(right_far);

                    left.lnext().constrainedSet(false);
                    right.lprev().constrainedSet(false);
                    left.lnext().connect(left_far.lprev());
                    right.lprev().connect(right_far.lnext());

                    left_far.lnext().connect(left_far_sym);
                    right_far.lprev().connect(right_far_sym);

                    try stack.append(arena, left.lprev());
                    try stack.append(arena, left_far.lnext());
                    // On the outside hull?
                    if (right.lnext().dest() != .none) {
                        try stack.append(arena, right.lnext());
                        try stack.append(arena, right_far.lprev());
                    }
                } else {

                    // Divide triangle into sub_1, sub_2, sub_3

                    const sub_1 = try self.triangleMake(.{
                        .org = start_triangle.org(),
                        .dest = start_triangle.dest(),
                        .apex = vertex,
                    });

                    const sub_1_sym = start_triangle.sym();

                    const sub_2 = try self.triangleMake(.{
                        .org = start_triangle.dest(),
                        .dest = start_triangle.apex(),
                        .apex = vertex,
                    });

                    const sub_2_sym = start_triangle.lnext().sym();

                    const sub_3 = try self.triangleMake(.{
                        .org = start_triangle.apex(),
                        .dest = start_triangle.org(),
                        .apex = vertex,
                    });

                    const sub_3_sym = start_triangle.lprev().sym();

                    self.triangleDelete(start_triangle.deref());

                    sub_1.lnext().connect(sub_2.lprev());
                    sub_2.lnext().connect(sub_3.lprev());
                    sub_3.lnext().connect(sub_1.lprev());
                    sub_1.connect(sub_1_sym);
                    sub_2.connect(sub_2_sym);
                    sub_3.connect(sub_3_sym);

                    try stack.append(arena, sub_1);
                    try stack.append(arena, sub_2);
                    try stack.append(arena, sub_3);
                }

                while (stack.pop()) |edge| {
                    const sym = edge.sym();
                    if (!sym.constrained() and sym.apex() != .none and self.incircleT(vertex, sym)) {
                        flip(edge);
                        log.debug("\tflip {f} + {}", .{ edge, edge.sym().apex() });
                        try stack.append(arena, edge.lprev());
                        try stack.append(arena, sym.lnext());
                    } else {
                        log.debug("\taccept {f} + {}", .{ edge, edge.sym().apex() });
                    }
                }
            } else {

                // If locate returns null, `point` is either outside of the triangulation
                // or on an edge in the convex hull.
                const start = self.left_edge;

                // Build a fan of triangles to every edge visible to the new vertex.
                var fan_first: Triangle.Ref = blk: {
                    var outside_triangle = start;
                    if (self.leftOf(point, outside_triangle.lprev())) {
                        // We started in the middle of the fan, move counter-clockwise
                        // until at the beginning
                        while (true) {
                            if (!self.leftOf(point, outside_triangle.lprev())) {
                                break :blk outside_triangle.dnext();
                            } else {
                                outside_triangle = outside_triangle.dprev();
                            }
                        }
                    } else {
                        // We are on the outside of the fan, move until at the
                        // beginning
                        while (true) {
                            const org_vertex = self.unwrap(outside_triangle.lprev().org());
                            const dest_vertex = self.unwrap(outside_triangle.lprev().dest());
                            const org_pos = Context.position(org_vertex);
                            const dest_pos = Context.position(dest_vertex);
                            const point_pos = Context.position(point);
                            const det = funcs.determinant(point_pos, org_pos, dest_pos);

                            if (det > 0) {
                                break :blk outside_triangle;
                            }

                            // Point lies on the outside hull, find the edge it's on
                            // and split it into a quad
                            else if (det == 0) {
                                const min = @min(org_pos.v, dest_pos.v);
                                const max = @max(org_pos.v, dest_pos.v);
                                if (Context.eql(point, org_vertex) or Context.eql(point, dest_vertex)) {
                                    // Point already exists..
                                    return;
                                } else if (min[0] <= point_pos.x() and point_pos.x() <= max[0] and
                                    min[1] <= point_pos.y() and point_pos.y() <= max[1])
                                {
                                    const vertex = try self.vertexMake(point);
                                    errdefer _ = self.vertices.pop();
                                    const inside_triangle = outside_triangle.lprev().sym();
                                    const b = inside_triangle.dest();
                                    const c = inside_triangle.apex();
                                    inside_triangle.destSet(vertex);
                                    outside_triangle.apexSet(vertex);

                                    const triangle_sym = try self.triangleMake(.{
                                        .org = vertex,
                                        .dest = b,
                                        .apex = c,
                                    });

                                    const outside_triangle_sym = try self.triangleMake(.{
                                        .org = b,
                                        .dest = vertex,
                                        .apex = .none,
                                    });

                                    triangle_sym.lnext().connect(inside_triangle.lnext().sym());
                                    triangle_sym.connect(outside_triangle_sym);
                                    triangle_sym.lprev().connect(inside_triangle.lnext());
                                    outside_triangle_sym.lprev().connect(outside_triangle.lnext().sym());
                                    outside_triangle_sym.lnext().connect(outside_triangle.lnext());
                                    return;
                                }
                            }
                            outside_triangle = outside_triangle.dnext();
                        }
                    }
                };

                const vertex = try self.vertexMake(point);
                errdefer _ = self.vertices.pop();

                log.debug("Outside hull point {}", .{vertex});
                var stack: std.ArrayList(Triangle.Ref) = .empty;

                var fan = fan_first;
                while (self.leftOf(point, fan.lprev())) {
                    log.debug("fan triangle {f}", .{fan});
                    fan.destSet(vertex);
                    try stack.append(arena, fan.lprev());
                    fan = fan.dnext();
                }

                const fan_last = fan.dprev();

                const fan_first_case = try self.triangleMake(.{
                    .org = fan_first.apex(),
                    .dest = fan_first.dest(),
                    .apex = .none,
                });

                const fan_last_case = try self.triangleMake(.{
                    .org = fan_last.dest(),
                    .dest = fan_last.org(),
                    .apex = .none,
                });

                fan_first_case.lprev().connect(fan_first.dprev());
                fan_last_case.lnext().connect(fan_last.sym());
                fan_first_case.connect(fan_first.lnext());
                fan_last_case.connect(fan_last);
                fan_first_case.lnext().connect(fan_last_case.lprev());

                while (stack.pop()) |edge| {
                    const sym = edge.sym();
                    if (!sym.constrained() and sym.apex() != .none and self.incircleT(vertex, sym)) {
                        flip(edge);
                        log.debug("\tflip {f} + {}", .{ edge, edge.sym().apex() });
                        try stack.append(arena, edge.lprev());
                        try stack.append(arena, sym.lnext());
                    } else {
                        log.debug("\taccept {f} + {}", .{ edge, edge.sym().apex() });
                    }
                }

                // Relocate left_edge
                while (self.left_edge.dest() != .none) {
                    const a = self.position(self.left_edge.org());
                    const b = self.position(self.left_edge.dest());
                    if (b.x() < a.x() or b.x() == a.x() and b.y() < a.y()) {
                        self.left_edge = self.left_edge.sym();
                    }
                    self.left_edge = self.left_edge.onext();
                }
            }
        }

        pub fn remove(self: *Self, pt: T) !void {
            defer _ = self.scratch.reset(.retain_capacity);
            const arena = self.scratch.allocator();

            log.debug("remove {}", .{pt});

            // start_vertex has org at start_pt
            const start_vertex: Triangle.Ref = blk: {
                const start = self.locateVertex(pt) orelse {
                    std.log.err("Locate failure!\n", .{});
                    return error.LocateFailure;
                };
                if (Context.eql(pt, self.unwrap(start.org()))) {
                    break :blk start;
                } else if (Context.eql(pt, self.unwrap(start.dest()))) {
                    break :blk start.lnext();
                } else if (Context.eql(pt, self.unwrap(start.apex()))) {
                    break :blk start.lprev();
                } else {
                    std.log.err("point {} not found. Located a triangle of {f}.", .{ pt, start });
                    std.log.err("positions: {} {} {}", .{
                        self.position(start.org()),
                        self.position(start.dest()),
                        self.position(start.apex()),
                    });
                    return error.RemovePointNotFound;
                }
            };

            log.debug("\tpoint located {f}", .{start_vertex});
            const to_delete_start_point = start_vertex.org();

            if (self.left_edge.org() == start_vertex.org()) {
                self.left_edge = self.left_edge.dnext();
            }

            // self.vertices.items[start_vertex.org().unwrap()] = .zero;

            var left_edge_needs_fixup = false;
            var hole: std.ArrayListUnmanaged(Triangle.Ref) = .empty;
            var vertex = start_vertex;

            while (vertex.valid()) {
                try hole.append(arena, vertex.lnext().sym());
                const to_delete = vertex;

                if (self.left_edge.deref() == to_delete.deref()) {
                    // The left_edge connection will be deleted here and
                    // remade later in the function, so at the end get `left_edge.sym()`
                    // to preserve the invariant.
                    self.left_edge = self.left_edge.sym();
                    left_edge_needs_fixup = true;
                }

                vertex = vertex.onext();
                log.debug("\tdelete {f}", .{to_delete});
                self.triangleDelete(to_delete.deref());
            }

            for (hole.items) |hole_edge| hole_edge.deref().visited = true;

            if (hole.items.len == 3) {
                const triangle = try self.triangleMake(.{
                    .org = hole.items[0].dest(),
                    .dest = hole.items[1].dest(),
                    .apex = hole.items[2].dest(),
                });
                triangle.connect(hole.items[0]);
                triangle.lnext().connect(hole.items[1]);
                triangle.lprev().connect(hole.items[2]);
            } else {

                // Create a fan of triangles from first_vertex.
                const first_vertex = hole.items[0].dest();

                const first_triangle = try self.triangleMake(.{
                    .org = hole.items[1].dest(),
                    .dest = hole.items[1].org(),
                    .apex = first_vertex,
                });

                first_triangle.connectWithoutConstraint(hole.items[1]);
                first_triangle.lprev().connectWithoutConstraint(hole.items[0]);

                var stack: std.ArrayListUnmanaged(Triangle.Ref) = .empty;
                try stack.append(arena, first_triangle.lnext());

                for (hole.items[2 .. hole.items.len - 2]) |hole_edge| {
                    const triangle = try self.triangleMake(.{
                        .org = hole_edge.dest(),
                        .dest = hole_edge.org(),
                        .apex = first_vertex,
                    });
                    triangle.connectWithoutConstraint(hole_edge);
                    triangle.lprev().connectWithoutConstraint(stack.items[stack.items.len - 1]);
                    try stack.append(arena, triangle.lnext());
                }

                const last_triangle = try self.triangleMake(.{
                    .org = hole.items[hole.items.len - 2].dest(),
                    .dest = hole.items[hole.items.len - 2].org(),
                    .apex = first_vertex,
                });

                last_triangle.connectWithoutConstraint(hole.items[hole.items.len - 2]);
                last_triangle.lnext().connectWithoutConstraint(hole.items[hole.items.len - 1]);
                last_triangle.lprev().connectWithoutConstraint(stack.items[stack.items.len - 1]);

                while (stack.pop()) |edge| {
                    if (edge.sym().deref().visited) {
                        // This edge is a part of the hole boundary, don't check it
                        continue;
                    }

                    if (self.quadFix(edge)) {
                        log.debug("edge flipped: {f}", .{edge});
                        try stack.append(arena, edge.lnext());
                        try stack.append(arena, edge.lprev());
                        try stack.append(arena, edge.sym().lnext());
                        try stack.append(arena, edge.sym().lprev());
                    }
                }

                for (hole.items) |hole_edge| {
                    hole_edge.deref().visited = false;
                    if (hole_edge.constrained()) hole_edge.sym().constrainedSet(true);
                }
            }
            if (left_edge_needs_fixup) {
                self.left_edge = self.left_edge.sym();
            }
            self.vertexDelete(to_delete_start_point);
        }

        /// This is in most cases an incircle test, except in the cases
        /// where one of the vertices in the quad is the null vertex.
        /// In that case, if the other three points are collinear,
        /// flip the "inside edge" making two outside triangles.
        /// Otherwise, flip to make sure there is at least one inside triangle.
        fn quadFix(self: *Self, edge: Triangle.Ref) bool {
            const apex_sym = edge.sym().apex();
            const org = edge.org();
            const dest = edge.dest();
            const apex = edge.apex();

            if (org != .none and dest != .none and apex != .none and apex_sym != .none) {
                if (self.incircleT(apex_sym, edge)) {
                    flip(edge);
                    return true;
                }
            } else if (org == .none and self.determinant(dest, apex, apex_sym) > 0.0 or
                dest == .none and self.determinant(org, apex, apex_sym) > 0.0 or
                apex == .none and self.determinant(dest, org, apex_sym) == 0.0 or
                apex_sym == .none and self.determinant(dest, apex, org) == 0.0)
            {
                flip(edge);
                return true;
            }

            return false;
        }

        /// NOTE: it is illegal to perform a constraint if there is a vertex
        /// on a collinear path between start_pt and end_pt.
        pub fn constrain(self: *Self, start_pt: T, end_pt: T) !void {
            defer _ = self.scratch.reset(.retain_capacity);
            const arena = self.scratch.allocator();

            const start_vertex: Triangle.Ref = blk: {
                const start = self.locateVertex(start_pt) orelse return error.LocateFailure;
                if (start.apex() != .none and Context.eql(start_pt, self.unwrap(start.apex()))) {
                    break :blk start;
                } else if (start.org() != .none and Context.eql(start_pt, self.unwrap(start.org()))) {
                    break :blk start.lnext();
                } else if (start.dest() != .none and Context.eql(start_pt, self.unwrap(start.dest()))) {
                    break :blk start.lprev();
                } else {
                    std.log.err("constrain point not found: {} {}", .{ start_pt, end_pt });
                    return error.ConstrainPointNotFound;
                }
            };

            // `tri_start` is the edge of the triangle that contains start_pt
            // and that is cut by line(start_pt, end_pt).
            var tri_start: Triangle.Ref = blk: {
                var search_edge = start_vertex;
                while (true) {
                    if (search_edge.org() != .none) {
                        if (Context.eql(end_pt, self.unwrap(search_edge.org()))) {
                            search_edge.lprev().constrainedSet(true);
                            search_edge.lprev().sym().constrainedSet(true);
                            return;
                        } else if (search_edge.dest() == .none) {
                            if (Context.eql(self.unwrap(search_edge.org()), end_pt)) {
                                start_vertex.constrainedSet(true);
                                start_vertex.sym().constrainedSet(true);
                                return;
                            }
                        } else {
                            const org_right = funcs.rightOf(
                                self.position(search_edge.org()),
                                Context.position(start_pt),
                                Context.position(end_pt),
                            );
                            const dest_left = funcs.leftOf(
                                self.position(search_edge.dest()),
                                Context.position(start_pt),
                                Context.position(end_pt),
                            );

                            if (org_right and dest_left) {
                                break :blk search_edge;
                            }
                        }
                    }

                    search_edge = search_edge.lprev().onext().lnext();
                    if (search_edge.org() == start_vertex.org()) break;
                }
                std.log.err("no edge found that cuts triangle, from  {} {}", .{ start_pt, end_pt });
                return error.EdgeNotFound;
            };

            var left: std.ArrayListUnmanaged(Triangle.Ref) = .empty;
            var right: std.ArrayListUnmanaged(Triangle.Ref) = .empty;
            var to_delete: std.ArrayListUnmanaged(Triangle.Ref) = .empty;

            // Together, right and left describe the (outside) edges of the
            // polygonal cavity created by deleting triangles
            // that intersect line(start, end).
            try right.append(arena, tri_start.lprev().sym());
            try left.append(arena, tri_start.lnext().sym());
            try to_delete.append(arena, tri_start);

            // Follow Anglada's algorithm to build left and right arrays.
            var tri = tri_start;
            while (true) {
                const tri_sym = tri.sym();
                // v_sym has .dest() equal to the .apex() of `tri_sym`.
                const v_sym = tri_sym.apex();

                try to_delete.append(arena, tri_sym);
                if (Context.eql(end_pt, self.unwrap(v_sym))) {
                    try left.append(arena, tri_sym.lprev().sym());
                    try right.append(arena, tri_sym.lnext().sym());
                    tri = tri.sym();
                    break;
                }

                if (funcs.leftOf(
                    self.position(v_sym),
                    Context.position(start_pt),
                    Context.position(end_pt),
                )) {
                    try left.append(arena, tri_sym.lprev().sym());

                    // tri.apex() is the shared vertex between tri and tri_sym
                    // that is left of line(start_pt, end_pt)
                    tri = tri_sym.lnext();
                } else {
                    try right.append(arena, tri_sym.lnext().sym());

                    // tri.apex() is the shared vertex between tri and tri_sym
                    // that is right of line(start_pt, end_pt)
                    tri = tri_sym.lprev();
                }
            }

            // items in `right` need to be reversed because
            // retriangulateHalf expects a counter-clockwise ordering
            // of (start, vertices[], end).
            for (0..right.items.len / 2) |i| {
                std.mem.swap(Triangle.Ref, &right.items[i], &right.items[right.items.len - i - 1]);
            }

            const left_base = try self.retriangulateHalf(left.items);
            const right_base = try self.retriangulateHalf(right.items);

            left_base.connect(right_base);
            left_base.constrainedSet(true);
            right_base.constrainedSet(true);

            for (to_delete.items) |del| {
                self.triangleDelete(del.deref());
            }
        }

        /// Recursively triangulates a series of edges produced by constrain().
        /// edges[] describes a chain of cavity edges from constrain().
        /// Returns the "base" of the retriangulated half
        /// (conceptually, edge closest to polygon's center).
        fn retriangulateHalf(self: *Self, edges: []Triangle.Ref) !Triangle.Ref {
            if (edges.len == 0) {
                unreachable;
            }

            if (edges.len == 1) {
                return edges[0];
            }

            const start = edges[0].org();
            const end = edges[edges.len - 1].dest();

            // There is only one vertex that has no other
            // points in its circumcircle (with start and end).
            var best_vertex: usize = 1;
            for (edges[1..], 1..) |candidate, i| {
                if (self.incircle(start, end, edges[best_vertex].org(), candidate.org())) {
                    best_vertex = i;
                }
            }

            const base = try self.triangleMake(.{
                .org = start,
                .dest = end,
                .apex = edges[best_vertex].org(),
            });

            if (edges.len == 2) {
                // Just one triangle, connect to the first and last outside edge.
                base.lprev().connect(edges[0]);
                base.lnext().connect(edges[1]);
            } else {
                const left_base = try self.retriangulateHalf(edges[0..best_vertex]);
                const right_base = try self.retriangulateHalf(edges[best_vertex..]);

                // If the triangles of left_base and right_base share a
                // common edge (in the cases that the polygon contains
                // repeated points), connect them here.
                if (left_base.lnext().org() == right_base.lprev().dest() and
                    left_base.lnext().dest() == right_base.lprev().org())
                {
                    left_base.lnext().connect(right_base.lprev());
                }

                base.lnext().connect(right_base);
                base.lprev().connect(left_base);
            }

            return base;
        }

        pub fn locatePoint(self: *Self, point: hym.Vec2) ?Triangle.Ref {
            var edge = self.left_edge.onext();

            if (funcs.rightOf(point, self.position(edge.org()), self.position(edge.dest()))) {
                edge = edge.sym();
            }

            var loop_protection: u16 = 10_000;
            while (loop_protection > 0) : (loop_protection -= 1) {
                if (point.eqlEps(self.position(edge.org()), f32_tolerance)) {
                    return edge;
                }

                if (point.eqlEps(self.position(edge.dest()), f32_tolerance)) {
                    return edge.sym();
                }

                if (edge.apex() == .none) {
                    if (funcs.determinant(
                        self.position(edge.org()),
                        self.position(edge.dest()),
                        point,
                    ) < f32_tolerance) {
                        edge = edge.dprev().lnext();
                        continue;
                    }
                    return null;
                }

                if (!funcs.rightOf(point, self.position(edge.onext().org()), self.position(edge.onext().dest()))) {
                    edge = edge.onext();
                    continue;
                }

                if (!funcs.rightOf(point, self.position(edge.dprev().org()), self.position(edge.dprev().dest()))) {
                    edge = edge.dprev();
                    continue;
                }

                return edge;
            }

            return null;
        }

        pub fn locateVertex(self: *Self, point: T) ?Triangle.Ref {
            var edge = self.left_edge.onext();

            if (self.rightOf(point, edge)) {
                edge = edge.sym();
            }

            var loop_protection: u16 = 10_000;
            while (loop_protection > 0) : (loop_protection -= 1) {
                if (Context.eql(point, self.unwrap(edge.org()))) {
                    return edge;
                }

                if (Context.eql(point, self.unwrap(edge.dest()))) {
                    return edge.sym();
                }

                if (edge.apex() == .none) {
                    if (funcs.determinant(
                        self.position(edge.org()),
                        self.position(edge.dest()),
                        Context.position(point),
                    ) < f32_tolerance) {
                        edge = edge.dprev().lnext();
                        continue;
                    }
                    return null;
                }

                if (!self.rightOf(point, edge.onext())) {
                    edge = edge.onext();
                    continue;
                }

                if (!self.rightOf(point, edge.dprev())) {
                    edge = edge.dprev();
                    continue;
                }

                return edge;
            }

            return null;
        }

        fn flip(edge: Triangle.Ref) void {
            // From the perspective of original `org`, looking at `dest`,
            // flip the edge so that edge is from `right` to `left`
            // (a counter-clockwise turn).

            // Vertices
            const org = edge.org();
            const dest = edge.dest();
            const left = edge.apex();
            const right = edge.sym().apex();

            edge.deref().constraints = @splat(false);
            edge.sym().deref().constraints = @splat(false);

            // Edges
            const close_right = edge.sym().lnext();
            const close_left = edge.lprev();
            const far_right = edge.sym().lprev();
            const far_left = edge.lnext();

            const close_right_sym = close_right.sym();
            const close_left_sym = close_left.sym();
            const far_left_sym = far_left.sym();
            const far_right_sym = far_right.sym();

            // Rewire one turn counter-clockwise
            // edge remains connected to edge.sym
            // close_left.connectWithoutConstraint(close_right_sym);
            // far_left.connectWithoutConstraint(close_left_sym);
            // far_right.connectWithoutConstraint(far_left_sym);
            // close_right.connectWithoutConstraint(far_right_sym);
            close_left.connect(close_right_sym);
            far_left.connect(close_left_sym);
            far_right.connect(far_left_sym);
            close_right.connect(far_right_sym);

            edge.orgSet(right);
            edge.destSet(left);
            edge.apexSet(org);

            edge.sym().orgSet(left);
            edge.sym().destSet(right);
            edge.sym().apexSet(dest);
        }

        pub const TrianglePoints = struct {
            org: VertexHandle,
            dest: VertexHandle,
            apex: VertexHandle,
        };

        fn vertexMake(self: *Self, point: T) !VertexHandle {
            if (self.free_list) |index| {
                const next: usize = self.vertices.items[index].next;
                self.free_list = if (next != std.math.maxInt(usize)) next else null;
                self.vertices.items[index] = .{ .data = point };
                return .make(index);
            } else {
                try self.vertices.append(self.allocator, .{ .data = point });
                return .make(self.vertices.items.len - 1);
            }
        }

        fn vertexDelete(self: *Self, vertex: VertexHandle) void {
            self.vertices.items[vertex.unwrap()] = if (self.free_list) |index| .{ .next = index } else .{ .next = std.math.maxInt(usize) };
            self.free_list = vertex.unwrap();
        }

        fn triangleMake(self: *Self, p: TrianglePoints) !Triangle.Ref {
            const triangle = try self.pool.create();

            triangle.* = .{
                .neighbor = @splat(.none),
                .vertices = .{ p.apex, p.org, p.dest },
            };

            return .init(triangle);
        }

        fn triangleDelete(self: *Self, triangle: *Triangle) void {
            for (0..3) |i| {
                const neighbor = triangle.neighbor[i];
                if (!neighbor.valid()) continue;

                if (neighbor.sym().deref() == triangle) {
                    neighbor.deref().neighbor[neighbor.rot] = .none;
                }
            }

            self.pool.destroy(triangle);
        }

        pub fn enumerate(self: *Self) ![]Triangle.Ref {
            defer _ = self.scratch.reset(.retain_capacity);
            const arena = self.scratch.allocator();

            var triangles: std.ArrayListUnmanaged(Triangle.Ref) = .empty;
            var real_triangles: std.ArrayListUnmanaged(Triangle.Ref) = .empty;
            var stack: std.ArrayListUnmanaged(Triangle.Ref) = .empty;

            const start = self.left_edge;
            try stack.append(arena, start);

            while (stack.items.len > 0) {
                const tri = stack.pop().?;
                if (tri.deref().visited) continue;
                tri.deref().visited = true;

                try triangles.append(arena, tri);

                if (tri.org() != .none and tri.dest() != .none and tri.apex() != .none) {
                    try real_triangles.append(arena, tri);
                }

                for (0..3) |n| {
                    if (tri.deref().neighbor[n].valid()) {
                        try stack.append(arena, tri.deref().neighbor[n]);
                    }
                }
            }

            for (triangles.items) |tri| {
                tri.deref().visited = false;
            }

            return try self.allocator.dupe(Triangle.Ref, real_triangles.items);
        }

        pub fn indices(self: *Self) ![]u32 {
            const triangles = try self.enumerate();
            defer self.allocator.free(triangles);
            const idxs = try self.allocator.alloc(u32, triangles.len * 3);
            for (triangles, 0..) |triangle, i| {
                idxs[i * 3 + 0] = @intCast(triangle.org().unwrap());
                idxs[i * 3 + 1] = @intCast(triangle.dest().unwrap());
                idxs[i * 3 + 2] = @intCast(triangle.apex().unwrap());
            }
            return idxs;
        }

        pub fn delete(self: *Self, points: []const Triangle.Ref) !void {
            var ara: std.heap.ArenaAllocator = .init(self.allocator);
            defer ara.deinit();
            const al = ara.allocator();

            var stack: std.AutoArrayHashMapUnmanaged(*Triangle, void) = .empty;

            for (points) |point| {
                try stack.put(al, point.deref(), {});

                var next_edge = point.onext();
                while (next_edge.dest() != point.dest()) {
                    const next = next_edge.onext();
                    try stack.put(al, next_edge.deref(), {});
                    next_edge = next;
                }
            }

            for (stack.keys()) |tri| {
                self.triangleDelete(tri);
            }
        }

        /// See "triangle cascade" from CGAL.
        pub fn visibility(self: *Self, origin: hym.Vec2, visibility_allocator: std.mem.Allocator) ![][2]hym.Vec2 {
            const arena = self.scratch.allocator();
            defer _ = self.scratch.reset(.retain_capacity);

            const RecurseItem = struct {
                edge: Triangle.Ref,
                left_limit: f32 = 0,
                right_limit: f32 = 1,
            };

            var stack: std.ArrayListUnmanaged(RecurseItem) = .empty;
            var visibility_edges: std.ArrayListUnmanaged([2]hym.Vec2) = .empty;

            const tri = self.locatePoint(origin) orelse return error.OutOfBounds;

            inline for (.{
                tri.sym(),
                tri.lprev().sym(),
                tri.lnext().sym(),
            }) |origin_edge| {
                try stack.append(arena, .{ .edge = origin_edge });
            }

            while (stack.items.len > 0) {
                const item = stack.pop().?;
                const edge = item.edge;
                const left = item.left_limit;
                const right = item.right_limit;

                if (edge.apex() == .none or edge.constrained()) {
                    const org = self.position(edge.org());
                    const dest = self.position(edge.dest());

                    // `edge` is an "outside edge" meaning it is going
                    // clockwise wrt. the visibility polygon. Visibility
                    // segments should go counter-clockwise, so right
                    // and left are flipped here.
                    try visibility_edges.append(arena, .{
                        org.lerp(dest, right),
                        org.lerp(dest, left),
                    });

                    continue;
                }

                const org_pos = self.position(edge.org());
                const dest_pos = self.position(edge.dest());
                const apex_pos = self.position(edge.apex());

                const dir_left = org_pos.lerp(dest_pos, left).sub(origin);
                const dir_right = org_pos.lerp(dest_pos, right).sub(origin);

                const apex_is_left = !funcs.rightOf(apex_pos, origin, dir_left.add(origin));
                const apex_is_right = !funcs.leftOf(apex_pos, origin, dir_right.add(origin));

                if (apex_is_left or apex_is_right) {
                    const visible_edge = if (apex_is_left) edge.lnext() else edge.lprev();
                    const start = if (apex_is_left) apex_pos else org_pos;
                    const end = if (apex_is_left) dest_pos else apex_pos;

                    const a, const unclamped_l = funcs.raySegmentIntersect(origin, dir_left, start, end);
                    const b, const unclamped_r = funcs.raySegmentIntersect(origin, dir_right, start, end);

                    const l = @max(0, @min(1, unclamped_l));
                    const r = @max(0, @min(1, unclamped_r));

                    std.debug.assert(a >= 0 and b >= 0);

                    try stack.append(arena, .{
                        .edge = visible_edge.sym(),
                        .left_limit = l,
                        .right_limit = r,
                    });
                } else {
                    // Consider both neighbor edges
                    const a, const unclamped_l = funcs.raySegmentIntersect(origin, dir_left, org_pos, apex_pos);
                    const b, const unclamped_r = funcs.raySegmentIntersect(origin, dir_right, apex_pos, dest_pos);

                    std.debug.assert(a >= 0 and b >= 0);

                    const l = @max(0, @min(1, unclamped_l));
                    const r = @max(0, @min(1, unclamped_r));

                    const next_left = edge.lprev().sym();
                    try stack.append(arena, .{
                        .edge = next_left,
                        .left_limit = l,
                        .right_limit = 1,
                    });

                    const next_right = edge.lnext().sym();
                    try stack.append(arena, .{
                        .edge = next_right,
                        .left_limit = 0,
                        .right_limit = r,
                    });
                }
            }

            return try visibility_allocator.dupe([2]hym.Vec2, visibility_edges.items);
        }

        fn leftOf(self: *Self, point: T, edge: Triangle.Ref) bool {
            return funcs.leftOf(
                Context.position(point),
                self.position(edge.org()),
                self.position(edge.dest()),
            );
        }

        fn rightOf(self: *Self, point: T, edge: Triangle.Ref) bool {
            return funcs.rightOf(
                Context.position(point),
                self.position(edge.org()),
                self.position(edge.dest()),
            );
        }

        fn determinant(self: *Self, a: VertexHandle, b: VertexHandle, c: VertexHandle) f32 {
            return funcs.determinant(
                self.position(a),
                self.position(b),
                self.position(c),
            );
        }

        fn incircle(self: *const Self, a: VertexHandle, b: VertexHandle, c: VertexHandle, d: VertexHandle) bool {
            return funcs.incircle(
                self.position(a),
                self.position(b),
                self.position(c),
                self.position(d),
            );
        }

        fn incircleT(self: *const Self, a: VertexHandle, t: Triangle.Ref) bool {
            return funcs.incircle(
                self.position(t.org()),
                self.position(t.dest()),
                self.position(t.apex()),
                self.position(a),
            );
        }
    };
}
