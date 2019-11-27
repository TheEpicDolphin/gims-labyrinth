onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib pixel_backpointers_opt

do {wave.do}

view wave
view structure
view signals

do {pixel_backpointers.udo}

run -all

quit -force
