import sys

inp = sys.stdin.read().splitlines()
h, w = len(inp), len(inp[0])


def within(x, y):
    return 0 <= x < w and 0 <= y < h


def check(x, y):
    pos = (
        [(x + i, y) for i in range(4)],
        [(x, y + i) for i in range(4)],
        [(x + i, y + i) for i in range(4)],
        [(x + i, y - i) for i in range(4)],
    )
    ss = ["".join(inp[y][x] for x, y in p if within(x, y)) for p in pos]
    ss += ["".join(reversed(s)) for s in ss]
    return sum(1 for s in ss if s == "XMAS")


def check2(x, y):
    pos = (
        [(x + i, y + i) for i in range(-1, 2)],
        [(x + i, y - i) for i in range(-1, 2)],
    )
    ss = ["".join(inp[y][x] for x, y in p if within(x, y)) for p in pos]
    return all(s in ("MAS", "SAM") for s in ss)


for i, f in enumerate((check, check2)):
    res = sum(f(x, y) for x in range(w) for y in range(h))
    print(f"Part {i + 1}: {res}")
