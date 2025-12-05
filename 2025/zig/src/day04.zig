const std = @import("std");
const adlib = @import("adlib.zig");

fn accessibleRolls(grid: [][]u8, remove: bool) u32 {
    var accessible: u32 = 0;

    for (grid, 0..) |row, i| {
        for (row, 0..) |byte, j| {
            if (byte == '.') continue;

            var blocked: u8 = 0;
            if (j > 0 and row[j - 1] != '.') {
                blocked += 1;
            }
            if (j < row.len - 1 and row[j + 1] != '.') {
                blocked += 1;
            }
            if (i > 0 and grid[i - 1][j] != '.') {
                blocked += 1;
            }
            if (i < grid.len - 1 and grid[i + 1][j] != '.') {
                blocked += 1;
            }

            if (j > 0 and i > 0 and grid[i - 1][j - 1] != '.') {
                blocked += 1;
            }
            if (j > 0 and i < grid.len - 1 and grid[i + 1][j - 1] != '.') {
                blocked += 1;
            }

            if (j < row.len - 1 and i > 0 and grid[i - 1][j + 1] != '.') {
                blocked += 1;
            }
            if (j < row.len - 1 and i < grid.len - 1 and grid[i + 1][j + 1] != '.') {
                blocked += 1;
            }

            if (blocked <= 3) {
                accessible += 1;
                grid[i][j] = 'x';
            }
        }
    }

    if (remove) {
        for (grid) |row| {
            for (row) |*byte| {
                if (byte.* == 'x') byte.* = '.';
            }
        }
    }

    return accessible;
}

fn partOne(grid: [][]u8) !u32 {
    return accessibleRolls(grid, false);
}

fn partTwo(grid: [][]u8) !u32 {
    var accessible: u32 = 0;
    while (true) {
        const newly_accessible = accessibleRolls(grid, true);
        if (newly_accessible == 0) break;
        accessible += newly_accessible;
    }
    return accessible;
}

pub fn main() !void {
    const gpa = adlib.allocator;
    const input = try adlib.collectStdin(gpa);
    const grid = try adlib.makeGrid(gpa, input);
    const res_1 = try partOne(grid);
    const res_2 = try partTwo(grid);
    std.debug.print("part one: {d}\npart two {d}\n", .{ res_1, res_2 });
    gpa.free(grid);
    gpa.free(input);
}
