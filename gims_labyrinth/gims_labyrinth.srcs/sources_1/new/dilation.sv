`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2019 11:53:22 PM
// Design Name: 
// Module Name: dilation
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


module dilation #(K = 5, IMG_W=320, IMG_H=240)(
    input clk,
	input rst,
	input start,
	input pixel_in,
	
	output logic pixel_addr,
	output logic processed_pixel,
	output logic pixel_valid,
	output logic done									// flag for when erosion is done
    );
	
	logic [(K-1)*IMG_W + K - 1: 0] pixel_buffer;	        // buffer of relevant pixels
    logic [(K-1)*IMG_W + K - 1: 0] pixel_buffer_dilated;    // buffer of relevant pixels after modification by dilation
    logic [(K-1)*IMG_W + K - 1: 0] temp;    
	logic [17:0] pixel_counter;							// # of pixels we have received since start
	logic [1:0] state;
	logic buffer_full;									// have enough pixels in buffer to start eroding
	integer i;											// used to build window
	integer j;											// used to build window
	
						
	logic [8:0] oldest_pixel_x;                         // x location of the oldest pixel we have received
	logic [7:0] oldest_pixel_y;                         // y location of the oldest pixel we have received
	integer half_k = K >> 1;							// half width of kernel
	integer center_idx = (K*K) >> 1;					// index into window of center pixel of the window
	
	logic [(K-1)*IMG_W + K - 1: 0] dilation_mask;

	parameter IDLE = 2'b00;
	parameter DELAY = 2'b01;
	parameter DILATING = 2'b10;
	parameter DONE = 2'b11;
	
	assign buffer_full = pixel_counter >= (K-1)*IMG_W + K;
	
	assign pixel_valid = (state == DILATING);
	assign done = (state == DONE);
	
	always_comb begin
		// this constructs the window from our pixel buffer
		dilation_mask = 0;
		for(i = 0; i < K; i = i + 1) begin
			for(j = 0; j < K; j = j + 1) begin
			    //dilation_mask[i*IMG_W+j] = pixel_buffer[((K-1)*IMG_W + K - 1) >> 1];
			    dilation_mask[i*IMG_W+j] = pixel_buffer[2*IMG_W + 2];
			end
		end
		
		temp = pixel_buffer_dilated | dilation_mask;
		processed_pixel = temp[(K-1)*IMG_W + K - 1];
		pixel_addr = pixel_counter - ((K-1)*IMG_W + K);

	end

    integer bin_maze_dilated_f;
    always_ff @(posedge clk)begin
        if(rst)begin
            state <= IDLE;
			pixel_counter <= 18'b0;
			pixel_buffer <= 0;
			pixel_buffer_dilated <= 0;
        end
        else begin
			pixel_buffer <= {pixel_buffer[(K-1)*IMG_W + K - 2:0], pixel_in};
			pixel_buffer_dilated <= {temp[(K-1)*IMG_W + K - 2:0], pixel_in};
            case(state)
                IDLE: begin
                    if(start)begin
                        state <= DELAY;
                        pixel_counter <= 18'b1;
                    end
                end
                DELAY: begin
                    pixel_counter <= pixel_counter + 1;
                    if(pixel_counter >= ((K-1)*IMG_W + K - 1) >> 1)begin
                        state <= DILATING;
                        oldest_pixel_x <= 9'b0;
                        oldest_pixel_y <= 8'b0;
                        bin_maze_dilated_f = $fopen("C:/Users/giand/Documents/MIT/Senior_Fall/6.111/gims-labyrinth/gims_labyrinth/python_stuff/verilog_testing/bin_maze_dilated_img.txt","w");
                    end
                end
                DILATING: begin
                    $fwrite(bin_maze_dilated_f,"%b\n",processed_pixel);
                    pixel_counter <= pixel_counter + 1;
					if(oldest_pixel_x == (IMG_W - 1) && oldest_pixel_y == (IMG_H - 1))begin
					   state <= DONE;
					end
					if(oldest_pixel_x == (IMG_W - 1)) begin
						oldest_pixel_x <= 9'b0;
						oldest_pixel_y <= oldest_pixel_y + 1;
					end 
					else begin
						oldest_pixel_x <= oldest_pixel_x + 1;
				    end
                end
                DONE: begin
                    $fclose(bin_maze_dilated_f);
                    state <= IDLE;
                end
            endcase
        end
    end
    
endmodule
