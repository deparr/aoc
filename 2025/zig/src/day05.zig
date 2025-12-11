const std = @import("std");
const adlib = @import("adlib.zig");

const Range = struct {
    lower: u64,
    upper: u64,

    fn contains(self: Range, val: u64) bool {
        return val >= self.lower and val <= self.upper;
    }

    fn overlaps(self: Range, other: Range) bool {
        return (self.lower <= other.lower and self.upper >= other.lower) or (other.lower <= self.lower and other.upper >= self.lower);
    }

    fn merge(self: *Range, other: Range) void {
        self.* = .{
            .lower = @min(self.lower, other.lower),
            .upper = @max(self.upper, other.upper),
        };
    }

    fn lessThan(_: void, self: Range, other: Range) bool {
        if (self.lower == other.lower) {
            return self.upper >= other.upper;
        }

        return self.lower < other.lower;
    }

    fn len(self: Range) u64 {
        return self.upper + 1 - self.lower;
    }
};

fn partOne(input: *std.Io.Reader) !u32 {
    var num_fresh: u32 = 0;
    var processed_ranges = false;
    var ranges: std.ArrayList(Range) = try .initCapacity(adlib.allocator, 20);
    while (try input.takeDelimiter('\n')) |line| {
        if (!processed_ranges) {
            if (std.mem.indexOfScalar(u8, line, '-')) |idx| {
                const lower = std.fmt.parseInt(u64, line[0..idx], 10) catch unreachable;
                const upper = std.fmt.parseInt(u64, line[idx + 1 ..], 10) catch unreachable;

                try ranges.append(adlib.allocator, .{ .lower = lower, .upper = upper });
            } else {
                processed_ranges = true;
                std.sort.pdq(Range, ranges.items, {}, Range.lessThan);
            }
        } else {
            const id = std.fmt.parseInt(u64, line, 10) catch unreachable;

            const valid = blk: for (ranges.items) |range| {
                if (range.contains(id)) break :blk true;
            } else false;

            num_fresh += @intFromBool(valid);
        }
    }

    ranges.deinit(adlib.allocator);
    return num_fresh;
}

fn partTwo(input: *std.Io.Reader) !u64 {
    var num_valid: u64 = 0;
    var ranges: std.ArrayList(Range) = try .initCapacity(adlib.allocator, 20);
    while (try input.takeDelimiter('\n')) |line| {
        if (std.mem.indexOfScalar(u8, line, '-')) |idx| {
            const lower = std.fmt.parseInt(u64, line[0..idx], 10) catch unreachable;
            const upper = std.fmt.parseInt(u64, line[idx + 1 ..], 10) catch unreachable;
            const new_range = Range{ .lower = lower, .upper = upper };
            try ranges.append(adlib.allocator, new_range);
        } else {
            std.sort.pdq(Range, ranges.items, {}, Range.lessThan);
            var i: u32 = 0;
            while (i < ranges.items.len - 1) {
                var j = i + 1;
                var range = ranges.items[i];
                while (j < ranges.items.len and range.overlaps(ranges.items[j])) : (j += 1) {
                    range.merge(ranges.items[j]);
                }
                i = j;
                num_valid += range.len();
            }
            break;
        }
    }

    ranges.deinit(adlib.allocator);

    return num_valid;
}

pub fn main() !void {
    var buf: [4096]u8 = undefined;
    const input = try adlib.inputFile("5");
    var reader = input.reader(&buf);
    const res_1 = try partOne(&reader.interface);
    try reader.seekTo(0);
    const res_2 = try partTwo(&reader.interface);
    std.debug.print("part one: {d}\npart two {d}\n", .{ res_1, res_2 });
    input.close();
}

