onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib binary_maze_opt

do {wave.do}

view wave
view structure
view signals

do {binary_maze.udo}

run -all

quit -force
