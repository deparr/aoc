#!/usr/bin/env python3
import os

template = """
def main(input):
    res = part_one(input)
    print(res)


def part_one(input: str):
    pass


def part_two(input: str):
    pass


if __name__ == "__main__":
    input = None
    with open("./input/__DAY_NUM__", "r") as f:
        input = f.read()

    main(input)
"""


def main() -> int:
    files: list[str] = os.listdir("./days")
    files = list(filter(lambda f: "day" in f, files))
    files.sort(reverse=True)
    last = files[0]
    num_start = last.find("day") + 3
    day_num = int(last[num_start:num_start+2]) + 1

    if day_num > 25:
        print("Advent of code is over! Merry Christmas 🎄")
        return 1

    print(f"creating day {day_num}...")
    day_str = f"day{day_num:02}"
    out_file = f"./days/{day_str}.py"

    out = template.replace("__DAY_NUM__", day_str)

    with open(out_file, "w") as of:
        print(out, file=of)

    print(f"day {day_num} created")


if __name__ == "__main__":
    main()
