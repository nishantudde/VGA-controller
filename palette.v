module palette(
				input wire [7:0] colour_in,
				output wire [11:0] colour_out
				);
				
assign colour_out = {colour_in[7:5], colour_in[5],
							colour_in[4:2], colour_in[2],
							colour_in[1:0], colour_in[0], colour_in[7:5]};

endmodule