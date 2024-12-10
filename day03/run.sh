#!/usr/bin/env bash
exec 3< <(grep -oE "mul\(\d+,\d+\)|do(n't)?\(\)")
sum1=0
sum2=0
fac=1
while read -r inst
do
	if [[ "${inst}" =~ ^mul\(([0-9]+),([0-9]+)\)$ ]]
	then
		((sum1+=BASH_REMATCH[1]*BASH_REMATCH[2]))
		((sum2+=fac*BASH_REMATCH[1]*BASH_REMATCH[2]))
	elif [[ "${inst}" == "do()" ]]
	then
		fac=1
	else # don't()
		fac=0
	fi
done <&3
exec 3<&-
echo "Part 1: ${sum1}"
echo "Part 2: ${sum2}"
