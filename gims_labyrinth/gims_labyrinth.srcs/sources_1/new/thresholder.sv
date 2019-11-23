`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2019 07:23:52 PM
// Design Name: 
// Module Name: thresholder
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


module thresholder #(parameter H_LOW, parameter H_HIGH,
                     parameter S_LOW, parameter S_HIGH,
                     parameter V_LOW, parameter V_HIGH) 
    (
        input logic [16:0] h,   //Q9.8
        input logic [7:0] s,  //Q8
        input logic [7:0] v,  //Q8
        output b
    );
    
    assign b = (H_LOW <= h && h <= H_HIGH) && (S_LOW <= s && s <= S_HIGH) && (V_LOW <= v && v <= V_HIGH);
endmodule
