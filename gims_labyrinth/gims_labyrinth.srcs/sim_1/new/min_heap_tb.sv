`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2019 03:35:36 PM
// Design Name: 
// Module Name: min_heap_tb
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


module min_heap_tb;
// Inputs
logic clock;
logic rst;
logic insert;
logic [25:0] k;
logic retrieve_min;

// Outputs
logic [25:0] min_k;
logic ready;

logic [1:0] state;


integer min_heap_input_f;
integer min_heap_output_f;
integer i;

// Instantiate the Unit Under Test (UUT)
min_heap #(.MAX_HEAP_SIZE(25),.MAX_NODES(64)) uut
    (
    .clk(clock),
    .rst(rst),
    .insert(insert),
    .k(k),
    .retrieve_min(retrieve_min),
    .min_k(min_k),
    .ready(ready),
    .state(state)
    );

always #5 clock = !clock;

initial begin
// Initialize Inputs
clock = 0;
rst = 0;
insert = 0;
retrieve_min = 0;
// Wait 100 ns for global reset to finish
#100;
#15;
rst = 1;
#15
rst = 0;
#15;


min_heap_input_f = $fopen("C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims_labyrinth/min_heap_input.txt","r");
for(i = 0; i < 20; i = i + 1)begin
     insert = 1;
     $fscanf(min_heap_input_f,"%b\n",k);
     #10
     insert = 0;
     #50;
end

min_heap_output_f = $fopen("C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims_labyrinth/min_heap_output.txt","w");
for(i = 0; i < 20; i = i + 1)begin
     #100;
     retrieve_min =1;
     $fwrite(min_heap_output_f,"%b\n",min_k);  
     #10
     retrieve_min = 0;
     #20;
end

$fclose(min_heap_input_f);
$fclose(min_heap_output_f);
end

endmodule
