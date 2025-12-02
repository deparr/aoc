const std = @import("std");
const adlib = @import("adlib.zig");

fn partOne(input: []const u8) !u64 {
    var id_sum: u64 = 0;
    var range_iter = std.mem.tokenizeScalar(u8, input, ',');
    var num_buf: [32]u8 = undefined;
    while (range_iter.next()) |range| {
        var split = std.mem.splitScalar(u8, range, '-');
        const los = split.first();
        const his = split.next();
        const lo = try std.fmt.parseInt(u64, los, 10);
        const hi = try std.fmt.parseInt(u64, his.?, 10);

        for (lo..hi) |id| {
            const id_str = try std.fmt.bufPrint(&num_buf, "{d}", .{id});
            if (id_str.len % 2 == 0 and std.mem.eql(
                u8,
                id_str[0 .. id_str.len / 2],
                id_str[id_str.len / 2 ..],
            )) {
                id_sum += id;
            }
        }
    }

    return id_sum;
}

fn partTwo(input: []const u8) !u64 {
    var id_sum: u64 = 0;
    var range_iter = std.mem.tokenizeScalar(u8, input, ',');
    var num_buf: [32]u8 = undefined;
    while (range_iter.next()) |range| {
        var split = std.mem.splitScalar(u8, range, '-');
        const los = split.first();
        const his = split.next();
        const lo = try std.fmt.parseInt(u64, los, 10);
        const hi = try std.fmt.parseInt(u64, his.?, 10);
        for (lo..hi + 1) |id| {
            const id_str = try std.fmt.bufPrint(&num_buf, "{d}", .{id});
            for (1..6) |pat_len| {
                if (pat_len >= id_str.len) break;
                if (id_str.len % pat_len != 0) continue;
                if (std.mem.containsAtLeast(u8, id_str, id_str.len / pat_len, id_str[0..pat_len])) {
                    id_sum += id;
                    break;
                }
            }
        }
    }

    return id_sum;
}

pub fn main() !void {
    const gpa = adlib.allocator;
    const input = try adlib.collectStdin(gpa);
    const trimmed = std.mem.trim(u8, input, &std.ascii.whitespace);
    const res_1 = try partOne(trimmed);
    const res_2 = try partTwo(trimmed);
    std.debug.print("part one: {d}\npart two {d}\n", .{ res_1, res_2 });
    gpa.free(input);
}
