const std = @import("std");
const hym = @import("../math.zig");

const root = @import("root.zig");
const funcs = @import("funcs.zig");
const VertexHandle = root.VertexHandle;
const determinant = funcs.determinant;

pub const EdgeExtra = struct {
    triangles: [2]Triangle.Ref,
    constrained: bool = false,

    pub const Ref = struct {
        edge: *EdgeExtra,
        a: f32 = 0,
        b: f32 = 1,
        rot: u1 = 0,

        pub fn sym(self: Ref) Ref {
            return .{
                .edge = self.edge,
                .a = (1 - self.b),
                .b = (1 - self.a),
                .rot = if (self.rot == 0) 1 else 0,
            };
        }

        pub fn constrained(self: Ref) bool {
            return self.edge.constrained;
        }

        pub fn constrainedSet(self: Ref, toggle: bool) void {
            self.edge.constrained = toggle;
        }

        pub fn limitLeft(self: Ref, value: f32) Ref {
            var ref: Ref = self;
            switch (ref.rot) {
                0 => ref.a = value,
                1 => ref.b = (1 - value),
            }
            std.debug.assert(ref.a <= ref.b);
            std.debug.assert(ref.a >= 0);
            std.debug.assert(ref.b <= 1);
            return ref;
        }

        pub fn limitRight(self: Ref, value: f32) Ref {
            var ref: Ref = self;
            switch (ref.rot) {
                0 => ref.b = value,
                1 => ref.a = (1 - value),
            }
            std.debug.assert(ref.a <= ref.b);
            std.debug.assert(ref.a >= 0);
            std.debug.assert(ref.b <= 1);
            return ref;
        }

        pub fn low(self: Ref) f32 {
            return self.a;
        }

        pub fn high(self: Ref) f32 {
            return self.b;
        }
    };

    pub const Pool = std.heap.MemoryPool(EdgeExtra);
};

