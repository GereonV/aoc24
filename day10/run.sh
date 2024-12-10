#!/usr/bin/env bash
if command -v docker &> /dev/null; then
	dop=docker
elif command -v podman &> /dev/null; then
	dop=podman
else
	echo "neither docker nor podman found" >&2
	exit 1
fi
"$dop" run --rm -i --arch amd64\
	--mount type=bind,src="$(pwd)"/main.s,dst=/day10.s,ro docker.io/library/alpine\
	sh -c 'apk add nasm gcc musl-dev && nasm -O2 -f elf64 day10.s && gcc -O3 -fPIC day10.o && ./a.out'
