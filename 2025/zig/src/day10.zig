const std = @import("std");
const adlib = @import("adlib.zig");

fn partOne(input: *std.Io.Reader) !u32 {
    while (true) {
        const line_op = input.takeDelimiter('\n') catch |err| switch (err) {
            error.StreamTooLong => break,
            else => return err,
        };
        if (line_op == null) break;

        const line = line_op.?;
        std.debug.assert(line[0] == '[');
        const close_bracket = std.mem.indexOfScalarPos(u8, line, 1, ']').?;
        std.debug.print("{d:02} ", .{close_bracket});
        var machine_state: u10 = 0;
        var parsed: [10]u8 = @splat('.');
        for (1..close_bracket) |i| {
            if (line[i] == '#') {
                const bp = @as(u4, 10) - @as(u4, @truncate(i));
                parsed[i - 1] = '#';
                machine_state |= @as(u10, 1) << bp;
            }
        }

        std.debug.print("{s}", .{line[1..close_bracket]});
        for (0..12 - close_bracket) |_| std.debug.print(" ", .{});
        std.debug.print("=> {s} | {b:010}\n", .{ parsed[0 .. close_bracket - 1], machine_state });
    }
    return 0;
}

fn partTwo(input: *std.Io.Reader) !u32 {
    _ = input;
    return 0;
}

pub fn main() !void {
    var buf: [4096]u8 = undefined;
    var in_file = try adlib.inputFile("10");
    var reader = in_file.reader(&buf);
    const res_1 = try partOne(&reader.interface);
    const res_2 = try partTwo(&reader.interface);
    std.debug.print("part one: {d}\npart two: {d}\n", .{ res_1, res_2 });
}
