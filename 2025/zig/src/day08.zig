const std = @import("std");
const adlib = @import("adlib.zig");

const Point = struct {
    x: f32,
    y: f32,
    z: f32,

    fn dist_to(self: Point, other: Point) f32 {
        return std.math.sqrt(
            self.x * other.x +
                self.y * other.y +
                self.z * other.z,
        );
    }

    fn lessThan(_: void, self: Point, other: Point) bool {
        if (self.x == other.x) {
            if (self.y == other.y) {
                return self.x < other.z;
            }
            return self.y < other.y;
        }
        return self.x < other.x;
    }
};

const Edge = struct {
    a: u16,
    b: u16,
    distance: f32,

    fn lessThan(_: void, self: Edge, other: Edge) bool {
        return self.distance > other.distance;
    }
};

const NodeSet = std.AutoHashMap(u16, void);

fn partOne(input: []const u8) !u32 {
    const count = std.mem.count(u8, input, "\n");
    var points: std.ArrayList(Point) = try .initCapacity(adlib.allocator, count);
    var line_it = std.mem.tokenizeScalar(u8, input, '\n');
    while (line_it.next()) |line| {
        const comma_1 = std.mem.indexOfScalar(u8, line, ',').?;
        const comma_2 = std.mem.indexOfScalarPos(u8, line, comma_1 + 1, ',').?;
        points.appendAssumeCapacity(.{
            .x = try std.fmt.parseFloat(f32, line[0..comma_1]),
            .y = try std.fmt.parseFloat(f32, line[comma_1 + 1 .. comma_2]),
            .z = try std.fmt.parseFloat(f32, line[comma_2 + 1 ..]),
        });
    }

    var distances = try std.ArrayList(Edge).initCapacity(adlib.allocator, count * (count - 1) / 2);
    distances.items.len = distances.capacity;
    defer distances.deinit(adlib.allocator);
    for (0..count - 1) |i| {
        const a = points.items[i];
        for (i + 1..count) |j| {
            const b = points.items[j];
            distances.items[i * count - (i * (i + 1)) / 2 + (j - i - 1)] = .{
                .a = @truncate(i),
                .b = @truncate(j),
                .distance = a.dist_to(b),
            };
        }
    }
    std.sort.pdq(Edge, distances.items, {}, Edge.lessThan);

    var circuits = try std.ArrayList(NodeSet).initCapacity(adlib.allocator, 50);
    for (0..200) |_| {
        const shortest_edge = distances.pop().?;
        std.debug.print("processing edge: {any}\n", .{shortest_edge});
        var a_circuit: ?*NodeSet = null;
        var b_circuit: ?*NodeSet = null;
        var a_idx: usize = 0;
        var b_idx: usize = 0;
        for (circuits.items, 0..) |*circuit, i| {
            if (circuit.contains(shortest_edge.a)) {
                a_circuit = circuit;
                a_idx = i;
            }
            if (circuit.contains(shortest_edge.b)) {
                b_circuit = circuit;
                b_idx = i;
            }

            if (a_circuit != null and b_circuit != null) break;
        }

        if (a_circuit == null and b_circuit == null) {
            var new_circuit = NodeSet.init(adlib.allocator);
            try new_circuit.put(shortest_edge.a, {});
            try new_circuit.put(shortest_edge.b, {});
            circuits.appendAssumeCapacity(new_circuit);
            continue;
        }

        if (a_circuit == b_circuit) continue;

        if (a_circuit != null and b_circuit != null) {
            var source, var sink, const source_idx = blk: {
                if (a_circuit.?.count() > b_circuit.?.count()) {
                    break :blk .{ a_circuit.?, b_circuit.?, a_idx };
                } else {
                    break :blk .{ b_circuit.?, a_circuit.?, b_idx };
                }
            };
            var source_keys = source.keyIterator();
            while (source_keys.next()) |key| {
                try sink.put(key.*, {});
            }
            source.deinit();
            _ = circuits.swapRemove(source_idx);
        } else if (a_circuit) |circuit| {
            try circuit.put(shortest_edge.b, {});
        } else if (b_circuit) |circuit| {
            try circuit.put(shortest_edge.a, {});
        }

        std.debug.print("a: 0x{x} b: 0x{x}\n", .{
            @as(usize, @intFromPtr(a_circuit)),
            @as(usize, @intFromPtr(b_circuit)),
        });

        for (circuits.items) |*c| {
            std.debug.print("0x{x} |{d}|\n", .{ @as(usize, @intFromPtr(c)), c.count() });
            var key_iter = c.keyIterator();
            while (key_iter.next()) |key| {
                std.debug.print(" {d}", .{key.*});
            }
        }
        std.debug.print("\n", .{});
    }

    std.debug.print("{d}\n", .{circuits.items.len});
    for (circuits.items) |circuit| {
        std.debug.print("{d}\n", .{circuit.count()});
    }

    return 0;
}

fn partTwo(input: []const u8) u32 {
    _ = input;
    return 0;
}

pub fn main() !void {
    const gpa = adlib.allocator;
    const input = try adlib.collectStdin(gpa);
    const res_1 = try partOne(input);
    const res_2 = partTwo(input);
    std.debug.print("part one: {d}\npart two: {d}\n", .{ res_1, res_2 });
    gpa.free(input);
}
