from collections import defaultdict, deque
from copy import deepcopy


def main(input):
    res = part_one(input)
    print(f"part_one: {res}")
    res = part_two(input)
    print(f"part_two: {res}")


def part_one(input: str):
    lines: list[str] = input.splitlines(keepends=False)
    br = lines.index("")
    depl = [ln.split("|") for ln in lines[:br]]
    deps = defaultdict(list)
    for pair in depl:
        deps[int(pair[1])].append(int(pair[0]))

    updates = [[int(x) for x in ln.split(",")] for ln in lines[br+1:]]

    total = 0
    for update in updates:
        seen = set()
        good = True
        for n in update:
            reqs = deps[n]
            for r in reqs:
                if r not in seen and r in update:
                    good = False
                    break

            if not good:
                break
            seen.add(n)

        if good:
            mid = len(update) // 2
            total += update[mid]

    return total


def topological_sort(lst, deps):
    q = deque()
    for n in lst:
        if n not in deps:
            q.append(n)
        else:
            deplist = deps[n]
            i = len(deplist)-1
            while i >= 0 and len(deplist) > 0:
                if deplist[i] not in lst:
                    deplist.pop(i)
                i -= 1

            if len(deplist) == 0:
                q.append(n)

    res = []
    while q:
        node = q.popleft()
        res.append(node)
        for m, deplist in deps.items():
            if node in deplist and m in lst:
                deplist.remove(node)
                if len(deplist) == 0:
                    q.append(m)
    return res


def part_two(input: str):
    lines: list[str] = input.splitlines(keepends=False)
    br = lines.index("")
    # (prereq, target)
    depl = [ln.split("|") for ln in lines[:br]]
    deps = defaultdict(list)
    for pair in depl:
        deps[int(pair[1])].append(int(pair[0]))

    updates = [[int(x) for x in ln.split(",")] for ln in lines[br+1:]]

    unsorted_updates = []
    for update in updates:
        seen = set()
        good = True
        for n in update:
            reqs = deps[n]
            for r in reqs:
                if r not in seen and r in update:
                    good = False
                    break
            if not good:
                unsorted_updates.append(update)
                break
            seen.add(n)

    total = 0
    for unsorted in unsorted_updates:
        sorted = topological_sort(unsorted, deepcopy(deps))
        total += sorted[len(sorted) // 2]

    return total


if __name__ == "__main__":
    input = None
    with open("./input/day05", "r") as f:
        input = f.read()

    main(input)
