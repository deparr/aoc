const std = @import("std");
const adlib = @import("adlib.zig");

fn partOne(input: *std.Io.Reader) !u32 {
    var joltage_sum: u32 = 0;
    while (try input.takeDelimiter('\n')) |line| {
        var max_joltage: u32 = 0;
        for (line, 0..) |ldd, i| {
            var j = line.len - 1;
            const ld: u32 = @as(u32, ldd & 0xf) * 10;
            while (j > i) : (j -= 1) {
                const rd: u32 = @intCast(line[j] & 0xf);
                max_joltage = @max(max_joltage, ld + rd);
            }

        }
        joltage_sum += max_joltage;
    }
    return joltage_sum;
}

// This is not my solution. Need to spend time to understand this.
// Dynamic programming is wack man.
fn partTwo(input: *std.Io.Reader) !u64 {
    var joltage_sum: u64 = 0;
    while (try input.takeDelimiter('\n')) |line| {
        var battery: [12]u8 = @splat(0);
        for (line, 0..) |ldd, i| {
            const ld = ldd & 0xf;
            var bat_start: u32 = @intCast(@max(0, @as(i64, 12) - @as(i64, @bitCast(line.len - i))));

            while (bat_start < 12) : (bat_start += 1) {
                if (ld <= battery[bat_start]) continue;
                battery[bat_start] = ld;
                bat_start += 1;
                while (bat_start < 12) {
                    battery[bat_start] = 0;
                    bat_start += 1;
                }
                break;
            }
        }

        var joltage: u64 = 0;
        for (battery) |digit| {
            joltage *= 10;
            joltage += digit;
        }

        joltage_sum += joltage;
    }
    return joltage_sum;
}

pub fn main() !void {
    var buf: [4096]u8 = undefined;
    const input = try adlib.inputFile("3");
    var reader = input.reader(&buf);
    const res_1 = try partOne(&reader.interface);
    try reader.seekTo(0);
    const res_2 = try partTwo(&reader.interface);
    std.debug.print("part one: {d}\npart two {d}\n", .{ res_1, res_2 });
    input.close();
}

