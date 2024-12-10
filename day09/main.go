package main

import (
	"fmt"
	"io"
	"os"
	"slices"
)

func read() string {
	b, err := io.ReadAll(os.Stdin)
	if err != nil {
		panic(err)
	}
	if b[len(b)-1] == '\n' {
		b = b[:len(b)-1] // remove trailing new line
	}
	return string(b)
}

func part1(s string) int {
	blocks := []int{}
	for i, ch := range s {
		v := i / 2
		if i%2 != 0 {
			v = -1
		}
		for range int(ch - '0') {
			blocks = append(blocks, v)
		}
	}
	l, r := 0, len(blocks)-1
	for {
		l += slices.Index(blocks[l:], -1)
		for blocks[r] == -1 {
			r--
		}
		if l >= r {
			break
		}
		blocks[l], blocks[r] = blocks[r], -1
	}
	sum := 0
	for i, x := range blocks {
		if x == -1 {
			break
		}
		sum += i * x
	}
	return sum
}

func part2(s string) int {
	type File struct {
		idx int
		pos int
		len int
	}
	type Gap struct {
		pos int
		len int
	}
	files := make([]File, 0, (len(s)+1)/2)
	gaps := make([]Gap, 0, len(s)/2)
	pos := 0
	for i, ch := range s {
		sz := int(ch - '0')
		if i%2 == 0 {
			files = append(files, File{i / 2, pos, sz})
		} else {
			gaps = append(gaps, Gap{pos, sz})
		}
		pos += sz
	}
	for i, f := range slices.Backward(files) {
		var g *Gap
		for i, gi := range gaps {
			if gi.len >= f.len {
				g = &gaps[i]
				break
			}
		}
		if g == nil || g.pos > f.pos {
			continue
		}
		files[i].pos = g.pos
		g.pos += f.len
		g.len -= f.len
	}
	sum := 0
	for _, f := range files {
		for i := range f.len {
			sum += (f.pos + i) * f.idx
		}
	}
	return sum
}

func main() {
	s := read()
	fmt.Printf("Part 1: %d\n", part1(s))
	fmt.Printf("Part 2: %d\n", part2(s))
}
