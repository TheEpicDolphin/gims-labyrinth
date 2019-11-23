`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2019 06:27:19 PM
// Design Name: 
// Module Name: dijkstras_algorithm_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module dijkstras_algorithm_tb;

logic clock;
logic rst;
logic run;

logic [9:0] n_start;
logic [9:0] n;
logic write_adj;
logic write_bp;
logic write_min_weight;
logic write_pos;
logic read;

logic [63:0] adjacency_r;
logic [63:0] adjacency_wr;
logic [15:0] min_weight_r;
logic [15:0] min_weight_wr;
logic [9:0] bp_r;
logic [9:0] bp_wr;
logic [25:0] k;
logic retrieve_min;

logic bram_ready;


//Debugging
logic [2:0] state;

integer graph_f;
integer i;

// Instantiate the Unit Under Test (UUT)
graph_manager gm(
    .clk(clock),
    .rst(rst),
    .n(n),
    .write_adj(write_adj),
    .write_bp(write_bp),
    .write_min_weight(write_min_weight),
    .write_pos(write_pos),
    .read(read),
    .adjacency_in(adjacency_wr),
    .weight_in(min_weight_wr),
    .backpointer_in(bp_wr),
    .adjacency_out(adjacency_r),
    .weight_out(min_weight_r),
    .backpointer_out(bp_r),
    .ready(bram_ready)
    );
    
dijkstras_algorithm #(.MAX_OUT_DEGREE(4),.MAX_NODES(64)) uut
    (
        .clk(clock),
        .rst(rst),
        .run(run),
        .n_start(n_start),
        .bram_ready(bram_ready),    
        .min_weight_in(min_weight_r),
        .adjacency(adjacency_r),
        .n(n),
        .read(read),
        .backpointer(bp_wr),
        .min_weight_out(min_weight_wr),
        .write_bp(write_bp),
        .write_min_weight(write_min_weight),
        .state(state)
        );

always #5 clock = !clock;

initial begin
// Initialize Inputs
clock = 0;
rst = 0;
run = 0;
retrieve_min = 0;
write_pos = 0;
write_adj = 0;
// Wait 100 ns for global reset to finish
#100;
#15;
rst = 1;
#15
rst = 0;
#15;

run = 1;
n_start = 10'b1;
#15
run = 0;
#500;

end

endmodule
