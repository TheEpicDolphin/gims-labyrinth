onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib cam_image_buffer_opt

do {wave.do}

view wave
view structure
view signals

do {cam_image_buffer.udo}

run -all

quit -force
