package main

import (
	"day21/puzzle"
	"fmt"
)

func main() {
	parts := []int{3, 26} // number of dirpad layers / total robots involved
	codes := puzzle.ReadCodes()
	costMatricies := make([]*puzzle.DirCosts, parts[len(parts)-1])
	costMatricies[0] = puzzle.HumanCosts()
	for i := 1; i < len(costMatricies); i++ {
		costMatricies[i] = puzzle.InceptionDirCosts(costMatricies[i-1])
	}
	for i, p := range parts {
		c := puzzle.SumComplexities(codes, costMatricies[p-1])
		fmt.Printf("Part %d: %d\n", i+1, c)
	}
}
