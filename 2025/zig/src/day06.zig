const std = @import("std");
const adlib = @import("adlib.zig");

const Op = enum {
    add,
    mul,
};

const Expr = struct { v: [4]u64 };

fn partOne(input: *std.Io.Reader) !u64 {
    var line_nr: u8 = 0;
    var exprs: std.ArrayList(Expr) = try .initCapacity(adlib.allocator, 1024);
    while (line_nr < 4) : (line_nr += 1) {
        const line = (try input.takeDelimiter('\n')).?;
        var num_iter = std.mem.tokenizeScalar(u8, line, ' ');
        var i: u32 = 0;
        while (num_iter.next()) |num| {
            const num_int = try std.fmt.parseInt(u64, num, 10);
            if (line_nr > 0) {
                exprs.items[i].v[line_nr] = num_int;
            } else {
                var expr: Expr = undefined;
                expr.v[0] = num_int;
                try exprs.append(adlib.allocator, expr);
            }
            i += 1;
        }
    }

    const op_line = (try input.takeDelimiter('\n')).?;
    var op_iter = std.mem.tokenizeScalar(u8, op_line, ' ');
    var ops: std.ArrayList(Op) = try .initCapacity(adlib.allocator, 1024);
    while (op_iter.next()) |op| {
        const parsed: Op = if (op[0] == '*') .mul else .add;
        try ops.append(adlib.allocator, parsed);
    }

    var grand_total: u64 = 0;
    for (ops.items, exprs.items) |op, expr| {
        if (op == .add) {
            grand_total += expr.v[0] + expr.v[1] + expr.v[2] + expr.v[3];
        } else {
            grand_total += expr.v[0] * expr.v[1] * expr.v[2] * expr.v[3];
        }
    }

    exprs.deinit(adlib.allocator);
    ops.deinit(adlib.allocator);

    return grand_total;
}

fn partTwoTwo(input: *std.Io.Reader) !u64 {
    var digit_lines: [4][]const u8 = undefined;
    for (0..digit_lines.len) |i| {
        const line = (try input.takeDelimiter('\n')).?;
        digit_lines[i] = try adlib.allocator.dupe(u8, line);
    }
    const op_line = (try input.takeDelimiter('\n')).?;

    var grand_total: u64 = 0;
    var start: usize = 0;
    var end: usize = 0;
    const pow_10: [4]u64 = .{ 1000, 100, 10, 1 };
    while (start < op_line.len) {
        end = std.mem.indexOfAnyPos(u8, op_line, start + 1, "*+") orelse op_line.len;
        const digit_end = if (end != op_line.len) end - 1 else end;
        var operands: [4]u64 = .{ 0, 0, 0, 0 };
        for (start..digit_end) |digit| {
            for (0..digit_lines.len) |i| {
                const digit_c = digit_lines[i][digit];
                if (digit_c == ' ') {
                    operands[digit - start] /= 10;
                } else {
                    const num: u64 = digit_c & 0xf;
                    operands[digit - start] += pow_10[i] * num;
                }
            }
        }

        if (op_line[start] == '*') {
            for (&operands) |*o| {
                if (o.* == 0) o.* = 1;
            }
            grand_total += operands[0] * operands[1] * operands[2] * operands[3];
        } else {
            grand_total += operands[0] + operands[1] + operands[2] + operands[3];
        }

        start = end;
    }

    for (digit_lines) |line| adlib.allocator.free(line);

    return grand_total;
}

pub fn main() !void {
    var buf: [4096]u8 = undefined;
    const input = try adlib.inputFile("6");
    var reader = input.reader(&buf);
    const res_1 = try partOne(&reader.interface);
    try reader.seekTo(0);
    const res_2 = try partTwoTwo(&reader.interface);
    std.debug.print("part one: {d}\npart two {d}\n", .{ res_1, res_2 });
    input.close();
}

