`timescale 1ns / 1ps

module top_ad9363_stream(
    input wire clk,
    input wire rst,
    //internal output stream
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_out TVALID" *)
    output wire out_valid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_out TDATA" *)
    output wire [23:0] out_data, //i q
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_out TREADY" *)
    input wire out_ready,
    //internal input stream
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_in TVALID" *)
    input wire in_valid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_in TDATA" *)
    input wire [23:0] in_data,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_in TREADY" *)
    output wire in_ready,
    //external output stream
    output wire fb_clk,
    output wire tx_frame,
    output wire [11:0] p1_d,
    //external input stream
    input wire data_clk,
    input wire rx_frame,
    input wire [11:0] p0_d
);

ad9363_stream my_ad9363_stream(
  .clk(clk),
  .rst(rst),
  //internal output stream
  .out_valid(out_valid),
  .out_data_i(out_data[23:12]),
  .out_data_q(out_data[11:0]),
  .out_ready(out_ready),
  //internal input stream
  .in_valid(in_valid),
  .in_data_i(in_data[23:12]),
  .in_data_q(in_data[11:0]),
  .in_ready(in_ready),
  //external output stream
  .fb_clk(fb_clk),
  .tx_frame(tx_frame),
  .p1_d(p1_d),
  //external input stream
  .data_clk(data_clk),
  .rx_frame(rx_frame),
  .p0_d(p0_d)
);

endmodule
