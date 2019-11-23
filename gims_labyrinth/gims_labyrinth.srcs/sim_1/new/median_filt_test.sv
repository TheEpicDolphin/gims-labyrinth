`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2019 01:02:35 PM
// Design Name: 
// Module Name: median_filt_test
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


module median_filt_test;
   // Inputs
logic clock;
logic rst;
logic start;
logic [1:0] ar [0:8];

// Outputs
logic [1:0] state;
logic [4:0] median;
logic ready;

// Instantiate the Unit Under Test (UUT)
median_filt uut(
     .clk(clock),
     .rst(rst),
     .start(start),
     .ar(ar),
     .median(median),
     .ready(ready),
     .state(state)
    );

always #5 clock = !clock;

initial begin
// Initialize Inputs
clock = 0;
start = 0;
rst = 0;

// Wait 100 ns for global reset to finish
#100;
#15;
rst = 1;
#15
rst = 0;
#15;
ar = {2, 3, 1, 
      0, 0, 1, 
      0, 2, 2};

#15;
start =1;
#10;
start = 0;
#400;

end

endmodule
