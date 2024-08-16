module vga_top (
						input wire clk, reset,
						
						//Avalon MM interface
						input wire [19:0] vga_address,
						input wire vga_chipselect,
						input wire vga_write,
						input wire vga_read,
						input wire [31:0] vga_writedata,
						output wire [31:0] vga_readdata,
						
						//conduit interface (to VGA monitor)
						output wire vsync, hsync,
						output wire [11:0] rgb, //12-bit RGB colour scheme
						output wire [17:0] sram_addr,
						
						//conduit interface (to and from SRAM)
						inout [15:0] sram_dq,
						output sram_ce_n, sram_oe_n, sram_we_n,
						output sram_lb_n, sram_ub_n
						);
						
//signal declarations
reg video_on_reg, vsync_reg , hsync_reg;
wire vsync_i, hsync_i, video_on_i , p_tick;
wire [9:0] pixel_x, pixel_y ;
wire wr_vram, rd_vram;
wire [7:0] cpu_rd_data, vga_rd_data;
wire [11:0] colour;

//body
//*****************************************************
//	module instantiation
//*****************************************************

// Instantiate vga_sync module
vga_sync vga_sync_inst (
    .clk(clk),           // Clock input
    .reset(reset),       // Reset input
	 
    .hsync_i(hsync_i),   // Horizontal sync output
    .vsync_i(vsync_i),   // Vertical sync output
    .video_on_i(video_on_i), // Video on output
    .p_tick(p_tick),     // Pixel tick output
    .pixel_x(pixel_x),   // X coordinate of pixel
    .pixel_y(pixel_y)    // Y coordinate of pixel
);

// Instantiate vram_ctrl module
vram_ctrl vram_ctrl_inst (
    .clk(clk),               // Clock input
    .reset(reset),           // Reset input
    // From video sync
    .pixel_x(pixel_x),       // X coordinate of pixel
    .pixel_y(pixel_y),       // Y coordinate of pixel
    .p_tick(p_tick),         // Pixel tick signal
    // Memory interface to VGA read
    .vga_rd_data(vga_rd_data), // VGA read data
    // Memory interface to GPU
    .cpu_mem_wr(wr_vram), // CPU memory write enable
    .cpu_mem_rd(rd_vram), // CPU memory read enable
    .cpu_addr(vga_address[18:0]),     // CPU address bus
    .cpu_wr_data(vga_writedata[7:0]), // CPU write data bus
    .cpu_rd_data(cpu_rd_data), // CPU read data bus
    // To and From SRAM
    .sram_addr(sram_addr),   // SRAM address bus
    .sram_dq(sram_dq),       // SRAM data bus
    .sram_ce_n(sram_ce_n),   // SRAM chip enable
    .sram_oe_n(sram_oe_n),   // SRAM output enable
    .sram_wr_n(sram_wr_n),   // SRAM write enable
    .sram_lb_n(sram_lb_n),   // SRAM lower byte enable
    .sram_ub_n(sram_ub_n)    // SRAM upper byte enable
);


// Instantiate palette module
palette palette_inst (
    .colour_in(vga_rd_data),    // Input color
    .colour_out(colour)   // Output color
);


//*****************************************************
//registers, wrtie decoding, and read multiplexing
//*****************************************************

//Delay VGA sync to accomodate memory access

always@(posedge clk) begin
	
	if (p_tick) begin
		vsync_reg <= vsync_i;
		hsync_reg <= hsync_i;
		video_on_reg <= video_on_i;
	end
end
	assign vsync = vsync_reg;
	assign hsync = hsync_reg;
	
//memory read/write decoding
	assign wr_vram = vga_write & vga_chipselect & (~vga_address[19]);
	assign rd_vram = vga_read & vga_chipselect & (~vga_address[19]);
	
//read data mux
	assign vga_readdata = (~vga_address[19]) ? {24'b0, cpu_rd_data} : 
															 {12'b0, pixel_y, pixel_x};
															 
//video output
	assign rgb = video_on_reg ? colour : 12'b0;

endmodule