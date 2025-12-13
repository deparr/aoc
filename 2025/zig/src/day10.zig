const std = @import("std");
const adlib = @import("adlib.zig");

const ButtonState = packed struct(u64) {
    state: u10 = 0,
    presses: u54 = 0,
};

fn partOne(input: *std.Io.Reader) !u64 {
    var total_min_presses: u64 = 0;
    var processed = std.AutoHashMap(u10, void).init(adlib.allocator);
    var queue = try adlib.Queue(ButtonState).initCapacity(adlib.allocator, 300);
    var linenr: u32 = 0;
    while (try input.takeDelimiter('\n')) |line| {
        linenr += 1;
        const close_bracket = std.mem.indexOfScalarPos(u8, line, 1, ']').?;
        var target: u10 = 0;
        for (1..close_bracket) |i| {
            if (line[i] == '#') {
                const bp = @as(u4, 10) - @as(u4, @truncate(i));
                target |= @as(u10, 1) << bp;
            }
        }

        var button_buf: [32]u10 = @splat(0);
        var button_count: u5 = 0;
        var par_start_idx = std.mem.indexOfScalarPos(u8, line, close_bracket + 1, '(');
        while (par_start_idx) |par_start| {
            const par_end = std.mem.indexOfScalarPos(u8, line, par_start + 1, ')').?;
            var nums = std.mem.tokenizeScalar(u8, line[par_start + 1 .. par_end], ',');
            var button: u10 = 0;
            while (nums.next()) |num_str| {
                const num = std.fmt.parseInt(u4, num_str, 10) catch unreachable;
                button |= @as(u10, 1) << (@as(u4, 9) - num);
            }
            button_buf[button_count] = button;
            button_count += 1;
            par_start_idx = std.mem.indexOfScalarPos(u8, line, par_end + 1, '(');
        }
        const buttons = button_buf[0..button_count];

        var min_presses: u64 = std.math.maxInt(u64);
        var max_queue_len: usize = 0;
        queue.push(.{});
        try processed.put(0, {});

        while (!queue.isEmpty()) {
            const item = queue.pop().?;
            if (item.state == target) {
                min_presses = @min(item.presses, min_presses);
                continue;
            }
            if (item.presses >= min_presses) continue;
            for (buttons) |button| {
                const new_state = item.state ^ button;
                if (!processed.contains(new_state)) {
                    try processed.put(item.state, {});
                    queue.push(.{ .state = new_state, .presses = item.presses + 1 });
                }
            }

            max_queue_len = @max(max_queue_len, queue.len());
        }

        if (min_presses != std.math.maxInt(u64))
            total_min_presses += min_presses;
        queue.clear();
        processed.clearRetainingCapacity();
    }

    queue.deinit();
    processed.deinit();
    return total_min_presses;
}

fn partTwo(input: *std.Io.Reader) !u32 {
    _ = input;
    return 0;
}

pub fn main() !void {
    var buf: [4096]u8 = undefined;
    var in_file = try adlib.inputFile("10");
    var reader = in_file.reader(&buf);
    const res_1 = try partOne(&reader.interface);
    try reader.seekTo(0);
    const res_2 = try partTwo(&reader.interface);
    std.debug.print("part one: {d}\npart two: {d}\n", .{ res_1, res_2 });
}
