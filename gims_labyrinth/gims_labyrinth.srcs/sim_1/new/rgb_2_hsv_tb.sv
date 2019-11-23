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


module rgb_2_hsv_tb;
   // Inputs
logic clock;
logic rst;
logic start_conv;
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
rgb_2_hsv uut(
    .clk(clock),
    .rst(rst),
    .start(start_conv),
    .r_in(r_in),
    .g_in(g_in),
    .b_in(b_in),
    .h(h),   //Q9.8
    .s(s),  //Q8
    .v(v),  //Q8
    .ready(ready),
    .state(state)
    );

always #5 clock = !clock;

initial begin
   // Initialize Inputs
   clock = 0;
   start_conv = 0;
   rst = 0;

   // Wait 100 ns for global reset to finish
   #100;
   #15;
   rst = 1;
   #15
   rst = 0;
   #15;
   r_in = 8'd100;
   g_in = 8'd120;
   b_in = 8'd50;
   
   #15;
   start_conv =1;
   #10;
   start_conv = 0;
   #200;
   
   rgb_f=$fopen("C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims_labyrinth/rgb.txt","r");
   hsv_f = $fopen("C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims_labyrinth/hsv.txt","w");
   for(i = 0; i < 10; i = i + 1)begin
        $fscanf(rgb_f,"%h\n",rgb);
        r_in = rgb[23:16];
        g_in = rgb[15:8];
        b_in = rgb[7:0];
        #15;
        start_conv =1;
        #10;
        start_conv = 0;
        #200;
        $fwrite(hsv_f,"%h\n",{h,s,v});
   end
   $fclose(rgb_f);
   $fclose(hsv_f);
end
   
endmodule
