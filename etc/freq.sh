#!/bin/sh
set -eu

for cpu in $(seq 1 $(nproc)); do
	echo "scale=100000;pi=4*a(1);0" | bc -l &
	echo $!
done | ( \
	sleep .1 ;
        mhz=$(cat /proc/cpuinfo | grep "^[c]pu MHz" | cut -d: -f2 | tr -d ' ' | sort -nr | head -1);
	printf "$(echo "scale=2; ($mhz + 5)/1000" | bc)ghz\n"
        while IFS= read -r pid; do
		kill "$pid";
	done )

