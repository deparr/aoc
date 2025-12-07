const std = @import("std");
const adlib = @import("adlib.zig");

const Op = enum {
    add,
    mul,
};

const Expr = struct { v: [4]u64 };

fn partOne(input: []const u8) !u64 {
    const op_line = input[std.mem.lastIndexOfScalar(u8, input, '\n').? + 1 ..];
    var op_iter = std.mem.tokenizeScalar(u8, op_line, ' ');
    var ops: std.ArrayList(Op) = try .initCapacity(adlib.allocator, 1024);
    while (op_iter.next()) |op| {
        const parsed: Op = if (op[0] == '*') .mul else .add;
        try ops.append(adlib.allocator, parsed);
    }

    var line_iter = std.mem.tokenizeScalar(u8, input, '\n');
    var line_nr: u8 = 0;
    var line: []const u8 = undefined;
    var exprs: std.ArrayList(Expr) = try .initCapacity(adlib.allocator, ops.items.len);
    while (line_nr < 4) : (line_nr += 1) {
        line = line_iter.next().?;
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

fn partTwoTwo(input: []const u8) !u64 {
    var op_line: []const u8 = undefined;
    var digit_lines: [4][]const u8 = undefined;
    {
        var lf_idx = std.mem.indexOfScalar(u8, input, '\n').?;
        var cursor: usize = 0;
        for (0..digit_lines.len) |i| {
            digit_lines[i] = input[cursor..lf_idx];
            cursor = lf_idx + 1;
            lf_idx = std.mem.indexOfScalarPos(u8, input, cursor, '\n') orelse 0;
        }
        op_line = input[cursor..];
    }

    var grand_total: u64 = 0;
    var start: usize = 0;
    var end: usize = 0;
    const pow_10: [4]u64 = .{ 1000, 100, 10, 1 };
    while (start < op_line.len) {
        end = std.mem.indexOfAnyPos(u8, op_line, start + 1, "*+") orelse op_line.len;
        const digit_end = if (end != op_line.len) end - 1 else end + 1;
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

    return grand_total;
}

pub fn main() !void {
    const gpa = adlib.allocator;
    const input = try adlib.collectStdin(gpa);
    const trimmed = std.mem.trim(u8, input, &std.ascii.whitespace);
    const res_1 = try partOne(trimmed);
    const res_2 = try partTwoTwo(trimmed);
    std.debug.print("part one: {d}\npart two: {d}\n", .{ res_1, res_2 });
    gpa.free(input);
}
