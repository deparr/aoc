import re


def main(input):
    res = part_two(input)
    print(res)


def part_one(input: str):
    matches = re.findall(r"mul\(\d+,\d+\)", input)
    res = 0
    for match in matches:
        comma_idx = match.find(",")
        open_par = match.find("(")
        close_par = match.find(")")

        lf = int(match[open_par + 1:comma_idx])
        r = int(match[comma_idx + 1:close_par])
        res += lf * r

    return res


def part_two(input: str):
    matches = re.findall(r"mul\(\d+,\d+\)|do\(\)|don't\(\)", input)
    enabled = True
    res = 0
    for match in matches:
        if match == "do()":
            enabled = True
            continue
        if match == "don't()":
            enabled = False
            continue

        if not enabled:
            continue

        comma_idx = match.find(",")
        open_par = match.find("(")
        close_par = match.find(")")

        lf = int(match[open_par + 1:comma_idx])
        r = int(match[comma_idx + 1:close_par])
        res += lf * r

    return res


if __name__ == "__main__":
    input = None
    with open("./input/day03", "r") as f:
        input = f.read()

    main(input)
