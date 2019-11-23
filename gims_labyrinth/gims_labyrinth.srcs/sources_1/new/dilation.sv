`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2019 11:53:22 PM
// Design Name: 
// Module Name: dilation
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


module dilation #(K = 3)(
    input [K*K-1 : 0] window,
    output [K*K-1 : 0] dilation
    );
    assign dilation = window[(K*K) >> 2] ? {(K*K){1'b1}} : window;
endmodule
