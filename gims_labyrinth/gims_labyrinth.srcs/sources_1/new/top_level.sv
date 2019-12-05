`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2019 08:55:55 PM
// Design Name: 
// Module Name: top_level
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


module top_level(
   input clk_100mhz,
   input[15:0] sw,
   input btnc, btnu, btnl, btnr, btnd,
   output[3:0] vga_r,
   output[3:0] vga_b,
   output[3:0] vga_g,
   output vga_hs,
   output vga_vs,
   output led16_b, led16_g, led16_r,
   output led17_b, led17_g, led17_r,
   output[15:0] led,
   output ca, cb, cc, cd, ce, cf, cg, dp,  // segments a-g, dp
   output[7:0] an    // Display location 0-7
   );
   
    logic clk_25mhz;    // ???
    logic blank;    // ???
    
    // create 65mhz system clock, happens to match 1024 x 768 XVGA timing
    clk_wiz_vga clkdivider(.clk_in1(clk_100mhz), .clk_out1(clk_25mhz));

    logic [31:0] data;      //  instantiate 7-segment display; display (8) 4-bit hex
    logic [6:0] segments;
    assign {cg, cf, ce, cd, cc, cb, ca} = segments[6:0];
    //display_8hex display(.clk_in(clk_25mhz),.data_in(data), .seg_out(segments), .strobe_out(an));
    //assign seg[6:0] = segments;
    assign  dp = 1'b1;  // turn off the period

    assign led = sw;                        // turn leds on
    //assign data = {28'h0123456, sw[3:0]};   // display 0123456 + sw[3:0]
    assign led16_r = btnl;                  // left button -> red led
    assign led16_g = btnc;                  // center button -> green led
    assign led16_b = btnr;                  // right button -> blue led
    assign led17_r = btnl;
    assign led17_g = btnc;
    assign led17_b = btnr;
                
    logic [9:0] hcount;     // pixel on current line
    logic [9:0] vcount;     // line number
    logic hsync, vsync;
    logic [11:0] pixel, pixel_path;
    logic [11:0] rgb;    
    vga vga1(.vclock_in(clk_25mhz),.hcount_out(hcount),.vcount_out(vcount),
          .hsync_out(hsync),.vsync_out(vsync),.blank_out(blank));

    // btnc button is user reset
    logic reset;
    debounce db1(.reset_in(0),.clock_in(clk_25mhz),.noisy_in(btnc),.clean_out(reset));
   
    logic find_path, move_car;
    debounce db2(.reset_in(reset),.clock_in(clk_25mhz),.noisy_in(btnu),
            .clean_out(find_path));
    debounce db3(.reset_in(reset),.clock_in(clk_25mhz),.noisy_in(btnd),
            .clean_out(move_car));                               

    // BRAMs operating mode No_Change
    parameter BRAM_SIZE = 76800;
    logic my_wea0, my_wea1;
    logic [16:0] addr0, my_addr0, addr1;
    logic [3:0] data_to_bram0, data_from_bram0;
    logic data_to_bram1, data_from_bram1;
    logic BRAM0_initialized, BRAM1_initialized;
    
    blk_mem_gen_0 bram0(.clka(clk_25mhz), .wea(my_wea0), .addra(addr0),  
                .dina(data_to_bram0), .douta(data_from_bram0));                           
    blk_mem_gen_1 bram1(.clka(clk_25mhz), .wea(my_wea1), .addra(addr1),  
                .dina(data_to_bram1), .douta(data_from_bram1));  
                
    parameter IMG_W = 320;
    parameter IMG_H = 240;
    
    parameter IDLE = 3'b000;
    parameter BINARY_MAZE_FILTERING = 3'b001;
    parameter SKELETONIZING = 3'b010;
    
    parameter COLORED_MAZE_FILTERING = 3'b011;
    parameter SOLVING = 3'b100;
    parameter TRACING_BACKPOINTERS = 3'b101;

    logic [2:0] state;
               
    // Instantiate the Unit Under Test (UUT)
    binary_maze skel_maze(.clka(clk_25mhz),
                          .addra(pixel_r_addr),
                          .douta(skel_pixel),
                          .wea(0)
                          );
    
    logic bin_maze_filt_done;
    binary_maze_filtering #(.IMG_W(320),.IMG_W(240)) bin_maze_filt
        (
        
         .clk(clk_25mhz),
         .rst(reset),
         .start(),
         .r(),
         .g(),
         .b(),        
         .done(bin_maze_filt_done),
         .pixel_wr_addr(),
         .pixel_wr(),
         .pixel_out()
         );
         
    logic colored_maze_filt_done;
    logic [16:0] start_pos;
    
    module colored_maze_filtering #(parameter IMG_W = 320, parameter IMG_H = 240)
        (
        .clk(clk_25mhz),
        .rst(reset),
        .start(),
        .r(),
        .g(),
        .b(),
        .start_pos(start_pos),
        .done(colored_maze_filt_done)
    );
    
    pixel_type_map p_tmap(.clka(clk_25mhz),
                          .addra(pixel_r_addr),
                          .douta(pixel_type),
                          .wea(0));
                          
                          
    pixel_backpointers p_bp(.clka(clk_25mhz),
                            .addra(pixel_wr_addr),
                            .dina(backpointer_wr),
                            .wea(write_bp),
                            .clkb(clk_25mhz),
                            .addrb(bp_tracer_addr),
                            .doutb(backpointer_r));
    

                 
    lees_algorithm #(.MAX_OUT_DEGREE(4),.BRAM_DELAY_CYCLES(2),
                     .IMG_W(IMG_W),.IMG_H(IMG_H)) maze_solver
                 (
                  .clk(clk_25mhz),
                  .rst(reset),
                  .start(),
                  .start_pos(start_pos),
                  .skel_pixel(skel_pixel),
                  .pixel_type(pixel_type),
                  .pixel_r_addr(),
                  .pixel_wr_addr(),
                  .backpointer(),
                  .write_bp(write_bp),
                  .done(),
                  .end_pos()
                  );
                  
    path_bram pb(.clka(clk_25mhz),
                 .addra(bp_tracer_addr),
                 .dina(write_path),
                 .wea(write_path));   
                     
    backpointer_tracer #(.BRAM_DELAY_CYCLES(2),.IMG_W(320),.IMG_H(240)) bp_tracer(
                      .clk(clock),
                      .rst(rst),
                      .start(start_bp_tracer),
                      .start_pos(start_pos),
                      .end_pos(end_pos),
                      .bp(backpointer_r),
                      .pixel_addr(bp_tracer_addr),
                      .write_path(write_path),
                      .done(bp_tracer_done)
                      );
         
    always_ff @(posedge clk_25mhz)begin
        if(reset)begin
        
        end
        else begin
            case(state)
                IDLE: begin
                    
                end
                BINARY_MAZE_FILTERING: begin
                    if(bin_maze_filt_done)begin
                        state <= SKELETONIZING;
                    end
                end
                SKELETONIZING: begin
                
                end
                COLORED_MAZE_FILTERING: begin
                    if(colored_maze_filt_done)begin
                        state <= SOLVING;
                        
                    end
                end
                SOLVING: begin
                    if(solving_done)begin
                        state <= TRACING_BACKPOINTERS;
                    end
                end
                TRACING_BACKPOINTERS: begin
                    
                end
            endcase
        end
    end
                              
    logic phsync,pvsync,pblank;
    logic b,hs,vs;
    logic my_hcount, my_vcount; 
    logic hsync1, vsync1, blank1, hsync2, vsync2, blank2;
    
    logic [9:0] car_x, car_y;
    parameter car_x_init = 0;   // The starting address is provided by maze algorithm
    parameter car_y_init = 9;   // so these two initial parameters are TO BE DELETED
    path pa(.vclock_in(clk_25mhz),.reset_in(reset), .data_from_bram1(data_from_bram1),
                .hcount_in(my_hcount),.vcount_in(my_vcount),
                .hsync_in(hsync2),.vsync_in(vsync2),.blank_in(blank2),
                .phsync_out(phsync),.pvsync_out(pvsync),.pblank_out(pblank),
                .pixel_out(pixel_path));

    logic border = (hcount==0 | hcount==639 | vcount==0 | vcount==479 |
                   hcount == 320 | vcount == 240);
    
    logic addr0_inc, addr1_inc;
    always_ff @(posedge clk_25mhz) begin
        if (reset) begin  //initialize BRAM path
            BRAM0_initialized <= 0;
            my_wea0 <= 1;
            addr0 <= 0;
            BRAM1_initialized <= 0;
            my_wea1 <= 1;
            addr1 <= 0;
            addr0_inc <= 0;
            addr1_inc <= 0;
        end else if (!BRAM0_initialized) begin      
            if (addr0 < BRAM_SIZE) begin
                if (!addr0_inc) begin
                    addr0_inc <= 1;
                    if ((addr0 >= 2880) && (addr0 < 3100)) 
                        data_to_bram0 <=  4'b0001;
                    else if (addr0==3100) data_to_bram0<=4'b0010;
                    else if ((addr0 == 3420) || (addr0 == 3740) || (addr0 == 4060) || (addr0 == 4380)
                        || (addr0 == 4700) || (addr0 == 5020) || (addr0 == 5340) || (addr0 == 5660))
                        data_to_bram0 <=  4'b0010;
                    else if ((addr0 == 5980) || (addr0 == 6300) || (addr0 == 6620) || (addr0 == 6940)
                        || (addr0 == 7260) || (addr0 == 7580) || (addr0 == 7900) || (addr0 == 8220))
                        data_to_bram0 <=  4'b0010;
                    else if ((addr0 == 8540) || (addr0 == 8860) || (addr0 == 9180) || (addr0 == 9500)
                        || (addr0 == 9820) || (addr0 == 10140) || (addr0 == 10460) )
                        data_to_bram0 <=  4'b0010;
                    else if ((addr0 >= 10561) && (addr0 < 10781)) 
                        data_to_bram0 <=  4'b0100;
                    else  data_to_bram0 <=  4'b0;                         
                end else begin
                    addr0_inc <= 0;
                    addr0 <= addr0 + 1;                    
                end            
            end else begin
                BRAM0_initialized <= 1; 
                addr0 <= 0;
                my_wea0 <= 0;
            end
        
        // find path    
        end else if (!BRAM1_initialized) begin       
            if (addr1 < BRAM_SIZE) begin
                if (!addr1_inc) begin
                    data_to_bram1 <= (data_from_bram0 == 4'b0) ? 1'b0 : 1'b1;
                    addr1_inc <= 1;
                end else begin
                    addr1_inc <= 0;
                    addr0 <= addr0 + 1;
                    addr1 <= addr1 + 1;
                end
            end else begin
                BRAM1_initialized <= 1;
                addr0 <= 0;
                addr1 <= 0; 
                my_wea1 <= 0;
            end
        //read from BRAM1 for solved path
        end else begin        
            addr0 <= my_addr0; 
            addr1 <= (hcount>>1)+ ((vcount>>1)*32'd320);    
        end
    
        //1 step delay of addr1 calculation + data out from bram of another step delay
        hsync2 <= hsync1;
        vsync2 <= vsync1;
        blank2 <= blank1;
        hsync1 <= hsync;
        vsync1 <= vsync;
        blank1 <= blank;
        my_hcount <= hcount;
        my_vcount <= vcount;
                
        if (sw[1:0] == 2'b01) begin
            // 1 pixel outline of visible area (white)
            hs <= hsync;
            vs <= vsync;
            b <= blank;
            rgb <= {12{border}};
        end else if (sw[1:0] == 2'b10) begin
            // color bars
            hs <= hsync;
            vs <= vsync;
            b <= blank;
            rgb <= {{4{hcount[7]}}, {4{hcount[6]}}, {4{hcount[5]}}};
        end else begin
            // default: path_car
            hs <= phsync;
            vs <= pvsync;
            b <= pblank;
            rgb <= pixel;
        end
    end
    
    parameter EAST  = 4'b0001;
    parameter SOUTH = 4'b0010;
    parameter WEST  = 4'b0100;
    parameter NORTH = 4'b1000;    
    always_ff @(negedge vsync2) begin  
        if(!BRAM1_initialized) begin
            car_x <= car_x_init;    // car_x_init and car_y_init are from maze algorithm
            car_y <= car_y_init;    // not from defined parameters (theh two parameters to be deleted
        end else begin
            if (data_from_bram0 == EAST) car_x <= (addr0 % 320) +1;
            else if (data_from_bram0 == SOUTH) car_y <= (addr0 / 320)+1;
            else if (data_from_bram0 == WEST) car_x <= (addr0 % 320)-1;
            else if (data_from_bram0 == NORTH) car_y <= (addr0 / 320)-1;
        end  
    end
    
    assign my_addr0 = car_x + (car_y*32'd320);
 
    parameter WIDTH = 4;
    parameter HEIGHT = 4;
    parameter COLOR = 12'h0F0;
    logic [9:0] car_x_min, car_y_min, car_x_max, car_y_max, x3, y3;
    logic [11:0] pixel_car;
    always_ff @(posedge clk_25mhz) begin
        if(!BRAM1_initialized) begin
            car_x_min <= 0;
            car_y_min <= 0;
            car_x_max <= 0;
            car_y_max <= 0;
            x3 <= (hcount>>1);
            y3 <= (vcount>>1);
        end else begin
            car_x_min <= (car_x < WIDTH)? 0 : (car_x-WIDTH);
            car_y_min <= (car_y < HEIGHT)? 0 : (car_y-HEIGHT);
            car_x_max <= (car_x < (320-WIDTH))? (car_x+WIDTH) : 319;
            car_y_max <= (car_y < 240-HEIGHT)? (car_y+HEIGHT) : 239;

            x3 <= (hcount>>1);
            y3 <= (vcount>>1);
            if ((x3 >= car_x_min && x3 < car_x_max) &&
                (y3 >= car_y_min && y3 < car_y_max))
                pixel_car <= COLOR;
            else pixel_car <= 12'b0;
            end
    end 
    assign pixel = pixel_path | pixel_car;
 
    // the following lines are required for the Nexys4 VGA circuit - do not change
    assign vga_r = ~b ? rgb[11:8]: 0;
    assign vga_g = ~b ? rgb[7:4] : 0;
    assign vga_b = ~b ? rgb[3:0] : 0;

    assign vga_hs = ~hs;
    assign vga_vs = ~vs;

endmodule


////////////////////////////////////////////////////////////////////////////////
//
// path: draw path 
//
////////////////////////////////////////////////////////////////////////////////
module path (
    input vclock_in,        // 25MHz clock
    input reset_in,         // 1 to initialize module
    input data_from_bram1,
    input [9:0] hcount_in,  // horizontal index of current pixel (0..639)
    input [9:0] vcount_in,  // vertical index of current pixel (0..479)
    input hsync_in,         // VGA horizontal sync signal (active low)
    input vsync_in,         // VGA vertical sync signal (active low)
    input blank_in,         // VGA blanking (1 means output black pixel)    
    output phsync_out,      // path_car's horizontal sync
    output pvsync_out,      // path_car's vertical sync
    output pblank_out,      // path_car's blanking
    output [11:0] pixel_out // path_car's pixel  // r=23:16, g=15:8, b=7:0 
    );

    parameter WHITE = 12'hFFF;
    parameter GREEN = 12'h0F0;
    
    logic [11:0] pixel_car, pixel_path;    

    assign pixel_path = data_from_bram1? WHITE : 12'b0;     
 
    assign phsync_out = hsync_in;
    assign pvsync_out = vsync_in;
    assign pblank_out = blank_in;
    
    assign pixel_out = pixel_path; 
endmodule


//////////////////////////////////////////////////////////////////////////////////
// Update: 8/8/2019 GH 
// Create Date: 10/02/2015 02:05:19 AM
// Module Name: xvga
//
// vga: Generate VGA display signals (640 x 480 @ 60Hz)
//
//                              ---- HORIZONTAL -----     ------VERTICAL -----
//                              Active                    Active
//                    Freq      Video   FP  Sync   BP      Video   FP  Sync  BP
//   640x480, 60Hz    25.175    640     16    96   48       480    11   2    31
//   800x600, 60Hz    40.000    800     40   128   88       600     1   4    23
//   1024x768, 60Hz   65.000    1024    24   136  160       768     3   6    29
//   1280x1024, 60Hz  108.00    1280    48   112  248       768     1   3    38
//   1280x720p 60Hz   75.25     1280    72    80  216       720     3   5    30
//   1920x1040 60Hz   148.5     1920    88    44  148      1080     4   5    36
//
// change the clock frequency, front porches, sync's, and back porches to create 
// other screen resolutions
////////////////////////////////////////////////////////////////////////////////

module vga(input vclock_in,
            output reg [9:0] hcount_out,    // pixel number on current line
            output reg [9:0] vcount_out,     // line number
            output reg vsync_out, hsync_out,
            output reg blank_out);

   parameter DISPLAY_WIDTH  = 640;      // display width
   parameter DISPLAY_HEIGHT = 480;       // number of lines

   parameter  H_FP = 16;                 // horizontal front porch
   parameter  H_SYNC_PULSE = 96;        // horizontal sync
   parameter  H_BP = 48;                // horizontal back porch

   parameter  V_FP = 11;                  // vertical front porch
   parameter  V_SYNC_PULSE = 2;          // vertical sync 
   parameter  V_BP = 31;                 // vertical back porch

   // horizontal: 800 pixels total
   // display 640 pixels per line
   reg hblank,vblank;
   wire hsyncon,hsyncoff,hreset,hblankon;
   assign hblankon = (hcount_out == (DISPLAY_WIDTH -1));    
   assign hsyncon = (hcount_out == (DISPLAY_WIDTH + H_FP - 1));  //655
   assign hsyncoff = (hcount_out == (DISPLAY_WIDTH + H_FP + H_SYNC_PULSE - 1));  // 751
   assign hreset = (hcount_out == (DISPLAY_WIDTH + H_FP + H_SYNC_PULSE + H_BP - 1));  //799

   // vertical: 524 lines total
   // display 480 lines
   wire vsyncon,vsyncoff,vreset,vblankon;
   assign vblankon = hreset & (vcount_out == (DISPLAY_HEIGHT - 1));   // 479 
   assign vsyncon = hreset & (vcount_out == (DISPLAY_HEIGHT + V_FP - 1));  // 490
   assign vsyncoff = hreset & (vcount_out == (DISPLAY_HEIGHT + V_FP + V_SYNC_PULSE - 1));  // 492
   assign vreset = hreset & (vcount_out == (DISPLAY_HEIGHT + V_FP + V_SYNC_PULSE + V_BP - 1)); // 523

   // sync and blanking
   wire next_hblank,next_vblank;
   assign next_hblank = hreset ? 0 : hblankon ? 1 : hblank;
   assign next_vblank = vreset ? 0 : vblankon ? 1 : vblank;
   always_ff @(posedge vclock_in) begin
      hcount_out <= hreset ? 0 : hcount_out + 1;
      hblank <= next_hblank;
      hsync_out <= hsyncon ? 0 : hsyncoff ? 1 : hsync_out;  // active low

      vcount_out <= hreset ? (vreset ? 0 : vcount_out + 1) : vcount_out;
      vblank <= next_vblank;
      vsync_out <= vsyncon ? 0 : vsyncoff ? 1 : vsync_out;  // active low

      blank_out <= next_vblank | (next_hblank & ~hreset);
   end
   
endmodule


///////////////////////////////////////////////////////////////////////////////
//
// Pushbutton Debounce Module (video version - 24 bits)  
//
///////////////////////////////////////////////////////////////////////////////
module debounce (input reset_in, clock_in, noisy_in,
                 output reg clean_out);
   reg [19:0] count;
   reg new_input;

   always_ff @(posedge clock_in)
     if (reset_in) begin 
        new_input <= noisy_in; 
        clean_out <= noisy_in; 
        count <= 0; end
     else if (noisy_in != new_input) begin new_input<=noisy_in; count <= 0; end
     else if (count == 650000) clean_out <= new_input;
     else count <= count+1;
endmodule
