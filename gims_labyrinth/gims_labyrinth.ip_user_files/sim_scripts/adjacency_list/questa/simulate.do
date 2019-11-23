onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib adjacency_list_opt

do {wave.do}

view wave
view structure
view signals

do {adjacency_list.udo}

run -all

quit -force
