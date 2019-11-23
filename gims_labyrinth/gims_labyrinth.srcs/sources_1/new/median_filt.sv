`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2019 12:25:47 PM
// Design Name: 
// Module Name: median_filt
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


module median_filt #(parameter KERNEL_SIZE = 3,
                     parameter N = 9)
    (
        input clk,
        input rst,
        input start,
        input [1:0] ar [0:N - 1],
        output logic [4:0] median,
        output ready,
        output logic [1:0] state
    );
    
    parameter READY = 2'b00;
    parameter COUNT_SORT = 2'b01;
    parameter FIND_MEDIAN = 2'b10;
    parameter DONE = 2'b11;
    
    //logic [1:0] state;
    
    logic [4:0] hashmap [0:3];
    logic [4:0] cumsum [0:3];
    logic [4:0] i;
    assign ready = state == READY;
    
    always_ff @(posedge clk)begin
        if(rst)begin
            i <= 0;
            state <= READY;
            hashmap <= {0, 0, 0, 0};
        end
        else begin
            case(state)
                READY: begin
                    if(start)begin
                        state <= COUNT_SORT;
                        i <= 0;
                        hashmap <= {0, 0, 0, 0};
                    end
                end
                COUNT_SORT: begin
                    if(i < N)begin
                        hashmap[ar[i]] <= hashmap[ar[i]] + 1;
                        i <= i + 1;
                    end
                    else begin
                        state <= FIND_MEDIAN;
                        i <= 1;
                        cumsum[0] <= hashmap[0];
                    end
                end
                FIND_MEDIAN: begin
                    if(cumsum[i - 1] > (N >> 1))begin
                        median <= i - 1;
                        state <= READY;
                    end
                    else begin
                        cumsum[i] <= cumsum[i - 1] + hashmap[i];
                        i <= i + 1;
                    end
                    
                end
                default: begin
                    //do nothing
                end
            endcase
        end
        
    end
    
    
    
endmodule
