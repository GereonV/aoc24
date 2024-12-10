package main

import (
	"bufio"
	"fmt"
	"os"
	"sync"
	"sync/atomic"
)

var inp [][]int

type pos struct{ x, y int }

func hike(p pos, c chan pos) {
	if inp[p.y][p.x] == 9 {
		c <- p
		return
	}
	ps := []pos{
		{p.x + 1, p.y},
		{p.x - 1, p.y},
		{p.x, p.y + 1},
		{p.x, p.y - 1},
	}
	var wg sync.WaitGroup
	for _, p2 := range ps {
		if 0 <= p2.y && p2.y < len(inp) && 0 <= p2.x && p2.x < len(inp[p2.y]) && inp[p2.y][p2.x] == inp[p.y][p.x]+1 {
			wg.Add(1)
			go func() {
				hike(p2, c)
				wg.Done()
			}()
		}
	}
	wg.Wait()
}

func scoreAndRate(p pos) (int64, int64) {
	c := make(chan pos)
	go func() {
		hike(p, c)
		close(c)
	}()
	m := make(map[pos]bool)
	var s int64
	for p := range c {
		m[p] = true
		s++
	}
	return int64(len(m)), s
}

func solve() (int64, int64) {
	var sum1, sum2 atomic.Int64
	var wg sync.WaitGroup
	for y, l := range inp {
		for x, h := range l {
			if h == 0 {
				wg.Add(1)
				go func() {
					s1, s2 := scoreAndRate(pos{x, y})
					sum1.Add(s1)
					sum2.Add(s2)
					wg.Done()
				}()
			}
		}
	}
	wg.Wait()
	return sum1.Load(), sum2.Load()
}

func main() {
	sc := bufio.NewScanner(os.Stdin)
	for sc.Scan() {
		s := sc.Text()
		l := make([]int, len(s))
		for i, ch := range s {
			l[i] = int(ch - '0')
		}
		inp = append(inp, l)
	}
	p1, p2 := solve()
	fmt.Printf("Part 1: %d\n", p1)
	fmt.Printf("Part 2: %d\n", p2)
}
