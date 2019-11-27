onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib corner_node_fifo_opt

do {wave.do}

view wave
view structure
view signals

do {corner_node_fifo.udo}

run -all

quit -force
