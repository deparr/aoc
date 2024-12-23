from collections import defaultdict


def main(input):
    res = part_one(input)
    print(f"part_one: {res}")
    res = part_two(input)
    print(f"part_two: {res}")


def part_one(input: str):
    map = [list(line) for line in input.splitlines(keepends=False)]
    locs = defaultdict(list)
    for i, row in enumerate(map):
        for j, let in enumerate(row):
            if let != ".":
                locs[let].append((i, j))


def part_two(input: str):
    pass


if __name__ == "__main__":
    input: str
    with open("./input/day08", "r") as f:
        input = f.read()

    main(input)
