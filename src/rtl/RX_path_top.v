module RX_path_top (
    input wire clk,
    input wire rst,
    //internal output stream
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_out TVALID" *)
    output wire out_valid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_out TDATA" *)
    output wire out_data,
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

wire [31:0] fir_data;

rx_filter my_fir(
  .aclk(clk),
  .aresetn(~rst),
  .s_axis_data_tvalid(in_valid),
  .s_axis_data_tdata({4'b0, in_data[23:12], 4'b0, in_data[11:0]}),
  .s_axis_data_tready(in_ready),
  .m_axis_data_tvalid(fir_valid),
  .m_axis_data_tdata(fir_data),
  .m_axis_data_tready(fir_ready)
);

physical_receiver my_receiver(
    .clk(clk),
    .rst(rst),
    .in_valid(fir_valid),
    .in_data({fir_data[27:16], fir_data[11:0]}),
    .in_ready(fir_ready),
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
  .out_valid(out_valid),
  .out_data(out_data),
  .out_ready(out_ready)
);

endmodule
