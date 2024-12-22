#!/usr/bin/env bash

# this uses runtime inputs
g++ @compile_flags.txt -DRUNTIME main.cpp && exec ./a.out

mv main.cpp main.cpp.bak
trap "mv main.cpp.bak main.cpp" EXIT
lineno=$(grep -En '\{\{input\}\}' main.cpp.bak | cut -d: -f1) || exit
head -n $((lineno - 1)) <main.cpp.bak >main.cpp
while read -r line; do
	echo "${line}," >>main.cpp
done
tail -n +$((lineno + 1)) <main.cpp.bak >>main.cpp
g++ @compile_flags.txt main.cpp && exec ./a.out
