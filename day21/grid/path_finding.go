package grid

import (
	"iter"
	"slices"
)

func dijkstra(pad []string, from Vec) map[Vec][]int {
	type Data struct {
		cost int
		dirs []int
		done bool
	}
	mem := map[Vec]*Data{from: {}}
	for {
		var mk Vec
		var mv *Data
		for k, v := range mem {
			if !v.done && (mv == nil || v.cost < mv.cost) {
				mk = k
				mv = v
			}
		}
		if mv == nil {
			incomingDirections := make(map[Vec][]int)
			for k, v := range mem {
				incomingDirections[k] = v.dirs
			}
			return incomingDirections
		}
		mv.done = true
		for di, d := range dirs {
			np := Vec{mk.X + d.X, mk.Y + d.Y}
			if pad[np.Y][np.X] == '#' {
				continue
			}
			od := mem[np]
			if od == nil || mv.cost+1 < od.cost {
				mem[np] = &Data{mv.cost + 1, []int{di}, false}
			} else if mv.cost+1 == od.cost {
				od.dirs = append(od.dirs, di)
			}
		}
	}
}

func paths(incomingDirsMap map[Vec][]int, tar Vec) iter.Seq[[]int] {
	incomingDirs := incomingDirsMap[tar]
	return func(yield func([]int) bool) {
		if len(incomingDirs) == 0 {
			yield(incomingDirs)
		}
		for _, d := range incomingDirs {
			for p := range paths(incomingDirsMap, Vec{tar.X - dirs[d].X, tar.Y - dirs[d].Y}) {
				if !yield(append(p, d)) {
					return
				}
			}
		}
	}
}

func shortestPaths(keypad Keypad) map[Connection][][]int {
	res := make(map[Connection][][]int)
	pad := pads[keypad]
	for y, r := range pad {
		for x, c := range r {
			if c != ' ' && c != '#' {
				cur := Vec{x, y}
				incomingDirsMap := dijkstra(pad, cur)
				for tar := range incomingDirsMap {
					res[Connection{cur, tar}] = slices.Collect(paths(incomingDirsMap, tar))
				}
			}
		}
	}
	return res
}
