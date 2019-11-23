`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2019 03:35:11 PM
// Design Name: 
// Module Name: divider_tb
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


module divider_tb;
   // Inputs
logic clock;
logic rst;
logic start;
logic [15:0] dividend;
logic [15:0] divider;

// Outputs
logic [15:0] quotient;
logic [15:0] remainder;
logic ready;

logic [1:0] state;

// Instantiate the Unit Under Test (UUT)
divider #(.WIDTH(16)) uut (
.clk(clock),
.sign(0),
.start(start),
.dividend(dividend),
.divider(divider),
.quotient(quotient),
.remainder(remainder),
.ready(ready)
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
dividend = 16'd5 << 8;
divider = 16'd34;

#15;
start =1;
#10;
start = 0;
#200;

end

endmodule
