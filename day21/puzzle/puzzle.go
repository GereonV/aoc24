package puzzle

import (
	"day21/grid"
)

// The costs to go from the first to the second directional button and click it.
// The indicies are the same as for grid.dirs,
// except that the additional index 4 is for 'A' button.
type DirCosts [5][5]int

const a = 4

// all ones, because the human operator can always press any button on the dirpad with cost 1
func HumanCosts() (costs *DirCosts) {
	costs = new(DirCosts)
	for y := range costs {
		for x := range costs {
			costs[y][x] = 1
		}
	}
	return
}

func pathCost(dc *DirCosts, path []int) int {
	at := a
	cost := 0
	for _, d := range path {
		cost += dc[at][d]
		at = d
	}
	return cost + dc[at][a]
}

func minCosts(keypad grid.Keypad, dc *DirCosts) map[grid.Connection]int {
	res := make(map[grid.Connection]int)
	for c := range grid.Connections(keypad) {
		minCost := int(^uint(0) >> 1) // max int
		for path := range grid.ShortestPaths(keypad, c) {
			minCost = min(minCost, pathCost(dc, path))
		}
		res[c] = minCost
	}
	return res
}

func InceptionDirCosts(dc *DirCosts) *DirCosts {
	costs := minCosts(grid.Dirpad, dc)
	pos := []grid.Vec{
		{X: 2, Y: 1}, // ^
		{X: 3, Y: 2}, // >
		{X: 2, Y: 2}, // v
		{X: 1, Y: 2}, // <
		{X: 3, Y: 1}, // A
	}
	dc = new(DirCosts)
	for fi, from := range pos {
		for ti, to := range pos {
			dc[fi][ti] = costs[grid.NewConnection(from, to)]
		}
	}
	return dc
}
