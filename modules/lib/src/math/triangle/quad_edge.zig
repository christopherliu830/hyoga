const std = @import("std");
const hym = @import("../math.zig");
const root = @import("root.zig");
const funcs = @import("funcs.zig");

const VertexHandle = root.VertexHandle;
const ccw = funcs.ccw;
const pointRightOf = funcs.rightOf;
const pointLeftOf = funcs.leftOf;
const determinant = funcs.determinant;

/// Quad edge data structures
/// Refer to Guibas & Stolfi
pub const Edge = struct {
    vert: [4]VertexHandle = @splat(.none),
    next: [4]Ref,
    visited: [2]bool = @splat(false),

    pub const Pool = std.heap.MemoryPool(Edge);

    pub const Ref = struct {
        edge: *Edge,
        rot: u2 = 0,

        pub fn eql(a: Ref, b: Ref) bool {
            return a.edge == b.edge and a.rot == b.rot;
        }

        pub fn format(value: Ref, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
            _ = fmt;
            if (value.org() != .none) {
                try std.fmt.formatInt(@intFromEnum(value.org()), 10, .lower, options, writer);
            } else {
                try writer.writeAll("N");
            }
            try writer.writeAll("->");
            if (value.dest() != .none) {
                try std.fmt.formatInt(@intFromEnum(value.dest()), 10, .lower, options, writer);
            } else {
                try writer.writeAll("N");
            }
            try writer.writeAll("@");
            try std.fmt.formatInt(@intFromPtr(value.edge) % 0xffff, 16, .lower, .{}, writer);
        }

        fn rotate(self: Ref, times: comptime_int) Ref {
            return .{ .edge = self.edge, .rot = wrapAdd(self.rot, times) };
        }

        fn sym(self: Ref) Ref {
            return self.rotate(2);
        }

        fn org(self: Ref) VertexHandle {
            return self.edge.vert[self.rot];
        }

        fn dest(self: Ref) VertexHandle {
            return self.edge.vert[wrapAdd(self.rot, 2)];
        }

        fn orgSet(self: Ref, hdl: VertexHandle) void {
            self.edge.vert[self.rot] = hdl;
        }

        fn destSet(self: Ref, hdl: VertexHandle) void {
            self.edge.vert[wrapAdd(self.rot, 2)] = hdl;
        }

        fn onext(self: Ref) Ref {
            return self.edge.next[self.rot];
        }

        fn oprev(self: Ref) Ref {
            return self.rotate(1).onext().rotate(1);
        }

        fn lnext(self: Ref) Ref {
            return self.rotate(-1).onext().rotate(1);
        }

        fn rnext(self: Ref) Ref {
            return self.rotate(1).onext().rotate(-1);
        }

        fn lprev(self: Ref) Ref {
            return self.onext().sym();
        }

        fn rprev(self: Ref) Ref {
            return self.sym().onext();
        }

        fn dprev(self: Ref) Ref {
            return self.rotate(-1).onext().rotate(-1);
        }

        /// Splice as explained by Guibas and Stolfi:
        /// Splice affects the two edge rings a.org and b.org, and, independently, the two edge
        /// rings a.left and b.left.
        ///
        /// (a) if the two rings are distinct, Splice will combine them into one;
        /// (b) if the two are exactly the same ring, Splice will break it in two separate pieces;
        /// (c) if the two are the same ring taken with opposite orientations, Splice will
        /// flip (and reverse the order) of a segment of that ring.
        fn splice(a: Ref, b: Ref) void {
            const alpha = a.onext().rotate(1);
            const beta = b.onext().rotate(1);

            std.mem.swap(Ref, &a.edge.next[a.rot], &b.edge.next[b.rot]);
            std.mem.swap(Ref, &alpha.edge.next[alpha.rot], &beta.edge.next[beta.rot]);
        }

        fn connect(pool: *Edge.Pool, a: Ref, b: Ref) !Ref {
            var e: Ref = try Edge.create(pool);
            e.orgSet(a.dest());
            e.destSet(b.org());
            splice(e, a.lnext());
            splice(e.sym(), b);
            return e;
        }

        fn delete(pool: *Edge.Pool, e: Ref) void {
            splice(e, e.oprev());
            splice(e.sym(), e.sym().oprev());
            pool.destroy(e.edge);
        }

        fn swap(e: Ref) void {
            const a = e.oprev();
            const b = e.sym().oprev();

            // Remove e from graph
            splice(e, a);
            splice(e.sym(), b);
            // Connect e back at the required position
            splice(e, a.lnext());
            splice(e.sym(), b.lnext());
            e.orgSet(a.dest());
            e.destSet(b.dest());
        }

        fn visit(e: Ref) void {
            std.debug.assert(e.rot == 0 or e.rot == 2);
            e.edge.visited[e.rot / 2] = true;
        }

        fn visited(e: Ref) bool {
            std.debug.assert(e.rot == 0 or e.rot == 2);
            return e.edge.visited[e.rot / 2];
        }
    };

    fn create(pool: *Edge.Pool) !Edge.Ref {
        const record = try pool.create();

        const e: Edge.Ref = .{ .edge = record, .rot = 0 };

        record.* = .{ .next = .{
            .{ .edge = record, .rot = 0 },
            .{ .edge = record, .rot = 3 },
            .{ .edge = record, .rot = 2 },
            .{ .edge = record, .rot = 1 },
        } };

        return e;
    }
};

