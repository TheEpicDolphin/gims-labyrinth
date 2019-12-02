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


module erosion #(K = 5, IMG_WIDTH=320, IMG_HEIGHT=240)(
    input clk,
	input rst,
	input start,
	input pixel_in,
	
	output processed_pixel,
	output logic done									// flag for when erosion is done
    );
	
	logic [K*K-1:0] window;								// window into original image
	logic [(K-1)*IMG_WIDTH + K - 1: 0] pixel_buffer;	// buffer of relevant pixels
	logic [17:0] pixel_counter;							// # of pixels we have received since start
	logic [1:0] state;
	logic buffer_full;									// safe to start eroding
	logic out_of_bounds;								// kernel is out_of_bounds
	integer i;
	integer j;
	
	logic [] center_x;									// x location of the center pixel of the window
	logic [] center_y;									// y location of the center pixel of the window
	integer half_k = K >> 1;							// half width of kernel
	integer center_idx = (K*K) >> 1;					// index into window of center pixel of the window

	parameter IDLE = 2'b00;
	parameter ERODING = 2'b01;
	parameter DONE = 2'b11;
	
	always_comb begin
		done = state == DONE;
		// this constructs the window from our pixel buffer
		for(i = 0; i < K; i = i + 1) begin
			for(j = 0; j < K; j = j + 1) begin
				window[i*K + j] = pixel_buffer[i*IMG_WIDTH+j];
			end
		end
		done = (state == DONE);
		out_of_bounds = center_x < half_k || center_x > (IMG_WIDTH - 1 - half_k) || center_y < half_k || center_y > (IMG_HEIGHT - 1 - half_k);
		processed_pixel = out_of_bounds ? window[center_idx] : &window;
		buffer_full = pixel_counter >= (K * K);
		
		// logic for getting center_x and center_y
		// NEED TO IMPLEMENT!!!
	end

    
    always_ff @(posedge clk)begin
        if(rst)begin
            state <= IDLE;
			buffer_full <= 1'b0;
			pixel_counter <= 18'b0;
			pixel_buffer <= 0;
        end
        else begin
            pixel_buffer <= pixel_buffer << 1;
			pixel_buffer[0] <= pixel_in;
            case(state)
                IDLE: begin
                    if(start)begin
                        state <= ERODING_PIXEL;
                        pixel_counter <= 18'b1;
                    end
                end
                ERODING: begin
                    pixel_counter <= pixel_counter + 1;
					state <= (center_x == (IMG_WIDTH - 1) && center_y == (IMG_HEIGHT - 1)) ? DONE : ERODING;
                end
                DONE: begin
                    state <= IDLE;
                end
            endcase
        end
    end
    
endmodule
