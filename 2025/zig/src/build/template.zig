const std = @import("std");
const adlib = @import("adlib.zig");

fn partOne(input: []const u8) u32 {
    _ = input;
    return 0;
}

fn partTwo(input: []const u8) u32 {
    _ = input;
    return 0;
}

pub fn main() !void {
    const gpa = adlib.allocator;
    const input = try adlib.collectStdin(gpa);
    const res_1 = partOne(input);
    const res_2 = partTwo(input);
    std.debug.print("part one: {d}\npart two {d}\n", .{ res_1, res_2 });
    gpa.free(input);
}

