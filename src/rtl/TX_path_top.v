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
    input wire [1:0] in_data, // i q
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_in TREADY" *)
    output wire in_ready
);

wire qpsk_out_valid, header_ready, header_out_valid, delay_ready;
wire [11:0] i_out_data, q_out_data, i_out_header, q_out_header, out_fir_i, out_fir_q;
wire [31:0] fir_out;

qpsk_mod my_qpsk(
  .clk(clk),
  .rst_n(~rst),
  .in_i(in_data[1]),
  .in_q(in_data[0]),
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
  .out_ready(out_ready_fir),
  .out_valid(out_valid_fir),
  .out_i(out_fir_i),
  .out_q(out_fir_q)
);

fir_compiler_0 my_fir(
  .aclk(clk),
  .aresetn(~rst),
  .s_axis_data_tvalid(out_valid_fir),
  .s_axis_data_tdata({4'b0, out_fir_i, 4'b0, out_fir_q}),
  .s_axis_data_tready(out_ready_fir),
  .m_axis_data_tvalid(out_valid),
  .m_axis_data_tdata(fir_out),
  .m_axis_data_tready(out_ready)
);

assign out_data[23:12] = fir_out[27:16];
assign out_data[11:0] = fir_out[11:0];

endmodule
