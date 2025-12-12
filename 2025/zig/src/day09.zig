const std = @import("std");
const adlib = @import("adlib.zig");

const Coord = struct {
    x: u64,
    y: u64,

    fn area_rect_with(self: Coord, other: Coord) u64 {
        return (@max(self.x, other.x) - @min(self.x, other.x) + 1) *
            (@max(self.y, other.y) - @min(self.y, other.y) + 1);
    }

    fn toSigned(self: Coord) struct { x: i64, y: i64 } {
        return .{ .x = @bitCast(self.x), .y = @intCast(self.y) };
    }

    pub fn format(self: Coord, writer: *std.Io.Writer) std.Io.Writer.Error!void {
        try writer.print("{d},{d}", self);
    }
};

fn partOne(input: *std.Io.Reader) !u64 {
    var coords: std.ArrayList(Coord) = try .initCapacity(adlib.allocator, 500);
    while (try input.takeDelimiter('\n')) |line| {
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
    var row_list: std.ArrayList(std.DynamicBitSet) = try .initCapacity(allocator, rows);
    for (0..rows) |_| {
        const row = try std.DynamicBitSet.initEmpty(allocator, cols);
        row_list.appendAssumeCapacity(row);
    }
    return row_list.toOwnedSlice(allocator);
}

fn dumpGrid(grid: []std.DynamicBitSet) void {
    for (grid) |row| {
        for (0..row.unmanaged.bit_length) |i| {
            std.debug.print("{c}", .{if (row.isSet(i)) @as(u8, '#') else @as(u8, '.')});
        }
        std.debug.print("\n", .{});
    }
}

fn dumpGridImage(grid: []std.DynamicBitSet) void {
    const image_width = 512;
    const image_height = 512;
    const stride = image_width * 3;
    var image: [image_width * image_height * 3]u8 = @splat(0);
    for (grid, 0..) |row, y| {
        const image_y = y / image_height;
        for (0..row.unmanaged.bit_length) |x| {
            const image_x = x / image_width;
            const px = image_y * stride + image_x * 3;
            if (row.isSet(x)) {
                image[px] = 0xff;
                image[px + 1] = 0x0;
                image[px + 2] = 0x0;
            }
        }
    }

    var buf: [1024]u8 = undefined;
    const file = std.fs.cwd().createFile("9-image.ppm", .{}) catch unreachable;
    var writer = file.writer(&buf);
    writer.interface.print("P6\n{d} {d}\n255\n", .{ image_width, image_height }) catch unreachable;
    writer.interface.writeAll(&image) catch unreachable;
    writer.interface.flush() catch unreachable;
}

fn connect(grid: []std.DynamicBitSet, a: Coord, b: Coord) void {
    const as = a.toSigned();
    const bs = b.toSigned();
    if (as.x == bs.x) {
        const inc: i64 = if (bs.y - as.y < 0) -1 else 1;
        var y = as.y + inc;
        while (y != bs.y) : (y += inc) {
            grid[@abs(y)].set(a.x);
        }
        return;
    }

    grid[a.y].setRangeValue(.{
        .start = @min(a.x, b.x),
        .end = @max(a.x, b.x),
    }, true);
}

fn validHorizontal(row: std.DynamicBitSet, start: usize, end: usize) bool {
    var x = start;
    var rg_count: u32 = 0;
    var prev: u8 = 1;
    while (x < end) : (x += 1) {
        prev, _ = @shlWithOverflow(prev, @as(u3, 1));
        if (row.isSet(x)) {
            rg_count += 1;
            prev |= 1;
        }
        const check = prev & 0b111;
        if (check == 0b110 or check == 0b011) return false;
    }

    return rg_count % 2 == 1;
}

fn validVertical(grid: []std.DynamicBitSet, start: usize, end: usize, col: usize) bool {
    var y = start;
    var rg_count: u32 = 0;
    var prev: u8 = 1;
    while (y < end) : (y += 1) {
        prev, _ = @shlWithOverflow(prev, @as(u3, 1));
        if (grid[y].isSet(col)) {
            rg_count += 1;
            prev |= 1;
        }
        const check = prev & 0b111;
        if (check == 0b110 or check == 0b011) return false;
    }

    return rg_count % 2 == 1;
}

fn validRect2(grid: []std.DynamicBitSet, a: Coord, b: Coord) bool {
    var aa, var bb = if (a.x < b.x) .{ a, b } else .{ b, a };
    const x = aa.x + 1;
    const x_end = bb.x;

    if (!validHorizontal(grid[aa.y], x, x_end)) return false;
    if (!validHorizontal(grid[bb.y], x, x_end)) return false;

    aa, bb = if (a.y < b.y) .{ a, b } else .{ b, a };
    const y = aa.y + 1;
    const y_end = bb.y;
    if (!validVertical(grid, y, y_end, aa.x)) return false;
    if (!validVertical(grid, y, y_end, bb.x)) return false;

    return true;
}

fn validRect(grid: []std.DynamicBitSet, a: Coord, b: Coord) bool {
    const ul = Coord {
        .x = @min(a.x, b.x),
        .y = @min(a.y, b.y),
    };
    const br = Coord {
        .x = @max(a.x, b.x),
        .y = @max(a.y, b.y),
    };
    for (ul.y..br.y + 1) |y| {
        const row = grid[y];
        for (ul.x..br.x+1) |x| {
            if (!row.isSet(x)) return false;
        }
    }
    return true;
}

fn partTwo(input: *std.Io.Reader) !u64 {
    var coords: std.ArrayList(Coord) = try .initCapacity(adlib.allocator, 500);
    var range_x = Range{};
    var range_y = Range{};
    while (try input.takeDelimiter('\n')) |line| {
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
    for (coords.items) |*coord| {
        coord.x -= min_x;
        coord.y -= min_y;
    }
    var prev: ?Coord = null;
    for (coords.items) |red_tile| {
        grid[red_tile.y].set(red_tile.x);
        if (prev) |other_red| {
            connect(grid, other_red, red_tile);
        }
        prev = red_tile;
    }
    connect(grid, prev.?, coords.items[0]);
    std.debug.print("closed shape\n", .{});

    for (grid) |*row| {
        var left = row.findFirstSet().?;
        var it = row.iterator(.{});
        _ = it.next();
        while (it.next()) |right| {
            row.setRangeValue(.{ .start = left, .end = right }, true);
            left = right;
        }

    }
    std.debug.print("fill shape\n", .{});

    std.debug.print("{d}\n", .{ coords.items.len });
    var max_area: u64 = 0;
    for (coords.items, 0..) |a, i| {
        for (coords.items[i + 1 ..]) |b| {
            if (a.x == b.x or a.y == b.y) continue;
            if (validRect(grid, a, b)) {
                max_area = @max(max_area, a.area_rect_with(b));
            }
        }
        std.debug.print("{d}\n", .{ i });
    }

    coords.deinit(adlib.allocator);
    for (grid) |*row| {
        row.deinit();
    }
    adlib.allocator.free(grid);
    return max_area;
}

pub fn main() !void {
    var buf: [4096]u8 = undefined;
    const input = try adlib.inputFile("9");
    var reader = input.reader(&buf);
    const res_1 = try partOne(&reader.interface);
    try reader.seekTo(0);
    const res_2 = try partTwo(&reader.interface);
    std.debug.print("part one: {d}\npart two: {d}\n", .{ res_1, res_2 });
    input.close();
}
