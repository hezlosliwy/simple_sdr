module RX_path_top (
    input wire clk,
    input wire rst,
    //internal output stream
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_out TVALID" *)
    output wire out_valid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_out TDATA" *)
    output wire [1:0] out_data, //i q
    // (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_out TREADY" *)
    // input wire out_ready,
    //internal input stream
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_in TVALID" *)
    input wire in_valid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_in TDATA" *)
    input wire [23:0] in_data,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_in TREADY" *)
    output wire in_ready
);

physical_receiver my_receiver(
    .clk(clk),
    .rst(rst),
    .in_valid(in_valid),
    .in_data(in_data),
    .in_ready(in_ready),
    .out_valid(out_valid),
    .out_data(out_data)
  );

endmodule
