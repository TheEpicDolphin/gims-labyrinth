`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/15/2019 06:41:00 PM
// Design Name: 
// Module Name: min_heap
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


module min_heap #(parameter MAX_HEAP_SIZE = 50,
                  parameter MAX_NODES)
    (
    input clk,
    input rst,
    input insert,
    input [35:0] k,
    input retrieve_min,
    output logic [35:0] min_k,
    output ready,
    output logic [1:0] state
    );
    parameter READY = 2'b00;
    parameter MIN_HEAPIFY_UP = 2'b01;
    parameter MIN_HEAPIFY_DOWN = 2'b10;
    //logic [1:0] state;
    
    logic [5:0] parent_i;
    logic [5:0] left_i;
    logic [5:0] right_i;
    logic [5:0] i;
    
    logic [5:0] heap_idx;
    
    assign ready = (state == READY);
    reg [35:0] heap [0:MAX_HEAP_SIZE - 1];
    reg [5:0] heap_size;
    reg [9:0] heap_idx_map [0:MAX_NODES - 1];
    integer j;
    
    always_comb begin
        parent_i = (i - 1) >> 1;
        left_i = (i << 1) + 1;
        right_i = (i << 1) + 2;
        
        heap_idx = heap_idx_map[k[19:10]];
    end
    
    assign min_k = heap[0];
    
    always_ff @(posedge clk)begin
        if(rst)begin
            heap_size <= 0;
            for (j = 0; j < MAX_NODES; j = j + 1) begin
                heap_idx_map[j] <= MAX_HEAP_SIZE;
            end
            state <= READY;
        end
        else begin
            case(state)
                READY: begin
                    if(insert)begin
                        if(heap_idx == MAX_HEAP_SIZE)begin
                            heap[heap_size] <= k;
                            //update heap index map
                            heap_idx_map[k[19:10]] <= heap_size;
                            
                            heap_size <= heap_size + 1;
                            i <= heap_size;
                            state <= MIN_HEAPIFY_UP;
                        end
                        else begin
                            i <= heap_idx;
                            if(k < heap[heap_idx])begin
                                heap[heap_idx] <= k;
                                state <= MIN_HEAPIFY_DOWN;
                            end
                        end
                        
                    end
                    if(retrieve_min)begin
                        if(heap_size == 1)begin
                            //min_k <= heap[0];
                            heap_size <= heap_size - 1;
                            //update heap index map
                            heap_idx_map[heap[0][19:10]] <= MAX_HEAP_SIZE;
                        end
                        else begin
                            //min_k <= heap[0];
                            heap[0] <= heap[heap_size - 1];
                            heap_size <= heap_size - 1;
                            state <= MIN_HEAPIFY_DOWN;
                            i <= 0;
                            //update heap index map
                            heap_idx_map[heap[0][19:10]] <= MAX_HEAP_SIZE;
                            heap_idx_map[heap[heap_size - 1][19:10]] <= 0;
                        end
                        
                        
                        
                    end
                end
                
                MIN_HEAPIFY_UP: begin
                    if(i > 0 && heap[parent_i] > heap[i])begin
                        {heap[i], heap[parent_i]} <= {heap[parent_i], heap[i]};
                        //update heap index map
                        heap_idx_map[heap[parent_i][19:10]] <= i;
                        heap_idx_map[heap[i][19:10]] <= parent_i; 
                        i <= parent_i;
                    end
                    else begin
                        state <= READY;
                    end
                    
                end
                
                MIN_HEAPIFY_DOWN: begin
                    if(left_i < heap_size && right_i < heap_size && heap[right_i] < heap[i] && heap[right_i] < heap[left_i])begin
                        {heap[i], heap[right_i]} <= {heap[right_i], heap[i]};
                        //update heap index map
                        heap_idx_map[heap[right_i][19:10]] <= i;
                        heap_idx_map[heap[i][19:10]] <= right_i; 
                        i <= right_i;          
                    end
                    else if(left_i < heap_size && heap[left_i] < heap[i])begin
                        {heap[i], heap[left_i]} <= {heap[left_i], heap[i]};
                        //update heap index map
                        heap_idx_map[heap[left_i][19:10]] <= i;
                        heap_idx_map[heap[i][19:10]] <= left_i; 
                        i <= left_i;
                    end
                    else begin
                        state <= READY;
                    end
                end
                default: begin
                    //do nothing
                end
            endcase

        end
    end
    
    
    
endmodule
