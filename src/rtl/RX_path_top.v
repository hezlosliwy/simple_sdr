module RX_path_top (
    input wire clk,
    input wire rst,
    //internal output stream
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_out TVALID" *)
    output wire out_valid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_out TDATA" *)
    output wire [7:0] out_data, //i q
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_out TREADY" *)
    input wire out_ready,
    //internal input stream
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_in TVALID" *)
    input wire in_valid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_in TDATA" *)
    input wire [23:0] in_data,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_in TREADY" *)
    output wire in_ready
);

wire [1:0] pl_data;

physical_receiver my_receiver(
    .clk(clk),
    .rst(rst),
    .in_valid(in_valid),
    .in_data(in_data),
    .in_ready(in_ready),
    .out_valid(pl_valid),
    .out_data(pl_data)
  );

stream_resizer
  #(
    .IN_WIDTH(2),
    .OUT_WIDTH(1)
  ) bch_resizer (
    .clk(clk),
    .rst(rst),
    .in_valid(pl_valid),
    .in_data(pl_data),
    .in_ready(),
    .out_valid(resizer_bch_valid),
    .out_data(resizer_bch_data),
    .out_ready(resizer_bch_ready)
);

bch_decoder my_bch_decoder(
  .clk(clk),
  .rst(rst),
  .in_valid(resizer_bch_valid),
  .in_data(resizer_bch_data),
  .in_ready(resizer_bch_ready),
  .out_valid(decoder_valid),
  .out_data(decoder_data),
  .out_ready(decoder_ready)
);

stream_resizer
  #(
    .IN_WIDTH(1),
    .OUT_WIDTH(8)
  ) out_resizer (
    .clk(clk),
    .rst(rst),
    .in_valid(decoder_valid),
    .in_data(decoder_data),
    .in_ready(decoder_ready),
    .out_valid(out_valid),
    .out_data(out_data),
    .out_ready(out_ready)
);

endmodule
