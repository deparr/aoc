const std = @import("std");

pub const allocator = std.heap.smp_allocator;

var iobuf: [4096]u8 = undefined;

pub fn collectStdin(gpa: std.mem.Allocator) ![]u8 {
    var stdin = std.fs.File.stdin().reader(&iobuf);
    var reader = &stdin.interface;
    return reader.allocRemaining(gpa, .unlimited);
}
