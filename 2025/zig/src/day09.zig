const std = @import("std");
const adlib = @import("adlib.zig");

const Coord = struct {
    x: u64,
    y: u64,

    fn area_rect_with(self: Coord, other: Coord) u64 {
        return (@max(self.x, other.x) - @min(self.x, other.x) + 1) *
            (@max(self.y, other.y) - @min(self.y, other.y) + 1);
    }

    pub fn format(self: Coord, writer: *std.Io.Writer) std.Io.Writer.Error!void {
        try writer.print("{d},{d}", self);
    }
};

fn partOne(input: []const u8) !u64 {
    const count = std.mem.count(u8, input, "\n");
    var coords: std.ArrayList(Coord) = try .initCapacity(adlib.allocator, count);
    var line_it = std.mem.tokenizeScalar(u8, input, '\n');
    while (line_it.next()) |line| {
        const comma = std.mem.indexOfScalar(u8, line, ',').?;
        coords.appendAssumeCapacity(.{
            .y = try std.fmt.parseInt(u64, line[0..comma], 10),
            .x = try std.fmt.parseInt(u64, line[comma + 1 ..], 10),
        });
    }

    var max_area: u64 = 0;
    for (coords.items) |coord_a| {
        for (coords.items) |coord_b| {
            max_area = @max(max_area, coord_a.area_rect_with(coord_b));
        }
    }

    coords.deinit(adlib.allocator);
    return max_area;
}

const Bounds = struct {
    by_x: std.AutoHashMap(u64, u64),
    by_y: std.AutoHashMap(u64, u64),

    // fn rect_within(a: Coord, b: Coord) bool { return false; }
};

const Range = struct {
    low: ?u64 = null,
    high: ?u64 = null,

    fn set_if_low(self: *Range, value: u64) void {
        if (self.low == null or value < self.low.?)
            self.low = value;
    }

    fn set_if_high(self: *Range, value: u64) void {
        if (self.high == null or value > self.high.?)
            self.high = value;
    }

    fn update(self: *Range, value: u64) void {
        self.set_if_low(value);
        self.set_if_high(value);
    }

    fn len(self: Range) u64 {
        return self.high.? - self.low.? + 1;
    }

    fn contains(self: Range, value: u64) bool {
        if (self.low == null) return false;
        if (self.low.? <= value) return true;
        if (self.high) |high_v| {
            return self.low.? <= value and value <= high_v;
        }
        return false;
    }
};

fn makeEmptyGrid(rows: u64, cols: u64) ![]std.DynamicBitSet {
    const allocator = adlib.allocator;
    var row_list: std.ArrayList([]std.DynamicBitSet) = try .initCapacity(allocator, rows);
    for (0..rows) |_| {
        const row = try std.DynamicBitSet.initEmpty(allocator, cols);
        row_list.appendAssumeCapacity(row);
    }
    return row_list.toOwnedSlice(allocator);
}

fn dumpGrid(grid: [][]u8) void {
    for (grid) |row| {
        std.debug.print("{s}\n", .{row});
    }

    std.debug.print("\n", .{});
}

fn partTwo(input: []const u8) !u64 {
    const count = std.mem.count(u8, input, "\n");
    var coords: std.ArrayList(Coord) = try .initCapacity(adlib.allocator, count);
    var line_it = std.mem.tokenizeScalar(u8, input, '\n');
    var range_x = Range{};
    var range_y = Range{};
    while (line_it.next()) |line| {
        const comma = std.mem.indexOfScalar(u8, line, ',').?;
        const coord = Coord{
            .x = try std.fmt.parseInt(u64, line[0..comma], 10),
            .y = try std.fmt.parseInt(u64, line[comma + 1 ..], 10),
        };
        range_x.update(coord.x);
        range_y.update(coord.y);
        coords.appendAssumeCapacity(coord);
    }
    std.debug.print("parsed coords\n", .{});

    const grid = try makeEmptyGrid(range_y.len(), range_x.len());
    std.debug.print("made grid\n", .{});

    const min_x = range_x.low.?;
    const min_y = range_y.low.?;
    for (coords.items) |red_tile| {
        grid[red_tile.y - min_y].set(red_tile.x - min_x);
    }

    std.debug.print("wrote red_tiles\n", .{});
    std.debug.print("{any} x {any}\n", .{ range_x.len(), range_y.len() });

    var active_ranges: [4]Range = .{.{}} ** 4;
    var last_active_index: u2 = 0;
    var range_set_at_row: u64 = 0;
    const cols = range_x.len();
    for (grid, 0..) |row, j| {
        if (j % 5000 == 0) {
            std.debug.print("{d}\n", .{j});
        }
        for (0..cols) |i| {
            const b = row.isSet(i);
            if (b) {
            } else {
                var active_range = &active_ranges[last_active_index];
                if (active_range.low == null) {
                    active_range.low = i;
                    range_set_at_row = j;
                } else if (active_range.high == null) {
                    active_range.high = i;
                    range_set_at_row = j;
                } else {
                    last_active_index += 1;
                    std.debug.assert(last_active_index < active_ranges.len);
                }
            }
            switch (b) {
                '.' => {
                    for (0..last_active_index + 1) |x| {
                        if (active_ranges[x].contains(i)) {
                            grid[j].set(i);
                            break;
                        }
                    }
                },
                'X' => {
                    if (active_range.low == null) {
                        active_range.low = i;
                        range_set_at_row = j;
                    } else if (active_range.high == null) {
                        active_range.high = i;
                        range_set_at_row = j;
                    } else {
                        if (range_set_at_row == j) {
                            active_range.high = @max(j, active_range.high.?);
                        } else {
                            active_range.low = @min(i, active_range.low.?);
                        }
                    }
                },
                else => unreachable,
            }
        }

        // std.debug.print("{s} |  active: {any}\n", .{ row, active_range });
    }
    // dumpGrid(grid);

    // var bounds = Bounds{ .by_x = .init(adlib.allocator), .by_y = .init(adlib.allocator) };
    // for (coords.items) |tile| {}

    const max_area: u64 = 0;
    // for (coords.items) |coord_a| {
    //     for (coords.items) |coord_b| {
    //         if (bounds.rect_within(coord_a, coord_b)) {
    //             max_area = @max(max_area, coord_a.area_rect_with(coord_b));
    //         }
    //     }
    // }

    coords.deinit(adlib.allocator);
    return max_area;
}

pub fn main() !void {
    const gpa = adlib.allocator;
    const input = try adlib.collectStdin(gpa);
    const res_1 = try partOne(input);
    const res_2 = try partTwo(input);
    std.debug.print("part one: {d}\npart two: {d}\n", .{ res_1, res_2 });
    gpa.free(input);
}
