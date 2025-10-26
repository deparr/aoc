const std = @import("std");

var optimize: std.builtin.OptimizeMode = undefined;
var target: std.Build.ResolvedTarget = undefined;

pub fn build(b: *std.Build) void {
    target = b.standardTargetOptions(.{});
    optimize = b.standardOptimizeOption(.{});

    const new_day_step = b.step("new-day", "stub out the next day");
    const all_step = b.step("all", "build all days");

    const dayno: ?usize = b.option(usize, "day", "day number");
    const selected_day = dayno orelse get_latest_day(b);
    doNewDayStep(b, new_day_step, selected_day);

    if (selected_day == 0) {
        fail(b, "day can't be zero");
        return;
    }

    if (selected_day > 12) {
        std.debug.print("Advent of Code is over, Merry Christmas 🎄!\n", .{});
        return;
    }

    doAllStep(b, all_step, selected_day);

    createExecutableForDay(b, b.getInstallStep(), selected_day);

}

fn doNewDayStep(b: *std.Build, create: *std.Build.Step, day: usize) void {
    const day_path = b.fmt("src/day{d:02}.zig", .{day + 1});
    const log = b.addSystemCommand(&.{ "echo", b.fmt("creating {s}...", .{day_path}), " // TODO fetch the input as well" });
    const cmd = b.addSystemCommand(&.{ "cp", "src/template.zig", day_path });
    cmd.step.dependOn(&log.step);
    create.dependOn(&cmd.step);
}

fn doAllStep(b: *std.Build, all: *std.Build.Step, latest_day: usize) void {
    for (1..latest_day+1) |day| {
        createExecutableForDay(b, all, day);
    }
}

fn createExecutableForDay(b: *std.Build, step: *std.Build.Step, num: usize) void {
    const source_file = b.fmt("src/day{d:02}.zig", .{num});
    const source_path = b.path(source_file);
    const day_name = b.fmt("day{d}", .{num});
    const exe = b.addExecutable(.{
        .name = day_name,
        .root_module = b.createModule(.{
            .root_source_file = source_path,
            .target = target,
            .optimize = optimize,
        }),
    });

    const log = b.addSystemCommand(&.{ "echo", b.fmt("building {s}", .{source_file})});
    const check_file = b.addCheckFile(source_path, .{});
    check_file.step.dependOn(&log.step);
    const install = b.addInstallArtifact(exe, .{});
    install.step.dependOn(&check_file.step);
    step.dependOn(&install.step);
}

fn fail(b: *std.Build, msg: []const u8) void {
    const fail_step = b.addFail(msg);
    b.default_step.dependOn(&fail_step.step);
}

fn get_latest_day(b: *std.Build) usize {
    var src = std.fs.cwd().openDir("src", .{ .iterate = true }) catch |err| {
        fail(b, b.fmt("{t}\n", .{err}));
        return 0;
    };
    defer src.close();
    var iter = src.walk(b.allocator) catch |err| {
        fail(b, b.fmt("{t}\n", .{err}));
        return 0;
    };
    defer iter.deinit();
    var latest_day: usize = 0;
    while (iter.next() catch |err| {
        fail(b, b.fmt("{t}\n", .{err}));
        return 0;
    }) |entry| {
        if (entry.kind != .file)
            continue;
        if (!std.mem.startsWith(u8, entry.basename, "day"))
            continue;
        const dot_index = std.mem.indexOf(u8, entry.basename, ".zig") orelse continue;
        if (std.fmt.parseInt(usize, entry.basename[3..dot_index], 10)) |d| {
            latest_day = @max(latest_day, d);
        } else |err| {
            std.debug.print("{s} {s} {t}\n", .{ entry.basename, entry.basename[3..dot_index], err });
        }
    }

    return latest_day;
}
