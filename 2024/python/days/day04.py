def main(input):
    res = part_one(input)
    print(f"part_one: {res}")
    res = part_two(input)
    print(f"part_two: {res}")


XMAS = "XMAS"


def check_hor(j, row):
    ret = 0
    if j + 3 < len(row) and row[j:j + 4] == XMAS:
        ret += 1
    if j - 3 > 0 and row[j:j - 4:-1] == XMAS:
        ret += 1
    elif (
        j - 3 == 0
        and row[j-1] == XMAS[1]
        and row[j-2] == XMAS[2]
        and row[j-3] == XMAS[3]
    ):
        ret += 1

    return ret


def check_ver(i, j, mat):
    ret = 0
    if (
        i + 3 < len(mat)
        and mat[i + 1][j] == XMAS[1]
        and mat[i + 2][j] == XMAS[2]
        and mat[i + 3][j] == XMAS[3]
    ):
        ret += 1
    if (
        i - 3 >= 0
        and mat[i - 1][j] == XMAS[1]
        and mat[i - 2][j] == XMAS[2]
        and mat[i - 3][j] == XMAS[3]
    ):
        ret += 1
    return ret


def check_dia(i, j, mat):
    ret = 0
    if (
        i + 3 < len(mat)
        and j + 3 < len(mat[0])
        and mat[i + 1][j + 1] == XMAS[1]
        and mat[i + 2][j + 2] == XMAS[2]
        and mat[i + 3][j + 3] == XMAS[3]
    ):
        ret += 1
    if (
        i - 3 >= 0
        and j - 3 >= 0
        and mat[i - 1][j - 1] == XMAS[1]
        and mat[i - 2][j - 2] == XMAS[2]
        and mat[i - 3][j - 3] == XMAS[3]
    ):
        ret += 1
    if (
        i - 3 >= 0
        and j + 3 < len(mat[0])
        and mat[i - 1][j + 1] == XMAS[1]
        and mat[i - 2][j + 2] == XMAS[2]
        and mat[i - 3][j + 3] == XMAS[3]
    ):
        ret += 1
    if (
        i + 3 < len(mat)
        and j - 3 >= 0
        and mat[i + 1][j - 1] == XMAS[1]
        and mat[i + 2][j - 2] == XMAS[2]
        and mat[i + 3][j - 3] == XMAS[3]
    ):
        ret += 1
    return ret


def part_one(input: str):
    mat = [line for line in input.splitlines(keepends=False)]
    total = 0
    for i, row in enumerate(mat):
        for j, let in enumerate(row):
            if let == "X":
                hres = check_hor(j, row)
                vres = check_ver(i, j, mat)
                dres = check_dia(i, j, mat)
                # if hres > 0:
                #     print(f"hres at: {i}, {j} ({hres})")
                # if vres > 0:
                #     print(f"vres at: {i}, {j} ({vres}) ")
                # if dres > 0:
                #     print(f"dres at: {i}, {j} ({dres})")
                # if hres or vres or dres:
                #     print()
                total += hres + vres + dres

    return total


MS = "MS"


def check_exes(mat, i, j) -> int:
    top_left = mat[i-1][j-1]
    top_right = mat[i-1][j+1]
    bot_left = mat[i+1][j-1]
    bot_right = mat[i+1][j+1]

    return ((top_left != bot_right and top_left in MS and bot_right in MS)
            and (top_right != bot_left and top_right in MS and bot_left in MS))


def part_two(input: str):
    mat = [line for line in input.splitlines(keepends=False)]
    total = 0
    for i, row in enumerate(mat):
        if i == 0 or i >= len(mat)-1:
            continue
        for j, let in enumerate(row):
            if j == 0 or j >= len(row)-1:
                continue

            if let == "A":
                res = check_exes(mat, i, j)
                # if res:
                #     print(f"res at: {i}, {j} ({res})")
                total += res
    return total


if __name__ == "__main__":
    input = None
    with open("./input/day04", "r") as f:
        input = f.read()

    main(input)
