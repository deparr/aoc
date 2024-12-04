import urllib.request
import sys

# todo: make this runnable from root and auto detect current year
active_langs = ["ocaml", "python"]


def main():
    if len(sys.argv) < 2:
        print("need day argument, exiting...")
        return 1
    print(sys.argv)
    daynum = int(sys.argv[1])

    with open("./aoc-cookie", "r") as f:
        cookie = f.read().strip()
    cookie = f"session={cookie}"

    url = f"https://adventofcode.com/2024/day/{daynum}/input"
    req = urllib.request.Request(url, method="GET", headers={"Cookie": cookie})
    with urllib.request.urlopen(req) as res:
        input = res.read().decode("utf-8")

    for lang in active_langs:
        with open(f"./{lang}/input/day{daynum:02}", "w", newline="\n") as of:
            written = of.write(input)
            while written != len(input):
                written += of.write(input[written:])


if __name__ == "__main__":
    sys.exit(main())
