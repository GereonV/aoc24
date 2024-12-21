import sys

inp = [(int((t := l.split(","))[0]), int(t[1])) for l in sys.stdin]

start = 0, 0
end = 70, 70
bytes_ = set(inp[:1024])


def dijkstra(bytes_) -> dict[tuple[int, int], int]:
    dists = {start: 0}
    seen: set[tuple[int, int]] = set()
    while (unseen := dists.keys() - seen):
        cur = min(unseen, key=dists.__getitem__)
        seen.add(cur)
        x, y = cur
        for dx, dy in ((0, -1), (1, 0), (0, 1), (-1, 0)):
            if not (0 <= x + dx <= end[0] and 0 <= y + dy <= end[1]):
                continue
            np = x + dx, y + dy
            if np not in bytes_ and dists[cur] + 1 < dists.get(np, 1e100):
                dists[np] = dists[cur] + 1
    return dists


print("Part 1:", dijkstra(bytes_)[end])

lo, hi = 1024, len(inp)
while lo < hi:
    m = (lo + hi) // 2
    nb = frozenset(inp[:m + 1])
    r = dijkstra(nb)
    if end in r:
        lo = m + 1
    else:
        hi = m
x, y = inp[lo]
print(f"Part 2: {x},{y}")
