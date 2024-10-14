#!/usr/bin/env bash

last_day=$(ls src | grep 'day' | sort | tail -1 | tr -cd '[:digit:]')
if [[ -z $last_day ]]; then
    last_day="0"
fi

next_num=$((10#$last_day + 1))

if [ $next_num -gt 25 ]; then
    echo "All days created. Merry Chirstmas 🎄!"
    exit 0
fi

next_day=$(printf "day_%03d.zig" $next_num)

echo "creating $next_day"
cat << EOF > "src/$next_day"
const std = @import("std");
const util = @import("util.zig");

const print = std.debug.print;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const ally = arena.allocator();

    var input = try util.getFullInput(ally);
}

EOF

echo "paste in day $next_num input:"
mapfile -t input
printf "%s\n" "${input[@]}" >  "input/day$next_num"

printf '\ndone!\n'
