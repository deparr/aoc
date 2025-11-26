const std = @import("std");

const url = "https://adventofcode.com/{s}/day/{s}/input";

pub fn main() !void {
    var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
    const gpa = debug_allocator.allocator();
    defer _ = debug_allocator.deinit();

    const root = std.Progress.start(.{
        .root_name = "Fetch input",
        .estimated_total_items = 1,
    });
    defer root.end();

    const args = try std.process.argsAlloc(gpa);
    defer std.process.argsFree(gpa, args);

    if (args.len < 3)
        return error.MissingExpectedArgs;
    const year = args[1];
    const day = args[2];

    const cookie_raw = std.process.getEnvVarOwned(gpa, "AOC_COOKIE") catch |err| switch (err) {
        error.EnvironmentVariableNotFound => try std.fs.cwd().readFileAlloc(gpa, "aoc-cookie", 4096),
        else => return err,
    };
    defer gpa.free(cookie_raw);
    const cookie = std.mem.trim(u8, cookie_raw, &std.ascii.whitespace);

    std.fs.cwd().makeDir("input") catch |err| switch (err) {
        error.PathAlreadyExists => {},
        else => return err,
    };

    var pathbuf: [16]u8 = undefined;
    var output_file = try std.fs.cwd().createFile(try std.fmt.bufPrint(&pathbuf, "input/{s}", .{day}), .{});
    var file_buf: [256]u8 = undefined;
    var file_writer = output_file.writer(&file_buf);

    var client: std.http.Client = .{ .allocator = gpa };
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

    output_file.close();

    if (res.status != .ok)
        std.debug.print("fetch failed with status {t}\n", .{res.status});

    root.completeOne();
}
