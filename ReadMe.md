### VGA Controller Specifications Summary

#### Inputs:
- **clk**: Clock input signal.
- **reset**: Reset input signal.

#### Avalon MM Interface:
- **vga_address [19:0]**: Address bus for Avalon MM interface.
- **vga_chipselect**: Chip select signal.
- **vga_write**: Write enable signal.
- **vga_read**: Read enable signal.
- **vga_writedata [31:0]**: Data to be written.
- **vga_readdata [31:0]**: Data to be read.

#### Conduit Interface (to VGA Monitor):
- **vsync**: Vertical sync signal.
- **hsync**: Horizontal sync signal.
- **rgb [11:0]**: 12-bit RGB color output.
- **sram_addr [17:0]**: Address bus for SRAM.

#### Conduit Interface (to/from SRAM):
- **sram_dq [15:0]**: Data bus for SRAM (bi-directional).
- **sram_ce_n**: Chip enable (active low).
- **sram_oe_n**: Output enable (active low).
- **sram_we_n**: Write enable (active low).
- **sram_lb_n**: Lower byte enable (active low).
- **sram_ub_n**: Upper byte enable (active low).

#### Internal Signals:
- **vsync_reg, hsync_reg, video_on_reg**: Registers for synchronization signals and video on/off.
- **vsync_i, hsync_i, video_on_i, p_tick**: Intermediate signals for sync and video.
- **pixel_x [9:0], pixel_y [9:0]**: Pixel coordinates.
- **wr_vram, rd_vram**: Write/read enable signals for VRAM.
- **cpu_rd_data [7:0], vga_rd_data [7:0]**: Data signals for CPU and VGA read operations.
- **colour [11:0]**: Color data.

#### Module Instantiations:
1. **vga_sync**:
    - Inputs: clk, reset
    - Outputs: hsync_i, vsync_i, video_on_i, p_tick, pixel_x, pixel_y

2. **vram_ctrl**:
    - Inputs: clk, reset, pixel_x, pixel_y, p_tick, vga_address, vga_writedata
    - Outputs: vga_rd_data, cpu_rd_data, sram_addr, sram_dq, sram_ce_n, sram_oe_n, sram_wr_n, sram_lb_n, sram_ub_n
    - Signals: wr_vram, rd_vram

3. **palette**:
    - Inputs: vga_rd_data
    - Outputs: colour

#### Functional Description:
- **Sync Signal Generation**: Synchronization signals (vsync, hsync) are generated and delayed to accommodate memory access.
- **Memory Access**: Decoding logic for read/write operations to VRAM.
- **Read Data Muxing**: Multiplexing read data from VRAM or pixel coordinates.
- **Video Output**: RGB color output based on video on/off signal.
