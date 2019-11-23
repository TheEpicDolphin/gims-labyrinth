`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2019 01:55:07 PM
// Design Name: 
// Module Name: signal_processing
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


module signal_processing #(parameter IMG_W = 640,
                           parameter K = 3)
    (
        input clk,
        input rst,
        input pixel
    );
    
    parameter IDLE = 2'b00;
    parameter THRESHOLDING = 2'b01;
    parameter ERODING_STARTED = 2'b10;
    parameter DILATION_STARTED = 2'b11;
    parameter DILATION_ENDED = 2'b11;
    parameter DONE = 2'b11;
    
    reg [((IMG_W + K) << 1) - 1 : 0] dilated;
    reg [((IMG_W + K) << 1) - 1 : 0] eroded;
    reg [((IMG_W + K) << 1) - 1 : 0] im_section;
    wire erosion;
    reg [K*K-1 : 0] dilation;
    
    
    module rgb_2_hsv(
        input clk,
        input rst,
        input start,
        input [7:0] r_in,
        input [7:0] g_in,
        input [7:0] b_in,
        output logic [16:0] h,   //Q9.8
        output logic [7:0] s,  //Q8
        output logic [7:0] v,  //Q8
        output ready,
        output logic [1:0] state
        );
    thresholder thrsh_maze #(parameter H_LOW, parameter H_HIGH,
                             parameter S_LOW, parameter S_HIGH,
                             parameter V_LOW, parameter V_HIGH) 
            (
                input logic [16:0] h,   //Q9.8
                input logic [7:0] s,  //Q8
                input logic [7:0] v,  //Q8
                output b
            );
                        
     module erosion #(K = 3)(
                .window(im_section[K*K-1 : 0]),
                .erosion(erosion)
                );
    module dilation #(K = 3)(
                    .window(eroded[]),
                    .dilation(dilation)
                    );
    
    wire write_dilation = (state >= DILATION_STARTED && state <= DILATION_ENDED);
    always_ff @(posedge clk)begin
        eroded[10:0] <= {eroded[10:1], erosion}
        im_section[10:0] <= {pixel, im_section[10:1]};
        for(i = 0; i < K*K; i=i+1)begin
            dilated[i] <= dilation[i];
        end
        case(state)
            
        endcase
    end

endmodule
