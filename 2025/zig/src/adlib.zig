const std = @import("std");

pub const allocator = std.heap.smp_allocator;

var iobuf: [4096]u8 = undefined;

pub fn collectStdin(gpa: std.mem.Allocator) ![]u8 {
    var stdin = std.fs.File.stdin().reader(&iobuf);
    var reader = &stdin.interface;
    return reader.allocRemaining(gpa, .unlimited);
}

pub fn inputFile(comptime day: []const u8) !std.fs.File {
    var path_buf: [32]u8 = undefined;
    const path = try std.fmt.bufPrint(&path_buf, "input/{s}", .{day});
    return std.fs.cwd().openFile(path, .{});
}

pub fn makeGrid(gpa: std.mem.Allocator, input: []const u8) ![][]u8 {
    var grid: std.ArrayList([]const u8) = try .initCapacity(gpa, std.mem.count(u8, input, "\n"));
    var line_it = std.mem.tokenizeScalar(u8, input, '\n');
    while (line_it.next()) |line| {
        std.debug.assert(line.len > 0);
        grid.appendAssumeCapacity(line);
    }

    return @ptrCast(try grid.toOwnedSlice(gpa));
}

pub fn dumpGrid(grid: [][]u8) void {
    for (grid) |row| {
        std.debug.print(".{{ ", .{});
        for (row) |byte| std.debug.print("{c}", .{byte});
        std.debug.print(" }}\n", .{});
    }
}
