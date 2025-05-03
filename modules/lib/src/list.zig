const std = @import("std");

pub fn ReverseIterator(T: type) type {
    return struct {
        slice: []T,
        idx: usize,

        pub fn next(self: *ReverseIterator(T)) ?*T {
            if (self.idx == 0) return null;
            self.idx -= 1;
            return &self.slice[self.idx];
        }
    };
}

pub fn reverse(slice: anytype) ReverseIterator(SliceChild(@TypeOf(slice))) {
    return ReverseIterator(SliceChild(@TypeOf(slice))){ .slice = slice, .idx = slice.len };
}

fn SliceChild(slice: type) type {
    return @typeInfo(slice).pointer.child;
}

pub fn swapRemovePtr(list: anytype, item: anytype) SliceChild(@TypeOf(list.items)) {
    const Child = SliceChild(@TypeOf(list.items));
    std.debug.assert(@TypeOf(list) == *std.ArrayListUnmanaged(Child));
    std.debug.assert(SliceChild(@TypeOf(list.items)) == @typeInfo(@TypeOf(item)).pointer.child);
    return list.swapRemove(item - list.items.ptr);
}
