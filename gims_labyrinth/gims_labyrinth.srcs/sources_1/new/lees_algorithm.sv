`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2019 11:10:22 PM
// Design Name: 
// Module Name: lees_algorithm
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


module lees_algorithm #(parameter MAX_OUT_DEGREE = 4, parameter MAX_NODES = 1024, parameter BRAM_DELAY_CYCLES)
(
    input clk,
    input rst,
    input start,
    input [18:0] start_pos,
    
    input skel_pixel,
    input [1:0] pixel_,
    input visited,
        
    //Used to index into the maze
    output logic [18:0] pixel_pos,
    
    //read is set high when reading from any of the brams
    output logic read,
    //below are used for writing backpointers
    output logic [1:0] backpointer,
    //These are set high when writing to the appropriate bram
    output logic write_bp,
    
    output logic done,
    output logic [2:0] state
    );
    
    parameter IDLE = 2'b00;
    parameter FETCH_NEIGHBORS = 2'b01;
    parameter VALIDATE_NEIGHBORS = 2'b10;
    parameter DONE = 2'b11;
    
    logic [5:0] idx;
    reg [18:0] queue[0:63];
    
    reg [18:0] neighbors[0:MAX_OUT_DEGREE - 1];
    logic [2:0] i;
    logic [2:0] j;
    
    always_ff @(posedge clk)begin
        if(rst)begin
            state <= IDLE;
        end
        else begin
            case(state)
                IDLE: begin
                    if(start)begin
                        state <= FETCH_NEIGHBORS;
                        pixel_pos <= start_pos;
                        idx <= 0;
                    end
                end
                FETCH_NEIGHBORS: begin
                    //right
                    neighbors[0] <= {queue[0][9:0] + 1, queue[0][18:10]};
                    //up
                    neighbors[1] <= {queue[0][9:0], queue[0][18:10] - 1};
                    //left
                    neighbors[2] <= {queue[0][9:0] - 1, queue[0][18:10]};
                    //down
                    neighbors[3] <= {queue[0][9:0], queue[0][18:10] + 1};
                    
                    state <= VALIDATE_NEIGHBORS;
                    queue <= {queue[], }
                    idx <= idx - 1;
                    i <= 0;
                    j <= 0;
                end
                VALIDATE_NEIGHBORS: begin
                    if(j == MAX_OUT_DEGREE)begin
                        state <= FETCH_NEIGHBORS;
                    end
                    if(i == j + BRAM_DELAY_CYCLES)begin
                        j <= j + 1;
                        queue[idx] <= neighbors[j];
                        idx <= idx + 1;
                    end
                    if(i < MAX_OUT_DEGREE)begin
                        read <= 1;
                        pixel_pos <= neighbors[i];
                    end
                    i <= i + 1;
                end
                DONE: begin
                
                end
            
            endcase
        end
    end
endmodule
