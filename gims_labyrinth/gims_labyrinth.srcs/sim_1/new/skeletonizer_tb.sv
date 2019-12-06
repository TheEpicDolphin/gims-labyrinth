`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/06/2019 01:29:58 AM
// Design Name: 
// Module Name: skeletonizer_tb
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


module skeletonizer_tb;
// Inputs
logic clock;
logic rst;
logic start;


logic bin_pixel_in;
logic bin_pixel_out;
logic [16:0] pixel_r_addr;
logic [16:0] pixel_wr_addr;
logic pixel_we;

binary_maze bin_maze(.clka(clock),
                    .addra(pixel_wr_addr),
                    .dina(bin_pixel_in),
                    .wea(pixel_we),
                     .clkb(clock),
                     .addrb(pixel_r_addr),
                     .doutb(bin_pixel_out));

// Instantiate the Unit Under Test (UUT)
skeletonizer #(.IMG_WIDTH(320), .IMG_HEIGHT(240), .BRAM_READ_DELAY(2)) skel(
    .clk(clock),
    .rst(rst),
    .start(start),
    .pixel_in(bin_pixel_out),		
    .pixel_r_addr(pixel_r_addr),
    .pixel_wr_addr(pixel_wr_addr),
    .pixel_we(pixel_we),                            // bram write enable
    .pixel_out(bin_pixel_in)                                // write data to bram
    );

always #5 clock = !clock;

initial begin
// Initialize Inputs
clock = 0;
start = 0;
rst = 0;

// Wait 100 ns for global reset to finish
#100;
#15;
rst = 1;
#15
rst = 0;
#15;
start =1;
#10;
start = 0;

#200;

end

endmodule
