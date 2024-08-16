module vga_sync(
						input wire clk, reset,
						output wire hsync_i, vsync_i, video_on_i, p_tick,
						output wire [9:0] pixel_x, pixel_y
					);
					

localparam HD = 640; //Horizontal line
localparam HF = 16 ; //Horizontal front porch
localparam HB = 48 ; //Horizontal back porch
localparam HR = 96 ; //Horizontal retrace

localparam VD = 480; //Vertical line
localparam VF = 10;	//vertical front porch
localparam VB = 33;	//Vertical back porch
localparam VR = 2;	//Vertical retrace

// mod—2 counter - Its use?
reg mod2_reg;
wire mod2_next;

// sync counters
reg [9:0] h_count_reg, h_count_next;
reg [9:0] v_count_reg, v_count_next;

// status signal
wire h_end , v_end, pixel_tick;

always @(posedge clk, posedge reset) begin //Sync Reset

	if (reset) begin //Set counter values to zero
		
		mod2_reg <= 1'b0;
		v_count_reg <= 0;
		h_count_reg <= 0;
		
	end
	
	else begin
	
		mod2_reg <= mod2_next;
		v_count_reg <= v_count_next;
		h_count_reg <= h_count_next;
		
	end
end

// mod—2 circuit to generate 25 MHz enable tick
assign mod2_next = mod2_reg;
assign pixel_tick = mod2_reg;

// status signals
// end of horizontal counter (799)
assign h_end = (h_count_reg==(HD+HF+HB+HR-1));

// end of vertical counter (524)
assign v_end = (v_count_reg==(VD+VF+VB+VR-1));


// next —state logic of mod—800 horizontal sync counter
always@(*) begin

	if (pixel_tick) begin // 25 MHz pulse
		if (h_end) h_count_next = 0;
		else h_count_next = h_count_reg + 1;
	end
	else h_count_next = h_count_reg;
	
end
	
always@(*) begin
	if (pixel_tick & h_end)
		if (v_end)
			v_count_next = 0;
		else
			v_count_next = v_count_reg + 1;
	else
		v_count_next = v_count_reg;

end
		
assign hsync_i = h_count_reg<(HD+HF) || h_count_reg>(HD+HF+HR-1); //Asserted between ???
assign vsync_i = v_count_reg<(VD+VF) || v_count_reg>(VD+VF+VR-1); //Asserted between ???

assign video_on_i = (h_count_reg<HD) && (v_count_reg<VD);

//output
assign pixel_x = h_count_reg;
assign pixel_y = v_count_reg;
assign p_tick = pixel_tick;

endmodule
	