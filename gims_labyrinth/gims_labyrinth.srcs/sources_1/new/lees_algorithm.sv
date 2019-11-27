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


module lees_algorithm #(parameter MAX_OUT_DEGREE = 4, parameter MAX_NODES = 1024)
(
    input clk,
    input rst,
    input run,
    input n_start,
    
    //Set high when we can safely read bram output
    input bram_ready,    
        
    //Used to index into the bram rows
    output logic [9:0] n,
    
    //read is set high when reading from any of the brams
    output logic read,
    //below are used for writing backpointers
    output logic [1:0] backpointer,
    //These are set high when writing to the appropriate bram
    output logic write_bp,
    output logic done,
    output logic [2:0] state
    );
    
    parameter IDLE = 3'b000;
    parameter FETCH_NEIGHBORS = 3'b001;
    parameter CONSIDER_NEIGHBOR = 3'b010;
    parameter CHECK_IF_NEIGHBOR_IN_SPT = 3'b011;
    parameter WAIT_FOR_HEAP_READY = 3'b100;
    parameter ADD_TO_FRONTIER = 3'b101; //Checks if adjacents are already included in SPT
    parameter SELECT_MIN_NODE = 3'b110;
    parameter DONE = 3'b111;
    
    logic [5:0] idx;
    reg [18:0] queue[0:63];
    reg visited [];
    
    always_ff @(posedge clk)begin
        if(rst)begin
            
        end
        else begin
            case(state)
                IDLE: begin
                    if(start)begin
                        state <= 
                    end
                end
                
            
            endcase
        end
    end
endmodule
