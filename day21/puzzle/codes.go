package puzzle

import (
	"bufio"
	"day21/grid"
	"os"
	"strconv"
)

type Code struct {
	vecs []grid.Vec
	num  int
}

// no error checking, be careful!
func ReadCodes() (codes []Code) {
	for scanner := bufio.NewScanner(os.Stdin); scanner.Scan(); {
		code := scanner.Text()
		vecs := make([]grid.Vec, len(code)+1)
		vecs[0] = grid.RuneToVec('A')
		for i, c := range code {
			vecs[i+1] = grid.RuneToVec(c)
		}
		num, _ := strconv.Atoi(code[:len(code)-1])
		codes = append(codes, Code{vecs, num})
	}
	return
}

func (c Code) complexity(minCosts map[grid.Connection]int) int {
	sum := 0
	for i, v := range c.vecs[1:] {
		sum += minCosts[grid.NewConnection(c.vecs[i], v)]
	}
	return sum * c.num
}

func SumComplexities(codes []Code, dc *DirCosts) (sum int) {
	minCosts := minCosts(grid.Numpad, dc)
	for _, c := range codes {
		sum += c.complexity(minCosts)
	}
	return
}
