vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/blk_mem_gen_v8_4_1
vlib modelsim_lib/msim/xil_defaultlib

vmap blk_mem_gen_v8_4_1 modelsim_lib/msim/blk_mem_gen_v8_4_1
vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vlog -work blk_mem_gen_v8_4_1 -64 -incr \
"../../../ipstatic/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib -64 -incr \
"../../../../gims_labyrinth.srcs/sources_1/ip/pixel_type_map/sim/pixel_type_map.v" \


vlog -work xil_defaultlib \
"glbl.v"

