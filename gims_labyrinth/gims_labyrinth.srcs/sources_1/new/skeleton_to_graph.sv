`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2019 02:44:59 PM
// Design Name: 
// Module Name: skeleton_to_graph
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


module skeleton_intersection_finder #(parameter IMG_W = 640, parameter IMG_H = 480, parameter BRAM_READ_DELAY = 2)
    (
    input clk,
    input rst,
    input start,
    input pixel_r,
    
    output logic [18:0] window_end_i_read,
    
    output logic [18:0] window_center_i,
    output logic [2:0] pixel_out,
    output logic write_pixel,
    
    output logic write_node,
    output logic [9:0] node,
    output logic [18:0] node_xy,
    output done,
    output logic [1:0] state
    );
    
    parameter IDLE = 2'b00;
    parameter READ_DELAY = 2'b01;
    parameter FIND_INTERSECTIONS = 2'b10;
    parameter DONE = 2'b11;
    
    reg [((IMG_W << 1) + 3) - 1 : 0] skel_window;
    //logic [1:0] state;
    
    logic w_11, w_01, w_10, w_21, w_12;
    assign w_11 = skel_window[IMG_W + 1];
    assign w_01 = skel_window[IMG_W + 2];
    assign w_10 = skel_window[(IMG_W << 1) + 1];
    assign w_21 = skel_window[IMG_W];
    assign w_12 = skel_window[1];
    
    logic [9:0] x_end;
    logic [8:0] y_end;
    
    logic [9:0] x_c;
    logic [8:0] y_c;
    
    logic [18:0] window_end_i;
    always_comb begin
        window_end_i = IMG_W * y_end + x_end;
        //Gets the pixel value that we will want in BRAM_READ_DELAY cycles
        x_c = x_end - 1;
        y_c = y_end - 1;
        window_center_i = window_end_i - (IMG_W + 3);
    end
    
    logic intersection;
    assign intersection = w_11 && 
                        ((w_01 && w_21 && w_12) ||
                        (w_10 && w_21 && w_12) ||
                        (w_10 && w_01 && w_12) ||
                        (w_10 && w_01 && w_21));

    logic [9:0] n;
    assign done = (state == DONE);
    
    always_ff @(posedge clk)begin
        if(rst)begin
            state <= IDLE;
        end
        else begin
            skel_window <= {skel_window[((IMG_W << 1) + 3) - 2:0], pixel_r};
            case(state)
                IDLE: begin
                    if(start)begin
                        state <= READ_DELAY;
                        window_end_i_read <= 0;
                        //The zeroth node is reserved as a dummy node
                        n <= 10'b1;
                    end
                end
                READ_DELAY: begin
                    window_end_i_read <= window_end_i_read + 1;
                    if(window_end_i_read == BRAM_READ_DELAY)begin
                        x_end <= 10'd00;
                        y_end <= 9'd00;
                        state <= FIND_INTERSECTIONS;
                    end
                end
                FIND_INTERSECTIONS: begin
                    window_end_i_read <= window_end_i_read + 1;
                    //Wait until window is completely filled before finding intersections
                    //Avoid y <= 2, y >= IMG_H - 3, x <= 2 and x >= IMG_W - 3 to avoid artifacts around edges of image from skeletonization
                    if(window_end_i > ((IMG_W << 1) + 3) && y_c > 9'd2 && y_c < IMG_H - 3 && x_c > 10'd2 && x_c < IMG_W - 3)begin
                        if(intersection)begin
                            write_pixel <= 1;
                            pixel_out <= 3'b010;
                                                   
                            node <= n;
                            node_xy <= {x_c, y_c};
                            n <= n + 1;
                        end
                        else begin
                            write_pixel <= 0;
                        end
                    end
                    
                    //Increment pixel coordinates
                    if(x_end == IMG_W - 1)begin
                        x_end <= 10'b0;
                        y_end <= y_end + 1;
                    end
                    else begin
                        x_end <= x_end + 1;
                    end
                    
                    //Window has reached the end. We can stop now    
                    if(x_end == IMG_W - 1 && y_end == IMG_H - 1)begin
                        write_pixel <= 0;
                        state <= DONE;
                    end
                end
                DONE: begin
                    state <= IDLE;
                end
            endcase
        end
    end
    
endmodule


module skeleton_corner_finder #(parameter IMG_W = 640, parameter IMG_H = 480)
    (
    input clk,
    input rst,
    input start,
    input [2:0] pixel_r,
    
    output logic [18:0] window_center_i,
    output logic [18:0] window_end_i,
    output logic [2:0] pixel_out,
    output logic write_pixel,
    
    output logic write_node,
    output logic [9:0] node,
    output logic [18:0] node_xy,
    output done
    );
    
    parameter IDLE = 2'b00;
    parameter FILLING_WINDOW = 2'b01;
    parameter FIND_INTERSECTIONS = 2'b10;
    parameter DONE = 2'b11;
    
    reg [((IMG_W + 3) << 1) - 1 : 0] skel_window;
    logic [1:0] state;
    
    logic w_11, w_01, w_10, w_21, w_12;
    assign w_11 = IMG_W + 3;
    assign w_01 = (IMG_W + 3) + 1;
    assign w_10 = ((IMG_W + 3) << 1) - 2;
    assign w_21 = (IMG_W + 3) - 1;
    assign w_12 = 1;
    
    logic x_end;
    logic y_end;
    
    logic x_c;
    logic y_c;
    
    always_comb begin
        window_end_i = IMG_W * y_end + x_end;
        x_c = x_end - 1;
        y_c = y_end - 1;
        window_center_i = window_end_i - (IMG_W + 3);
    end
    
    logic intersection;
    assign intersection = w_11 && 
                        (w_01 && w_21 && w_12) &&
                        (w_10 && w_21 && w_12) &&
                        (w_10 && w_01 && w_12) &&
                        (w_10 && w_01 && w_21);

    logic [9:0] n;
    assign done = (state == DONE);
    
    always_ff @(posedge clk)begin
        if(rst)begin
            
        end
        else begin
            skel_window <= {skel_window[((IMG_W + 3) << 1) - 1:1], (pixel_r > 0)};
            case(state)
                IDLE: begin
                    if(start)begin
                        state <= FILLING_WINDOW;
                        window_end_i <= 19'b00;
                        x_end <= 10'b00;
                        y_end <= 9'b00;
                        //The zeroth node is reserved as a dummy node
                        n <= 10'b1;
                    end
                end
                FILLING_WINDOW: begin
                    if(window_end_i > ((IMG_W + 3) << 1))begin
                        state <= FIND_INTERSECTIONS;
                    end
                    window_end_i <= window_end_i + 1;
                    
                    if(x_end == 10'd640)begin
                        x_end <= 10'b0;
                        y_end <= y_end + 1;
                    end
                    else begin
                        x_end <= x_end + 1;
                    end
                end
                FIND_INTERSECTIONS: begin
                    if(x_end == IMG_W && y_end == IMG_H)begin
                        write_pixel <= 0;
                        state <= DONE;
                    end
                    if(intersection)begin
                        write_pixel <= 1;
                        pixel_out <= 3'b010;
                        
                        node <= n;
                        node_xy <= {x_c, y_c};
                        n <= n + 1;
                    end
                    else begin
                        write_pixel <= 0;
                    end
                end
                DONE: begin
                    state <= IDLE;
                end
            endcase
        end
    end
    
endmodule
