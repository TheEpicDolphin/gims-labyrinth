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


module lees_algorithm #(parameter MAX_OUT_DEGREE = 4, parameter BRAM_DELAY_CYCLES = 2,
                        parameter IMG_W = 320, parameter IMG_H = 240)
(
    input clk,
    input rst,
    input start,
    input [16:0] start_pos,
    
    input skel_pixel,
    input [1:0] pixel_type,
    input visited,
        
    //Used to index into the maze
    output logic [16:0] pixel_r_addr,
    output logic [16:0] pixel_wr_addr,
    
    //below are used for writing backpointers
    output logic [1:0] backpointer,
    //These are set high when writing to the appropriate bram
    output logic write_bp,

    output logic visit,
    output logic write_visited,
    
    output logic done,
    output logic [16:0] end_pos,
    
    output logic [1:0] state
    );
    
    parameter NORMAL_PIXEL = 2'b00;
    parameter OBSTACLE_PIXEL = 2'b01;
    parameter START_PIXEL = 2'b10;
    parameter END_PIXEL = 2'b11;
    
    parameter QUEUE_SIZE = 64;
    
    parameter IDLE = 2'b00;
    parameter FETCH_NEIGHBORS = 2'b01;
    parameter VALIDATE_NEIGHBORS = 2'b10;
    parameter DONE = 2'b11;
    
    logic [5:0] q_idx;
    reg [16:0] queue[0:QUEUE_SIZE - 1];
    integer k;
    
    reg [16:0] neighbors[0:MAX_OUT_DEGREE - 1];
    reg [1:0] backpointers[0:MAX_OUT_DEGREE - 1];
    logic [2:0] i;
    logic [2:0] j;
    
    assign done = state == DONE;
    
    assign visit = 1;
    
    logic neighbor_within_bounds;
    
    always_comb begin
        neighbor_within_bounds = neighbors[j][16:8] > 2 && neighbors[j][16:8] < IMG_W - 3 && neighbors[j][7:0] > 2 && neighbors[j][7:0] < IMG_H - 3;
    end
    
    always_ff @(posedge clk)begin
        if(rst)begin
            state <= IDLE;
        end
        else begin
            case(state)
                IDLE: begin
                    if(start)begin
                        state <= FETCH_NEIGHBORS;
                        queue[0] <= start_pos;
                        q_idx <= 1;
                        write_visited <= 1;
                        pixel_wr_addr <= start_pos[7:0] * IMG_W + start_pos[16:8];
                    end
                end
                FETCH_NEIGHBORS: begin
                    write_visited <= 0;
                    if(q_idx == 0)begin
                        //End was not found
                        state <= DONE;
                    end
                    else begin
                        //right
                        neighbors[0] <= {queue[0][16:8] + 9'b1, queue[0][7:0]};
                        backpointers[0] <= 2'b00;
                        //up
                        neighbors[1] <= {queue[0][16:8], queue[0][7:0] - 8'b1};
                        backpointers[1] <= 2'b01;
                        //left
                        neighbors[2] <= {queue[0][16:8] - 9'b1, queue[0][7:0]};
                        backpointers[2] <= 2'b10;
                        //down
                        neighbors[3] <= {queue[0][16:8], queue[0][7:0] + 8'b1};
                        backpointers[3] <= 2'b11;
                        
                        state <= VALIDATE_NEIGHBORS;
                        
                        for (k = 0; k < QUEUE_SIZE - 1; k = k + 1) begin    
                            queue[k] <= queue[k + 1];
                        end
                        q_idx <= q_idx - 1;
                        
                        i <= 0;
                        j <= 0;
                    end

                end
                VALIDATE_NEIGHBORS: begin
                    if(j == MAX_OUT_DEGREE)begin
                        write_bp <= 0;
                        write_visited <= 0;
                        state <= FETCH_NEIGHBORS;
                    end
                    else if(i == j + BRAM_DELAY_CYCLES + 1)begin
                        j <= j + 1;
                        if((pixel_type == NORMAL_PIXEL || pixel_type == START_PIXEL) && skel_pixel == 1 && !visited && neighbor_within_bounds)begin
                            queue[q_idx] <= neighbors[j];
                            q_idx <= q_idx + 1;
                            
                            pixel_wr_addr <= neighbors[j][7:0] * IMG_W + neighbors[j][16:8];
                            
                            write_bp <= 1;
                            backpointer <= backpointers[j];
                            write_visited <= 1;
                        end
                        else if(pixel_type == END_PIXEL)begin
                            pixel_wr_addr <= neighbors[j][7:0] * IMG_W + neighbors[j][16:8];
                            write_bp <= 1;
                            backpointer <= backpointers[j];
                            write_visited <= 1;
                            
                            state <= DONE;
                            end_pos <= neighbors[j];
                        end
                        else begin
                            write_bp <= 0;
                            write_visited <= 0;
                        end    
                    end
                    if(i < MAX_OUT_DEGREE)begin
                        pixel_r_addr <= neighbors[i][7:0] * IMG_W + neighbors[i][16:8];
                    end
                    i <= i + 1;
                end
                DONE: begin
                    write_bp <= 0;
                    write_visited <= 0;
                    state <= IDLE;
                end
            
            endcase
        end
    end
endmodule
