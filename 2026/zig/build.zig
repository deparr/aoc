const std = @import("std");
const Io = std.Io;

const max_days = 12;

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const year = b.option([]const u8, "year", "year number") orelse "2026";
    const day, const next_day = blk: {
        const input_day = b.option(usize, "day", "day to operate on");
        if (input_day) |user_day| {
            if (user_day != 0) break :blk .{ user_day, user_day };
        }
        const latest_day = getLatestDay(b);
        break :blk .{ latest_day, latest_day + 1 };
    };

    const next_day_step = b.step("next", "stub out the next day");
    const all_step = b.step("all", "build all days");
    const run_step = b.step("run", "run the specified or latest day");
    const input_step = b.step("fetch-input", "fetch input for day");

    if (day == 0) {
        const fail_step = b.addFail("unable to determine day, are there any in ./src?");
        b.getInstallStep().dependOn(&fail_step.step);
        run_step.dependOn(&fail_step.step);
        all_step.dependOn(&fail_step.step);
        input_step.dependOn(&fail_step.step);
    }

    // single day install
    const single_day_exe = addExecutableForDay(b, day, target, optimize);
    b.installArtifact(single_day_exe);

    // run single day
    const run_single_day_exe = b.addRunArtifact(single_day_exe);
    run_step.dependOn(&run_single_day_exe.step);

    // create next day
    addNextDay(b, next_day_step, year, next_day);

    // fetch input for specific day
    input_step.dependOn(runFetchForDay(b, year, day));

    // install all days
    for (1..day + 1) |d| {
        const d_exe = addExecutableForDay(b, d, target, optimize);
        all_step.dependOn(&b.addInstallArtifact(d_exe, .{}).step);
    }
}

fn addNextDay(b: *std.Build, step: *std.Build.Step, year: []const u8, day: usize) void {
    if (day > max_days) {
        if (b.graph.host.result.os.tag == .windows) {
            var handle = std.os.windows.CONSOLE.USER_IO.SET_CP(.Output, 65001);
            _ = handle.operate(b.graph.io, null) catch {};
        }
        std.debug.print("Advent of Code is over, Merry Christmas 🎄!\n", .{});
        return;
    }

    const fetch_step = runFetchForDay(b, year, day);

    const day_path = b.fmt("src/day{d:02}.zig", .{day});
    if (b.root.root_dir.handle.statFile(b.graph.io, day_path, .{})) |_| {
        step.dependOn(&b.addFail(b.fmt("{s} already exists", .{ day_path })).step);
        return;
    } else |_| {}

    const copy_templ = b.addUpdateSourceFiles();
    copy_templ.addCopyFileToSource(b.path("src/build/template.zig"), day_path);

    step.dependOn(&copy_templ.step);
    step.dependOn(fetch_step);
}

fn addExecutableForDay(b: *std.Build, day: usize, target: std.Build.ResolvedTarget, optimize: std.builtin.Optimize) *std.Build.Step.Compile {
    const source_file = b.fmt("src/day{d:02}.zig", .{day});
    const source_path = b.path(source_file);
    const day_name = b.fmt("day{d}", .{day});
    const exe = b.addExecutable(.{
        .name = day_name,
        .root_module = b.createModule(.{
            .root_source_file = source_path,
            .target = target,
            .optimize = optimize,
        }),
    });
    return exe;
}

fn runFetchForDay(b: *std.Build, year: []const u8, day: usize) *std.Build.Step {
    const fetch = b.addExecutable(.{
        .name = "fetch",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/build/fetch-input.zig"),
            .optimize = .debug,
            .target = b.graph.host,
        }),
    });
    const run_fetch = b.addRunArtifact(fetch);
    run_fetch.addArg(year);
    run_fetch.addArg(b.fmt("{d}", .{day}));
    run_fetch.setName("fetch day input");
    return &run_fetch.step;
}

// this scan is not tracked by the graph
// adding a new day and then running `zig build all` does
// not build the new day.
//
// I'm not sure if there is a granular way to track this.
// there is b.dependOnDirectory*() but depending on `src` is dumb
fn getLatestDay(b: *std.Build) usize {
    var src = b.root.root_dir.handle.openDir(b.graph.io, "src", .{ .iterate = true }) catch |err| {
        std.debug.print("failed to open src to read days: {t}\n", .{err});
        return 0;
    };
    defer src.close(b.graph.io);
    var iter = src.walk(b.allocator) catch |err| {
        std.debug.print("failed to init src walker: {t}\n", .{err});
        return 0;
    };
    defer iter.deinit();
    var latest_day: usize = 0;
    while (iter.next(b.graph.io) catch |err| {
        std.debug.print("failed to advance src walker: {t}\n", .{err});
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
