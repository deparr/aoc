import re


with open("input/day01", "r") as f:
    input = f.read().splitlines(keepends=False)

    lr = []
    r = []
    for s in input:
        ss = re.split(" +", s)
        lr.append(int(ss[0]))
        r.append(int(ss[1]))

    lr.sort()
    r.sort()

    res = 0
    with open("out01", "w") as of:
        for ln, rn in zip(lr, r):
            res += abs(ln - rn)
            print(f"{ln} {rn}", file=of)

    print(res)
