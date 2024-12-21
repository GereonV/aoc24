package grid

import (
	"iter"
	"maps"
	"strings"
)

type Keypad int

const (
	Numpad Keypad = iota
	Dirpad
)

var pads = [][]string{
	Numpad: {
		" ### ",
		"#789#",
		"#456#",
		"#123#",
		" #0A#",
		"  ## ",
	},
	Dirpad: {
		"  ## ",
		" #^A#",
		"#<v>#",
		" ### ",
	},
}

var runes = func() map[rune]Vec {
	runes := "0123456789A"
	res := make(map[rune]Vec, len(runes))
outer:
	for _, c := range runes {
		for y, r := range pads[Numpad] {
			if x := strings.Index(r, string(c)); x != -1 {
				res[c] = Vec{x, y}
				continue outer
			}
		}
		panic("should never happen")
	}
	return res
}()

// no error checking, be careful!
func RuneToVec(r rune) Vec {
	return runes[r]
}

var shortestPathss = []map[Connection][][]int{
	Numpad: shortestPaths(Numpad),
	Dirpad: shortestPaths(Dirpad),
}

func Connections(keypad Keypad) iter.Seq[Connection] {
	return maps.Keys(shortestPathss[keypad])
}

func ShortestPaths(keypad Keypad, c Connection) iter.Seq[[]int] {
	v := shortestPathss[keypad][c]
	cpy := make([]int, len(v[0]))
	return func(yield func([]int) bool) {
		for _, path := range v {
			copy(cpy, path)
			if !yield(cpy) {
				return
			}
		}
	}
}
