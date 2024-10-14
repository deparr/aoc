const std = @import("std");
const print = std.debug.print;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const dayno: ?usize = b.option(usize, "day", "Day number");

    if (dayno) |day| {
        if (day == 0 or day > 25) {
            print("Invalid day: {d}\nrange: [1-25]\n", .{day});
            std.process.exit(2);
        }
        const name = b.fmt("day_{d:0>3}.zig", .{day});
        const infile = b.fmt("input/day{d}", .{day});
        const root_path = b.fmt("src/{s}", .{name});

        const exe = b.addExecutable(.{
            .name = std.fs.path.stem(name),
            .root_source_file = b.path(root_path),
            .target = target,
            .optimize = optimize,
        });

        const run_cmd = b.addRunArtifact(exe);
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        run_cmd.setStdIn(.{ .lazy_path = b.path(infile) });
        b.default_step.dependOn(&run_cmd.step);
    } else {
        print("Select a day to run with -Dday={{day}}\n", .{});
    }
}
