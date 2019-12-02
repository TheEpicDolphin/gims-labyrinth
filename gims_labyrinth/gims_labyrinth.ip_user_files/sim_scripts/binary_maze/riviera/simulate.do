onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+binary_maze -L xil_defaultlib -L xpm -L blk_mem_gen_v8_4_1 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.binary_maze xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {binary_maze.udo}

run -all

endsim

quit -force
