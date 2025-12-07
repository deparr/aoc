const std = @import("std");
const adlib = @import("adlib.zig");

fn solve(grid: [][]u8) !struct { u32, u64 } {
    const n = grid[0].len;

    const start = std.mem.indexOfScalar(u8, grid[0], 'S').?;

    var active_beams: [141]u64 = .{0} ** 141;
    active_beams[start] = 1;

    var split_count: u32 = 0;
    for (grid) |row| {
        for (0..active_beams.len) |i| {
            switch (row[i]) {
                '.', 'S' => {},
                '^' => {
                    if (active_beams[i] > 0) {
                        split_count += 1;
                        if (i > 0)
                            active_beams[i - 1] += active_beams[i];
                        if (i < n - 1)
                            active_beams[i + 1] += active_beams[i];
                        active_beams[i] = 0;
                    }
                },
                else => unreachable,
            }
        }
    }

    var total_active_beams: u64 = 0;
    for (active_beams) |beam| total_active_beams += beam;

    return .{ split_count, total_active_beams };
}

pub fn main() !void {
    const gpa = adlib.allocator;
    const input = try adlib.collectStdin(gpa);
    const grid = try adlib.makeGrid(gpa, input);
    const res_1, const res_2 = try solve(grid);
    std.debug.print("part one: {d}\npart two: {d}\n", .{ res_1, res_2 });
    gpa.free(grid);
    gpa.free(input);
}
