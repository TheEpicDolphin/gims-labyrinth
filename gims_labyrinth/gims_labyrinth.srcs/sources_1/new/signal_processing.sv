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


module signal_processing #(parameter IMG_W = 320, parameter IMG_H = 240)
    (
        input clk,
        input start,
        input rst,
        input [7:0] r,
        input [7:0] g,
        input [7:0] b,
        output logic [16:0] h,
        output logic [7:0] s,
        output logic [7:0] v
    );
    
    parameter IDLE = 2'b00;
    parameter DELAY = 2'b01;
    parameter PROCESSING = 2'b10;
    parameter DONE = 2'b11;
    logic [1:0] state;
    
    parameter RGB_2_HSV_CYCLES = 19;
    
    //logic [16:0] h;
    //logic [7:0] s;
    //logic [7:0] v;
    logic bin_maze_pixel;
    
    reg [32:0] hsv_buffer [0:RGB_2_HSV_CYCLES - 1];
    logic [4:0] rgb_2_hsv_sel;
    
    genvar i;
    generate
        for(i = 0; i < RGB_2_HSV_CYCLES; i++)begin
            rgb_2_hsv inst(
                .clk(clk),
                .rst(rst),
                .start(rgb_2_hsv_sel == i),
                .r_in(r),
                .g_in(g),
                .b_in(b),
                .h(hsv_buffer[i][32:16]), //Q9.8
                .s(hsv_buffer[i][15:8]),  //Q8
                .v(hsv_buffer[i][7:0])    //Q8
            );
        end
    endgenerate
    
    assign h = hsv_buffer[rgb_2_hsv_sel][32:16];
    assign s = hsv_buffer[rgb_2_hsv_sel][15:8];
    assign v = hsv_buffer[rgb_2_hsv_sel][7:0];
    
    //Threshold for white path
    thresholder #(.H_LOW(17'h0),.H_HIGH(17'h1_FF_FF),
                  .S_LOW(8'b0000_0000),.S_HIGH(8'b0001_1000),
                  .V_LOW(8'b1110_1000),.V_HIGH(8'b1111_1111)) skel_thresh
            (
                .h(h),   //Q9.8
                .s(s),  //Q8
                .v(v),  //Q8
                .b(bin_maze_pixel)
            );
    
    logic [23:0] cycles;        
    logic start_erosion;
    logic start_dilation;
    logic start_skeletonization;
    
    assign start_erosion = cycles == RGB_2_HSV_CYCLES;
    assign start_dilation = cycles == (RGB_2_HSV_CYCLES + IMG_W * IMG_H);
    
    //Debugging
    integer bin_maze_f;
    
    always_ff @(posedge clk)begin
        if(rst)begin
            state <= IDLE;
        end
        else begin
            case(state)
                IDLE: begin
                    if(start)begin
                        state <= PROCESSING;
                        rgb_2_hsv_sel <= 0;
                        cycles <= 0;
                        //Debugging
                        bin_maze_f = $fopen("C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/python_stuff/verilog_testing/bin_maze_img.txt","w");
                    end
                end
                PROCESSING: begin
                    if(rgb_2_hsv_sel == RGB_2_HSV_CYCLES - 1)begin
                        rgb_2_hsv_sel <= 0;
                    end
                    else begin
                        rgb_2_hsv_sel <= rgb_2_hsv_sel + 1;
                    end
                    
                    if(cycles >= (RGB_2_HSV_CYCLES + IMG_W * IMG_H))begin
                        state <= DONE;
                    end
                    else if(cycles >= RGB_2_HSV_CYCLES)begin
                        //Debugging
                        $fwrite(bin_maze_f,"%b\n",bin_maze_pixel);
                    end
                    cycles <= cycles + 1;
                end
                DONE: begin
                    
                    //Debugging
                    $fclose(bin_maze_f);
                    state <= IDLE;
                end
            endcase
        end

    end

endmodule
