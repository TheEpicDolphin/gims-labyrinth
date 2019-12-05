`define SIM 1
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2019 11:53:03 PM
// Design Name: 
// Module Name: erosion
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


module erosion #(K = 5, IMG_W=320, IMG_H=240)(
    input clk,
	input rst,
	input start,
	input pixel_in,
	output pixel_valid,
	output logic processed_pixel,
	output logic done									// flag for when erosion is done
	
    );
	
	logic [K*K-1:0] window;								// window into original image for kernel
	logic [(K-1)*IMG_W + K - 1: 0] pixel_buffer;	// buffer of relevant pixels
	logic [17:0] pixel_counter;							// # of pixels we have received since start
	logic [1:0] state;
	logic in_bounds;								    // kernel is in bounds
	integer i;											// used to build window
	integer j;											// used to build window
	
	logic [8:0] center_x;								// x location of the center pixel of the window
	logic [7:0] center_y;								// y location of the center pixel of the window
	integer half_k = K >> 1;							// half width of kernel
	integer center_idx = (K*K) >> 1;					// index into window of center pixel of the window

	parameter IDLE = 2'b00;
	parameter DELAY = 2'b01;
	parameter ERODING = 2'b10;
	parameter DONE = 2'b11;
	
	//assign pixel_valid = pixel_counter >= (((K-1)*IMG_W + K - 1) >> 1);
	assign pixel_valid = state == ERODING;
	always_comb begin
		done = (state == DONE);
		// this constructs the window from our pixel buffer
		for(i = 0; i < K; i = i + 1) begin
			for(j = 0; j < K; j = j + 1) begin
				window[i*K + j] = pixel_buffer[i*IMG_W+j];
			end
		end
		in_bounds = center_x >= half_k && center_x <= (IMG_W - 1 - half_k) && center_y >= half_k && center_y <= (IMG_H - 1 - half_k);
		
		processed_pixel = in_bounds ? &window : 1'b0;	// change to window[center_idx] if we want to pass through
	end

    `ifdef SIM
    integer bin_maze_eroded_f;
    `endif
    
    always_ff @(posedge clk)begin
        if(rst)begin
            state <= IDLE;
			pixel_counter <= 18'b0;
			pixel_buffer <= 0;
        end
        else begin
			pixel_buffer <= {pixel_buffer[(K-1)*IMG_W + K - 2:0], pixel_in};
            case(state)
                IDLE: begin
                    if(start)begin
                        state <= DELAY;
                        pixel_counter <= 18'b1;
                    end
                end
                DELAY: begin
                    pixel_counter <= pixel_counter + 1;
                    if(pixel_counter >= (((K-1)*IMG_W + K - 1) >> 1))begin
                        state <= ERODING;
                        center_x <= 9'b0;
                        center_y <= 8'b0;
                        `ifdef SIM
                        bin_maze_eroded_f = $fopen("C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/python_stuff/verilog_testing/bin_maze_eroded_img.txt","w");
                        `endif
                        
                    end
                end
                ERODING: begin
                    `ifdef SIM
                    $fwrite(bin_maze_eroded_f,"%b\n",processed_pixel);
                    `endif
                    
                    pixel_counter <= pixel_counter + 1;
					state <= (center_x == (IMG_W - 1) && center_y == (IMG_H - 1)) ? DONE : ERODING;
					if(center_x == (IMG_W - 1)) begin
						center_x <= 9'b0;
						center_y <= center_y + 1;
					end else
						center_x <= center_x + 1;
                end
                DONE: begin
                    state <= IDLE;
                    `ifdef SIM
                    $fclose(bin_maze_eroded_f);
                    `endif
                end
            endcase
        end
    end
    
endmodule
