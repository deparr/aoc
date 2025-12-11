const std = @import("std");
const adlib = @import("adlib.zig");

fn partOne(input: []const u8) u32 {
    var line_it = std.mem.tokenizeScalar(u8, input, '\n');
    while (line_it.next()) |line| {
        std.debug.assert(line[0] == '[');
        const close_bracket = std.mem.indexOfScalarPos(u8, line, 1, ']').?;
        std.debug.print("{d} ", .{ close_bracket });
        var machine_state: u10 = 0;
        var parsed: [10]u8 = .{ '.' } ** 10;
        for (1..close_bracket) |i| {
            if (line[i] == '#') {
                const bp = @as(u4, 9) - @as(u4, @truncate(i));
                parsed[i - i] = '#';
                machine_state |= @as(u10, 1) << bp;
            }
        }


        std.debug.print("{s} => {s}\n", .{ line[1..close_bracket], parsed[0..close_bracket - 1] });
    }
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
    std.debug.print("part one: {d}\npart two: {d}\n", .{ res_1, res_2 });
    gpa.free(input);
}

