const std = @import("std");
const adlib = @import("adlib.zig");

fn partOne(input: []const u8) u32 {
    var joltage_sum: u32 = 0;
    var line_it = std.mem.tokenizeScalar(u8, input, '\n');
    while (line_it.next()) |line| {
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
fn partTwo(input: []const u8) u64 {
    var joltage_sum: u64 = 0;
    var line_it = std.mem.tokenizeScalar(u8, input, '\n');
    while (line_it.next()) |line| {
        var battery: [12]u8 = .{ 0 } ** 12;
        for (line, 0..) |ldd, i| {
            const ld = ldd & 0xf;
            var bat_start: u32 = @intCast(@max(0, @as(i64, 12) - @as(i64, @bitCast(line.len - i))));
            std.debug.print("{d} {d} {d} ----\n", .{i, ld, bat_start});

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
    const gpa = adlib.allocator;
    const input = try adlib.collectStdin(gpa);
    const res_1 = partOne(input);
    const res_2 = partTwo(input);
    std.debug.print("part one: {d}\npart two {d}\n", .{ res_1, res_2 });
    gpa.free(input);
}