pub const Triangle = struct {
    neighbor: [3]Ref,
    vertices: [3]VertexHandle = @splat(.none),
    edges: [3]?EdgeExtra.Ref = @splat(null),
    visited: bool = false,

    pub const Ref = packed struct(usize) {
        rot: u2 = 0,
        triangle: u62,

        pub fn format(value: Ref, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
            _ = options;
            _ = fmt;
            try writer.writeAll("(");
            if (value.org() != .none) try std.fmt.formatInt(@intFromEnum(value.org()), 10, .lower, .{}, writer) else try writer.writeAll("*");
            try writer.writeAll(" ");
            if (value.dest() != .none) try std.fmt.formatInt(@intFromEnum(value.dest()), 10, .lower, .{}, writer) else try writer.writeAll("*");
            try writer.writeAll(" ");
            if (value.apex() != .none) try std.fmt.formatInt(@intFromEnum(value.apex()), 10, .lower, .{}, writer) else try writer.writeAll("*");
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

        inline fn sym(self: Ref) Ref {
            return self.deref().neighbor[self.rot];
        }

        fn lnext(self: Ref) Ref {
            return .{ .triangle = self.triangle, .rot = switch (self.rot) {
                0 => 1,
                1 => 2,
                2 => 0,
                3 => unreachable,
            } };
        }

        fn lprev(self: Ref) Ref {
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
        }

        fn constrained(self: Ref) bool {
            return (self.deref().edges[self.rot] orelse return false).constrained();
        }

        fn edgeExtra(self: Ref) ?EdgeExtra.Ref {
            return self.deref().edges[self.rot];
        }
    };

    const Pool = std.heap.MemoryPool(Triangle);
};

pub const Visibility = struct {
    origin: hym.Vec2 = .zero,
    segments: [][2]hym.Vec2 = &.{},

    pub fn query(self: Visibility, point: hym.Vec2) bool {
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

        const idx = std.sort.binarySearch([2]hym.Vec2, self.segments, SortContext {
            .start = start_angle,
            .target = target_angle,
            .origin = self.origin,
        }, SortContext.compare) orelse return false;

        return funcs.leftOf(point, self.segments[idx][0], self.segments[idx][1]);
    }

    pub fn deinit(self: Visibility, allocator: std.mem.Allocator) void {
        allocator.free(self.segments);
    }
};

fn PositionFn(T: type) type {
    return ?*const fn (x: T) hym.Vec2;
}

pub fn Subdivision(Vertex: type, positionFn: PositionFn(Vertex)) type {
    return struct {
        const Self = @This();
        const BucketKey = struct { x: usize, y: usize };
        const BucketMap = std.AutoHashMapUnmanaged(BucketKey, std.SinglyLinkedList(Triangle.Ref));
        const NodePool = std.heap.MemoryPool(std.SinglyLinkedList(Triangle.Ref).Node);

        allocator: std.mem.Allocator,
        pool: Triangle.Pool,
        edge_pool: EdgeExtra.Pool,
        dummy_triangle: *Triangle,
        left_edge: Triangle.Ref,
        right_edge: Triangle.Ref,
        verts: std.ArrayListUnmanaged(Vertex) = .empty,
        indices: []u32 = &.{},
        buckets: BucketMap = .empty,
        bucket_allocator: NodePool,

        pub fn init(allocator: std.mem.Allocator) !Self {
            var pool: Triangle.Pool = .init(allocator);
            const edge_pool: EdgeExtra.Pool = .init(allocator);
            const dummy_triangle = try pool.create();
            dummy_triangle.* = .{
                .neighbor = @splat(.init(dummy_triangle)),
            };

            return .{
                .allocator = allocator,
                .pool = pool,
                .edge_pool = edge_pool,
                .dummy_triangle = dummy_triangle,
                .left_edge = .init(dummy_triangle),
                .right_edge = .init(dummy_triangle),
                .bucket_allocator = .init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.verts.deinit(self.allocator);
            self.allocator.free(self.indices);
            self.buckets.deinit(self.allocator);
            self.pool.deinit();
            self.edge_pool.deinit();
            self.bucket_allocator.deinit();
        }

        pub fn vertex(self: *const Self, h: VertexHandle) hym.Vec2 {
            return if (positionFn) |func| func(self.verts.items[h.unwrap()]) else self.verts.items[h.unwrap()];
        }

        pub fn segment(self: *const Self, edge: EdgeExtra.Ref) [2]hym.Vec2 {
            const tri = edge.edge.triangles[edge.rot];
            return .{
                self.vertex(tri.org()).lerp(self.vertex(tri.dest()), edge.low()),
                self.vertex(tri.org()).lerp(self.vertex(tri.dest()), edge.high()),
            };
        }

        inline fn position(v: Vertex) hym.Vec2 {
            return if (positionFn) |func| func(v) else v;
        }

        fn incircle(self: *const Self, a: VertexHandle, b: VertexHandle, c: VertexHandle, d: VertexHandle) bool {
            return funcs.incircle(
                self.vertex(a),
                self.vertex(b),
                self.vertex(c),
                self.vertex(d),
            );
        }

        pub fn triangulate(self: *Self, verts: []const Vertex) ![2]Triangle.Ref {
            const gpa = self.allocator;

            const Context = struct {
                fn lessThan(_: @This(), a: Vertex, b: Vertex) bool {
                    const pa = position(a);
                    const pb = position(b);
                    if (pa.x() == pb.x())
                        return pa.y() < pb.y()
                    else
                        return pa.x() < pb.x();
                }
            };

            const dupe = try gpa.dupe(Vertex, verts);
            defer gpa.free(dupe);

            std.sort.heap(Vertex, dupe, Context{}, Context.lessThan);

            for (dupe) |v| {
                if (self.verts.items.len == 0) {
                    try self.verts.append(gpa, v);
                } else if (!position(v).eql(position(self.verts.items[self.verts.items.len - 1]))) {
                    try self.verts.append(gpa, v);
                } else continue;
            }

            std.debug.assert(self.verts.items.len > 2);

            const l, const r = try self.triangulateRecursive(0, self.verts.items.len);
            self.left_edge = l;
            self.right_edge = r;

            try self.refresh();

            return .{ l, r };
        }

        pub fn constrain(self: *Self, in_start: Triangle.Ref, end: Triangle.Ref) !void {
            var start = in_start;

            var ara: std.heap.ArenaAllocator = .init(self.allocator);
            const arena = ara.allocator();
            defer ara.deinit();

            // Start must have origin at first endpoint and
            // also be inside the convex hull.

            // Detect a collinear path to the vertex.
            var current_node = start;
            var next_edge = start;
            var initial_check_done = false;
            while (!initial_check_done or current_node != next_edge) : (next_edge = next_edge.onext()) {
                initial_check_done = true;
                std.debug.assert(next_edge.deref() != self.dummy_triangle);

                if (next_edge.dest() == end.org()) {
                    const edge = try self.edgeMake(next_edge);
                    edge.constrainedSet(true);
                    return;
                } else if (next_edge.org() != .none and next_edge.dest() != .none) {
                    const a = self.vertex(next_edge.org());
                    const b = self.vertex(next_edge.dest());
                    const c = self.vertex(end.org());
                    const min_x = @min(a.x(), c.x());
                    const max_x = @max(a.x(), c.x());
                    const min_y = @min(a.y(), c.y());
                    const max_y = @max(a.y(), c.y());
                    const det = funcs.determinant(
                        self.vertex(next_edge.org()),
                        self.vertex(next_edge.dest()),
                        self.vertex(end.org()),
                    );

                    if (det == 0 and min_x <= b.x() and b.x() <= max_x and
                        min_y <= b.y() and b.y() <= max_y)
                    {
                        // end lies past next_edge and is collinear, continue search
                        // next_edge.constraintSet(true);
                        current_node = next_edge.sym();
                        next_edge = current_node.onext();
                        initial_check_done = false;
                    }
                }
            }

            start = current_node;

            const pt_start = self.vertex(start.org());
            const pt_end = self.vertex(end.org());

            var to_delete: std.AutoArrayHashMapUnmanaged(*Triangle, void) = .empty;
            var boundary_edges: std.ArrayListUnmanaged(Triangle.Ref) = .empty;

            // Track the edges that define the polygonal hole
            // that will be created once the triangles are deleted.
            var test_edge = start;

            // Find the first triangle that is intersected by the line
            // and set test_edge to the edge immediately right (cw) of the line
            const loop_protection: u32 = 16;
            for (0..loop_protection) |_| {
                const pt_test_edge_dest = self.vertex(test_edge.dest());
                const pt_next_edge_dest = self.vertex(test_edge.onext().dest());
                if (funcs.rightOf(pt_test_edge_dest, pt_start, pt_end) and
                    funcs.leftOf(pt_next_edge_dest, pt_start, pt_end))
                {
                    break;
                }
                test_edge = test_edge.onext();
            } else {
                std.debug.panic("Collinear point was found, this should not be possible", .{});
            }

            const polygon_start = test_edge.sym();
            const polygon_end = test_edge.onext();

            test_edge = test_edge.lnext();

            while (test_edge.org() != end.org()) {
                const pt_test_edge_start = self.vertex(test_edge.org());
                const pt_test_edge_end = self.vertex(test_edge.dest());
                if (funcs.rightOf(pt_test_edge_start, pt_start, pt_end) and
                    funcs.leftOf(pt_test_edge_end, pt_start, pt_end))
                {
                    try to_delete.put(arena, test_edge.deref(), {});
                    test_edge = test_edge.sym().lnext();
                } else {
                    try boundary_edges.append(arena, test_edge);
                    test_edge = test_edge.lnext();
                }
            }

            // Go backwards to get the other half of the polygon
            for (0..loop_protection) |_| {
                const pt_test_edge_dest = self.vertex(test_edge.dest());
                const pt_next_edge_dest = self.vertex(test_edge.onext().dest());
                if (funcs.rightOf(pt_test_edge_dest, pt_end, pt_start) and
                    funcs.leftOf(pt_next_edge_dest, pt_end, pt_start))
                {
                    break;
                }
                test_edge = test_edge.onext();
            } else {
                std.debug.panic("Collinear point was found, this should not be possible", .{});
            }
            var i: u32 = 0;
            while (test_edge.dest() != start.org() and i < loop_protection) {
                i += 1;
                const pt_test_edge_start = self.vertex(test_edge.org());
                const pt_test_edge_end = self.vertex(test_edge.dest());
                if (funcs.rightOf(pt_test_edge_start, pt_end, pt_start) and
                    funcs.leftOf(pt_test_edge_end, pt_end, pt_start))
                {
                    try to_delete.put(arena, test_edge.deref(), {});
                    test_edge = test_edge.sym().lnext();
                } else {
                    try boundary_edges.append(arena, test_edge);
                    test_edge = test_edge.lnext();
                }
            }
            if (i == loop_protection) unreachable;

            try to_delete.put(arena, test_edge.deref(), {});

            // var last_vertex = test_edge.org();

            // Triangle before the polygonal hole
            var prev_triangle = polygon_start;
            for (boundary_edges.items[0..]) |item| {
                const fan_triangle = try self.triangleMake(.{
                    .org = item.org(),
                    .dest = item.dest(),
                    .apex = start.org(),
                });

                fan_triangle.lprev().connect(prev_triangle);
                fan_triangle.connect(item.sym());

                if (item.org() == end.org()) {
                    const edge = try self.edgeMake(fan_triangle.lprev());
                    edge.constrainedSet(true);
                }

                prev_triangle = fan_triangle.lnext();
            }

            prev_triangle.connect(polygon_end);

            for (to_delete.keys()) |item| {
                self.triangleDelete(item);
            }

            try self.refresh();
        }

        pub fn locate(self: *Self, point: hym.Vec2) ?Triangle.Ref {
            const key: BucketKey = .{ .x = @intFromFloat(point.x()), .y = @intFromFloat(point.y()) };
            const bucket = self.buckets.get(key) orelse return null;

            var mb_node = bucket.first;
            while (mb_node) |node| : (mb_node = node.next) {
                const triangle = node.data;
                std.debug.assert(triangle.deref() != self.dummy_triangle);
                std.debug.assert(triangle.org() != .none);
                std.debug.assert(triangle.dest() != .none);
                std.debug.assert(triangle.apex() != .none);

                if (point.eql(self.vertex(triangle.org()))) {
                    return triangle;
                } else if (point.eql(self.vertex(triangle.dest()))) {
                    return triangle.lnext();
                } else if (point.eql(self.vertex(triangle.apex()))) {
                    return triangle.lprev();
                } else {
                    const a = !funcs.rightOf(point, self.vertex(triangle.org()), self.vertex(triangle.dest()));
                    const b = !funcs.leftOf(point, self.vertex(triangle.onext().org()), self.vertex(triangle.onext().dest()));
                    const c = !funcs.leftOf(point, self.vertex(triangle.dprev().org()), self.vertex(triangle.dprev().dest()));
                    if (a and b and c) return triangle;
                }
            }

            return null;
        }

        fn flip(edge: Triangle.Ref) void {
            const right = edge.org();
            const left = edge.dest();
            const bot = edge.apex();
            const edge_sym = edge.sym();
            const far = edge_sym.apex();

            const top_left = edge_sym.lprev();
            const top_right = edge_sym.lnext();
            const bot_left = edge.lnext();
            const bot_right = edge.lprev();
            const top_left_casing = top_left.sym();
            const top_right_casing = top_right.sym();
            const bot_left_casing = bot_left.sym();
            const bot_right_casing = bot_right.sym();

            top_left.connect(bot_left_casing);
            bot_left.connect(bot_right_casing);
            bot_right.connect(top_right_casing);
            top_right.connect(top_left_casing);

            // edge remains connected to edge_sym

            edge.orgSet(far);
            edge.destSet(bot);
            edge.apexSet(right);

            edge_sym.orgSet(bot);
            edge_sym.destSet(far);
            edge_sym.apexSet(left);
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
                const det = determinant(self.vertex(s1), self.vertex(s2), self.vertex(s3));

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
                    const ldi_dest = self.vertex(ldi.dest());
                    const ldi_apex = self.vertex(ldi.apex());
                    const rdi_org = self.vertex(rdi.org());
                    const rdi_apex = self.vertex(rdi.apex());
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
                    const l_valid = funcs.leftOf(self.vertex(upper_left), self.vertex(lower_left), self.vertex(lower_right));
                    const r_valid = funcs.leftOf(self.vertex(upper_right), self.vertex(lower_left), self.vertex(lower_right));

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

                                // lcand new neighbors:
                                //   0: null
                                //   1: next_edge.lprev()
                                //   2: side_casing
                                // next_edge new neighbors:
                                //   0: outer_casing
                                //   1: top_casing
                                //   2: lcand.lprev()

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
                            var edge_needs_flip = funcs.incircle(
                                self.vertex(lower_left),
                                self.vertex(lower_right),
                                self.vertex(upper_right),
                                self.vertex(next_apex),
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

                                // rcand new neighbors:
                                //   0: null
                                //   1: side_casing
                                //   2: next_edge.lprev()
                                // next_edge new neighbors:
                                //   0: outer_casing
                                //   1: top_casing
                                //   2: rcand.lnext()

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

        pub const TrianglePoints = struct {
            org: VertexHandle,
            dest: VertexHandle,
            apex: VertexHandle,
        };

        fn triangleMake(self: *Self, p: TrianglePoints) !Triangle.Ref {
            const triangle = try self.pool.create();

            triangle.* = .{
                .neighbor = @splat(.init(self.dummy_triangle)),
                .vertices = .{ p.apex, p.org, p.dest },
            };

            return .init(triangle);
        }

        fn triangleDelete(self: *Self, triangle: *Triangle) void {
            for (0..3) |i| {
                const neighbor = triangle.neighbor[i];
                if (neighbor.deref() == self.dummy_triangle) continue;

                if (neighbor.sym().deref() == triangle) {
                    neighbor.deref().neighbor[neighbor.rot] = .init(self.dummy_triangle);
                }
            }

            self.pool.destroy(triangle);
        }

        fn edgeMake(self: *Self, triangle: Triangle.Ref) !EdgeExtra.Ref {
            const extra = try self.edge_pool.create();
            extra.* = .{ .triangles = .{ triangle, triangle.sym() } };
            const edge_ref: EdgeExtra.Ref = .{
                .edge = extra,
                .rot = 0,
                .a = 0,
                .b = 1,
            };
            triangle.deref().edges[triangle.rot] = edge_ref;
            triangle.sym().deref().edges[triangle.sym().rot] = edge_ref.sym();
            return edge_ref;
        }

        pub fn enumerate(self: *const Self, start: Triangle.Ref) ![]Triangle.Ref {
            var ara: std.heap.ArenaAllocator = .init(self.allocator);
            const arena = ara.allocator();
            defer ara.deinit();

            // Enumerate all edges;
            var triangles: std.ArrayListUnmanaged(Triangle.Ref) = .empty;
            var real_triangles: std.ArrayListUnmanaged(Triangle.Ref) = .empty;
            var stack: std.ArrayListUnmanaged(Triangle.Ref) = .empty;

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
                    if (tri.deref().neighbor[n].deref() != self.dummy_triangle) {
                        try stack.append(arena, tri.deref().neighbor[n]);
                    }
                }
            }

            for (triangles.items) |tri| {
                tri.deref().visited = false;
            }

            return try self.allocator.dupe(Triangle.Ref, real_triangles.items);
        }

        fn pointValid(self: *const Self, cand: VertexHandle, base: Triangle.Ref) bool {
            return funcs.rightOf(self.vertex(cand), self.vertex(base.org()), self.vertex(base.dest()));
        }

        pub fn refresh(self: *Self) !void {
            // Put triangles into buckets for faster lookup.
            // A triangle is put in every bucket that has x,y value inside
            // the triangle's bounding box.
            const gpa = self.allocator;
            const all_triangles = try self.enumerate(self.left_edge);
            defer gpa.free(all_triangles);

            gpa.free(self.indices);
            self.indices = try gpa.alloc(u32, all_triangles.len * 3);

            _ = self.bucket_allocator.reset(.retain_capacity);
            self.buckets.clearRetainingCapacity();

            for (all_triangles, 0..) |tri, i| {
                const apex = self.vertex(tri.apex());
                const org = self.vertex(tri.org());
                const dest = self.vertex(tri.dest());

                const min_x: usize = @intFromFloat(@min(@min(apex.x(), org.x()), dest.x()));
                const min_y: usize = @intFromFloat(@min(@min(apex.y(), org.y()), dest.y()));
                const max_x: usize = @intFromFloat(@max(@max(apex.x(), org.x()), dest.x()));
                const max_y: usize = @intFromFloat(@max(@max(apex.y(), org.y()), dest.y()));

                for (min_x..max_x + 1) |x| for (min_y..max_y + 1) |y| {
                    const key: BucketKey = .{ .x = x, .y = y };
                    const entry = try self.buckets.getOrPut(gpa, key);
                    const node = try self.bucket_allocator.create();
                    node.* = .{ .data = tri };
                    if (!entry.found_existing) {
                        entry.value_ptr.* = .{};
                    }
                    entry.value_ptr.prepend(node);
                };

                self.indices[i * 3 + 0] = @intCast(tri.apex().unwrap());
                self.indices[i * 3 + 1] = @intCast(tri.org().unwrap());
                self.indices[i * 3 + 2] = @intCast(tri.dest().unwrap());
            }
        }

        const RecurseItem = struct {
            edge: Triangle.Ref,
            left_limit: f32 = 0,
            right_limit: f32 = 1,
        };

        pub fn visibility(self: *Self, origin: hym.Vec2, visibility_allocator: std.mem.Allocator) !Visibility {
            var ara: std.heap.ArenaAllocator = .init(self.allocator);
            const arena = ara.allocator();
            defer ara.deinit();

            var stack: std.ArrayListUnmanaged(RecurseItem) = .empty;

            var visibility_edges: std.ArrayListUnmanaged([2]hym.Vec2) = .empty;

            const tri = self.locate(origin).?;
            inline for (.{ tri.sym(), tri.lprev().sym(), tri.lnext().sym() }) |origin_edge| {
                try stack.append(arena, .{ .edge = origin_edge });
            }

            while (stack.items.len > 0) {
                const item = stack.pop().?;
                const edge = item.edge;
                const left = item.left_limit;
                const right = item.right_limit;

                if (edge.constrained()) {
                    const extra = edge.edgeExtra().?
                        .limitLeft(left)
                        .limitRight(right)
                        .sym();
                    try visibility_edges.append(arena, self.segment(extra));
                    continue;
                }

                const org_pos = self.vertex(edge.org());
                const dest_pos = self.vertex(edge.dest());
                const apex_pos = self.vertex(edge.apex());

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


            return .{
                .origin = origin,
                .segments = try visibility_allocator.dupe([2]hym.Vec2, visibility_edges.items),
            };
        }
    };
}

// test "insert clockwise base case" {
//     const tal = std.testing.allocator;
//     var arena: std.heap.ArenaAllocator = .init(tal);
//     defer arena.deinit();
//     var verts = [_]hym.Vec2{
//         .of(1, 0),
//         .of(2, 3),
//         .of(3, 0),
//     };
//     var t: Subdivision(
//         hym.Vec2,
//     ) = try .init(arena.allocator());
//     const l, _ = try t.triangulate(arena.allocator(), &verts);
//     const tris = try t.enumerate(arena.allocator(), l);
//     const a: VertexHandle = .make(0);
//     const b: VertexHandle = .make(1);
//     const c: VertexHandle = .make(2);
//     try std.testing.expectEqual(.{ b, a, c }, .{ tris[0].org(), tris[0].dest(), tris[0].apex() });
// }
//
// test "insert counter-clockwise base case" {
//     const tal = std.testing.allocator;
//     var arena: std.heap.ArenaAllocator = .init(tal);
//     defer arena.deinit();
//     var verts = [_]hym.Vec2{
//         .of(1, 3),
//         .of(2, 0),
//         .of(3, 3),
//     };
//     var t: Subdivision = try .init(arena.allocator());
//     const l, _ = try t.triangulate(arena.allocator(), &verts);
//     const tris = try t.enumerate(arena.allocator(), l);
//     const a: VertexHandle = .make(0);
//     const b: VertexHandle = .make(1);
//     const c: VertexHandle = .make(2);
//     try std.testing.expectEqual(.{ c, a, b }, .{ tris[0].org(), tris[0].dest(), tris[0].apex() });
// }

test "insert vertical line" {
    const tal = std.testing.allocator;
    var arena: std.heap.ArenaAllocator = .init(tal);
    defer arena.deinit();
    var verts = [_]hym.Vec2{
        .of(0, 1),
        .of(0, 2),
        .of(0, 3),
        .of(0, 4),
        .of(0, 5),
        .of(0, 6),
        .of(1, 1),
        .of(1, 2),
        .of(1, 3),
        .of(1, 4),
        .of(1, 5),
        .of(1, 6),
        .of(2, 1),
        .of(2, 2),
        .of(2, 3),
        .of(2, 4),
        .of(2, 5),
        .of(2, 6),
    };
    var t: Subdivision(hym.Vec2, null) = try .init(arena.allocator());
    _ = try t.triangulate(arena.allocator(), &verts);
}

// test "insert collinear" {
//     const tal = std.testing.allocator;
//     var arena: std.heap.ArenaAllocator = .init(tal);
//     defer arena.deinit();
//     var verts = [_]hym.Vec2{
//         .of(1, 0),
//         .of(2, 0),
//         .of(3, 0),
//     };
//     var t: Subdivision(hym.Vec2) = try .init(arena.allocator());
//     const l, _ = try t.triangulate(&verts);
//     const tris = try t.enumerate(arena.allocator(), l);
//
//     const a: VertexHandle = .make(0);
//     const b: VertexHandle = .make(1);
//     const c: VertexHandle = .make(2);
//
//     try std.testing.expectEqualDeep(&[_][3]VertexHandle{
//         .{ b, a, .none },
//         .{ .none, a, b },
//         .{ .none, b, c },
//         .{ c, b, .none },
//     }, tris);
// }

// test "insert w/ merge" {
//     const tal = std.testing.allocator;
//     var arena: std.heap.ArenaAllocator = .init(tal);
//     defer arena.deinit();
//     var verts = [_]hym.Vec2{
//         .of(0, 0),
//         .of(0.1, 0.5),
//         .of(0.3, 1),
//         .of(0.7, 1),
//         .of(0.9, 0.5),
//         .of(1, 0),
//     };
//     var t: Subdivision = try .init(arena.allocator());
//     const l, _ = try t.triangulate(arena.allocator(), &verts);
// }

// test "insert with constraint" {
//     const tal = std.testing.allocator;
//     var arena: std.heap.ArenaAllocator = .init(tal);
//     defer arena.deinit();
//     var verts = [_]hym.Vec2{
//         .of(0, 0),
//         .of(0, 3),
//         .of(0.2, 0.2),
//         .of(0.2, 2.8),
//         .of(0.3, 2.7),
//         .of(0.3, 2.9),
//         .of(2.7, 2.7),
//         .of(2.7, 2.9),
//         .of(2.8, 0.2),
//         .of(2.8, 2.8),
//         .of(3, 0),
//         .of(3, 3),
//     };
//     var t: Subdivision = try .init(arena.allocator());
//     _ = try t.triangulate(arena.allocator(), &verts);
// }
//
// test "locate" {
//     const tal = std.testing.allocator;
//     var arena: std.heap.ArenaAllocator = .init(tal);
//     defer arena.deinit();
//     var verts = [_]hym.Vec2{
//         .of(0, 0),
//         .of(0, 3),
//         .of(0.2, 0.2),
//         .of(0.2, 2.8),
//         .of(0.3, 2.7),
//         .of(0.3, 2.9),
//         .of(2.7, 2.7),
//         .of(2.7, 2.9),
//         .of(2.8, 0.2),
//         .of(2.8, 2.8),
//         .of(3, 0),
//         .of(3, 3),
//     };
//     var t: Subdivision = try .init(arena.allocator());
//     _ = try t.triangulate(arena.allocator(), &verts);
//
//     const tri = t.locate(.of(0.2, 0.2));
//     try std.testing.expect(tri != null);
//     try std.testing.expectEqual(
//         [3]VertexHandle{ .make(2), .make(8), .make(4) },
//         .{ tri.?.org(), tri.?.dest(), tri.?.apex() },
//     );
// }
