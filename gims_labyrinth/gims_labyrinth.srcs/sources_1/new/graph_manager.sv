`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/16/2019 03:13:30 PM
// Design Name: 
// Module Name: graph_manager
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


module graph_manager(
    input clk,
    input rst,
    input [9:0] n,
    input write_adj,
    input write_bp,
    input write_min_weight,
    input write_pos,
    input read,
    //writing
    input [63:0] adjacency_in,
    input [15:0] weight_in,
    input [9:0] backpointer_in,
    input [18:0] xy_in,
    //reading
    output [63:0] adjacency_out,
    output [15:0] weight_out,
    output [9:0] backpointer_out,
    output [18:0] xy_out,
    output ready
    );
    parameter DO_NOTHING = 3'b000;
    parameter SET_ADJACENCY = 3'b001;
    parameter SET_BACKPOINTER = 3'b010;
    parameter SET_MIN_WEIGHT = 3'b011;
    parameter SET_NODE_POS = 3'b100;
    parameter READ = 3'b101;
    
    parameter READY = 2'b00;
    parameter FIRST_CYCLE = 2'b01;
    parameter SECOND_CYCLE = 2'b10;
    logic [1:0] state;
    
    //All these brams have as many rows as the maximum number of nodes in the graph
    
    //10 bits for adjacent node
    //6 bits for weight
    //repeat above 4 times for each of the four possible neighbors
    adjacency_list adj_list(.clka(clk),
                            .addra(n),
                            .dina(adjacency_in),
                            .douta(adjacency_out),
                            .wea(write_adj)
                            );
    
    //10 bits for x
    //9 bits for y
    node_list n_list(.clka(clk),
                     .addra(n),
                     .dina(xy_in),
                     .douta(xy_out),
                     .wea(write_pos)
                     );
    
    //10 bits for pointer to previous node for minimum weight path
    spt_backpointers spt_bp(.clka(clk),
                            .addra(n),
                            .dina(backpointer_in),
                            .douta(backpointer_out),
                            .wea(write_bp));
    
    //16 bits for minimum weight path
    spt_min_weights spt_min_w(.clka(clk),
                              .addra(n),
                              .dina(weight_in),
                              .douta(weight_out),
                              .wea(write_min_weight)
                              );

    assign ready = (state == SECOND_CYCLE);
    logic do_something;
    assign do_something = write_adj || write_bp || write_min_weight || write_pos || read;
    
    always_ff @(posedge clk)begin
        if(rst)begin
            state <= READY;
        end
        else begin
            case(state)
                READY: begin
                    if(do_something)begin
                        state <= FIRST_CYCLE;
                    end
                end
                FIRST_CYCLE: begin
                    state <= SECOND_CYCLE;
                end
                SECOND_CYCLE: begin
                    state <= READY;
                end
                default: begin
                    //do nothing
                end
            endcase
        end
    end
    
endmodule
