def main(input):
    res = part_one(input)
    print(res)


def part_one(input: str):
    ints = [[int(ss) for ss in s.split(" ")] for s in input.splitlines(keepends=False)]
    safe_count = 0
    for report in ints:
        is_safe = True
        is_inc = True
        prev = -1
        for i, level in enumerate(report):
            if i == 0:
                prev = level
                continue
            diff = level - prev

            if diff < 0 and is_inc and i > 1:
                is_safe = False
                break
            elif diff > 0 and not is_inc and i > 1:
                is_safe = False
                break
            elif diff < 0 and is_inc:
                is_inc = False

            if abs(diff) < 1 or abs(diff) > 3:
                is_safe = False
                break

            prev = level

        if is_safe:
            safe_count += 1

    return safe_count


def part_two(input: str):
    pass


if __name__ == "__main__":
    input = None
    with open("./input/day02", "r") as f:
        input = f.read()

    main(input)
