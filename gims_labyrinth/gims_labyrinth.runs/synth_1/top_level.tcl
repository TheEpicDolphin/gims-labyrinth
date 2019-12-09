# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
set_param xicom.use_bs_reader 1
create_project -in_memory -part xc7a100tcsg324-3

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_msg_config -source 4 -id {IP_Flow 19-2162} -severity warning -new_severity info
set_property webtalk.parent_dir C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/gims_labyrinth.cache/wt [current_project]
set_property parent.project_path C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/gims_labyrinth.xpr [current_project]
set_property XPM_LIBRARIES {XPM_CDC XPM_MEMORY} [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language Verilog [current_project]
set_property ip_output_repo c:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/gims_labyrinth.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
add_files C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/python_stuff/verilog_testing/bin_maze.coe
add_files C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/python_stuff/verilog_testing/pixel_type_map.coe
add_files C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/python_stuff/verilog_testing/maze_img.coe
read_verilog -library xil_defaultlib -sv {
  C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/gims_labyrinth.srcs/sources_1/new/backpointer_tracer.sv
  C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/gims_labyrinth.srcs/sources_1/new/dilation.sv
  C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/gims_labyrinth.srcs/sources_1/new/divider.sv
  C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/gims_labyrinth.srcs/sources_1/new/erosion.sv
  C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/gims_labyrinth.srcs/sources_1/new/lees_algorithm.sv
  C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/gims_labyrinth.srcs/sources_1/new/rgb_2_hsv.sv
  C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/gims_labyrinth.srcs/sources_1/new/signal_processing.sv
  C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/gims_labyrinth.srcs/sources_1/new/skeletonizer.sv
  C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/gims_labyrinth.srcs/sources_1/new/thresholder.sv
  C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/gims_labyrinth.srcs/sources_1/new/top_level.sv
}
read_ip -quiet C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/gims_labyrinth.srcs/sources_1/ip/path_bram/path_bram.xci
set_property used_in_implementation false [get_files -all c:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/gims_labyrinth.srcs/sources_1/ip/path_bram/path_bram_ooc.xdc]

read_ip -quiet C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/gims_labyrinth.srcs/sources_1/ip/binary_maze/binary_maze.xci
set_property used_in_implementation false [get_files -all c:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/gims_labyrinth.srcs/sources_1/ip/binary_maze/binary_maze_ooc.xdc]

read_ip -quiet C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/gims_labyrinth.srcs/sources_1/ip/pixel_backpointers/pixel_backpointers.xci
set_property used_in_implementation false [get_files -all c:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/gims_labyrinth.srcs/sources_1/ip/pixel_backpointers/pixel_backpointers_ooc.xdc]

read_ip -quiet C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/gims_labyrinth.srcs/sources_1/ip/visited_map/visited_map.xci
set_property used_in_implementation false [get_files -all c:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/gims_labyrinth.srcs/sources_1/ip/visited_map/visited_map_ooc.xdc]

read_ip -quiet C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/gims_labyrinth.srcs/sources_1/ip/cam_image_buffer/cam_image_buffer.xci
set_property used_in_implementation false [get_files -all c:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/gims_labyrinth.srcs/sources_1/ip/cam_image_buffer/cam_image_buffer_ooc.xdc]

read_ip -quiet C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/gims_labyrinth.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xci
set_property used_in_implementation false [get_files -all c:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/gims_labyrinth.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_board.xdc]
set_property used_in_implementation false [get_files -all c:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/gims_labyrinth.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0.xdc]
set_property used_in_implementation false [get_files -all c:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/gims_labyrinth.srcs/sources_1/ip/clk_wiz_0/clk_wiz_0_ooc.xdc]

# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/gims_labyrinth.srcs/constrs_1/imports/Desktop/nexys4_ddr_lab3.xdc
set_property used_in_implementation false [get_files C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/gims_labyrinth.srcs/constrs_1/imports/Desktop/nexys4_ddr_lab3.xdc]

read_xdc dont_touch.xdc
set_property used_in_implementation false [get_files dont_touch.xdc]
set_param ips.enableIPCacheLiteLoad 0
close [open __synthesis_is_running__ w]

synth_design -top top_level -part xc7a100tcsg324-3


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef top_level.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file top_level_utilization_synth.rpt -pb top_level_utilization_synth.pb"
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]
