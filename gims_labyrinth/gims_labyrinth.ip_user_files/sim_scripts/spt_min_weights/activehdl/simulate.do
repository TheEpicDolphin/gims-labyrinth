onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+spt_min_weights -L xil_defaultlib -L xpm -L blk_mem_gen_v8_4_1 -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.spt_min_weights xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {spt_min_weights.udo}

run -all

endsim

quit -force
