def main(input):
    res = part_one(input)
    print(f"part_one: {res}")
    res = part_two(input)
    print(f"part_two: {res}")


def any_op(ops, x, y, t):
    for op in ops:
        if op(x, y, t):
            return True
    return False


ops = [
        (lambda x, y, t: (x + y) == t),
        (lambda x, y, t: (x * y) == t),
        (lambda x, y, t: int(f"{x}{y}") == t)
]


def is_valid(test, expr, cur):
    if len(expr) == 1:
        return cur + expr[0] == test or cur * expr[0] == test

    next_add = cur + expr[0]
    next_mul = cur * expr[0]
    next_expr = expr[1:]

    return (is_valid(test, next_expr, next_add)
            or is_valid(test, next_expr, next_mul))


def is_valid2(test, expr, cur):
    if len(expr) == 1:
        return any_op(ops, cur, expr[0], test)

    next_add = cur + expr[0]
    next_mul = cur * expr[0]
    next_con = int(f"{cur}{expr[0]}")
    next_expr = expr[1:]

    return (is_valid2(test, next_expr, next_add)
            or is_valid2(test, next_expr, next_mul)
            or is_valid2(test, next_expr, next_con))


def part_one(input: str):
    pairs = [
        (lambda ls: (int(ls[0]), [int(x) for x in ls[1].strip().split(" ")]))(
            line.split(":")
        )
        for line in input.splitlines()
    ]

    total = 0
    for p in pairs:
        if is_valid(p[0], p[1][1:], p[1][0]):
            total += p[0]

    return total


def part_two(input: str):
    pairs = [
        (lambda ls: (int(ls[0]), [int(x) for x in ls[1].strip().split(" ")]))(
            line.split(":")
        )
        for line in input.splitlines()
    ]

    total = 0
    for p in pairs:
        if is_valid2(p[0], p[1][1:], p[1][0]):
            total += p[0]

    return total


if __name__ == "__main__":
    input = None
    with open("./input/day07", "r") as f:
        input = f.read()

    main(input)
