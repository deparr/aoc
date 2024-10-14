const std = @import("std");
const util = @import("util.zig");

const print = std.debug.print;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const ally = arena.allocator();

    const input = try util.getFullInput(ally);

    var total: i32 = 0;
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        var left: i32 = -1;
        var right: i32 = -1;
        for (0..line.len) |i| {
            if (left == -1 and isDigit(line[i])) {
                left = @as(i32, line[i] & 0x0f) * 10;
            }
            if (right == -1 and isDigit(line[line.len - (i + 1)])) {
                right = @as(i32, line[line.len - (i + 1)] & 0xf);
            }

            if (left >= 0 and right >= 0) {
                break;
            }

        }

        if (left < 0 or right < 0) {
            print("left or right is empty, exiting\n", .{});
            return error.Bad;
        }

        total += left + right;
    }

    print("{}\n", .{total});
}

fn isDigit(b: u8) bool {
    return b >= '0' and b <= '9';
}
