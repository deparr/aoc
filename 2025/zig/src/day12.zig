const std = @import("std");
const adlib = @import("adlib.zig");

fn partOne(input: *std.Io.Reader) !u32 {
    var presents: [6]u9 = @splat(0);
    var read_presents: u32 = 0;
    var present_linenr: u8 = 0;
    while (try input.takeDelimiter('\n')) |line| {
        if (line.len == 0) {
            read_presents += 1;
            present_linenr = 0;
            if (read_presents >= 6) break;
            continue;
        }
        if (std.mem.indexOfScalar(u8, line, ':')) |_| continue;
        var present_line: u9 = 0;
        for (line, 1..) |c, i| {
            if (c == '.') continue;
            present_line |= @as(u9, 1) << (@as(u4, 3) - @as(u4, @truncate(i)));
        }
        present_line <<= 9 - @as(u4, 3) * @as(u4, @truncate(present_linenr + 1));
        presents[read_presents] |= present_line;
        present_linenr += 1;
    }

    for (presents, 0..) |p, i| {
        presents[i] = @intCast(@popCount(p));
    }

    for (presents) |p| {
        std.debug.print("{b:09}\n", .{p});
    }
    std.debug.print("\n", .{});

    var packable_regions: u32 = 0;
    while (try input.takeDelimiter('\n')) |line| {
        const x = std.mem.indexOfScalar(u8, line, 'x').?;
        const colon = std.mem.indexOfScalarPos(u8, line, x, ':').?;
        const width = std.fmt.parseInt(u32, line[0..x], 10) catch unreachable;
        const height = std.fmt.parseInt(u32, line[x + 1..colon], 10) catch unreachable;
        var num_iter = std.mem.tokenizeScalar(u8, line[colon + 1..], ' ');
        var num_count: u32 = 0;
        var required_counts: [6]u32 = @splat(0);
        while (num_iter.next()) |num| {
            required_counts[num_count] = std.fmt.parseInt(u32, num, 10) catch unreachable;
            num_count += 1;
        }

        if (canPack(width, height, &required_counts, &presents))
            packable_regions += 1;
    }

    return packable_regions;
}

fn canPack(width: u32, height: u32, presents: []const u32, sizes: []const u9) bool {
    const size = width * height;
    const required_size = blk: {
        var sum: u32 = 0;
        for (presents, sizes) |p, s| sum += p * @as(u32, s);
        break :blk sum;
    };

    if (required_size > size) return false;
    const spread_size = blk: {
        var sum: u32 = 0;
        for (presents, 0..) |p, i| sum += p + @as(u32, @truncate(i));
        break :blk sum * 9;
    };
    if (spread_size <= size) return true;

    unreachable;
}

fn partTwo(input: *std.Io.Reader) !u32 {
    _ = input;
    return 0;
}

pub fn main() !void {
    var threaded = std.Io.Threaded.init(std.mem.Allocator.failing, .{});
    const io = threaded.io();
    var buf: [4096]u8 = undefined;
    const input = try adlib.inputFile("12", io);
    var reader = input.reader(io, &buf);
    const res_1 = try partOne(&reader.interface);
    try reader.seekTo(0);
    const res_2 = try partTwo(&reader.interface);
    std.debug.print("part one: {d}\npart two: {d}\n", .{ res_1, res_2 });
    input.close(io);
}