pub const Subdivision = struct {
    left_edge: Edge.Ref,
    right_edge: Edge.Ref,
    last_located_edge: Edge.Ref,
    edge_pool: Edge.Pool,
    verts: std.ArrayListUnmanaged(hym.Vec2) = .empty,

    pub fn delaunay(gpa: std.mem.Allocator, verts: []hym.Vec2) !Subdivision {
        const Context = struct {
            fn lessThan(_: @This(), a: hym.Vec2, b: hym.Vec2) bool {
                if (a.x() == b.x()) return a.y() < b.y() else return a.x() < b.x();
            }
        };

        std.sort.heap(hym.Vec2, verts, Context{}, Context.lessThan);

        var edge_pool: Edge.Pool = .init(gpa);

        const l, const r = try triangulate(&edge_pool, verts, 0, verts.len);

        return .{
            .edge_pool = edge_pool,
            .left_edge = l,
            .right_edge = r,
            .last_located_edge = l,
            .verts = .fromOwnedSlice(gpa.dupe(hym.Vec2, verts) catch unreachable),
        };
    }

    fn discover(gpa: std.mem.Allocator, stack: *std.ArrayListUnmanaged(Edge.Ref), e: Edge.Ref) !void {
        e.visit();
        var neighbor = e.onext();
        while (!neighbor.eql(e)) : (neighbor = neighbor.onext()) {
            if (!neighbor.visited()) {
                try stack.append(gpa, neighbor);
            }
        }
    }

    fn enumerate(s: *const Subdivision, gpa: std.mem.Allocator) ![][3]usize {
        // Enumerate all edges;
        var triangles: std.ArrayListUnmanaged([3]usize) = .empty;
        var stack: std.ArrayListUnmanaged(Edge.Ref) = .empty;
        defer stack.deinit(gpa);

        try stack.append(gpa, s.left_edge);
        while (stack.items.len > 0) {
            const tri_start = stack.pop().?;
            if (tri_start.visited()) {
                continue;
            }

            tri_start.visit();

            if (tri_start.lnext().lnext().dest() == tri_start.org()) {
                var tri_verts: [3]VertexHandle = @splat(.none);
                tri_verts = .{
                    tri_start.org(),
                    tri_start.lnext().org(),
                    tri_start.lnext().dest(),
                };

                try discover(gpa, &stack, tri_start);

                var e = tri_start.lnext();
                var i: usize = 1;
                // Traverse the ring
                while (!e.eql(tri_start)) : (e = e.lnext()) {
                    tri_verts[i] = e.org();
                    i += 1;

                    try discover(gpa, &stack, e);
                }

                triangles.append(gpa, .{
                    @intFromEnum(tri_verts[0]),
                    @intFromEnum(tri_verts[1]),
                    @intFromEnum(tri_verts[2]),
                }) catch unreachable;
            }
        }

        return try triangles.toOwnedSlice(gpa);
    }

    fn triangulate(edge_pool: *Edge.Pool, verts: []const hym.Vec2, l: usize, r: usize) ![2]Edge.Ref {
        // One edge
        if (r - l == 2) {
            const a = try Edge.create(edge_pool);
            a.orgSet(.make(l));
            a.destSet(.make(l + 1));
            return .{ a, a.sym() };
        }

        // One triangle
        else if (r - l == 3) {
            const a = try Edge.create(edge_pool);
            const b = try Edge.create(edge_pool);

            Edge.Ref.splice(a.sym(), b); // (a, b) becomes a -> b -> ...

            a.orgSet(.make(l));
            a.destSet(.make(l + 1));
            b.orgSet(.make(l + 1));
            b.destSet(.make(l + 2));

            if (ccw(verts[l], verts[l + 1], verts[l + 2])) {
                _ = try Edge.Ref.connect(edge_pool, b, a);
                return .{ a, b.sym() };
            } else if (ccw(verts[l], verts[l + 2], verts[l + 1])) {
                const c = try Edge.Ref.connect(edge_pool, b, a);
                return .{ c.sym(), c };
            } else {
                return .{ a, b.sym() };
            }
        } else {
            const mid = (r + l) / 2;
            var ldo, var ldi = try triangulate(edge_pool, verts, l, mid);
            var rdi, var rdo = try triangulate(edge_pool, verts, mid, r);

            while (true) {
                if (leftOf(verts, rdi.org(), ldi)) {
                    ldi = ldi.lnext();
                } else if (rightOf(verts, ldi.org(), rdi)) {
                    rdi = rdi.rprev();
                } else {
                    break;
                }
            }

            var basel = try Edge.Ref.connect(edge_pool, rdi.sym(), ldi);
            if (ldi.org() == ldo.org()) {
                ldo = basel.sym();
            }
            if (rdi.org() == rdo.org()) {
                rdo = basel;
            }

            while (true) {
                var lcand = basel.sym().onext();
                if (validCrossEdge(verts, lcand, basel)) {
                    while (incircle(
                        verts,
                        basel.dest(),
                        basel.org(),
                        lcand.dest(),
                        lcand.onext().dest(),
                    )) {
                        const t: Edge.Ref = lcand.onext();
                        Edge.Ref.delete(edge_pool, lcand);
                        lcand = t;
                    }
                }

                var rcand = basel.oprev();
                if (validCrossEdge(verts, rcand, basel)) {
                    while (incircle(
                        verts,
                        basel.dest(),
                        basel.org(),
                        rcand.dest(),
                        rcand.oprev().dest(),
                    )) {
                        const t: Edge.Ref = rcand.oprev();
                        Edge.Ref.delete(edge_pool, rcand);
                        rcand = t;
                    }
                }

                const l_valid = validCrossEdge(verts, lcand, basel);
                const r_valid = validCrossEdge(verts, rcand, basel);
                // basel is the upper common tangent
                if (!l_valid and !r_valid) {
                    break;
                }
                const r_incircle = incircle(verts, lcand.dest(), lcand.org(), rcand.org(), rcand.dest());

                if (!l_valid or (r_valid and r_incircle)) {
                    basel = try Edge.Ref.connect(edge_pool, rcand, basel.sym());
                } else {
                    basel = try Edge.Ref.connect(edge_pool, basel.sym(), lcand.sym());
                }
            }
            return .{ ldo, rdo };
        }
    }

    fn locate(s: *Subdivision, point: hym.Vec2) Edge.Ref {
        var e = s.last_located_edge;
        while (true) {
            const org = s.verts.items[e.org().unwrap()];
            const dest = s.verts.items[e.dest().unwrap()];

            const verts = s.verts.items;
            if (point.eql(org)) {
                return e;
            } else if (point.eql(dest)) {
                return e.sym();
            } else if (pointRightOf(
                point,
                verts[e.org().unwrap()],
                verts[e.dest().unwrap()],
            )) {
                e = e.sym();
            } else if (!pointRightOf(
                point,
                verts[e.onext().org().unwrap()],
                verts[e.onext().dest().unwrap()],
            )) {
                e = e.onext();
            } else if (pointLeftOf(
                point,
                verts[e.dprev().org().unwrap()],
                verts[e.dprev().dest().unwrap()],
            )) {
                e = e.dprev();
            } else {
                s.last_located_edge = e;
                return e;
            }
        }

        return .{};
    }

    fn insert(s: *Subdivision, gpa: std.mem.Allocator, point: hym.Vec2) !void {
        var edge = locate(s, point);
        s.last_located_edge = edge;

        const org = s.verts.items[edge.org().unwrap()];
        const dest = s.verts.items[edge.dest().unwrap()];

        if (point.eql(org) or point.eql(dest)) {
            return;
        }

        const a = point;
        const b = org;
        const c = dest;

        const det = (b.x() - a.x()) * (c.y() - a.y()) -
            (b.y() - a.y()) * (c.x() - a.x());

        if (det == 0) {
            const t = edge;
            Edge.Ref.delete(&s.edge_pool, edge);
            edge = t;
        }

        try s.verts.append(gpa, point);
        const v: VertexHandle = .make(s.verts.items.len - 1);

        const spoke_first = edge.org();
        var base = try Edge.create(&s.edge_pool);
        base.orgSet(spoke_first);
        base.destSet(v);
        Edge.Ref.splice(base, edge);

        while (edge.dest() != spoke_first) {
            base = try Edge.Ref.connect(&s.edge_pool, edge, base.sym());
            edge = base.oprev();
        }
        edge = base.oprev();

        while (true) {
            const t = edge.oprev();
            if (rightOf(s.verts.items, t.dest(), edge) and incircle(s.verts.items, edge.org(), t.dest(), edge.dest(), v)) {
                Edge.Ref.swap(edge);
                edge = t;
            } else if (edge.org() == spoke_first) {
                return;
            } else {
                edge = edge.onext().lprev();
            }
        }
    }

    fn insertConstraint(s: *Subdivision, start: Edge.Ref, end: Edge.Ref) !void {
        var next_edge = start.onext();
        while (next_edge.dest() != start.dest()) : (next_edge = next_edge.onext()) {
            if (next_edge.dest() == end.org()) {
                // Edge already exists, nothing to do.
                return;
            }
        }

        const constraint = try Edge.Ref.connect(&s.edge_pool, start, end);

        // Delete all edges that cross the new edge
        next_edge = start.onext();

        while (next_edge.dest() != constraint.dest()) {
            const cross_cand = next_edge.rprev();
            const r = rightOf(s.verts.items, start.org(), cross_cand);
            const l = leftOf(s.verts.items, end.org(), cross_cand);
            if (l and r) {
                Edge.Ref.delete(&s.edge_pool, cross_cand);
            } else {
                next_edge = cross_cand;
            }
        }
    }

    fn rightOf(verts: []const hym.Vec2, a: VertexHandle, e: Edge.Ref) bool {
        return ccw(verts[a.unwrap()], verts[e.dest().unwrap()], verts[e.org().unwrap()]);
    }

    fn leftOf(verts: []const hym.Vec2, a: VertexHandle, e: Edge.Ref) bool {
        return ccw(verts[a.unwrap()], verts[e.org().unwrap()], verts[e.dest().unwrap()]);
    }

    fn validCrossEdge(verts: []const hym.Vec2, e: Edge.Ref, base: Edge.Ref) bool {
        return rightOf(verts, e.dest(), base);
    }
};

