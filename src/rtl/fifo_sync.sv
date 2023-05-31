module fifo_sync
#(
  parameter integer WRITE_DATA_WIDTH  = 8,
  parameter integer READ_DATA_WIDTH   = 8,
  parameter integer DATA_DEPTH        = 8,
  parameter integer PROG_EMPTY_THRESH = 0,
  parameter integer PROG_FULL_THRESH  = 0
)
(
    input  wire rst,
    input  wire clk,
    input  wire in_valid,
    output wire in_ready,
    input  wire[WRITE_DATA_WIDTH-1:0] in_data,
    output wire out_valid,
    input  wire out_ready,
    output wire[READ_DATA_WIDTH-1:0] out_data
);

assign wr_en     = in_valid & (~full);
assign in_ready  = (~full) & (~wr_rst_busy);
assign rd_en     = out_ready & (~empty);
assign out_valid = (~rd_rst_busy) & (~empty);


xpm_fifo_sync #(
   .CASCADE_HEIGHT(0),        // DECIMAL
   .DOUT_RESET_VALUE("0"),    // String
   .ECC_MODE("no_ecc"),       // String
   .FIFO_MEMORY_TYPE("auto"), // String
   .FIFO_READ_LATENCY(0),     // DECIMAL
   .FIFO_WRITE_DEPTH(DATA_DEPTH),   // DECIMAL
   .FULL_RESET_VALUE(0),      // DECIMAL
   .PROG_EMPTY_THRESH(PROG_EMPTY_THRESH),    // DECIMAL
   .PROG_FULL_THRESH(PROG_FULL_THRESH),     // DECIMAL
   .RD_DATA_COUNT_WIDTH(1),   // DECIMAL
   .READ_DATA_WIDTH(READ_DATA_WIDTH),      // DECIMAL
   .READ_MODE("std"),         // String
   .SIM_ASSERT_CHK(0),        // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
   .USE_ADV_FEATURES("0808"), // String
   .WAKEUP_TIME(0),           // DECIMAL
   .WRITE_DATA_WIDTH(WRITE_DATA_WIDTH),     // DECIMAL
   .WR_DATA_COUNT_WIDTH(1)    // DECIMAL
)
xpm_fifo_sync_inst (
   .almost_empty(almost_empty),
   .almost_full(almost_full),
   .data_valid(data_valid),
   .dbiterr(dbiterr),
   .dout(out_data),
   .empty(empty),
   .full(full),
   .overflow(overflow),
   .prog_empty(prog_empty),
   .prog_full(prog_full),
   .rd_data_count(rd_data_count),
   .rd_rst_busy(rd_rst_busy),
   .sbiterr(sbiterr),
   .underflow(underflow),
   .wr_ack(wr_ack),
   .wr_data_count(wr_data_count),
   .wr_rst_busy(wr_rst_busy),
   .din(in_data),
   .injectdbiterr(injectdbiterr),
   .injectsbiterr(injectsbiterr),
   .rd_en(rd_en),
   .rst(rst),
   .sleep(sleep),
   .wr_clk(clk),
   .wr_en(wr_en)
);

endmodule