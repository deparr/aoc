
def main(input):
    res = part_one(input)
    print(f"part_one: {res}")
    res = part_two(input)
    print(f"part_two: {res}")


def part_one(input: str):
    pass


def part_two(input: str):
    pass


if __name__ == "__main__":
    input = None
    with open("./input/day09", "r") as f:
        input = f.read()

    main(input)

