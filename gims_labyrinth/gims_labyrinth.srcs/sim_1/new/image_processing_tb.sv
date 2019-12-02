`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2019 05:55:56 PM
// Design Name: 
// Module Name: image_processing_tb
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


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2019 02:52:04 PM
// Design Name: 
// Module Name: rgb_2_hsv_tb
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


module image_processing_tb;
   // Inputs
logic clock;
logic rst;
logic start;
logic [7:0] r_in;
logic [7:0] g_in;
logic [7:0] b_in;

// Outputs
logic [16:0] h;
logic [7:0] s;
logic [7:0] v;
logic ready;

logic [1:0] state;

integer rgb_f;
integer hsv_f;
integer i;
logic [23:0] rgb;

// Instantiate the Unit Under Test (UUT)
signal_processing uut(
    .clk(clock),
    .rst(rst),
    .start(start),
    .r(r_in),
    .g(g_in),
    .b(b_in),
    .h(h),   //Q9.8
    .s(s),  //Q8
    .v(v)   //Q8
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
   
   /*
   rgb_f=$fopen("C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/python_stuff/verilog_testing/rgb.txt","r");
   for(i = 0; i < 30; i = i + 1)begin
        $fscanf(rgb_f,"%h\n",rgb);
        r_in = rgb[23:16];
        g_in = rgb[15:8];
        b_in = rgb[7:0];
        #10;
   end
   #200;
   $fclose(rgb_f);
   */
   
   rgb_f=$fopen("C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/python_stuff/verilog_testing/maze_img.txt","r");
   for(i = 0; i < 320*240; i = i + 1)begin
        $fscanf(rgb_f,"%h\n",rgb);
        r_in = rgb[23:16];
        g_in = rgb[15:8];
        b_in = rgb[7:0];
        #10;
   end
   $fclose(rgb_f);
   #200;
   
end
   
endmodule