const std = @import("std");
const util = @import("util.zig");

const print = std.debug.print;

fn getInput(ally: std.mem.Allocator) ![]u8 {
    const stdin_handle = std.io.getStdIn().reader();
    var br = std.io.bufferedReader(stdin_handle);
    const stdin = br.reader();
    return stdin.readAllAlloc(ally, 1 << 16);
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const ally = arena.allocator();

    const input = try util.getFullInput(ally);
    print("{d}\n", .{input[0]});
}

