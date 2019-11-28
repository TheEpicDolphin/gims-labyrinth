// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
// Date        : Wed Nov 27 01:21:20 2019
// Host        : LAPTOP-9CDK2BBH running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top binary_maze -prefix
//               binary_maze_ binary_maze_stub.v
// Design      : binary_maze
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-3
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_1,Vivado 2018.2" *)
module binary_maze(clka, wea, addra, dina, douta)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[0:0],addra[16:0],dina[0:0],douta[0:0]" */;
  input clka;
  input [0:0]wea;
  input [16:0]addra;
  input [0:0]dina;
  output [0:0]douta;
endmodule
