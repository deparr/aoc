const std = @import("std");

pub const allocator = std.heap.smp_allocator;

var iobuf: [4096]u8 = undefined;

pub fn collectStdin(gpa: std.mem.Allocator) ![]u8 {
    var stdin = std.fs.File.stdin();
    var reader = &stdin.reader(&iobuf).interface;
    return reader.allocRemaining(gpa, 1024 * 1024 * 10);
}

