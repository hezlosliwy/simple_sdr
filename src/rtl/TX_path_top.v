module TX_path_top (
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
    //external input stream
    input wire in_I, // temporary
    input wire in_Q  // temporary
);

wire qpsk_out_valid, header_ready, header_out_valid, delay_ready;
wire [11:0] i_out_data, q_out_data, i_out_header, q_out_header;

qpsk_mod my_qpsk(
  .clk(clk),
  .rst_n(~rst),
  .in_i(in_I),
  .in_q(in_Q),
  .in_valid(in_valid),
  .in_ready(in_ready),
  .out_ready(header_ready),
  .out_valid(qpsk_out_valid),
  .out_i(i_out_data),
  .out_q(q_out_data)
);

header my_header(
  .clk(clk),
  .rst(rst),
  .in_valid(qpsk_out_valid),
  .in_i(i_out_data),
  .in_q(q_out_data),
  .in_ready(header_ready),
  // .out_valid(header_out_valid),
  // .out_i(i_out_header),
  // .out_q(q_out_header),
  // .out_ready(delay_ready)
  .out_ready(out_ready),
  .out_valid(out_valid),
  .out_i(out_data[23:12]),
  .out_q(out_data[11:0])
);

// hold_8_cycles my_delay (
//   .clk(clk),
//   .rst(rst),
//   .in_i(i_out_header),
//   .in_q(q_out_header),
//   .in_valid(header_out_valid),
//   .in_ready(delay_ready),

//   .out_ready(out_ready),
//   .out_valid(out_valid),
//   .out_i(out_data[23:12]),
//   .out_q(out_data[11:0])
// );

endmodule
