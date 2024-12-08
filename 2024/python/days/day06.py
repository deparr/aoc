def main(input):
    res = part_one(input)
    print(f"part_one: {res}")
    res = part_two(input)
    print(f"part_two: {res}")


def get_path(str_map) -> tuple[list[str], list[int]]:
    map = list(input)
    n = str_map.find("\n") + 1
    left, right, up, down = -1, 1, -n, n
    dirs = [up, right, down, left]
    cur = input.find("^")
    dir = 0
    dir_map = [None] * len(map)

    while 0 <= cur < len(map):
        map[cur] = "X"
        dir_map[cur] = dirs[dir]
        match dirs[dir]:
            case - 1:
                next = cur + left
                if next <= 0 or map[next] == "\n":
                    break
            case 1:
                next = cur + right
                if next >= len(map) or map[next] == "\n":
                    break
            case row_width if row_width == -n:
                next = cur + up
                if next <= 0:
                    break
            case _:
                next = cur + down
                if next >= len(map):
                    break

        if map[next] == "#":
            dir = (dir + 1) % len(dirs)
        else:
            cur = next

    return map, dirs, dir_map


def has_cycle(map, dirs, start, start_dir) -> bool:
    cur = start
    dir = start_dir
    n = dirs[2]
    max_iter = 0
    while 0 <= cur < len(map) and max_iter < 10000:
        match dirs[dir]:
            case - 1:
                next = cur - 1
                if next <= 0 or map[next] == "\n":
                    return False

            case 1:
                next = cur + 1
                if next >= len(map) or map[next] == "\n":
                    return False
            case row_width if row_width == -n:
                next = cur - n
                if next <= 0:
                    return False
            case _:
                next = cur + n
                if next >= len(map):
                    return False
        if next == start:
            return True

        if map[next] == "#":
            dir = (dir + 1) % len(dirs)
        else:
            cur = next
        max_iter += 1

    return False


def part_one(input: str):
    walked_map, _, _ = get_path(input)
    return walked_map.count("X")


def part_two(input: str):
    walked_map, dirs, dir_map = get_path(input)
    total = 0
    for i, cell in enumerate(walked_map):
        if cell == "X":
            walked_map[i] = "#"
            prev_cell = i + -dir_map[i]
            rotated_dir = (dirs.index(dir_map[i]) + 1) % len(dirs)
            if has_cycle(walked_map, dirs, prev_cell, rotated_dir):
                print(i // dirs[2], i % dirs[2])
                total += 1

            walked_map[i] = "X"

    return total


if __name__ == "__main__":
    input = None
    with open("./input/day06.test", "r") as f:
        input = f.read()

    main(input)
