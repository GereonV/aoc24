import itertools as it
import sys

# stolen from someone I don't remember, sry :/
lines = list(sys.stdin)
grid = {complex(i, j) for i, r in enumerate(lines) for j, c in enumerate(r) if c != "#"}


def distances():
    (start,) = (
        complex(y, x) for y, r in enumerate(lines) for x, c in enumerate(r) if c == "S"
    )
    # BFS
    d = {start: 0}
    q = [start]
    while q:
        cur = q.pop(0)
        for next in cur - 1, cur + 1, cur - 1j, cur + 1j:
            if next in grid and next not in d:
                d[next] = d[cur] + 1
                q.append(next)
    return d


parts = [2, 20]
solutions = [0 for _ in parts]
dists = distances()
for posA, posB in it.combinations(dists, 2):  # horribly inefficient but who cares?
    d = posA - posB
    cheatLen = sum(abs(x) for x in (d.real, d.imag))
    fasterBy = abs(dists[posA] - dists[posB]) - cheatLen
    if fasterBy < 100:
        continue
    for i, p in enumerate(parts):
        if cheatLen <= p:
            solutions[i] += 1

for i, p in enumerate(solutions, 1):
    print(f"Part {i}: {p}")
