`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2019 04:39:49 PM
// Design Name: 
// Module Name: lees_algorithm_tb
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


module lees_algorithm_tb;
logic clock;
logic rst;
logic start;

logic [16:0] start_pos;
logic [16:0] pixel_r_addr;
logic [16:0] pixel_wr_addr;
logic skel_pixel;
logic [1:0] pixel_type;
logic visited;

logic write_bp;
logic write_visited;
logic [1:0] backpointer;
logic visit;

logic [16:0] end_pos;
logic done;

//Debugging
logic [2:0] state;


// Instantiate the Unit Under Test (UUT)
binary_maze skel_maze(.clka(clock),
                      .addra(pixel_r_addr),
                      .douta(skel_pixel),
                      .wea(0)
                      );
                      
pixel_backpointers p_bp(.clka(clock),
                        .addra(pixel_wr_addr),
                        .dina(backpointer),
                        .wea(write_bp));
                        
pixel_type_map p_tmap(.clka(clock),
                      .addra(pixel_r_addr),
                      .douta(pixel_type),
                      .wea(0));
                      
visited_map visited_map(.clka(clock),
                      .addra(pixel_wr_addr),
                      .dina(visit),
                      .wea(write_visited),
                      .clkb(clock),
                      .addrb(pixel_r_addr),
                      .doutb(visited));
    
lees_algorithm #(.MAX_OUT_DEGREE(4),.BRAM_DELAY_CYCLES(2),.IMG_W(320),.IMG_H(240)) l_a
                      (
                      .clk(clock),
                      .rst(rst),
                      .start(start),
                      .start_pos(start_pos),
                          
                      .skel_pixel(skel_pixel),
                      .pixel_type(pixel_type),
                      .visited(visited),
                      .pixel_r_addr(pixel_r_addr),
                      .pixel_wr_addr(pixel_wr_addr),
                      .backpointer(backpointer),
                      .write_bp(write_bp),
                      .write_visited(write_visited),
                      .visit(visit),
                      .done(done),
                      .end_pos(end_pos),
                          
                      .state(state)
                       );

always #5 clock = !clock;

initial begin
// Initialize Inputs
clock = 0;
rst = 0;
start = 0;

// Wait 100 ns for global reset to finish
#100;
#15;
rst = 1;
#15
rst = 0;
#15;

start_pos = {9'd49, 8'd15};
start = 1;
#15
start = 0;
#500;

end

endmodule
