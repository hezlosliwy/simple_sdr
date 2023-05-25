`timescale 1ns / 1ps

module tb_tx_path;

localparam CLK_PERIOD = 20;
localparam DATA_LEN   = 100*8;

logic clk, out_clk;
logic rst = 1'b1;
logic [11:0] o_I, o_Q;
logic o_valid;

logic fir_ready;
logic [11:0] fifo_I_output, fifo_Q_output;
logic [15:0] out_stream_data_i, out_stream_data_q;

logic [7:0] in_stream_data;

initial begin : system_clock
  clk = 1'b0;
  forever begin
    clk = #(CLK_PERIOD/2) ~clk;
  end
end

initial begin
  out_clk = 1'b0;
  forever begin
    out_clk = #(CLK_PERIOD/2*30) ~out_clk;
  end
end

axis_fsource #(
    .DATA_WIDTH_IN_BYTES(1),
    .FILE_NAME("tb.in")
) in_source
  (
    .clk(clk),
    .rst(rst),
    .out_data(in_stream_data),
    .out_valid(in_stream_valid),
    .out_ready(in_stream_ready),
    .eof()
  );

initial begin : main
  rst = 1'b1;
  repeat(4*16)@(posedge clk);
  rst = 1'b0;
end

logic tx_valid, tx_ready;
logic tx_data;

stream_resizer
#(
  .IN_WIDTH(8),
  .OUT_WIDTH(1)
) bch_resizer (
  .clk(clk),
  .rst(rst),
  .in_valid(in_stream_valid),
  .in_data(in_stream_data),
  .in_ready(in_stream_ready),
  .out_valid(tx_valid),
  .out_data(tx_data),
  .out_ready(tx_ready)
);

TX_path_top DUT (
  .clk(clk),
  .rst(rst),
  //internal output stream
  .out_valid(o_valid),
  .out_data({o_I, o_Q}), //i q
  .out_ready(fir_ready),
  //internal input stream
  .in_valid(tx_valid),
  .in_data(tx_data),
  .in_ready(tx_ready)
);

fifo_async
#(
  .WRITE_DATA_WIDTH(24),
  .READ_DATA_WIDTH(24),
  .DATA_DEPTH(16)
) in_fifo
(
    .rst(rst),
    .in_clk(clk),
    .in_valid(o_valid),
    .in_ready(fir_ready),
    .in_data({o_I, o_Q}),
    .out_clk(out_clk),
    .out_valid(fifo_out_valid),
    .out_ready(1'b1),
    .out_data({fifo_I_output, fifo_Q_output})
);

axis_fsource #(
    .DATA_WIDTH_IN_BYTES(4),
    .FILE_NAME("tb.out")
) out_source
  (
    .clk(out_clk),
    .rst(rst),
    .out_data({out_stream_data_i, out_stream_data_q}),
    .out_valid(out_stream_valid),
    .out_ready(fifo_out_valid),
    .eof()
  );


endmodule