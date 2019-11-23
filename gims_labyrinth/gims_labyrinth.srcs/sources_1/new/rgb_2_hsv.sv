`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/06/2019 02:50:40 PM
// Design Name: 
// Module Name: rgb_2_hsv
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

module rgb_2_hsv(
    input clk,
    input rst,
    input start,
    input [7:0] r_in,
    input [7:0] g_in,
    input [7:0] b_in,
    output logic [16:0] h,   //Q9.8
    output logic [7:0] s,  //Q8
    output logic [7:0] v,  //Q8
    output ready,
    output logic [1:0] state
    );
    
    parameter DIVIDEND_WIDTH = 16;
    
    parameter IDLE = 2'b00;
    parameter DIV = 2'b01;
    parameter DONE = 2'b10;
    //logic [1:0] state;
    logic [7:0] r;
    logic [7:0] g;
    logic [7:0] b;
    
    logic div_start;
    logic div_ready;
    
    reg [7:0] min, max, delta;
    
    logic [15:0] h_dividend;
    logic [15:0] h_quotient;
    
    logic [15:0] s_dividend;
    logic [15:0] s_quotient;
    
    logic [15:0] v_dividend;
    logic [15:0] v_quotient;
    
    logic [31:0] h_prod;
    
    assign ready = state == DONE;
    
    divider #(.WIDTH(DIVIDEND_WIDTH)) h_div1 (
    .clk(clk),
    .sign(0),
    .start(div_start),
    .dividend(h_dividend),
    .divider({8'b0, delta}),
    .quotient(h_quotient),
    .ready(div_ready)
    );

    divider #(.WIDTH(DIVIDEND_WIDTH)) s_div1(
    .clk(clk),
    .sign(0),
    .start(div_start),
    .dividend({delta, 8'b0}),
    .divider({8'b0, max}),
    .quotient(s_quotient)
    );
    
    divider #(.WIDTH(DIVIDEND_WIDTH)) v_div1(
    .clk(clk),
    .sign(0),
    .start(div_start),
    .dividend({max, 8'b0}),
    .divider(16'd255),
    .quotient(v_quotient)
    );
    
    always_comb begin        
        delta = max - min;
        h_prod = 16'h3c00 * h_quotient;
        
        if(max == 0)begin
            h_dividend = 0;
            h = 0;
        end
        else if(r == max)begin
            if(g >= b)begin
                h_dividend = {g - b, 8'b0};
                h = h_prod[23:8];
            end
            else begin
                h_dividend = {b - g, 8'b0};
                h = 17'h16800 - h_prod[23:8];
            end
        end
        else if (g == max)begin
            if(b >= r)begin
                h_dividend = {b - r, 8'b0};
                h = 17'h07800 + h_prod[23:8];
            end
            else begin
                h_dividend = {r - b, 8'b0};
                h = 17'h07800 - h_prod[23:8];
            end
        end
        else if(b == max)begin
            if(r >= g)begin
                h_dividend = {r - g, 8'b0};
                h = 17'h0F000 + h_prod[23:8];
            end
            else begin
                h_dividend = {g - r, 8'b0};
                h = 17'h0F000 - h_prod[23:8];
            end
        end
        
    end
    
    
    always_ff @(posedge clk) begin
        if(rst)begin
            state <= IDLE;
        end
        else begin
            case(state)
                IDLE: begin
                    if(start)begin
                        if((r_in >= g_in) && (r_in>= b_in))begin
                            max <= r_in;
                        end 
                        else if((g_in >= r_in) && (g_in >= b_in))begin
                            max <= g_in;
                        end
                        else begin
                            max <= b_in;
                        end
                        
                        if((r_in <= g_in) && (r_in <= b_in))begin
                            min <= r_in;
                        end 
                        else if((g_in <= r_in) && (g_in <= b_in))begin
                            min <= g_in;
                        end
                        else begin
                            min <= b_in;
                        end
                        
                        r <= r_in;
                        g <= g_in;
                        b <= b_in;
                        div_start <= 1;
                        state <= DIV;
                    end
                end
                DIV: begin
                    div_start <= 0;
                    if(div_ready)begin
                        state <= DONE;
                        s <= s_quotient;
                        v <= v_quotient;
                    end
                end
                DONE: begin
                    state <= IDLE;
                end   
                default: begin
                    //Do nothing
                end         
            endcase
        end

        
    end
endmodule
