def main(input):
    res = part_two(input)
    print(res)


def is_safe(report: list[int]) -> bool:
    prev = 0
    is_inc = True
    for i, level in enumerate(report):
        if i == 0:
            prev = level
            continue

        diff = level - prev

        if diff < 0 and is_inc and i > 1:
            return False
        elif diff > 0 and not is_inc and i > 1:
            return False
        elif diff < 0 and is_inc:
            is_inc = False

        if abs(diff) < 1 or abs(diff) > 3:
            return False

        prev = level

    return True


def part_one(input: str):
    ints = [[int(ss) for ss in s.split(" ")] for s in input.splitlines(keepends=False)]
    safe_count = 0
    for report in ints:
        if is_safe(report):
            safe_count += 1

    return safe_count


def part_two(input: str):
    ints = [[int(ss) for ss in s.split(" ")] for s in input.splitlines(keepends=False)]
    safe_count = 0
    for report in ints:
        for i in range(len(report)):
            skipped = report.copy()
            skipped.pop(i)
            if is_safe(skipped):
                safe_count += 1
                break

    return safe_count


if __name__ == "__main__":
    input = None
    with open("./input/day02", "r") as f:
        input = f.read()

    main(input)
