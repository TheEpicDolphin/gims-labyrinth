`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2019 11:29:15 PM
// Design Name: 
// Module Name: skeletonizer
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


module skeletonizer #(IMG_WIDTH=320, IMG_HEIGHT=240, BRAM_READ_DELAY=2)(
    input clk,
    input rst,
    input start,
    input pixel_in,										// read data from bram
    
    output logic [16:0] pixel_r_addr,
    output logic [16:0] pixel_wr_addr,
	output logic pixel_we,							// bram write enable
	output logic pixel_out,								// write data to bram
    
    output logic done
    );
    
    parameter IDLE = 2'b00;
    parameter INITIAL_READ_DELAY = 2'b01;
    parameter SKELETONIZING = 2'b10;
    parameter DONE = 2'b11;
    
    
    logic [2*IMG_WIDTH + 2:0] unmod_pixel_buffer, mod_pixel_buffer, temp;
	logic [8:0] unmod_window, mod_window;
	logic [7:0] disc_check_buffer1, disc_check_buffer2;	//used to check for discontinuity
	logic [7:0] xored_disc_buffers;
	logic [3:0] num_transitions;						// number of transitions for discontinuity check
	logic causes_discontinuity;
	
	logic [1:0] state;
	logic changes_made;									// flag to see if changes were made while skeletonizing
	integer i;
	integer j;
    
	logic [8:0] center_x;								// x location of the center pixel of the windows
	logic [7:0] center_y;								// y location of the center pixel of the windows
	
	logic h0, h1, h2, h3, h4, h5, h6, h7, h0_7;
	logic skeletonized_pixel;
	integer skel_maze_f;
    
    always_comb begin
		//This constructs the windows from our pixel buffers
		for(i = 0; i < 3; i = i + 1) begin
			for(j = 0; j < 3; j = j + 1) begin
				unmod_window[3*i + j] = unmod_pixel_buffer[i*IMG_WIDTH + j];
				mod_window[3*i + j] = mod_pixel_buffer[i*IMG_WIDTH + j];
			end
		end
		pixel_wr_addr = IMG_WIDTH*center_y + center_x;
		pixel_we = (state == SKELETONIZING);
		done = (state == DONE);
		
		// check for discontinuity
		disc_check_buffer1 = {mod_window[8], mod_window[7], mod_window[6], mod_window[3], mod_window[0], mod_window[1], mod_window[2], mod_window[5]};
		disc_check_buffer2 = {mod_window[7], mod_window[6], mod_window[3], mod_window[0], mod_window[1], mod_window[2], mod_window[5], mod_window[8]};
		xored_disc_buffers = disc_check_buffer1 ^ disc_check_buffer2;
		num_transitions = xored_disc_buffers[7] + xored_disc_buffers[6] + + xored_disc_buffers[5] + xored_disc_buffers[4] +
							xored_disc_buffers[3] + xored_disc_buffers[2] + xored_disc_buffers[1] + xored_disc_buffers[0];
		// flag to see if skeletonizing would cause discontinuity
		causes_discontinuity = num_transitions > 2;
		
		
		// skeletonizing logic
		h0 = (unmod_window[8] == 0) & (unmod_window[5] == 0) & (unmod_window[2] == 0) & (unmod_window[4] == 1) & (unmod_window[6] == 1) 
            & (unmod_window[3] == 1) & (unmod_window[0] == 1);
        h1 = (unmod_window[5] == 0) & (unmod_window[2] == 0) & (unmod_window[1] == 0) & (unmod_window[7] == 1) & (unmod_window[4] == 1) 
            & (unmod_window[3] == 1);
        h2 = (unmod_window[2] == 0) & (unmod_window[1] == 0) & (unmod_window[0] == 0) & (unmod_window[8] == 1) & (unmod_window[7] == 1) 
            & (unmod_window[4] == 1) & (unmod_window[6] == 1);
        h3 = (unmod_window[1] == 0) & (unmod_window[3] == 0) & (unmod_window[0] == 0) & (unmod_window[5] == 1) & (unmod_window[7] == 1) 
            & (unmod_window[4] == 1); 
        h4 = (unmod_window[6] == 0) & (unmod_window[3] == 0) & (unmod_window[0] == 0) & (unmod_window[8] == 1) & (unmod_window[5] == 1) 
            & (unmod_window[2] == 1) & (unmod_window[4] == 1);
        h5 = (unmod_window[7] == 0) & (unmod_window[6] == 0) & (unmod_window[3] == 0) & (unmod_window[5] == 1) & (unmod_window[4] == 1) 
            & (unmod_window[1] == 1);
        h6 = (unmod_window[8] == 0) & (unmod_window[7] == 0) & (unmod_window[6] == 0) & (unmod_window[2] == 1) & (unmod_window[4] == 1) 
            & (unmod_window[1] == 1) & (unmod_window[0] == 1); 
        h7 = (unmod_window[8] == 0) & (unmod_window[5] == 0) & (unmod_window[7] == 0) & (unmod_window[4] == 1) & (unmod_window[1] == 1) 
            & (unmod_window[3] == 1); 
        
        h0_7 = ~(h0 | h1 | h2 | h3 | h4 | h5 | h6 | h7);
        
        skeletonized_pixel = unmod_window[4] & h0_7;
		pixel_out = causes_discontinuity ? unmod_window[4] : skeletonized_pixel;
		
		// combinationally sets the center pixel of temp to be the output pixel (will shift this into mod_pixel_buffer later)
		temp = {mod_pixel_buffer[2*IMG_WIDTH + 2: IMG_WIDTH + 2], pixel_out, mod_pixel_buffer[IMG_WIDTH:0]};
		
    end
    
    always_ff @(posedge clk)begin
        if(rst)begin
            state <= IDLE;
			unmod_pixel_buffer <= 0;
			mod_pixel_buffer <= 0;
        end
        else begin
			// always shift what we read from bram into unmod_pixel_buffer
			unmod_pixel_buffer <= {unmod_pixel_buffer[2*IMG_WIDTH + 1: 0], pixel_in};
			// Update mod_pixel_buffer by shifting temp
            mod_pixel_buffer <=  {temp[2*IMG_WIDTH + 1:0], pixel_in};
            
            case(state)
                IDLE: begin
                    if(start)begin
                        state <= INITIAL_READ_DELAY;
                        pixel_r_addr <= 17'b0;
						changes_made <= 1'b0;
						
                    end
                end
                INITIAL_READ_DELAY: begin
                    // read_address reads from BRAM the value that we will want BRAM_READ_DELAY cycles from now
                    pixel_r_addr <= pixel_r_addr + 1;
					// wait until buffer is half full before starting skeletonization
                    if(pixel_r_addr == ((BRAM_READ_DELAY - 1) + (IMG_WIDTH + 2)))begin
                        center_x <= 9'b0;
                        center_y <= 8'b0;
                        state <= SKELETONIZING;
                        skel_maze_f = $fopen("C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/python_stuff/verilog_testing/maze_skel.txt","w");
                    end
                end
                SKELETONIZING: begin
                    $fwrite(skel_maze_f,"%b\n",pixel_out);
                    //Increment center pixel coordinates
                    if(center_x == IMG_WIDTH - 1)begin
                        center_x <= 9'b0;
                        center_y <= center_y + 1;
                    end
                    else begin
                        center_x <= center_x + 1;
                    end
                    
                    if(pixel_r_addr == IMG_WIDTH * IMG_HEIGHT - 1)begin
                        pixel_r_addr <= 17'b0;
                    end
                    else begin
                        pixel_r_addr <= pixel_r_addr + 1;
                    end
                    
                    //Have processed all the pixels
                    if(center_x == IMG_WIDTH - 1 && center_y == IMG_HEIGHT - 1)begin
						if(changes_made) begin				// repeat if any changes were made
							center_x <= 9'b0;
                            center_y <= 8'b0;
							changes_made <= 1'b0;
							$fclose(skel_maze_f);
							skel_maze_f = $fopen("C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/python_stuff/verilog_testing/maze_skel.txt","w");
						end else begin						// otherwise we are done
							state <= DONE;
							$fclose(skel_maze_f);
						end
                    end
					else begin
						changes_made <= changes_made | (pixel_out != unmod_window[4]);
					end
                end
                DONE: begin
                    state <= IDLE;
                end
            endcase
        end
    end
    
endmodule