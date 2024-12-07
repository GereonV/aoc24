"use strict"

import { readFileSync } from 'fs'
const lines = readFileSync(process.stdin.fd, 'utf-8').split("\n");
--lines.length;  // get rid of UNIX newline

function solve(line: string, possibilities: (x: number, y: number) => number[]): number {
	const [ress, nums] = line.split(": ");
	const res = +ress;
	const [x, ...xs] = nums.split(" ").map(x => +x);
	const works = (x: number, xs: number[]): boolean => {
		if (xs.length === 0)
			return x === res;
		const [y, ...ys] = xs;
		return possibilities(x, y).some(z => works(z, ys));
	};
	return works(x, xs) ? res : 0;
}

const part1 = (x: number, y: number) => [x + y, x * y];
const part2 = (x: number, y: number) => [...part1(x, y), +`${x}${y}`];
[part1, part2].forEach((f, i) => console.log(`Part ${i + 1}: ${lines.map(l => solve(l, f)).reduce((acc, x) => acc + x, 0)}`));
