
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
`timescale 1ns / 1ps

module top_level(
   input clk_100mhz,
   input[15:0] sw,
   input btnc, btnu, btnl, btnr, btnd,
   input [7:0] ja,
   input [2:0] jb,
   output   jbclk,
   input [2:0] jd,
   output   jdclk,
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
    logic clk_25mhz;
    // create 25mhz system clock, happens to match 640 x 480 VGA timing
    clk_wiz_0 clkdivider(.reset(0),.clk_in1(clk_100mhz), .clk_out1(clk_25mhz));

    wire [9:0] hcount;    // pixel on current line
    wire [9:0] vcount;     // line number
    wire hsync, vsync, blank;
    wire [11:0] pixel;
    reg [11:0] rgb;    
    vga vga1(.vclock_in(clk_25mhz),.hcount_out(hcount),.vcount_out(vcount),
          .hsync_out(hsync),.vsync_out(vsync),.blank_out(blank));


    // btnc button is user reset
    wire reset;
    wire reset_cam;
    wire up,down;
    debounce db1(.reset_in(0),.clock_in(clk_25mhz),.noisy_in(btnc),.clean_out(reset));         
     
    logic xclk;
    
    logic pclk_buff, pclk_in;
    debounce db2(.reset_in(0),.clock_in(pclk_in),.noisy_in(btnc),.clean_out(reset_cam));
    logic vsync_buff, vsync_in;
    logic href_buff, href_in;
    logic[7:0] pixel_buff, pixel_in;
    
    logic [15:0] output_pixels;
    logic [15:0] old_output_pixels;
    logic [12:0] processed_pixels;
    logic valid_pixel;
    logic frame_done_out;
    
    logic [16:0] pixel_addr_in;
    logic [16:0] pixel_addr_out;
    
    assign xclk = clk_25mhz;    //changed by viv
    assign jbclk = xclk;
    assign jdclk = xclk;

    
    parameter IMG_W = 320;
    parameter IMG_H = 240;
    
    parameter IDLE = 3'b000;
    parameter CAPTURE_IMAGE = 3'b001;
    parameter BINARY_MAZE_FILTERING = 3'b010;
    parameter SKELETONIZING = 3'b011;
    
    parameter FIND_END_NODES = 3'b100;
    parameter SOLVING = 3'b101;
    parameter TRACING_BACKPOINTERS = 3'b110;

    logic [2:0] state;
    logic [1:0] cam_state;
    wire [31:0] data;      //  instantiate 7-segment display; display (8) 4-bit hex
    wire [6:0] segments;
    assign {cg, cf, ce, cd, cc, cb, ca} = segments[6:0];
    display_8hex display(.clk_in(clk_25mhz),.data_in(data), .seg_out(segments), .strobe_out(an));
    //assign seg[6:0] = segments;
    assign  dp = 1'b1;  // turn off the period

    assign led = sw;                        // turn leds on
    assign data = {14'b0, cam_state, 13'b0, state};   // display 0123456 + sw[3:0]
    assign led16_r = btnl;                  // left button -> red led
    assign led16_g = btnc;                  // center button -> green led
    assign led16_b = btnr;                  // right button -> blue led
    assign led17_r = btnl;
    assign led17_g = btnc;
    assign led17_b = btnr;
    
    logic [16:0] cam_pixel_wr_addr;
    logic [16:0] cam_pixel_r_addr;
    
    logic cam_pixel_we;
    logic [11:0] rgb_pixel;
    
    cam_image_buffer cam_img_buf(.clka(pclk_in),
                                .addra(cam_pixel_wr_addr),
                                .dina({output_pixels[15:12],output_pixels[10:7],output_pixels[4:1]}),
                                .wea(cam_pixel_we),
                                .clkb(clk_25mhz),
                                .addrb(cam_pixel_r_addr),
                                .doutb(rgb_pixel));
    
    logic [16:0] bin_pixel_wr_addr;
    logic bin_pixel_in;
    logic bin_pixel_we;
    logic [16:0] bin_pixel_r_addr;
    logic bin_pixel_out;
                                    
    binary_maze skel_maze(.clka(clk_25mhz),
                          .addra(bin_pixel_wr_addr),
                          .dina(bin_pixel_in),
                          .wea(bin_pixel_we),
                          .clkb(clk_25mhz),
                          .addrb(bin_pixel_r_addr),
                          .doutb(bin_pixel_out)
                          );
    logic bin_maze_filt_start;
    logic bin_maze_filt_done;
    logic [16:0] filt_pixel_wr_addr;
    logic filt_pixel;
    logic filt_pixel_we;
    logic [16:0] filt_pixel_r_addr;
        
    binary_maze_filtering #(.IMG_W(IMG_W),.IMG_W(IMG_H)) bin_maze_filt
        (
         .clk(clk_25mhz),
         .rst(reset),
         .start(bin_maze_filt_start),
         .rgb_pixel(rgb_pixel),  
         .cam_pixel_r_addr(filt_pixel_r_addr), 
         .done(bin_maze_filt_done),
         .pixel_wr_addr(filt_pixel_wr_addr),
         .pixel_wea(filt_pixel_we),
         .pixel_out(filt_pixel)
         );
    
    logic start_skeletonizer;
    logic skeletonizer_done;
    logic [16:0] skel_pixel_wr_addr;
    logic skel_pixel;
    logic skel_pixel_we;
    logic [16:0] skel_pixel_r_addr;
    skeletonizer #(.IMG_WIDTH(IMG_W),.IMG_HEIGHT(IMG_H),.BRAM_READ_DELAY(2)) skel
    (
             .clk(clk_25mhz),
             .rst(reset),
             .start(start_skeletonizer),
             .pixel_in(bin_pixel_out),
             .pixel_r_addr(skel_pixel_r_addr),
             .pixel_wr_addr(skel_pixel_wr_addr),
             .pixel_we(skel_pixel_we),
             .pixel_out(skel_pixel),
             .done(skeletonizer_done)
             );
             
    logic start_find_end_nodes;
    logic find_end_nodes_done;
    logic colored_maze_filt_done;
    logic [16:0] start_pos;
    logic [16:0] end_pos;
    logic [16:0] maze_r_addr;
    find_end_nodes #(.IMG_W(IMG_W),.IMG_H(IMG_H),.BRAM_READ_DELAY(2)) fse
        (
            .clk(clk_25mhz),
            .rst(reset),
            .start(start_find_end_nodes),
            .rgb_pixel(rgb_pixel),
            .skel_pixel(bin_pixel_out),
            .maze_r_addr(maze_r_addr),
            .start_pos(start_pos),
            .end_pos(end_pos),
            .done(find_end_nodes_done)
        );
    
    
    logic start_lees_alg;
    logic lees_alg_done;
    logic [16:0] bp_wr_addr;
    logic [1:0] bp;
    logic bp_we;
    logic [16:0] solver_pixel_r_addr;
                       
    pixel_backpointers p_bp(.clka(clk_25mhz),
                            .addra(bp_wr_addr),
                            .dina(bp),
                            .wea(bp_we),
                            .clkb(clk_25mhz),
                            .addrb(bp_tracer_addr),
                            .doutb(backpointer_r));
    
    
                 
    lees_algorithm #(.MAX_OUT_DEGREE(4),.BRAM_DELAY_CYCLES(2),
                     .IMG_W(IMG_W),.IMG_H(IMG_H)) maze_solver
                 (
                  .clk(clk_25mhz),
                  .rst(reset),
                  .start(start_lees_alg),
                  .start_pos(start_pos),
                  .skel_pixel(bin_pixel_out),
                  .pixel_r_addr(solver_pixel_r_addr),
                  .pixel_wr_addr(bp_wr_addr),
                  .backpointer(bp),
                  .bp_we(bp_we),
                  .done(lees_alg_done)
                  );
                  
    /*
    backpointer_tracer #(.BRAM_DELAY_CYCLES(2),.IMG_W(IMG_W),.IMG_H(IMG_H)) bp_tracer(
                      .clk(clk_25mhz),
                      .rst(rst),
                      .start(start_bp_tracer),
                      .start_pos(start_pos),
                      .end_pos(end_pos),
                      .bp(backpointer_r),
                      .pixel_addr(bp_tracer_addr),
                      .write_path(write_path),
                      .done(bp_tracer_done)
                      );
    
    path_bram pb(.clka(clk_25mhz),
                 .addra(bp_tracer_addr),
                 .dina(write_path),
                 .wea(write_path));   
    */
    
    logic [16:0] fpga_read_addr;
    
    always_comb begin
        case(state)
            BINARY_MAZE_FILTERING: begin
                bin_pixel_wr_addr = filt_pixel_wr_addr;
                bin_pixel_in = filt_pixel;
                bin_pixel_we = filt_pixel_we;
                cam_pixel_r_addr = filt_pixel_r_addr;
            end
            SKELETONIZING: begin
                bin_pixel_wr_addr = skel_pixel_wr_addr;
                bin_pixel_in = skel_pixel;
                bin_pixel_we = skel_pixel_we;
                bin_pixel_r_addr = skel_pixel_r_addr;
            end
            IDLE: begin
                bin_pixel_r_addr = fpga_read_addr;
            end
            FIND_END_NODES: begin
                cam_pixel_r_addr = maze_r_addr;
                bin_pixel_r_addr = maze_r_addr;
            end
            SOLVING: begin
                bin_pixel_r_addr = solver_pixel_r_addr;
            end
            
        endcase
    end
    
    logic frame_done;                   
    always_ff @(posedge clk_25mhz)begin
        if(reset)begin
            state <= IDLE;
        end
        else begin
            case(state)
                IDLE: begin                                    
                    if(frame_done)begin
                        //Wait for camera to finish current incomplete frame
                        state <= CAPTURE_IMAGE;
                    end
                end
                CAPTURE_IMAGE: begin
                    if(frame_done)begin
                        //camera image is now stored in bram
                        state <= BINARY_MAZE_FILTERING;
                        bin_maze_filt_start <= 1;
                    end
                end
                BINARY_MAZE_FILTERING: begin
                    bin_maze_filt_start <= 0;
                    if(bin_maze_filt_done)begin
                        state <= SKELETONIZING;
                        start_skeletonizer <= 1;
                    end
                end
                SKELETONIZING: begin
                    start_skeletonizer <= 0;
                    //get stuck in here for now
                    if(skeletonizer_done)begin
                        state <= FIND_END_NODES;
                        start_find_end_nodes <= 1;
                    end
                end
                FIND_END_NODES: begin
                    start_find_end_nodes <= 0;
                    if(find_end_nodes_done)begin
                        state <= SOLVING;
                        start_lees_alg <= 1;
                    end
                end
                SOLVING: begin
                    start_lees_alg <= 0;
                    if(lees_alg_done)begin
                        state <= TRACING_BACKPOINTERS;
                    end
                end
                TRACING_BACKPOINTERS: begin
                    state <= IDLE;
                end
            endcase
        end
    end
    
    logic frame_done_buff;
    always_ff @(posedge clk_25mhz) begin
        if(reset)begin
            frame_done_buff <= 0;
            frame_done <= 0;
        end
        else begin
            //Comes from camera sensor
            pclk_buff <= jb[0];//WAS JB
            vsync_buff <= jb[1]; //WAS JB
            href_buff <= jb[2]; //WAS JB
            pixel_buff <= ja;
                
            pclk_in <= pclk_buff;
            vsync_in <= vsync_buff;
            href_in <= href_buff;
            pixel_in <= pixel_buff;
                
            frame_done_buff <= frame_done_out;
            frame_done <= frame_done_buff;
        end
        
    end
    
    logic sync_state;
    logic state_buff;
    always_ff @(posedge pclk_in) begin
        if(reset_cam)begin
            sync_state <= IDLE;
            state_buff <= IDLE;
        end
        else begin
            state_buff <= state;
            sync_state <= state_buff;
            if(frame_done_out)begin
                cam_pixel_wr_addr <= 0;
            end
            else if(valid_pixel)begin
                cam_pixel_wr_addr <= cam_pixel_wr_addr + 1; 
            end
        end
        
    end
    
    assign cam_pixel_we = valid_pixel && (sync_state == CAPTURE_IMAGE);
    
    camera_read  my_camera(.p_clock_in(pclk_in),
                            .rst(reset),
                          .vsync_in(vsync_in),
                          .href_in(href_in),
                          .p_data_in(pixel_in),
                          .pixel_data_out(output_pixels),
                          .pixel_valid_out(valid_pixel),
                          .frame_done_out(frame_done_out),
                          .FSM_state(cam_state));
       

    wire border = (hcount==0 | hcount==639 | vcount==0 | vcount==479 |
                   hcount == 320 | vcount == 240);

    reg b,hs,vs;
    always_ff @(posedge clk_25mhz) begin
      if(reset)begin
        
      end
      else begin
          if (sw[1:0] == 2'b01) begin
             // 1 pixel outline of visible area (white)
             hs <= hsync;
             vs <= vsync;
             b <= blank;
             rgb <= {12{border}};
          end 
          else if (sw[1:0] == 2'b10) begin
             // color bars
             hs <= hsync;
             vs <= vsync;
             b <= blank;
             rgb <= {{4{hcount[7]}}, {4{hcount[6]}}, {4{hcount[5]}}} ;
          end 
          else begin
             
             hs <= hsync;
             vs <= vsync;
             b <= blank;
             
             if(state == IDLE)begin
                fpga_read_addr <= (hcount>>1)+ ((vcount>>1) * IMG_W);
                rgb <= bin_pixel_out ? 12'hFFF : 12'b0;
             end
             
           end
      end

    end

    // the following lines are required for the Nexys4 VGA circuit - do not change
    assign vga_r = ~b ? rgb[11:8]: 0;
    assign vga_g = ~b ? rgb[7:4] : 0;
    assign vga_b = ~b ? rgb[3:0] : 0;

    assign vga_hs = ~hs;
    assign vga_vs = ~vs;

endmodule

////////////////////////////////////////////////////////////////////////////////
//
// camera_read
//
////////////////////////////////////////////////////////////////////////////////

module camera_read(
	input  p_clock_in,
	input rst,
	input  vsync_in,
	input  href_in,
	input  [7:0] p_data_in,
	output logic [15:0] pixel_data_out,
	output logic pixel_valid_out,
	output logic frame_done_out,
	output logic [1:0] FSM_state
    );
	 
	
	//logic [1:0] FSM_state = 0;
    logic pixel_half = 0;
	
	localparam WAIT_FRAME_START = 0;
	localparam ROW_CAPTURE = 1;
	
	
	always_ff@(posedge p_clock_in) begin
	    if(rst)begin
	       FSM_state <= WAIT_FRAME_START;
	    end
	    else begin
	       case(FSM_state)
                    WAIT_FRAME_START: begin //wait for VSYNC
                       FSM_state <= (!vsync_in) ? ROW_CAPTURE : WAIT_FRAME_START;
                       frame_done_out <= 0;
                       pixel_half <= 0;
                    end
                    
                    ROW_CAPTURE: begin 
                       FSM_state <= vsync_in ? WAIT_FRAME_START : ROW_CAPTURE;
                       frame_done_out <= vsync_in ? 1 : 0;
                       pixel_valid_out <= (href_in && pixel_half) ? 1 : 0; 
                       if (href_in) begin
                           pixel_half <= ~ pixel_half;
                           if (pixel_half) pixel_data_out[7:0] <= p_data_in;
                           else pixel_data_out[15:8] <= p_data_in;
                       end
                    end
                endcase
	    end
        
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

//   always_ff @(posedge clock_in)
//     if (reset_in) begin new <= noisy_in; clean_out <= noisy_in; count <= 0; end
//     else if (noisy_in != new) begin new <= noisy_in; count <= 0; end
//     else if (count == 200000) clean_out <= new;
//     else count <= count+1;

   always_ff @(posedge clock_in)
     if (reset_in) begin 
        new_input <= noisy_in; 
        clean_out <= noisy_in; 
        count <= 0; end
     else if (noisy_in != new_input) begin new_input<=noisy_in; count <= 0; end
     else if (count == 200000) clean_out <= new_input;
     else count <= count+1;


endmodule

//////////////////////////////////////////////////////////////////////////////////
// Engineer:   g.p.hom
// 
// Create Date:    18:18:59 04/21/2013 
// Module Name:    display_8hex 
// Description:  Display 8 hex numbers on 7 segment display
//
//////////////////////////////////////////////////////////////////////////////////

module display_8hex(
    input clk_in,                 // system clock
    input [31:0] data_in,         // 8 hex numbers, msb first
    output reg [6:0] seg_out,     // seven segment display output
    output reg [7:0] strobe_out   // digit strobe
    );

    localparam bits = 13;
     
    reg [bits:0] counter = 0;  // clear on power up
     
    wire [6:0] segments[15:0]; // 16 7 bit memorys
    assign segments[0]  = 7'b100_0000;  // inverted logic
    assign segments[1]  = 7'b111_1001;  // gfedcba
    assign segments[2]  = 7'b010_0100;
    assign segments[3]  = 7'b011_0000;
    assign segments[4]  = 7'b001_1001;
    assign segments[5]  = 7'b001_0010;
    assign segments[6]  = 7'b000_0010;
    assign segments[7]  = 7'b111_1000;
    assign segments[8]  = 7'b000_0000;
    assign segments[9]  = 7'b001_1000;
    assign segments[10] = 7'b000_1000;
    assign segments[11] = 7'b000_0011;
    assign segments[12] = 7'b010_0111;
    assign segments[13] = 7'b010_0001;
    assign segments[14] = 7'b000_0110;
    assign segments[15] = 7'b000_1110;
     
    always_ff @(posedge clk_in) begin
      // Here I am using a counter and select 3 bits which provides
      // a reasonable refresh rate starting the left most digit
      // and moving left.
      counter <= counter + 1;
      case (counter[bits:bits-2])
          3'b000: begin  // use the MSB 4 bits
                  seg_out <= segments[data_in[31:28]];
                  strobe_out <= 8'b0111_1111 ;
                 end

          3'b001: begin
                  seg_out <= segments[data_in[27:24]];
                  strobe_out <= 8'b1011_1111 ;
                 end

          3'b010: begin
                   seg_out <= segments[data_in[23:20]];
                   strobe_out <= 8'b1101_1111 ;
                  end
          3'b011: begin
                  seg_out <= segments[data_in[19:16]];
                  strobe_out <= 8'b1110_1111;        
                 end
          3'b100: begin
                  seg_out <= segments[data_in[15:12]];
                  strobe_out <= 8'b1111_0111;
                 end

          3'b101: begin
                  seg_out <= segments[data_in[11:8]];
                  strobe_out <= 8'b1111_1011;
                 end

          3'b110: begin
                   seg_out <= segments[data_in[7:4]];
                   strobe_out <= 8'b1111_1101;
                  end
          3'b111: begin
                  seg_out <= segments[data_in[3:0]];
                  strobe_out <= 8'b1111_1110;
                 end

       endcase
      end

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
