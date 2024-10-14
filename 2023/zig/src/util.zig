const std = @import("std");

pub fn getFullInput(ally: std.mem.Allocator) ![]u8 {
    const stdin_handle = std.io.getStdIn().reader();
    var br = std.io.bufferedReader(stdin_handle);
    const stdin = br.reader();
    return stdin.readAllAlloc(ally, 1 << 16);
}
