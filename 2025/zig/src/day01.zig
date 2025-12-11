const std = @import("std");
const adlib = @import("adlib.zig");

fn partOne(input: *std.Io.Reader) !u32 {
    var password: u32 = 0;
    var dial: i32 = 50;
    while (try input.takeDelimiter('\n')) |line| {
        const sign: i32 = if (line[0] == 'L') -1 else 1;
        const turns = try std.fmt.parseInt(i32, line[1..], 10);
        dial = @mod(dial + sign * turns, 100);
        if (dial == 0)
            password += 1;
    }

    return password;
}

fn partTwo(input: *std.Io.Reader) !u32 {
    var password: u32 = 0;
    var dial: i32 = 50;
    while (try input.takeDelimiter('\n')) |line| {
        const sign: i32 = if (line[0] == 'L') -1 else 1;
        const raw_turns = try std.fmt.parseInt(i32, line[1..], 10);
        const mod_turns = @mod(raw_turns, 100);
        const rotated_dial = dial + raw_turns * sign;
        if (
            (sign == -1 and mod_turns > dial and dial != 0)
            or (sign == 1 and dial + mod_turns > 100)
        )
            password += 1;

        dial = @mod(rotated_dial, 100);

        if (dial == 0)
            password += 1;
        password += @abs(@divFloor(raw_turns, 100));
    }

    return password;
}

pub fn main() !void {
    var buf: [4096]u8 = undefined;
    const input = try adlib.inputFile("1");
    var reader = input.reader(&buf);
    const res_1 = try partOne(&reader.interface);
    try reader.seekTo(0);
    const res_2 = try partTwo(&reader.interface);
    std.debug.print("part one: {d}\npart two {d}\n", .{ res_1, res_2 });
    input.close();
}
