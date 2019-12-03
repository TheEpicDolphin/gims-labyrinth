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
	
	output logic processed_pixel,
	output logic done									// flag for when erosion is done
    );
	
	logic [K*K-1:0] window;								// window into original image for kernel
	logic [(K-1)*IMG_W + K - 1: 0] pixel_buffer;	// buffer of relevant pixels
	logic [17:0] pixel_counter;							// # of pixels we have received since start
	logic [1:0] state;
	logic buffer_full;									// have enough pixels in buffer to start eroding
	logic in_bounds;								    // kernel is in bounds
	integer i;											// used to build window
	integer j;											// used to build window
	
	logic [8:0] center_x;								// x location of the center pixel of the window
	logic [7:0] center_y;								// y location of the center pixel of the window
	logic [8:0] latest_pixel_x;							// x location of the latest pixel we have received
	logic [7:0] latest_pixel_y;							// y location of the latest pixel we have received
	integer half_k = K >> 1;							// half width of kernel
	integer center_idx = (K*K) >> 1;					// index into window of center pixel of the window

	parameter IDLE = 2'b00;
	parameter ERODING = 2'b01;
	parameter DONE = 2'b11;
	
	assign buffer_full = pixel_counter >= (K-1)*IMG_W + K;
	
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
		//buffer_full = pixel_counter >= (K * K);
		
		// logic for getting center_x and center_y
		center_x  = latest_pixel_x - half_k;
		center_y = latest_pixel_y - half_k;
	end

    
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
                        state <= ERODING;
                        pixel_counter <= 18'b1;
						latest_pixel_x <= 9'b0;
						latest_pixel_y <= 8'b0;
                    end
                end
                ERODING: begin
                    pixel_counter <= pixel_counter + 1;
					state <= (latest_pixel_x == (IMG_W - 1) && latest_pixel_y == (IMG_H - 1)) ? DONE : ERODING;
					if(latest_pixel_x == (IMG_W - 1)) begin
						latest_pixel_x <= 9'b0;
						latest_pixel_y <= latest_pixel_y + 1;
					end else
						latest_pixel_x <= latest_pixel_x + 1;
                end
                DONE: begin
                    state <= IDLE;
                end
            endcase
        end
    end
    
endmodule
