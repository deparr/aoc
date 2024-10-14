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
            if (left < 0) {
                left = switch (line[i]) {
                    'e',
                    'o',
                    't',
                    'n',
                    'f',
                    's',
                    => wordToNum(i, line) * 10,
                    '0'...'9' => @as(i32, line[i] & 0x0f) * 10,
                    else => -1,
                };
            }
            const ridx = line.len - (i + 1);
            if (right < 0) {
                right = switch (line[ridx]) {
                    'e',
                    'o',
                    't',
                    'n',
                    'f',
                    's',
                    => wordToNum(ridx, line),
                    '0'...'9' => @as(i32, line[ridx] & 0x0f),
                    else => -1,
                };
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

fn wordToNum(i: usize, line: []const u8) i32 {
    if (i + 2 >= line.len)
        return -1;

    return outer: switch (line[i]) {
        'o' => {
            for ("ne", 1..) |next, off| {
                if (i + off >= line.len or line[i + off] != next) break :outer -1;
            }
            break :outer 1;
        },
        't' => {
            if (line[i + 1] == 'h') {
                for ("ree", 2..) |next, off| {
                    if (i + off >= line.len or line[i + off] != next) break :outer -1;
                }
                break :outer 3;
            } else if (line[i+1] == 'w' and line[i+2] == 'o') {
                break :outer 2;
            } else break :outer -1;
        },
        'f' => {
            if (line[i + 1] == 'i') {
                for ("ve", 2..) |next, off| {
                    if (i + off >= line.len or line[i + off] != next) break :outer -1;
                }
                break :outer 5;
            } else if (line[i+1] == 'o') {
                for ("ur", 2..) |next, off| {
                    if (i + off >= line.len or line[i + off] != next) break :outer -1;
                }
                break :outer 4;
            } else break :outer -1;

        },
        's' => {
            if (line[i + 1] == 'i' and line[i+2] == 'x') {
                break :outer 6;
            } else {
                for ("even", 1..) |next, off| {
                    if (i + off >= line.len or line[i + off] != next) break :outer -1;
                }
                break :outer 7;
            }
        },
        'e' => {
            for ("ight", 1..) |next, off| {
                if (i + off >= line.len or line[i + off] != next) break :outer -1;
            }
            break :outer 8;
        },
        'n' => {
            for ("ine", 1..) |next, off| {
                if (i + off >= line.len or line[i + off] != next) break :outer -1;
            }
            break :outer 9;
        },
        else => -1,
    };
}

