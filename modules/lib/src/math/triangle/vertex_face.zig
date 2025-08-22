const std = @import("std");
const hym = @import("../math.zig");

const root = @import("root.zig");
const funcs = @import("funcs.zig");
const VertexHandle = root.VertexHandle;
const determinant = funcs.determinant;

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

        inline fn init(ptr: *Triangle) Triangle.Ref {
            var ref: Triangle.Ref = @bitCast(@intFromPtr(ptr));
            ref.rot = 0;
            return ref;
        }

        inline fn deref(self: Ref) *Triangle {
            return @ptrFromInt(@as(usize, @bitCast(@as(u64, self.triangle << 2))));
        }

        pub inline fn sym(self: Ref) Ref {
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

        fn apex(self: Ref) VertexHandle {
            return self.deref().vertices[self.rot];
        }

        fn apexSet(self: Ref, a: VertexHandle) void {
            self.deref().vertices[self.rot] = a;
        }

        fn org(self: Ref) VertexHandle {
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

        fn dest(self: Ref) VertexHandle {
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

        pub fn constrained(self: Ref) bool {
            return self.deref().constraints[self.rot];
        }

        fn constrainedSet(self: Ref, toggle: bool) void {
            self.deref().constraints[self.rot] = toggle;
        }
    };

    const Pool = std.heap.MemoryPool(Triangle);
};

pub const CDT = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    scratch: std.heap.ArenaAllocator,
    pool: std.heap.MemoryPool(Triangle),
    left_edge: Triangle.Ref,
    right_edge: Triangle.Ref,
    vertices: std.ArrayListUnmanaged(hym.Vec2) = .empty,

    pub fn init(allocator: std.mem.Allocator, initial_vertices: []const hym.Vec2) !Self {
        var sd: CDT = .{
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
        self.pool.arena.deinit();
    }

    inline fn position(self: *const Self, h: VertexHandle) hym.Vec2 {
        return self.vertices.items[h.unwrap()];
    }

    pub fn triangulate(self: *Self, initial_vertices: []const hym.Vec2) ![2]Triangle.Ref {
        const gpa = self.allocator;

        const Context = struct {
            fn lessThan(_: @This(), a: hym.Vec2, b: hym.Vec2) bool {
                if (a.x() == b.x())
                    return a.y() < b.y()
                else
                    return a.x() < b.x();
            }
        };

        const dupe = try gpa.dupe(hym.Vec2, initial_vertices);
        defer gpa.free(dupe);

        std.sort.heap(hym.Vec2, dupe, Context{}, Context.lessThan);

        // Remove duplicate points
        for (dupe) |vertex| {
            if (self.vertices.items.len == 0 or
                !vertex.eql(self.vertices.getLast()))
            {
                try self.vertices.append(gpa, vertex);
            } else continue;
        }

        std.debug.assert(self.vertices.items.len > 2);

        const l, const r = try self.triangulateRecursive(0, self.vertices.items.len);
        self.left_edge = l;
        self.right_edge = r;
        return .{ l, r };
    }

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
            const det = determinant(self.position(s1), self.position(s2), self.position(s3));

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

    pub fn insert(self: *CDT, vertex: hym.Vec2) !void {
        defer _ = self.scratch.reset(.retain_capacity);
        const arena = self.scratch.allocator();

        const start_triangle = self.locate(vertex) orelse return error.OutOfBounds;

        try self.vertices.append(self.allocator, vertex);

        const new_point: VertexHandle = .make(self.vertices.items.len - 1);

        // Divide triangle into sub_1, sub_2, sub_3

        const sub_1 = try self.triangleMake(.{
            .org = start_triangle.org(),
            .dest = start_triangle.dest(),
            .apex = new_point,
        });

        const sub_1_sym = start_triangle.sym();

        const sub_2 = try self.triangleMake(.{
            .org = start_triangle.dest(),
            .dest = start_triangle.apex(),
            .apex = new_point,
        });

        const sub_2_sym = start_triangle.lnext().sym();

        const sub_3 = try self.triangleMake(.{
            .org = start_triangle.apex(),
            .dest = start_triangle.org(),
            .apex = new_point,
        });

        const sub_3_sym = start_triangle.lprev().sym();

        self.triangleDelete(start_triangle.deref());

        sub_1.lnext().connect(sub_2.lprev());
        sub_2.lnext().connect(sub_3.lprev());
        sub_3.lnext().connect(sub_1.lprev());
        sub_1.connect(sub_1_sym);
        sub_2.connect(sub_2_sym);
        sub_3.connect(sub_3_sym);

        var stack: std.ArrayListUnmanaged(Triangle.Ref) = .empty;

        try stack.append(arena, sub_1);
        try stack.append(arena, sub_2);
        try stack.append(arena, sub_3);

        while (stack.pop()) |edge| {
            const sym = edge.sym();
            if (!sym.constrained() and self.incircleT(new_point, sym)) {
                flip(edge);
                try stack.append(arena, edge.lprev());
                try stack.append(arena, sym.lnext());
            }
        }
    }

    pub fn remove(self: *Self, pt: hym.Vec2) !void {
        defer _ = self.scratch.reset(.retain_capacity);
        const arena = self.scratch.allocator();

        // start_vertex has org at start_pt
        const start_vertex: Triangle.Ref = blk: {
            const start = self.locate(pt) orelse return error.OutOfBounds;
            if (pt.eql(self.position(start.org()))) {
                break :blk start;
            } else if (pt.eql(self.position(start.dest()))) {
                break :blk start.lnext();
            } else if (pt.eql(self.position(start.apex()))) {
                break :blk start.lprev();
            } else {
                return error.PointNotFound;
            }
        };

        var hole: std.ArrayListUnmanaged(Triangle.Ref) = .empty;
        try hole.append(arena, start_vertex.lnext().sym());
        var vertex = start_vertex.onext();
        const start_dest = start_vertex.dest();

        while (vertex.dest() != start_dest) {
            try hole.append(arena, vertex.lnext().sym());
            const to_delete = vertex;
            vertex = vertex.onext();
            self.triangleDelete(to_delete.deref());
        }

        for (hole.items) |hole_edge| {
            hole_edge.deref().visited = true;
        }

        var stack: std.ArrayListUnmanaged(Triangle.Ref) = .empty;

        if (hole.items.len == 3) {
            const triangle = try self.triangleMake(.{
                .org = hole.items[0].dest(),
                .dest = hole.items[1].dest(),
                .apex = hole.items[2].dest(),
            });
            triangle.connect(hole.items[0]);
            triangle.lnext().connect(hole.items[1]);
            triangle.lprev().connect(hole.items[2]);
            return;
        }

        // Create a fan of triangles from first_vertex.
        const first_vertex = hole.items[0].dest();

        const first_triangle = try self.triangleMake(.{
            .org = hole.items[1].dest(),
            .dest = hole.items[1].org(),
            .apex = first_vertex,
        });

        first_triangle.connect(hole.items[1]);
        first_triangle.lprev().connect(hole.items[0]);

        try stack.append(arena, first_triangle.lnext());

        for (hole.items[2 .. hole.items.len - 2]) |hole_edge| {
            const triangle = try self.triangleMake(.{
                .org = hole_edge.dest(),
                .dest = hole_edge.org(),
                .apex = first_vertex,
            });
            triangle.connect(hole_edge);
            triangle.lprev().connect(stack.items[stack.items.len - 1]);
            try stack.append(arena, triangle.lnext());
        }

        const last_triangle = try self.triangleMake(.{
            .org = hole.items[hole.items.len - 2].dest(),
            .dest = hole.items[hole.items.len - 2].org(),
            .apex = first_vertex,
        });

        last_triangle.connect(hole.items[hole.items.len - 2]);
        last_triangle.lnext().connect(hole.items[hole.items.len - 1]);
        last_triangle.lprev().connect(stack.items[stack.items.len - 1]);

        for (hole.items) |hole_edge| {
            hole_edge.deref().visited = true;
        }

        while (stack.pop()) |edge| {
            if (edge.sym().deref().visited) {
                // This edge is a part of the hole boundary, don't check it
                continue;
            }

            const opposite_vertex = edge.sym().apex();
            if (opposite_vertex != .none and self.incircleT(opposite_vertex, edge)) {
                flip(edge);
                try stack.append(arena, edge.lnext());
                try stack.append(arena, edge.lprev());
                try stack.append(arena, edge.sym().lnext());
                try stack.append(arena, edge.sym().lprev());
            }
        }

        for (hole.items) |hole_edge| {
            hole_edge.deref().visited = false;
        }
    }

    pub fn constrain(self: *Self, start_pt: hym.Vec2, end_pt: hym.Vec2) !void {
        defer _ = self.scratch.reset(.retain_capacity);
        const arena = self.scratch.allocator();

        // start_vertex has apex at start_pt.
        const start_vertex: Triangle.Ref = blk: {
            const start = self.locate(start_pt) orelse return error.OutOfBounds;
            if (start_pt.eql(self.position(start.apex()))) {
                break :blk start;
            } else if (start_pt.eql(self.position(start.org()))) {
                break :blk start.lnext();
            } else if (start_pt.eql(self.position(start.dest()))) {
                break :blk start.lprev();
            } else {
                return error.PointNotFound;
            }
        };

        // `tri_start` is the edge of the triangle that contains start_pt
        // and that is cut by line(start_pt, end_pt).
        var tri_start: Triangle.Ref = blk: {
            var search_edge = start_vertex;
            while (true) {
                const org_right = funcs.rightOf(self.position(search_edge.org()), start_pt, end_pt);
                const dest_left = funcs.leftOf(self.position(search_edge.dest()), start_pt, end_pt);
                if (org_right and dest_left) {
                    break :blk search_edge;
                } else if (end_pt.eql(self.position(search_edge.org()))) {
                    search_edge.lprev().constrainedSet(true);
                    search_edge.lprev().sym().constrainedSet(true);
                    return;
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
            if (end_pt.eql(self.position(v_sym))) {
                try left.append(arena, tri_sym.lprev().sym());
                try right.append(arena, tri_sym.lnext().sym());
                tri = tri.sym();
                break;
            }

            if (funcs.leftOf(self.position(v_sym), start_pt, end_pt)) {
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
    fn retriangulateHalf(self: *CDT, edges: []Triangle.Ref) !Triangle.Ref {
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

    pub fn locate(self: *CDT, point: hym.Vec2) ?Triangle.Ref {
        var edge = self.left_edge;

        while (edge.dest() == .none) edge = edge.onext();

        if (self.rightOf(point, edge)) {
            edge = edge.sym();
        }

        while (true) {
            if (point.eql(self.position(edge.org()))) {
                return edge;
            }
            if (point.eql(self.position(edge.dest()))) {
                return edge.sym();
            }

            if (edge.onext().org() == .none or edge.onext().dest() == .none) {
                return null;
            }
            if (!self.rightOf(point, edge.onext())) {
                edge = edge.onext();
                continue;
            }

            if (edge.dprev().org() == .none or edge.dprev().dest() == .none) {
                return null;
            }
            if (!self.rightOf(point, edge.dprev())) {
                edge = edge.dprev();
                continue;
            }

            return edge;
        }
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

        const tri = self.locate(origin) orelse return error.OutOfBounds;

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

    fn rightOf(self: *CDT, point: hym.Vec2, edge: Triangle.Ref) bool {
        return funcs.rightOf(point, self.position(edge.org()), self.position(edge.dest()));
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

pub const VisibilityPolygon = struct {
    origin: hym.Vec2 = .zero,
    segments: [][2]hym.Vec2 = &.{},

    pub fn query(self: VisibilityPolygon, point: hym.Vec2) bool {
        if (self.segments.len == 0) return false;

        const start_angle = self.segments[0][0].sub(self.origin).atan();
        const target_angle = @mod(point.sub(self.origin).atan() - start_angle, std.math.pi * 2);

        const SortContext = struct {
            target: f32,
            start: f32,
            origin: hym.Vec2,

            fn compare(ctx: @This(), segment: [2]hym.Vec2) std.math.Order {
                const lower_bound = angle(ctx, segment[0]);
                if (ctx.target < lower_bound) return .lt;
                const upper_bound = angle(ctx, segment[1]);
                if (ctx.target > upper_bound) return .gt;
                return .eq;
            }

            inline fn angle(ctx: @This(), pt: hym.Vec2) f32 {
                return @mod(pt.sub(ctx.origin).atan() - ctx.start, std.math.pi * 2);
            }
        };

        const idx = std.sort.binarySearch([2]hym.Vec2, self.segments, SortContext{
            .start = start_angle,
            .target = target_angle,
            .origin = self.origin,
        }, SortContext.compare) orelse return false;

        return funcs.leftOf(point, self.segments[idx][0], self.segments[idx][1]);
    }

    pub fn deinit(self: VisibilityPolygon, allocator: std.mem.Allocator) void {
        allocator.free(self.segments);
    }
};
