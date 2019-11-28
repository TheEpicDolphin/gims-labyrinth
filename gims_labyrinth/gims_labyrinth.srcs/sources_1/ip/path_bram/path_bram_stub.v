// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
// Date        : Wed Nov 27 19:29:28 2019
// Host        : LAPTOP-9CDK2BBH running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top path_bram -prefix
//               path_bram_ visited_map_stub.v
// Design      : visited_map
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-3
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_1,Vivado 2018.2" *)
module path_bram(clka, wea, addra, dina, clkb, addrb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[0:0],addra[16:0],dina[0:0],clkb,addrb[16:0],doutb[0:0]" */;
  input clka;
  input [0:0]wea;
  input [16:0]addra;
  input [0:0]dina;
  input clkb;
  input [16:0]addrb;
  output [0:0]doutb;
endmodule
