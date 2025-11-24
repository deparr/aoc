const std = @import("std");

var optimize: std.builtin.OptimizeMode = undefined;
var target: std.Build.ResolvedTarget = undefined;
var year: []const u8 = undefined;

pub fn build(b: *std.Build) void {
    target = b.standardTargetOptions(.{});
    optimize = b.standardOptimizeOption(.{});

    const new_day_step = b.step("new-day", "stub out the next day");
    const all_step = b.step("all", "build all days");
    const run_step = b.step("run", "run a given day on its specific input");

    year = b.option([]const u8, "year", "year number") orelse "2025";
    const dayno: ?usize = b.option(usize, "day", "day number");
    const selected_day = dayno orelse getLatestDay(b);
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

    const exe = createExecutableForDay(b, b.getInstallStep(), selected_day);
    const run_day_exe = b.addRunArtifact(exe);
    run_day_exe.setStdIn(.{ .lazy_path = b.path(b.fmt("input/{d}", .{selected_day})) });
    run_step.dependOn(&run_day_exe.step);
}

fn doNewDayStep(b: *std.Build, create: *std.Build.Step, day: usize) void {
    const fetch = b.addExecutable(.{
        .name = "fetch",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/build/fetch-input.zig"),
            .optimize = .Debug,
            .target = b.graph.host,
        }),
    });

    const run_fetch = b.addRunArtifact(fetch);
    run_fetch.addArg(year);
    run_fetch.addArg(b.fmt("{d}", .{day}));
    run_fetch.setName("fetch day input");

    const day_path = b.fmt("src/day{d:02}.zig", .{day + 1});
    const write_templ = TemplateDayStep.create(b, "src/build/template.zig", day_path);

    create.dependOn(&write_templ.step);
    create.dependOn(&run_fetch.step);
}

fn doAllStep(b: *std.Build, all: *std.Build.Step, latest_day: usize) void {
    for (1..latest_day + 1) |day| {
        _ = createExecutableForDay(b, all, day);
    }
}

fn createExecutableForDay(b: *std.Build, step: *std.Build.Step, num: usize) *std.Build.Step.Compile {
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

    const check_file = b.addCheckFile(source_path, .{});
    const install = b.addInstallArtifact(exe, .{});
    install.step.dependOn(&check_file.step);
    step.dependOn(&install.step);

    return exe;
}

fn fail(b: *std.Build, msg: []const u8) void {
    const fail_step = b.addFail(msg);
    b.default_step.dependOn(&fail_step.step);
}

fn getLatestDay(b: *std.Build) usize {
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

const TemplateDayStep = struct {
    step: std.Build.Step,
    builder: *std.Build,
    source: []const u8,
    dest: []const u8,

    pub fn create(b: *std.Build, source: []const u8, dest: []const u8) *TemplateDayStep {
        const self = b.allocator.create(TemplateDayStep) catch @panic("OOM");
        self.* = .{
            .step = std.Build.Step.init(.{
                .id = .custom,
                .name = b.fmt("copy {s} to {s}", .{ source, dest }),
                .owner = b,
                .makeFn = make,
            }),
            .builder = b,
            .source = b.dupe(source),
            .dest = b.dupe(dest),
        };
        return self;
    }

    fn make(step: *std.Build.Step, _: std.Build.Step.MakeOptions) anyerror!void {
        const self: *TemplateDayStep = @fieldParentPtr("step", step);

        try std.fs.cwd().copyFile(
            self.source,
            std.fs.cwd(),
            self.dest,
            .{},
        );
    }
};
