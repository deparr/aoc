const std = @import("std");
const adlib = @import("adlib.zig");

fn strToNode(str: []const u8) u24 {
    std.debug.assert(str.len == 3);
    var node: u24 = @as(u24, str[0]) << 16;
    node |= @as(u24, str[1]) << 8;
    node |= @as(u24, str[2]);
    return node;
}

const EdgeList = std.AutoHashMap(u24, []u24);
const NodeSet = std.AutoHashMap(u24, u64);

var edgelist: EdgeList = undefined;
fn parseEdges(input: *std.Io.Reader) !void {
    edgelist = EdgeList.init(adlib.allocator);
    while (try input.takeDelimiter('\n')) |line| {
        const colon = std.mem.indexOfScalar(u8, line, ':').?;
        const node = strToNode(line[0..colon]);

        var outbound_edges: [32]u24 = @splat(0);
        var edge_count: u8 = 0;
        const edge_list_str = line[colon + 1..];
        var num_it = std.mem.tokenizeScalar(u8, edge_list_str, ' ');
        while (num_it.next()) |outbound| {
            outbound_edges[edge_count] = strToNode(outbound);
            edge_count += 1;
        }

        try edgelist.put(node, try adlib.allocator.dupe(u24, outbound_edges[0..edge_count]));
    }
}

fn countPathsInner(seen: *NodeSet, node: u24, target: u24) u64 {
    if (node == target) return 1;
    if (seen.get(node)) |count| return count;

    var count: u64 = 0;
    if (edgelist.get(node)) |children| {
        for (children) |edge| {
            count += countPathsInner(seen, edge, target);
        }
    }

    seen.put(node, count) catch unreachable;
    return count;
}

fn countPaths(seen: *NodeSet, node: u24, target: u24) u64 {
    const count = countPathsInner(seen, node, target);
    seen.clearRetainingCapacity();
    return count;
}

fn solve(input: *std.Io.Reader) !struct {u64, u64} {
    try parseEdges(input);

    var seen = NodeSet.init(adlib.allocator);

    const you: u24 = 'y' << 16 | 'o' << 8 | 'u';
    const out: u24 = 'o' << 16 | 'u' << 8 | 't';
    const you_out = countPaths(&seen, you, out);


    // svr -> dac * dac -> fft * fft -> out
    // svr -> fft * fft -> dac * dac -> out
    const svr: u24 = 's' << 16 | 'v' << 8 | 'r';
    const fft: u24 = 'f' << 16 | 'f' << 8 | 't';
    const dac: u24 = 'd' << 16 | 'a' << 8 | 'c';

    const svr_dac = countPaths(&seen, svr, dac);
    const dac_fft = countPaths(&seen, dac, fft);
    const fft_out = countPaths(&seen, fft, out);

    const svr_fft = countPaths(&seen, svr, fft);
    const fft_dac = countPaths(&seen, fft, dac);
    const dac_out = countPaths(&seen, dac, out);

    const svr_dacfft_out = svr_dac * dac_fft * fft_out + svr_fft * fft_dac * dac_out;

    var keys = edgelist.keyIterator();
    while (keys.next()) |key| {
        adlib.allocator.free(edgelist.get(key.*).?);
    }
    edgelist.deinit();
    seen.deinit();

    return .{ you_out, svr_dacfft_out };
}

pub fn main() !void {
    var buf: [4096]u8 = undefined; 
    const input = try adlib.inputFile("11");
    var reader = input.reader(&buf);
    const res_1, const res_2 = try solve(&reader.interface);
    std.debug.print("part one: {d}\npart two: {d}\n", .{ res_1, res_2 });
    input.close();
}

