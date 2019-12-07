`define SIM 1
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


module binary_maze_filtering #(parameter IMG_W = 320, parameter IMG_H = 240, parameter BRAM_READ_DELAY = 2)
    (
        input clk,
        input start,
        input rst,
        input [11:0] rgb_pixel,
        
        output logic [16:0] cam_pixel_r_addr,
        
        output done,
        //Used for writing filtered pixel values into bram
        output logic [16:0] pixel_wr_addr,
        output pixel_wea,
        output pixel_out
    );
    logic [7:0] r;
    logic [7:0] g;
    logic [7:0] b;
    assign r = {rgb_pixel[11:8], 4'b0};
    assign g = {rgb_pixel[7:4], 4'b0};
    assign b = {rgb_pixel[3:0], 4'b0}; 
    
    parameter IDLE = 2'b00;
    parameter READ_DELAY = 2'b01;
    parameter SMOOTHING = 2'b10;
    parameter DONE = 2'b11;
    logic [1:0] state;
    
    parameter RGB_2_HSV_CYCLES = 19;
    
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
    
    logic [16:0] h;
    logic [7:0] s;
    logic [7:0] v;
    assign h = hsv_buffer[rgb_2_hsv_sel][32:16];
    assign s = hsv_buffer[rgb_2_hsv_sel][15:8];
    assign v = hsv_buffer[rgb_2_hsv_sel][7:0];
    
    logic bin_maze_pixel;

    //This thresholds for red
    logic red1;
    thresholder #(.H_LOW(17'h0_00_00),.H_HIGH(17'h0_14_00),
                      .S_LOW(8'b1000_0000),.S_HIGH(8'b1111_1111),
                      .V_LOW(8'b0000_0000),.V_HIGH(8'b1111_1111)) skel_thresh_red1
                (
                    .h(h),   //Q9.8
                    .s(s),  //Q8
                    .v(v),  //Q8
                    .b(r1)
                );
    logic red2;
    thresholder #(.H_LOW(17'h1_54_00),.H_HIGH(17'h1_FF_FF),
                  .S_LOW(8'b1000_0000),.S_HIGH(8'b1111_1111),
                  .V_LOW(8'b0000_0000),.V_HIGH(8'b1111_1111)) skel_thresh_red2
                (
                   .h(h),   //Q9.8
                   .s(s),  //Q8
                   .v(v),  //Q8
                   .b(r2)
                );
    assign bin_maze_pixel = red1 || red2;
    
    logic start_color;
    thresholder #(.H_LOW(17'h1_54_00),.H_HIGH(17'h1_FF_FF),
                  .S_LOW(8'b1000_0000),.S_HIGH(8'b1111_1111),
                  .V_LOW(8'b0000_0000),.V_HIGH(8'b1111_1111)) skel_thresh_start
                (
                   .h(h),   //Q9.8
                   .s(s),  //Q8
                   .v(v),  //Q8
                   .b(start_color)
                );
    
    
    logic end_color;
    thresholder #(.H_LOW(17'h1_54_00),.H_HIGH(17'h1_FF_FF),
                  .S_LOW(8'b1000_0000),.S_HIGH(8'b1111_1111),
                  .V_LOW(8'b0000_0000),.V_HIGH(8'b1111_1111)) skel_thresh_end
                (
                   .h(h),   //Q9.8
                   .s(s),  //Q8
                   .v(v),  //Q8
                   .b(end_color)
                );
    assign end_markers = end_color;
    
 
    logic [23:0] cycles;
    logic eroded_pixel;
    logic dilated_pixel;
    
    assign pixel_out = dilated_pixel;
         
    logic start_erosion;
    logic start_dilation;
    logic dilation_done;
    
    assign start_erosion = cycles == RGB_2_HSV_CYCLES;
            
    erosion #(.K(5),.IMG_W(320),.IMG_H(240)) bin_erosion
                (
                .clk(clk),
                .rst(rst),
                .start(start_erosion),
                .pixel_in(bin_maze_pixel),
                .pixel_valid(start_dilation),
                .processed_pixel(eroded_pixel)
                );
    
    dilation #(.K(5),.IMG_W(320),.IMG_H(240)) bin_dilation
                    (
                    .clk(clk),
                    .rst(rst),
                    .start(start_dilation),
                    .pixel_in(eroded_pixel),
                    .pixel_addr(pixel_wr_addr),
                    .pixel_valid(pixel_wea),
                    .processed_pixel(dilated_pixel),
                    .done(dilation_done)
                    );
    
    assign done = state == DONE;
    
    //Debugging
    `ifdef SIM
    integer bin_maze_f;
    `endif
    
    always_ff @(posedge clk)begin
        if(rst)begin
            state <= IDLE;
        end
        else begin
            case(state)
                IDLE: begin
                    if(start)begin
                        state <= READ_DELAY;
                        cam_pixel_r_addr <= 0;
                    end
                end
                READ_DELAY: begin
                    //window_end_i_read reads from BRAM the value that we will want BRAM_READ_DELAY cycles from now
                    cam_pixel_r_addr <= cam_pixel_r_addr + 1;
                    if(cam_pixel_r_addr == BRAM_READ_DELAY - 1)begin
                        state <= SMOOTHING;
                        rgb_2_hsv_sel <= 0;
                        cycles <= 0;
                        `ifdef SIM   
                        bin_maze_f = $fopen("C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/python_stuff/verilog_testing/bin_maze_img.txt","w");
                        `endif
                    end
                end
                SMOOTHING: begin
                    cam_pixel_r_addr <= cam_pixel_r_addr + 1;
                    if(rgb_2_hsv_sel == RGB_2_HSV_CYCLES - 1)begin
                        rgb_2_hsv_sel <= 0;
                    end
                    else begin
                        rgb_2_hsv_sel <= rgb_2_hsv_sel + 1;
                    end
                    
                    if(dilation_done)begin
                        state <= DONE;
                    end
                    
                    `ifdef SIM
                    if(cycles == (RGB_2_HSV_CYCLES + IMG_W * IMG_H))begin
                    $fclose(bin_maze_f);
                    end
                    else if(cycles >= RGB_2_HSV_CYCLES)begin
                    $fwrite(bin_maze_f,"%b\n",bin_maze_pixel);
                    end
                    `endif
                    
                    cycles <= cycles + 1;
                end
                DONE: begin
                    state <= IDLE;
                end
            endcase
        end

    end

endmodule


module find_end_nodes #(parameter IMG_W = 320, parameter IMG_H = 240, parameter BRAM_READ_DELAY = 2)
    (
        input clk,
        input rst,
        input start,
        input [11:0] rgb_pixel,
        input skel_pixel,
        output logic [16:0] maze_r_addr,
        output logic [16:0] start_pos,
        output logic [16:0] end_pos,
        output done
    );
    logic [7:0] r;
    logic [7:0] g;
    logic [7:0] b;
    assign r = {rgb_pixel[11:8], 4'b0};
    assign g = {rgb_pixel[7:4], 4'b0};
    assign b = {rgb_pixel[3:0], 4'b0}; 
    
    parameter IDLE = 2'b00;
    parameter READ_DELAY = 2'b01;
    parameter SMOOTHING = 2'b10;
    parameter DONE = 2'b11;
    logic [1:0] state;
    
    parameter RGB_2_HSV_CYCLES = 19;
    
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
    
    logic [8:0] x;
    logic [7:0] y;
    
    logic [16:0] h;
    logic [7:0] s;
    logic [7:0] v;
    assign h = hsv_buffer[rgb_2_hsv_sel][32:16];
    assign s = hsv_buffer[rgb_2_hsv_sel][15:8];
    assign v = hsv_buffer[rgb_2_hsv_sel][7:0];
    
    //green
    logic start_color;
    thresholder #(.H_LOW(17'h0_5A_00),.H_HIGH(17'h0_8C_00),
                  .S_LOW(8'b1000_0000),.S_HIGH(8'b1111_1111),
                  .V_LOW(8'b0100_0000),.V_HIGH(8'b1111_1111)) skel_thresh_start
                (
                   .h(h),   //Q9.8
                   .s(s),  //Q8
                   .v(v),  //Q8
                   .b(start_color)
                );
    
    //yellow
    logic end_color;
    thresholder #(.H_LOW(17'h0_32_00),.H_HIGH(17'h0_46_00),
                  .S_LOW(8'b0100_0000),.S_HIGH(8'b1111_1111),
                  .V_LOW(8'b1011_1111),.V_HIGH(8'b1111_1111)) skel_thresh_end
                (
                   .h(h),   //Q9.8
                   .s(s),  //Q8
                   .v(v),  //Q8
                   .b(end_color)
                );
    
 
    logic [23:0] cycles;
    assign done = state == DONE;
    
    //Debugging
    `ifdef SIM
    integer bin_maze_f;
    `endif
    
    always_ff @(posedge clk)begin
        if(rst)begin
            state <= IDLE;
        end
        else begin
            case(state)
                IDLE: begin
                    if(start)begin
                        state <= READ_DELAY;
                        maze_r_addr <= 0;
                    end
                end
                READ_DELAY: begin
                    //window_end_i_read reads from BRAM the value that we will want BRAM_READ_DELAY cycles from now
                    maze_r_addr <= maze_r_addr + 1;
                    if(maze_r_addr == BRAM_READ_DELAY - 1)begin
                        x <= 9'b0;
                        y <= 8'b0;
                    end
                end
                SMOOTHING: begin
                    if(x == IMG_W - 1)begin
                        x <= 9'b0;
                        y <= y + 1;
                    end
                    else begin
                        x <= x + 1;
                    end
                    
                    if(skel_pixel && start_color)begin
                        start_pos <= {x, y};
                    end
                    else if(skel_pixel && end_color)begin
                        end_pos <= {x, y};
                    end
                end
                DONE: begin
                    state <= IDLE;
                end
            endcase
        end

    end

endmodule