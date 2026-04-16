const std = @import("std");

const url = "https://adventofcode.com/{s}/day/{s}/input";

pub fn main(init: std.process.Init) !void {
    const arena = init.arena.allocator();
    const io = init.io;

    const root = std.Progress.start(io, .{
        .root_name = "Fetch input",
        .estimated_total_items = 1,
    });
    defer root.end();

    const args = try init.minimal.args.toSlice(arena);

    if (args.len < 3)
        return error.MissingExpectedArgs;
    const year = args[1];
    const day = args[2];

    const cookie_raw = init.environ_map.get("AOC_COOKIE") orelse try std.Io.Dir.cwd().readFileAlloc(init.io, "aoc-cookie", arena, .limited(2048));
    const cookie = std.mem.trim(u8, cookie_raw, &std.ascii.whitespace);

    std.Io.Dir.cwd().createDir(io, "input", .default_dir) catch |err| switch (err) {
        error.PathAlreadyExists => {},
        else => return err,
    };

    var pathbuf: [16]u8 = undefined;
    var output_file = try std.Io.Dir.cwd().createFile(io, try std.fmt.bufPrint(&pathbuf, "input/{s}", .{day}), .{});
    var file_buf: [256]u8 = undefined;
    var file_writer = output_file.writer(io, &file_buf);

    var client: std.http.Client = .{ .io = io, .allocator = arena };
    var cookie_buf: [1024]u8 = undefined;
    var url_buf: [1024]u8 = undefined;
    var headers = [_]std.http.Header{.{
        .name = "Cookie",
        .value = try std.fmt.bufPrint(&cookie_buf, "session={s}", .{cookie}),
    }};
    const res = try client.fetch(.{
        .method = .GET,
        .location = .{ .url = try std.fmt.bufPrint(&url_buf, url, .{ year, day }) },
        .extra_headers = &headers,
        .response_writer = &file_writer.interface,
    });
    client.deinit();

    output_file.close(io);

    if (res.status != .ok)
        std.debug.print("fetch failed with status {t}\n", .{res.status});

    root.completeOne();
}
