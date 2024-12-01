import re
from collections import Counter


with open("input/day01", "r") as f:
    input = f.read().splitlines(keepends=False)

    lr = []
    r = []
    for s in input:
        ss = re.split(" +", s)
        lr.append(int(ss[0]))
        r.append(int(ss[1]))

    lr.sort()

    rc = Counter(r)

    res = 0
    for ln in lr:
        res += ln * rc[ln]

    print(res)
