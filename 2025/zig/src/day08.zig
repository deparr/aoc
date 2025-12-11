const std = @import("std");
const adlib = @import("adlib.zig");

const Point = struct {
    x: f32,
    y: f32,
    z: f32,

    fn dist_to(self: Point, other: Point) f32 {
        const x = other.x - self.x;
        const y = other.y - self.y;
        const z = other.z - self.z;
        return std.math.sqrt(
            x * x + y * y + z * z
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

fn max3(list: []NodeSet) u32 {
    var max: [3]u32 = .{ 1, 1, 1 };
    for (list) |item| {
        if (item.count() > max[0]) {
            max[2] = max[1];
            max[1] = max[0];
            max[0] = item.count();
        }
    }
    return max[0] * max[1] * max[2];
}

fn solve(input: *std.Io.Reader) !struct { u32, u64 } {
    var points: std.ArrayList(Point) = try .initCapacity(adlib.allocator, 1000);
    while (true) {
        const line = (try input.takeDelimiter('\n')) orelse break;
        const comma_1 = std.mem.indexOfScalar(u8, line, ',').?;
        const comma_2 = std.mem.indexOfScalarPos(u8, line, comma_1 + 1, ',').?;
        points.appendAssumeCapacity(.{
            .x = try std.fmt.parseFloat(f32, line[0..comma_1]),
            .y = try std.fmt.parseFloat(f32, line[comma_1 + 1 .. comma_2]),
            .z = try std.fmt.parseFloat(f32, line[comma_2 + 1 ..]),
        });
    }
    const count = points.items.len;

    var distances = try std.ArrayList(Edge).initCapacity(adlib.allocator, count * (count - 1) / 2);
    distances.items.len = distances.capacity;
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
    var shortest_edge: Edge = undefined;
    var product_at_1000_joins: ?u32 = null;
    var joins: u32 = 0;
    while(true) : (joins += 1) {
        if (product_at_1000_joins == null and joins == 999)
            product_at_1000_joins = max3(circuits.items);
        if (circuits.items.len > 0 and circuits.items[0].count() >= 1000)
            break;

        shortest_edge = distances.pop().?;
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
            try circuits.append(adlib.allocator, new_circuit);
            continue;
        }

        if (a_circuit == b_circuit) continue;

        if (a_circuit != null and b_circuit != null) {
            var source, var sink, const source_idx = blk: {
                if (a_circuit.?.count() > b_circuit.?.count()) {
                    break :blk .{ b_circuit.?, a_circuit.?, b_idx };
                } else {
                    break :blk .{ a_circuit.?, b_circuit.?, a_idx };
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

    }


    const ax: u64 = @intFromFloat(points.items[shortest_edge.a].x);
    const bx: u64 = @intFromFloat(points.items[shortest_edge.b].x);
    const last_edge_x_product = ax * bx;

    for (circuits.items) |*c| c.deinit();
    circuits.deinit(adlib.allocator);
    distances.deinit(adlib.allocator);
    points.deinit(adlib.allocator);

    return .{ product_at_1000_joins.?, last_edge_x_product };
}

pub fn main() !void {
    var buf: [4096]u8 = undefined;
    var input = try adlib.inputFile("8");
    var reader = input.reader(&buf);
    const res_1, const res_2 = try solve(&reader.interface);
    std.debug.print("part one: {d}\npart two: {d}\n", .{ res_1, res_2 });
    input.close();
}
