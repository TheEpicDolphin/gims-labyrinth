`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/28/2019 02:07:10 PM
// Design Name: 
// Module Name: backpointer_tracer
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


module backpointer_tracer #(parameter BRAM_DELAY_CYCLES = 2, parameter IMG_W = 320, parameter IMG_H = 240)(
    input clk,
    input rst,
    input start,
    input [16:0] start_pos,
    input [16:0] end_pos,
    input [1:0] bp,
    output logic [16:0] pixel_addr,
    output logic write_path,
    output done
    );
    
    parameter IDLE = 2'b00;
    parameter READING_BACKPOINTER = 2'b01;
    parameter NEXT_PIXEL = 2'b10;
    parameter DONE = 2'b11;
    logic [1:0] state;
    logic [2:0] cycles;
    logic [16:0] cur_pos;
    logic [16:0] next_pos;
    
    always_comb begin
        case(bp)
            2'b00: begin
                next_pos = {cur_pos[16:8] - 9'b1, cur_pos[7:0]};
            end
            2'b01: begin
                next_pos = {cur_pos[16:8], cur_pos[7:0] + 8'b1};
            end
            2'b10: begin
                next_pos = {cur_pos[16:8] + 9'b1, cur_pos[7:0]};
            end
            2'b11: begin
                next_pos = {cur_pos[16:8], cur_pos[7:0] - 8'b1};
            end
        endcase
    end
    
    integer maze_sol_f;
        
    assign done = state == DONE;
    always_ff @(posedge clk)begin
        if(rst)begin
            state <= IDLE;
        end
        else begin
            case(state)
                IDLE: begin
                    if(start)begin
                        state <= READING_BACKPOINTER;
                        write_path <= 1;
                        pixel_addr <= end_pos[7:0] * IMG_W + end_pos[16:8];
                        cur_pos <= end_pos;
                        cycles <= 0;
                        
                        //Debugging
                        maze_sol_f = $fopen("C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/python_stuff/verilog_testing/maze_sol.txt","w");
                    end
                end
                READING_BACKPOINTER: begin
                    write_path <= 0;
                    if(cycles == BRAM_DELAY_CYCLES - 1)begin
                        state <= NEXT_PIXEL;
                    end
                    else begin
                        cycles <= cycles + 1;
                    end
                end
                NEXT_PIXEL: begin
                    if(next_pos == start_pos)begin
                        state <= DONE;
                    end
                    else begin
                        cycles <= 0;
                        state <= READING_BACKPOINTER;
                    end
                    pixel_addr <= next_pos[7:0] * IMG_W + next_pos[16:8];
                    write_path <= 1;
                    cur_pos <= next_pos;
                    
                    //Debugging
                    $fwrite(maze_sol_f,"%b\n",next_pos);
                    
                end
                DONE: begin
                    write_path <= 0;
                    state <= IDLE;
                    
                    //Debugging
                    $fclose(maze_sol_f);
                end
            endcase
        end
    end
    
endmodule
