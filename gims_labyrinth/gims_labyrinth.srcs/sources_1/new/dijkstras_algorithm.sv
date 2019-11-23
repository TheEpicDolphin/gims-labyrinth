`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2019 05:35:26 PM
// Design Name: 
// Module Name: dijkstras_algorithm
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



module dijkstras_algorithm #(parameter MAX_OUT_DEGREE = 4, parameter MAX_NODES = 1024)
(
    input clk,
    input rst,
    input run,
    input n_start,
    
    //Set high when we can safely read bram output
    input bram_ready,    
    //The minimum weight to get to node n
    input [15:0] min_weight_in,
    //Contains the edge weights and nodes of the neighbors of n
    input [63:0] adjacency,
        
    //Used to index into the bram rows
    output logic [9:0] n,
    
    //read is set high when reading from any of the brams
    output logic read,
    //below are used for writing backpointers and minimum weights
    output logic [9:0] backpointer,
    output logic [15:0] min_weight_out,
    //These are set high when writing to the appropriate bram
    output logic write_bp,
    output logic write_min_weight,
    output logic done,
    output logic [2:0] state
    );
    //Every iteration of the algorithm, we output the current node and the minimum weight
    //to reach it. This minimum weight is written into the bram that stores the minimum weight
    //to each node. At the same time, we also fetch the neighbors for that node for the 
    //next iteration 
    
    parameter IDLE = 3'b000;
    parameter FETCH_NEIGHBORS = 3'b001;
    parameter CONSIDER_NEIGHBOR = 3'b010;
    parameter CHECK_IF_NEIGHBOR_IN_SPT = 3'b011;
    parameter WAIT_FOR_HEAP_READY = 3'b100;
    parameter ADD_TO_FRONTIER = 3'b101; //Checks if adjacents are already included in SPT
    parameter SELECT_MIN_NODE = 3'b110;
    parameter DONE = 3'b111;
    //logic [2:0] state;
    
    reg spt_set [0:MAX_NODES - 1];
    reg [15:0] neighbors [0:MAX_OUT_DEGREE - 1];
    logic [2:0] i;
    
    logic frontier_ready;
    logic insert_into_frontier;
    logic retrieve_min;
    
    logic [35:0] k;
    logic [35:0] min_k;
    
    min_heap #(.MAX_NODES(MAX_NODES))frontier_heap(
        .clk(clk),
        .rst(rst),
        .insert(insert_into_frontier),
        .k(k),
        .retrieve_min(retrieve_min),
        .min_k(min_k),
        .ready(frontier_ready));
    
    logic [9:0] neighbor;
    logic [5:0] neighbor_weight;
    
    integer j;
    logic [9:0] parent;
    logic [15:0] parent_min_weight;
    assign done = state == DONE;
    
    always_ff @(posedge clk)begin
        if(rst)begin
            state <= IDLE;
            read <= 0;
            write_bp <= 0;
            write_min_weight <= 0;
            insert_into_frontier <= 0;
            retrieve_min <= 0;
        end
        else begin
            case(state)
                IDLE: begin
                    if(run)begin
                        i <= 3'b0;
                        state <= FETCH_NEIGHBORS;
                        //Initialize spt_set for dijkstra's algorithm
                        for (j = 0; j < MAX_NODES; j = j + 1) begin    
                            spt_set[j] <= j == n_start;
                        end
                        n <= n_start;
                        parent <= n_start;
                        parent_min_weight <= 16'b0;
                        read <= 1;
                    end
                end
                FETCH_NEIGHBORS: begin
                    read <= 0;
                    write_bp <= 0;
                    write_min_weight <= 0;
                    if(bram_ready)begin
                        for (j = 0; j < MAX_OUT_DEGREE; j = j + 1) begin
                            neighbors[j] <= adjacency[(j << 4) +: 16];
                        end
                        state <= CONSIDER_NEIGHBOR;
                        i <= 3'b0;
                    end
                end
                CONSIDER_NEIGHBOR: begin
                    if(i == MAX_OUT_DEGREE)begin
                        retrieve_min <= 1;
                        state <= SELECT_MIN_NODE;
                    end
                    else begin
                        {neighbor, neighbor_weight} <= neighbors[i];
                        state <= CHECK_IF_NEIGHBOR_IN_SPT;
                    end
                    
                end
                CHECK_IF_NEIGHBOR_IN_SPT: begin
                    if(spt_set[neighbor] == 0)begin
                        state <= WAIT_FOR_HEAP_READY;
                    end
                    else begin
                        state <= CONSIDER_NEIGHBOR;
                        i <= i + 1;
                    end                  
                end
                WAIT_FOR_HEAP_READY: begin
                    if(frontier_ready)begin 
                        if(neighbor == 10'b0)begin
                            //We are finished inserting neighbors
                            retrieve_min <= 1;
                            state <= SELECT_MIN_NODE;
                        end
                        else begin
                            insert_into_frontier <= 1;
                            //Store parent so that we can have a backpointer to the minimum weight path
                            k <= {neighbor_weight + parent_min_weight, neighbor, parent};
                            i <= i + 1;
                            state <= ADD_TO_FRONTIER;
                        end
                    end
                end
                ADD_TO_FRONTIER: begin
                    insert_into_frontier <= 0;
                    if(frontier_ready)begin
                        state <= CONSIDER_NEIGHBOR;
                    end
                end
                SELECT_MIN_NODE: begin
                    retrieve_min <= 0;
                    {min_weight_out, n, backpointer} <= min_k;
                    //Store the parent of the new neighbors and the minimum weight
                    //of the path to this parent
                    parent <= min_k[19:10];
                    parent_min_weight <= min_k[25:20];
                    
                    spt_set[n] <= 1;
                    read <= 1;
                    write_min_weight <= 1;
                    write_bp <= 1;
                    state <= FETCH_NEIGHBORS;
                end
                DONE: begin
                    
                end
            endcase
            
        end
    end
    
    
endmodule
