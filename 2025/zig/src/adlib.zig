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

pub fn streamGrid(gpa: std.mem.Allocator, stream: *std.Io.Reader) ![][]u8 {
    var grid: std.ArrayList([]u8) = try .initCapacity(gpa, 100);
    while (try stream.takeDelimiter('\n')) |line| {
        std.debug.assert(line.len > 0);
        try grid.append(gpa, try gpa.dupe(u8, line));
    }

    return try grid.toOwnedSlice(gpa);
}

pub fn freeGrid(gpa: std.mem.Allocator, grid: [][]u8) void {
    for (grid) |row| gpa.free(row);
    gpa.free(grid);
}

pub fn dumpGrid(grid: [][]u8) void {
    for (grid) |row| {
        std.debug.print(".{{ ", .{});
        for (row) |byte| std.debug.print("{c}", .{byte});
        std.debug.print(" }}\n", .{});
    }
}

pub fn Queue(comptime T: type) type {
    return struct {
        front: usize,
        back: usize,
        buffer: []T,
        allocator: std.mem.Allocator,

        const Self = @This();
        const empty: Self = .{ .front = 0, .back = 0, .buffer = &.{} };

        pub fn initCapacity(gpa: std.mem.Allocator, capacity: usize) !Self {
            const buf = try gpa.alloc(T, capacity);

            return .{
                .front = 0,
                .back = 0,
                .buffer = buf,
                .allocator = gpa,
            };
        }

        pub fn pop(self: *Self) ?T {
            if (self.isEmpty()) return null;
            const value = self.buffer[self.mask(self.front)];
            self.front = self.mask2(self.front + 1);
            return value;
        }

        pub fn push(self: *Self, v: T) void {
            if (self.isFull()) {
                self.resize();
            }
            self.buffer[self.mask(self.back)] = v;
            self.back = self.mask2(self.back + 1);
        }

        pub fn mask(self: Self, index: usize) usize {
            return index % self.buffer.len;
        }

        pub fn mask2(self: Self, index: usize) usize {
            return index % (2 * self.buffer.len);
        }

        pub fn len(self: Self) usize {
            const wrap_offset = 2 * self.buffer.len * @intFromBool(self.back < self.front);
            const adjusted_back = self.back + wrap_offset;
            return adjusted_back - self.front;
        }

        pub fn isFull(self: Self) bool {
            return self.mask2(self.back + self.buffer.len) == self.front;
        }

        pub fn isEmpty(self: Self) bool {
            return self.front == self.back;
        }

        pub fn resize(self: *Self) void {
            const new_len = self.buffer.len * 9 / 5;
            var new_buffer = self.allocator.alloc(T, new_len) catch unreachable;
            const front = self.front;
            const back = self.back % (self.buffer.len + 1);
            const first = if (back < front) self.buffer[front..] else self.buffer[front..back];
            const second = if (back < front) self.buffer[0..back] else &.{};
            @memcpy(new_buffer[0..first.len], first);
            @memcpy(new_buffer[first.len .. first.len + second.len], second);
            self.front = 0;
            self.back = first.len + second.len;
            self.allocator.free(self.buffer);
            self.buffer = new_buffer;
        }

        pub fn clear(self: *Self) void {
            self.front = 0;
            self.back = 0;
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.buffer);
            self.* = undefined;
        }
    };
}

test Queue {
    var queue = try Queue(u8).initCapacity(std.testing.allocator, 5);
    queue.push(1);
    queue.push(2);
    queue.push(3);
    queue.push(4);
    queue.push(5);
    try std.testing.expect(std.mem.eql(u8, queue.buffer, &.{ 1, 2, 3, 4, 5 }));
    queue.push(6);
    try std.testing.expectEqual(9, queue.buffer.len);
    try std.testing.expectEqualSlices(u8, &.{ 1, 2, 3, 4, 5, 6 }, queue.buffer[queue.front..queue.back]);
    queue.deinit();

    // resize
}
