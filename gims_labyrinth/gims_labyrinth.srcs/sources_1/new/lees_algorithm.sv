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
    input [16:0] end_pos,
    input skel_pixel,
        
    //Used to index into the maze
    output logic [16:0] pixel_r_addr,
    output logic [16:0] pixel_wr_addr,
    
    //below are used for writing backpointers
    output logic [1:0] backpointer,
    //These are set high when writing to the appropriate bram
    output logic bp_we,
    output logic done,
    
    output logic [2:0] state
    );
    
    parameter QUEUE_SIZE = 64;
    
    parameter IDLE = 3'b000;
    parameter FETCH_NEIGHBORS = 3'b001;
    parameter VALIDATE_NEIGHBORS = 3'b010;
    parameter DELAY = 3'b011;
    parameter DONE = 3'b100;
    parameter CLEAR_VISITED_MAP = 3'b101;
    
    logic [5:0] q_idx;
    reg [16:0] queue[0:QUEUE_SIZE - 1];
    integer k;
    
    reg [16:0] neighbors[0:MAX_OUT_DEGREE - 1];
    reg [1:0] backpointers[0:MAX_OUT_DEGREE - 1];
    logic [2:0] i;
    logic [2:0] j;
    logic [2:0] delay_cycles;
    assign done = state == DONE;
    
    logic visited_we;
    logic visit_val;
    logic visited;
    visited_map visited_map(.clka(clk),
                          .addra(pixel_wr_addr),
                          .dina(visit_val),
                          .wea(visited_we),
                          .clkb(clk),
                          .addrb(pixel_r_addr),
                          .doutb(visited));
    
    logic neighbor_within_bounds;
    
    always_comb begin
        neighbor_within_bounds = neighbors[j][16:8] > 2 && neighbors[j][16:8] < IMG_W - 3 && neighbors[j][7:0] > 2 && neighbors[j][7:0] < IMG_H - 3;
    end
    
    integer bp_f;
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
                        visited_we <= 1;
                        visit_val <= 1;
                        pixel_wr_addr <= start_pos[7:0] * IMG_W + start_pos[16:8];
                    end
                end
                FETCH_NEIGHBORS: begin
                    visited_we <= 0;
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
                        bp_we <= 0;
                        visited_we <= 0;
                        state <= FETCH_NEIGHBORS;
                    end
                    else if(i == j + BRAM_DELAY_CYCLES + 1)begin
                        j <= j + 1;
                        if(neighbors[j] == end_pos)begin
                            pixel_wr_addr <= neighbors[j][7:0] * IMG_W + neighbors[j][16:8];
                            bp_we <= 1;
                            backpointer <= backpointers[j];
                            visited_we <= 1;
                            delay_cycles <= 0;        
                            state <= DELAY;
                        end
                        else if(skel_pixel == 1 && !visited && neighbor_within_bounds)begin
                            queue[q_idx] <= neighbors[j];
                            q_idx <= q_idx + 1;
                                                        
                            pixel_wr_addr <= neighbors[j][7:0] * IMG_W + neighbors[j][16:8];
                                                        
                            bp_we <= 1;
                            backpointer <= backpointers[j];
                            visited_we <= 1;
                        end
                        else begin
                            bp_we <= 0;
                            visited_we <= 0;
                        end
 
                    end
                    if(i < MAX_OUT_DEGREE)begin
                        pixel_r_addr <= neighbors[i][7:0] * IMG_W + neighbors[i][16:8];
                    end
                    i <= i + 1;
                end
                
                DELAY: begin
                    pixel_wr_addr <= 0;
                    visit_val <= 0;
                    bp_we <= 0;
                    if(delay_cycles >= 2)begin
                        state <= DONE;
                    end
                    else begin
                        delay_cycles <= delay_cycles + 1;
                    end
                    
                end
                
                DONE: begin
                    visited_we <= 1;
                    state <= CLEAR_VISITED_MAP;
                end
                
                CLEAR_VISITED_MAP: begin
                    if(pixel_wr_addr == IMG_W * IMG_H)begin
                        state <= IDLE;
                        visited_we <= 0;
                    end
                    else begin
                        pixel_wr_addr <= pixel_wr_addr + 1;
                    end
                end
                
                default: begin
                    //Do nothing
                end
                
            endcase
        end
    end
endmodule
