const std = @import("std");
const adlib = @import("adlib.zig");

fn partOne(input: *std.Io.Reader) !u32 {
    _ = input;
    return 0;
}

fn partTwo(input: *std.Io.Reader) !u32 {
    _ = input;
    return 0;
}

pub fn main() !void {
    var buf: [4096]u8 = undefined; 
    const input = try adlib.inputFile("DAY");
    var reader = input.reader(&buf);
    const res_1 = try partOne(&reader.interface);
    try reader.seekTo(0);
    const res_2 = try partTwo(&reader.interface);
    std.debug.print("part one: {d}\npart two: {d}\n", .{ res_1, res_2 });
    input.close();
}