inline fn wrapAdd(rot: u2, x: comptime_int) u2 {
    return @intCast(@mod(@as(i32, rot) + x, 4));
}

inline fn incircle(verts: []const hym.Vec2, ah: VertexHandle, bh: VertexHandle, ch: VertexHandle, dh: VertexHandle) bool {
    const av = verts[ah.unwrap()];
    const bv = verts[bh.unwrap()];
    const cv = verts[ch.unwrap()];
    const dv = verts[dh.unwrap()];

    return funcs.incircle(av, bv, cv, dv);
}

test "create" {
    const tal = std.testing.allocator;
    var arena: std.heap.ArenaAllocator = .init(tal);
    defer arena.deinit();
    var verts = [_]hym.Vec2{
        .of(1, 0),
        .of(2, 1),
        .of(2.5, 3),
        .of(3, 0),
        .of(4, 1),
        .of(5, 2),
    };

    var tri_map: Subdivision = try .delaunay(arena.allocator(), &verts);
    const triangles = tri_map.enumerate(arena.allocator());

    try std.testing.expectEqualDeep(triangles, &([_][3]usize{
        .{ 0, 3, 1 },
        .{ 1, 2, 0 },
        .{ 2, 4, 5 },
        .{ 4, 1, 3 },
        .{ 1, 4, 2 },
    }));
}

test "insertion" {
    const tal = std.testing.allocator;
    var arena: std.heap.ArenaAllocator = .init(tal);
    defer arena.deinit();
    var verts = [_]hym.Vec2{
        .of(1, 0),
        .of(2, 1),
        .of(2.5, 3),
        .of(3, 0),
        .of(4, 1),
        .of(5, 2),
    };
    var tri_map: Subdivision = try .delaunay(arena.allocator(), &verts);
    try tri_map.insert(arena.allocator(), .of(3.5, 2.5));
    const triangles = try tri_map.enumerate(arena.allocator());
    try std.testing.expectEqualDeep(triangles, &([_][3]usize{
        .{ 0, 3, 1 },
        .{ 1, 2, 0 },
        .{ 2, 6, 5 },
        .{ 5, 6, 4 },
        .{ 4, 1, 3 },
        .{ 1, 6, 2 },
        .{ 6, 1, 4 },
    }));
}
