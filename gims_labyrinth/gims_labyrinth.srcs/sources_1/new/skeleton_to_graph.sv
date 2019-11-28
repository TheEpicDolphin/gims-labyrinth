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
    
    //This contains the 3x3 window that we will apply the kernel on.
    reg [((IMG_W << 1) + 3) - 1 : 0] skel_window;
    //logic [1:0] state;
    
    //This constructs the 3x3 window shown below
    // w_00 w_10 w_20
    // w_01 w_11 w_21
    // w_02 w_12 w_22
    
    logic w_11, w_01, w_10, w_21, w_12;
    assign w_11 = skel_window[IMG_W + 1];
    assign w_01 = skel_window[IMG_W + 2];
    assign w_10 = skel_window[(IMG_W << 1) + 1];
    assign w_21 = skel_window[IMG_W];
    assign w_12 = skel_window[1];
    
    //This marks the location on the image of pixel skel_window[0]
    logic [9:0] x_end;
    logic [8:0] y_end;
    
    //This marks the location on the image of the center of skel_window
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
    
    //Below is the kernel being applied to the 3x3 window 
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
                        //The zeroth node is reserved as a dummy node for dijkstra
                        n <= 10'b1;
                    end
                end
                READ_DELAY: begin
                    //window_end_i_read reads from BRAM the value that we will want BRAM_READ_DELAY cycles from now
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
                            //If we have an intersection, we mark it with the value 3'b010 in the bram
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


//IGNORE THIS LUIS. not important for the skeltonizer or erosion

module skeleton_corner_finder #(parameter IMG_W = 640, parameter IMG_H = 480)
    (
    input clk,
    input rst,
    input start,
    input [18:0] intersection_xy,
    input [5:0] intersection_count,
    
    input bram_ready,
    
    output logic write_node,
    output logic [9:0] node,
    output logic [18:0] node_xy,
    output done
    );
    
    logic done1;
    logic done2;
    logic done3;
    logic done4;
    
    logic cf1;
    logic cf2;
    logic cf3;
    logic cf4;
    logic start_crawling;
    
    logic [18:0] c1;
    logic [18:0] c2;
    logic [18:0] c3;
    logic [18:0] c4;
    
    logic [18:0] cout1;
    logic [18:0] cout2;
    logic [18:0] cout3;
    logic [18:0] cout4;
    
    logic empty1;
    logic empty2;
    logic empty3;
    logic empty4;
    
    logic r_en1;
    logic r_en2;
    logic r_en3;
    logic r_en4;
    
    logic [1:0] fifo_choice;
    
    assign r_en1 = fifo_choice == 2'b00;
    assign r_en2 = fifo_choice == 2'b01;
    assign r_en3 = fifo_choice == 2'b01;
    assign r_en4 = fifo_choice == 2'b01;
    
    corner_node_fifo f1(.clk(clk),
                        .din(c1),
                        .wr_en(cf1),
                        .empty(empty1),
                        .dout(cout1),
                        .rd_en(r_en1));
    corner_node_fifo f2(.clk(clk),
                        .din(c2),
                        .wr_en(cf2),
                        .empty(empty2),
                        .dout(cout2),
                        .rd_en(r_en2));
    corner_node_fifo f3(.clk(clk),
                        .din(c3),
                        .wr_en(cf3),
                        .empty(empty3),
                        .dout(cout3),
                        .rd_en(r_en3));
    corner_node_fifo f4(.clk(clk),
                        .din(c4),
                        .wr_en(cf4),
                        .empty(empty4),
                        .dout(cout4),
                        .rd_en(r_en4));
    
    path_crawler pc1(.clk(clk),.rst(rst),.start(start_crawling),.origin(intersection_xy),.corner_found(cf1),.c(c1),.done(done1));
    path_crawler pc2(.clk(clk),.rst(rst),.start(start_crawling),.origin(intersection_xy),.corner_found(cf2),.c(c2),.done(done2));
    path_crawler pc3(.clk(clk),.rst(rst),.start(start_crawling),.origin(intersection_xy),.corner_found(cf3),.c(c3),.done(done3));
    path_crawler pc4(.clk(clk),.rst(rst),.start(start_crawling),.origin(intersection_xy),.corner_found(cf4),.c(c4),.done(done4));
    
    parameter IDLE = 2'b00;
    parameter FETCH_NEXT_INTERSECTION = 2'b01;
    parameter CRAWL = 2'b10;
    parameter DONE = 2'b11;
    logic [1:0] state;
    
    logic x_end;
    logic y_end;
    
    logic x_c;
    logic y_c;
    
    logic n;
    logic [5:0] num_intersections_left;

    always_ff @(posedge clk)begin
        if(rst)begin
            state <= IDLE;
            fifo_choice <= 2'b00;
        end
        else begin
            
            fifo_choice <= fifo_choice + 1;
            //This makes sure that we select only one node at a time to add to the node list
            case(fifo_choice)
                2'b00: begin
                    write_node <= !empty1;
                    node_xy <= cout1;
                end
                2'b01: begin
                    write_node <= !empty2;
                    node_xy <= cout2;
                end
                2'b10: begin
                    write_node <= !empty2;
                    node_xy <= cout2;
                end
                2'b11: begin
                    write_node <= !empty2;
                    node_xy <= cout2;
                end
            endcase
            
            
            case(state)
                IDLE: begin
                    if(start)begin
                        state <= FETCH_NEXT_INTERSECTION;
                        num_intersections_left <= intersection_count;
                        //The zeroth node is reserved as a dummy node
                        n <= 10'b1;
                    end
                end
                FETCH_NEXT_INTERSECTION: begin
                    if(num_intersections_left == 0)begin
                        state <= DONE;
                    end
                    else begin
                        if(bram_ready)begin
                             num_intersections_left <= num_intersections_left - 1;
                             state <= CRAWL;
                             start_crawling <= 1;
                        end
                    end
                    
                end
                CRAWL: begin
                    start_crawling <= 0;
                    if(done1 && done2 && done3 && done4)begin
                        state <= FETCH_NEXT_INTERSECTION);
                    end
                end
                DONE: begin
                    state <= IDLE;
                end
            endcase
        end
    end
    
endmodule
