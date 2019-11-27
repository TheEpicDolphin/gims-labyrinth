`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2019 05:45:56 PM
// Design Name: 
// Module Name: skeleton_intersection_finder_tb
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


module skeleton_intersection_finder_tb;
logic clock;
logic rst;
logic start;

logic [16:0] addr;
logic pixel_r;

//Debugging
logic [2:0] state;



// Instantiate the Unit Under Test (UUT)
binary_maze skel_maze(.clka(clock),
                      .addra(addr),
                      .douta(pixel_r),
                      .wea(0)
                      );
    
skeleton_intersection_finder #(.IMG_W(320),.IMG_H(240), .BRAM_READ_DELAY(2)) uut 
        (
        .clk(clock),
        .rst(rst),
        .start(start),
        .pixel_r(pixel_r),
        .window_end_i_read(addr),
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

start = 1;
#15
start = 0;
#500;

end

endmodule

