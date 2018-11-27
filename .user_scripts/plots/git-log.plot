#!/usr/local/bin/gnuplot

reset
set terminal png

set xdata time
set timefmt "%Y-%m-%d"
set format x "%Y"

set xlabel "Time"
set ylabel "Commits"

set title "Commits per Day"
unset key
set grid

plot "/tmp/out.csv" using 1:2

